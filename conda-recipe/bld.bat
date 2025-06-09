@echo off

REM Build script for conda package on Windows
REM This script is executed during the conda build process

REM Install the package using pip
%PYTHON% -m pip install . -vv --no-deps --ignore-installed

REM Verify installation
%PYTHON% -c "import cvannotate; print('CVAnnotate version:', cvannotate.__version__)"

if errorlevel 1 exit 1
