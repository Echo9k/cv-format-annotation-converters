# Development Guide

This guide covers development setup, testing, and contribution workflows for CVAnnotate.

## Development Setup

### Prerequisites
- Python 3.8+ 
- Git
- Conda (for conda package development)

### 1. Clone and Setup Environment

```bash
git clone https://github.com/Echo9k/cv-format-annotation-converters.git
cd cv-format-annotation-converters

# Create development environment
conda env create -f environment-dev.yml
conda activate cvannotate-dev

# Or with pip
pip install -r requirements-dev.txt
pip install -e .
```

### 2. Install Development Dependencies

```bash
pip install build pytest pytest-cov pytest-xdist
pip install flake8 black isort mypy
pip install safety bandit[toml]
```

## Testing

### Unit Tests
```bash
pytest tests/ -v --cov=cvannotate --cov-report=term-missing
```

### Test Scripts
Use the scripts in `scripts/` directory for pre-push validation:

```bash
# Test conda pipeline before pushing
./scripts/test-github-actions-conda.sh

# Validate conda package structure  
./scripts/validate-conda-package.sh

# Test upload process (simulation)
./scripts/test-upload-process.sh

# Quick validation
./scripts/validate-github-actions-conda.sh
```

See `scripts/README.md` for detailed documentation of all available scripts.

### Code Quality
```bash
# Formatting
black cvannotate tests
isort cvannotate tests

# Linting
flake8 cvannotate tests

# Type checking
mypy cvannotate --ignore-missing-imports

# Security checks
bandit -r cvannotate
safety check
```

## Building Packages

### Python Package
```bash
python -m build
```

### Conda Package
```bash
./scripts/build-conda-ci.sh
```

## Release Process

1. Update version in `pyproject.toml`
2. Create and push git tag: `git tag v1.0.0 && git push origin v1.0.0`
3. GitHub Actions will automatically:
   - Run tests
   - Build packages
   - Publish to PyPI and Anaconda.org

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make changes and add tests
4. Run test scripts to validate before pushing
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

## CI/CD Pipeline

The GitHub Actions workflow handles:
- Testing across Python versions
- Code quality checks
- Security scanning
- Package building and publishing
- Conda package distribution

Pre-push validation with test scripts helps ensure CI/CD success.
