"""Clone-only positive sample: real maker sessions, then genuine checker sessions.

Full mode produces 210 VND documents (10 per month); --smoke produces 10.
This is supplementary bounded UAT coverage, not the legacy full/massive-volume
seed (approximately 4,800+ documents); that financial coverage remains NOT_RUN.
Original generator entries, guards, collision behavior and batches are retained.
Admin prepares metadata and brackets the run with enable/restore only.
This command requires the RunSeedWorkflow application dispatch integration.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import sys
import time
import uuid

import onec_runtime as runtime


MAKERS = {'ar': 'ketoan_ar', 'ap': 'ketoan_ap', 'netting': 'chuyenvien_doisoat'}
DOCUMENTS = {
    'ar': ['BienBanNghiemThuGiaiDoan', 'HoaDonGTGTDauRa',
           'BienBanNghiemThuGiaiDoan', 'HoaDonGTGTDauRa', 'BaoCoNganHang'],
    'ap': ['HoaDonNhaCungCap', 'HoaDonNhaCungCap', 'UyNhiemChi'],
    'netting': ['CanTruCongNoNoiBo', 'BangKeDoiSoatKenhThanhToan'],
}
MODES = {'clean': (), 'master': (), 'massive': (), 'ar': ('ar',),
         'ap': ('ar', 'ap'), 'netting': ('ar', 'ap', 'netting'),
         'full': ('ar', 'ap', 'netting')}


def validate_manifest(path, run_id, domain, months, started_ns):
    """Require fresh correlated exact-reference evidence; never query global counts."""
    path = Path(path)
    if (not path.is_file() or runtime._linked(path) or path.stat().st_nlink != 1
            or not started_ns <= path.stat().st_mtime_ns <= time.time_ns()):
        raise runtime.RuntimeSafetyError('Seed manifest is missing, linked, or stale')
    data = runtime._read_json(path)
    if (not isinstance(data, dict) or set(data) != {
            'run_id', 'phase', 'months', 'maker', 'checker', 'refs'}
            or data['run_id'] != run_id or data['phase'] != domain
            or type(data['months']) is not int or data['months'] != months
            or data['maker'] != MAKERS[domain] or data['checker'] != 'ketoan_truong'
            or not isinstance(data['refs'], list)):
        raise runtime.RuntimeSafetyError('Seed manifest has an invalid schema or identity')
    seen = set()
    names = []
    for item in data['refs']:
        if (not isinstance(item, dict) or set(item) != {'document', 'uuid'}
                or item['document'] not in DOCUMENTS[domain]
                or not isinstance(item['uuid'], str)
                or not re.fullmatch(r'[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}', item['uuid'])
                or item['uuid'] == '00000000-0000-0000-0000-000000000000'):
            raise runtime.RuntimeSafetyError('Invalid seed document reference')
        key = (item['document'], item['uuid'])
        if key in seen:
            raise runtime.RuntimeSafetyError('Duplicate seed reference')
        seen.add(key)
        names.append(item['document'])
    if names != DOCUMENTS[domain] * months:
        raise runtime.RuntimeSafetyError('Seed manifest has missing, extra, or unordered references')
    return data


def run_workflow(mode, ib_path, *, smoke=False, admin_user='Admin', timeout=90,
                 exe_path=runtime.DEFAULT):
    """Return PASS only after every exact phase result and flag restoration pass.

    AP/netting modes include the financial prerequisites that fund their payments.
    A clone-local exclusive lock serializes enable/restore across host seed runs.
    Runtime failures leave their per-phase evidence intact and raise, never PASS.
    """
    if mode not in MODES or admin_user != 'Admin' or type(smoke) is not bool:
        raise runtime.RuntimeSafetyError('Invalid mode, smoke flag, or explicit Admin metadata user')
    ib = runtime.validate_clone(ib_path)
    directory = runtime._result_directory(ib)
    if any(char in str(directory) for char in ';"\r\n'):
        raise runtime.RuntimeSafetyError('Evidence paths contain command delimiters')
    run_id = uuid.uuid4().hex
    control = directory / (run_id + '-control.manifest.json')
    results = []
    manifests = []
    lock = directory / 'seed-workflow.lock'
    try:
        fd = os.open(lock, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    except OSError as exc:
        raise runtime.RuntimeSafetyError('Clone already has a seed-workflow lock; investigate its owner') from exc
    os.close(fd)

    def phase(name, user, manifest):
        runtime.validate_clone(ib)
        if runtime._result_directory(ib) != directory:
            raise runtime.RuntimeSafetyError('Results directory changed during seed run')
        output = directory / (run_id + '-' + name + '.json')
        if output.exists() or runtime._linked(output):
            raise runtime.RuntimeSafetyError('Refusing to overwrite seed result evidence')
        started = time.time_ns()
        runtime._execute(exe_path, ['ENTERPRISE', '/F', str(ib), '/N', user, '/C',
            f'RunSeedWorkflow;{run_id};{output};{name};{manifest}',
            '/DisableStartupMessages', '/DisableStartupDialogs'], timeout)
        runtime.validate_clone(ib)
        if runtime._result_directory(ib) != directory:
            raise runtime.RuntimeSafetyError('Results directory changed during seed run')
        result = runtime.validate_result(output, run_id, (name,), started)
        results.append({'phase': name, 'user': user, 'result_path': str(output), 'result': result})
        return started

    try:
        try:
            phase('enable', admin_user, control)
            prior = runtime._read_json(control)
            if (runtime._linked(control) or not control.is_file() or control.stat().st_nlink != 1
                    or not isinstance(prior, dict) or set(prior) != {'run_id', 'prior_enabled'}
                    or prior['run_id'] != run_id or type(prior['prior_enabled']) is not bool):
                raise runtime.RuntimeSafetyError('Invalid seed flag restoration snapshot')
            control_digest = hashlib.sha256(control.read_bytes()).digest()
            metadata_phase = 'clean' if mode == 'clean' else 'master'
            phase(metadata_phase, admin_user, control)
            months = 1 if smoke else 21
            for domain in MODES[mode]:
                manifest = directory / (run_id + '-' + domain + '.manifest.json')
                if manifest.exists() or runtime._linked(manifest):
                    raise runtime.RuntimeSafetyError('Refusing to overwrite seed manifest evidence')
                started = phase(domain + ('-smoke' if smoke else ''), MAKERS[domain], manifest)
                validate_manifest(manifest, run_id, domain, months, started)
                digest = hashlib.sha256(manifest.read_bytes()).hexdigest()
                phase('check-' + domain, 'ketoan_truong', manifest)
                validate_manifest(manifest, run_id, domain, months, started)
                if hashlib.sha256(manifest.read_bytes()).hexdigest() != digest:
                    raise runtime.RuntimeSafetyError('Checker changed the produced-reference manifest')
                manifests.append({'phase': domain, 'path': str(manifest), 'sha256': digest})
            if hashlib.sha256(control.read_bytes()).digest() != control_digest:
                raise runtime.RuntimeSafetyError('Seed flag restoration snapshot changed')
        finally:
            # enable writes its snapshot before mutating the flag, even if its result fails.
            try:
                phase('restore', admin_user, control)
            except Exception as exc:
                raise runtime.RuntimeSafetyError('Seed flag restore failed: ' + str(exc)) from exc
    finally:
        lock.unlink()
    return {'run_id': run_id, 'status': 'PASS', 'mode': mode,
            'coverage': 'bounded-positive-uat' if MODES[mode] else 'admin-metadata-only',
            'legacy_full_volume': 'NOT_RUN',
            'months': 1 if smoke else 21, 'phases': results, 'manifests': manifests}


def run_cli(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=MODES)
    parser.add_argument('--ib-path', required=True)
    parser.add_argument('--user', default='Admin', help='Explicit metadata session only; financial users are fixed')
    parser.add_argument('--exe-path', default=runtime.DEFAULT)
    parser.add_argument('--timeout', type=float, default=90)
    parser.add_argument('--smoke', action='store_true', help='One month, ten financial documents')
    args = parser.parse_args(argv)
    try:
        result = run_workflow(args.mode, args.ib_path, smoke=args.smoke,
            admin_user=args.user, timeout=args.timeout, exe_path=args.exe_path)
        print(json.dumps(result, ensure_ascii=True))
        return 0
    except (runtime.RuntimeSafetyError, OSError, ValueError, TypeError) as exc:
        print(json.dumps({'status': 'FAIL', 'error': str(exc)}))
        return 1


if __name__ == '__main__':
    sys.exit(run_cli())
