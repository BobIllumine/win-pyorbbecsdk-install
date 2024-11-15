param (
    [string]$InstallPath = (Join-Path $PWD.Path "dependencies")
)

# Create installation directory
New-Item -ItemType Directory -Path $InstallPath -Force
Set-Location -Path $InstallPath

# Function to compare version numbers
function Compare-Versions {
    param (
        [string]$current,
        [string]$required
    )
    $currentVersion = [version]($current -replace '[^\d\.].*$')
    $requiredVersion = [version]$required
    return $currentVersion -ge $requiredVersion
}

# Required minimum versions
$minGitVersion = "2.44.0"
$minPythonVersion = "3.11.0"
$minCMakeVersion = "3.28.0"

# Check and install Git if needed
try {
    $currentGitVersion = (git --version).Replace('git version ', '')
    if (Compare-Versions -current $currentGitVersion -required $minGitVersion) {
        Write-Host "Git $currentGitVersion is already installed and meets minimum version requirement." -ForegroundColor Green
    } else {
        throw "Git needs updating"
    }
} catch {
    Write-Host "Downloading Git..." -ForegroundColor Cyan
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.46.1.windows.1/Git-2.46.1-64-bit.exe"
    $gitInstaller = Join-Path $InstallPath "git_installer.exe"
    Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller

    Write-Host "Installing Git..." -ForegroundColor Cyan
    $gitArgs = @(
        '/VERYSILENT',
        '/NORESTART',
        '/NOCANCEL',
        '/SP-',
        '/CLOSEAPPLICATIONS',
        '/RESTARTAPPLICATIONS',
        '/COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"'
    )
    Start-Process -FilePath $gitInstaller -ArgumentList $gitArgs -Wait
}

# Check and install Python if needed
try {
    $currentPythonVersion = (python --version).Replace('Python ', '')
    if (Compare-Versions -current $currentPythonVersion -required $minPythonVersion) {
        Write-Host "Python $currentPythonVersion is already installed and meets minimum version requirement." -ForegroundColor Green
    } else {
        throw "Python needs updating"
    }
} catch {
    Write-Host "Downloading Python..." -ForegroundColor Cyan
    $pythonUrl = "https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe"
    $pythonInstaller = Join-Path $InstallPath "python_installer.exe"
    Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller

    Write-Host "Installing Python..." -ForegroundColor Cyan
    $pythonArgs = @(
        '/quiet',
        'InstallAllUsers=1',
        'PrependPath=1',
        'Include_test=0'
    )
    Start-Process -FilePath $pythonInstaller -ArgumentList $pythonArgs -Wait
}

# Check and install CMake if needed
try {
    $currentCMakeVersion = (cmake --version).Split("`n")[0].Replace('cmake version ', '')
    if (Compare-Versions -current $currentCMakeVersion -required $minCMakeVersion) {
        Write-Host "CMake $currentCMakeVersion is already installed and meets minimum version requirement." -ForegroundColor Green
    } else {
        throw "CMake needs updating"
    }
} catch {
    Write-Host "Downloading CMake..." -ForegroundColor Cyan
    $cmakeUrl = "https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3-windows-x86_64.msi"
    $cmakeInstaller = Join-Path $InstallPath "cmake_installer.msi"
    Invoke-WebRequest -Uri $cmakeUrl -OutFile $cmakeInstaller

    Write-Host "Installing CMake..." -ForegroundColor Cyan
    $cmakeArgs = @(
        '/i',
        $cmakeInstaller,
        '/quiet',
        '/norestart',
        'ADD_CMAKE_TO_PATH=System'
    )
    Start-Process -FilePath "msiexec.exe" -ArgumentList $cmakeArgs -Wait
}

# Check if Visual Studio Build Tools is already installed
$vsInstalled = $false
$defaultVSPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools"
$defaultVSPath2 = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community"

if (Test-Path $defaultVSPath) {
    Write-Host "Visual Studio Build Tools is already installed at: $defaultVSPath" -ForegroundColor Green
    $vsInstalled = $true
    $vsInstallPath = $defaultVSPath
} elseif (Test-Path $defaultVSPath2) {
    Write-Host "Visual Studio Community is already installed at: $defaultVSPath2" -ForegroundColor Green
    $vsInstalled = $true
    $vsInstallPath = $defaultVSPath2
}

if (-not $vsInstalled) {
    # Download VS Build Tools installer
    Write-Host "Downloading Visual Studio Build Tools installer..." -ForegroundColor Cyan
    $vsInstallPath = $defaultVSPath  # Use default installation path
    $exePath = Join-Path $InstallPath "vs_buildtools.exe"
    Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_BuildTools.exe' -UseBasicParsing -OutFile $exePath

    # Install VS Build Tools
    Write-Host "Installing Visual Studio Build Tools..." -ForegroundColor Cyan
    $arguments = @(
        '--quiet',
        '--wait',
        '--norestart',
        '--nocache',
        '--add', 'Microsoft.VisualStudio.Workload.VCTools',
        '--add', 'Microsoft.VisualStudio.Component.Windows11SDK.22621',
        '--add', 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
        '--includeRecommended'
    )

    # Start installation
    $process = Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -PassThru -NoNewWindow

    # Check VS Build Tools installation result
    if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
        Write-Host "Visual Studio Build Tools installation completed successfully" -ForegroundColor Green
        
        # Add to PATH if not already present
        # $vsPath = Join-Path $vsInstallPath "Common7\Tools"
        # if ($env:Path -notlike "*$vsPath*") {
        #     [Environment]::SetEnvironmentVariable(
        #         'Path',
        #         "$([Environment]::GetEnvironmentVariable('Path', 'Machine'));$vsPath",
        #         'Machine'
        #     )
        # }
    } else {
        Write-Host "Visual Studio Build Tools installation completed with exit code: $($process.ExitCode)" -ForegroundColor Yellow
        Write-Host "This is normal if installation requires a reboot or if Build Tools are already installed." -ForegroundColor Yellow
    }
}

# Refresh environment variables without requiring restart
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verify all installations
Write-Host "`nVerifying installations..." -ForegroundColor Cyan

try {
    $gitVersion = git --version
    Write-Host "Git Version: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "Git verification failed. You may need to restart your terminal." -ForegroundColor Red
}

try {
    $pythonVersion = python --version
    Write-Host "Python Version: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Python verification failed. You may need to restart your terminal." -ForegroundColor Red
}

try {
    $cmakeVersion = cmake --version
    Write-Host "CMake Version: $cmakeVersion" -ForegroundColor Green
} catch {
    Write-Host "CMake verification failed. You may need to restart your terminal." -ForegroundColor Red
}

Write-Host "`nNote: You may need to restart your terminal or computer for all PATH changes to take effect." -ForegroundColor Yellow

