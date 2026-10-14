"""Offline seed orchestration checks; no native 1C is launched."""
import importlib
import json
import os
from pathlib import Path
import tempfile
import time
import unittest
from unittest.mock import patch


class SeedWorkflowTests(unittest.TestCase):
    def setUp(self):
        self.seed = importlib.import_module('seed_workflow')
        self.temp = tempfile.TemporaryDirectory(prefix='seed workflow ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.ib = self.root / 'scratch' / 'uat' / 'fixture' / 'ib'
        self.ib.mkdir(parents=True)
        (self.ib / '1Cv8.1CD').write_bytes(b'fixture, not 1C')
        (self.ib.parent / '.uat-clone.json').write_text(json.dumps({
            'ib_path': str(self.ib), 'source_sha256': 'a' * 64}), encoding='utf-8')
        self.addCleanup(patch.stopall)
        patch.object(self.seed.runtime, 'WORKSPACE_ROOT', self.root).start()
        self.calls = []
        self.fail_phase = None
        self.bad_manifest = False
        self.bad_result = False
        self.change_manifest = False
        self.flag = False
        patch.object(self.seed.runtime, '_execute', side_effect=self.execute).start()

    def execute(self, exe, args, timeout):
        command, run_id, result, phase, manifest = args[args.index('/C') + 1].split(';')
        user = args[args.index('/N') + 1]
        self.calls.append((command, phase, user))
        path = Path(manifest)
        if phase == 'enable':
            path.write_text(json.dumps({'run_id': run_id, 'prior_enabled': self.flag}), encoding='utf-8')
            self.flag = True
        elif phase == 'restore':
            self.flag = json.loads(path.read_text())['prior_enabled']
        elif phase.split('-')[0] in self.seed.MAKERS:
            domain = phase.split('-')[0]
            months = 1 if phase.endswith('-smoke') else 21
            refs = [{'document': name, 'uuid': f'00000000-0000-0000-0000-{i:012d}'}
                    for i, name in enumerate(self.seed.DOCUMENTS[domain] * months, 1)]
            if self.bad_manifest:
                refs.append(refs[0])
            path.write_text(json.dumps({'run_id': run_id, 'phase': domain, 'months': months,
                'maker': self.seed.MAKERS[domain], 'checker': 'ketoan_truong', 'refs': refs}), encoding='utf-8')
        if phase == self.fail_phase:
            raise self.seed.runtime.RuntimeSafetyError('injected fixture failure')
        if self.change_manifest and phase == 'check-ar':
            data = json.loads(path.read_text())
            data['refs'][0]['uuid'] = '00000000-0000-0000-0000-999999999999'
            path.write_text(json.dumps(data), encoding='utf-8')
        passed = not (self.bad_result and phase == 'ar-smoke')
        Path(result).write_text(json.dumps({'run_id': run_id, 'status': 'PASS', 'cases': [
            {'name': phase, 'passed': passed, 'error': '' if passed else 'fixture evidence failure'}]}), encoding='utf-8')
        now = time.time_ns()
        os.utime(result, ns=(now, now))
        if path.exists() and phase.split('-')[0] in self.seed.MAKERS:
            os.utime(path, ns=(now, now))

    def test_full_smoke_real_session_order_and_flag_restored(self):
        result = self.seed.run_workflow('full', self.ib, smoke=True)
        self.assertEqual(result['status'], 'PASS')
        self.assertEqual([(p, u) for _, p, u in self.calls], [
            ('enable', 'Admin'), ('master', 'Admin'), ('ar-smoke', 'ketoan_ar'),
            ('check-ar', 'ketoan_truong'), ('ap-smoke', 'ketoan_ap'),
            ('check-ap', 'ketoan_truong'), ('netting-smoke', 'chuyenvien_doisoat'),
            ('check-netting', 'ketoan_truong'), ('restore', 'Admin')])
        self.assertFalse(self.flag)
        self.assertEqual(len(result['phases']), 9)
        self.assertEqual(len(result['manifests']), 3)

    def test_failure_stops_checker_and_restores_even_after_enable_failure(self):
        for phase in ('enable', 'ar-smoke', 'check-ar', 'ap-smoke'):
            with self.subTest(phase=phase):
                self.calls.clear()
                self.fail_phase = phase
                with self.assertRaises(self.seed.runtime.RuntimeSafetyError):
                    self.seed.run_workflow('full', self.ib, smoke=True)
                self.assertEqual(self.calls[-1][1], 'restore')
                self.assertFalse(self.flag)
                self.assertNotIn('netting-smoke', [p for _, p, _ in self.calls])

    def test_prior_enabled_is_preserved(self):
        self.flag = True
        self.seed.run_workflow('clean', self.ib)
        self.assertTrue(self.flag)

    def test_restore_failure_cannot_return_pass(self):
        self.fail_phase = 'restore'
        with self.assertRaisesRegex(self.seed.runtime.RuntimeSafetyError, 'restore'):
            self.seed.run_workflow('clean', self.ib)

    def test_duplicate_refs_cannot_reach_checker(self):
        self.bad_manifest = True
        with self.assertRaises(self.seed.runtime.RuntimeSafetyError):
            self.seed.run_workflow('ar', self.ib, smoke=True)
        self.assertNotIn('check-ar', [p for _, p, _ in self.calls])
        self.assertFalse(self.flag)

    def test_protected_path_and_bad_parameters_never_launch(self):
        for mode, ib, kwargs in [('full', self.root / 'infobase', {}),
                ('unknown', self.ib, {}), ('clean', self.ib, {'admin_user': 'ketoan_truong'})]:
            with self.subTest(mode=mode, kwargs=kwargs):
                with self.assertRaises(self.seed.runtime.RuntimeSafetyError):
                    self.seed.run_workflow(mode, ib, **kwargs)
        self.assertEqual(self.calls, [])

    def test_failed_evidence_and_manifest_tampering_cannot_pass(self):
        for attr in ('bad_result', 'change_manifest'):
            with self.subTest(attr=attr):
                self.calls.clear()
                setattr(self, attr, True)
                with self.assertRaises(self.seed.runtime.RuntimeSafetyError):
                    self.seed.run_workflow('ar', self.ib, smoke=True)
                self.assertEqual(self.calls[-1][1], 'restore')
                self.assertFalse(self.flag)
                setattr(self, attr, False)

    def test_existing_lock_never_launches(self):
        directory = self.seed.runtime._result_directory(self.ib)
        (directory / 'seed-workflow.lock').write_text('existing owner')
        with self.assertRaises(self.seed.runtime.RuntimeSafetyError):
            self.seed.run_workflow('ar', self.ib, smoke=True)
        self.assertEqual(self.calls, [])
        self.assertEqual((directory / 'seed-workflow.lock').read_text(), 'existing owner')

    def test_legacy_hardened_generators_preserved_and_new_sample_is_separate(self):
        repo = Path(__file__).resolve().parent.parent
        for name in ('GeneratorARServer', 'GeneratorAPServer', 'GeneratorNettingReconcileServer'):
            relative = Path('CommonModules') / name / 'Ext' / 'Module.bsl'
            source = (repo / 'src' / relative).read_text(encoding='utf-8-sig')
            baseline = repo / 'scratch' / 'uat' / 'baseline-src' / relative
            if baseline.exists():
                self.assertTrue(source.startswith(baseline.read_text(encoding='utf-8-sig').rstrip()))
            sample = source[source.index('Procedure SinhMauUAT('):]
            self.assertIn('Export', sample.splitlines()[0])
            self.assertNotIn('DocumentWriteMode.Posting', sample)
            self.assertNotIn('DataExchange.Load', sample)
            self.assertIn('SeedWorkflowServer.RequireMaker(', sample)
            self.assertIn('SeedWorkflowServer.SavePending(', sample)


if __name__ == '__main__':
    unittest.main()
