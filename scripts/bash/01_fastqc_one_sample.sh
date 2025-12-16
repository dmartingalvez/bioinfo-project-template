#!/bin/bash

SAMPLE_ID="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/../.."
cd "$REPO_ROOT" || exit 1

source scripts/utils/load_config.sh

OUTDIR="$ANALYSES_DIR/01_fastqc"
mkdir -p "$OUTDIR"

if command -v module &> /dev/null; then
    module load fastqc
else
    echo "FastQC: no module system in this environment"
fi

fastqc -t "$THREADS" -o "$OUTDIR" "$FASTQ_RAW_DIR/${SAMPLE_ID}"*.fastq.gz