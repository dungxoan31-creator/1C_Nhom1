"""Three-phase native characterization; main provisions and compiles the clone.

Route /C RunNettingReversal;run_id;result_path;phase;fixture_path to
NettingReversalTestsServer.RunNettingReversalCharacterization.
--self-test runs offline only. These sequential checks do not prove concurrency.
Passwords: ONEC_AR_PASSWORD, ONEC_MAKER_PASSWORD, ONEC_CHECKER_PASSWORD.
"""

import argparse
import io
import json
import os
from pathlib import Path
import sys
import tempfile
import time
import unittest
import uuid
from contextlib import redirect_stdout
from unittest.mock import patch

import onec_runtime


CHARACTERIZATION_CASES = (
    'backdated_netting', 'netting_repost', 'foreign_units',
    'current_ap_exhausted', 'current_ar_exhausted', 'duplicate_reversal',
)


def run_netting_reversal(ib_path, timeout=90, exe_path=onec_runtime.DEFAULT):
    """Return PASS only after all real-user phases supply fresh exact evidence."""
    ib = onec_runtime.validate_clone(ib_path)
    directory = onec_runtime._result_directory(ib)
    run_id = uuid.uuid4().hex
    fixture = directory / f'{run_id}-fixture.json'
    with fixture.open('x', encoding='utf-8') as stream:
        json.dump({'run_id': run_id}, stream)
    for phase, user, expected in (
        ('prepare-ar', 'ketoan_ar', ('prepare-ar',)),
        ('prepare', 'ketoan_ap', ('prepare',)),
        ('characterize', 'ketoan_truong', CHARACTERIZATION_CASES),
    ):
        result_path = directory / f'{run_id}-{phase}.json'
        if result_path.exists() or onec_runtime._linked(result_path):
            raise onec_runtime.RuntimeSafetyError('Unique result path already exists')
        arguments = ['ENTERPRISE', '/F', str(ib), '/N', user]
        password = os.environ.get({'prepare-ar': 'ONEC_AR_PASSWORD',
                                   'prepare': 'ONEC_MAKER_PASSWORD',
                                   'characterize': 'ONEC_CHECKER_PASSWORD'}[phase], '')
        if password:
            arguments += ['/P', password]
        arguments += ['/C', f'RunNettingReversal;{run_id};{result_path};{phase};{fixture}',
                      '/DisableStartupMessages', '/DisableStartupDialogs']
        started_ns = time.time_ns()
        onec_runtime._execute(exe_path, arguments, timeout)
        onec_runtime.validate_clone(ib)
        if onec_runtime._result_directory(ib) != directory:
            raise onec_runtime.RuntimeSafetyError('Results directory changed during the run')
        result = onec_runtime.validate_result(result_path, run_id, expected, started_ns)
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ib-path', required=True)
    parser.add_argument('--exe-path', default=onec_runtime.DEFAULT)
    parser.add_argument('--timeout', type=float, default=90)
    args = parser.parse_args(argv)
    try:
        result = run_netting_reversal(args.ib_path, args.timeout, args.exe_path)
        print(json.dumps(result, ensure_ascii=True))
        return 0
    except (onec_runtime.RuntimeSafetyError, OSError, ValueError, TypeError) as exc:
        print(json.dumps({'status': 'FAIL', 'error': str(exc)}))
        return 1


class OfflineTests(unittest.TestCase):
    def setUp(self):
        self.runner = getattr(sys.modules[__name__], 'run_netting_reversal', None)
        self.assertTrue(callable(self.runner), 'Three-phase runtime wrapper is missing')
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name).resolve()
        self.ib = self.root / 'scratch' / 'uat' / 'fixture' / 'ib'
        self.ib.mkdir(parents=True)
        (self.ib / '1Cv8.1CD').write_bytes(b'offline fixture only')
        (self.ib.parent / '.uat-clone.json').write_text(json.dumps({
            'ib_path': str(self.ib), 'source_sha256': 'a' * 64}), encoding='utf-8')
        context = patch.object(onec_runtime, 'WORKSPACE_ROOT', self.root)
        context.start()
        self.addCleanup(context.stop)
        self.launches = []
        self.bad_phase = None
        self.bad_result = None

    def execute_fixture(self, exe_path, arguments, timeout):
        self.launches.append(arguments)
        command, run_id, result_path, phase, fixture_path = arguments[arguments.index('/C') + 1].split(';')
        self.assertEqual(command, 'RunNettingReversal')
        self.assertEqual(json.loads(Path(fixture_path).read_text())['run_id'], run_id)
        names = (phase,) if phase in ('prepare-ar', 'prepare') else (
            'backdated_netting', 'netting_repost', 'foreign_units',
            'current_ap_exhausted', 'current_ar_exhausted', 'duplicate_reversal')
        result = {'run_id': run_id, 'status': 'PASS', 'cases': [
            {'name': name, 'passed': True, 'error': ''} for name in names]}
        if phase == self.bad_phase:
            result = self.bad_result(result)
        Path(result_path).write_text(json.dumps(result), encoding='utf-8')
        timestamp = time.time_ns()
        os.utime(result_path, ns=(timestamp, timestamp))

    def test_unsafe_target_fails_before_launch(self):
        with patch.object(onec_runtime, '_execute') as execute:
            with self.assertRaises(onec_runtime.RuntimeSafetyError):
                self.runner(self.root / 'Infobase_FullData', exe_path=sys.executable)
            output = io.StringIO()
            with redirect_stdout(output):
                self.assertEqual(main(['--ib-path', str(self.root / 'Infobase_FullData')]), 1)
            self.assertEqual(json.loads(output.getvalue())['status'], 'FAIL')
            execute.assert_not_called()

    def test_three_phases_use_real_users_and_fresh_correlated_paths(self):
        with patch.object(onec_runtime, '_execute', side_effect=self.execute_fixture):
            first = self.runner(self.ib, exe_path=sys.executable)
            second = self.runner(self.ib, exe_path=sys.executable)
        self.assertEqual(first['status'], 'PASS')
        self.assertNotEqual(first['run_id'], second['run_id'])
        self.assertEqual([args[args.index('/N') + 1] for args in self.launches],
                         ['ketoan_ar', 'ketoan_ap', 'ketoan_truong'] * 2)
        commands = [args[args.index('/C') + 1].split(';') for args in self.launches]
        self.assertEqual([command[3] for command in commands], ['prepare-ar', 'prepare', 'characterize'] * 2)
        self.assertEqual(len({command[2] for command in commands}), 6)
        self.assertEqual(len({command[4] for command in commands[:3]}), 1)
        self.assertNotEqual(commands[0][4], commands[3][4])

    def test_malformed_phase_results_fail_closed(self):
        mutations = (
            lambda value: dict(value, run_id='stale'),
            lambda value: dict(value, cases=[]),
            lambda value: dict(value, cases=value['cases'] + value['cases'][:1]),
            lambda value: dict(value, cases=[{'name': 'unexpected', 'passed': True, 'error': ''}]),
            lambda value: dict(value, cases=[dict(case, passed=1) for case in value['cases']]),
            lambda value: dict(value, cases=[dict(case, passed=False, error='rejected') for case in value['cases']]),
        )
        for phase_index, phase in enumerate(('prepare-ar', 'prepare', 'characterize'), 1):
            for mutation in mutations:
                self.bad_phase, self.bad_result = phase, mutation
                self.launches.clear()
                with self.subTest(phase=phase, mutation=mutation), \
                        patch.object(onec_runtime, '_execute', side_effect=self.execute_fixture):
                    with self.assertRaises(onec_runtime.RuntimeSafetyError):
                        self.runner(self.ib, exe_path=sys.executable)
                self.assertEqual(len(self.launches), phase_index)


if __name__ == '__main__':
    if sys.argv[1:] == ['--self-test']:
        unittest.main(argv=[sys.argv[0]])
    else:
        sys.exit(main())
