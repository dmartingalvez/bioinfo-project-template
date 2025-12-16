# Bioinformatics Project Template

This repository provides a template for bioinformatics analysis projects (RNA-seq, metagenomics, variant calling, proteomics, etc.). It includes a standard folder structure, initialization scripts, and configuration guidance.

## Minimum Requirements
- bash ≥ 4, coreutils, awk/sed/grep
- `yq` to read YAML in shell
- Git ≥ 2.30
- Quarto (optional for documentation)

macOS (Homebrew):
```
brew install yq git quarto rsync gnu-sed gawk
```

## Initialize the Project
```
bash scripts/setup/init_project.sh
```
This creates base folders and configuration files under `config/`.

## Configure Git and SSH Keys
1. Generate a key:
```
ssh-keygen -t ed25519 -C "you@email" -f ~/.ssh/id_ed25519
ssh-add ~/.ssh/id_ed25519
```
2. Add the public key to GitHub/GitLab and to your cluster account.
3. Set remote and push:
```
git init && git add . && git commit -m "Init"
git remote add origin https://github.com/<user>/<repo>.git
git push -u origin main
```

## Cluster Connection
Configure `~/.ssh/config`:
```
Host cluster
  HostName cluster.univ.es
  User username
  IdentityFile ~/.ssh/id_ed25519
```
Connect with:
```
ssh cluster
```

## Next Steps
- Edit `config/config.yaml` and `config/config_local.yaml`.
- Use templates under `scripts/templates/` to scaffold analyses.
- Read the guide in `docs/bioinformatics_project_template.qmd`.