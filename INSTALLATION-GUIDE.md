# CVAnnotate Installation Guide

## 🎉 **Your Package is Now Available!**

Your `cvannotate` package has been successfully uploaded to Test PyPI and is ready for installation!

**Test PyPI URL**: https://test.pypi.org/project/cvannotate/0.1.0/

---

## 📦 **Installation Methods**

### **Method 1: Install from Test PyPI (Recommended for Testing)**

```bash
# Install from Test PyPI
pip install -i https://test.pypi.org/simple/ cvannotate

# Or specify version
pip install -i https://test.pypi.org/simple/ cvannotate==0.1.0
```

**Note**: Test PyPI may not have all dependencies, so you might need to install them separately:

```bash
# Install dependencies from regular PyPI first
pip install typer pillow

# Then install cvannotate from Test PyPI
pip install -i https://test.pypi.org/simple/ cvannotate
```

### **Method 2: Install from Built Wheel (Offline Installation)**

For machines without internet or for distribution:

```bash
# Copy the wheel file to target machine
scp dist/cvannotate-0.1.0-py3-none-any.whl user@target-machine:/tmp/

# On target machine
pip install /tmp/cvannotate-0.1.0-py3-none-any.whl
```

### **Method 3: Install from Source (Development)**

```bash
# Clone the repository
git clone https://github.com/Echo9k/cv-format-annotation-converters.git
cd cv-format-annotation-converters

# Install in development mode
pip install -e .
```

### **Method 4: Install from Tarball**

```bash
# Copy the source distribution
scp dist/cvannotate-0.1.0.tar.gz user@target-machine:/tmp/

# On target machine
pip install /tmp/cvannotate-0.1.0.tar.gz
```

---

## 🚀 **Production PyPI Deployment**

To deploy to production PyPI (so users can install with just `pip install cvannotate`):

### **Option A: Manual Upload**
```bash
twine upload dist/*
```

### **Option B: GitHub Actions (Automated)**
```bash
# Create and push a version tag
git tag v0.1.0
git push origin v0.1.0
```

This will trigger the GitHub Actions workflow to automatically deploy to production PyPI.

---

## ✅ **Verify Installation**

After installation, test that it works:

```bash
# Check if command is available
cvannotate --help

# Test conversion
cvannotate convert --help

# Test with sample data (if available)
cvannotate convert -i sample.txt --from-format yolo -f voc -w 640 --height 480 -c classes.txt
```

---

## 🌐 **Distribution Scenarios**

### **For End Users**
```bash
pip install -i https://test.pypi.org/simple/ cvannotate
```

### **For Docker Images**
```dockerfile
FROM python:3.11-slim
RUN pip install -i https://test.pypi.org/simple/ cvannotate
```

### **For Requirements Files**
```txt
# requirements.txt
--index-url https://test.pypi.org/simple/
cvannotate==0.1.0
```

### **For Conda Environments**
```bash
# Create new environment with package
conda create -n cvtools python=3.11
conda activate cvtools
pip install -i https://test.pypi.org/simple/ cvannotate
```

---

## 🔧 **Troubleshooting**

### **Dependencies Issues**
If you get dependency errors with Test PyPI:
```bash
# Install dependencies from regular PyPI first
pip install typer pillow

# Then install your package
pip install -i https://test.pypi.org/simple/ cvannotate --no-deps
```

### **Permission Issues**
```bash
# Install for current user only
pip install --user -i https://test.pypi.org/simple/ cvannotate
```

### **Version Conflicts**
```bash
# Force reinstall
pip install --force-reinstall -i https://test.pypi.org/simple/ cvannotate
```

---

## 📈 **Next Steps**

1. **Test Installation** on different machines/environments
2. **Deploy to Production PyPI** when ready
3. **Update Documentation** with installation instructions
4. **Share with Users** - they can now install your package easily!

Your package is now distributable and ready for real-world use! 🎉
