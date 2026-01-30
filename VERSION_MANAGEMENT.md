# Version Management and Change Propagation

This document describes the automated system for managing changes across multiple VTL language versions and propagating fixes and updates between version branches.

## Overview

The project maintains multiple version branches (`v2.0`, `v2.1`, `v2.2`) where each version is isolated. When fixes or improvements are made to one version, they often need to be propagated to newer versions.

**Challenge:** Manual cherry-picking between version branches is time-consuming, error-prone, and risks missing fixes in newer versions.

**Solution:** Automated change propagation using GitHub Actions with label-based backporting. This document describes the setup and usage of this system.

### Branch Structure and Commit Propagation

The following diagrams illustrate how commits flow between version branches:

#### Initial Branch Structure

```
develop:  *---*---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \
v2.1:        *-------*-------*---*---*
               \       \       \
v2.2:          *-------*-------*---*---*---*---*
```

**Key Points:**
- Each version branch contains commits from previous versions (that were propagated)
- `v2.1` has all commits from `v2.0` (that were propagated) plus its own commits
- `v2.2` has all commits from `v2.1` (that were propagated) plus its own commits
- Versions are cumulative: newer versions have more commits than older versions

#### Scenario 1: Commit Stays on v2.1 Only

When a change is specific to version 2.1 and should not propagate to newer versions:

```
Before:
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \       \
v2.1:        *-------*-------*-------*---*---*
               \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*
                                                      ↑
                                            v2.2 already has more commits than v2.1

After commit on v2.1 (no propagation):
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \       \
v2.1:        *-------*-------*-------*---*---*---[v2.1 only]
               \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*
                                                      ↑
                                            v2.2 still has more commits
                                            but does not include [v2.1 only]
```

**Visual Note:** 
- `v2.1` has 6 commits (3 from v2.0 + 3 of its own, including `[v2.1 only]`)
- `v2.2` has 7 commits (3 from v2.0 + 4 of its own, but not `[v2.1 only]`)
- `v2.2` has more commits overall, but excludes the v2.1-specific commit

**Example:** Adding a v2.1-specific feature that does not exist in v2.2.

**Action:** No label needed, commit stays on `v2.1` branch only.

#### Scenario 2: Commit on v2.1 Propagates to v2.2

When a fix or improvement in v2.1 should also apply to v2.2:

```
Before propagation:
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \       \
v2.1:        *-------*-------*-------*---*---*---[Fix typo]
               \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*---*
                                                      ↑
                                            v2.2 already has more commits than v2.1

After adding label "backport-to-v2.2" and merging:
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \       \
v2.1:        *-------*-------*-------*---*---*---[Fix typo]
               \       \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*---*---[Fix typo] (cherry-picked)
                                                                          ↑
                                                            v2.2 now has even more commits
                                                            including the propagated fix
```

**Visual Note:**
- Before: `v2.1` has 6 commits, `v2.2` has 7 commits (missing the typo fix)
- After: `v2.1` has 6 commits, `v2.2` has 8 commits (now includes the typo fix)
- `v2.2` maintains its position as having more commits than `v2.1`

**Example:** Fixing a typo in documentation that exists in both v2.1 and v2.2.

**Action:** Add label `backport-to-v2.2` before merging the PR to `v2.1`.

#### Scenario 3: Commit on v2.0 Propagates to v2.1 and v2.2

When a fix in v2.0 should propagate to all newer versions:

```
Before propagation:
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*---[Bug fix]
             \       \       \
v2.1:        *-------*-------*---*---*
               \       \       \
v2.2:          *-------*-------*---*---*---*---*

After adding labels "backport-to-v2.1" and "backport-to-v2.2":
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*---[Bug fix]
             \       \       \       \
v2.1:        *-------*-------*-------[Bug fix] (cherry-picked)---*---*
               \       \       \       \
v2.2:          *-------*-------*-------[Bug fix] (cherry-picked)---*---*---*---*
```

**Visual Note:**
- Before: `v2.0` has 4 commits, `v2.1` has 5 commits, `v2.2` has 7 commits
- After: `v2.0` has 4 commits, `v2.1` has 6 commits (+1), `v2.2` has 8 commits (+1)
- Both `v2.1` and `v2.2` now have more commits, maintaining the cumulative hierarchy
- `v2.2` still has the most commits overall

**Example:** Fixing a critical bug in the ANTLR grammar that affects all versions.

**Action:** Add labels `backport-to-v2.1` and `backport-to-v2.2` before merging the PR to `v2.0`.

#### Scenario 4: Multiple Commits with Different Propagation Rules

Real-world scenario with multiple commits showing cumulative nature:

```
develop:  *---*---*---*---*---*---*---*---*
           \       \       \       \       \
v2.0:      *-------*-------*---[Fix A]---[Fix B]
             \       \       \       \
v2.1:        *-------*-------*-------[Fix A]---[v2.1 only]---[v2.1 feat]
               \       \       \       \
v2.2:          *-------*-------*-------[Fix A]---[v2.2 feat A]---[v2.2 feat B]---[v2.2 feat C]
```

**Commit Count:**
- `v2.0`: 5 commits total
- `v2.1`: 7 commits total (5 from v2.0 propagated + 2 new)
- `v2.2`: 10 commits total (7 from v2.1 propagated + 3 new)

**Legend:**
- `[Fix A]` - Propagated from v2.0 → v2.1 → v2.2 (bug fix, all versions have it)
- `[Fix B]` - Stayed on v2.0 only (v2.0-specific change, not in v2.1 or v2.2)
- `[v2.1 only]` - Stayed on v2.1 only (v2.1-specific feature, not in v2.2)
- `[v2.1 feat]` - New feature in v2.1, propagated to v2.2
- `[v2.2 feat A/B/C]` - New features in v2.2 only

**Key Insight:** Each version has progressively more commits, but some commits from earlier versions are excluded if they were not propagated.

### Propagation Rules Summary

| Source Branch | Can Propagate To | Direction |
|--------------|------------------|-----------|
| `v2.0`       | `v2.1`, `v2.2`   | Forward only |
| `v2.1`       | `v2.2`           | Forward only |
| `v2.2`       | None (latest)    | N/A |

**Key Principle:** Commits only propagate forward to newer versions, never backward to older versions.

## Branch Strategy

### Recommended Structure: Develop as Primary Branch

**Structure:**
```
develop:        Primary development branch (renamed from main)
v2.0:           Stable release branch (direct PRs for fixes)
v2.1:           Stable release branch (direct PRs for fixes)
v2.2:           Latest release branch (merged from develop)
```

**Rationale:**
- Latest version (v2.2) receives most development work
- `develop` serves as integration branch for latest version features
- Older versions (v2.0, v2.1) are stable and receive direct PRs for fixes only
- No need for `main` branch when `develop` handles all development

**Workflow:**

**For Latest Version (v2.2):**
1. Create feature branch from `develop`
2. Make changes
3. Create PR targeting `develop`
4. Review and merge to `develop`
5. Periodically create PR from `develop` → `v2.2` when features are ready
6. Add backport labels on `develop` PRs if fixes should go to v2.1 or v2.0

**For Older Versions (v2.0, v2.1):**
1. Create feature branch from version branch (e.g., `v2.1`)
2. Make changes
3. Create PR targeting version branch directly
4. Review and merge to version branch
5. Add backport labels if fix should propagate forward to v2.2

**Visual representation:**

```
Latest version development:
feature/new-op → develop → [integration] → PR → v2.2
                                    ↓
                              (backport labels)
                                    ↓
                              v2.1, v2.0

Older version fixes:
feature/fix-typo → v2.1 → (backport label) → v2.2
```

### Renaming Main to Develop

**Steps to rename `main` to `develop`:**

1. **Rename branch locally:**
   ```bash
   git checkout main
   git branch -m main develop
   ```

2. **Push new branch and delete old:**
   ```bash
   git push origin develop
   git push origin --delete main
   ```

3. **Update default branch on GitHub:**
   - Navigate to repository Settings → Branches
   - Change default branch from `main` to `develop`
   - Confirm the change

4. **Update local tracking:**
   ```bash
   git fetch origin
   git branch -u origin/develop develop
   ```

5. **Update backport configuration:**
   - Modify `.github/backport.json` to use `develop` instead of `main`:
   ```json
   {
     "upstream": ["develop"],
     ...
   }
   ```

6. **Update any references:**
   - Update documentation references from `main` to `develop`
   - Update CI/CD workflows if they reference `main`
   - Update branch protection rules

### Backport Configuration

**Updated `.github/backport.json` for develop-based workflow:**

```json
{
  "upstream": ["develop"],
  "branches": [
    {
      "name": "v2.2",
      "labels": ["backport-to-v2.2"],
      "checked": true
    },
    {
      "name": "v2.1",
      "labels": ["backport-to-v2.1"],
      "checked": true
    },
    {
      "name": "v2.0",
      "labels": ["backport-to-v2.0"],
      "checked": true
    }
  ],
  "labels": {
    "backport-to-v2.2": "Backport to v2.2",
    "backport-to-v2.1": "Backport to v2.1",
    "backport-to-v2.0": "Backport to v2.0"
  }
}
```

This configuration allows:
- PRs merged to `develop` can be backported to `v2.2`, `v2.1`, or `v2.0` using labels
- PRs merged to version branches can be backported forward using labels

### Workflow Examples

**Example 1: New feature for latest version**

```
1. Create feature branch from develop
   git checkout develop
   git checkout -b feature/new-operator

2. Make changes and commit
   git add .
   git commit -m "Add new operator"

3. Create PR targeting develop
   PR: feature/new-operator → develop
   Title: "Add new operator"

4. Review and merge to develop
   Merged to develop

5. When ready, create PR from develop → v2.2
   PR: develop → v2.2
   Title: "Release v2.2: New features"

6. Review and merge to v2.2
   Merged to v2.2
```

**Example 2: Fix in develop that should backport**

```
1. Create PR: feature/fix-bug → develop
2. Add labels: backport-to-v2.1, backport-to-v2.0
3. Merge to develop
4. Workflow automatically creates:
   - PR: backport → v2.1
   - PR: backport → v2.0
5. Review and merge backport PRs
```

**Example 3: Fix in older version**

```
1. Create PR: feature/fix-typo → v2.1
2. Add label: backport-to-v2.2
3. Merge to v2.1
4. Workflow automatically creates:
   - PR: backport → v2.2
5. Review and merge backport PR
```

### Merge Cadence: Develop → v2.2

Establish a regular cadence for merging `develop` to `v2.2`:

**Options:**
- **Time-based**: Weekly, bi-weekly, or monthly
- **Feature-based**: When a set of features is complete
- **Milestone-based**: When a milestone is reached

**Process:**
1. Review commits in `develop` since last merge to `v2.2`
2. Ensure all features are tested and ready
3. Create PR: `develop` → `v2.2`
4. Review the PR (shows all commits to be merged)
5. Merge to `v2.2`
6. Tag the release if needed

**Visual example:**

```
develop:  *---*---*---*---*---*---*---*---*
           \       \       \       \
v2.2:      *-------*-------*-------*---[PR: develop → v2.2]
```

### Branch Protection

Consider setting up branch protection rules:

**For `develop` branch:**
- Require PR reviews before merging
- Require status checks to pass
- Require branches to be up to date

**For version branches (`v2.0`, `v2.1`, `v2.2`):**
- Require PR reviews before merging
- Require status checks to pass
- Prevent direct pushes (all changes via PR)


## Solution Approaches

### Approach 1: Label-Based Backporting (Recommended)

GitHub labels trigger automatic backporting when PRs are merged.

**How it works:**
1. Developers merge a PR to `develop` (for latest version) or to a version branch (for older versions)
2. If the change should propagate, add appropriate backport labels (e.g., `backport-to-v2.2`, `backport-to-v2.1`)
3. GitHub Action automatically creates PRs to target branches with the changes
4. PRs can be reviewed and merged independently

**Tools:**
- **[backport-action](https://github.com/korthout/backport-action)** (Recommended)
  - Fast and flexible
  - Supports multiple target branches
  - Creates PRs automatically
  - Well-maintained

- **[backport](https://github.com/tibdex/backport)** (Alternative)
  - JavaScript-based
  - Supports rebased and squashed merges
  - Multiple labels support

### Approach 2: PR Title/Description Convention

Naming conventions in PR titles trigger propagation.

**How it works:**
1. Developers include propagation instructions in PR title/description
2. Format: `[propagate:v2.2,v2.3]` or `[backport:v2.2]`
3. GitHub Action parses the PR and creates backport PRs automatically

**Advantages:**
- Explicit intent in PR description
- No need for labels
- Works well with conventional commits

**Disadvantages:**
- Requires discipline in PR naming
- Less flexible than labels

### Approach 3: Automatic Detection with Rules

Automatically detect changes that should propagate based on file patterns or commit messages.

**How it works:**
1. Define rules (e.g., changes to `docs/` always propagate forward)
2. GitHub Action analyzes merged PRs
3. Automatically creates backport PRs based on rules

**Advantages:**
- Fully automated
- No manual intervention needed
- Consistent propagation

**Disadvantages:**
- May propagate changes that should not be propagated
- Requires careful rule definition

## Recommended Implementation: Label-Based Backporting

### Setup with `backport-action`

#### Step 1: Create Backport Configuration

Create `.github/backport.json`:

```json
{
  "upstream": ["develop"],
  "branches": [
    {
      "name": "v2.2",
      "labels": ["backport-to-v2.2"],
      "checked": true
    },
    {
      "name": "v2.1",
      "labels": ["backport-to-v2.1"],
      "checked": true
    },
    {
      "name": "v2.0",
      "labels": ["backport-to-v2.0"],
      "checked": true
    }
  ],
  "labels": {
    "backport-to-v2.2": "Backport to v2.2",
    "backport-to-v2.1": "Backport to v2.1",
    "backport-to-v2.0": "Backport to v2.0"
  }
}
```

The `upstream` field specifies which branches can trigger backports. With `develop` as the primary branch, it is included as the upstream source.

#### Step 2: Create GitHub Actions Workflow

Create `.github/workflows/backport.yml`:

```yaml
name: Backport

on:
  pull_request:
    types: [closed]

jobs:
  backport:
    runs-on: ubuntu-latest
    if: github.event.pull_request.merged == true
    steps:
      - name: Backport
        uses: korthout/backport-action@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          backport_config_file: .github/backport.json
```

#### Step 3: Create GitHub Labels

Create labels in the repository:
- `backport-to-v2.2` (color: `#0E8A16`)
- `backport-to-v2.1` (color: `#0E8A16`)
- `backport-to-v2.0` (color: `#0E8A16`)

These can be created via GitHub UI or using the GitHub CLI:

```bash
gh label create "backport-to-v2.2" --description "Backport to v2.2" --color "0E8A16"
gh label create "backport-to-v2.1" --description "Backport to v2.1" --color "0E8A16"
gh label create "backport-to-v2.0" --description "Backport to v2.0" --color "0E8A16"
```

### Usage Workflow

#### Step-by-Step Guide

**1. Create Pull Request**
- **For latest version (v2.2)**: Create PR targeting `develop` branch
  - Example: New feature for v2.2 → PR targeting `develop`
  - Example: Fix for v2.2 → PR targeting `develop`
- **For older versions (v2.0, v2.1)**: Create PR targeting the version branch directly
  - Example: If fixing a bug in v2.1, create PR targeting `v2.1` branch
  - Example: If fixing a bug in v2.0, create PR targeting `v2.0` branch
- **Source branch**: Feature or fix branch (e.g., `fix/typo-in-docs`)

**2. Add Backport Labels (Before Merging)**
- In the GitHub PR UI, add labels to indicate where the change should propagate:
  - `backport-to-v2.2`: If the fix should also go to v2.2
  - `backport-to-v2.1`: If the fix should also go to v2.1
  - `backport-to-v2.0`: If the fix should also go to v2.0
- Multiple labels can be added if the fix should propagate to multiple versions
- **Important**: Labels must be added before merging the PR

**3. Review and Merge**
- Review the PR as normal
- Merge the PR to the target branch (`develop` for latest version, or version branch for older versions)

**4. Automatic Backport PRs Creation**
- After merge, the GitHub Action automatically:
  - Detects the labels on the merged PR
  - Creates new PRs to the target branches specified by labels
  - Cherry-picks the commits from the merged PR
  - Opens the backport PRs for review

**5. Review and Merge Backport PRs**
- Review each backport PR independently
- Merge them when ready
- Each backport PR can be reviewed and merged separately

#### Visual Example

```
Developer workflow:

1. Create PR: fix/typo → v2.1
   ┌─────────────────────┐
   │ PR #123: Fix typo   │
   │ base: v2.1          │
   │ labels: (none yet)  │
   └─────────────────────┘

2. Add label: backport-to-v2.2
   ┌─────────────────────┐
   │ PR #123: Fix typo   │
   │ base: v2.1          │
   │ labels: backport-   │
   │         to-v2.2     │
   └─────────────────────┘

3. Merge PR #123 to v2.1
   Merged

4. GitHub Action automatically creates:
   ┌─────────────────────────────┐
   │ PR #124: backport: Fix typo │
   │ base: v2.2                  │
   │ (auto-created by workflow)  │
   └─────────────────────────────┘

5. Review and merge PR #124
   Backport complete
```

#### Common Scenarios

**Scenario A: New feature for latest version (v2.2)**
- Create PR targeting `develop`
- Merge PR to `develop`
- When ready, create PR from `develop` → `v2.2`
- Merge PR to `v2.2`

**Scenario B: Fix in develop that should backport to older versions**
- Create PR targeting `develop`
- Add labels `backport-to-v2.1` AND `backport-to-v2.0` (if needed)
- Merge PR to `develop`
- Workflow creates backport PRs to `v2.1` and `v2.0`
- Later, when merging `develop` → `v2.2`, the fix will be included

**Scenario C: Fix in v2.1 that should go to v2.2**
- Create PR targeting `v2.1`
- Add label `backport-to-v2.2`
- Merge PR to `v2.1`
- Workflow creates PR to `v2.2`

**Scenario D: Fix in v2.1 that should stay only in v2.1**
- Create PR targeting `v2.1`
- Do not add any backport labels
- Merge PR to `v2.1`
- No backport PRs created

### Quick Reference: How to Use Labels

**In GitHub PR UI:**
1. Open the PR
2. Click on the "Labels" section (right sidebar)
3. Type or select: `backport-to-v2.2`, `backport-to-v2.1`, or `backport-to-v2.0`
4. Labels appear as colored badges on the PR
5. **Important**: Add labels before merging the PR

**Example PR with labels:**
```
┌─────────────────────────────────────────┐
│ PR #123: Fix typo in documentation     │
│                                         │
│ base: v2.1 ← target branch             │
│                                         │
│ Labels:                                 │
│   backport-to-v2.2                     │
│                                         │
│ [Ready to merge]                        │
└─────────────────────────────────────────┘
```

### Example Scenario

**Scenario:** Fix a typo in `v2.1` documentation that also exists in `v2.2`

**Visual Flow:**

```
Step 1: Developer creates PR to v2.1
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \       \
v2.1:        *-------*-------*-------*---*---*---[PR: Fix typo] (open)
               \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*---*
                                                      ↑
                                            v2.2 already has more commits

Step 2: Add label "backport-to-v2.2" and merge PR
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \       \
v2.1:        *-------*-------*-------*---*---*---[Fix typo] (merged)
               \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*---*
                                                      ↑
                                            v2.2 still has more commits

Step 3: Workflow automatically creates backport PR
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \       \
v2.1:        *-------*-------*-------*---*---*---[Fix typo]
               \       \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*---*---[PR: backport] (open)
                                                                          ↑
                                                            v2.2 now has even more commits

Step 4: Review and merge backport PR
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \       \
v2.1:        *-------*-------*-------*---*---*---[Fix typo]
               \       \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*---*---[Fix typo] (merged)
                                                                          ↑
                                                            v2.2 has the most commits,
                                                            including the propagated fix
```

**Steps:**
1. Create PR to `develop` branch fixing the typo
2. Add label `backport-to-v2.1` and `backport-to-v2.0` before merging (if typo exists in those versions)
3. Merge PR to `develop`
4. Workflow automatically creates backport PRs to `v2.1` and `v2.0`
5. Review and merge the backport PRs
6. When ready, create PR from `develop` → `v2.2` (includes the typo fix)
7. Merge PR to `v2.2`

## Alternative: Custom Workflow with PR Title Convention

For teams preferring PR title conventions over labels, a custom workflow can be implemented:

### Create `.github/workflows/propagate-changes.yml`:

```yaml
name: Propagate Changes

on:
  pull_request:
    types: [closed]

jobs:
  propagate:
    runs-on: ubuntu-latest
    if: github.event.pull_request.merged == true
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Parse PR title for propagation
        id: parse
        run: |
          PR_TITLE="${{ github.event.pull_request.title }}"
          SOURCE_BRANCH="${{ github.event.pull_request.base.ref }}"
          
          # Extract target branches from PR title
          # Format: [propagate:v2.2,v2.3] or [backport:v2.2]
          if [[ "$PR_TITLE" =~ \[propagate:([^\]]+)\] ]]; then
            TARGETS="${BASH_REMATCH[1]}"
            echo "targets=$TARGETS" >> $GITHUB_OUTPUT
            echo "should_propagate=true" >> $GITHUB_OUTPUT
          elif [[ "$PR_TITLE" =~ \[backport:([^\]]+)\] ]]; then
            TARGETS="${BASH_REMATCH[1]}"
            echo "targets=$TARGETS" >> $GITHUB_OUTPUT
            echo "should_propagate=true" >> $GITHUB_OUTPUT
          else
            echo "should_propagate=false" >> $GITHUB_OUTPUT
          fi

      - name: Propagate to target branches
        if: steps.parse.outputs.should_propagate == 'true'
        run: |
          TARGETS="${{ steps.parse.outputs.targets }}"
          SOURCE_BRANCH="${{ github.event.pull_request.base.ref }}"
          COMMIT_SHA="${{ github.event.pull_request.merge_commit_sha }}"
          
          IFS=',' read -ra BRANCHES <<< "$TARGETS"
          for BRANCH in "${BRANCHES[@]}"; do
            BRANCH=$(echo "$BRANCH" | xargs) # trim whitespace
            
            echo "Propagating to $BRANCH..."
            
            # Checkout target branch
            git checkout "$BRANCH"
            git pull origin "$BRANCH"
            
            # Cherry-pick commit
            if git cherry-pick "$COMMIT_SHA"; then
              # Push and create PR
              git push origin "$BRANCH"
              gh pr create \
                --base "$BRANCH" \
                --head "$BRANCH" \
                --title "Propagate: ${{ github.event.pull_request.title }}" \
                --body "Automatically propagated from $SOURCE_BRANCH"
            else
              echo "Cherry-pick failed for $BRANCH, manual intervention needed"
            fi
          done
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Usage with PR Title Convention

**PR Title Format:**
```
Fix typo in documentation [propagate:v2.2]
```

Or for multiple targets:
```
Update operator examples [propagate:v2.1,v2.2]
```

**Visual Example:**

```
PR Title: "Fix typo in docs [propagate:v2.2]"

Before merge:
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \       \
v2.1:        *-------*-------*-------*---*---*---[PR: Fix typo] (open)
               \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*---*
                                                      ↑
                                            v2.2 already has more commits

After merge (workflow detects [propagate:v2.2]):
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \       \
v2.1:        *-------*-------*-------*---*---*---[Fix typo] (merged)
               \       \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*---*---[PR: Propagate] (auto-created)
                                                                          ↑
                                                            v2.2 will have even more commits
                                                            after merging the backport PR
```

## Advanced: Rule-Based Automatic Propagation

For fully automatic propagation based on file patterns:

### Create `.github/workflows/auto-propagate.yml`:

```yaml
name: Auto Propagate Changes

on:
  pull_request:
    types: [closed]

jobs:
  auto-propagate:
    runs-on: ubuntu-latest
    if: github.event.pull_request.merged == true
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Determine propagation targets
        id: targets
        run: |
          SOURCE_BRANCH="${{ github.event.pull_request.base.ref }}"
          CHANGED_FILES="${{ github.event.pull_request.changed_files }}"
          
          # Rules: propagate based on source branch and file patterns
          TARGETS=""
          
          if [[ "$SOURCE_BRANCH" == "v2.0" ]]; then
            # Changes in v2.0 should propagate to v2.1 and v2.2
            TARGETS="v2.1,v2.2"
          elif [[ "$SOURCE_BRANCH" == "v2.1" ]]; then
            # Changes in v2.1 should propagate to v2.2
            TARGETS="v2.2"
          fi
          
          # Check if changed files match propagation rules
          # Example: always propagate docs/ changes forward
          if echo "$CHANGED_FILES" | grep -q "^docs/"; then
            echo "targets=$TARGETS" >> $GITHUB_OUTPUT
            echo "should_propagate=true" >> $GITHUB_OUTPUT
          else
            echo "should_propagate=false" >> $GITHUB_OUTPUT
          fi

      - name: Propagate changes
        if: steps.targets.outputs.should_propagate == 'true'
        uses: korthout/backport-action@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          # Configure based on targets
```

## Best Practices

### 1. Propagation Strategy

**Forward-only propagation:**
- Fixes in `v2.0` propagate to `v2.1` and `v2.2`
- Fixes in `v2.1` propagate to `v2.2`
- Fixes in `v2.2` do not propagate (latest version)

**Visual representation:**

```
v2.0 fixes propagate forward:
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*---[Fix]---*
             \       \       \       \       \
v2.1:        *-------*-------*-------*---*---*---*---[Fix] (propagated)
               \       \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*---*---[Fix] (propagated)
                                                                        ↑
                                                          v2.2 has the most commits,
                                                          including the propagated fix

v2.1 fixes propagate forward:
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \       \
v2.1:        *-------*-------*-------*---*---*---*---[Fix]---*
               \       \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*---*---*---[Fix] (propagated)
                                                                              ↑
                                                            v2.2 accumulates more commits,
                                                            including the propagated fix

v2.2 fixes stay local:
develop:  *---*---*---*---*---*---*
           \       \       \       \
v2.0:      *-------*-------*-------*
             \       \       \       \
v2.1:        *-------*-------*-------*---*---*---*
               \       \       \       \
v2.2:          *-------*-------*-------*---*---*---*---*---*---*---[Fix]---* (no propagation)
                                                                                  ↑
                                                            v2.2 has the most commits,
                                                            this fix stays only in v2.2
```

**Selective propagation:**
- Not all changes should propagate
- Use labels or explicit instructions
- Review each backport PR independently

### 2. Conflict Resolution

When cherry-picking causes conflicts:
- Backport PR will show conflict status
- Manual resolution required
- Consider if the change is still relevant to target version

### 3. Documentation Changes

**Documentation propagation rules:**
- Typo fixes: always propagate forward
- New features: only propagate if feature exists in target version
- API changes: version-specific, usually do not propagate

### 4. Code Changes

**Code propagation rules:**
- Bug fixes: usually propagate forward
- New features: version-specific, do not propagate
- Breaking changes: version-specific, do not propagate

## Monitoring and Tracking

### GitHub Issues Integration

Create issues for tracking propagation:
- Label: `needs-propagation`
- Automatically close when backport PRs are merged

### Dashboard

Track propagation status:
- Which PRs have been propagated
- Which PRs need manual propagation
- Propagation success rate

## Frequently Asked Questions

### Q: Where should pull requests be created?

**A:** Pull requests should target branches based on the version:
- **For latest version (v2.2)**: PR targeting `develop`
  - New features, improvements, fixes for v2.2
- **For older versions (v2.0, v2.1)**: PR targeting the version branch directly
  - Fixing something in v2.1: PR targeting `v2.1`
  - Fixing something in v2.0: PR targeting `v2.0`

The PR base branch determines where the change will be applied first. Changes in `develop` are later merged to `v2.2` via PR.

### Q: How are labels added in GitHub UI?

**A:** 
1. Open the PR page on GitHub
2. Locate the "Labels" section in the right sidebar
3. Click on the gear icon or "Labels" button
4. Type `backport-to-v2.2` (or other label name)
5. Select it from the dropdown
6. The label will appear as a colored badge on the PR

**Visual guide:**
```
GitHub PR Page:
┌─────────────────────────────────────┐
│ PR Title                            │
│                                     │
│ [Content of PR]                     │
│                                     │
│ ┌─────────────────────────────┐   │
│ │ Labels                      │   │
│ │ [backport-to-v2.2]          │   │
│ │ [+ Add labels] ← Click here │   │
│ └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Q: When should labels be added?

**A:** Labels must be added before merging the PR. The GitHub Action only processes labels that exist at the time of merge.

**Best practice:** Add labels during PR review, so reviewers can see which versions will receive the change.

### Q: What happens if labels are forgotten before merging?

**A:** The backport will not happen automatically. Options:
- Manually cherry-pick the commit to target branches, OR
- Revert the merge, add labels, and merge again (not recommended), OR
- Manually create backport PRs

**Tip:** Set up branch protection rules to require labels before merging.

### Q: Can multiple labels be added?

**A:** Yes. If a fix in v2.0 should go to both v2.1 and v2.2:
- Add both `backport-to-v2.1` AND `backport-to-v2.2`
- The workflow will create 2 separate PRs (one for each target branch)

### Q: What if a change should not propagate?

**A:** Simply do not add any backport labels. The change will stay only in the branch where the PR was merged.

### Q: Can changes propagate backward from newer to older versions?

**A:** No. Propagation only works forward (to newer versions):
- `develop` → v2.2, v2.1, v2.0 (supported via labels)
- v2.0 → v2.1, v2.2 (supported)
- v2.1 → v2.2 (supported)
- v2.2 → nowhere (it is the latest) (supported)
- v2.2 → v2.1 (backward propagation not supported)
- v2.1 → v2.0 (backward propagation not supported)

### Q: Who can add labels?

**A:** Anyone with write access to the repository can add labels. Typically:
- PR author
- Repository maintainers
- Collaborators with write access

### Q: What if the backport PR has conflicts?

**A:** The backport PR will show a conflict status. Steps to resolve:
1. Checkout the backport PR branch locally
2. Resolve conflicts manually
3. Push the resolution
4. Merge the backport PR

The workflow does not automatically resolve conflicts.

## Troubleshooting

### Backport PR Creation Fails

**Common causes:**
- Target branch does not exist
- Insufficient permissions
- Merge conflicts

**Solutions:**
- Verify branch names in configuration
- Check GitHub token permissions
- Resolve conflicts manually

### Wrong Commits Propagated

**Cause:** Squash merges create new commit SHAs

**Solution:** Use merge commits instead of squash merges, or configure backport tool to handle squash merges

## Migration Plan

### Phase 1: Setup (Week 1)
1. Choose approach (recommended: label-based)
2. Install backport-action
3. Create labels
4. Test with a sample PR

### Phase 2: Documentation (Week 1)
1. Document workflow for team
2. Create PR template with propagation instructions
3. Add examples to CONTRIBUTING.md

### Phase 3: Rollout (Week 2)
1. Enable workflow for all version branches
2. Train team on label usage
3. Monitor first few propagations

### Phase 4: Optimization (Ongoing)
1. Refine rules based on experience
2. Add custom rules if needed
3. Improve conflict resolution process

## References

- [backport-action Documentation](https://github.com/korthout/backport-action)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Cherry-picking Guide](https://git-scm.com/docs/git-cherry-pick)

## Support

For questions or issues with version propagation:
1. Check this documentation
2. Review workflow logs in GitHub Actions
3. Open an issue with `version-management` label
