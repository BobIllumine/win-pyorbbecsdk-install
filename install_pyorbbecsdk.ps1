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
$cmakeArgs = @(
    '-G', '"Visual Studio 17 2022"',
    '-A', 'x64',
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
