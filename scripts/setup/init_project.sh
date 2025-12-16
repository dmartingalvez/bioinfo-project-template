#!/usr/bin/env bash
set -euo pipefail

# Initialize a generic bioinformatics project structure in the current repo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/../.."
cd "$REPO_ROOT"

# Create base folders
mkdir -p config docs scripts/utils scripts/templates scripts/setup analyses data/raw data/processed reference logs

# Create default config files if missing
if [[ ! -f config/config.yaml ]]; then
  cat > config/config.yaml <<'YAML'
paths:
  data_raw: data/raw
  data_processed: data/processed
  reference: reference
  analyses: analyses
project:
  name: "bioinfo-project"
cluster:
  threads: 8
  memory: "16G"
  queue: "short"
YAML
  echo "Created config/config.yaml"
fi

if [[ ! -f config/config_local.yaml ]]; then
  cat > config/config_local.yaml <<YAML
base_dir: "$(pwd)"
repo_dir: "$(pwd)"
YAML
  echo "Created config/config_local.yaml"
fi

# Template load_config.sh if missing
if [[ ! -f scripts/utils/load_config.sh ]]; then
  cat > scripts/utils/load_config.sh <<'BASH'
#!/usr/bin/env bash
set -euo pipefail

MAIN_CONFIG="config/config.yaml"
LOCAL_CONFIG="config/config_local.yaml"

if [[ ! -f "$MAIN_CONFIG" || ! -f "$LOCAL_CONFIG" ]]; then
  echo "ERROR: Missing config files in config/" >&2; exit 1
fi

# Require yq
if ! command -v yq >/dev/null 2>&1; then
  echo "ERROR: 'yq' is required. Install with: brew install yq" >&2
  exit 1
fi

BASE_DIR=$(yq -r '.base_dir' "$LOCAL_CONFIG")
REPO_DIR=$(yq -r '.repo_dir' "$LOCAL_CONFIG")
if [[ "$BASE_DIR" == ~* ]]; then BASE_DIR="${BASE_DIR/#\~/$HOME}"; fi
if [[ "$REPO_DIR" == ~* ]]; then REPO_DIR="${REPO_DIR/#\~/$HOME}"; fi

RAW_REL=$(yq -r '.paths.data_raw' "$MAIN_CONFIG")
PROC_REL=$(yq -r '.paths.data_processed' "$MAIN_CONFIG")
REF_REL=$(yq -r '.paths.reference' "$MAIN_CONFIG")
ANALYSES_REL=$(yq -r '.paths.analyses' "$MAIN_CONFIG")

DATA_RAW_DIR="$BASE_DIR/$RAW_REL"
DATA_PROCESSED_DIR="$BASE_DIR/$PROC_REL"
REFERENCE_DIR="$BASE_DIR/$REF_REL"
ANALYSES_DIR="$BASE_DIR/$ANALYSES_REL"

THREADS=$(yq -r '.cluster.threads' "$MAIN_CONFIG")
MEMORY=$(yq -r '.cluster.memory' "$MAIN_CONFIG")
QUEUE=$(yq -r '.cluster.queue' "$MAIN_CONFIG")
BASH
  chmod +x scripts/utils/load_config.sh
  echo "Created scripts/utils/load_config.sh"
fi

# Templates directory scripts
mkdir -p scripts/templates

# Generic job template (SLURM)
cat > scripts/templates/job_slurm_template.sh <<'BASH'
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
# your_tool --threads "$THREADS" --input "$DATA_RAW_DIR" --output "$ANALYSES_DIR/example"
BASH
chmod +x scripts/templates/job_slurm_template.sh

# Generic bash script template
cat > scripts/templates/analysis_script_template.sh <<'BASH'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."
cd "$REPO_ROOT"

source scripts/utils/load_config.sh

# Read from "$DATA_RAW_DIR" and write results to "$ANALYSES_DIR"
BASH
chmod +x scripts/templates/analysis_script_template.sh

# Logs dir for SLURM
mkdir -p logs

echo "Project scaffolding complete. Edit config/config.yaml and start building your analysis."
