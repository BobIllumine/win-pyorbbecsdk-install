param (
    [string]$InstallPath = (Join-Path $PWD.Path "pyorbbecsdk")
)

# Create working directory
New-Item -ItemType Directory -Path $InstallPath -Force
Set-Location -Path $InstallPath

# Clone the repository
Write-Host "Cloning pyorbbecsdk repository..." -ForegroundColor Cyan
git clone https://github.com/orbbec/pyorbbecsdk.git .

# Install Python dependencies
Write-Host "Installing Python dependencies..." -ForegroundColor Cyan
python -m pip install -r requirements.txt

# Create build directory
Write-Host "Creating build directory..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path 'build' -Force
Set-Location -Path 'build'

# Configure CMake project
Write-Host "Configuring CMake project..." -ForegroundColor Cyan

# Get Python installation path from AppData
$pythonRoot = Join-Path $env:LOCALAPPDATA "Programs\Python\Python311"
if (-not (Test-Path $pythonRoot)) {
    Write-Host "Python installation not found in AppData. Checking system path..." -ForegroundColor Yellow
    $pythonPath = (Get-Command python).Source
    $pythonRoot = Split-Path -Parent (Split-Path -Parent $pythonPath)
}

$pybind11Path = Join-Path $pythonRoot "share\cmake\pybind11"
if (-not (Test-Path $pybind11Path)) {
    Write-Host "pybind11 not found in Python installation. Installing..." -ForegroundColor Yellow
    python -m pip install pybind11
}

$cmakeArgs = @(
    '-G', '"Visual Studio 17 2022"',
    '-A', 'x64',
    '-DBUILD_TESTING=OFF',
    '-DCMAKE_CONFIGURATION_TYPES="Debug;Release;MinSizeRel;RelWithDebInfo"',
    "-DCMAKE_INSTALL_PREFIX=`"$InstallPath`"",
    "-Dpybind11_DIR=`"$pybind11Path`"",
    '..'
)
cmake @cmakeArgs

# Build the project
Write-Host "Building project..." -ForegroundColor Cyan
cmake --build . --config Release

# Install the built package
Write-Host "Installing built package..." -ForegroundColor Cyan
cmake --build . --target INSTALL --config Release

# Copy necessary files to examples directory
Write-Host "Copying files to examples directory..." -ForegroundColor Cyan
if (Test-Path "install/lib") {
    Copy-Item -Path "install/lib/*" -Destination "../examples/" -Recurse -Force
}

# Return to original directory
Set-Location -Path '..'

Write-Host "`nBuild completed. You can now run examples from the 'examples' directory." -ForegroundColor Green
Write-Host "Example command: python examples/ColorViewer.py" -ForegroundColor Yellow
