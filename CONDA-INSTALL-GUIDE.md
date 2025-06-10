# Complete Environment Setup for CVAnnotate

## 🔧 Conda/Mamba Environment Files

The conda recipe and environment files have been created to support easy installation and development.

### 📦 Available Installation Methods

#### **Method 1: Install from PyPI using Conda**
```bash
# Create environment and install from PyPI
conda create -n cvtools python=3.11 pip
conda activate cvtools
pip install cvannotate
```

#### **Method 2: Install from conda-forge (Future)**
Once the package is submitted to conda-forge:
```bash
conda install -c conda-forge cvannotate
```

#### **Method 3: Development Environment**
```bash
# Clone the repository
git clone https://github.com/Echo9k/cv-format-annotation-converters.git
cd cv-format-annotation-converters

# Create development environment
conda env create -f environment-dev.yml
conda activate cvannotate-dev

# Install in editable mode
pip install -e .
```

#### **Method 4: User Environment**
```bash
# Create user environment from environment.yml
conda env create -f environment.yml
conda activate cvannotate
```

#### **Method 5: Build from Conda Recipe**
```bash
# Build the conda package locally
conda build conda-recipe

# Install the built package
conda install --use-local cvannotate
```

### 🐍 Mamba (Faster Alternative)

If you prefer mamba (faster conda alternative):

```bash
# Install mamba first
conda install mamba -n base -c conda-forge

# Then use mamba instead of conda
mamba env create -f environment.yml
mamba activate cvannotate
```

### 🔄 Environment Management

**Create new environment:**
```bash
# From environment file
conda env create -f environment.yml

# Or create minimal environment
conda create -n cvtools python=3.11 typer pillow
conda activate cvtools
pip install cvannotate
```

**Update environment:**
```bash
# Update from file
conda env update -f environment-dev.yml

# Or update packages
conda update --all
```

**Remove environment:**
```bash
conda env remove -n cvannotate
```

**Export current environment:**
```bash
# Export exact environment
conda env export > my-environment.yml

# Export only explicit packages
conda env export --from-history > minimal-environment.yml
```

### 🏗️ Building Conda Package

To build the conda package yourself:

1. **Ensure conda-build is installed:**
   ```bash
   conda install conda-build
   ```

2. **Build the package:**
   ```bash
   conda build conda-recipe
   ```

3. **Install locally:**
   ```bash
   conda install --use-local cvannotate
   ```

4. **Upload to conda channel (for maintainers):**
   ```bash
   anaconda upload /path/to/built/package.tar.bz2
   ```

### 📋 Environment Files Included

- **`environment.yml`**: User environment with minimal dependencies
- **`environment-dev.yml`**: Development environment with testing tools
- **`conda-recipe/meta.yaml`**: Conda package recipe
- **`conda-recipe/build.sh`**: Unix build script
- **`conda-recipe/bld.bat`**: Windows build script

### 🎯 Recommended Workflow

For most users:
```bash
# Quick start
conda create -n cvtools python=3.11 pip
conda activate cvtools
pip install cvannotate
```

For developers:
```bash
# Development setup
git clone <repository>
cd cv-format-annotation-converters
conda env create -f environment-dev.yml
conda activate cvannotate-dev
pip install -e .
```

### 🔍 Troubleshooting

**Environment conflicts:**
```bash
# Reset environment
conda env remove -n cvannotate
conda env create -f environment.yml
```

**Package not found:**
```bash
# Update conda
conda update conda

# Clear cache
conda clean --all
```

**Permission issues:**
```bash
# Install in user space
conda create --prefix ./envs/cvannotate python=3.11
conda activate ./envs/cvannotate
pip install cvannotate
```

Your package is now ready for distribution through multiple conda-based installation methods! 🚀
