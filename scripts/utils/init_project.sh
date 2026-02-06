#!/usr/bin/env bash
set -euo pipefail

# Initialize a generic bioinformatics project structure in the current repo

# Display usage information
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Initialize a bioinformatics project structure with:
  - Repository folder: Contains scripts, config, docs (this repository)
  - Analysis folder: Contains data and results (created in specified location)

OPTIONS:
  -p, --parent-path PATH    Parent path where the analysis folder will be created
                            (required)
  -n, --folder-name NAME    Name of the analysis folder to create
                            (required)
  -h, --help                Display this help message

STRUCTURE CREATED:
  <parent-path>/<folder-name>/
  ├── 1_DATA/               # Minimal replicated inputs
  └── 2_ANALYSES/
      ├── Scripts/          # Symlink to repository scripts
      └── Results/          # All outputs generated here

EXAMPLES:
  # Create analysis folder 'run_20251209' in /fstrat/dmartin/my-analysis
  $(basename "$0") -p /fstrat/dmartin/my-analysis -n run_20251209

  # Using long options
  $(basename "$0") --parent-path /Volumes/Data/projects --folder-name experiment_01

NOTES:
  - The repository directory will always be the location of this repository
  - The Scripts/ folder will be a symbolic link to the repository's scripts/
  - Configuration will be saved in config/config_local.yaml

EOF
  exit 0
}

# Parse command line arguments
PARENT_PATH=""
FOLDER_NAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--parent-path)
      PARENT_PATH="$2"
      shift 2
      ;;
    -n|--folder-name)
      FOLDER_NAME="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      echo "Use --help for usage information" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/../.."
cd "$REPO_ROOT"

# Validate required arguments
if [[ -z "$PARENT_PATH" ]]; then
  echo "ERROR: --parent-path is required" >&2
  echo "Use --help for usage information" >&2
  exit 1
fi

if [[ -z "$FOLDER_NAME" ]]; then
  echo "ERROR: --folder-name is required" >&2
  echo "Use --help for usage information" >&2
  exit 1
fi

# Create parent path if it doesn't exist
if [[ ! -d "$PARENT_PATH" ]]; then
  echo "Creating parent directory: $PARENT_PATH"
  mkdir -p "$PARENT_PATH"
fi

# Convert to absolute path
PARENT_PATH="$(cd "$PARENT_PATH" && pwd)"
BASE_DIR="$PARENT_PATH/$FOLDER_NAME"

# Check if analysis folder already exists
if [[ -d "$BASE_DIR" ]]; then
  echo "WARNING: Analysis folder already exists: $BASE_DIR" >&2
  read -p "Do you want to continue and update the structure? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
else
  echo "Creating analysis folder: $BASE_DIR"
  mkdir -p "$BASE_DIR"
fi

# Create analysis folder structure in base directory
echo "Creating analysis folder structure..."
mkdir -p "$BASE_DIR/1_DATA"
mkdir -p "$BASE_DIR/2_ANALYSES/Results"
mkdir -p "$BASE_DIR/logs"

# Create symlink to repository scripts
SCRIPTS_LINK="$BASE_DIR/2_ANALYSES/Scripts"
if [[ -L "$SCRIPTS_LINK" ]]; then
  echo "Symlink already exists: $SCRIPTS_LINK"
elif [[ -e "$SCRIPTS_LINK" ]]; then
  echo "WARNING: $SCRIPTS_LINK exists but is not a symlink. Skipping symlink creation."
else
  ln -s "$(pwd)/scripts" "$SCRIPTS_LINK"
  echo "Created symlink: $SCRIPTS_LINK -> $(pwd)/scripts"
fi

echo "Analysis folder structure created in: $BASE_DIR"

# Create default config files if missing
if [[ ! -f config/config.yaml ]]; then
  cat > config/config.yaml <<'YAML'
paths:
  data: 1_DATA
  analyses: 2_ANALYSES
  results: 2_ANALYSES/Results
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
base_dir: "$BASE_DIR"
repo_dir: "$(pwd)"
analysis_name: "$FOLDER_NAME"
YAML
  echo "Created config/config_local.yaml"
fi

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
REPO_ROOT="${SCRIPT_DIR}/../.."
cd "$REPO_ROOT"

source scripts/utils/load_config.sh

# Example command
# your_tool --threads "$THREADS" --input "$DATA_DIR" --output "$RESULTS_DIR/example"
BASH
chmod +x scripts/templates/job_slurm_template.sh

# Generic bash script template
cat > scripts/templates/analysis_script_template.sh <<'BASH'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/../.."
cd "$REPO_ROOT"

source scripts/utils/load_config.sh

# Example: Read from "$DATA_DIR" and write results to "$RESULTS_DIR"
BASH
chmod +x scripts/templates/analysis_script_template.sh

# Logs dir for SLURM
mkdir -p logs

echo "========================================"
echo "Project scaffolding complete!"
echo "========================================"
echo "Repository directory:  $(pwd)"
echo "Analysis base folder:  $BASE_DIR"
echo "Analysis name:         $FOLDER_NAME"
echo ""
echo "Structure created:"
echo "  $BASE_DIR/"
echo "  ├── 1_DATA/              (your input data)"
echo "  └── 2_ANALYSES/"
echo "      ├── Scripts/         (symlink to repo scripts)"
echo "      └── Results/         (analysis outputs)"
echo ""
echo "Next steps:"
echo "  1. Place your input data in: $BASE_DIR/1_DATA/"
echo "  2. Edit config/config.yaml for project settings"
echo "  3. Review config/config_local.yaml for paths"
echo "  4. Use scripts via: $BASE_DIR/2_ANALYSES/Scripts/"
echo "  5. Results will be saved in: $BASE_DIR/2_ANALYSES/Results/"
echo "========================================"
