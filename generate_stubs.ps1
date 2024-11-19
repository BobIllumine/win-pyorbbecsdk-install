# Get Python installation path and version
$pythonPath = (Get-Command python).Source
$pythonVersion = (python --version).Replace('Python ', '').Trim()
$majorMinor = $pythonVersion -replace '^(\d+\.\d+).*','$1'
$sitePackages = Join-Path (Split-Path -Parent (Split-Path -Parent $pythonPath)) "Lib\site-packages"

Write-Host "Python version: $pythonVersion" -ForegroundColor Cyan
Write-Host "Site-packages location: $sitePackages" -ForegroundColor Cyan

# Create temporary directory for stub generation
$tempStubDir = Join-Path $env:TEMP "pyorbbecsdk_stubs"
New-Item -ItemType Directory -Path $tempStubDir -Force | Out-Null

# Install pybind11-stubgen if not already installed
if (-not (Get-Command pybind11-stubgen -ErrorAction SilentlyContinue)) {
    Write-Host "Installing pybind11-stubgen..." -ForegroundColor Cyan
    pip install pybind11-stubgen
}

# Generate stubs
Write-Host "Generating stubs..." -ForegroundColor Cyan
pybind11-stubgen pyorbbecsdk -o $tempStubDir

# Copy stubs to site-packages
$moduleDir = Join-Path $sitePackages "pyorbbecsdk"
$stubsDir = Join-Path $moduleDir "stubs"

if (Test-Path $stubsDir) {
    Write-Host "Removing existing stubs..." -ForegroundColor Yellow
    Remove-Item -Path $stubsDir -Recurse -Force
}

Write-Host "Copying stubs to module directory..." -ForegroundColor Cyan
Copy-Item -Path (Join-Path $tempStubDir "pyorbbecsdk-stubs") -Destination $stubsDir -Recurse -Force

# Clean up temporary directory
Remove-Item -Path $tempStubDir -Recurse -Force

Write-Host "`nStubs have been generated and installed to: $stubsDir" -ForegroundColor Green