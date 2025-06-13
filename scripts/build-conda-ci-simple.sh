#!/bin/bash
################################################################################
# Simple Conda Package CI Build Script - Cross Platform Version
#
# Purpose: Builds conda package with cross-platform path detection
#          Specifically designed to work on GitHub Actions across all OS
#
# Usage: ./scripts/build-conda-ci-simple.sh
#
# Output: dist-conda/noarch/cvannotate-*.conda
################################################################################

set -e

echo "🏗️  Building conda package (cross-platform)..."

# Create output directory
mkdir -p dist-conda/noarch

echo "🔍 Conda environment info:"
echo "Conda base: $(conda info --base)"
echo "Current environment: $(conda info --envs | grep '\*' || echo 'No active environment detected')"
echo "PATH: $PATH"
echo "CONDA_PREFIX: ${CONDA_PREFIX:-'Not set'}"

echo "📋 Getting expected output location..."
EXPECTED_OUTPUT=$(conda-build conda-recipe/ --output 2>/dev/null || echo "")
echo "📦 Expected package location: ${EXPECTED_OUTPUT:-'(could not determine)'}"

echo "🔨 Building conda package..."
conda-build conda-recipe/ --no-anaconda-upload

echo "🔍 Searching for built package..."

# Method 1: Use the expected output if available
if [[ -n "$EXPECTED_OUTPUT" && -f "$EXPECTED_OUTPUT" ]]; then
    echo "✅ Found package at expected location: $EXPECTED_OUTPUT"
    cp "$EXPECTED_OUTPUT" dist-conda/noarch/
    echo "📦 Package copied successfully!"
    ls -la dist-conda/noarch/
    exit 0
fi

# Method 2: Search in conda-build output locations
echo "🔍 Searching in conda build directories..."

# Get conda base and search common locations
CONDA_BASE=$(conda info --base)
SEARCH_LOCATIONS=(
    "$CONDA_BASE/conda-bld"
    "$CONDA_BASE/envs/*/conda-bld"
    "$HOME/miniconda3/conda-bld"
    "$HOME/miniconda3/envs/*/conda-bld"
    "/Users/runner/miniconda3/envs/*/conda-bld"
    "/Users/runner/miniconda3/envs/test/conda-bld"  # Specific path from error
    "/opt/conda/conda-bld"
    "${CONDA_PREFIX}/conda-bld"  # Current environment path
)

echo "🔍 Will search in these locations:"
for loc in "${SEARCH_LOCATIONS[@]}"; do
    echo "  - $loc"
done

FOUND_PACKAGE=""

for location_pattern in "${SEARCH_LOCATIONS[@]}"; do
    # Handle glob patterns by expanding them
    if [[ "$location_pattern" == *"*"* ]]; then
        # Use bash globbing for patterns with wildcards
        for actual_location in $location_pattern; do
            if [[ -d "$actual_location" ]]; then
                echo "🔍 Checking: $actual_location"
                PACKAGE=$(find "$actual_location" -name "*cvannotate*.conda" 2>/dev/null | head -1)
                if [[ -n "$PACKAGE" ]]; then
                    echo "✅ Found package: $PACKAGE"
                    FOUND_PACKAGE="$PACKAGE"
                    break 2
                fi
            fi
        done
    else
        # Direct path check
        if [[ -d "$location_pattern" ]]; then
            echo "🔍 Checking: $location_pattern"
            PACKAGE=$(find "$location_pattern" -name "*cvannotate*.conda" 2>/dev/null | head -1)
            if [[ -n "$PACKAGE" ]]; then
                echo "✅ Found package: $PACKAGE"
                FOUND_PACKAGE="$PACKAGE"
                break
            fi
        fi
    fi
done

if [[ -n "$FOUND_PACKAGE" ]]; then
    cp "$FOUND_PACKAGE" dist-conda/noarch/
    echo "📦 Package copied successfully!"
    ls -la dist-conda/noarch/
else
    echo "❌ Could not find conda package"
    echo "🔍 Performing final search..."
    find / -name "*cvannotate*.conda" 2>/dev/null | head -10 || echo "No packages found"
    exit 1
fi

echo "✅ Conda package build completed successfully!"
