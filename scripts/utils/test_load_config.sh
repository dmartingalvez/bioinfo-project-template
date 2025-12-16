#!/bin/bash

set -e

echo ">>> Testing load_config.sh..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/../.."
cd "$REPO_ROOT" || exit 1

source scripts/utils/load_config.sh

echo ""
echo "=== Loaded Configuration ==="
echo "BASE_DIR       = $BASE_DIR"
echo "REPO_DIR       = $REPO_DIR"
echo "FASTQ_RAW_DIR  = $FASTQ_RAW_DIR"
echo "FASTQ_CLEAN_DIR= $FASTQ_CLEAN_DIR"
echo "REFERENCE_DIR  = $REFERENCE_DIR"
echo "ANALYSES_DIR   = $ANALYSES_DIR"
echo ""
echo "THREADS        = $THREADS"
echo "MEMORY         = $MEMORY"
echo "QUEUE          = $QUEUE"

echo ""
echo ">>> Checking folders existence (if base_dir is correct)..."
[ -d "$BASE_DIR" ] && echo "OK: BASE_DIR exists" || echo "WARNING: BASE_DIR does not exist"
[ -d "$FASTQ_RAW_DIR" ] && echo "OK: FASTQ_RAW_DIR exists" || echo "WARNING: FASTQ_RAW_DIR does not exist"
[ -d "$ANALYSES_DIR" ] && echo "OK: ANALYSES_DIR exists" || echo "WARNING: ANALYSES_DIR does not exist"

echo ""
echo ">>> load_config.sh test finished."