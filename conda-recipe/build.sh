#!/bin/bash

# Build script for conda package
# This script is executed during the conda build process

set -e  # Exit on any error

echo "Starting build process..."
echo "Python path: $PYTHON"
echo "Current directory: $(pwd)"

# Install the package using pip
echo "Installing package with pip..."
$PYTHON -m pip install . -vv --no-deps --ignore-installed

# Verify installation
echo "Verifying installation..."
$PYTHON -c "import cvannotate; print('CVAnnotate version:', cvannotate.__version__)"

echo "Build completed successfully!"
