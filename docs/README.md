# Documentation Sphinx Multi-version

Ce dossier contient la configuration pour générer la documentation Sphinx multi-version de VTL.

## Structure

```
docs/
├── conf.py              # Configuration Sphinx avec sphinx-multiversion
├── index.rst           # Page d'accueil de la documentation
├── requirements.txt    # Dépendances Python
├── Makefile            # Commandes pour builder la doc
├── _static/            # Fichiers statiques (CSS, JS)
│   └── version-selector.js  # Sélecteur de version
└── _templates/         # Templates Sphinx (optionnel)
```

## Installation

```bash
pip install -r requirements.txt
```

## Build

### Build toutes les versions (recommandé)

```bash
make html-multiversion
```

Cela va :
- Détecter automatiquement toutes les branches `v2.1`, `v2.2`
- Builder la documentation de chaque version
- Créer un dossier pour chaque version dans `_build/html/`

### Build une seule version

```bash
make html
```

## Test local

Après avoir buildé la documentation :

```bash
make serve
```

Puis ouvrir http://localhost:8000 dans votre navigateur.

## Versions supportées

- **v2.2** : Documentation complète (User Manual + Reference Manual)
- **v2.1** : Documentation complète (User Manual + Reference Manual)
- **v2.0** : Pas de documentation Sphinx (uniquement grammaire ANTLR)

## Configuration

La configuration principale se trouve dans `conf.py` :
- `smv_branch_whitelist` : Pattern pour sélectionner les branches
- `smv_latest_version` : Version considérée comme la plus récente
- `smv_rename_latest_version` : Nom donné à la version latest

## Déploiement

Le déploiement se fait automatiquement via GitHub Actions (voir `.github/workflows/deploy-docs.yml`).

Pour déployer manuellement, voir `../DEPLOY_GITHUB_PAGES.md`.

