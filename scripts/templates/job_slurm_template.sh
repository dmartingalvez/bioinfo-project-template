#!/usr/bin/env bash
#SBATCH -J job_name
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH -p short

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."
cd "$REPO_ROOT"

source scripts/utils/load_config.sh

# Example command
# your_tool --threads "$THREADS" --input "$DATA_DIR" --output "$RESULTS_DIR/example"
