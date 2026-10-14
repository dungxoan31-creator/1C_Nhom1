"""Clone-only 1C runtime entry point; stdout is never test evidence.

Only registered BSL commands have a structured contract. Legacy Seed* commands,
TestUserLogin and RunUATSecurityProof remain NOT_RUN: they are never launched or
inferred from event-log text. RunRBACChecks proves ActualRole and PermissionBoundary
per user. VerifyContractFees, VerifyGLAnalyticKeys and ExportTrialBalanceEvidence
are read-only structured commands; each has one case named exactly as its command.
The exporter writes data to result_path + '.evidence.json'; the helper returns
only the strict {run_id,status,cases} result. No fee updates or backfills run here.
exe_path normally names an executable; a sequence supplies a launcher prefix
(e.g. Python plus a fixture script) without a shell.
"""
import argparse
import json
import math
import os
from pathlib import Path
import re
import subprocess
import sys
import time
import uuid


WORKSPACE_ROOT = Path(__file__).resolve().parent.parent
DEFAULT = os.environ.get('ONEC_EXE_PATH', str(
    Path(os.environ.get('ProgramFiles(x86)', r'C:\Program Files (x86)'))
    / '1cv8t' / '8.3.22.1704' / 'bin' / '1cv8t.exe'))
EXPECTED_CASES = {
    'RunUnitTests': ('SecurityAndSoD', 'GLSubledger'),
    'RunPostingLifecycleTests': ('ZeroResidual', 'RepostParity', 'GLSubledger'),
    'RunHardeningUAT': ('SeedSafety', 'SeedTransactions', 'StateGuard'),
    'RunSecurityTests': ('SecurityAndSoD',),
    'RunRBACChecks': ('ActualRole', 'PermissionBoundary'),
    'VerifyContractFees': ('VerifyContractFees',),
    'VerifyGLAnalyticKeys': ('VerifyGLAnalyticKeys',),
    'ExportTrialBalanceEvidence': ('ExportTrialBalanceEvidence',),
}


class RuntimeSafetyError(RuntimeError):
    """An unsafe target, failed process, or unproven result."""


class RuntimeNotRun(RuntimeSafetyError):
    """No structured BSL evidence exists for this command yet."""


def _json_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise RuntimeSafetyError('Duplicate JSON key: ' + key)
        result[key] = value
    return result


def _read_json(path):
    try:
        return json.loads(path.read_text(encoding='utf-8-sig'), object_pairs_hook=_json_object)
    except (OSError, UnicodeError, ValueError) as exc:
        raise RuntimeSafetyError(f'Missing or malformed JSON: {path}') from exc


def _linked(path):
    return path.is_symlink() or getattr(path, 'is_junction', lambda: False)()


def validate_clone(ib_path):
    """Return the canonical local scratch/uat/<runid>/ib with a bound marker.

    source_sha256 is provenance supplied by the clone creator; validation does
    not pretend to recompute the source backup's hash from a mutated clone.
    """
    raw = str(ib_path)
    if not raw or any(char in raw for char in ';"\r\n'):
        raise RuntimeSafetyError('IBPath must be an explicit canonical local clone path')
    target = Path(raw)
    if not target.is_absolute() or raw.startswith(('\\\\', '//')):
        raise RuntimeSafetyError('IBPath must be an absolute local clone path')
    protected = {'infobase', 'infobase_fulldata'}
    if any(part.casefold() in protected for part in target.parts):
        raise RuntimeSafetyError('Protected infobase path is forbidden')
    try:
        canonical = target.resolve(strict=True)
        relative = canonical.relative_to(WORKSPACE_ROOT.resolve())
    except (OSError, ValueError, RuntimeError) as exc:
        raise RuntimeSafetyError('IBPath is outside the workspace clone area or does not exist') from exc
    if (target != canonical or not canonical.is_dir() or len(relative.parts) != 4
            or tuple(part.casefold() for part in relative.parts[:2]) != ('scratch', 'uat')
            or relative.parts[-1].casefold() != 'ib'):
        raise RuntimeSafetyError('Only canonical scratch/uat/<runid>/ib clones are allowed')
    if any(_linked(path) for path in (canonical, *canonical.parents)):
        raise RuntimeSafetyError('Clone paths may not contain symlinks or junctions')
    marker = canonical.parent / '.uat-clone.json'
    if _linked(marker):
        raise RuntimeSafetyError('Clone marker may not be a link')
    metadata = _read_json(marker)
    if not isinstance(metadata, dict):
        raise RuntimeSafetyError('Clone marker must be a JSON object')
    marked = metadata.get('ib_path')
    source_hash = metadata.get('source_sha256')
    if (not isinstance(marked, str) or not Path(marked).is_absolute()
            or Path(marked) != canonical or str(Path(marked)) != str(Path(marked).resolve())
            or not isinstance(source_hash, str) or not re.fullmatch(r'[0-9a-fA-F]{64}', source_hash)):
        raise RuntimeSafetyError('Clone marker must bind the canonical IBPath and source SHA-256')
    database = canonical / '1Cv8.1CD'
    if not database.is_file() or _linked(database) or database.stat().st_nlink != 1:
        raise RuntimeSafetyError('Clone database must be an independent regular 1Cv8.1CD file')
    return canonical


def _result_directory(ib_path):
    directory = ib_path.parent / 'results'
    if _linked(directory):
        raise RuntimeSafetyError('Results directory may not be a link')
    directory.mkdir(exist_ok=True)
    if directory.resolve() != directory:
        raise RuntimeSafetyError('Results directory escapes the clone')
    return directory


def _execute(exe_path, arguments, timeout):
    if isinstance(timeout, bool) or not isinstance(timeout, (int, float)) or not math.isfinite(timeout) or timeout <= 0:
        raise RuntimeSafetyError('Timeout must be a positive finite number')
    prefix = [str(exe_path)] if isinstance(exe_path, (str, os.PathLike)) else list(exe_path)
    if not prefix:
        raise RuntimeSafetyError('An executable path is required')
    try:
        # subprocess.run kills and waits only for the child it owns on timeout.
        process = subprocess.run(prefix + arguments, capture_output=True, timeout=timeout,
            creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0)
    except subprocess.TimeoutExpired as exc:
        raise RuntimeSafetyError(f'Owned runtime process timed out after {timeout}s') from exc
    except OSError as exc:
        raise RuntimeSafetyError('Unable to launch runtime executable') from exc
    if process.returncode != 0:
        raise RuntimeSafetyError(f'Runtime process exited with code {process.returncode}')


def validate_result(result_path, run_id, expected_cases, started_ns):
    """Accept only fresh, exact-schema, correlated evidence with every case true."""
    path = Path(result_path)
    if (not path.is_file() or _linked(path) or path.stat().st_nlink != 1
            or not started_ns <= path.stat().st_mtime_ns <= time.time_ns()):
        raise RuntimeSafetyError('Result is missing, linked, or stale')
    result = _read_json(path)
    if (not isinstance(result, dict) or set(result) != {'run_id', 'status', 'cases'}
            or result['run_id'] != run_id or result['status'] not in ('PASS', 'FAIL')
            or not isinstance(result['cases'], list) or not result['cases']):
        raise RuntimeSafetyError('Result has an invalid schema, run ID, or empty case list')
    names = []
    for case in result['cases']:
        if (not isinstance(case, dict) or set(case) != {'name', 'passed', 'error'}
                or not isinstance(case['name'], str) or not case['name'].strip()
                or type(case['passed']) is not bool or not isinstance(case['error'], str)):
            raise RuntimeSafetyError('Malformed case result')
        names.append(case['name'])
        if not case['passed']:
            raise RuntimeSafetyError(f"Case failed: {case['name']}: {case['error']}")
        if case['error']:
            raise RuntimeSafetyError(f"Passing case carries an error: {case['name']}: {case['error']}")
    if (not expected_cases or len(names) != len(set(names))
            or set(names) != set(expected_cases) or result['status'] != 'PASS'):
        raise RuntimeSafetyError('Result failed or has duplicate, missing, or unexpected cases')
    return result


def run_command(command, ib_path, user='Admin', expected_cases=(), timeout=90, exe_path=DEFAULT):
    """Run a registered BSL command and return its validated result dict.

    Raises RuntimeSafetyError (RuntimeNotRun for legacy commands). No log
    substring or zero process exit alone can yield PASS.
    """
    ib = validate_clone(ib_path)
    if not isinstance(command, str) or not re.fullmatch(r'[A-Za-z][A-Za-z0-9]*', command):
        raise RuntimeSafetyError('Invalid runtime command')
    if command not in EXPECTED_CASES:
        raise RuntimeNotRun(f'{command}: structured BSL results are not implemented')
    expected = tuple(expected_cases)
    if (not expected or any(not isinstance(name, str) or not name.strip() for name in expected)
            or len(expected) != len(set(expected)) or set(expected) != set(EXPECTED_CASES[command])):
        raise RuntimeSafetyError('Expected cases must match the registered command exactly')
    run_id = uuid.uuid4().hex
    result_path = _result_directory(ib) / (run_id + '.json')
    if result_path.exists() or _linked(result_path):
        raise RuntimeSafetyError('Unique result path already exists; refusing to overwrite evidence')
    started_ns = time.time_ns()
    _execute(exe_path, ['ENTERPRISE', '/F', str(ib), '/N', user,
        '/C', f'{command};{run_id};{result_path}',
        '/DisableStartupMessages', '/DisableStartupDialogs'], timeout)
    validate_clone(ib)
    if _result_directory(ib) != result_path.parent:
        raise RuntimeSafetyError('Results directory changed during the run')
    return validate_result(result_path, run_id, expected, started_ns)


def run_registered(command, ib_path, user='Admin', timeout=90, exe_path=DEFAULT):
    """Run with the registry's exact expected cases; legacy commands stay NOT_RUN."""
    return run_command(command, ib_path, user,
        EXPECTED_CASES.get(command, ()), timeout, exe_path)


def update_database(ib_path, source_path, user='Admin', password='', timeout=90, exe_path=DEFAULT):
    """Designer load then update; stop immediately on any failed exit or timeout."""
    ib = validate_clone(ib_path)
    source = Path(source_path).resolve(strict=True)
    if not source.is_dir():
        raise RuntimeSafetyError('SourcePath must name an existing configuration directory')
    run_id = uuid.uuid4().hex
    directory = _result_directory(ib)
    common = ['DESIGNER', '/F', str(ib), '/N', user]
    if password:
        common += ['/P', password]
    logs = []
    for stage, arguments in (('load', ['/LoadConfigFromFiles', str(source)]), ('update', ['/UpdateDBCfg'])):
        validate_clone(ib)
        log = directory / f'{run_id}-{stage}.log'
        if log.exists() or _linked(log):
            raise RuntimeSafetyError('Designer log already exists')
        _execute(exe_path, common + arguments + ['/DisableStartupMessages',
            '/DisableStartupDialogs', '/OUT', str(log)], timeout)
        logs.append(str(log))
    return {'run_id': run_id, 'status': 'PASS', 'logs': logs}


def run_cli(command=None, argv=None):
    """Shared wrapper CLI. Returns 0 only for validated PASS, otherwise 1 (usage: 2)."""
    parser = argparse.ArgumentParser(description=__doc__)
    if command is None:
        parser.add_argument('command', help='BSL command, or update-db')
    parser.add_argument('--ib-path', required=True, help='Canonical marked scratch/uat/<runid>/ib')
    parser.add_argument('--exe-path', default=DEFAULT)
    parser.add_argument('--user', help='Defaults to the lifecycle checker, otherwise Admin')
    parser.add_argument('--timeout', type=float, default=90)
    parser.add_argument('--source-path', default=str(WORKSPACE_ROOT / 'src'))
    parser.add_argument('--password', default='', help='Designer authentication only')
    args = parser.parse_args(argv)
    selected = command if command is not None else args.command
    user = args.user or ('ketoan_truong' if selected == 'RunPostingLifecycleTests' else 'Admin')
    try:
        if selected == 'update-db':
            result = update_database(args.ib_path, args.source_path, user, args.password,
                args.timeout, args.exe_path)
        else:
            if args.password:
                raise RuntimeSafetyError('--password is supported only for Designer update-db')
            result = run_registered(selected, args.ib_path, user,
                args.timeout, args.exe_path)
        print(json.dumps(result, ensure_ascii=True))
        return 0
    except RuntimeNotRun as exc:
        print(json.dumps({'status': 'NOT_RUN', 'error': str(exc)}))
        return 1
    except (RuntimeSafetyError, OSError, ValueError, TypeError) as exc:
        print(json.dumps({'status': 'FAIL', 'error': str(exc)}))
        return 1


if __name__ == '__main__':
    sys.exit(run_cli())
