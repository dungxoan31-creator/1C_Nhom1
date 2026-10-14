"""NOT_RUN: two independent concurrent sessions are not implemented here.
RunHardeningUAT covers SeedSafety, SeedTransactions and StateGuard only."""
import sys

from onec_runtime import run_cli


if __name__ == '__main__':
    sys.exit(run_cli('RunUATSecurityProof'))
