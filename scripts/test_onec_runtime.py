"""Host-only runtime checks. All children are Python fixtures, never 1C."""
from contextlib import redirect_stdout
import importlib
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch


CHILD = r'''
import json, os, pathlib, sys, time
mode = sys.argv[1]
args = sys.argv[2:]
ib = pathlib.Path(args[args.index('/F') + 1])
(ib.parent / 'launch.json').write_text(json.dumps(args), encoding='utf-8')
with (ib.parent / 'launch.jsonl').open('a', encoding='utf-8') as launches:
    launches.write(json.dumps(args) + '\n')
if mode == 'timeout':
    (ib.parent / 'child.pid').write_text(str(os.getpid()))
    time.sleep(30)
if 'DESIGNER' in args:
    log = ib.parent / 'designer.jsonl'
    with log.open('a') as f:
        f.write(json.dumps(args) + '\n')
    if mode == 'load_error' and '/LoadConfigFromFiles' in args:
        sys.exit(4)
    if mode == 'update_error' and '/UpdateDBCfg' in args:
        sys.exit(5)
    sys.exit(0)
command, run_id, filename = args[args.index('/C') + 1].split(';')
result = pathlib.Path(filename)
cases = {
    'RunUnitTests': ['SecurityAndSoD', 'GLSubledger'],
    'RunPostingLifecycleTests': ['ZeroResidual', 'RepostParity', 'GLSubledger'],
    'RunHardeningUAT': ['SeedSafety', 'SeedTransactions', 'StateGuard'],
    'RunSecurityTests': ['SecurityAndSoD'],
    'RunRBACChecks': ['ActualRole', 'PermissionBoundary'],
    'VerifyContractFees': ['VerifyContractFees'],
    'VerifyGLAnalyticKeys': ['VerifyGLAnalyticKeys'],
    'ExportTrialBalanceEvidence': ['ExportTrialBalanceEvidence'],
}[command]
if mode == 'rbac_wrong_cases': cases = ['ActualRole', 'CrossDomainDenied']
data = {'run_id': run_id, 'status': 'PASS',
        'cases': [{'name': name, 'passed': True, 'error': ''} for name in cases]}
if mode == 'missing':
    print('ALL TESTS PASS')
    sys.exit(0)
if mode == 'wrong_id': data['run_id'] = 'old-run'
if mode == 'fail': data['status'] = 'FAIL'
if mode == 'false': data['cases'][0].update(passed=False, error='[FAIL]')
if mode == 'empty': data['cases'] = []
if mode == 'missing_case': data['cases'].pop()
if mode == 'duplicate_case': data['cases'].append(data['cases'][0])
if mode == 'extra_case': data['cases'].append({'name': 'Unknown', 'passed': True, 'error': ''})
if mode == 'bool_string': data['cases'][0]['passed'] = 'true'
if mode == 'bool_int': data['cases'][0]['passed'] = 1
if mode == 'missing_error': del data['cases'][0]['error']
if mode == 'error_type': data['cases'][0]['error'] = None
if mode == 'true_error': data['cases'][0]['error'] = '[FAIL] despite success summary'
if mode == 'rbac_cfo_fail' and args[args.index('/N') + 1] == 'cfo_giamdoc':
    data['cases'][1].update(passed=False, error='Maker self-approval Write(Posting) was allowed')
if mode == 'extra_key': data['total'] = len(data['cases'])
if mode == 'case_extra_key': data['cases'][0]['total'] = 1
if mode == 'malformed': result.write_text('ALL TESTS PASS', encoding='utf-8')
elif mode == 'duplicate_key':
    result.write_text(json.dumps(data).replace('"status": "PASS"', '"status": "FAIL", "status": "PASS"'))
elif mode == 'symlink':
    target = ib.parent / 'external.json'
    target.write_text(json.dumps(data), encoding='utf-8')
    result.symlink_to(target)
else: result.write_text(json.dumps(data), encoding='utf-8')
if command == 'ExportTrialBalanceEvidence':
    pathlib.Path(str(result) + '.evidence.json').write_text(json.dumps({'fixture': True}), encoding='utf-8')
if mode == 'stale': os.utime(result, (1, 1))
if mode == 'future': os.utime(result, (time.time() + 3600, time.time() + 3600))
if mode == 'exit_error': sys.exit(7)
'''


class RuntimeTests(unittest.TestCase):
    def setUp(self):
        try:
            self.runtime = importlib.import_module('onec_runtime')
        except ModuleNotFoundError:
            self.fail('The shared runtime safety helper is not implemented')
        self.temp = tempfile.TemporaryDirectory(prefix='onec safety ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.ib = self.root / 'scratch' / 'uat' / 'fixture' / 'ib'
        self.ib.mkdir(parents=True)
        (self.ib / '1Cv8.1CD').write_bytes(b'fixture, not an infobase')
        self.marker = self.ib.parent / '.uat-clone.json'
        self.metadata = {'ib_path': str(self.ib), 'source_sha256': 'a' * 64}
        self.write_marker(self.metadata)
        self.child = self.root / 'child.py'
        self.child.write_text(CHILD, encoding='utf-8')
        self.source = self.root / 'src'
        self.source.mkdir()
        self.addCleanup(patch.stopall)
        patch.object(self.runtime, 'WORKSPACE_ROOT', self.root).start()

    def write_marker(self, data):
        self.marker.write_text(json.dumps(data), encoding='utf-8')

    def run_fixture(self, mode='pass', command='RunUnitTests', **kwargs):
        return self.runtime.run_command(
            command, self.ib, expected_cases=('SecurityAndSoD', 'GLSubledger'),
            exe_path=(sys.executable, str(self.child), mode), **kwargs)

    def test_pass_uses_correlated_unique_result_and_safe_arguments(self):
        first = self.run_fixture(user='accountant with spaces')
        first_args = json.loads((self.ib.parent / 'launch.json').read_text())
        self.assertEqual(first_args[first_args.index('/N') + 1], 'accountant with spaces')
        second = self.run_fixture()
        self.assertEqual(first['status'], 'PASS')
        self.assertNotEqual(first['run_id'], second['run_id'])
        results = list((self.ib.parent / 'results').glob('*.json'))
        self.assertEqual(len(results), 2)
        args = json.loads((self.ib.parent / 'launch.json').read_text())
        self.assertEqual(args[args.index('/F') + 1], str(self.ib))
        command, run_id, result_path = args[args.index('/C') + 1].split(';')
        self.assertEqual(command, 'RunUnitTests')
        self.assertEqual(run_id, second['run_id'])
        self.assertEqual(Path(result_path).parent, self.ib.parent / 'results')

    def test_invalid_child_results_never_pass(self):
        for mode in ('missing', 'wrong_id', 'fail', 'false', 'empty',
                     'missing_case', 'duplicate_case', 'extra_case',
                     'bool_string', 'bool_int', 'missing_error', 'error_type',
                     'true_error', 'extra_key', 'case_extra_key', 'malformed',
                     'duplicate_key', 'stale', 'future', 'exit_error'):
            with self.subTest(mode=mode), self.assertRaises(self.runtime.RuntimeSafetyError):
                self.run_fixture(mode)

    def test_each_registered_command_requires_its_real_cases(self):
        for command, expected in (
            ('RunPostingLifecycleTests', ('ZeroResidual', 'RepostParity', 'GLSubledger')),
            ('RunHardeningUAT', ('SeedSafety', 'SeedTransactions', 'StateGuard')),
            ('RunSecurityTests', ('SecurityAndSoD',)),
        ):
            with self.subTest(command=command):
                result = self.runtime.run_command(command, self.ib,
                    expected_cases=expected, exe_path=(sys.executable, str(self.child), 'pass'))
                self.assertEqual({case['name'] for case in result['cases']}, set(expected))

    def test_registered_rbac_uses_exact_cases_and_rejects_unproven_results(self):
        runner = getattr(self.runtime, 'run_registered', None)
        self.assertTrue(callable(runner), 'Registered-command API is missing')
        good = runner('RunRBACChecks', self.ib, user='ketoan_ar',
            exe_path=(sys.executable, str(self.child), 'pass'))
        self.assertEqual({case['name'] for case in good['cases']},
            {'ActualRole', 'PermissionBoundary'})
        for mode in ('missing', 'wrong_id', 'false', 'missing_case', 'duplicate_case',
                     'extra_case', 'bool_string', 'malformed', 'exit_error', 'rbac_wrong_cases'):
            with self.subTest(mode=mode), self.assertRaises(self.runtime.RuntimeSafetyError):
                runner('RunRBACChecks', self.ib,
                    exe_path=(sys.executable, str(self.child), mode))
        with self.assertRaises(self.runtime.RuntimeNotRun):
            runner('SeedARData', self.ib, exe_path=(sys.executable, str(self.child), 'pass'))

    def test_lifecycle_cli_defaults_to_real_checker_and_respects_override(self):
        for options, expected in (([], 'ketoan_truong'), (['--user', 'Admin'], 'Admin')):
            with self.subTest(options=options), patch.object(
                    self.runtime, 'run_registered', return_value={'status': 'PASS'}) as run:
                with redirect_stdout(io.StringIO()):
                    self.assertEqual(self.runtime.run_cli(argv=[
                        'RunPostingLifecycleTests', '--ib-path', str(self.ib), *options]), 0)
                self.assertEqual(run.call_args.args[2], expected)

    def test_rbac_wrapper_requires_all_six_authenticated_sessions(self):
        wrapper = importlib.import_module('test_runtime_rbac_real_users')
        runner = getattr(wrapper, 'run_rbac_checks', None)
        self.assertTrue(callable(runner), 'Six-user RBAC runner is missing')
        report = runner(self.ib, exe_path=(sys.executable, str(self.child), 'pass'))
        users = ['Admin', 'ketoan_ar', 'ketoan_ap', 'chuyenvien_doisoat',
                 'ketoan_truong', 'cfo_giamdoc']
        self.assertEqual(report['status'], 'PASS')
        self.assertEqual([item['user'] for item in report['users']], users)
        self.assertEqual(len({item['result']['run_id'] for item in report['users']}), 6)
        for item in report['users']:
            self.assertEqual({case['name'] for case in item['result']['cases']},
                {'ActualRole', 'PermissionBoundary'})
        args = [json.loads(line) for line in (self.ib.parent / 'launch.jsonl').read_text().splitlines()]
        self.assertEqual([launch[launch.index('/N') + 1] for launch in args], users)
        self.assertTrue(all(launch[launch.index('/C') + 1].startswith('RunRBACChecks;')
                            for launch in args))

    def test_rbac_permission_boundary_failure_cannot_green_the_matrix(self):
        wrapper = importlib.import_module('test_runtime_rbac_real_users')
        runner = getattr(wrapper, 'run_rbac_checks', None)
        self.assertTrue(callable(runner), 'Six-user RBAC runner is missing')
        report = runner(self.ib, exe_path=(sys.executable, str(self.child), 'rbac_cfo_fail'))
        self.assertEqual(report['status'], 'FAIL')
        self.assertEqual(len(report['users']), 6)
        cfo = next(item for item in report['users'] if item['user'] == 'cfo_giamdoc')
        self.assertEqual(cfo['status'], 'FAIL')
        self.assertIn('PermissionBoundary', cfo['error'])

    def test_rbac_cli_reports_matrix_status_and_registered_command_status(self):
        wrapper = importlib.import_module('test_runtime_rbac_real_users')
        self.assertTrue(callable(getattr(wrapper, 'main', None)), 'RBAC CLI is missing')
        for mode, status, code in (('pass', 'PASS', 0), ('rbac_cfo_fail', 'FAIL', 1)):
            output = io.StringIO()
            with self.subTest(mode=mode), redirect_stdout(output), \
                    patch.object(wrapper, 'DEFAULT', (sys.executable, str(self.child), mode)):
                self.assertEqual(wrapper.main(['--ib-path', str(self.ib)]), code)
            report = json.loads(output.getvalue())
            self.assertEqual(report['status'], status)
            self.assertEqual(len(report['users']), 6)
        output = io.StringIO()
        with redirect_stdout(output), patch.object(self.runtime, 'DEFAULT',
                (sys.executable, str(self.child), 'pass')):
            self.assertEqual(self.runtime.run_cli(argv=['RunRBACChecks', '--ib-path',
                str(self.ib), '--user', 'ketoan_ap']), 0)
        self.assertEqual({case['name'] for case in json.loads(output.getvalue())['cases']},
            {'ActualRole', 'PermissionBoundary'})

    def test_timeout_reaps_owned_child_and_leaves_unrelated_process_alive(self):
        unrelated = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(30)'])
        try:
            started = time.monotonic()
            with self.assertRaises(self.runtime.RuntimeSafetyError):
                self.run_fixture('timeout', timeout=1)
            self.assertLess(time.monotonic() - started, 5)
            self.assertIsNone(unrelated.poll())
            pid = int((self.ib.parent / 'child.pid').read_text())
            if os.name == 'nt':
                query = subprocess.run(['powershell', '-NoProfile', '-Command',
                    f'if (Get-Process -Id {pid} -ErrorAction SilentlyContinue) {{ exit 1 }}'],
                    capture_output=True, timeout=10)
                self.assertEqual(query.returncode, 0)
            else:
                with self.assertRaises(ProcessLookupError): os.kill(pid, 0)
        finally:
            unrelated.kill()
            unrelated.wait()

    def test_clone_marker_required_and_bound_to_canonical_target(self):
        for metadata in (None, {}, {'ib_path': str(self.ib)},
                         dict(self.metadata, ib_path=str(self.root / 'published')),
                         dict(self.metadata, ib_path='scratch/uat/fixture/ib'),
                         dict(self.metadata, source_sha256=''),
                         dict(self.metadata, source_sha256=None)):
            with self.subTest(metadata=metadata):
                if metadata is None: self.marker.unlink(missing_ok=True)
                else: self.write_marker(metadata)
                with self.assertRaises(self.runtime.RuntimeSafetyError): self.run_fixture()
                self.assertFalse((self.ib.parent / 'launch.json').exists())
        self.marker.write_text('{bad')
        with self.assertRaises(self.runtime.RuntimeSafetyError): self.run_fixture()

    def test_published_paths_and_relative_paths_rejected_before_launch(self):
        for target in ('Infobase', 'Infobase_FullData', 'published', 'ib'):
            other = self.root / target
            other.mkdir()
            self.write_marker(dict(self.metadata, ib_path=str(other)))
            with self.subTest(target=target), self.assertRaises(self.runtime.RuntimeSafetyError):
                self.runtime.validate_clone(other)
        for target in ('scratch/uat/fixture/ib', '', r'Srvr="production";Ref="db"'):
            with self.subTest(target=target), self.assertRaises(self.runtime.RuntimeSafetyError):
                self.runtime.validate_clone(target)

    def test_missing_database_and_shared_hardlink_are_rejected(self):
        database = self.ib / '1Cv8.1CD'
        database.unlink()
        with self.assertRaises(self.runtime.RuntimeSafetyError): self.run_fixture()
        original = self.root / 'published.1CD'
        original.write_bytes(b'untouched fixture')
        os.link(original, database)
        with self.assertRaises(self.runtime.RuntimeSafetyError): self.run_fixture()

    def test_legacy_commands_do_not_launch_even_with_requested_cases(self):
        for command in ('SeedARData', 'SeedAPData', 'SeedNettingData', 'SeedMasterData',
                        'SeedCleanMasterData', 'SeedFullTestData', 'TestUserLogin'):
            with self.subTest(command=command), self.assertRaises(self.runtime.RuntimeNotRun):
                self.run_fixture(command=command)
        self.assertFalse((self.ib.parent / 'launch.json').exists())

    def test_readonly_commands_require_one_exact_case_and_never_implicit_updates(self):
        self.assertTrue(all(command in self.runtime.EXPECTED_CASES for command in (
            'VerifyContractFees', 'VerifyGLAnalyticKeys', 'ExportTrialBalanceEvidence')),
            'Read-only structured commands are not registered')
        for command in ('VerifyContractFees', 'VerifyGLAnalyticKeys', 'ExportTrialBalanceEvidence'):
            with self.subTest(command=command):
                result = self.runtime.run_registered(command, self.ib,
                    exe_path=(sys.executable, str(self.child), 'pass'))
                self.assertEqual(result['status'], 'PASS')
                self.assertEqual(set(result), {'run_id', 'status', 'cases'})
                self.assertEqual(result['cases'], [{'name': command, 'passed': True, 'error': ''}])
                for mode in ('missing', 'missing_case', 'duplicate_case', 'extra_case',
                             'false', 'malformed', 'wrong_id', 'rbac_wrong_cases'):
                    with self.subTest(mode=mode), self.assertRaises(self.runtime.RuntimeSafetyError):
                        self.runtime.run_registered(command, self.ib,
                            exe_path=(sys.executable, str(self.child), mode))
        launches = [json.loads(line) for line in (self.ib.parent / 'launch.jsonl').read_text().splitlines()]
        self.assertEqual({args[args.index('/C') + 1].split(';')[0] for args in launches},
            {'VerifyContractFees', 'VerifyGLAnalyticKeys', 'ExportTrialBalanceEvidence'})
        sidecars = list((self.ib.parent / 'results').glob('*.json.evidence.json'))
        self.assertTrue(sidecars)
        self.assertEqual(json.loads(sidecars[0].read_text()), {'fixture': True})

    def test_empty_or_duplicate_expected_cases_and_injected_command_rejected(self):
        for expected in ((), ('SecurityAndSoD', 'SecurityAndSoD'), ('',), ('GLSubledger',)):
            with self.subTest(expected=expected), self.assertRaises(self.runtime.RuntimeSafetyError):
                self.runtime.run_command('RunUnitTests', self.ib, expected_cases=expected,
                    exe_path=(sys.executable, str(self.child), 'pass'))
        with self.assertRaises(self.runtime.RuntimeSafetyError):
            self.run_fixture(command='RunUnitTests;injected')
        self.assertFalse((self.ib.parent / 'launch.json').exists())

    def test_cli_reports_validated_pass_fail_timeout_and_not_run(self):
        for mode, command, expected_code, expected_status in (
            ('pass', 'RunUnitTests', 0, 'PASS'),
            ('false', 'RunUnitTests', 1, 'FAIL'),
            ('exit_error', 'RunUnitTests', 1, 'FAIL'),
            ('timeout', 'RunUnitTests', 1, 'FAIL'),
            ('pass', 'RunUATSecurityProof', 1, 'NOT_RUN'),
            ('load_error', 'update-db', 1, 'FAIL'),
            ('update_error', 'update-db', 1, 'FAIL'),
            ('pass', 'update-db', 0, 'PASS'),
        ):
            output = io.StringIO()
            with self.subTest(mode=mode, command=command), redirect_stdout(output), \
                    patch.object(self.runtime, 'DEFAULT', (sys.executable, str(self.child), mode)):
                code = self.runtime.run_cli(argv=[command, '--ib-path', str(self.ib),
                    '--timeout', '0.5', '--source-path', str(self.source)])
                self.assertEqual(code, expected_code)
                self.assertEqual(json.loads(output.getvalue())['status'], expected_status)

    def test_invalid_timeout_or_missing_executable_does_not_pass(self):
        for timeout in (0, -1, float('inf'), float('nan'), True):
            with self.subTest(timeout=timeout), self.assertRaises(self.runtime.RuntimeSafetyError):
                self.run_fixture(timeout=timeout)
        with self.assertRaises(self.runtime.RuntimeSafetyError):
            self.runtime.run_command('RunUnitTests', self.ib,
                expected_cases=('SecurityAndSoD', 'GLSubledger'),
                exe_path=str(self.root / 'missing.exe'))

    def test_symlinked_result_and_result_directory_are_rejected(self):
        external = self.root / 'external'
        external.mkdir()
        probe = self.root / 'link-probe'
        try:
            probe.symlink_to(external, target_is_directory=True)
        except OSError:
            self.skipTest('Symlink privilege is unavailable')
        probe.unlink()
        with self.assertRaises(self.runtime.RuntimeSafetyError): self.run_fixture('symlink')
        directory = self.ib.parent / 'results'
        for item in directory.iterdir(): item.unlink()
        directory.rmdir()
        directory.symlink_to(external, target_is_directory=True)
        with self.assertRaises(self.runtime.RuntimeSafetyError): self.run_fixture()

    def test_preexisting_result_is_rejected_without_overwriting(self):
        fixed = 'b' * 32
        directory = self.ib.parent / 'results'
        directory.mkdir()
        result = directory / (fixed + '.json')
        result.write_text('old evidence')
        with patch.object(self.runtime.uuid, 'uuid4') as uuid4:
            uuid4.return_value.hex = fixed
            with self.assertRaises(self.runtime.RuntimeSafetyError): self.run_fixture()
        self.assertEqual(result.read_text(), 'old evidence')
        self.assertFalse((self.ib.parent / 'launch.json').exists())

    def test_designer_stops_after_load_failure_and_reports_update_failure(self):
        for mode, steps in (('load_error', 1), ('update_error', 2), ('pass', 2)):
            log = self.ib.parent / 'designer.jsonl'
            log.unlink(missing_ok=True)
            with self.subTest(mode=mode):
                if mode == 'pass':
                    self.runtime.update_database(self.ib, self.source,
                        exe_path=(sys.executable, str(self.child), mode))
                else:
                    with self.assertRaises(self.runtime.RuntimeSafetyError):
                        self.runtime.update_database(self.ib, self.source,
                            exe_path=(sys.executable, str(self.child), mode))
                self.assertEqual(len(log.read_text().splitlines()), steps)

    def test_cli_and_all_wrappers_fail_closed_on_unsafe_path(self):
        scripts = Path(__file__).resolve().parent
        py_wrappers = ('test_posting_lifecycle_runtime.py', 'test_runtime_rbac_real_users.py',
                       'test_uat_rollback_concurrency.py', 'export_operational_evidence.py',
                       'test_contract_fees.py', 'verify_gl_analytic_keys.py')
        for filename in py_wrappers:
            with self.subTest(filename=filename):
                result = subprocess.run([sys.executable, str(scripts / filename),
                    '--ib-path', str(self.root / 'published'), '--exe-path', sys.executable],
                    capture_output=True, text=True, timeout=10)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('FAIL', result.stdout + result.stderr)
                result = subprocess.run([sys.executable, str(scripts / filename)],
                    capture_output=True, text=True, timeout=10)
                self.assertNotEqual(result.returncode, 0)
        ps = shutil.which('powershell') or shutil.which('pwsh')
        if not ps: return
        ps_wrappers = ('run_unit_tests.ps1', 'run_security_tests.ps1', 'update_db.ps1',
            'run_seed_ar_data.ps1', 'run_seed_ap_data.ps1', 'run_seed_netting_data.ps1',
            'run_seed_master_data.ps1', 'run_seed_clean_data.ps1',
            'run_seed_full_data.ps1', 'run_seed_massive_data.ps1')
        for filename in ps_wrappers:
            with self.subTest(filename=filename):
                result = subprocess.run([ps, '-NoProfile', '-NonInteractive',
                    '-ExecutionPolicy', 'Bypass', '-File', str(scripts / filename),
                    '-IBPath', str(self.root / 'published'), '-ExePath', sys.executable,
                    '-PythonPath', sys.executable], capture_output=True, text=True, timeout=15)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('FAIL', result.stdout + result.stderr)
                result = subprocess.run([ps, '-NoProfile', '-NonInteractive',
                    '-ExecutionPolicy', 'Bypass', '-File', str(scripts / filename)],
                    capture_output=True, text=True, timeout=15)
                self.assertNotEqual(result.returncode, 0)

    def test_powershell_propagates_real_helper_pass_and_fail_codes(self):
        ps = shutil.which('powershell') or shutil.which('pwsh')
        if not ps:
            self.skipTest('PowerShell is unavailable')
        scripts = Path(__file__).resolve().parent
        # The bridge changes only the fixture workspace/launcher. The real
        # PowerShell wrapper, CLI, child execution and validator all execute.
        bridge = self.root / 'bridge.py'
        bridge.write_text(
            'import sys\nfrom pathlib import Path\n'
            f'sys.path.insert(0, {str(scripts)!r})\n'
            'import onec_runtime\n'
            f'onec_runtime.WORKSPACE_ROOT = Path({str(self.root)!r})\n'
            f'onec_runtime.DEFAULT = (sys.executable, {str(self.child)!r}, sys.argv[1])\n'
            'sys.exit(onec_runtime.run_cli(argv=sys.argv[4:]))\n', encoding='utf-8')
        quote = lambda value: "'" + str(value).replace("'", "''") + "'"
        for filename, mode, code, status in (
            ('run_unit_tests.ps1', 'pass', 0, 'PASS'),
            ('run_unit_tests.ps1', 'false', 1, 'FAIL'),
            ('run_unit_tests.ps1', 'timeout', 1, 'FAIL'),
            ('run_security_tests.ps1', 'pass', 0, 'PASS'),
            ('update_db.ps1', 'load_error', 1, 'FAIL'),
            ('update_db.ps1', 'update_error', 1, 'FAIL'),
            ('update_db.ps1', 'pass', 0, 'PASS'),
            ('run_seed_ar_data.ps1', 'pass', 1, 'NOT_RUN'),
        ):
            command = (f'function Invoke-PythonFixture {{ & {quote(sys.executable)} -B '
                f'{quote(bridge)} {quote(mode)} @args }}\n'
                f'& {quote(scripts / filename)} -IBPath {quote(self.ib)} '
                '-PythonPath Invoke-PythonFixture -Timeout 0.5')
            with self.subTest(filename=filename, mode=mode):
                result = subprocess.run([ps, '-NoProfile', '-NonInteractive',
                    '-ExecutionPolicy', 'Bypass', '-Command', command],
                    capture_output=True, text=True, timeout=15)
                self.assertEqual(result.returncode, code, result.stdout + result.stderr)
                self.assertEqual(json.loads(result.stdout)['status'], status)


if __name__ == '__main__':
    unittest.main()
