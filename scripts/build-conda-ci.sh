#!/bin/bash
################################################################################
# Conda Package CI Build Script
#
# Purpose: Builds conda package with workarounds for conda-build limitations
#          Used in both local development and CI/CD pipeline.
#
# Features:
# - Handles conda-build output directory issues
# - Provides robust error handling and cleanup
# - Creates proper directory structure for artifacts
# - Validates successful package creation
#
# Usage: ./scripts/build-conda-ci.sh
#
# Output: dist-conda/noarch/cvannotate-*.conda
################################################################################

# Build conda package and copy to dist-conda directory
# This script works around issues with conda-build --output-folder

set -e

echo "🏗️  Building conda package..."

# Clean up any previous builds
rm -rf /opt/conda/conda-bld/*cvannotate*

# Create output directory
mkdir -p dist-conda/noarch

# Build the package normally (this works reliably)
conda-build conda-recipe/ --no-anaconda-upload || {
    echo "❌ conda-build failed"
    exit 1
}

# Find and copy the built package
CONDA_PKG=$(find /opt/conda/conda-bld -name "*cvannotate*.conda" | head -1)
TAR_PKG=$(find /opt/conda/conda-bld -name "*cvannotate*.tar.bz2" | head -1)

if [[ -n "$CONDA_PKG" ]]; then
    echo "✅ Found conda package: $CONDA_PKG"
    cp "$CONDA_PKG" dist-conda/noarch/
else
    echo "❌ No conda package found"
    exit 1
fi

if [[ -n "$TAR_PKG" ]]; then
    echo "✅ Found tar.bz2 package: $TAR_PKG"
    cp "$TAR_PKG" dist-conda/noarch/
fi

echo "📦 Built packages:"
ls -la dist-conda/noarch/

echo "✅ Conda package build completed successfully!"
