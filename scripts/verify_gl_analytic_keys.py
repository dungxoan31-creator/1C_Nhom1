"""Read-only analytic-key queries verified by a correlated VerifyGLAnalyticKeys case.
Backfills are outside this wrapper's scope."""
import sys

from onec_runtime import run_cli


if __name__ == '__main__':
    sys.exit(run_cli('VerifyGLAnalyticKeys'))
