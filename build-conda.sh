#!/bin/bash

# Automated conda build script for cvannotate package
# Usage: ./build-conda.sh [version]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 CVAnnotate Conda Build Script${NC}"
echo "================================="

# Get version from argument or pyproject.toml
if [ "$1" ]; then
    VERSION="$1"
else
    VERSION=$(grep '^version = ' pyproject.toml | cut -d'"' -f2)
fi

echo -e "${YELLOW}📦 Building version: ${VERSION}${NC}"

# Check if conda-build is installed
if ! command -v conda-build &> /dev/null; then
    echo -e "${RED}❌ conda-build not found. Installing...${NC}"
    conda install conda-build -y
fi

# Function to get SHA256 from PyPI
get_sha256() {
    local version=$1
    echo -e "${YELLOW}🔍 Getting SHA256 for version ${version}...${NC}"
    
    # Download the source distribution
    pip download "cvannotate==${version}" --no-deps --no-binary=:all: -q
    
    # Get SHA256
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        SHA256=$(shasum -a 256 "cvannotate-${version}.tar.gz" | cut -d' ' -f1)
    else
        # Linux
        SHA256=$(sha256sum "cvannotate-${version}.tar.gz" | cut -d' ' -f1)
    fi
    
    echo -e "${GREEN}✅ SHA256: ${SHA256}${NC}"
    
    # Clean up
    rm "cvannotate-${version}.tar.gz"
    
    echo "$SHA256"
}

# Get SHA256 hash
SHA256=$(get_sha256 "$VERSION")

# Update meta.yaml with correct version and SHA256
echo -e "${YELLOW}📝 Updating meta.yaml...${NC}"
sed -i.bak "s/{% set version = .* %}/{% set version = \"$VERSION\" %}/" conda-recipe/meta.yaml
sed -i.bak "s/sha256: {{ sha256 }}/sha256: $SHA256/" conda-recipe/meta.yaml

echo -e "${YELLOW}🏗️  Building conda package...${NC}"

# Build the package
conda-build conda-recipe/ --no-anaconda-upload

# Get the path to the built package
PACKAGE_PATH=$(conda-build conda-recipe/ --output)

echo -e "${GREEN}✅ Package built successfully!${NC}"
echo -e "${BLUE}📍 Package location: ${PACKAGE_PATH}${NC}"

# Test installation
echo -e "${YELLOW}🧪 Testing package installation...${NC}"

# Create a test environment
TEST_ENV="test-cvannotate-$$"
conda create -n "$TEST_ENV" python=3.11 -y -q

# Install the package
conda install -n "$TEST_ENV" "$PACKAGE_PATH" -y -q

# Test the package
echo -e "${YELLOW}🔍 Testing package functionality...${NC}"
conda run -n "$TEST_ENV" cvannotate --help > /dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Package test passed!${NC}"
else
    echo -e "${RED}❌ Package test failed!${NC}"
    exit 1
fi

# Cleanup test environment
conda env remove -n "$TEST_ENV" -y -q

# Restore original meta.yaml
mv conda-recipe/meta.yaml.bak conda-recipe/meta.yaml

echo ""
echo -e "${GREEN}🎉 Conda package build completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo "  1. Test the package: conda install --use-local cvannotate"
echo "  2. Upload to anaconda.org: anaconda upload ${PACKAGE_PATH}"
echo "  3. Or submit to conda-forge for wider distribution"
echo ""
echo -e "${BLUE}📦 Package details:${NC}"
echo "  Version: ${VERSION}"
echo "  SHA256: ${SHA256}"
echo "  Path: ${PACKAGE_PATH}"
