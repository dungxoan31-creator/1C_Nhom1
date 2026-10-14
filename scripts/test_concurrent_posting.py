"""Task 4 runtime regression; Designer/clone provisioning belongs to the parent.

Compile/register ConcurrencyTestsServer first, then route:
  /C RunConcurrentPosting;run_id;result_path;worker_id;fixture_ref
to ConcurrencyTestsServer.RunConcurrentPosting(the four string arguments).
worker_id: prepare (real ketoan_ap), approve, 1, 2, verify (ketoan_truong).
fixture_ref is an absolute JSON file, initially {run_id, scenario}.
The helper writes every result as {run_id,status,cases:[{name,passed,error}]}.

Only run against a disposable, compiled clone restored from a full-data snapshot.
--snapshot-backup names the immutable backup used by the parent to make the clone.
This script neither clones nor loads configurations. It owns only its Popen handles.
Passwords come from ONEC_MAKER_PASSWORD / ONEC_CHECKER_PASSWORD (empty by default).
Exit codes: 0 PASS, 1 FAIL, 2 NOT_RUN. --self-test launches no 1C processes.
NOT_RUN requires current-worker startup logs proving the Training connection limit.
"""

import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time
import unittest
import uuid

from onec_runtime import RuntimeSafetyError, _json_object, validate_clone


SCENARIOS = ("payment", "revaluation")
VERIFY_CASES = {
    "payment": {"one_payment", "no_overdraw", "payment_ledger", "loser_rollback"},
    "revaluation": {"revaluation_balances", "revaluation_ledger", "no_duplicate_fx"},
}


class NotRun(RuntimeError):
    pass


class WorkerExitedBeforeRendezvous(RuntimeError):
    pass


def read_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8-sig"), object_pairs_hook=_json_object)


def write_json(path, value):
    # Atomic rendezvous files; BSL never sees a partially written release signal.
    path = Path(path)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding="utf-8")
    temporary.replace(path)


def validate_result(value, run_id, expected, exit_code=0):
    if exit_code != 0:
        raise RuntimeError(f"1C process exited {exit_code}")
    if (not isinstance(value, dict) or set(value) != {"run_id", "status", "cases"}
            or value.get("run_id") != run_id):
        raise RuntimeError("Missing/stale run ID or malformed result schema")
    cases = value.get("cases")
    if not isinstance(cases, list) or len(cases) != len(expected):
        raise RuntimeError("Missing/extra cases")
    if any(not isinstance(c, dict) or set(c) != {"name", "passed", "error"}
           or type(c.get("passed")) is not bool
           or not isinstance(c.get("error"), str) for c in cases):
        raise RuntimeError("Malformed case result")
    names = [c.get("name") for c in cases]
    if any(not isinstance(n, str) for n in names) or set(names) != set(expected):
        raise RuntimeError("Missing/duplicate/unexpected case")
    if value.get("status") != "PASS" or any(not c["passed"] for c in cases):
        raise RuntimeError("; ".join(c["error"] for c in cases) or "Runtime case failed")
    if any(c["error"] for c in cases):
        raise RuntimeError("PASS carries an error")
    return value


def sha256(path):
    with Path(path).open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


class Runtime:
    def __init__(self, args, directory):
        self.args = args
        self.directory = directory
        self.processes = []
        self.logs = []

    def launch(self, run_id, worker, fixture):
        result = self.directory / f"{run_id}-{worker}.json"
        log = self.directory / f"{run_id}-{worker}.log"
        parameter = ";".join(("RunConcurrentPosting", run_id, str(result), worker, str(fixture)))
        if any(";" in str(v) for v in (result, fixture)):
            raise ValueError("1C command paths cannot contain semicolons")
        maker = worker == "prepare"
        password = os.environ.get("ONEC_MAKER_PASSWORD" if maker else "ONEC_CHECKER_PASSWORD", "")
        command = [str(self.args.onec_exe), "ENTERPRISE", "/F", str(self.args.ib_path),
                   "/N", "ketoan_ap" if maker else "ketoan_truong", "/P", password,
                   "/C", parameter, "/Out", str(log),
                   "/DisableStartupMessages", "/DisableStartupDialogs"]
        output = log.with_suffix(".console.log").open("wb")
        try:
            process = subprocess.Popen(command, stdout=output, stderr=subprocess.STDOUT,
                                       creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
        finally:
            output.close()
        self.processes.append(process)
        self.logs.append(log)
        return process, result

    def finish(self, launched, run_id, expected):
        process, result = launched
        process.wait(timeout=self.args.timeout)
        if process.returncode != 0:
            raise RuntimeError(f"1C process {process.pid} exited {process.returncode}")
        if not result.is_file():
            raise RuntimeError(f"Process {process.pid} produced no result: {result}")
        return validate_result(read_json(result), run_id, expected, process.returncode)

    def phase(self, run_id, worker, fixture):
        return self.finish(self.launch(run_id, worker, fixture), run_id, {worker})

    def stop_owned(self):
        for process in self.processes:
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait(timeout=5)


def validate_signal(value, run_id):
    if (not isinstance(value, dict) or set(value) != {"run_id", "connection", "user"}
            or value.get("run_id") != run_id or type(value.get("connection")) is not int
            or value["connection"] <= 0 or value.get("user") != "ketoan_truong"):
        raise RuntimeError("Stale or malformed authenticated rendezvous signal")
    return value


def wait_signal(path, run_id, processes, timeout):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if path.is_file():
            try:
                value = read_json(path)
            except (json.JSONDecodeError, OSError):
                # BSL writers close the file before they return, but are not atomic.
                time.sleep(0.05)
                continue
            return validate_signal(value, run_id)
        if any(p.poll() is not None for p in processes):
            raise WorkerExitedBeforeRendezvous(f"Process exited before rendezvous: {path.name}")
        time.sleep(0.05)
    raise TimeoutError(f"Rendezvous timeout: {path.name}")


def training_connection_limit(result):
    """Require the observed Training connection diagnostic in this worker's log."""
    for log in (result.with_suffix(".log"), result.with_suffix(".console.log")):
        try:
            data = log.read_bytes()
        except FileNotFoundError:
            continue
        encoding = "utf-16" if data.startswith((b"\xff\xfe", b"\xfe\xff")) else "utf-8-sig"
        lines = [line.strip().casefold() for line in data.decode(encoding).splitlines()]
        if ("training version limitation reached", "infobase connections limitation reached") in zip(
                lines, lines[1:]):
            return log
    return None


def run_pair(runtime, run_id, fixture, scenario):
    runtime.phase(run_id, "prepare", fixture)
    runtime.phase(run_id, "approve", fixture)
    workers = [runtime.launch(run_id, worker, fixture) for worker in ("1", "2")]
    signals = lambda suffix: Path(str(fixture) + suffix)
    try:
        ready = [wait_signal(signals(f".ready{w}"), run_id, [p for p, _ in workers],
                             min(runtime.args.timeout, 25)) for w in ("1", "2")]
    except (WorkerExitedBeforeRendezvous, TimeoutError) as error:
        # A helper-reported error is a failure, not an unsupported-platform skip.
        evidence = []
        for worker, (process, result) in zip(("1", "2"), workers):
            exit_code = process.poll()
            if result.is_file():
                validate_result(read_json(result), run_id, {"worker"}, exit_code or 0)
            ready_path = signals(f".ready{worker}")
            if ready_path.exists():
                validate_signal(read_json(ready_path), run_id)
            log = training_connection_limit(result)
            if exit_code is not None and log is None:
                raise RuntimeError(f"Worker {worker} exited {exit_code} before readiness") from error
            if log is not None and not ready_path.exists():
                evidence.append(log)
        if evidence:
            raise NotRun(f"Training version infobase connection limit: {evidence}; {error}") from error
        raise
    if ready[0]["connection"] == ready[1]["connection"]:
        raise RuntimeError("Workers are not independent authenticated checker connections")
    write_json(signals(".go1"), {"run_id": run_id})
    wait_signal(signals(".held1"), run_id, [workers[0][0]], 25)
    write_json(signals(".go2"), {"run_id": run_id})
    wait_signal(signals(".attempt2"), run_id, [workers[1][0]], 25)
    # Give worker 2 time to enter Posting while worker 1 still owns its transaction.
    time.sleep(1)
    write_json(signals(".release1"), {"run_id": run_id})
    for launched in workers:
        runtime.finish(launched, run_id, {"worker"})
    return runtime.finish(runtime.launch(run_id, "verify", fixture), run_id, VERIFY_CASES[scenario])


def run_sequential(runtime, run_id, fixture, scenario):
    """Characterize historical overdraw/revaluation; this is not a concurrency proof."""
    runtime.phase(run_id, "prepare", fixture)
    runtime.phase(run_id, "approve", fixture)
    for worker in ("1", "2"):
        write_json(Path(str(fixture) + ".go" + worker), {"run_id": run_id})
        if worker == "1":
            write_json(Path(str(fixture) + ".release1"), {"run_id": run_id})
        runtime.finish(runtime.launch(run_id, worker, fixture), run_id, {"worker"})
    return runtime.finish(runtime.launch(run_id, "verify", fixture), run_id, VERIFY_CASES[scenario])


class ResultContractTests(unittest.TestCase):
    def setUp(self):
        self.good = {"run_id": "fresh", "status": "PASS", "cases": [
            {"name": "worker", "passed": True, "error": ""}]}

    def test_good_result(self):
        validate_result(self.good, "fresh", {"worker"})

    def test_rejects_false_green_results(self):
        variants = []
        for key, value in (("run_id", "old"), ("cases", []), ("status", "FAIL")):
            bad = copy.deepcopy(self.good)
            bad[key] = value
            variants.append(bad)
        for key, value in (("passed", False), ("passed", 1), ("error", "failed"),
                           ("name", "wrong")):
            bad = copy.deepcopy(self.good)
            bad["cases"][0][key] = value
            variants.append(bad)
        for bad in variants:
            with self.subTest(bad=bad), self.assertRaises(RuntimeError):
                validate_result(bad, "fresh", {"worker"})
        with self.assertRaises(RuntimeError):
            validate_result(self.good, "fresh", {"worker"}, 7)

    def test_helper_not_run_is_failure(self):
        value = {"run_id": "fresh", "status": "NOT_RUN", "cases": [
            {"name": "worker", "passed": False, "error": "two sessions unavailable"}]}
        with self.assertRaises(RuntimeError) as caught:
            validate_result(value, "fresh", {"worker"})
        self.assertNotIsInstance(caught.exception, NotRun)

    def test_refuses_live_database_and_resolved_alias(self):
        with tempfile.TemporaryDirectory() as root:
            live = Path(root) / "Infobase_FullData"
            live.mkdir()
            (live / "1Cv8.1CD").touch()
            with self.assertRaises(RuntimeSafetyError):
                validate_clone(live)
            alias = Path(root) / "uat-clone"
            try:
                alias.symlink_to(live, target_is_directory=True)
            except OSError:
                return  # Windows may disallow symlink creation for this account.
            with self.assertRaises(RuntimeSafetyError):
                validate_clone(alias)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--sequential", action="store_true",
                        help="Historical balance characterization only; does not verify concurrency")
    parser.add_argument("--scenario", choices=SCENARIOS)
    parser.add_argument("--ib-path", type=Path)
    parser.add_argument("--snapshot-backup", type=Path)
    parser.add_argument("--onec-exe", type=Path, default=Path(
        r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"))
    parser.add_argument("--results-dir", type=Path)
    parser.add_argument("--repeats", type=int, default=3)
    parser.add_argument("--timeout", type=float, default=60)
    args = parser.parse_args()
    if args.self_test:
        return 0 if unittest.TextTestRunner().run(unittest.defaultTestLoader.loadTestsFromTestCase(
            ResultContractTests)).wasSuccessful() else 1
    if not args.ib_path or not args.snapshot_backup or not args.results_dir:
        parser.error("--ib-path, --snapshot-backup and --results-dir are required")
    if args.repeats < 1 or not 35 <= args.timeout <= 60:
        parser.error("--repeats must be positive and --timeout must be 35..60 seconds")
    args.ib_path = validate_clone(args.ib_path)
    args.onec_exe = args.onec_exe.resolve(strict=True)
    backup = args.snapshot_backup.resolve(strict=True)
    if (backup == (args.ib_path / "1Cv8.1CD").resolve() or not backup.is_file()
            or backup.stat().st_nlink != 1
            or any(p.casefold() in {"infobase", "infobase_fulldata"} for p in backup.parts)):
        parser.error("Snapshot backup must be a separate immutable file")
    before_hash = sha256(backup)
    marker = read_json(args.ib_path.parent / ".uat-clone.json")
    if marker["source_sha256"].casefold() != before_hash:
        parser.error("--snapshot-backup SHA-256 differs from the bound clone provenance")
    run_id = uuid.uuid4().hex
    args.results_dir = args.results_dir.resolve()
    if (args.results_dir == args.ib_path or args.ib_path in args.results_dir.parents
            or any(p.casefold() in {"infobase", "infobase_fulldata"} for p in args.results_dir.parts)):
        parser.error("Results must be outside the database")
    directory = args.results_dir / run_id
    directory.mkdir(parents=True, exist_ok=False)
    runtime = Runtime(args, directory)
    cases = []
    status = "PASS"
    try:
        for scenario in ((args.scenario,) if args.scenario else SCENARIOS):
            for repeat in range(args.repeats):
                fixture_id = f"{run_id}-{scenario}-{repeat}"
                fixture = directory / f"{fixture_id}.fixture.json"
                write_json(fixture, {"run_id": fixture_id, "scenario": scenario})
                execution = run_sequential if args.sequential else run_pair
                result = execution(runtime, fixture_id, fixture, scenario)
                for case in result["cases"]:
                    cases.append({**case, "name": f"{scenario}.{repeat}.{case['name']}"})
    except NotRun as error:
        status = "NOT_RUN"
        cases.append({"name": "two_session_execution", "passed": False, "error": str(error)})
    except (RuntimeError, ValueError, OSError, KeyError, subprocess.TimeoutExpired,
            TimeoutError) as error:
        status = "FAIL"
        cases.append({"name": "two_session_execution", "passed": False, "error": str(error)})
    finally:
        runtime.stop_owned()
    if sha256(backup) != before_hash:
        status = "FAIL"
        cases.append({"name": "snapshot_immutable", "passed": False, "error": "Snapshot changed"})
    report = {"run_id": run_id, "status": status,
              "execution": "sequential_characterization" if args.sequential else "two_session",
              "cases": cases}
    manifest = {"run_id": run_id, "ib_path": str(args.ib_path), "snapshot_backup": str(backup),
              "snapshot_sha256": before_hash, "process_ids": [p.pid for p in runtime.processes],
              "logs": [str(p) for p in runtime.logs]}
    write_json(directory / "result.json", report)
    write_json(directory / "manifest.json", manifest)
    print(f"{status}: {directory / 'result.json'}")
    return {"PASS": 0, "FAIL": 1, "NOT_RUN": 2}[status]


if __name__ == "__main__":
    raise SystemExit(main())
