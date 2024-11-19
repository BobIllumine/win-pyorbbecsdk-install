# Get the directory where the script is located
$INSTALL_PATH = Join-Path $PWD.Path "pyorbbecsdk"

# Add the install/lib directory to PYTHONPATH
$env:PYTHONPATH = "$INSTALL_PATH\install\lib;$env:PYTHONPATH"