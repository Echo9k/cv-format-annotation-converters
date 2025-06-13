# Scripts Directory

This directory contains utility scripts for development, testing, CI/CD operations, and **conda recipe automation**.

## Conda Recipe Automation 🚀

### 🐍 `update_conda_recipe.py`
Python script that fetches package information from PyPI/test-PyPI and updates the conda recipe automatically.

**Features:**
- Fetches latest or specific version information
- Supports both PyPI and test-PyPI
- Updates version, URL, and SHA256 hash automatically
- Dry-run mode for testing
- Detailed error handling

**Usage:**
```bash
# Update to latest version from PyPI
python scripts/update_conda_recipe.py cvannotate

# Update to specific version from test-PyPI
python scripts/update_conda_recipe.py cvannotate --version 1.0.0 --test-pypi

# Dry run to see what would be changed
python scripts/update_conda_recipe.py cvannotate --dry-run
```

### 🔧 `update_recipe.sh`
Bash wrapper script for easier command-line usage.

**Usage:**
```bash
# Update to latest version
./scripts/update_recipe.sh

# Update specific package and version
./scripts/update_recipe.sh cvannotate 1.0.0

# Use test-PyPI
./scripts/update_recipe.sh cvannotate 1.0.0 --test-pypi
```

### 🤖 GitHub Actions Integration
The workflow `.github/workflows/update-conda-recipe.yml` automatically:
1. **Triggers on new GitHub releases**
2. **Fetches PyPI information** for the released version  
3. **Updates conda recipe** with new version and hash
4. **Creates a Pull Request** with the changes

## Build Scripts

### `build-conda-ci.sh`
**Purpose**: Builds conda package with workarounds for conda-build limitations.

**Usage**:
```bash
./scripts/build-conda-ci.sh
```

**Features**:
- Handles conda-build output directory issues
- Provides robust error handling and cleanup
- Creates proper directory structure for artifacts
- Used in both local development and CI/CD pipeline

**Output**: `dist-conda/noarch/cvannotate-*.conda`

### `build-conda-ci-simple.sh`
**Purpose**: Cross-platform conda build script for GitHub Actions.

**Usage**:
```bash
./scripts/build-conda-ci-simple.sh
```

**Features**:
- Cross-platform path detection (Linux, macOS, Windows)
- Uses `conda-build --output` for accurate location detection
- Comprehensive search across multiple conda directories
- Optimized for GitHub Actions environments

**Output**: `dist-conda/noarch/cvannotate-*.conda`

**Note**: Currently used in CI/CD pipeline for better platform compatibility.

## Test/Validation Scripts

### `test-github-actions-conda.sh`
**Purpose**: Comprehensive simulation of the GitHub Actions conda pipeline.

**Usage**:
```bash
./scripts/test-github-actions-conda.sh
```

**What it tests**:
- Conda environment setup
- Package building process
- Upload script validation  
- Error handling scenarios

**Use case**: Run before pushing changes to prevent CI/CD failures.

### `validate-conda-package.sh`
**Purpose**: Validates conda package structure and metadata.

**Usage**:
```bash
./scripts/validate-conda-package.sh
```

**What it validates**:
- Package file integrity
- Metadata structure
- Dependency specifications
- Entry points configuration

### `test-upload-process.sh`
**Purpose**: Simulates the package upload process without actual upload.

**Usage**:
```bash
./scripts/test-upload-process.sh
```

**What it tests**:
- Upload script syntax
- File path handling
- Error handling scenarios
- Package readiness for anaconda.org

### `validate-github-actions-conda.sh`
**Purpose**: Quick validation of conda setup and package.

**Usage**:
```bash
./scripts/validate-github-actions-conda.sh
```

**Use case**: Fast pre-commit check for conda-related changes.

## Installation Scripts

### `install.sh`
**Purpose**: Local development environment setup.

**Usage**:
```bash
./scripts/install.sh
```

**What it does**:
- Sets up development environment
- Installs dependencies
- Configures development tools

### `test-installation.sh`
**Purpose**: Tests package installation in clean environment.

**Usage**:
```bash
./scripts/test-installation.sh
```

### `test-conda-setup.sh`
**Purpose**: Tests conda environment setup and configuration.

**Usage**:
```bash
./scripts/test-conda-setup.sh
```

## Recommended Workflow

### Before Pushing Changes
```bash
# 1. Validate package structure
./scripts/validate-conda-package.sh

# 2. Test complete pipeline
./scripts/test-github-actions-conda.sh

# 3. Test upload process
./scripts/test-upload-process.sh
```

### During Development
```bash
# Build and test locally
./scripts/build-conda-ci.sh
./scripts/test-installation.sh
```

### CI/CD Integration
- `build-conda-ci.sh` is used in GitHub Actions workflow
- Other scripts are for local validation before push
- Helps catch issues early and prevent CI/CD failures

## Notes

- All scripts include comprehensive error handling
- Scripts use `set -e` for fail-fast behavior
- Color-coded output for better readability
- Detailed logging for debugging purposes
