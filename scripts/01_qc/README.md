# Quality Control (01_qc)

FastQC quality control for all samples.

## Scripts

- `01_fastqc_one_sample.sh` - Bash script: process one sample (for local testing)
- `01_fastqc_array.sbatch` - SLURM script: submit parallel array job

## Quick Start

### Test Locally

```bash
bash 01_fastqc_one_sample.sh sample_1
```

### Submit to HPC

```bash
sbatch 01_fastqc_array.sbatch
ls slurm_out/
```

## Configuration

Sample names read from: `config/samples_names.txt`

Output directory: `2_ANALYSES/Results/01_qc/`

Log files: `scripts/01_qc/slurm_out/`

## Documentation

See `docs/bioinformatics_project_template.qmd` for detailed information on:
- Script architecture
- One-sample scripts
- SLURM array jobs
- How to create new analysis steps
