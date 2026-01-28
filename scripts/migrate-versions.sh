#!/bin/bash

# Migration script for versions from vtl to Language-management-POC
# Usage: ./scripts/migrate-versions.sh /path/to/vtl

set -e

SOURCE_DIR="${1:-../vtl}"
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

echo "Migrating from $SOURCE_DIR to current directory..."

# Versions to migrate
VERSIONS=("2.0" "2.1" "2.2")

# For each version
for VERSION in "${VERSIONS[@]}"; do
    VERSION_DIR="$SOURCE_DIR/v$VERSION"
    
    if [ ! -d "$VERSION_DIR" ]; then
        echo "Warning: Version $VERSION directory not found, skipping..."
        continue
    fi
    
    echo ""
    echo "========================================="
    echo "Processing version $VERSION..."
    echo "========================================="
    
    # Create branch from main
    BRANCH_NAME="v$VERSION"
    echo "Creating branch $BRANCH_NAME..."
    git checkout main
    git checkout -b "$BRANCH_NAME" 2>/dev/null || {
        echo "Branch $BRANCH_NAME already exists, checking it out..."
        git checkout "$BRANCH_NAME"
        # Clean existing branch
        git rm -rf . 2>/dev/null || true
    }
    
    # Copy source content (ANTLR grammar)
    if [ -d "$VERSION_DIR/src" ]; then
        echo "  Copying src/..."
        mkdir -p src
        cp -r "$VERSION_DIR/src"/* src/
    fi
    
    # Copy documentation
    if [ -d "$VERSION_DIR/docs" ]; then
        echo "  Copying docs/..."
        mkdir -p docs
        cp -r "$VERSION_DIR/docs"/* docs/ 2>/dev/null || true
        # Copy hidden files if necessary
        cp -r "$VERSION_DIR/docs"/.[!.]* docs/ 2>/dev/null || true
    fi
    
    # Copy pom.xml if exists
    if [ -f "$VERSION_DIR/pom.xml" ]; then
        echo "  Copying pom.xml..."
        cp "$VERSION_DIR/pom.xml" pom.xml
    fi
    
    # Copy README.md if exists
    if [ -f "$VERSION_DIR/README.md" ]; then
        echo "  Copying README.md..."
        cp "$VERSION_DIR/README.md" README.md
    fi
    
    # Create commit
    git add -A
    git commit -m "[v$VERSION] Initial migration from vtl project" || echo "  No changes to commit"
    
    echo "  Version $VERSION migrated successfully"
done

# Return to main
git checkout main

echo ""
echo "========================================="
echo "Migration completed!"
echo "========================================="
echo ""
echo "Branches created:"
git branch | grep -E "v2\." || git branch
echo ""
echo "Next steps:"
echo "1. Review the branches: git branch"
echo "2. Push branches to remote: git push -u origin --all"
echo "3. Verify main is the default branch"

