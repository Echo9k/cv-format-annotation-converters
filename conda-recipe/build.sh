#!/bin/bash

# Build script for conda package
# This script is executed during the conda build process

# Install the package using pip
$PYTHON -m pip install . -vv --no-deps --ignore-installed

# Verify installation
$PYTHON -c "import cvannotate; print('CVAnnotate version:', cvannotate.__version__)"
