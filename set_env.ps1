# Get the directory where the script is located
$CURR_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# Add the install/lib directory to PYTHONPATH
$env:PYTHONPATH = "$CURR_DIR\install\lib;$env:PYTHONPATH"