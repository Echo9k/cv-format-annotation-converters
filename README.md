# CVAnnotate - Annotation Format Converters

[![CI/CD Pipeline](https://github.com/Echo9k/cv-format-annotation-converters/workflows/CI/CD%20Pipeline/badge.svg)](https://github.com/Echo9k/cv-format-annotation-converters/actions)
[![PyPI version](https://badge.fury.io/py/cvannotate.svg)](https://badge.fury.io/py/cvannotate)
[![Python versions](https://img.shields.io/pypi/pyversions/cvannotate.svg)](https://pypi.org/project/cvannotate/)
[![codecov](https://codecov.io/gh/Echo9k/cv-format-annotation-converters/branch/main/graph/badge.svg)](https://codecov.io/gh/Echo9k/cv-format-annotation-converters)

This repository covers all formats of annotations for Object Detection and can easily convert from one form to another using the `cvannotate` Python package.

## Installation

### PyPI (Recommended)

Install from PyPI:
```bash
pip install cvannotate
```

### Test PyPI (Latest Development)

```bash
pip install -i https://test.pypi.org/simple/ cvannotate
```

### Conda/Mamba

Create a conda environment and install:
```bash
# Create environment
conda create -n cvannotate python=3.11
conda activate cvannotate

# Install from PyPI
pip install cvannotate

# Or use environment file
conda env create -f environment.yml
```

### From Source

```bash
git clone https://github.com/Echo9k/cv-format-annotation-converters.git
cd cv-format-annotation-converters
pip install -e .
```

## Quick Start

### CLI Usage

Convert annotations between different formats:

```bash
# Convert YOLO to VOC format
cvannotate convert -i annotations.txt --from-format yolo -f voc -w 640 --height 480 -c classes.txt

# Convert VOC to COCO format
cvannotate convert -i annotations.xml --from-format voc -f coco -c classes.txt

# Convert COCO to YOLO format
cvannotate convert -i annotations.json --from-format coco -f yolo -w 640 --height 480 -c classes.txt
```

### Python API

```python
from cvannotate import convert
from pathlib import Path

# Read annotations
annotations = convert.read_annotation(
    Path("annotations.txt"), 
    "yolo", 
    width=640, 
    height=480
)

# Write in different format
convert.write_annotation(
    annotations, 
    Path("output/"), 
    "voc", 
    ["person", "car", "bicycle"]
)
```

## Features

- ✅ **Multi-format Support**: Convert between YOLO, VOC, and COCO formats
- ✅ **CLI Interface**: Simple command-line interface for batch processing
- ✅ **Python API**: Programmatic access for integration
- ✅ **Type Safety**: Full type hints for better development experience
- ✅ **Testing**: Comprehensive test suite with >90% coverage
- ✅ **Documentation**: Well-documented code and examples

## Documentation

- 📖 [Installation Guide](INSTALLATION.md)
- 🛠️ [Development Guide](DEVELOPMENT.md)  
- 🤝 [Contributing Guidelines](CONTRIBUTING.md)
- 📦 [Technical Documentation](docs/technical/)

## Supported Formats

- **YOLO**: Normalized center coordinates _(x_center, y_center, width, height)_
- **Pascal VOC**: Corner coordinates _(xmin, ymin, xmax, ymax)_ in XML
- **MS COCO**: Top-left coordinates _(x, y, width, height)_ in JSON

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

### Local Development Setup

```bash
git clone https://github.com/USERNAME/cv-format-annotation-converters.git
cd cv-format-annotation-converters
pip install -e .
pip install -r requirements-dev.txt
pre-commit install
```

### Running Tests

```bash
pytest tests/ -v --cov=cvannotate
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Scripts ##
