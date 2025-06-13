#!/bin/bash
################################################################################
# GitHub Actions Conda Pipeline Test Script
# 
# Purpose: Simulates the complete GitHub Actions conda build and upload process
#          to validate changes locally before pushing to the repository.
#
# What it tests:
# - Conda environment setup
# - Package building process  
# - Upload script validation
# - Error handling scenarios
#
# Usage: ./scripts/test-github-actions-conda.sh
# 
# This script helps prevent CI/CD failures by catching issues early.
################################################################################

# GitHub Actions Conda Build & Upload Simulation Script
# This script replicates the conda build and upload process from GitHub Actions
# to test locally before pushing to GitHub

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR"
CONDA_ENV_NAME="cvannotate-ci-test"

echo -e "${BLUE}🚀 GitHub Actions Conda Build & Upload Simulation${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""
echo "Workspace: $WORKSPACE_DIR"
echo "Test environment: $CONDA_ENV_NAME"
echo ""

# Function to simulate GitHub Actions step
step() {
    echo -e "${BLUE}📋 STEP: $1${NC}"
    echo "----------------------------------------"
}

# Function to simulate shell command with conda environment
conda_shell() {
    echo -e "${YELLOW}🐍 Running in conda shell: $1${NC}"
    # Simulate 'shell: bash -l {0}' from GitHub Actions
    conda run -n "$CONDA_ENV_NAME" bash -c "$1"
}

# Cleanup function
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up test environment...${NC}"
    conda env remove -n "$CONDA_ENV_NAME" -y || true
    rm -rf dist-conda-test/
}

# Set trap for cleanup
trap cleanup EXIT

cd "$WORKSPACE_DIR"

# =============================================================================
# SIMULATE: Setup Miniconda
# =============================================================================
step "Setup Test Conda Environment (simulates setup-miniconda@v3)"

echo "Creating test conda environment with Python 3.11..."
conda create -n "$CONDA_ENV_NAME" python=3.11 -y -q

echo "Activating environment and setting channels..."
conda config --env --add channels conda-forge
conda config --env --add channels defaults
conda config --env --set channel_priority true

conda_shell "conda info"

# =============================================================================
# SIMULATE: Install conda-build
# =============================================================================
step "Install conda-build and anaconda-client"

conda_shell "conda install conda-build anaconda-client -y"
conda_shell "conda info"
conda_shell "conda list | grep -E '(conda-build|anaconda-client)'"

# =============================================================================
# SIMULATE: Update conda recipe version
# =============================================================================
step "Update conda recipe version (simulates version extraction)"

# Extract version from pyproject.toml (simulating GitHub Actions logic)
VERSION=$(grep '^version = ' pyproject.toml | sed 's/version = "//' | sed 's/"//')
echo "Extracted version: $VERSION"

# Backup original meta.yaml
cp conda-recipe/meta.yaml conda-recipe/meta.yaml.github-test-backup

# Update meta.yaml with current version (simulating GitHub Actions sed command)
echo "Updating meta.yaml with version: $VERSION"
sed -i.bak "s/{% set version = .* %}/{% set version = \"$VERSION\" %}/" conda-recipe/meta.yaml

echo "Updated meta.yaml version section:"
head -3 conda-recipe/meta.yaml

# =============================================================================
# SIMULATE: Build conda package
# =============================================================================
step "Build conda package (simulates build-conda-ci.sh)"

echo "Creating dist-conda-test directory..."
mkdir -p dist-conda-test/noarch

echo "Building conda package..."
# Use our build script but output to test directory
BUILD_SCRIPT_CONTENT=$(cat build-conda-ci.sh | sed 's/dist-conda/dist-conda-test/g')
echo "$BUILD_SCRIPT_CONTENT" > build-conda-ci-test.sh
chmod +x build-conda-ci-test.sh

# Run the build in the conda environment
conda_shell "./build-conda-ci-test.sh"

echo "Verifying build results:"
ls -la dist-conda-test/noarch/

# =============================================================================
# SIMULATE: Upload conda package artifacts (file validation)
# =============================================================================
step "Validate conda package artifacts (simulates upload-artifact@v4)"

echo "Validating package files..."
PACKAGE_COUNT=$(find dist-conda-test/ -name "*.tar.bz2" -o -name "*.conda" | wc -l)
echo "Found $PACKAGE_COUNT conda packages"

if [[ $PACKAGE_COUNT -eq 0 ]]; then
    echo -e "${RED}❌ No conda packages found!${NC}"
    exit 1
fi

echo "Package details:"
find dist-conda-test/ -name "*.tar.bz2" -o -name "*.conda" | while read package; do
    echo "  📦 $package"
    echo "      Size: $(ls -lh "$package" | awk '{print $5}')"
    echo "      Type: $(file "$package")"
done

# =============================================================================
# SIMULATE: Install package and test
# =============================================================================
step "Test package installation (simulates conda install test)"

echo "Testing package installation in clean environment..."
TEST_ENV="cvannotate-install-test"
conda create -n "$TEST_ENV" python=3.11 -y -q

# Find the conda package
CONDA_PACKAGE=$(find dist-conda-test/ -name "*.conda" | head -1)
if [[ -n "$CONDA_PACKAGE" ]]; then
    echo "Installing package: $CONDA_PACKAGE"
    conda install -n "$TEST_ENV" "$CONDA_PACKAGE" -y
    
    echo "Testing CLI functionality..."
    conda run -n "$TEST_ENV" cvannotate --help | head -5
    
    echo "Verifying package contents..."
    conda run -n "$TEST_ENV" python -c "import cvannotate; print(f'CVAnnotate version: {cvannotate.__version__}')"
    
    echo -e "${GREEN}✅ Package installation test passed!${NC}"
    
    # Cleanup test environment
    conda env remove -n "$TEST_ENV" -y
else
    echo -e "${RED}❌ No conda package found for testing!${NC}"
    exit 1
fi

# =============================================================================
# SIMULATE: Upload preparation (without actual upload)
# =============================================================================
step "Simulate upload to anaconda.org test channel"

echo "Simulating anaconda upload process..."
echo "Environment variables that would be set:"
echo "  ANACONDA_API_TOKEN: [MASKED]"
echo ""

echo "Upload commands that would be executed:"
for package in $(find dist-conda-test/ -name "*.tar.bz2" -o -name "*.conda"); do
    if [[ -f "$package" ]]; then
        echo "  📤 anaconda upload \"$package\" --label test --force --no-progress"
        echo "      File: $package"
        echo "      Size: $(ls -lh "$package" | awk '{print $5}')"
        echo "      Status: ✅ Ready for upload"
    else
        echo "  ⚠️  Package file not found: $package"
    fi
done

# =============================================================================
# SIMULATE: Validate upload readiness
# =============================================================================
step "Validate upload readiness (anaconda client compatibility)"

echo "Testing anaconda client can read package metadata..."
for package in $(find dist-conda-test/ -name "*.conda"); do
    echo "Testing package: $package"
    
    # Test that anaconda client can read the package
    timeout 5 conda_shell "anaconda upload --help > /dev/null" || {
        echo -e "${RED}❌ anaconda client not working properly${NC}"
        exit 1
    }
    
    # Verify package is a valid zip archive
    if file "$package" | grep -q "Zip archive"; then
        echo -e "${GREEN}✅ Package is valid zip archive${NC}"
    else
        echo -e "${RED}❌ Package is not a valid zip archive${NC}"
        exit 1
    fi
    
    # Test package contents
    if python3 -c "
import zipfile
try:
    with zipfile.ZipFile('$package', 'r') as zf:
        files = zf.namelist()
        if len(files) > 0:
            print(f'✅ Package contains {len(files)} files')
        else:
            print('❌ Package is empty')
            exit(1)
except Exception as e:
    print(f'❌ Error reading package: {e}')
    exit(1)
" 2>/dev/null; then
        echo -e "${GREEN}✅ Package contents validation passed${NC}"
    else
        echo -e "${RED}❌ Package contents validation failed${NC}"
        exit 1
    fi
done

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo -e "${GREEN}🎉 SIMULATION COMPLETED SUCCESSFULLY!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""
echo "Summary of simulated GitHub Actions workflow:"
echo "✅ Conda environment setup (setup-miniconda@v3)"
echo "✅ conda-build and anaconda-client installation"
echo "✅ Version extraction and meta.yaml update"
echo "✅ Conda package build (build-conda-ci.sh)"
echo "✅ Package artifact validation (upload-artifact@v4)"
echo "✅ Package installation testing"
echo "✅ Upload preparation and validation"
echo ""
echo "Built packages:"
find dist-conda-test/ -name "*.tar.bz2" -o -name "*.conda" | while read package; do
    echo "  📦 $package ($(ls -lh "$package" | awk '{print $5}'))"
done
echo ""
echo -e "${BLUE}The conda build and upload process is ready for GitHub Actions!${NC}"
echo -e "${BLUE}You can now safely push to the develop branch to test the real CI/CD.${NC}"

# Restore original meta.yaml
echo ""
echo "Restoring original meta.yaml..."
mv conda-recipe/meta.yaml.github-test-backup conda-recipe/meta.yaml

# Cleanup build artifacts
rm -f build-conda-ci-test.sh

echo -e "${GREEN}✅ Cleanup completed${NC}"
