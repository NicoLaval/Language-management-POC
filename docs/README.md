# Sphinx Multi-version Documentation

This directory contains the configuration to generate multi-version Sphinx documentation for VTL.

## Structure

```
docs/
├── conf.py
├── index.rst
├── requirements.txt
├── Makefile
├── _static/
└── _templates/
```

## Installation

```bash
pip install -r requirements.txt
```

## Build

### Build all versions (recommended)

```bash
make html-multiversion
```

This will:
- Automatically detect all branches `v2.1`, `v2.2`
- Build documentation for each version
- Create a directory for each version in `_build/html/`

### Build single version

```bash
make html
```

## Local testing

After building the documentation:

```bash
make serve
```

Then open http://localhost:8000 in your browser.

## Supported versions

- **v2.2** : Complete documentation (User Manual + Reference Manual)
- **v2.1** : Complete documentation (User Manual + Reference Manual)
- **v2.0** : No Sphinx documentation (ANTLR grammar only)

## Configuration

Main configuration is in `conf.py`:
- `smv_branch_whitelist`: Pattern to select branches
- `smv_latest_version`: Version considered as latest
- `smv_rename_latest_version`: Name given to latest version

## Deployment

Deployment is automatic via GitHub Actions (see `.github/workflows/deploy-docs.yml`). The workflow builds documentation on every push to version branches and deploys to GitHub Pages.

