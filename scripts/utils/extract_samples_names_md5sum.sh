#!/usr/bin/env bash
#
# -------------------------------------------------------------
# Script: extract_samples_names_md5sum.sh
# Description:
#   Extract sample names from a md5sum file.
#   Priority:
#      1) If user provides a file → use it.
#      2) Otherwise → auto-detect md5sum*.txt in FASTQ/RAW.
#   Outputs file: config/samples_names.txt
# -------------------------------------------------------------

### -------------------------------
### Locate repository root
### -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/../.."
cd "$REPO_ROOT" || exit 1

### -------------------------------
### Load configuration
### -------------------------------
source scripts/utils/load_config.sh

### -------------------------------
### Determine input file
### -------------------------------
USERFILE="$1"

if [[ -n "$USERFILE" ]]; then
    echo "→ User provided md5sum file:"
    echo "   $USERFILE"
    if [[ ! -f "$USERFILE" ]]; then
        echo "ERROR: File not found: $USERFILE"
        exit 1
    fi
    MD5FILE="$USERFILE"
else
    echo "→ No file provided, auto-detecting in:"
    echo "   $FASTQ_RAW_DIR"
    MD5FILE=$(ls "${FASTQ_RAW_DIR}"/md5sum*.txt 2>/dev/null | head -n 1)
    if [[ -z "$MD5FILE" ]]; then
        echo "ERROR: No md5sum*.txt found in:"
        echo "   $FASTQ_RAW_DIR"
        echo "TIP: Provide file explicitly:"
        echo "   bash extract_samples_names_md5sum.sh /path/to/file.txt"
        exit 1
    fi
fi

echo "✓ Using md5sum file:"
echo "  $MD5FILE"
echo ""

### -------------------------------
### Output file
### -------------------------------
OUTDIR="${REPO_ROOT}/config"
OUTFILE="${OUTDIR}/samples_names.txt"
mkdir -p "$OUTDIR"

### -------------------------------
### Extract sample names
### -------------------------------
awk '
    NR > 1 {
        for (i = 1; i <= NF; i++) {
            field = $i
            gsub(/"/, "", field)
            if (field !~ /fastq\.gz$/) continue
            n = split(field, parts, "/")
            fn = parts[n]
            if (fn ~ /_1\.fastq\.gz$/) {
                base = fn
                sub(/_1\.fastq\.gz$/, "", base)
                samples[base] = 1
            } else if (fn ~ /_2\.fastq\.gz$/) {
                base = fn
                sub(/_2\.fastq\.gz$/, "", base)
                samples[base] = 1
            }
        }
    }

    END {
        for (s in samples) print s
    }
' "$MD5FILE" | sort -u > "$OUTFILE"
# Send awk output to the outfile, sorted and unique

### -------------------------------
### Done
### -------------------------------
echo "✓ Sample names extracted."
echo "→ Saved to: $OUTFILE"
echo ""
echo "Contents:"
cat "$OUTFILE"