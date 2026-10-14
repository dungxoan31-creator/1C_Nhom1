"""Posting lifecycle: requires fresh ZeroResidual, RepostParity and GLSubledger evidence."""
import sys

from onec_runtime import run_cli


if __name__ == '__main__':
    sys.exit(run_cli('RunPostingLifecycleTests'))
