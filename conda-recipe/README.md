# CVAnnotate Conda Recipe

This directory contains the conda recipe for building and distributing the `cvannotate` package through conda/mamba package managers.

## Files

- **`meta.yaml`**: Main recipe configuration file defining package metadata, dependencies, and build instructions
- **`build.sh`**: Build script for Unix-like systems (Linux, macOS)
- **`bld.bat`**: Build script for Windows systems

## Building the Package Locally

### Prerequisites

Install conda-build:
```bash
conda install conda-build
# or
mamba install conda-build
```

### Build the Package

1. **Update the recipe** (if needed):
   - Update version in `meta.yaml`
   - Update dependencies if changed
   - Update GitHub URLs with your actual username

2. **Get the SHA256 hash** of your PyPI package:
   ```bash
   # For the current version
   pip download cvannotate==0.1.0 --no-deps
   sha256sum cvannotate-0.1.0.tar.gz
   ```

3. **Update `meta.yaml`** with the correct SHA256 hash.

4. **Build the conda package**:
   ```bash
   # From the parent directory
   conda-build conda-recipe/
   
   # Or specify Python version
   conda-build conda-recipe/ --python=3.11
   ```

5. **Test the package**:
   ```bash
   # Install from local build
   conda install --use-local cvannotate
   
   # Test functionality
   cvannotate --help
   ```

## Installation for Users

Once published to a conda channel:

```bash
# Install from conda-forge (when available)
conda install -c conda-forge cvannotate

# Or with mamba
mamba install -c conda-forge cvannotate

# Install from your personal channel
conda install -c YOUR_CHANNEL cvannotate
```

## Publishing to Conda-Forge

To make your package available through conda-forge:

1. **Fork conda-forge/staged-recipes**
2. **Create a new recipe** in `recipes/cvannotate/`
3. **Copy the recipe files** from this directory
4. **Submit a Pull Request** to conda-forge/staged-recipes
5. **Wait for review** and merge

See: https://conda-forge.org/docs/maintainer/adding_pkgs.html

## Environment File

Create environment files for different use cases:

### Basic Environment (`environment.yml`)
```yaml
name: cvannotate-env
channels:
  - conda-forge
dependencies:
  - python>=3.8
  - cvannotate
```

### Development Environment (`environment-dev.yml`)
```yaml
name: cvannotate-dev
channels:
  - conda-forge
dependencies:
  - python>=3.8
  - cvannotate
  - pytest
  - black
  - isort
  - flake8
  - mypy
```

## Usage Examples

After installation:

```bash
# Create environment with cvannotate
conda create -n myproject python=3.11 cvannotate
conda activate myproject

# Use the tool
cvannotate convert -i annotations.txt --from-format yolo -f voc -w 640 --height 480 -c classes.txt
```

## Maintenance

When releasing new versions:

1. Update version in `meta.yaml`
2. Update SHA256 hash from PyPI
3. Rebuild and test locally
4. Update conda-forge recipe (if published there)

## Troubleshooting

### Common Issues

1. **Missing dependencies**: Ensure all runtime dependencies are listed in `meta.yaml`
2. **Import errors**: Check that all modules are properly imported in the test section
3. **Build failures**: Check build logs for missing build dependencies

### Debug Build

```bash
# Build with verbose output
conda-build conda-recipe/ --debug

# Keep build directory for inspection
conda-build conda-recipe/ --no-remove-work-dir
```
