<#
.SYNOPSIS
  SecureEdge Inc. - Internal Documentation Portal Deployment Script
  Date: 06/11/2025
  Description:
    - Checks if Nginx is installed on the system.
    - Downloads and installs Nginx if it is not present.
    - Creates the web directory structure.
    - Copies the provided index.html file.
    - Configures and starts the Nginx web server.
#>

# ---------------------------
# Configuration Variables
# ---------------------------
$SiteDomain = "docs.secureedge.local"           # Internal domain name
$NginxRoot = "C:\nginx"                         # Nginx installation directory
$WebRoot = "$NginxRoot\html"                    # Directory to host the website files
$IndexSource = "$PSScriptRoot\index.html"       # Location of the provided HTML file
$NginxConf = "$NginxRoot\conf\nginx.conf"       # Path to Nginx configuration file
$NginxUrl = "https://nginx.org/download/nginx-1.26.2.zip"  # Official Nginx Windows package
$ZipPath = "$env:TEMP\nginx.zip"                # Temporary path for the downloaded zip file

Write-Host "Checking Nginx installation status..." -ForegroundColor Cyan

# ---------------------------
# Step 1: Verify Nginx Installation
# ---------------------------
if (!(Test-Path "$NginxRoot\nginx.exe")) {
    Write-Host "Nginx not found. Downloading and installing..." -ForegroundColor Yellow

    # Download the Nginx package
    Invoke-WebRequest -Uri $NginxUrl -OutFile $ZipPath

    # Extract the zip archive to C:\
    Expand-Archive -Path $ZipPath -DestinationPath "C:\"

    # Detect the extracted folder (e.g., nginx-1.26.2) and rename it to 'nginx'
    $Extracted = Get-ChildItem "C:\" | Where-Object { $_.Name -like "nginx-*" } | Select-Object -First 1
    Rename-Item -Path "C:\$($Extracted.Name)" -NewName "nginx"

    Write-Host "Nginx successfully installed at C:\nginx" -ForegroundColor Green
} else {
    Write-Host "Nginx is already installed." -ForegroundColor Green
}

# ---------------------------
# Step 2: Create Web Directory
# ---------------------------
if (!(Test-Path $WebRoot)) {
    Write-Host "Creating web root directory at $WebRoot..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $WebRoot -Force | Out-Null
}

# ---------------------------
# Step 3: Copy index.html
# ---------------------------
if (Test-Path $IndexSource) {
    Copy-Item $IndexSource -Destination "$WebRoot\index.html" -Force
    Write-Host "index.html copied to $WebRoot" -ForegroundColor Green
} else {
    Write-Host "index.html file not found in the script directory." -ForegroundColor Red
    exit 1
}

# ---------------------------
# Step 4: Configure Nginx
# ---------------------------
Write-Host "Creating Nginx configuration file..." -ForegroundColor Cyan

$Config = @"
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  $SiteDomain;
        root         $WebRoot;
        index        index.html;

        access_log  logs/access.log;
        error_log   logs/error.log;

        location / {
            try_files \$uri \$uri/ =404;
        }
    }
}
"@

Set-Content -Path $NginxConf -Value $Config -Encoding UTF8
Write-Host "Nginx configuration file created successfully." -ForegroundColor Green

# ---------------------------
# Step 5: Add Local DNS Entry
# ---------------------------
$HostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$HostsEntry = "127.0.0.1`t$SiteDomain"

if (-not (Select-String -Path $HostsPath -Pattern $SiteDomain -Quiet)) {
    Add-Content -Path $HostsPath -Value $HostsEntry
    Write-Host "Added local hosts entry: $HostsEntry" -ForegroundColor Yellow
}

# ---------------------------
# Step 6: Start Nginx
# ---------------------------
Write-Host "Starting Nginx service..." -ForegroundColor Cyan
Start-Process -FilePath "$NginxRoot\nginx.exe"

Start-Sleep -Seconds 3

# ---------------------------
# Step 7: Verify Operation
# ---------------------------
$nginxProc = Get-Process nginx -ErrorAction SilentlyContinue
if ($nginxProc) {
    Write-Host "Deployment successful. Access the portal at: http://$SiteDomain" -ForegroundColor Green
} else {
    Write-Host "Failed to start Nginx. Please check manually." -ForegroundColor Red
}

Write-Host "----------------------------------------------------------"
Write-Host "SecureEdge Inc. - Internal Documentation Portal Deployment"
Write-Host "----------------------------------------------------------"
