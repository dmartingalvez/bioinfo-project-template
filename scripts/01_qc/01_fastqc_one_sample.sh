#!/bin/bash

SAMPLE_ID="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/../.."
cd "$REPO_ROOT" || exit 1

source scripts/utils/load_config.sh

# Quality control output directory
OUTDIR="$ANALYSES_DIR/Results/01_qc"
mkdir -p "$OUTDIR"

# Load FastQC module (if available)
if command -v module &> /dev/null; then
    module load fastqc
else
    echo "FastQC: no module system in this environment"
fi

# Run FastQC on original FASTQ files from 1_DATA/FASTQ
fastqc -t "$THREADS" -o "$OUTDIR" "$FASTQ_RAW_DIR/${SAMPLE_ID}"*.fastq.gz

echo "FastQC completed for $SAMPLE_ID"
echo "Results saved to: $OUTDIR"