# Bioinformatics Project Template

A **generic, portable, and scalable template** for structuring any bioinformatics analysis project. Works seamlessly across **different analysis types** (RNA-seq, ChIP-seq, metagenomics, variant calling, single-cell, etc.) and **multiple computing environments** (macOS, HPC clusters, NAS storage).

## Key Features

✅ **Analysis-agnostic** - Works with any bioinformatics tool or workflow  
✅ **Portable** - Same scripts run on macOS, and HPC cluster without modification  
✅ **Scalable** - From single-machine to HPC array jobs  
✅ **Version-controlled** - Only scripts and config in repo, never large data  
✅ **Reproducible** - Configuration system ensures identical results across environments  
✅ **Secure** - SSH key management for cluster, GitHub, and NAS access  

## Repository Structure

```
bioinfo-project-repo/
├── config/                    # Configuration files
│   ├── config.yaml            # Shared, versioned paths & parameters
│   ├── config_local.yaml      # Machine-specific (never commit)
│   └── samples_names.txt       # Sample identifiers list
├── scripts/
│   ├── 01_qc/                 # Quality control analysis scripts
│   │   ├── 01_fastqc_one_sample.sh
│   │   ├── 01_fastqc_array.sbatch
│   │   ├── README.md
│   │   └── slurm_out/
│   ├── templates/             # Script templates for new analyses
│   │   ├── analysis_script_template.sh
│   │   ├── array_job_template.sbatch
│   │   ├── job_slurm_template.sh
│   │   └── slurm_out/
│   └── utils/                 # Utility scripts
│       ├── init_project.sh    # Initialize project folders
│       ├── load_config.sh     # Load YAML configuration
│       └── test_load_config.sh
├── docs/
│   ├── bioinformatics_project_template.qmd
│   ├── bioinformatics_project_template.html
│   └── index.html
├── logs/                      # Job logs and outputs
└── README.md
```

## Quick Start

### 1. Install Requirements

**macOS:**
```bash
brew install yq git quarto rsync gnu-sed gawk
```

**Linux:**
```bash
sudo apt-get install yq git quarto rsync
```

### 2. Clone Template

```bash
git clone https://github.com/dmartingalvez/bioinfo-project-template.git
cd bioinfo-project-template
```

### 3. View Complete Documentation

📖 **[Read the full guide online](https://dmartingalvez.github.io/bioinfo-project-template/bioinformatics_project_template.html)** (hosted on GitHub Pages)

Or view locally:

```bash
# Clone and open the HTML documentation
git clone https://github.com/dmartingalvez/bioinfo-project-template.git
cd bioinfo-project-template
open docs/bioinformatics_project_template.html

# Or render from source
quarto render docs/bioinformatics_project_template.qmd --to html
```

## What's Included

The complete guide covers:
- **Configuration System** - How to manage paths across environments
- **SSH Setup** - Secure access to GitHub, cluster, and NAS
- **Project Structure** - Data organization best practices
- **Script Architecture** - One-sample scripts + SLURM array jobs
- **Storage Strategy** - Working across macOS, HOME, fstrat, and NAS
- **Customization Examples** - Adapting for your analysis type

## Key Principles

1. **Repository** (`bioinfo-project-repo/`) - Only scripts, config, docs
2. **Project Data** (`my-analysis/`) - Data and results, outside repo
3. **Separation** - `1_DATA/` (inputs) and `2_ANALYSES/` (outputs)
4. **Configuration** - `config.yaml` (versioned) + `config_local.yaml` (local)
5. **Portability** - Scripts work unchanged on macOS, cluster, and NAS

## How to Use This Template for Your Project

This template is designed to be **forked or cloned** as the basis for your project-specific repository.

**See the complete guide in** [docs/bioinformatics_project_template.qmd](docs/bioinformatics_project_template.qmd) for step-by-step instructions on:
- Creating a project-specific repository
- Customizing configuration files
- Writing analysis-specific scripts
- Generating sample lists
- Testing locally before cluster execution

## Troubleshooting

| Issue | Solution |
|-------|----------|
| SSH connection fails | Check `~/.ssh/config` and test with `ssh -v cluster` |
| Missing `config_local.yaml` | Create it manually with your local paths (don't commit) |
| Scripts not executable | Run `chmod +x scripts/**/*.sh scripts/**/*.sbatch` |
| SLURM job fails | Check job logs and verify `config/samples_names.txt` exists |

## Key Resources

- **Complete Documentation**: [docs/bioinformatics_project_template.qmd](docs/bioinformatics_project_template.qmd)
- **Configuration System**: See Section 6 in the guide
- **SSH Setup**: See Section 4 in the guide
- **Creating Your Project**: See "Creating a Repository for Your Specific Project" in the guide

## License

This template is provided as-is for bioinformatics research and analysis.

## Authors and Contributors

- **David Martín-Gálvez** - Template design, configuration system, documentation
- **Mercè Palacios** - Contributions and feedback

## Contributing

This template is designed to be adapted for different projects. Feel free to customize and extend it for your specific needs.

## See Also

- [Quarto Documentation](https://quarto.org)
- [SLURM Job Scheduling](https://slurm.schedmd.com)
- [yq YAML processor](https://github.com/mikefarah/yq)
- [VS Code Remote-SSH](https://code.visualstudio.com/docs/remote/ssh)