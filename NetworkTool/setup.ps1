# Script to check for and install dependencies for the NetworkTool on Windows.

# --- Configuration ---
$pythonVersion = "3.11.5" # A specific, stable version of Python
$pythonDownloadUrl = "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-amd64.exe"
$installerPath = Join-Path $env:TEMP "python-installer.exe"

# --- Function to Install Python ---
function Install-Python {
    Write-Host "Python not found. Attempting to download and install version $pythonVersion..."
    
    # Force TLS 1.2 for security
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    # Download the Python installer
    try {
        Write-Host "Downloading from $pythonDownloadUrl..."
        Invoke-WebRequest -Uri $pythonDownloadUrl -OutFile $installerPath -ErrorAction Stop
        Write-Host "Download complete."
    } catch {
        Write-Error "Failed to download the Python installer. Please check your internet connection."
        Write-Error "Details: $_"
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    # Install Python silently
    try {
        Write-Host "Starting silent installation... (This may take a few minutes)"
        # Arguments: /quiet -> silent mode, InstallAllUsers=1 -> install for all users, PrependPath=1 -> add to PATH
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait -PassThru
        
        if ($installProcess.ExitCode -ne 0) {
            Throw "Installer exited with a non-zero exit code: $($installProcess.ExitCode)"
        }
        
        Write-Host "Python installation completed successfully." -ForegroundColor Green
    } catch {
        Write-Error "An error occurred during Python installation."
        Write-Error "Details: $_"
        Read-Host "Press Enter to exit"
        exit 1
    } finally {
        # Clean up the installer
        if (Test-Path $installerPath) {
            Remove-Item $installerPath -Force
        }
    }
    
    Write-Host "IMPORTANT: The script has installed Python. Please close this window and run the script again to install the required dependencies." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 0
}

# --- Main Script Logic ---

# Attempt to find the Python executable
$pythonExe = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $pythonExe) {
    $pythonExe = Get-Command python -ErrorAction SilentlyContinue
}

# Check if Python was found
if ($pythonExe) {
    Write-Host "Python is already installed: $($pythonExe.Source)"
    
    # Set the execution policy for the current process to allow script execution
    try {
        Set-ExecutionPolicy RemoteSigned -Scope Process -Force -ErrorAction Stop
    } catch {
        Write-Warning "Could not set the execution policy. Dependency installation may fail."
    }

    # Install the psutil dependency using pip
    Write-Host "Installing 'psutil' dependency..."
    $pipProcess = Start-Process -FilePath $pythonExe.Source -ArgumentList "-m", "pip", "install", "psutil" -Wait -PassThru -NoNewWindow
    
    if ($pipProcess.ExitCode -eq 0) {
        Write-Host "Successfully installed 'psutil' dependency." -ForegroundColor Green
    } else {
        Write-Error "An error occurred while installing 'psutil'. Please check your Python/pip installation."
    }
} else {
    # If Python is not found, run the installation function
    Install-Python
}

Write-Host "Setup complete."
Read-Host "Press Enter to exit"
