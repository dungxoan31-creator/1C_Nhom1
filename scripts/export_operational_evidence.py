"""Read-only trial-balance export with a correlated ExportTrialBalanceEvidence case.
BSL writes data to result_path + '.evidence.json' beside this run's strict result;
the helper validates and returns only {run_id,status,cases}."""
import sys

from onec_runtime import run_cli


if __name__ == '__main__':
    sys.exit(run_cli('ExportTrialBalanceEvidence'))
