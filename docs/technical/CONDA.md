# Conda Package Management

This document covers conda package building, testing, and distribution for CVAnnotate.

## Quick Start

### Install from Conda
```bash
# From anaconda.org (when available)
conda install -c echo9k cvannotate

# From local build
conda install -c local cvannotate
```

## Building Conda Packages

### Prerequisites
```bash
conda install conda-build anaconda-client
```

### Build Process
```bash
# Use the dedicated build script (recommended)
./scripts/build-conda-ci.sh

# Or manually
conda-build conda-recipe --output-folder=dist-conda
```

### Build Script Features
The `scripts/build-conda-ci.sh` script:
- Handles conda build output directory issues
- Provides robust error handling
- Creates proper directory structure
- Validates package creation

## Package Validation

### Automated Testing
```bash
# Full GitHub Actions simulation
./scripts/test-github-actions-conda.sh

# Package structure validation
./scripts/validate-conda-package.sh

# Upload process testing
./scripts/test-upload-process.sh
```

### Manual Validation
```bash
# Check package contents
conda info dist-conda/noarch/cvannotate-*.conda

# Test installation
conda create -n test-env -y
conda activate test-env
conda install dist-conda/noarch/cvannotate-*.conda

# Test functionality
cvannotate --help
python -c "import cvannotate; print('✅ Import successful')"
```

## Dependencies

The conda package includes these runtime dependencies:
- `python >=3.8`
- `typer` - CLI framework
- `pillow` - Image processing
- `defusedxml` - Secure XML parsing

Dependencies are automatically resolved when installing from anaconda.org.

## CI/CD Integration

### GitHub Actions Workflow
1. **Build Stage**: Creates conda packages for multiple OS
2. **Test Upload**: Uploads to test channel on develop branch
3. **Production Upload**: Uploads to main channel on tagged releases

### Upload Process
The CI/CD pipeline uses a robust upload script that:
- Handles both `.tar.bz2` and `.conda` formats
- Provides detailed logging for debugging
- Fails fast on upload errors
- Reports file sizes for validation

```bash
# Example upload command used in CI
anaconda upload package.conda --label test --force --no-progress
```

## Troubleshooting

### Common Issues

**Build Failures**
- Ensure conda-build is installed: `conda install conda-build`
- Check meta.yaml syntax and dependencies
- Verify source path references

**Upload Failures** 
- Verify ANACONDA_API_TOKEN is set
- Check package file exists and is readable
- Ensure anaconda-client is installed

**Dependency Issues**
- Local installs may require manual dependency installation
- Anaconda.org installs automatically resolve dependencies
- Use `conda install -c conda-forge <missing-dep>` if needed

### Test Scripts
Use validation scripts before pushing changes:
```bash
./scripts/test-github-actions-conda.sh  # Full pipeline test
./scripts/validate-conda-package.sh     # Package validation
./scripts/test-upload-process.sh        # Upload simulation
./scripts/validate-github-actions-conda.sh  # Quick validation
```

See `scripts/README.md` for detailed script documentation.

## Package Metadata

Current package configuration:
- **Name**: cvannotate
- **Version**: 0.1.0 (auto-updated from pyproject.toml)
- **Build**: py_0 (noarch Python package)
- **Channels**: conda-forge, defaults
- **License**: MIT

## Release Channels

- **Test Channel**: `conda install -c echo9k/label/test cvannotate`
- **Main Channel**: `conda install -c echo9k cvannotate`

Test channel receives uploads from develop branch, main channel from tagged releases.

---

**Status**: ✅ Conda package build and upload process is fully operational
**Last Updated**: June 12, 2025
