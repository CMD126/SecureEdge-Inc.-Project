<#
.SYNOPSIS
  SecureEdge Inc. - Internal Documentation Portal Deployment Script (Windows)
  Date: 06/11/2025
  Description:
    - Checks if Nginx is installed on the system.
    - Downloads and installs Nginx if it is not present.
    - Creates the web directory structure.
    - Copies the provided index.html file.
    - Configures and starts the Nginx web server.
#>

# ---------------------------
# Check for Administrative Privileges
# ---------------------------
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit 1
}

# ---------------------------
# Configuration Variables
# ---------------------------
$SiteDomain   = "securedge.inc"
$NginxRoot    = "C:\nginx"
$WebRoot      = "$NginxRoot\html"
$IndexSource  = "$PSScriptRoot\index.html"
$NginxConf    = "$NginxRoot\conf\nginx.conf"
$NginxVersion = "1.25.3"
$NginxUrl     = "https://nginx.org/download/nginx-$($NginxVersion).zip"
$ZipPath      = "$env:TEMP\nginx.zip"

Write-Host "`n=== SecureEdge Deployment Started ===`n" -ForegroundColor Cyan

# ---------------------------
# Step 1: Verify Nginx Installation
# ---------------------------
if (!(Test-Path "$NginxRoot\nginx.exe")) {
    Write-Host "Nginx not found. Downloading version $NginxVersion..." -ForegroundColor Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Invoke-WebRequest -Uri $NginxUrl -OutFile $ZipPath
    Expand-Archive -Path $ZipPath -DestinationPath "C:\" -Force

    $Extracted = Get-ChildItem "C:\" | Where-Object { $_.Name -like "nginx-*" } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($Extracted -and (Test-Path "C:\$($Extracted.Name)\nginx.exe")) {
        Rename-Item -Path "C:\$($Extracted.Name)" -NewName "nginx" -Force
        Write-Host "Nginx successfully installed at C:\nginx" -ForegroundColor Green
    } else {
        Write-Host "Failed to locate extracted Nginx folder." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Nginx is already installed." -ForegroundColor Green
}

# ---------------------------
# Step 2: Prepare Directories
# ---------------------------
if (!(Test-Path $WebRoot)) { New-Item -ItemType Directory -Path $WebRoot -Force | Out-Null }
if (!(Test-Path "$NginxRoot\logs")) { New-Item -ItemType Directory -Path "$NginxRoot\logs" -Force | Out-Null }

# ---------------------------
# Step 3: Copy index.html
# ---------------------------
if (Test-Path $IndexSource) {
    Copy-Item $IndexSource -Destination "$WebRoot\index.html" -Force
    Write-Host "index.html copied to $WebRoot" -ForegroundColor Green
} else {
    Write-Host "index.html not found in script folder." -ForegroundColor Red
    exit 1
}

# ---------------------------
# Step 4: Configure Nginx
# ---------------------------
Write-Host "Generating nginx.conf..." -ForegroundColor Cyan
$NginxWebRoot = $WebRoot.Replace('\', '/')

$Config = @"
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile      on;
    keepalive_timeout 65;

    server {
        listen       80;
        server_name  $SiteDomain;
        root         "$NginxWebRoot";
        index        index.html;

        access_log   logs/access.log;
        error_log    logs/error.log;

        location / {
            autoindex on;
        }
    }
}
"@

Set-Content -Path $NginxConf -Value $Config -Encoding ASCII
Write-Host "Configuration file created at $NginxConf" -ForegroundColor Green

# ---------------------------
# Step 5: Add Local DNS Entry
# ---------------------------
$HostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$HostsEntry = "127.0.0.1`t$SiteDomain"
attrib -r $HostsPath -ErrorAction SilentlyContinue
if (-not (Select-String -Path $HostsPath -Pattern $SiteDomain -Quiet)) {
    Add-Content -Path $HostsPath -Value $HostsEntry
    Write-Host "Added local hosts entry for $SiteDomain" -ForegroundColor Yellow
}

# ---------------------------
# Step 6: Stop Old Nginx
# ---------------------------
$proc = Get-Process nginx -ErrorAction SilentlyContinue
if ($proc) {
    Write-Host "Stopping old Nginx process..." -ForegroundColor Yellow
    Push-Location $NginxRoot
    .\nginx.exe -s stop
    Pop-Location
    Start-Sleep -Seconds 2
}

# ---------------------------
# Step 7: Validate & Start
# ---------------------------
Push-Location $NginxRoot
$TestResult = (.\nginx.exe -t 2>&1)
if ($LASTEXITCODE -ne 0) {
    Write-Host "Nginx configuration test failed:" -ForegroundColor Red
    Write-Host $TestResult
    Pop-Location
    exit 1
}
Write-Host "Configuration test passed." -ForegroundColor Green

Write-Host "Starting Nginx..." -ForegroundColor Cyan
Start-Process -FilePath ".\nginx.exe"
Pop-Location
Start-Sleep -Seconds 2

# ---------------------------
# Step 8: Verify
# ---------------------------
if (Get-Process nginx -ErrorAction SilentlyContinue) {
    Write-Host "`nDeployment successful!" -ForegroundColor Green
    Write-Host "Access the portal at: http://$SiteDomain`n" -ForegroundColor Cyan
} else {
    Write-Host "Nginx did not start properly. Check logs in $NginxRoot\logs" -ForegroundColor Red
}

Write-Host "-----------------------------------------------------------"
Write-Host " SecureEdge Inc. - Documentation Portal Deployed Successfully"
Write-Host "-----------------------------------------------------------"
