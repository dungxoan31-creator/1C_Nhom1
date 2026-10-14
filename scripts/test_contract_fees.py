"""Read-only contract fee queries verified by a correlated VerifyContractFees case.
Fee updates are outside this wrapper's scope."""
import sys

from onec_runtime import run_cli


if __name__ == '__main__':
    sys.exit(run_cli('VerifyContractFees'))
