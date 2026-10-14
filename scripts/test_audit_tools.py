"""Offline regression tests; no 1C runtime or third-party dependencies."""

import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPTS = Path(__file__).resolve().parent
BOM = b"\xef\xbb\xbf"


class AuditToolsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.src = self.root / "src"
        self.dump = self.root / "dump"
        self.src.mkdir()
        self.dump.mkdir()

    def write(self, base, name, data):
        path = base / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data.encode("utf-8") if isinstance(data, str) else data)
        return path

    def python(self, *args):
        env = dict(os.environ, PYTHONIOENCODING="utf-8", PYTHONDONTWRITEBYTECODE="1")
        return subprocess.run(
            [sys.executable, "-B", *map(str, args)], cwd=self.root,
            env=env, capture_output=True, text=True, encoding="utf-8", timeout=20,
        )

    def cli(self, script, *args):
        return self.python(SCRIPTS / script, *args)

    def api(self, module, expression):
        result = self.python(
            "-c", "import sys, json; from pathlib import Path; "
            f"sys.path.insert(0, {str(SCRIPTS)!r}); import {module} as tool; "
            f"print(json.dumps({expression}))",
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        try:
            return json.loads(result.stdout)
        except ValueError:
            self.fail("API import printed output instead of a reusable result: " + result.stdout)

    def parity(self, *python_flags):
        return self.python(*python_flags, SCRIPTS / "audit_config_diff.py",
                           "--src", self.src, "--dump", self.dump)

    def audit(self):
        result = self.api(
            "audit_codebase",
            "tool.audit_tree(Path('src')) if callable(getattr(tool, 'audit_tree', None)) "
            "else {'missing_api': 'audit_tree'}",
        )
        self.assertIsInstance(result, list, result)
        return result

    def test_imports_do_not_scan_print_or_replace_stdout(self):
        for module in ("verify_bsl_syntax", "audit_config_diff", "audit_codebase"):
            with self.subTest(module=module):
                result = self.python(
                    "-c", "import sys; import io; "
                    f"sys.path.insert(0, {str(SCRIPTS)!r}); "
                    "original = sys.stdout; "
                    f"import {module}; assert sys.stdout is original; print('import-safe')",
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(result.stdout, "import-safe\n")

    def test_three_bom_modules_do_not_produce_balance_issues(self):
        for name in ("first", "second", "third"):
            self.write(self.src, name + ".bsl", BOM + b"Procedure Test()\r\nEndProcedure\r\n")
        result = self.cli("verify_bsl_syntax.py")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Total syntax balance issues: 0", result.stdout)

    def test_missing_endprocedure_returns_failure(self):
        self.write(self.src, "broken.bsl", "Procedure Broken()\n")
        result = self.cli("verify_bsl_syntax.py")
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("broken.bsl", result.stdout)

    def test_syntax_functions_are_reusable_and_ignore_comments_and_strings(self):
        content = 'Procedure Test()\n// If Try For\nMessage("If ""Try"" EndFunction");\nEndProcedure'
        result = self.api(
            "verify_bsl_syntax",
            f"tool.check_content({content!r}) "
            "if callable(getattr(tool, 'check_content', None)) else {'missing_api': 'check_content'}",
        )
        self.assertEqual(result, [])

    def test_syntax_rejects_missing_empty_and_unreadable_source(self):
        for directory in (self.root / "missing", self.src):
            with self.subTest(directory=directory):
                self.assertNotEqual(self.cli("verify_bsl_syntax.py", "--src", directory).returncode, 0)
        self.write(self.src, "bad.bsl", b"\xff")
        self.assertNotEqual(self.cli("verify_bsl_syntax.py", "--src", self.src).returncode, 0)

    def test_parity_requires_both_paths(self):
        for args in ((), ("--src", self.src), ("--dump", self.dump)):
            with self.subTest(args=args):
                result = self.cli("audit_config_diff.py", *args)
                self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
                self.assertIn("required", result.stderr)

    def test_parity_normalizes_only_text_bom_and_crlf(self):
        self.write(self.src, "Module.bsl", BOM + b"Procedure Test()\r\nEndProcedure\r\n")
        self.write(self.dump, "Module.bsl", "Procedure Test()\nEndProcedure\n")
        self.write(self.dump, "ConfigDumpInfo.xml", "generated manifest")
        result = self.parity()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_parity_preserves_text_whitespace(self):
        for left, right in ((b"value\n", b"value"), (b" value", b"value"),
                            (b"value\r", b"value\n"), (BOM + BOM + b"value", b"value")):
            with self.subTest(left=left, right=right):
                self.write(self.src, "data.xml", left)
                self.write(self.dump, "data.xml", right)
                self.assertNotEqual(self.parity().returncode, 0)

    def test_binary_hash_is_exact_even_for_utf8_bytes(self):
        for data in (b" \x00\r\nvalue \n", BOM + b"value", b"\xefvalue", b"\xbbvalue", b"\xbfvalue", b"text\r\n"):
            with self.subTest(data=data):
                self.write(self.src, "asset.bin", data)
                result = self.api("audit_config_diff", "tool.compute_content_sha256(Path('src/asset.bin'))")
                self.assertEqual(result, hashlib.sha256(data).hexdigest())

    def test_binary_changes_cannot_be_normalized_away(self):
        self.write(self.src, "image.png", BOM + b"\x00\r\n ")
        self.write(self.dump, "image.png", b"\x00\n")
        result = self.parity()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("image.png", result.stdout)

    def test_binary_content_with_text_extension_is_hashed_exactly(self):
        data = BOM + b"\x00value\r\n "
        self.write(self.src, "payload.txt", data)
        result = self.api("audit_config_diff", "tool.compute_content_sha256(Path('src/payload.txt'))")
        self.assertEqual(result, hashlib.sha256(data).hexdigest())

    def test_parity_fails_for_missing_extra_and_changed_files_under_optimization(self):
        self.write(self.src, "missing.xml", "missing")
        self.write(self.dump, "extra.xml", "extra")
        self.write(self.src, "changed.xml", "one")
        self.write(self.dump, "changed.xml", "two")
        result = self.parity("-O")
        self.assertNotEqual(result.returncode, 0, result.stdout)
        for name in ("missing.xml", "extra.xml", "changed.xml"):
            self.assertIn(name, result.stdout)

    def test_parity_rejects_missing_or_empty_trees(self):
        self.assertNotEqual(self.parity().returncode, 0)
        result = self.cli("audit_config_diff.py", "--src", self.src,
                          "--dump", self.root / "missing")
        self.assertNotEqual(result.returncode, 0)

    def test_parity_comparison_returns_structured_differences(self):
        self.write(self.src, "missing.xml", "one")
        self.write(self.dump, "extra.xml", "two")
        result = self.api(
            "audit_config_diff", "tool.compare_trees(Path('src'), Path('dump')) "
            "if callable(getattr(tool, 'compare_trees', None)) else {'missing_api': 'compare_trees'}",
        )
        self.assertEqual(result.get("missing_in_dump"), ["missing.xml"])
        self.assertEqual(result.get("extra_in_dump"), ["extra.xml"])
        self.assertEqual(result.get("hash_mismatches"), [])

    def test_transaction_closure_in_another_procedure_cannot_mask_warning(self):
        self.write(self.src, "Module.bsl",
                   "Procedure OpenOnly()\nBeginTransaction();\nEndProcedure\n"
                   "Procedure CloseOnly()\nCommitTransaction();\nRollbackTransaction();\nEndProcedure\n")
        findings = [f for f in self.audit() if f["rule"] == "T1"]
        self.assertEqual(len(findings), 1, findings)
        self.assertEqual(findings[0]["procedure"], "OpenOnly")
        self.assertEqual(findings[0]["line"], 2)
        self.assertEqual(findings[0]["classification"], "needs_runtime_proof")

    def test_batched_transactions_with_shared_exception_handler_are_not_counted(self):
        self.write(self.src, "Module.bsl", """Procedure Batch()
Try
    BeginTransaction();
    For Each Item In Items Do
        If Full Then
            CommitTransaction();
            BeginTransaction();
        EndIf;
    EndDo;
    CommitTransaction();
Except
    RollbackTransaction();
    Raise;
EndTry;
EndProcedure
""")
        self.assertEqual([f for f in self.audit() if f["rule"] == "T1"], [])

    def test_transaction_tokens_without_exception_structure_are_warnings(self):
        self.write(self.src, "Module.bsl", "Procedure Unsafe()\nBeginTransaction();\n"
                   "CommitTransaction();\nRollbackTransaction();\nEndProcedure\n")
        self.assertTrue([f for f in self.audit() if f["rule"] == "T1"])

    def test_begin_immediately_before_try_remains_supported(self):
        self.write(self.src, "Module.bsl", "Procedure Legacy()\nBeginTransaction();\nTry\n"
                   "CommitTransaction();\nExcept\nRollbackTransaction();\nRaise;\nEndTry;\nEndProcedure\n")
        self.assertEqual([f for f in self.audit() if f["rule"] == "T1"], [])

    def shared_guard(self, body):
        self.write(self.src, "CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl",
                   "Procedure KiemTraTrangThaiVaQuyen(DocObject, WriteMode, PostingMode, Cancel) Export\n"
                   + body + "\nEndProcedure\n")
        self.write(self.src, "Documents/Example/Ext/ObjectModule.bsl",
                   "Procedure BeforeWrite(Cancel, WriteMode, PostingMode)\n"
                   "QuanLyVongDoiChungTuServer.KiemTraTrangThaiVaQuyen(\n"
                   "ThisObject, WriteMode, PostingMode, Cancel);\nEndProcedure\n")

    def test_shared_lifecycle_guard_resolves_dataexchange_warning(self):
        self.shared_guard("If DocObject.DataExchange.Load Then\nReturn;\nEndIf;")
        self.assertEqual([f for f in self.audit() if f["rule"] == "V5"], [])

    def test_shared_guard_must_handle_dataexchange_in_the_target_procedure(self):
        self.shared_guard('// DataExchange.Load is handled elsewhere')
        self.write(self.src, "CommonModules/Unrelated/Ext/Module.bsl",
                   "Procedure Other()\nIf DataExchange.Load Then Return; EndIf;\nEndProcedure\n")
        self.assertEqual(len([f for f in self.audit() if f["rule"] == "V5"]), 1)

    def test_direct_guard_is_case_insensitive_and_not_limited_to_twenty_lines(self):
        self.write(self.src, "Module.bsl", "Procedure OnWrite(Cancel)\n" + "// context\n" * 25
                   + "if thisobject.dataexchange.load then\nreturn;\nendif;\nEndProcedure\n")
        self.assertEqual([f for f in self.audit() if f["rule"] == "V5"], [])

    def test_handler_cannot_borrow_guard_from_next_procedure(self):
        self.write(self.src, "Module.bsl", "Procedure BeforeWrite(Cancel)\nEndProcedure\n"
                   "Procedure Other()\nIf DataExchange.Load Then Return; EndIf;\nEndProcedure\n")
        findings = [f for f in self.audit() if f["rule"] == "V5"]
        self.assertEqual(len(findings), 1)
        self.assertEqual(findings[0]["procedure"], "BeforeWrite")
        self.assertNotIn("Then Return", findings[0]["fix"])

    def test_comments_and_strings_do_not_generate_code_warnings(self):
        self.write(self.src, "Module.bsl", "Procedure Example()\n"
                   '// BeginTransaction(); Cancel = False; CurrentDate();\n'
                   'Text = "Cancel = False; BeginTransaction(); CurrentDate();";\nEndProcedure\n')
        self.assertEqual(self.audit(), [])

    def test_date_and_posting_warnings_include_context_and_require_runtime_proof(self):
        self.write(self.src, "Module.bsl", "Procedure Posting(Cancel, Mode)\n"
                   "Stamp = CurrentDate();\nQ = New Query;\n"
                   'Q.Text = "SELECT * FROM AccumulationRegister.Ledger.Balance()";\nEndProcedure\n')
        findings = self.audit()
        self.assertTrue({"F7", "P6", "P8"}.issubset({f["rule"] for f in findings}), findings)
        for item in findings:
            self.assertEqual(item["classification"], "needs_runtime_proof")
            self.assertEqual(item["procedure"], "Posting")
            self.assertTrue(item["context"])
        date = next(f for f in findings if f["rule"] == "F7")
        self.assertIn("log", (date["why"] + date["fix"]).lower())


if __name__ == "__main__":
    unittest.main(verbosity=2)
