$INSTALL_PATH = Join-Path $PWD.Path "pyorbbecsdk"

. .\set_env.ps1

Write-Host "Installing pybind11-stubgen..." -ForegroundColor Cyan
pip install pybind11-stubgen

Write-Host "Generating stubs..." -ForegroundColor Cyan
pybind11-stubgen setup.py -o ($INSTALL_PATH + "\stubs")