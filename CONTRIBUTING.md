# Contributing to CVAnnotate

Thank you for your interest in contributing to CVAnnotate! This document provides guidelines for contributing to the project.

## Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/Echo9k/cv-format-annotation-converters.git
   cd cv-format-annotation-converters
   ```

2. **Set up Development Environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -e .
   pip install -r requirements-dev.txt
   ```

3. **Install Pre-commit Hooks**
   ```bash
   pip install pre-commit
   pre-commit install
   ```

## Development Workflow

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Write clean, readable code
   - Add tests for new functionality
   - Update documentation as needed

3. **Run Tests Locally**
   ```bash
   # Run all tests
   pytest tests/ -v
   
   # Run with coverage
   pytest tests/ -v --cov=cvannotate --cov-report=term-missing
   
   # Run specific test
   pytest tests/test_convert.py::test_yolo_to_voc -v
   ```

4. **Code Quality Checks**
   ```bash
   # Format code
   black cvannotate tests
   
   # Sort imports
   isort cvannotate tests
   
   # Lint code
   flake8 cvannotate tests
   
   # Type checking
   mypy cvannotate
   
   # Security scan
   bandit -r cvannotate
   ```

5. **Commit and Push**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request**
   - Open a PR against the `develop` branch
   - Provide clear description of changes
   - Link any related issues

## Code Style

- Use **Black** for code formatting (line length: 88)
- Use **isort** for import sorting
- Follow **PEP 8** guidelines
- Use type hints where appropriate
- Write descriptive docstrings

## Testing

- Write tests for all new functionality
- Aim for high test coverage (>90%)
- Use descriptive test names
- Test edge cases and error conditions

## Commit Message Format

Use conventional commits:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `test:` for adding tests
- `refactor:` for code refactoring
- `ci:` for CI/CD changes

## Release Process

See [RELEASE.md](RELEASE.md) for detailed release instructions.

## Questions?

If you have questions, please:
1. Check existing issues
2. Open a new issue with the `question` label
3. Join our discussions

Thank you for contributing! 🎉
