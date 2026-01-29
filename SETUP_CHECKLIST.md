# Setup Checklist: Backport System

Checklist to prepare the backport system for testing.

## Manual Steps Required

### 1. Push Files to GitHub

```bash
cd /Users/nicolaval/MS/Projects/Language-management-POC

# Ensure on develop branch
git checkout develop

# Add new files
git add .github/backport.json .github/workflows/backport.yml TESTING.md SETUP_CHECKLIST.md

# Commit
git commit -m "Setup automated backport system"

# Push to GitHub
git push origin develop
```

### 2. Create GitHub Labels

**Option A: Using GitHub CLI (Recommended)**

```bash
gh label create "backport-to-v2.2" --description "Backport to v2.2" --color "0E8A16"
gh label create "backport-to-v2.1" --description "Backport to v2.1" --color "0E8A16"
gh label create "backport-to-v2.0" --description "Backport to v2.0" --color "0E8A16"
```

**Option B: Using GitHub Web UI**

1. Navigate to the repository on GitHub
2. Click **Issues** → **Labels**
3. Click **New label** button
4. Create each label:
   - **Name:** `backport-to-v2.2`
   - **Description:** `Backport to v2.2`
   - **Color:** `#0E8A16` (green)
   - Click **Create label**
5. Repeat for `backport-to-v2.1` and `backport-to-v2.0`

### 3. Verify Branches Exist

Ensure these branches exist in the repository:
- [ ] `develop`
- [ ] `v2.0`
- [ ] `v2.1`
- [ ] `v2.2`

Check with:
```bash
git branch -a | grep -E "(develop|v2\.)"
```

### 4. Verify Workflow File Location

The workflow file must be on the `develop` branch for it to work:
- [ ] `.github/workflows/backport.yml` exists on `develop` branch
- [ ] `.github/backport.json` exists on `develop` branch

## Ready to Test

Once all checkboxes above are completed:

1. Files pushed to GitHub
2. Labels created
3. Branches verified
4. Workflow file on develop branch

The system is ready for testing. Follow the guide in `TESTING.md`.

## Quick Test

1. Create a test PR targeting `v2.1`
2. Add label `backport-to-v2.2`
3. Merge the PR
4. Check if a backport PR is automatically created for `v2.2`

## Troubleshooting

If something does not work:

1. **Check GitHub Actions:**
   - Navigate to **Actions** tab
   - Look for "Backport" workflow
   - Check for errors in logs

2. **Verify labels:**
   - Labels must exist before merging PR
   - Label names must match exactly (case-sensitive)

3. **Check configuration:**
   - `.github/backport.json` must be valid JSON
   - Branch names must match exactly

4. **Permissions:**
   - GitHub token needs write access
   - Default `GITHUB_TOKEN` should work for public repos
