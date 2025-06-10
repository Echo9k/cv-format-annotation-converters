# GitHub Actions Setup for Conda/Mamba Publishing

This guide explains how to set up automated Conda/Mamba package publishing using GitHub Actions.

## Implementation Status

✅ **CI/CD Workflow Updated**: Added conda build and publishing jobs to `.github/workflows/ci-cd.yml`
✅ **Conda Recipe**: Updated `conda-recipe/meta.yaml` for production builds
✅ **Build Script**: Enhanced `build-conda.sh` with version management
⏳ **GitHub Secrets**: Need to be configured (see below)
⏳ **GitHub Environments**: Need to be created (see below)

## Required GitHub Secrets

Add these secrets to your repository settings (`Settings > Secrets and variables > Actions`):

### For Anaconda.org Publishing
```
ANACONDA_USERNAME: your_anaconda_username
ANACONDA_API_TOKEN: your_anaconda_api_token
```

### How to Get Anaconda API Token
1. Go to [anaconda.org](https://anaconda.org/)
2. Login to your account
3. Go to Settings > Access
4. Create a new token with upload permissions
5. Copy the token and add it as `ANACONDA_API_TOKEN` secret

## Required GitHub Environments

Create these environments in your repository settings (`Settings > Environments`):

### 1. conda-test
- **Purpose**: For uploading packages to test channel on develop branch
- **Protection rules**: None (optional)

### 2. conda-production  
- **Purpose**: For uploading packages to main channel on release tags
- **Protection rules**: Require tag matching pattern `v*` (recommended)

## Workflow Triggers

The new conda jobs will trigger on:

- **Build conda packages**: When pushing to `develop` branch or creating version tags (`v*`)
- **Test channel upload**: When pushing to `develop` branch
- **Production channel upload**: When creating version tags (e.g., `v1.0.0`)

## Package Installation

After publishing, users can install your package via:

### From your Anaconda.org channel
```bash
# Using conda
conda install -c YOUR_USERNAME cvannotate

# Using mamba
mamba install -c YOUR_USERNAME cvannotate
```

### From test channel (development)
```bash
conda install -c YOUR_USERNAME/label/test cvannotate
```

## Testing the Setup

### 1. Test Local Build
```bash
./build-conda.sh
conda install --use-local cvannotate
cvannotate --help
```

### 2. Test Development Workflow
```bash
git push origin develop
# Check GitHub Actions tab for conda build and test upload
```

### 3. Test Production Release
```bash
git tag v0.1.1
git push origin v0.1.1
# Check GitHub Actions tab for conda build and production upload
```

## Multi-Platform Support

The workflow builds conda packages for:
- ✅ **Linux** (ubuntu-latest)
- ✅ **macOS** (macos-latest) 
- ✅ **Windows** (windows-latest)

All packages are built as `noarch: python` for maximum compatibility.

## Conda-Forge Submission (Optional)

For wider distribution, consider submitting to conda-forge:

1. Fork [conda-forge/staged-recipes](https://github.com/conda-forge/staged-recipes)
2. Copy your recipe to `recipes/cvannotate/`
3. Submit a PR to conda-forge
4. Once accepted, packages will be available as:
   ```bash
   conda install -c conda-forge cvannotate
   ```

## Troubleshooting

### Common Issues

1. **Build fails with "conda-build not found"**
   - The workflow automatically installs conda-build
   - For local builds, install with: `conda install conda-build`

2. **Upload fails with authentication error**
   - Check that `ANACONDA_USERNAME` and `ANACONDA_API_TOKEN` are correctly set
   - Verify the API token has upload permissions

3. **Package not found after upload**
   - Check the upload logs for any errors
   - Verify the channel name matches your username
   - Allow some time for indexing (up to 15 minutes)

4. **Version conflicts**
   - Ensure the version in `pyproject.toml` matches the git tag
   - Use semantic versioning (e.g., `v1.0.0`)

### Debug Commands

```bash
# Check conda-build output
conda-build conda-recipe/ --output

# Test package locally
conda-build conda-recipe/
conda install --use-local cvannotate

# Check anaconda.org uploads
anaconda show YOUR_USERNAME/cvannotate
```

## Next Steps

1. **Configure Secrets**: Add the required secrets to your repository
2. **Create Environments**: Set up the conda-test and conda-production environments  
3. **Test Build**: Run a test build with `./build-conda.sh`
4. **Test Workflow**: Push to develop branch to test the CI/CD pipeline
5. **Create Release**: Tag a version to test production publishing

## Files Modified

- ✅ `.github/workflows/ci-cd.yml` - Added conda build and publishing jobs
- ✅ `conda-recipe/meta.yaml` - Updated for production builds
- ✅ `build-conda.sh` - Enhanced build script
- ✅ `CONDA-GITHUB-ACTIONS-SETUP.md` - This documentation file

The implementation is complete and ready for testing once the GitHub secrets and environments are configured!
