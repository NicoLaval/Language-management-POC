# Language Management POC

A proof of concept demonstrating language version control using Git branches for VTL (Validation and Transformation Language) versions, with automated multi-version Sphinx documentation deployment.

## Overview

This project demonstrates an alternative approach to managing multiple versions of a language specification. Instead of organizing versions as subdirectories (as in the `vtl` project), each version is maintained in its own Git branch, enabling:

- **Clean version isolation**: Each version lives in its own branch
- **Multi-version documentation**: Single Sphinx documentation site automatically built for all versions
- **Automated deployment**: GitHub Actions builds and deploys documentation on every push
- **Easy version management**: Switch between versions with `git checkout`

## Project Structure

```
Language-management-POC/
├── develop/          # Primary development branch (infrastructure + latest version)
│   ├── docs/         # Sphinx multi-version configuration
│   ├── .github/      # GitHub Actions workflows
│   └── README.md
├── v2.0/ (branch)    # Version 2.0 - ANTLR grammar only
├── v2.1/ (branch)    # Version 2.1 - Source + documentation
└── v2.2/ (branch)    # Version 2.2 - Source + documentation (latest)
```

## Documentation

**[Deployed Documentation](https://nicolaval.github.io/Language-management-POC/)** - Multi-version Sphinx documentation accessible online

### Accessing Different Versions

Documentation is available for multiple versions:

- **[Latest (v2.2)](https://nicolaval.github.io/Language-management-POC/latest/)** - Latest version with all features
- **[v2.2](https://nicolaval.github.io/Language-management-POC/v2.2/)** - Version 2.2 documentation
- **[v2.1](https://nicolaval.github.io/Language-management-POC/v2.1/)** - Version 2.1 documentation

**Note**: Version 2.0 does not have Sphinx documentation (ANTLR grammar only).

## Quick Start

### Prerequisites

- Git
- Python 3.11+
- GitHub account

### Local Development

1. **Clone the repository**:
```bash
git clone https://github.com/YOUR-USERNAME/Language-management-POC.git
cd Language-management-POC
```

2. **Install dependencies**:
```bash
pip install -r docs/requirements.txt
```

3. **Build documentation locally**:
```bash
cd docs
make html-multiversion
make serve
```

4. **Open in browser**: http://localhost:8000

### Working with Versions

- **Switch to a version branch**: `git checkout v2.1`
- **Make version-specific changes**: Edit files in the branch
- **Update documentation**: Edit files in `docs/` directory
- **Push changes**: `git push origin v2.1` (triggers automatic rebuild)

## Migration Guide

For teams migrating from the `vtl` project structure (versions as subdirectories) to this branch-based approach, see the comprehensive **[Migration Guide](MIGRATION.md)**.

The migration guide covers:
- Step-by-step migration process
- Automated migration script usage
- GitHub repository configuration
- Troubleshooting common issues
- Post-migration verification

## Features

### Multi-Version Documentation

- **sphinx-multiversion**: Automatically detects and builds documentation for all version branches
- **Version selector**: Dropdown in documentation sidebar for easy navigation
- **Latest alias**: `/latest/` automatically points to the most recent version

### Automated Deployment

- **GitHub Actions**: Builds documentation on every push to version branches
- **GitHub Pages**: Automatically deploys built documentation
- **No manual steps**: Everything happens automatically

### Version Management

- **Branch-based**: Each version is isolated in its own branch
- **Easy switching**: Use `git checkout` to work on different versions
- **Independent updates**: Update one version without affecting others

## Branch Strategy

- **`develop`**: Primary development branch (infrastructure + latest version integration)
- **`v2.0`, `v2.1`, `v2.2`**: Version-specific branches with source code and documentation
- **Never merge version branches**: Each version branch is independent

**Workflow:**
- Latest version (v2.2): Feature branches → `develop` → PR → `v2.2`
- Older versions (v2.0, v2.1): Feature branches → version branch directly
- See [Version Management Guide](VERSION_MANAGEMENT.md#branch-strategy) for detailed workflow

## Version Management

This project uses automated change propagation between version branches. When fixes or improvements are made to one version, they can be automatically propagated to newer versions.

See **[Version Management Guide](VERSION_MANAGEMENT.md)** for:
- Automated backporting workflows
- Label-based change propagation
- Best practices for managing changes across versions
- Setup instructions for GitHub Actions

## Contributing

**For latest version (v2.2) - all changes:**
1. Create feature branch from `develop`: `git checkout develop && git checkout -b feature/new-feature`
2. Make changes (code, documentation, infrastructure, etc.)
3. Create PR targeting `develop`
4. After merge, create PR from `develop` → `v2.2` when ready for release
5. Add backport labels on `develop` PRs if fixes should propagate to older versions

**For older versions (v2.0, v2.1):**
1. Checkout the version branch: `git checkout v2.1`
2. Create feature branch: `git checkout -b fix/typo`
3. Make changes and create PR targeting the version branch directly
4. Add backport labels if fix should propagate forward to newer versions

## Related Projects

- **[vtl](https://github.com/sdmx-twg/vtl)**: Original VTL project with version subdirectories
- **[VTL Specification](https://sdmx.org)**: Official VTL specification from SDMX Technical Working Group

## License

See [LICENSE](LICENSE) file for details.
