# Conda/Mamba Installation Guide for CVAnnotate

This guide covers how to install and use `cvannotate` with conda and mamba package managers.

## 🚀 Quick Installation

### Option 1: Using Pip in Conda Environment (Recommended)

```bash
# Create a new conda environment
conda create -n cvannotate python=3.11
conda activate cvannotate

# Install from PyPI
pip install cvannotate

# Or install from Test PyPI
pip install -i https://test.pypi.org/simple/ cvannotate
```

### Option 2: Using Environment File

```bash
# Clone the repository (or download environment.yml)
git clone https://github.com/Echo9k/cv-format-annotation-converters.git
cd cv-format-annotation-converters

# Create environment from file
conda env create -f environment.yml
conda activate cvannotate

# Verify installation
cvannotate --help
```

### Option 3: Direct Conda Install (Future)

Once published to conda-forge:
```bash
conda install -c conda-forge cvannotate
# or
mamba install -c conda-forge cvannotate
```

## 🛠️ Development Setup

For development work:

```bash
# Create development environment
conda env create -f environment-dev.yml
conda activate cvannotate-dev

# Install package in development mode
pip install -e .

# Install pre-commit hooks
pre-commit install
```

## 📦 Building Conda Package

### Prerequisites

```bash
# Install conda-build
conda install conda-build

# Or with mamba
mamba install conda-build
```

### Build Process

1. **Automated Build** (Recommended):
   ```bash
   ./build-conda.sh
   ```

2. **Manual Build**:
   ```bash
   # Build the package
   conda-build conda-recipe/
   
   # Install locally
   conda install --use-local cvannotate
   ```

### Testing the Build

```bash
# Create test environment
conda create -n test-cvannotate python=3.11
conda activate test-cvannotate

# Install the built package
conda install --use-local cvannotate

# Test functionality
cvannotate --help
cvannotate convert --help
```

## 📋 Environment Management

### Create Minimal Environment

```bash
conda create -n cv-work python=3.11 cvannotate
conda activate cv-work
```

### Create Full Development Environment

```bash
conda create -n cv-dev python=3.11
conda activate cv-dev
conda install pytest black isort flake8 mypy
pip install cvannotate
```

### Export Current Environment

```bash
# Export exact environment
conda env export > my-environment.yml

# Export cross-platform environment
conda env export --no-builds > my-environment-cross-platform.yml
```

## 🐳 Docker with Conda

Create a Dockerfile using conda:

```dockerfile
FROM continuumio/miniconda3:latest

# Copy environment file
COPY environment.yml /tmp/environment.yml

# Create environment
RUN conda env create -f /tmp/environment.yml

# Activate environment
RUN echo "conda activate cvannotate" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

# Set working directory
WORKDIR /app

# Default command
CMD ["cvannotate", "--help"]
```

Build and run:
```bash
docker build -t cvannotate:latest .
docker run -it cvannotate:latest
```

## 🎯 Usage Examples

### Basic Conversion

```bash
# Activate environment
conda activate cvannotate

# Convert YOLO to VOC
cvannotate convert \
    -i annotations.txt \
    --from-format yolo \
    -f voc \
    -w 640 \
    --height 480 \
    -c classes.txt
```

### Batch Processing Script

```bash
#!/bin/bash
# batch_convert.sh

# Ensure conda environment is activated
eval "$(conda shell.bash hook)"
conda activate cvannotate

# Process all YOLO files in a directory
for file in data/yolo/*.txt; do
    echo "Converting $file..."
    cvannotate convert \
        -i "$file" \
        -o "data/voc/" \
        --from-format yolo \
        -f voc \
        -w 640 \
        --height 480 \
        -c data/classes.txt
done

echo "Batch conversion completed!"
```

## 🔧 Troubleshooting

### Common Issues

1. **Environment not found**:
   ```bash
   conda info --envs  # List environments
   conda activate cvannotate  # Activate specific environment
   ```

2. **Package not found**:
   ```bash
   conda list  # Check installed packages
   pip list   # Check pip-installed packages
   ```

3. **Import errors**:
   ```bash
   python -c "import cvannotate; print(cvannotate.__file__)"
   ```

4. **Command not found**:
   ```bash
   which cvannotate  # Check if command is in PATH
   conda activate cvannotate  # Ensure environment is activated
   ```

### Reinstallation

```bash
# Remove and recreate environment
conda env remove -n cvannotate
conda env create -f environment.yml

# Or update existing environment
conda env update -f environment.yml
```

## 📊 Performance Considerations

### Memory Usage

For large datasets, consider:
```bash
# Create environment with specific memory settings
conda create -n cvannotate-large python=3.11
conda activate cvannotate-large
conda install python=3.11
pip install cvannotate

# Monitor memory usage
conda install psutil
python -c "import psutil; print(f'Memory: {psutil.virtual_memory().percent}%')"
```

### Parallel Processing

```bash
# Install with additional dependencies for parallel processing
conda create -n cvannotate-parallel python=3.11
conda activate cvannotate-parallel
conda install joblib
pip install cvannotate
```

## 📚 Advanced Usage

### Custom Conda Channel

If you maintain your own conda channel:

```bash
# Add your channel
conda config --add channels YOUR_CHANNEL

# Install from your channel
conda install -c YOUR_CHANNEL cvannotate
```

### Mixing Conda and Pip

Best practices when mixing conda and pip:

```bash
# Install conda packages first
conda create -n mixed-env python=3.11 numpy pandas
conda activate mixed-env

# Then install pip packages
pip install cvannotate

# Check what was installed where
conda list  # Shows both conda and pip packages
```

## 🚀 Publishing to Conda-Forge

To make your package available through conda-forge:

1. Fork [conda-forge/staged-recipes](https://github.com/conda-forge/staged-recipes)
2. Copy your recipe to `recipes/cvannotate/`
3. Submit a pull request
4. Wait for review and merge

Your package will then be available as:
```bash
conda install -c conda-forge cvannotate
```

This makes it easy for users to install without needing PyPI or custom channels.

## 📋 Maintenance

### Updating Dependencies

```bash
# Update all packages in environment
conda update --all

# Update specific package
conda update cvannotate

# Update from pip
pip install --upgrade cvannotate
```

### Environment Cleanup

```bash
# Remove unused packages
conda clean --all

# List large packages
conda list --size

# Remove specific environment
conda env remove -n old-environment
```
