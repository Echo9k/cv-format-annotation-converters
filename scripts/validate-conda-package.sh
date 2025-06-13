#!/bin/bash

# Test script to validate conda package
set -e

PACKAGE_FILE="dist-conda/noarch/cvannotate-0.1.0-py_0.conda"

echo "🔍 Validating conda package: $PACKAGE_FILE"

# Check if file exists
if [[ ! -f "$PACKAGE_FILE" ]]; then
    echo "❌ Package file not found: $PACKAGE_FILE"
    exit 1
fi

# Check file size
FILE_SIZE=$(stat -c%s "$PACKAGE_FILE" 2>/dev/null || stat -f%z "$PACKAGE_FILE" 2>/dev/null || echo "0")
echo "📦 Package size: $FILE_SIZE bytes"

if [[ "$FILE_SIZE" -lt 1000 ]]; then
    echo "❌ Package file is too small, likely corrupted"
    exit 1
fi

# Check file type
FILE_TYPE=$(file "$PACKAGE_FILE")
echo "📄 File type: $FILE_TYPE"

if [[ ! "$FILE_TYPE" == *"Zip archive"* ]]; then
    echo "❌ Package is not a valid zip archive"
    exit 1
fi

# Try to extract metadata using python
echo "🔍 Checking package contents..."
python3 -c "
import zipfile
import sys

try:
    with zipfile.ZipFile('$PACKAGE_FILE', 'r') as zf:
        files = zf.namelist()
        print(f'📁 Package contains {len(files)} files')
        
        # Look for metadata files
        metadata_files = [f for f in files if 'info' in f.lower() or 'metadata' in f.lower()]
        if metadata_files:
            print('📋 Metadata files found:')
            for f in metadata_files[:5]:  # Show first 5
                print(f'   - {f}')
        
        # Check for package files
        if any('cvannotate' in f for f in files):
            print('✅ Package contains cvannotate files')
        else:
            print('❌ Package does not contain cvannotate files')
            sys.exit(1)
            
except Exception as e:
    print(f'❌ Error reading package: {e}')
    sys.exit(1)
"

echo "✅ Package validation successful!"
