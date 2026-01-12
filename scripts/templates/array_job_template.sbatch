#!/bin/bash

#SBATCH -J array_job_template
#SBATCH -o slurm_out/%x_%A_%a.out
#SBATCH -e slurm_out/%x_%A_%a.err
#SBATCH -c 8
#SBATCH --mem=16G
#SBATCH -t 3-00:00:00
#SBATCH --constrain=cal
#SBATCH --array=1-N

###############################################################################
# SLURM Array Job Template
#
# Use this template to create scalable array jobs on HPC clusters.
#
# KEY FEATURES:
# - Processes one sample per SLURM task
# - Reads sample names from config/samples_names.txt
# - Each task calls a bash script with the sample ID
# - Parallel execution with automatic job scheduling
#
# SETUP INSTRUCTIONS:
#
# 1. Copy this template:
#    cp scripts/templates/array_job_template.sbatch scripts/<step>/<step>_array.sbatch
#
# 2. Customize SLURM directives (top section):
#    - Change job name: -J your_job_name
#    - Adjust CPU cores: -c <number>
#    - Adjust memory: --mem=<amount>G
#    - Set time limit: -t <HH:MM:SS> or <days-HH:MM:SS>
#    - Set array size: --array=1-N (N = number of samples)
#
# 3. Replace function call:
#    bash scripts/bash/your_one_sample_script.sh "$SAMPLE_ID"
#
# 4. Submit the job:
#    sbatch scripts/<step>/<step>_array.sbatch
#
# WORKFLOW:
#
#   config/samples_names.txt (sample list)
#            |
#            v
#   sbatch scripts/<step>/<step>_array.sbatch
#            |
#            +---> SLURM Task 1: bash scripts/bash/script.sh sample_1
#            +---> SLURM Task 2: bash scripts/bash/script.sh sample_2
#            +---> SLURM Task N: bash scripts/bash/script.sh sample_N
#
# MONITORING:
#
#   # Check job status
#   squeue -j <job_id>
#
#   # View log file
#   tail -f scripts/<step>/slurm_out/array_job_template_<job_id>_<task_id>.out
#
#   # Cancel job
#   scancel <job_id>
#
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/../.."
cd "$REPO_ROOT" || exit 1

# Load configuration and environment
source scripts/utils/load_config.sh

# Load sample names from config file
SAMPLES_FILE="config/samples_names.txt"
if [[ ! -f "$SAMPLES_FILE" ]]; then
    echo "ERROR: Missing $SAMPLES_FILE" >&2
    exit 1
fi

# Read samples into array (skip empty lines)
mapfile -t SAMPLES < <(grep -v '^[[:space:]]*$' "$SAMPLES_FILE")

# Get current sample ID based on SLURM array task ID
TASK_ID=$((SLURM_ARRAY_TASK_ID - 1))  # Convert to 0-based index
SAMPLE_ID="${SAMPLES[$TASK_ID]}"

if [[ -z "$SAMPLE_ID" ]]; then
    echo "ERROR: No sample at index $TASK_ID" >&2
    echo "Available samples: ${#SAMPLES[@]}"
    exit 1
fi

# Print job information
echo "=========================================="
echo "SLURM Array Job"
echo "=========================================="
echo "Job ID:        $SLURM_JOB_ID"
echo "Task ID:       $SLURM_ARRAY_TASK_ID / $SLURM_ARRAY_JOB_NUM_TASKS"
echo "Sample:        $SAMPLE_ID"
echo "CPU Cores:     $SLURM_CPUS_PER_TASK"
echo "Memory:        $SLURM_MEM_PER_NODE"
echo "Repository:    $REPO_ROOT"
echo "Base Dir:      $BASE_DIR"
echo "=========================================="

# CUSTOMIZE: Replace with your actual script and sample parameter
# bash scripts/bash/your_one_sample_script.sh "$SAMPLE_ID"

echo "Placeholder: Would execute analysis on sample $SAMPLE_ID"

echo "=========================================="
echo "Task completed for sample: $SAMPLE_ID"
echo "=========================================="
