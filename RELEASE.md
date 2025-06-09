# CVAnnotate Release Workflow

This document outlines the release process for the `cvannotate` Python package.

## Release Process

### 1. Development
- All development happens on feature branches
- Pull requests are merged to `develop` branch
- All tests must pass before merging

### 2. Testing Release (Test PyPI)
- Push to `develop` branch triggers deployment to Test PyPI
- Test the package installation from Test PyPI:
  ```bash
  pip install -i https://test.pypi.org/simple/ cvannotate
  ```

### 3. Production Release
- Create a release tag following semantic versioning (e.g., `v0.1.1`)
- Push the tag to trigger production deployment:
  ```bash
  git tag v0.1.1
  git push origin v0.1.1
  ```

### 4. Required Secrets

The following secrets need to be configured in GitHub repository settings:

#### For Test PyPI (Environment: test-pypi)
- `TEST_PYPI_API_TOKEN`: Your Test PyPI API token

#### For Production PyPI (Environment: production)
- `PYPI_API_TOKEN`: Your PyPI API token

### 5. Environment Setup

Create the following environments in GitHub:
- `test-pypi`: For Test PyPI deployments
- `production`: For production PyPI deployments (with protection rules)

### 6. Version Management

Update the version in `pyproject.toml` before creating a release tag:
```toml
[project]
version = "0.1.1"  # Update this
```

## Workflow Features

- **Multi-Python Testing**: Tests against Python 3.8-3.12
- **Code Quality**: Linting with flake8, formatting with black, import sorting with isort
- **Security Scanning**: Safety and bandit security checks
- **Package Testing**: Builds and tests package installation
- **Automated Publishing**: Deploys to Test PyPI on develop, Production PyPI on tags
- **Release Creation**: Automatically creates GitHub releases for tagged versions
