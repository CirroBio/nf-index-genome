#!/usr/bin/env bash
# Run the test suite. Uses nf-core test data (same URLs as nf-core/modules).
# Usage: ./scripts/run_tests.sh [nf-test options]
# Example: ./scripts/run_tests.sh --tag bowtie2
#          ./scripts/run_tests.sh -stub   # run only stub tests

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if ! command -v nf-test &>/dev/null; then
    echo "nf-test not found. Install with: nextflow plugin add nf-test"
    exit 1
fi

exec nf-test test tests/workflows "$@"
