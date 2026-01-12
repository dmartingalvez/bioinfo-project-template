#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."
cd "$REPO_ROOT"

source scripts/utils/load_config.sh

# Example: Read from "$DATA_DIR" and write results to "$RESULTS_DIR"
