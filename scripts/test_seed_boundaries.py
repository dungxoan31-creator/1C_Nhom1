"""Supplementary ATOMIC AR collision boundaries; never legacy 50-document batches.

Native run: --ib-path <canonical prepared Full clone>. Exactly three sessions:
Admin enable, ketoan_ar RunSeedBoundaries, Admin restore (also on failure).
--self-test uses Python fixture children only and never launches native 1C.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import sys
import tempfile
import time
import unittest
import uuid
from unittest.mock import patch

import onec_runtime as runtime

CASES = ('Boundary1', 'Boundary49', 'Boundary50', 'Boundary51')


def run_boundaries(ib_path, *, timeout=90, exe_path=runtime.DEFAULT):
    """Enable, execute real AR boundaries, restore; PASS requires all evidence."""
    ib = runtime.validate_clone(ib_path)
    directory = runtime._result_directory(ib)
    if any(char in str(directory) for char in ';"\r\n'):
        raise runtime.RuntimeSafetyError('Invalid evidence path delimiters')
    run_id = uuid.uuid4().hex
    control = directory / (run_id + '-control.manifest.json')
    lock = directory / 'seed-workflow.lock'
    try:
        fd = os.open(lock, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    except OSError as exc:
        raise runtime.RuntimeSafetyError('Clone has an existing seed-workflow lock; investigate its owner') from exc
    os.close(fd)
    phases = []

    def phase(name, user):
        runtime.validate_clone(ib)
        if runtime._result_directory(ib) != directory:
            raise runtime.RuntimeSafetyError('Evidence directory changed')
        output = directory / (run_id + '-' + name + '.json')
        if output.exists() or runtime._linked(output):
            raise runtime.RuntimeSafetyError('Refusing to overwrite boundary evidence')
        command = (f'RunSeedBoundaries;{run_id};{output}' if name == 'boundaries' else
                   f'RunSeedWorkflow;{run_id};{output};{name};{control}')
        expected = CASES if name == 'boundaries' else (name,)
        started = time.time_ns()
        runtime._execute(exe_path, ['ENTERPRISE', '/F', str(ib), '/N', user,
            '/C', command, '/DisableStartupMessages', '/DisableStartupDialogs'], timeout)
        runtime.validate_clone(ib)
        if runtime._result_directory(ib) != directory:
            raise runtime.RuntimeSafetyError('Evidence directory changed')
        result = runtime.validate_result(output, run_id, expected, started)
        phases.append({'phase': name, 'user': user, 'result_path': str(output), 'result': result})
        return started

    try:
        try:
            started = phase('enable', 'Admin')
            if (not control.is_file() or runtime._linked(control) or control.stat().st_nlink != 1
                    or not started <= control.stat().st_mtime_ns <= time.time_ns()):
                raise runtime.RuntimeSafetyError('Invalid flag snapshot file')
            snapshot = runtime._read_json(control)
            if (not isinstance(snapshot, dict) or set(snapshot) != {'run_id', 'prior_enabled'}
                    or snapshot['run_id'] != run_id or type(snapshot['prior_enabled']) is not bool):
                raise runtime.RuntimeSafetyError('Invalid flag snapshot schema')
            digest = hashlib.sha256(control.read_bytes()).digest()
            phase('boundaries', 'ketoan_ar')
            if hashlib.sha256(control.read_bytes()).digest() != digest:
                raise runtime.RuntimeSafetyError('Flag snapshot changed during boundary tests')
        finally:
            try:
                phase('restore', 'Admin')
            except Exception as exc:
                raise runtime.RuntimeSafetyError('Boundary flag restore failed: ' + str(exc)) from exc
    finally:
        lock.unlink()
    return {'run_id': run_id, 'status': 'PASS', 'mode': 'supplementary-atomic-ar',
            'legacy_batch50': 'NOT_RUN', 'phases': phases}


FIXTURE = r'''
import json, os, pathlib, sys, time
mode = sys.argv[1]
args = sys.argv[2:]
ib = pathlib.Path(args[args.index('/F') + 1])
user = args[args.index('/N') + 1]
parts = args[args.index('/C') + 1].split(';')
command, run_id, output = parts[:3]
root = ib.parent
with (root / 'launches.jsonl').open('a') as stream:
    stream.write(json.dumps({'user': user, 'parts': parts}) + '\n')
flag = root / 'flag.json'
if command == 'RunSeedWorkflow':
    assert len(parts) == 5 and user == 'Admin'
    phase, manifest = parts[3:]
    snapshot = pathlib.Path(manifest)
    if phase == 'enable':
        snapshot.write_text(json.dumps({'run_id': run_id, 'prior_enabled': json.loads(flag.read_text())}))
        flag.write_text('true')
    elif phase == 'restore':
        flag.write_text(json.dumps(json.loads(snapshot.read_text())['prior_enabled']))
    else:
        raise AssertionError('unexpected metadata preparation')
    cases = [phase]
    if mode == phase + '_fail': sys.exit(8)
else:
    assert command == 'RunSeedBoundaries' and len(parts) == 3 and user == 'ketoan_ar'
    assert json.loads(flag.read_text()) is True
    cases = ['Boundary1', 'Boundary49', 'Boundary50', 'Boundary51']
    if mode == 'missing': sys.exit(0)
data = {'run_id': run_id, 'status': 'PASS',
        'cases': [{'name': name, 'passed': True, 'error': ''} for name in cases]}
if command == 'RunSeedBoundaries':
    if mode == 'wrong_id': data['run_id'] = 'old'
    if mode == 'false': data['cases'][2].update(passed=False, error='atomic rollback failed')
    if mode == 'missing_case': data['cases'].pop()
path = pathlib.Path(output)
path.write_text(json.dumps(data), encoding='utf-8')
stamp = time.time_ns()
os.utime(path, ns=(stamp, stamp))
'''


def self_test():
    class OfflineTests(unittest.TestCase):
        def setUp(self):
            self.temp = tempfile.TemporaryDirectory(prefix='seed boundaries ')
            self.addCleanup(self.temp.cleanup)
            self.root = Path(self.temp.name).resolve()
            self.ib = self.root / 'scratch' / 'uat' / 'fixture' / 'ib'
            self.ib.mkdir(parents=True)
            (self.ib / '1Cv8.1CD').write_bytes(b'offline fixture, not an infobase')
            (self.ib.parent / '.uat-clone.json').write_text(json.dumps({
                'ib_path': str(self.ib), 'source_sha256': 'a' * 64}), encoding='utf-8')
            self.flag = self.ib.parent / 'flag.json'
            self.flag.write_text('false')
            self.child = self.root / 'fixture.py'
            self.child.write_text(FIXTURE, encoding='utf-8')
            patcher = patch.object(runtime, 'WORKSPACE_ROOT', self.root)
            patcher.start()
            self.addCleanup(patcher.stop)

        def run_fixture(self, mode='pass'):
            return run_boundaries(self.ib, exe_path=(sys.executable, str(self.child), mode))

        def launches(self):
            return [json.loads(line) for line in (self.ib.parent / 'launches.jsonl').read_text().splitlines()]

        def test_exact_three_sessions_and_atomic_scope(self):
            result = self.run_fixture()
            self.assertEqual(result['status'], 'PASS')
            self.assertEqual(result['mode'], 'supplementary-atomic-ar')
            self.assertEqual(result['legacy_batch50'], 'NOT_RUN')
            self.assertEqual([entry['user'] for entry in self.launches()], ['Admin', 'ketoan_ar', 'Admin'])
            self.assertEqual([len(entry['parts']) for entry in self.launches()], [5, 3, 5])
            self.assertEqual([case['name'] for case in result['phases'][1]['result']['cases']], list(CASES))
            self.assertFalse(json.loads(self.flag.read_text()))

        def test_invalid_boundary_evidence_always_restores(self):
            for mode in ('missing', 'false', 'wrong_id', 'missing_case'):
                with self.subTest(mode=mode), self.assertRaises(runtime.RuntimeSafetyError):
                    self.run_fixture(mode)
                self.assertEqual(self.launches()[-1]['parts'][3], 'restore')
                self.assertFalse(json.loads(self.flag.read_text()))

        def test_failed_enable_still_restores(self):
            with self.assertRaises(runtime.RuntimeSafetyError):
                self.run_fixture('enable_fail')
            self.assertEqual([entry['parts'][3] for entry in self.launches()], ['enable', 'restore'])
            self.assertFalse(json.loads(self.flag.read_text()))

        def test_restore_failure_cannot_pass(self):
            with self.assertRaisesRegex(runtime.RuntimeSafetyError, 'restore'):
                self.run_fixture('restore_fail')

        def test_prior_enabled_flag_is_preserved(self):
            self.flag.write_text('true')
            self.run_fixture()
            self.assertTrue(json.loads(self.flag.read_text()))

        def test_unsafe_clone_and_existing_lock_never_launch(self):
            with self.assertRaises(runtime.RuntimeSafetyError):
                run_boundaries(self.root / 'infobase', exe_path=(sys.executable, str(self.child), 'pass'))
            self.assertFalse((self.ib.parent / 'launches.jsonl').exists())
            directory = runtime._result_directory(self.ib)
            lock = directory / 'seed-workflow.lock'
            lock.write_text('another owner')
            with self.assertRaises(runtime.RuntimeSafetyError):
                self.run_fixture()
            self.assertFalse((self.ib.parent / 'launches.jsonl').exists())
            self.assertEqual(lock.read_text(), 'another owner')

    result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(OfflineTests))
    return 0 if result.wasSuccessful() else 1


def run_cli(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--self-test', action='store_true')
    parser.add_argument('--ib-path')
    parser.add_argument('--exe-path', default=runtime.DEFAULT)
    parser.add_argument('--timeout', type=float, default=90)
    args = parser.parse_args(argv)
    if args.self_test:
        return self_test()
    if not args.ib_path:
        parser.error('--ib-path is required for the native boundary run')
    try:
        print(json.dumps(run_boundaries(args.ib_path, exe_path=args.exe_path, timeout=args.timeout)))
        return 0
    except (runtime.RuntimeSafetyError, OSError, ValueError, TypeError) as exc:
        print(json.dumps({'status': 'FAIL', 'mode': 'supplementary-atomic-ar', 'error': str(exc)}))
        return 1


if __name__ == '__main__':
    sys.exit(run_cli())
