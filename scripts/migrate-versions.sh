#!/bin/bash

# Script de migration des versions depuis vtl vers Language-management-POC
# Usage: ./scripts/migrate-versions.sh /path/to/vtl

set -e

SOURCE_DIR="${1:-../vtl}"
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

echo "Migrating from $SOURCE_DIR to current directory..."

# Versions à migrer
VERSIONS=("2.0" "2.1" "2.2")

# Pour chaque version
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
    
    # Créer la branche depuis main
    BRANCH_NAME="v$VERSION"
    echo "Creating branch $BRANCH_NAME..."
    git checkout main
    git checkout -b "$BRANCH_NAME" 2>/dev/null || {
        echo "Branch $BRANCH_NAME already exists, checking it out..."
        git checkout "$BRANCH_NAME"
        # Nettoyer la branche existante
        git rm -rf . 2>/dev/null || true
    }
    
    # Copier le contenu source (grammaire ANTLR)
    if [ -d "$VERSION_DIR/src" ]; then
        echo "  Copying src/..."
        mkdir -p src
        cp -r "$VERSION_DIR/src"/* src/
    fi
    
    # Copier la documentation
    if [ -d "$VERSION_DIR/docs" ]; then
        echo "  Copying docs/..."
        mkdir -p docs
        cp -r "$VERSION_DIR/docs"/* docs/ 2>/dev/null || true
        # Copier les fichiers cachés si nécessaire
        cp -r "$VERSION_DIR/docs"/.[!.]* docs/ 2>/dev/null || true
    fi
    
    # Copier pom.xml si existe
    if [ -f "$VERSION_DIR/pom.xml" ]; then
        echo "  Copying pom.xml..."
        cp "$VERSION_DIR/pom.xml" pom.xml
    fi
    
    # Copier README.md si existe
    if [ -f "$VERSION_DIR/README.md" ]; then
        echo "  Copying README.md..."
        cp "$VERSION_DIR/README.md" README.md
    fi
    
    # Créer un commit
    git add -A
    git commit -m "[v$VERSION] Initial migration from vtl project" || echo "  No changes to commit"
    
    echo "  Version $VERSION migrated successfully"
done

# Créer la branche master basée sur v2.2
echo ""
echo "========================================="
echo "Creating master branch from v2.2..."
echo "========================================="
git checkout v2.2
git checkout -b master 2>/dev/null || {
    echo "Branch master already exists, checking it out..."
    git checkout master
    # Mettre à jour master avec v2.2
    git merge v2.2 --no-edit || true
}

# Retourner sur main
git checkout main

echo ""
echo "========================================="
echo "Migration completed!"
echo "========================================="
echo ""
echo "Branches created:"
git branch | grep -E "(v2\.|master)" || git branch
echo ""
echo "Next steps:"
echo "1. Review the branches: git branch"
echo "2. Push branches to remote: git push -u origin --all"
echo "3. Set master as default branch (if needed)"

