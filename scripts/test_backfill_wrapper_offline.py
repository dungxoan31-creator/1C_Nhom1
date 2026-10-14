"""Exercise the backfill wrapper with the real CLI and no native 1C executable."""

import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


class BackfillWrapperOfflineTests(unittest.TestCase):
    def setUp(self):
        self.powershell = shutil.which("powershell") or shutil.which("pwsh")
        if not self.powershell:
            self.skipTest("PowerShell is unavailable")
        temporary = tempfile.TemporaryDirectory(prefix="backfill offline ")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name).resolve()
        scripts = self.root / "scripts"
        scripts.mkdir()
        source = Path(__file__).resolve().parent
        for name in ("run_backfill_gl.ps1", "onec_runtime.py"):
            shutil.copyfile(source / name, scripts / name)
        self.wrapper = scripts / "run_backfill_gl.ps1"
        self.ib = self.root / "scratch" / "uat" / "fixture" / "ib"
        self.ib.mkdir(parents=True)
        (self.ib / "1Cv8.1CD").write_bytes(b"offline database fixture")
        (self.ib.parent / ".uat-clone.json").write_text(json.dumps({
            "ib_path": str(self.ib), "source_sha256": "a" * 64}), encoding="utf-8")

    def invoke(self, ib_path=None):
        def quote(value):
            return "'" + str(value).replace("'", "''") + "'"

        # Block the legacy wrapper's unsafe operations before exercising it RED.
        # These guards remain active after the fix; tests never kill or launch 1C.
        command = ("function Stop-Process { throw 'Unowned process termination attempted' }; "
                   "function Start-Process { throw 'Native process launch attempted' }; & "
                   + quote(self.wrapper))
        if ib_path is not None:
            command += (" -IBPath " + quote(ib_path) + " -PythonPath " + quote(sys.executable)
                        + " -ExePath " + quote(self.root / "native-forbidden.exe"))
        return subprocess.run([self.powershell, "-NoProfile", "-NonInteractive", "-Command", command],
                              capture_output=True, text=True, timeout=20)

    def report(self, result):
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        lines = [line for line in result.stdout.splitlines() if line.startswith("{")]
        self.assertEqual(len(lines), 1, result.stdout + result.stderr)
        return json.loads(lines[0])

    def test_valid_clone_backfill_is_explicitly_unsupported(self):
        report = self.report(self.invoke(self.ib))
        self.assertEqual(report["status"], "NOT_RUN")
        self.assertIn("BackfillGLAnalyticKeys", report["error"])
        self.assertIn("not implemented", report["error"])
        self.assertEqual((self.ib / "1Cv8.1CD").read_bytes(), b"offline database fixture")

    def test_protected_full_data_path_fails_before_command_dispatch(self):
        report = self.report(self.invoke(self.root / "Infobase_FullData"))
        self.assertEqual(report["status"], "FAIL")
        self.assertIn("Protected", report["error"])

    def test_ib_path_is_required_without_default_database(self):
        result = self.invoke()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("IBPath", result.stderr)
        self.assertNotIn("PASS", result.stdout)


if __name__ == "__main__":
    unittest.main()
