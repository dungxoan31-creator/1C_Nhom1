"""Require ActualRole and PermissionBoundary evidence for six real 1C sessions.

BSL must attempt cross-domain draft Write() for AR/AP/reconciliation users, and
maker self-approval Write(Posting) for Admin/lead/CFO. CFO legitimately approves;
the tested boundary is self-approval, not a blanket prohibition on CFO writes.
Login exit codes, metadata rights and event-log text cannot prove either case.
"""
import argparse
import json
import sys

from onec_runtime import DEFAULT, RuntimeNotRun, RuntimeSafetyError, run_registered, validate_clone


REAL_USERS = ('Admin', 'ketoan_ar', 'ketoan_ap', 'chuyenvien_doisoat',
              'ketoan_truong', 'cfo_giamdoc')


def run_rbac_checks(ib_path, timeout=90, exe_path=DEFAULT):
    """Collect independently validated results for every user; any failure fails the matrix."""
    ib = validate_clone(ib_path)
    users = []
    for user in REAL_USERS:
        try:
            result = run_registered('RunRBACChecks', ib, user=user,
                timeout=timeout, exe_path=exe_path)
            users.append({'user': user, 'status': 'PASS', 'result': result})
        except RuntimeNotRun as exc:
            users.append({'user': user, 'status': 'NOT_RUN', 'error': str(exc)})
        except (RuntimeSafetyError, OSError, ValueError, TypeError) as exc:
            users.append({'user': user, 'status': 'FAIL', 'error': str(exc)})
    status = 'FAIL' if any(item['status'] == 'FAIL' for item in users) else (
        'NOT_RUN' if any(item['status'] == 'NOT_RUN' for item in users) else 'PASS')
    return {'status': status, 'users': users}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ib-path', required=True)
    parser.add_argument('--exe-path', default=DEFAULT)
    parser.add_argument('--timeout', type=float, default=90, help='Timeout per user session')
    args = parser.parse_args(argv)
    try:
        report = run_rbac_checks(args.ib_path, args.timeout, args.exe_path)
    except (RuntimeSafetyError, OSError, ValueError, TypeError) as exc:
        report = {'status': 'FAIL', 'error': str(exc)}
    print(json.dumps(report, ensure_ascii=True))
    return 0 if report['status'] == 'PASS' else 1


if __name__ == '__main__':
    sys.exit(main())
