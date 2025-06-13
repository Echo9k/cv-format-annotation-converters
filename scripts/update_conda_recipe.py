#!/usr/bin/env python3
"""
Script to automatically update conda recipe with PyPI package information.
This script fetches the latest package information from PyPI or test-PyPI
and updates the conda recipe meta.yaml file accordingly.
"""

import json
import sys
import argparse
from pathlib import Path
from urllib.request import urlopen
from urllib.error import HTTPError
import yaml


def get_pypi_info(package_name: str, version: str = None, use_test_pypi: bool = False) -> dict:
    """
    Fetch package information from PyPI or test-PyPI.
    
    Args:
        package_name: Name of the package
        version: Specific version (if None, gets latest)
        use_test_pypi: Whether to use test-PyPI instead of main PyPI
        
    Returns:
        Dictionary with package information including URL and SHA256
    """
    base_url = "https://test.pypi.org" if use_test_pypi else "https://pypi.org"
    
    if version:
        url = f"{base_url}/pypi/{package_name}/{version}/json"
    else:
        url = f"{base_url}/pypi/{package_name}/json"
    
    try:
        with urlopen(url) as response:
            data = json.loads(response.read().decode())
            
        # Get the source distribution (sdist)
        for release_file in data['urls']:
            if release_file['packagetype'] == 'sdist':
                return {
                    'version': data['info']['version'],
                    'url': release_file['url'],
                    'sha256': release_file['digests']['sha256'],
                    'filename': release_file['filename']
                }
        
        raise ValueError(f"No source distribution found for {package_name}")
        
    except HTTPError as e:
        if e.code == 404:
            raise ValueError(f"Package {package_name} not found on {'test-' if use_test_pypi else ''}PyPI")
        else:
            raise ValueError(f"HTTP error {e.code} when fetching package info")


def update_conda_recipe(recipe_path: Path, package_info: dict, package_name: str) -> None:
    """
    Update the conda recipe meta.yaml file with new package information.
    
    Args:
        recipe_path: Path to the meta.yaml file
        package_info: Package information from PyPI
        package_name: Name of the package
    """
    # Read the current meta.yaml
    with open(recipe_path, 'r') as f:
        content = f.read()
    
    # Update version
    old_version_line = '{% set version = "1.0.0" %}'
    new_version_line = '{{% set version = "{}" %}}'.format(package_info["version"])
    content = content.replace(old_version_line, new_version_line)
    
    # Update URL (handle both test-pypi and regular pypi patterns)
    if 'test-files.pythonhosted.org' in package_info['url']:
        # Extract the path components for test-pypi
        url_parts = package_info['url'].split('/')
        path_part = '/'.join(url_parts[5:])  # Skip https://test-files.pythonhosted.org/packages/
        new_url = f"https://test-files.pythonhosted.org/packages/{path_part}"
    else:
        # Regular PyPI URL pattern
        new_url = f"https://pypi.io/packages/source/{{{{ name[0] }}}}/{{{{ name }}}}/{package_info['filename']}"
    
    # Replace URL line
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if line.strip().startswith('url:'):
            lines[i] = f"  url: {new_url}"
            break
    
    # Replace SHA256 line
    for i, line in enumerate(lines):
        if line.strip().startswith('sha256:'):
            lines[i] = f"  sha256: {package_info['sha256']}"
            break
    
    # Write back the updated content
    content = '\n'.join(lines)
    with open(recipe_path, 'w') as f:
        f.write(content)


def main():
    parser = argparse.ArgumentParser(description='Update conda recipe with PyPI package information')
    parser.add_argument('package_name', help='Name of the package')
    parser.add_argument('--version', help='Specific version (default: latest)')
    parser.add_argument('--test-pypi', action='store_true', help='Use test-PyPI instead of main PyPI')
    parser.add_argument('--recipe-path', type=Path, default='conda-recipe/meta.yaml',
                       help='Path to meta.yaml file (default: conda-recipe/meta.yaml)')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be updated without making changes')
    
    args = parser.parse_args()
    
    try:
        # Fetch package information
        print(f"Fetching package information for {args.package_name}...")
        package_info = get_pypi_info(args.package_name, args.version, args.test_pypi)
        
        print(f"Package: {args.package_name}")
        print(f"Version: {package_info['version']}")
        print(f"URL: {package_info['url']}")
        print(f"SHA256: {package_info['sha256']}")
        print(f"Filename: {package_info['filename']}")
        
        if args.dry_run:
            print("\n--dry-run mode: No files will be modified")
            return
        
        # Update the recipe
        if not args.recipe_path.exists():
            print(f"Error: Recipe file {args.recipe_path} not found")
            sys.exit(1)
        
        print(f"\nUpdating {args.recipe_path}...")
        update_conda_recipe(args.recipe_path, package_info, args.package_name)
        print("✅ Recipe updated successfully!")
        
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
