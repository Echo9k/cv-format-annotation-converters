#!/bin/bash
# CVAnnotate Installation Script

echo "🚀 Installing CVAnnotate..."

# Check if pip is available
if ! command -v pip &> /dev/null; then
    echo "❌ pip is not installed. Please install pip first."
    exit 1
fi

# Check Python version
python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "✅ Python $python_version detected"

# Install from wheel if available locally
if [ -f "cvannotate-0.1.0-py3-none-any.whl" ]; then
    echo "📦 Installing from local wheel..."
    pip install cvannotate-0.1.0-py3-none-any.whl
elif [ -f "cvannotate-0.1.0.tar.gz" ]; then
    echo "📦 Installing from source distribution..."
    pip install cvannotate-0.1.0.tar.gz
else
    echo "📦 Installing from source (requires git)..."
    if ! command -v git &> /dev/null; then
        echo "❌ git is not installed. Please install git or download the wheel file."
        exit 1
    fi
    
    # Clone and install from source
    git clone https://github.com/Echo9k/cv-format-annotation-converters.git
    cd cv-format-annotation-converters
    pip install .
    cd ..
    rm -rf cv-format-annotation-converters
fi

# Verify installation
if command -v cvannotate &> /dev/null; then
    echo "✅ CVAnnotate installed successfully!"
    echo "🎯 Usage: cvannotate convert --help"
    cvannotate --help
else
    echo "❌ Installation failed. Please check error messages above."
    exit 1
fi
