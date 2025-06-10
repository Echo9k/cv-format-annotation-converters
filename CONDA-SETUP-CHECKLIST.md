# 📋 Conda/Mamba GitHub Actions Setup Checklist

Use this checklist to complete the setup of automated Conda/Mamba package publishing.

## ✅ Implementation Status

- [x] **GitHub Actions workflow updated** with conda build/publish jobs
- [x] **Conda recipe enhanced** for production builds  
- [x] **Build scripts created** and tested
- [x] **Documentation completed**
- [ ] **GitHub secrets configured** (YOUR ACTION REQUIRED)
- [ ] **GitHub environments created** (YOUR ACTION REQUIRED)
- [ ] **Setup tested** (YOUR ACTION REQUIRED)

## 🔧 Required Actions

### 1. Configure GitHub Secrets

Go to your repository: **Settings → Secrets and variables → Actions**

Add these repository secrets:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `ANACONDA_USERNAME` | Your anaconda.org username | Your account username |
| `ANACONDA_API_TOKEN` | API token with upload permissions | [Get from anaconda.org/account/settings](https://anaconda.org/account/settings) |

**To get your Anaconda API token:**
1. Visit [anaconda.org](https://anaconda.org) and log in
2. Go to Settings → Access  
3. Click "Create Token"
4. Give it a name (e.g., "GitHub Actions")
5. Select permissions: **Allow uploads**
6. Copy the generated token

### 2. Create GitHub Environments

Go to your repository: **Settings → Environments**

Create these environments:

#### Environment: `conda-test`
- **Purpose**: Development builds to test channel
- **Protection rules**: None (optional)
- **Secrets**: Use repository secrets

#### Environment: `conda-production` 
- **Purpose**: Production builds to main channel
- **Protection rules**: 
  - ✅ **Required reviewers** (recommended)
  - ✅ **Deployment branches**: Only protected branches and release tags
  - ✅ **Environment secrets**: Use repository secrets

### 3. Test the Setup

#### Local Testing (Recommended First)
```bash
# Test conda build locally
./test-conda-setup.sh

# If successful, test manual build
./build-conda.sh
conda install --use-local cvannotate
cvannotate --help
```

#### CI/CD Testing

**Test Development Workflow:**
```bash
# Make a small change and push to develop
git checkout develop
echo "# Test comment" >> README.md
git add README.md
git commit -m "Test conda CI/CD workflow"
git push origin develop
```

**Check Results:**
- Go to **Actions** tab in GitHub
- Verify `build-conda` job runs successfully
- Verify `publish-conda-test` job uploads to test channel
- Test installation: `conda install -c YOUR_USERNAME/label/test cvannotate`

**Test Production Workflow:**
```bash
# Create and push a version tag
git tag v0.1.1
git push origin v0.1.1
```

**Check Results:**
- Verify all jobs run successfully
- Verify package published to main channel
- Test installation: `conda install -c YOUR_USERNAME cvannotate`
- Verify GitHub release created

## 🎯 Success Criteria

When setup is complete, you should have:

- ✅ **Packages building** on Linux, macOS, and Windows
- ✅ **Test packages** available at: `conda install -c YOUR_USERNAME/label/test cvannotate`
- ✅ **Production packages** available at: `conda install -c YOUR_USERNAME cvannotate`
- ✅ **GitHub releases** created automatically for version tags
- ✅ **Both PyPI and Conda** distribution working

## 🚨 Troubleshooting

### Common Issues

**❌ "Context access might be invalid" warnings in workflow**
- These are expected before secrets are configured
- Will resolve once you add the required secrets

**❌ Authentication failed during upload**
- Verify `ANACONDA_USERNAME` matches your exact anaconda.org username
- Verify `ANACONDA_API_TOKEN` has upload permissions
- Check token hasn't expired

**❌ Package not found after upload**
- Check upload logs for errors
- Wait up to 15 minutes for indexing
- Verify channel name: `conda install -c YOUR_EXACT_USERNAME cvannotate`

**❌ Build fails locally**
- Ensure conda-build is installed: `conda install conda-build`
- Check conda recipe syntax: `conda-build conda-recipe/ --check`

### Debug Commands

```bash
# Check conda-build works
conda-build conda-recipe/ --output

# Test recipe syntax
conda-build conda-recipe/ --check

# Check anaconda.org packages
anaconda show YOUR_USERNAME/cvannotate

# List your channels
anaconda show YOUR_USERNAME
```

## 📞 Need Help?

If you encounter issues:

1. **Check the logs** in GitHub Actions for detailed error messages
2. **Run local tests** first: `./test-conda-setup.sh`
3. **Verify secrets** are correctly named and have proper permissions
4. **Check documentation**: 
   - `CONDA-GITHUB-ACTIONS-SETUP.md` - Complete setup guide
   - `CONDA-IMPLEMENTATION-SUMMARY.md` - Technical details

## 🎉 Completion

Once all items are checked off:

✅ Your package will be automatically published to both PyPI and Anaconda.org  
✅ Users can install via `pip`, `conda`, or `mamba`  
✅ You have professional-grade package distribution  

**Congratulations! You now have complete Python package ecosystem coverage! 🚀**

---

**Quick Start:**
1. Add secrets → 2. Create environments → 3. Run `./test-conda-setup.sh` → 4. Push to develop → 5. Create release tag
