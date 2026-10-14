"""Restore an explicit read-only .dt into a new, marked workspace UAT clone.

Existing targets AND run directories are rejected; no files are deleted and no
backup/source snapshots are copied or overwritten. Failed attempts retain their
unmarked directories/logs for inspection. Each owned process has a 90s default
timeout. Only a successfully restored independent database receives a marker.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys
import uuid

import onec_runtime as runtime


WORKSPACE_ROOT = runtime.WORKSPACE_ROOT
DEFAULT = runtime.DEFAULT


def _target(target_path, run_id):
    root = WORKSPACE_ROOT.resolve(strict=True)
    if target_path is None:
        run_id = uuid.uuid4().hex if run_id is None else run_id
        target = root / 'scratch' / 'uat' / str(run_id) / 'ib'
    else:
        raw = str(target_path)
        target = Path(raw)
        if not target.is_absolute() or raw.startswith(('\\\\', '//')):
            raise runtime.RuntimeSafetyError('TargetPath must be an absolute local clone path')
        if run_id is not None and target.parent.name != run_id:
            raise runtime.RuntimeSafetyError('RunId must match the target parent directory')
        run_id = target.parent.name
    if (not isinstance(run_id, str) or not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_-]{0,127}', run_id)
            or any(part.casefold() in {'infobase', 'infobase_fulldata'} for part in target.parts)
            or any(char in str(target) for char in (';', '"', "'", '\r', '\n'))):
        raise runtime.RuntimeSafetyError('Unsafe target path or RunId')
    canonical = target.resolve()
    try:
        relative = canonical.relative_to(root)
    except ValueError as exc:
        raise runtime.RuntimeSafetyError('Target is outside the workspace UAT clone area') from exc
    if (target != canonical or relative.parts != ('scratch', 'uat', run_id, 'ib')
            or any(runtime._linked(path) for path in (target, *target.parents))):
        raise runtime.RuntimeSafetyError('Only canonical scratch/uat/<runid>/ib targets are allowed')
    return canonical, run_id


def _source(source_dt):
    try:
        source = Path(source_dt).resolve(strict=True)
        if not source.is_file() or source.suffix.casefold() != '.dt':
            raise runtime.RuntimeSafetyError('SourceDT must be an existing .dt file')
        return source
    except (OSError, ValueError, TypeError) as exc:
        raise runtime.RuntimeSafetyError('SourceDT must be an explicit readable .dt file') from exc


def _sha256(source):
    with source.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def create_clone(source_dt, target_path=None, run_id=None, exe_path=DEFAULT, timeout=90):
    """Create a fresh clone; return its provenance, or raise RuntimeSafetyError.

    An omitted target selects a UUID directory. An explicit target's parent is
    its RunId; a supplied RunId must agree. A failed run directory is never reused.
    """
    target, run_id = _target(target_path, run_id)
    source = _source(source_dt)
    if target.exists() or runtime._linked(target) or target.parent.exists() or runtime._linked(target.parent):
        raise runtime.RuntimeSafetyError('Target or run directory already exists; nothing will be overwritten')
    source_hash = _sha256(source)
    try:
        # exist_ok=False reserves this run and refuses concurrent reuse.
        target.parent.mkdir(parents=True, exist_ok=False)
        _target(target, run_id)
        target.mkdir(exist_ok=False)
        directory = target.parent / 'results'
        directory.mkdir(exist_ok=False)
        create_log = directory / 'create.log'
        restore_log = directory / 'restore.log'
        # Python's Windows list serialization escapes embedded double quotes
        # with backslashes, which 1C's command parser does not treat as escapes.
        connection = f"File='{target}';" if any(char.isspace() for char in str(target)) else f'File={target};'
        runtime._execute(exe_path, ['CREATEINFOBASE', connection,
            '/DisableStartupDialogs', '/DisableStartupMessages', '/OUT', str(create_log)], timeout)
        _target(target, run_id)
        runtime._execute(exe_path, ['DESIGNER', '/F', str(target), '/RestoreIB', str(source),
            '/DisableStartupDialogs', '/DisableStartupMessages', '/OUT', str(restore_log)], timeout)
        _target(target, run_id)
        database = target / '1Cv8.1CD'
        if not database.is_file() or runtime._linked(database) or database.stat().st_nlink != 1:
            raise runtime.RuntimeSafetyError('Restore produced no independent regular 1Cv8.1CD file')
        if _source(source_dt) != source or _sha256(source) != source_hash:
            raise runtime.RuntimeSafetyError('Source snapshot changed during clone creation')
        marker = {'ib_path': str(target), 'source_sha256': source_hash}
        with (target.parent / '.uat-clone.json').open('x', encoding='utf-8') as stream:
            json.dump(marker, stream)
        runtime.validate_clone(target)
    except (OSError, ValueError) as exc:
        raise runtime.RuntimeSafetyError('Clone creation failed; any partial run remains unmarked') from exc
    return {'status': 'PASS', 'run_id': run_id, **marker,
            'logs': [str(create_log), str(restore_log)]}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-dt', required=True)
    parser.add_argument('--target-path', help='New absolute workspace scratch/uat/<runid>/ib')
    parser.add_argument('--run-id', help='New run directory name; defaults to UUID')
    parser.add_argument('--exe-path', default=DEFAULT)
    parser.add_argument('--timeout', type=float, default=90)
    args = parser.parse_args(argv)
    try:
        result = create_clone(args.source_dt, args.target_path, args.run_id, args.exe_path, args.timeout)
    except (runtime.RuntimeSafetyError, OSError, ValueError, TypeError) as exc:
        print(json.dumps({'status': 'FAIL', 'error': str(exc)}))
        return 1
    print(json.dumps(result, ensure_ascii=True))
    return 0


if __name__ == '__main__':
    sys.exit(main())
