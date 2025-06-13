#!/bin/bash
# Automated conda recipe updater for PyPI releases
# Usage: ./update_recipe.sh [package_name] [version] [--test-pypi]

set -e

PACKAGE_NAME="${1:-cvannotate}"
VERSION="${2:-latest}"
USE_TEST_PYPI="${3}"

echo "🔍 Updating conda recipe for $PACKAGE_NAME..."

# Use Python script to update recipe
python3 scripts/update_conda_recipe.py "$PACKAGE_NAME" \
    ${VERSION:+--version "$VERSION"} \
    ${USE_TEST_PYPI:+--test-pypi} \
    --recipe-path conda-recipe/meta.yaml

echo "✅ Conda recipe updated!"
echo ""
echo "📦 To build the conda package:"
echo "   conda build conda-recipe --no-anaconda-upload"
echo ""
echo "🚀 To test the package:"
echo "   conda install /opt/conda/conda-bld/noarch/${PACKAGE_NAME}-*.conda"
