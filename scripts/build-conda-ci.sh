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

# Get the conda build directory (works on all platforms)
CONDA_BLD_PATH=$(conda info --base)/conda-bld
echo "📁 Using conda build path: $CONDA_BLD_PATH"

# Also check for alternative conda build paths (especially on macOS/Windows)
CONDA_ENV_PATH=$(conda info --envs | grep '\*' | awk '{print $3}')/conda-bld
MINICONDA_PATH="$HOME/miniconda3/conda-bld"
MINICONDA_ENV_PATH="$HOME/miniconda3/envs/test/conda-bld"

echo "🔍 Potential conda build paths:"
echo "  - $CONDA_BLD_PATH"
echo "  - $CONDA_ENV_PATH" 
echo "  - $MINICONDA_PATH"
echo "  - $MINICONDA_ENV_PATH"

# Define search paths array
SEARCH_PATHS=("$CONDA_BLD_PATH" "$CONDA_ENV_PATH" "$MINICONDA_PATH" "$MINICONDA_ENV_PATH")

# Clean up any previous builds
for cleanup_path in "${SEARCH_PATHS[@]}"; do
    if [[ -d "$cleanup_path" ]]; then
        echo "🧹 Cleaning up previous builds in: $cleanup_path"
        rm -rf "$cleanup_path"/*cvannotate* 2>/dev/null || true
    fi
done

# Create output directory
mkdir -p dist-conda/noarch

# Build the package normally (this works reliably)
echo "📋 Getting expected output location..."
EXPECTED_OUTPUT=$(conda-build conda-recipe/ --output 2>/dev/null | grep -E '\.(conda|tar\.bz2)$' | head -1)
echo "📦 Expected package location: ${EXPECTED_OUTPUT:-'(not detected)'}"

echo "🔍 Conda build environment info:"
echo "  Conda base: $(conda info --base)"
echo "  Current env: $(conda info --envs | grep '\*' | awk '{print $1}')"
echo "  Build root: $(conda config --show | grep bld_path || echo 'Not set')"

echo "🔨 Building conda package..."
conda-build conda-recipe/ --no-anaconda-upload || {
    echo "❌ conda-build failed"
    exit 1
}

# Find and copy the built package
echo "🔍 Searching for built packages..."

CONDA_PKG=""
TAR_PKG=""

# First check if the expected output exists
if [[ -n "$EXPECTED_OUTPUT" && -f "$EXPECTED_OUTPUT" ]]; then
    echo "✅ Found package at expected location: $EXPECTED_OUTPUT"
    CONDA_PKG="$EXPECTED_OUTPUT"
else
    echo "🔍 Expected location not found, searching in all potential directories..."
    
    for search_path in "${SEARCH_PATHS[@]}"; do
        if [[ -d "$search_path" ]]; then
            echo "🔍 Searching in: $search_path"
            ls -la "$search_path" 2>/dev/null || echo "  (empty or inaccessible)"
            
            # Look for conda package
            found_conda=$(find "$search_path" -name "*cvannotate*.conda" 2>/dev/null | head -1)
            if [[ -n "$found_conda" ]]; then
                CONDA_PKG="$found_conda"
                echo "✅ Found conda package: $CONDA_PKG"
                break
            fi
            
            # Look for tar.bz2 package
            found_tar=$(find "$search_path" -name "*cvannotate*.tar.bz2" 2>/dev/null | head -1)
            if [[ -n "$found_tar" ]]; then
                TAR_PKG="$found_tar"
                echo "✅ Found tar.bz2 package: $TAR_PKG"
            fi
        fi
    done
fi

if [[ -n "$CONDA_PKG" ]]; then
    echo "📦 Copying conda package to dist-conda/noarch/"
    cp "$CONDA_PKG" dist-conda/noarch/
else
    echo "❌ No conda package found in standard locations"
    echo "🔍 Performing comprehensive search for cvannotate packages..."
    
    # Search more broadly in home directory and common conda locations
    BROAD_SEARCH=$(find ~/ /opt /usr/local /Users -name "*cvannotate*.conda" 2>/dev/null | head -5)
    
    if [[ -n "$BROAD_SEARCH" ]]; then
        echo "🔍 Found packages in broader search:"
        echo "$BROAD_SEARCH"
        CONDA_PKG=$(echo "$BROAD_SEARCH" | head -1)
        echo "📦 Using: $CONDA_PKG"
        cp "$CONDA_PKG" dist-conda/noarch/
    else
        echo "❌ No conda package found anywhere"
        echo "🔍 Last resort - checking all conda envs:"
        conda info --envs
        exit 1
    fi
fi

if [[ -n "$TAR_PKG" ]]; then
    echo "✅ Found tar.bz2 package: $TAR_PKG"
    cp "$TAR_PKG" dist-conda/noarch/
fi

echo "📦 Built packages:"
ls -la dist-conda/noarch/

echo "✅ Conda package build completed successfully!"
