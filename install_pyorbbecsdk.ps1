# Create working directory
New-Item -ItemType Directory -Path 'C:\software\pyorbbecsdk' -Force
Set-Location -Path 'C:\software\pyorbbecsdk'

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
    '-G', 'Visual Studio 17 2022',
    '-A', 'x64',
    '..'
)
Start-Process -FilePath 'cmake' -ArgumentList $cmakeArgs -NoNewWindow -Wait

# Build the project
Write-Host "Building project..." -ForegroundColor Cyan
$buildArgs = @(
    '--build', '.',
    '--config', 'Release'
)
Start-Process -FilePath 'cmake' -ArgumentList $buildArgs -NoNewWindow -Wait

# Install the built package
Write-Host "Installing built package..." -ForegroundColor Cyan
$installArgs = @(
    '--build', '.',
    '--target', 'INSTALL',
    '--config', 'Release'
)
Start-Process -FilePath 'cmake' -ArgumentList $installArgs -NoNewWindow -Wait

# Copy necessary files to examples directory
Write-Host "Copying files to examples directory..." -ForegroundColor Cyan
Copy-Item -Path "install/lib/*" -Destination "../examples/" -Recurse -Force

# Return to original directory
Set-Location -Path '..'

Write-Host "`nBuild completed. You can now run examples from the 'examples' directory." -ForegroundColor Green
Write-Host "Example command: python examples/ColorViewer.py" -ForegroundColor Yellow
