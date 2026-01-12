#!/bin/bash

#SBATCH -J fastqc_array
#SBATCH -o ./slurm_out/%x_%A_%a.out
#SBATCH -e ./slurm_out/%x_%A_%a.err
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH -t 3-00:00:00
#SBATCH --constraint=cal
#SBATCH --array=1-2

###############################################################################
# SLURM Array Job: Run FastQC on all samples in parallel
#
# This script submits an array job to SLURM that:
# 1. Reads sample names from config/samples_names.txt
# 2. For each sample, executes 01_fastqc_one_sample.sh
# 3. Processes samples in parallel (one per SLURM task)
#
# USAGE:
#   sbatch scripts/01_qc/01_fastqc_array.sbatch
#
# NOTES:
#   - Execute from repository root directory
#   - Update #SBATCH --array=1-N to match number of samples
#   - Log files saved to: scripts/01_qc/slurm_out/fastqc_array_<job_id>_<task_id>.out
#   - Constraint: cal (execute on cal nodes)
#   - Time limit: 3 days
#
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/../.."
cd "$REPO_ROOT" || exit 1

# Load configuration
source scripts/utils/load_config.sh

# Load sample names
SAMPLES_FILE="config/samples_names.txt"
if [[ ! -f "$SAMPLES_FILE" ]]; then
    echo "ERROR: Missing $SAMPLES_FILE" >&2
    exit 1
fi

# Get sample names into array
mapfile -t SAMPLES < <(grep -v '^[[:space:]]*$' "$SAMPLES_FILE")

# Get current sample from array index
TASK_ID=$((SLURM_ARRAY_TASK_ID - 1))  # Convert to 0-based index
SAMPLE_ID="${SAMPLES[$TASK_ID]}"

if [[ -z "$SAMPLE_ID" ]]; then
    echo "ERROR: No sample at index $TASK_ID" >&2
    exit 1
fi

echo "=========================================="
echo "SLURM Array Job: FastQC"
echo "=========================================="
echo "Job ID:        $SLURM_JOB_ID"
echo "Task ID:       $SLURM_ARRAY_TASK_ID"
echo "Sample:        $SAMPLE_ID"
echo "Repository:    $REPO_ROOT"
echo "Base Dir:      $BASE_DIR"
echo "=========================================="

# Run FastQC for this sample
bash scripts/01_qc/01_fastqc_one_sample.sh "$SAMPLE_ID"

echo "=========================================="
echo "FastQC completed for sample: $SAMPLE_ID"
echo "=========================================="
