# CLI Build Scripts for PyOrbbec SDK

This repository contains PowerShell scripts for installing build tools and cloning the PyOrbbec SDK repository.

## Prerequisites

- Windows 10 or later
- PowerShell 5.1 or later

## Usage

**WARNING!** In order to run the scripts you need to run PowerShell as Administrator and enable unrestricted script execution. Generally, this is VERY unsafe and has to be done in a controlled environment.

Before proceeding, run the following command to enable unrestricted script execution:
```powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
```

1. Clone the repository:
   ```powershell
   git clone https://github.com/BobIllumine/win-pyorbbecsdk-install.git
   ```
   Or download the zip file and extract it.
2. Navigate to the repository directory:
   ```powershell
   cd win-pyorbbecsdk-install
   ```
3. Run the script to install build tools and clone the PyOrbbec SDK repository:
   ```powershell
   .\install_build_tools.ps1
   ```
4. Run the script to install the PyOrbbec SDK repository:
   ```powershell
   .\install_pyorbbecsdk.ps1
   ```
5. Voila! Now you can test the PyOrbbec SDK using the python scripts in the pyorbbecsdk repository.
    ```powershell
    cd pyorbbecsdk
    python examples/depth_viewer.py
    ```
