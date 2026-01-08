import os
import re
from pathlib import Path
from subprocess import check_output

from jinja2 import Environment, FileSystemLoader

# ============================================================================
# Configuration sphinx-multiversion
# ============================================================================
smv_tag_whitelist = r'^v\d+\.\d+$'  # Tags v2.0, v2.1, etc.
smv_branch_whitelist = r'^v2\.[12]$'  # Branches v2.1 et v2.2 uniquement (exclut v2.0 qui n'a pas de docs)
smv_remote_whitelist = r'^origin$'
smv_latest_version = 'v2.2'  # Version la plus récente
smv_rename_latest_version = 'latest'  # Renomme v2.2 en "latest" dans la doc
smv_outputdir_format = '{ref.name}'  # Format du dossier de sortie

# ============================================================================
# Project information
# ============================================================================
project = u'VTL Documentation'
copyright = u'SDMX Technical Working Group'
author = u'SDMX-TWG'

# Extraire la version depuis la branche Git actuelle
def get_version():
    try:
        branch = check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD']).decode('utf-8').strip()
        match = re.match(r'v?(\d+\.\d+)', branch)
        if match:
            return match.group(1)
        return "2.2"  # Version par défaut
    except:
        return "2.2"

VERSION = get_version()
release = VERSION
version = VERSION

# ============================================================================
# Extensions
# ============================================================================
extensions = [
    "sphinxcontrib.mermaid",
    "sphinxcontrib.plantuml",
    "sphinx_toolbox.collapse",
    "sphinx_multiversion",  # Extension clé pour multi-version
]

# ============================================================================
# Paths
# ============================================================================
templates_path = ['_templates']
exclude_patterns = [
    "*intro.rst",
    "pandocTranslation*",
    "_build",
    "Thumbs.db",
    ".DS_Store"
]

html_static_path = ['_static']

# ============================================================================
# HTML theme
# ============================================================================
html_theme = "sphinx_rtd_theme"
html_theme_options = {
    "navigation_depth": 5,
    "collapse_navigation": False,
}

# Détecter le repository GitHub depuis l'environnement ou utiliser des valeurs par défaut
github_user = os.getenv("GITHUB_REPOSITORY_OWNER", "votre-username")
github_repo = os.getenv("GITHUB_REPOSITORY", "Language-management-POC")
if "/" in github_repo:
    github_user, github_repo = github_repo.split("/", 1)

html_context = {
    "display_github": True,
    "github_user": github_user,
    "github_repo": github_repo,
    "github_version": VERSION if 'VERSION' in locals() else "v2.2",
    "conf_py_path": "/docs/",
}

# ============================================================================
# PDF configuration (optionnel)
# ============================================================================
pdf_documents = [
    ("index", f"VTL_{VERSION}_DOCS", f"VTL {VERSION} DOCS", "SDMX-TWG"),
]

# ============================================================================
# PlantUML configuration
# ============================================================================
plantuml = "java -jar " + os.getenv("PUML_PATH", "/tmp/plantuml.jar")
plantuml_output_format = 'svg'

# ============================================================================
# Templates Jinja2 (si vous utilisez des templates)
# ============================================================================
def name_norm(value):
    return re.sub("[^a-zA-Z0-9]", "", value)

# Charger les templates si le dossier existe
template_dir = Path("templates")
if template_dir.exists():
    jinjaEnv = Environment(loader=FileSystemLoader(searchpath="templates"))
    jinjaEnv.filters["name_norm"] = name_norm
    templates = {}
    for template in template_dir.glob("*"):
        if template.is_file():
            templates[template.name] = jinjaEnv.get_template(template.name)
else:
    templates = {}

# ============================================================================
# Apply templates in each op type folder (si la structure existe)
# ============================================================================
def apply_templates():
    operators_dir = Path("reference_manual/operators")
    if not operators_dir.exists():
        return
    
    for op_type in operators_dir.iterdir():
        if not op_type.is_dir():
            continue
        
        for op_folder in op_type.iterdir():
            if not op_folder.is_dir():
                continue
            
            examples_folder = op_folder / "examples"
            if not examples_folder.exists():
                continue
            
            # Collect datasets
            ds_list = sorted(
                x.stem for x in examples_folder.glob("ds_*.csv")
            )
            inputs = []
            for i, ds_name in enumerate(ds_list, 1):
                inputs.append({
                    "folder": examples_folder,
                    "i": i,
                    "name": ds_name
                })
            
            # Collect examples
            ex_list = sorted(
                x.stem for x in examples_folder.glob("ex_*.vtl")
            )
            examples = []
            for i, ex_name in enumerate(ex_list, 1):
                examples.append({
                    "folder": examples_folder,
                    "i": i,
                    "name": ex_name
                })
            
            # Render examples
            if "examples" in templates:
                examples_text = templates["examples"].render(
                    {
                        "examples": examples,
                        "inputs": inputs,
                        "op_type": op_type.name,
                        "repourl_ex": f"https://github.com/{github_user}/{github_repo}/blob/{VERSION}/docs/reference_manual/operators",
                    }
                )
                if (examples_folder / "end_text.rst").exists():
                    examples_text += """.. include:: examples/end_text.rst"""
                
                with open(op_folder / "examples.rst", "w") as f:
                    f.write(examples_text)

# Appliquer les templates si on est dans un build normal (pas multiversion)
if not os.getenv("SPHINX_MULTIVERSION_BUILD"):
    apply_templates()

# ============================================================================
# Setup function pour ajouter le sélecteur de version
# ============================================================================
def setup(app):
    app.add_js_file('version-selector.js')

