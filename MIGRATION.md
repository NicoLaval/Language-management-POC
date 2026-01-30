# Migration Guide: From `vtl` to `Language-management-POC`

This comprehensive guide explains how to migrate from the `vtl` project structure (with versions as subdirectories) to the `Language-management-POC` project structure (with versions as Git branches) and set up multi-version Sphinx documentation.

## Overview

### Current Structure (`vtl` project)

The `vtl` project has versions organized as subdirectories:

```
vtl/
├── v2.0/
│   ├── src/          # ANTLR grammar
│   ├── pom.xml
│   └── README.md
├── v2.1/
│   ├── src/          # ANTLR grammar
│   ├── docs/         # Sphinx documentation
│   ├── pom.xml
│   └── README.md
└── v2.2/
    ├── src/          # ANTLR grammar
    ├── docs/         # Sphinx documentation
    ├── pom.xml
    └── README.md
```

### Target Structure (`Language-management-POC` project)

The `Language-management-POC` project uses Git branches for version management:

```
Language-management-POC/
├── develop/          # Primary development branch
│   ├── docs/         # Sphinx multi-version configuration
│   ├── .github/      # GitHub Actions workflows
│   └── README.md
├── v2.0/ (branch)    # Version 2.0 content
│   ├── src/
│   └── pom.xml
├── v2.1/ (branch)    # Version 2.1 content
│   ├── src/
│   ├── docs/
│   └── pom.xml
└── v2.2/ (branch)    # Version 2.2 content
    ├── src/
    ├── docs/
    └── pom.xml
```

## Benefits of Migration

1. **Clean version separation**: Each version is isolated in its own branch
2. **Multi-version documentation**: Single Sphinx documentation site for all versions
3. **Easy version management**: Switch between versions with `git checkout`
4. **Automated deployment**: GitHub Actions builds and deploys documentation automatically
5. **Version navigation**: Dropdown selector in documentation sidebar

## Prerequisites

- Git installed and configured
- Access to the `vtl` project directory
- Access to the `Language-management-POC` repository (or create it)
- Python 3.11+ (for building Sphinx documentation)
- GitHub account with repository access

## Migration Steps

### Step 1: Prepare the Target Repository

1. **Clone or create the `Language-management-POC` repository**:

```bash
# If repository doesn't exist, create it on GitHub first
# Then clone it:
git clone https://github.com/YOUR-USERNAME/Language-management-POC.git
cd Language-management-POC
```

2. **Ensure you're on the `develop` branch** (or create it from current branch):

```bash
# If main exists, rename it to develop
git checkout main
git branch -m main develop

# Or if starting fresh
git checkout -b develop
```

### Step 2: Run the Migration Script

The project includes an automated migration script that will:
- Create branches for each version (`v2.0`, `v2.1`, `v2.2`)
- Copy content from `vtl` subdirectories to corresponding branches
- Create initial commits for each version

1. **Make the script executable**:

```bash
chmod +x scripts/migrate-versions.sh
```

2. **Run the migration script**:

```bash
# Adjust the path to your vtl project
./scripts/migrate-versions.sh /path/to/vtl
```

The script will:
- Checkout `develop`
- For each version (2.0, 2.1, 2.2):
  - Create a branch `v2.X` from `develop`
  - Copy `src/` from `vtl/v2.X/src/`
  - Copy `docs/` from `vtl/v2.X/docs/` (if it exists)
  - Copy `pom.xml` from `vtl/v2.X/pom.xml` (if it exists)
  - Create a commit with the migrated content
- Return to `develop` branch

**Note**: The script will skip `v2.0` if it doesn't have a `docs/` folder (which is expected).

### Step 3: Verify Branch Structure

After migration, verify that branches were created correctly:

```bash
# List all branches
git branch -a

# Verify v2.0 doesn't have docs/ (expected)
git ls-tree -r v2.0 --name-only | grep "^docs/"
# Should return nothing

# Verify v2.1 has docs/
git ls-tree -r v2.1 --name-only | grep "^docs/"
# Should list files

# Verify v2.2 has docs/
git ls-tree -r v2.2 --name-only | grep "^docs/"
# Should list files
```

### Step 4: Set Up Multi-Version Documentation

The `develop` branch should already contain the Sphinx multi-version setup. If not, ensure you have:

1. **`docs/conf.py`** with `sphinx-multiversion` configuration:

```python
smv_branch_whitelist = r'^v2\.[12]$'  # v2.1 and v2.2 only (v2.0 has no docs)
smv_latest_version = 'v2.2'
smv_rename_latest_version = 'latest'
```

2. **`docs/requirements.txt`** with dependencies:

```
sphinx>=5.0.0
sphinx-rtd-theme>=1.0.0
sphinx-multiversion>=0.2.4
sphinxcontrib-mermaid>=0.8.0
sphinxcontrib-plantuml>=0.3.0
sphinx-toolbox>=3.0.0
jinja2>=3.0.0
```

3. **`.github/workflows/deploy-docs.yml`** for automated deployment

4. **`docs/_templates/layout.html`** for version selector dropdown

### Step 5: Clean Up Old Branches (if needed)

If you have an old `master` branch that needs to be removed:

```bash
# Delete master branch locally (if it exists)
git branch -D master

# Delete master branch on remote GitHub
git push origin --delete master
```

### Step 6: Commit and Push All Changes

```bash
# Ensure you're on develop
git checkout develop

# Add all files
git add docs/ .github/ *.md scripts/

# Verify what will be committed
git status

# Commit
git commit -m "Add Sphinx multi-version documentation setup"

# Push develop branch
git push -u origin develop

# Push all version branches
git push -u origin v2.0
git push -u origin v2.1
git push -u origin v2.2

# Or push all at once
git push -u origin --all
```

### Step 7: Configure GitHub Repository

1. **Set `develop` as default branch**:
   - Go to repository **Settings** → **Branches**
   - Set **Default branch** to `develop`
   - If it's not set, click the change button next to the default branch
   - Select `develop` and confirm

2. **Enable GitHub Pages**:
   - Go to repository **Settings** → **Pages**
   - Under **Source**, select **GitHub Actions**
   - Click **Save**

### Step 8: Verify Deployment

1. **Check GitHub Actions**:
   - Go to repository **Actions** tab
   - The workflow "Build and Deploy Documentation" should run automatically
   - Wait for completion (2-5 minutes)

2. **Access deployed documentation**:
   - Go to **Settings** → **Pages**
   - Your documentation URL will be displayed
   - Example: `https://YOUR-USERNAME.github.io/Language-management-POC/`

3. **Verify version selector**:
   - Open the documentation in a browser
   - Check that the version dropdown appears in the sidebar
   - Test switching between versions

### Step 9: (Optional) Test Locally

To test the documentation before or after deployment:

```bash
cd /path/to/Language-management-POC

# Install Python dependencies
pip install -r docs/requirements.txt

# Build the documentation
cd docs
make html-multiversion

# Serve locally
make serve
```

Then open http://localhost:8000 in your browser.

## Documentation Structure After Migration

Once deployed, the documentation will be accessible at:

```
https://YOUR-USERNAME.github.io/Language-management-POC/
├── index.html          # Landing page with version links
├── latest/             # Alias to v2.2 (latest version)
│   ├── index.html
│   └── ...
├── v2.2/
│   ├── index.html
│   └── ...
└── v2.1/
    ├── index.html
    └── ...
```

**Note**: `v2.0` will not appear in the documentation because it doesn't have Sphinx documentation (only ANTLR grammar).

## Troubleshooting

### Migration Script Issues

**Error: "Source directory does not exist"**
- Verify the path to the `vtl` project is correct
- Use absolute path if relative path doesn't work

**Error: "Branch already exists"**
- The script will checkout existing branches
- If you want to re-migrate, delete branches first: `git branch -D v2.0 v2.1 v2.2`

### Documentation Build Issues

**The workflow doesn't trigger**
- Verify that GitHub Pages is enabled with "GitHub Actions" as source
- Verify that the file `.github/workflows/deploy-docs.yml` is present on `develop`
- Check permissions in repository settings

**Documentation doesn't display**
- Check workflow logs in the **Actions** tab
- Verify that `v2.1` and `v2.2` branches have a `docs/` folder with a `conf.py`
- Verify that the `v2.0` branch does **not** have a `docs/` folder (otherwise sphinx-multiversion might try to build it)

**Error: "sphinx-multiversion not found"**
- Check `docs/requirements.txt` has `sphinx-multiversion>=0.2.4`
- Install dependencies: `pip install -r docs/requirements.txt`

**Error: "No documentation found for branch"**
- Verify `v2.1` and `v2.2` branches have `docs/` folder
- Verify `docs/conf.py` exists in those branches
- Check `smv_branch_whitelist` pattern in `docs/conf.py` matches your branches (should be `r'^v2\.[12]$'`)

**404 Error on GitHub Pages**
- Ensure GitHub Pages is enabled with "GitHub Actions" as source
- Check workflow completed successfully in **Actions** tab
- Verify `environment: github-pages` is set in workflow file

**Version selector not appearing**
- Verify `docs/_templates/layout.html` exists on `develop` branch
- Check that `html_static_path = ['_static']` is in `docs/conf.py`
- Clear browser cache and reload

**Build error**
- Verify all dependencies are in `docs/requirements.txt`
- Verify the `smv_branch_whitelist` pattern in `docs/conf.py` matches your branches
- **Note**: The version of `sphinx-multiversion` should be `>=0.2.4` (version 0.3.0 doesn't exist)

## Updating Documentation After Migration

To update documentation for a specific version:

1. **Checkout the version branch**:
```bash
git checkout v2.1
```

2. **Make changes to documentation**:
```bash
# Edit files in docs/
vim docs/some-file.rst
```

3. **Commit and push**:
```bash
git add docs/
git commit -m "Update v2.1 documentation"
git push origin v2.1
```

4. **GitHub Actions will automatically**:
   - Detect the push to `v2.1`
   - Rebuild the documentation for that version
   - Redeploy to GitHub Pages

## Important Notes

1. **v2.0 has no Sphinx documentation**: This is expected. Version 2.0 only contains ANTLR grammar and tests.

2. **sphinx-multiversion behavior**:
   - Automatically detects branches matching `smv_branch_whitelist`
   - Builds documentation for each detected branch
   - Creates separate output directories for each version
   - Ignores branches without `docs/` folder

3. **Version selector**:
   - Appears in the sidebar of all documentation pages
   - Allows switching between `latest`, `v2.2`, and `v2.1`
   - Preserves your position in the documentation when switching

4. **Branch management**:
   - Always work on version-specific branches for version-specific changes
   - Use `develop` branch for documentation infrastructure changes and latest version development
   - Never merge version branches into each other

## Migration Checklist

- [ ] `Language-management-POC` repository created/cloned
- [ ] Migration script executed successfully
- [ ] Branches `v2.0`, `v2.1`, `v2.2` created and verified
- [ ] `v2.0` confirmed to have no `docs/` folder
- [ ] `v2.1` and `v2.2` confirmed to have `docs/` folders
- [ ] Old `master` branch removed (if it existed)
- [ ] All branches pushed to remote
- [ ] `develop` set as default branch on GitHub
- [ ] GitHub Pages enabled with GitHub Actions source
- [ ] Workflow runs successfully
- [ ] Documentation accessible on GitHub Pages
- [ ] Version selector appears and works correctly

## Next Steps

After successful migration:

1. **Update README.md** with link to deployed documentation
2. **Test version switching** in the documentation
3. **Share the documentation URL** with your team
4. **Set up branch protection rules** (optional) to prevent accidental changes to version branches
