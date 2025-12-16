#!/bin/bash

MAIN_CONFIG="config/config.yaml"
LOCAL_CONFIG="config/config_local.yaml"

if [[ ! -f "$MAIN_CONFIG" ]]; then
    echo "ERROR: Missing config.yaml" >&2; exit 1
fi
if [[ ! -f "$LOCAL_CONFIG" ]]; then
    echo "ERROR: Missing config_local.yaml" >&2; exit 1
fi

# Machine-specific base directory
BASE_DIR=$(yq -r '.base_dir' "$LOCAL_CONFIG")
REPO_DIR=$(yq -r '.repo_dir' "$LOCAL_CONFIG")

# Expand leading tilde (~) to the full home directory so globs work
if [[ "$BASE_DIR" == ~* ]]; then
    BASE_DIR="${BASE_DIR/#\~/$HOME}"
fi
if [[ "$REPO_DIR" == ~* ]]; then
    REPO_DIR="${REPO_DIR/#\~/$HOME}"
fi

# Relative paths from config.yaml
RAW_REL=$(yq -r '.paths.fastq_raw' "$MAIN_CONFIG")
CLEAN_REL=$(yq -r '.paths.fastq_clean' "$MAIN_CONFIG")
REF_REL=$(yq -r '.paths.reference' "$MAIN_CONFIG")
ANALYSES_REL=$(yq -r '.paths.analyses' "$MAIN_CONFIG")

# Build absolute paths
FASTQ_RAW_DIR="$BASE_DIR/$RAW_REL"
FASTQ_CLEAN_DIR="$BASE_DIR/$CLEAN_REL"
REFERENCE_DIR="$BASE_DIR/$REF_REL"
ANALYSES_DIR="$BASE_DIR/$ANALYSES_REL"

# Cluster parameters
THREADS=$(yq -r '.cluster.threads' "$MAIN_CONFIG")
MEMORY=$(yq -r '.cluster.memory' "$MAIN_CONFIG")
QUEUE=$(yq -r '.cluster.queue' "$MAIN_CONFIG")