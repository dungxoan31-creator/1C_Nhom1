"""Offline concurrency-runner regressions; Popen is replaced, never native 1C."""

from contextlib import redirect_stdout
import hashlib
import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

import onec_runtime
import test_concurrent_posting as runner


TRAINING_LIMIT = ("Training version limitation reached\n"
                  "Infobase connections limitation reached\n")


class FixtureProcess:
    def __init__(self, pid, returncode):
        self.pid = pid
        self.returncode = returncode

    def poll(self):
        return self.returncode

    def wait(self, timeout):
        if self.returncode is None:
            self.returncode = 0
        return self.returncode

    def terminate(self):
        self.returncode = -15

    def kill(self):
        self.returncode = -9


class ConcurrentPostingOfflineTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="posting offline ")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name).resolve()
        self.ib = self.root / "scratch" / "uat" / "fixture" / "ib"
        self.ib.mkdir(parents=True)
        (self.ib / "1Cv8.1CD").write_bytes(b"offline database fixture")
        self.backup = self.root / "snapshot.dt"
        self.backup.write_bytes(b"immutable offline snapshot")
        (self.ib.parent / ".uat-clone.json").write_text(json.dumps({
            "ib_path": str(self.ib),
            "source_sha256": hashlib.sha256(self.backup.read_bytes()).hexdigest(),
        }), encoding="utf-8")
        self.options = {}
        self.processes = []
        for patcher in (patch.object(onec_runtime, "WORKSPACE_ROOT", self.root),
                        patch.object(runner.subprocess, "Popen", self.launch)):
            patcher.start()
            self.addCleanup(patcher.stop)

    def launch(self, command, **kwargs):
        _, run_id, result_name, worker, fixture_name = command[command.index("/C") + 1].split(";")
        result = Path(result_name)
        fixture = Path(fixture_name)
        options = self.options.get(worker, {})
        is_worker = worker in ("1", "2")
        process = FixtureProcess(100 + len(self.processes),
                                 options.get("exit", None if is_worker else 0))
        self.processes.append(process)
        log = Path(command[command.index("/Out") + 1])
        log.write_text(options.get("log", ""), encoding=options.get("encoding", "utf-8-sig"))
        log.with_suffix(".console.log").write_text(options.get("console", ""), encoding="utf-8")
        if options.get("result", not is_worker or options.get("ready", True)):
            names = (runner.VERIFY_CASES["payment"] if worker == "verify"
                     else {"worker" if is_worker else worker})
            status = options.get("status", "PASS")
            result.write_text(json.dumps({"run_id": run_id, "status": status, "cases": [
                {"name": name, "passed": status == "PASS", "error": "" if status == "PASS"
                 else options.get("error", "helper unavailable")}
                for name in sorted(names)]}), encoding="utf-8")
        if is_worker and options.get("ready", True):
            signal = options.get("signal", {"run_id": run_id, "connection": int(worker),
                                             "user": "ketoan_truong"})
            if isinstance(signal, dict) and signal.get("run_id") == "{RUN_ID}":
                signal = {**signal, "run_id": run_id}
            for suffix in (".ready" + worker, ".held1" if worker == "1" else ".attempt2"):
                payload = options.get("raw_signal", json.dumps(signal)).replace("{RUN_ID}", run_id)
                Path(str(fixture) + suffix).write_text(payload, encoding="utf-8")
        return process

    def execute(self, sequential=False):
        output = self.root / f"results-{len(self.processes)}"
        argv = ["test_concurrent_posting.py", "--ib-path", str(self.ib),
                "--snapshot-backup", str(self.backup), "--onec-exe", sys.executable,
                "--results-dir", str(output), "--scenario", "payment", "--repeats", "1"]
        if sequential:
            argv.append("--sequential")
        with patch.object(sys, "argv", argv), patch.object(runner.time, "sleep"), redirect_stdout(io.StringIO()):
            exit_code = runner.main()
        reports = list(output.glob("*/result.json"))
        self.assertEqual(len(reports), 1)
        report = json.loads(reports[0].read_text(encoding="utf-8"))
        self.assertTrue(all(process.poll() is not None for process in self.processes))
        return exit_code, report

    def assert_failure(self, sequential=False):
        code, report = self.execute(sequential)
        self.assertEqual((code, report["status"]), (1, "FAIL"))
        self.assertTrue(any(not case["passed"] for case in report["cases"]))

    def test_unexpected_worker_exit_is_fail_without_license_evidence(self):
        self.options["2"] = {"ready": False, "exit": 7}
        self.assert_failure()

    def test_readiness_timeout_is_fail_without_license_evidence(self):
        self.options["2"] = {"ready": False}
        with patch.object(runner.time, "monotonic", side_effect=[0, 26]):
            self.assert_failure()

    def test_generic_startup_logs_do_not_prove_training_connection_limit(self):
        for log in ("Training version limitation reached", "Infobase connections limitation reached",
                    "Training version: authentication failed", "Unable to obtain a license",
                    "No " + TRAINING_LIMIT, TRAINING_LIMIT.rstrip() + " not reached"):
            with self.subTest(log=log):
                self.options["2"] = {"ready": False, "exit": 7, "log": log}
                # Each CLI run owns a unique output directory.
                self.assert_failure()

    def test_proven_current_worker_training_connection_limit_is_not_run(self):
        self.options["2"] = {"ready": False, "exit": 7, "log": TRAINING_LIMIT}
        code, report = self.execute()
        self.assertEqual((code, report["status"]), (2, "NOT_RUN"))

    def test_training_limit_supports_utf16_startup_and_console_logs(self):
        for options in ({"log": TRAINING_LIMIT, "encoding": "utf-16"},
                        {"console": TRAINING_LIMIT}):
            with self.subTest(options=options):
                self.options["2"] = {"ready": False, "exit": 7, **options}
                code, report = self.execute()
                self.assertEqual((code, report["status"]), (2, "NOT_RUN"))

    def test_previous_phase_license_log_cannot_excuse_worker_exit(self):
        self.options["prepare"] = {"log": TRAINING_LIMIT}
        self.options["2"] = {"ready": False, "exit": 7}
        self.assert_failure()

    def test_helper_not_run_without_license_log_is_fail(self):
        self.options["prepare"] = {"status": "NOT_RUN"}
        self.assert_failure()

    def test_worker_helper_not_run_is_fail_even_with_license_log(self):
        self.options["2"] = {"ready": False, "exit": 0, "result": True,
                             "status": "NOT_RUN", "log": TRAINING_LIMIT}
        self.assert_failure()

    def test_helper_failure_takes_priority_over_license_log(self):
        self.options["2"] = {"ready": False, "exit": 0, "result": True,
                             "status": "FAIL", "error": "posting failed", "log": TRAINING_LIMIT}
        self.assert_failure()

    def test_unrelated_peer_exit_takes_priority_over_license_log(self):
        self.options["1"] = {"ready": False, "exit": 8}
        self.options["2"] = {"ready": False, "exit": 7, "log": TRAINING_LIMIT}
        self.assert_failure()

    def test_stale_readiness_takes_priority_over_license_log(self):
        self.options["1"] = {"signal": {"run_id": "old", "connection": 1, "user": "ketoan_truong"}}
        self.options["2"] = {"ready": False, "exit": 7, "log": TRAINING_LIMIT}
        self.assert_failure()

    def test_unvisited_stale_readiness_takes_priority_over_license_log(self):
        self.options["1"] = {"ready": False, "exit": 7, "log": TRAINING_LIMIT}
        self.options["2"] = {"signal": {"run_id": "old", "connection": 2, "user": "ketoan_truong"}}
        self.assert_failure()

    def test_malformed_readiness_takes_priority_over_license_log(self):
        for signal in ({"run_id": "{RUN_ID}"}, {"run_id": "{RUN_ID}", "connection": True,
                       "user": "ketoan_truong"}, {"run_id": "{RUN_ID}", "connection": 2,
                       "user": "Admin"}, {"run_id": "{RUN_ID}", "connection": 2,
                       "user": "ketoan_truong", "unexpected": True}):
            with self.subTest(signal=signal):
                self.options["1"] = {"ready": False, "exit": 7, "log": TRAINING_LIMIT}
                self.options["2"] = {"signal": signal}
                self.assert_failure()

    def test_duplicate_readiness_keys_cannot_be_hidden_by_license_log(self):
        self.options["1"] = {"ready": False, "exit": 7, "log": TRAINING_LIMIT}
        self.options["2"] = {"raw_signal": '{"run_id":"old","run_id":"{RUN_ID}",'
                             '"connection":2,"user":"ketoan_truong"}'}
        self.assert_failure()

    def test_independent_sessions_pass(self):
        code, report = self.execute()
        self.assertEqual((code, report["status"], report["execution"]), (0, "PASS", "two_session"))
        self.assertEqual({case["name"] for case in report["cases"]}, {
            "payment.0.one_payment", "payment.0.no_overdraw", "payment.0.payment_ledger",
            "payment.0.loser_rollback"})

    def test_same_connection_cannot_pass_as_two_sessions(self):
        self.options["2"] = {"signal": {"run_id": "{RUN_ID}", "connection": 1,
                                         "user": "ketoan_truong"}}
        self.assert_failure()

    def test_zero_exit_without_readiness_or_result_is_fail(self):
        self.options["2"] = {"ready": False, "exit": 0}
        self.assert_failure()

    def test_sequential_pass_remains_characterization(self):
        code, report = self.execute(sequential=True)
        self.assertEqual((code, report["status"], report["execution"]),
                         (0, "PASS", "sequential_characterization"))

    def test_sequential_helper_not_run_is_fail(self):
        self.options["2"] = {"status": "NOT_RUN", "log": TRAINING_LIMIT}
        self.assert_failure(sequential=True)


class ResultSchemaOfflineTests(unittest.TestCase):
    def test_duplicate_json_keys_are_rejected_at_every_depth(self):
        payloads = (
            '{"run_id":"old","run_id":"fresh","status":"PASS","cases":[]}',
            '{"run_id":"fresh","status":"FAIL","status":"PASS","cases":[]}',
            '{"cases":[{"passed":false,"passed":true}]}',
            '{"run_id":"fresh","connection":1,"connection":2,"user":"ketoan_truong"}',
        )
        with tempfile.TemporaryDirectory() as root:
            path = Path(root) / "result.json"
            for payload in payloads:
                with self.subTest(payload=payload):
                    path.write_text(payload, encoding="utf-8-sig")
                    with self.assertRaises(RuntimeError):
                        runner.read_json(path)

    def test_result_extraneous_fields_are_rejected(self):
        for extra in ({"total": 1}, {"execution": "sequential_characterization"}):
            with self.subTest(extra=extra), self.assertRaises(RuntimeError):
                runner.validate_result({"run_id": "fresh", "status": "PASS", "cases": [
                    {"name": "worker", "passed": True, "error": ""}], **extra}, "fresh", {"worker"})

    def test_case_extraneous_fields_are_rejected(self):
        with self.assertRaises(RuntimeError):
            runner.validate_result({"run_id": "fresh", "status": "PASS", "cases": [
                {"name": "worker", "passed": True, "error": "", "total": 1}]}, "fresh", {"worker"})


if __name__ == "__main__":
    unittest.main()
