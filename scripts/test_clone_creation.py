"""Clone creation safety tests using Python children, never the 1C executable."""
from contextlib import redirect_stdout
import hashlib
import importlib
import io
import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch


CHILD = r'''
import json, pathlib, subprocess, sys, time
mode = sys.argv[1]
args = sys.argv[2:]
creating = args[0] == 'CREATEINFOBASE'
if creating:
    # Model the observed 1C custom parser boundary, not Python's CRT argv alone.
    if '\\"' in subprocess.list2cmdline(args): sys.exit(10)
    value = args[1][len('File='):].rstrip(';')
    if value.startswith("'") and value.endswith("'"): value = value[1:-1]
    target = pathlib.Path(value)
else:
    target = pathlib.Path(args[args.index('/F') + 1])
if (target.parent / '.uat-clone.json').exists(): sys.exit(9)
with (target.parent / 'launches.jsonl').open('a', encoding='utf-8') as f:
    f.write(json.dumps(args) + '\n')
if mode == 'create_timeout' and creating or mode == 'restore_timeout' and not creating:
    time.sleep(30)
if mode == 'create_error' and creating: sys.exit(7)
if mode == 'restore_error' and not creating: sys.exit(8)
target.mkdir(exist_ok=True)
if mode != 'missing_database':
    (target / '1Cv8.1CD').write_bytes(b'created fixture' if creating else b'restored fixture')
if '/OUT' in args:
    pathlib.Path(args[args.index('/OUT') + 1]).write_text('fixture log')
'''


class CloneCreationTests(unittest.TestCase):
    def setUp(self):
        try:
            self.creator = importlib.import_module('create_uat_clone')
        except ModuleNotFoundError:
            self.fail('Safe UAT clone creator is missing')
        self.temp = tempfile.TemporaryDirectory(prefix='clone safety ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        for module in (self.creator, self.creator.runtime):
            patcher = patch.object(module, 'WORKSPACE_ROOT', self.root)
            patcher.start()
            self.addCleanup(patcher.stop)
        self.source = self.root / 'published snapshot.dt'
        self.source.write_bytes(b'published snapshot must never be overwritten')
        self.source_bytes = self.source.read_bytes()
        self.original = self.root / 'snapshot.ORIGINAL.dt'
        self.original.write_bytes(b'preexisting immutable backup')
        self.child = self.root / 'child.py'
        self.child.write_text(CHILD, encoding='utf-8')
        self.target = self.root / 'scratch' / 'uat' / 'fixture-run' / 'ib'

    def clone(self, mode='pass', **kwargs):
        return self.creator.create_clone(self.source, target_path=self.target,
            exe_path=(sys.executable, str(self.child), mode), **kwargs)

    def test_success_restores_then_publishes_bound_marker_without_copying_source(self):
        result = self.clone()
        self.assertEqual(result['status'], 'PASS')
        marker = json.loads((self.target.parent / '.uat-clone.json').read_text())
        self.assertEqual(marker, {'ib_path': str(self.target),
            'source_sha256': hashlib.sha256(self.source_bytes).hexdigest()})
        self.assertEqual(self.creator.runtime.validate_clone(self.target), self.target)
        commands = [json.loads(line) for line in (self.target.parent / 'launches.jsonl').read_text().splitlines()]
        self.assertEqual([command[0] for command in commands], ['CREATEINFOBASE', 'DESIGNER'])
        restore = commands[1]
        self.assertEqual(restore[restore.index('/RestoreIB') + 1], str(self.source))
        self.assertEqual(restore[restore.index('/F') + 1], str(self.target))
        self.assertEqual((self.target / '1Cv8.1CD').read_bytes(), b'restored fixture')
        self.assertEqual(self.source.read_bytes(), self.source_bytes)
        self.assertEqual(self.original.read_bytes(), b'preexisting immutable backup')

    def test_any_existing_target_is_rejected_without_launch_or_modification(self):
        for kind in ('directory', 'file'):
            target = self.root / 'scratch' / 'uat' / kind / 'ib'
            target.parent.mkdir(parents=True)
            if kind == 'directory':
                target.mkdir()
                canary = target / '1Cv8.1CD'
            else:
                canary = target
            canary.write_bytes(b'existing target must remain untouched')
            with self.subTest(kind=kind), self.assertRaises(self.creator.runtime.RuntimeSafetyError):
                self.creator.create_clone(self.source, target_path=target,
                    exe_path=(sys.executable, str(self.child), 'pass'))
            self.assertEqual(canary.read_bytes(), b'existing target must remain untouched')
            self.assertFalse((target.parent / 'launches.jsonl').exists())
        self.assertEqual(self.source.read_bytes(), self.source_bytes)

    def test_space_path_connection_survives_native_windows_argument_serialization(self):
        self.assertIn(' ', str(self.target))
        try:
            self.clone()
        except self.creator.runtime.RuntimeSafetyError as exc:
            self.fail(f'Space-path CREATEINFOBASE serialization regression: {exc}')
        arguments = json.loads((self.target.parent / 'launches.jsonl').read_text().splitlines()[0])
        self.assertEqual(arguments[1], f"File='{self.target}';")
        self.assertNotIn('\\"', subprocess.list2cmdline(arguments))
        self.assertEqual(self.source.read_bytes(), self.source_bytes)

    def test_no_space_connection_needs_no_embedded_quotes(self):
        with tempfile.TemporaryDirectory(prefix='onec-native-') as directory:
            root = Path(directory).resolve()
            if any(char.isspace() for char in str(root)):
                self.skipTest('Temporary root contains spaces')
            target = root / 'scratch' / 'uat' / 'native-final2' / 'ib'
            with patch.object(self.creator, 'WORKSPACE_ROOT', root), \
                    patch.object(self.creator.runtime, 'WORKSPACE_ROOT', root):
                try:
                    self.creator.create_clone(self.source, target_path=target,
                        exe_path=(sys.executable, str(self.child), 'pass'))
                except self.creator.runtime.RuntimeSafetyError as exc:
                    self.fail(f'No-space CREATEINFOBASE serialization regression: {exc}')
            arguments = json.loads((target.parent / 'launches.jsonl').read_text().splitlines()[0])
            self.assertEqual(arguments[1], f'File={target};')
            self.assertNotIn('\\"', subprocess.list2cmdline(arguments))

    def test_apostrophe_target_is_rejected_before_reserving_a_run(self):
        target = self.root / "owner's workspace" / 'scratch' / 'uat' / 'new' / 'ib'
        with patch.object(self.creator, 'WORKSPACE_ROOT', self.root / "owner's workspace"), \
                self.assertRaises(self.creator.runtime.RuntimeSafetyError):
            (self.root / "owner's workspace").mkdir()
            self.creator.create_clone(self.source, target_path=target,
                exe_path=(sys.executable, str(self.child), 'pass'))
        self.assertFalse(target.parent.exists())

    def test_readonly_published_snapshot_can_be_used_without_rewriting_it(self):
        original_mode = self.source.stat().st_mode
        self.source.chmod(stat.S_IREAD)
        try:
            result = self.clone()
            self.assertEqual(result['status'], 'PASS')
            self.assertEqual(self.source.read_bytes(), self.source_bytes)
            self.assertFalse(self.source.stat().st_mode & stat.S_IWRITE)
        finally:
            self.source.chmod(original_mode)

    def test_existing_run_directory_and_marker_are_not_overwritten(self):
        self.target.parent.mkdir(parents=True)
        marker = self.target.parent / '.uat-clone.json'
        marker.write_text('existing provenance')
        with self.assertRaises(self.creator.runtime.RuntimeSafetyError): self.clone()
        self.assertEqual(marker.read_text(), 'existing provenance')
        self.assertFalse(self.target.exists())

    def test_protected_published_relative_and_alias_targets_fail_before_launch(self):
        for name in ('Infobase', 'Infobase_FullData', 'published'):
            directory = self.root / name
            directory.mkdir()
            canary = directory / '1Cv8.1CD'
            canary.write_bytes(b'live fixture')
            for target in (directory, directory / 'new'):
                with self.subTest(target=target), self.assertRaises(self.creator.runtime.RuntimeSafetyError):
                    self.creator.create_clone(self.source, target_path=target,
                        exe_path=(sys.executable, str(self.child), 'pass'))
                self.assertEqual(canary.read_bytes(), b'live fixture')
        for target in ('scratch/uat/new/ib', self.root / 'scratch' / 'uat' / 'new' / 'ib' / '..' / 'other',
                       self.root / 'scratch' / 'uat' / 'Infobase_FullData' / 'ib'):
            with self.subTest(target=target), self.assertRaises(self.creator.runtime.RuntimeSafetyError):
                self.creator.create_clone(self.source, target_path=target,
                    exe_path=(sys.executable, str(self.child), 'pass'))
        self.assertEqual(self.source.read_bytes(), self.source_bytes)

    def test_live_junction_alias_is_rejected_before_launch(self):
        if os.name != 'nt': self.skipTest('Windows junction test')
        live = self.root / 'Infobase_FullData'
        live.mkdir()
        canary = live / '1Cv8.1CD'
        canary.write_bytes(b'live fixture')
        self.target.parent.mkdir(parents=True)
        command = f'New-Item -ItemType Junction -Path "{self.target}" -Target "{live}" | Out-Null'
        process = subprocess.run(['powershell', '-NoProfile', '-Command', command],
            capture_output=True, timeout=15)
        if process.returncode: self.skipTest('Junction creation unavailable')
        try:
            with self.assertRaises(self.creator.runtime.RuntimeSafetyError): self.clone()
            self.assertEqual(canary.read_bytes(), b'live fixture')
            self.assertFalse((self.target.parent / 'launches.jsonl').exists())
        finally:
            self.target.rmdir()  # Remove only the fixture junction, never its contents.

    def test_failed_process_keeps_source_and_never_marks_partial_clone(self):
        for mode, steps in (('create_error', 1), ('restore_error', 2), ('missing_database', 2)):
            target = self.root / 'scratch' / 'uat' / mode / 'ib'
            with self.subTest(mode=mode), self.assertRaises(self.creator.runtime.RuntimeSafetyError):
                self.creator.create_clone(self.source, target_path=target,
                    exe_path=(sys.executable, str(self.child), mode))
            self.assertFalse((target.parent / '.uat-clone.json').exists())
            self.assertEqual(len((target.parent / 'launches.jsonl').read_text().splitlines()), steps)
            self.assertEqual(self.source.read_bytes(), self.source_bytes)
            self.assertEqual(self.original.read_bytes(), b'preexisting immutable backup')

    def test_timeout_cannot_publish_marker_or_mutate_source(self):
        for mode in ('create_timeout', 'restore_timeout'):
            target = self.root / 'scratch' / 'uat' / mode / 'ib'
            started = time.monotonic()
            with self.subTest(mode=mode), self.assertRaises(self.creator.runtime.RuntimeSafetyError):
                self.creator.create_clone(self.source, target_path=target, timeout=0.5,
                    exe_path=(sys.executable, str(self.child), mode))
            self.assertLess(time.monotonic() - started, 5)
            self.assertFalse((target.parent / '.uat-clone.json').exists())
            self.assertEqual(self.source.read_bytes(), self.source_bytes)

    def test_unique_defaults_and_explicit_run_id_cannot_reuse_a_target(self):
        first = self.creator.create_clone(self.source,
            exe_path=(sys.executable, str(self.child), 'pass'))
        second = self.creator.create_clone(self.source,
            exe_path=(sys.executable, str(self.child), 'pass'))
        self.assertNotEqual(first['ib_path'], second['ib_path'])
        explicit = self.creator.create_clone(self.source, run_id='explicit-run',
            exe_path=(sys.executable, str(self.child), 'pass'))
        self.assertEqual(Path(explicit['ib_path']), self.root / 'scratch' / 'uat' / 'explicit-run' / 'ib')
        with self.assertRaises(self.creator.runtime.RuntimeSafetyError):
            self.creator.create_clone(self.source, run_id='explicit-run',
                exe_path=(sys.executable, str(self.child), 'pass'))
        for run_id in ('../Infobase', '', 'a/b', 'Infobase_FullData'):
            with self.subTest(run_id=run_id), self.assertRaises(self.creator.runtime.RuntimeSafetyError):
                self.creator.create_clone(self.source, run_id=run_id,
                    exe_path=(sys.executable, str(self.child), 'pass'))

    def test_invalid_source_or_conflicting_run_id_creates_nothing(self):
        for source in (self.root / 'missing.dt', self.root, self.root / 'not-a-snapshot.txt'):
            with self.subTest(source=source), self.assertRaises(self.creator.runtime.RuntimeSafetyError):
                self.creator.create_clone(source, target_path=self.target,
                    exe_path=(sys.executable, str(self.child), 'pass'))
            self.assertFalse(self.target.parent.exists())
        with self.assertRaises(self.creator.runtime.RuntimeSafetyError): self.clone(run_id='different-run')
        self.assertFalse(self.target.parent.exists())

    def test_cli_and_powershell_wrapper_propagate_safe_creation_and_failures(self):
        for mode, code in (('pass', 0), ('restore_error', 1)):
            output = io.StringIO()
            with self.subTest(mode=mode), redirect_stdout(output), patch.object(self.creator, 'DEFAULT',
                    (sys.executable, str(self.child), mode)):
                actual = self.creator.main(['--source-dt', str(self.source), '--run-id', 'cli-' + mode])
            self.assertEqual(actual, code)
            self.assertEqual(json.loads(output.getvalue())['status'], 'PASS' if code == 0 else 'FAIL')
        ps = shutil.which('powershell') or shutil.which('pwsh')
        if not ps: return
        scripts = Path(__file__).resolve().parent
        bridge = self.root / 'bridge.py'
        bridge.write_text('import sys\nfrom pathlib import Path\n'
            f'sys.path.insert(0, {str(scripts)!r})\nimport create_uat_clone as creator\n'
            f'creator.WORKSPACE_ROOT = creator.runtime.WORKSPACE_ROOT = Path({str(self.root)!r})\n'
            f'creator.DEFAULT = (sys.executable, {str(self.child)!r}, sys.argv[1])\n'
            'sys.exit(creator.main(sys.argv[4:]))\n', encoding='utf-8')
        quote = lambda value: "'" + str(value).replace("'", "''") + "'"
        for mode, code in (('pass', 0), ('restore_error', 1)):
            command = (f'function Invoke-PythonFixture {{ & {quote(sys.executable)} -B '
                f'{quote(bridge)} {quote(mode)} @args }}\n'
                f'& {quote(scripts / "backup_and_prepare_env.ps1")} -SourceDT {quote(self.source)} '
                f'-RunId {quote("ps-" + mode)} -PythonPath Invoke-PythonFixture')
            with self.subTest(ps_mode=mode):
                result = subprocess.run([ps, '-NoProfile', '-NonInteractive', '-ExecutionPolicy',
                    'Bypass', '-Command', command], capture_output=True, text=True, timeout=15)
                self.assertEqual(result.returncode, code, result.stdout + result.stderr)
                self.assertEqual(json.loads(result.stdout)['status'], 'PASS' if code == 0 else 'FAIL')
        result = subprocess.run([ps, '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass',
            '-File', str(scripts / 'backup_and_prepare_env.ps1'), '-SourceDT', str(self.source),
            '-TargetIB', str(self.root / 'Infobase_FullData'), '-ExePath', sys.executable],
            capture_output=True, text=True, timeout=15)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.source.read_bytes(), self.source_bytes)
        self.assertEqual(self.original.read_bytes(), b'preexisting immutable backup')


if __name__ == '__main__':
    unittest.main()
