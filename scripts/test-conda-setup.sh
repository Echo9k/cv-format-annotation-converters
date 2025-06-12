#!/bin/bash
# Test script for conda package build and installation
# Usage: ./test-conda-setup.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing Conda Package Setup${NC}"
echo "==============================="

# Check prerequisites
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo -e "${RED}❌ conda not found. Please install conda/miniconda first.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ conda found: $(conda --version)${NC}"
fi

# Check if conda-build is available
if ! command -v conda-build &> /dev/null; then
    echo -e "${YELLOW}⚠️  conda-build not found. Installing...${NC}"
    conda install conda-build anaconda-client -y
else
    echo -e "${GREEN}✅ conda-build found: $(conda-build --version)${NC}"
fi

# Check if pyproject.toml exists
if [[ ! -f pyproject.toml ]]; then
    echo -e "${RED}❌ pyproject.toml not found${NC}"
    exit 1
else
    VERSION=$(grep '^version = ' pyproject.toml | sed 's/version = "//' | sed 's/"//')
    echo -e "${GREEN}✅ pyproject.toml found, version: ${VERSION}${NC}"
fi

# Check if conda recipe exists
if [[ ! -f conda-recipe/meta.yaml ]]; then
    echo -e "${RED}❌ conda-recipe/meta.yaml not found${NC}"
    exit 1
else
    echo -e "${GREEN}✅ conda recipe found${NC}"
fi

echo ""
echo -e "${BLUE}🏗️  Testing conda package build...${NC}"

# Create a backup of meta.yaml
cp conda-recipe/meta.yaml conda-recipe/meta.yaml.test-bak

# Update meta.yaml with current version
echo -e "${YELLOW}📝 Updating meta.yaml with version ${VERSION}...${NC}"
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/{% set version = .* %}/{% set version = \"$VERSION\" %}/" conda-recipe/meta.yaml
else
    sed -i "s/{% set version = .* %}/{% set version = \"$VERSION\" %}/" conda-recipe/meta.yaml
fi

# Create output directory
mkdir -p dist-conda-test

# Build the package
echo -e "${YELLOW}🔨 Building conda package...${NC}"
if conda-build conda-recipe/ --output-folder dist-conda-test/ --no-anaconda-upload; then
    echo -e "${GREEN}✅ Conda package built successfully!${NC}"
    
    # Get package path
    PACKAGE_PATH=$(conda-build conda-recipe/ --output)
    echo -e "${BLUE}📦 Package location: ${PACKAGE_PATH}${NC}"
    
    # Test installation in a new environment
    echo -e "${YELLOW}🧪 Testing package installation...${NC}"
    
    TEST_ENV="test-cvannotate-$$"
    echo -e "${YELLOW}📋 Creating test environment: ${TEST_ENV}${NC}"
    
    if conda create -n "$TEST_ENV" python=3.11 -y -q; then
        echo -e "${GREEN}✅ Test environment created${NC}"
        
        # Install the built package
        if conda install -n "$TEST_ENV" "$PACKAGE_PATH" -y -q; then
            echo -e "${GREEN}✅ Package installed successfully${NC}"
            
            # Test the CLI
            echo -e "${YELLOW}🔍 Testing CLI functionality...${NC}"
            if conda run -n "$TEST_ENV" cvannotate --help > /dev/null 2>&1; then
                echo -e "${GREEN}✅ CLI test passed${NC}"
                
                # Test convert command
                if conda run -n "$TEST_ENV" cvannotate convert --help > /dev/null 2>&1; then
                    echo -e "${GREEN}✅ Convert command test passed${NC}"
                    TEST_SUCCESS=true
                else
                    echo -e "${RED}❌ Convert command test failed${NC}"
                    TEST_SUCCESS=false
                fi
            else
                echo -e "${RED}❌ CLI test failed${NC}"
                TEST_SUCCESS=false
            fi
        else
            echo -e "${RED}❌ Package installation failed${NC}"
            TEST_SUCCESS=false
        fi
        
        # Cleanup test environment
        echo -e "${YELLOW}🧹 Cleaning up test environment...${NC}"
        conda env remove -n "$TEST_ENV" -y -q
    else
        echo -e "${RED}❌ Failed to create test environment${NC}"
        TEST_SUCCESS=false
    fi
else
    echo -e "${RED}❌ Conda package build failed${NC}"
    TEST_SUCCESS=false
fi

# Restore original meta.yaml
echo -e "${YELLOW}🔄 Restoring original meta.yaml...${NC}"
mv conda-recipe/meta.yaml.test-bak conda-recipe/meta.yaml

# Cleanup build artifacts
echo -e "${YELLOW}🧹 Cleaning up build artifacts...${NC}"
rm -rf dist-conda-test

echo ""
echo -e "${BLUE}📊 Test Results${NC}"
echo "==============="

if [[ "$TEST_SUCCESS" == true ]]; then
    echo -e "${GREEN}🎉 All tests passed! Your conda package setup is working correctly.${NC}"
    echo ""
    echo -e "${BLUE}📋 Next steps:${NC}"
    echo "  1. Configure GitHub secrets (ANACONDA_USERNAME, ANACONDA_API_TOKEN)"
    echo "  2. Create GitHub environments (conda-test, conda-production)"
    echo "  3. Test the GitHub Actions workflow by pushing to develop branch"
    echo "  4. Create a release tag to test production publishing"
    echo ""
    echo -e "${BLUE}📚 Documentation:${NC}"
    echo "  - Setup guide: CONDA-GITHUB-ACTIONS-SETUP.md"
    echo "  - Build script: ./build-conda.sh"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Please check the errors above and fix them.${NC}"
    echo ""
    echo -e "${BLUE}💡 Troubleshooting tips:${NC}"
    echo "  - Ensure all dependencies are installed correctly"
    echo "  - Check that the package builds locally with: ./build-conda.sh"
    echo "  - Verify the conda recipe syntax in conda-recipe/meta.yaml"
    echo "  - Check that the entry points are correctly defined"
    echo ""
    exit 1
fi
