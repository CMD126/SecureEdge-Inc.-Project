# SecureEdge Inc. - Internal Documentation Portal Deployment Script

## Synopsis

This PowerShell script automates the deployment of an internal documentation portal using Nginx on a Windows environment. It is designed to be a one-stop solution for setting up a local web server, ensuring that all necessary dependencies are handled and configurations are applied seamlessly. The script checks for an existing Nginx installation, downloads and installs it if necessary, and configures it to serve a local website.

## Features

- **Automated Nginx Installation:** The script detects if Nginx is installed and, if not, downloads and extracts the latest stable version from the official Nginx website.
- **Directory Structure Creation:** Automatically creates the required webroot directory for hosting the documentation files.
- **Customizable Configuration:** Key settings such as the site domain, installation paths, and Nginx configuration are managed through easily accessible variables.
- **Local DNS Resolution:** The script adds an entry to the local `hosts` file, allowing you to access the portal using a custom domain name (`docs.secureedge.local` by default).
- **Service Verification:** After starting the Nginx service, the script verifies that the process is running to confirm a successful deployment.

## Prerequisites

- **Windows Operating System:** This script is designed for Windows and uses PowerShell for execution.
- **Execution Policy:** You may need to set the PowerShell execution policy to allow script execution. You can do this by running `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` in your PowerShell session.
- **`index.html` File:** An `index.html` file must be present in the same directory as the script.

## Configuration

The script includes a configuration section at the top, allowing you to customize the deployment to your needs. The following variables are available:

| Variable          | Default Value                        | Description                                          |
|-------------------|--------------------------------------|------------------------------------------------------|
| `$SiteDomain`     | `"docs.secureedge.local"`            | The internal domain name for the documentation portal. |
| `$NginxRoot`      | `"C:\nginx"`                         | The directory where Nginx will be installed.         |
| `$WebRoot`        | `"$NginxRoot\html"`                  | The directory where the website files will be hosted.  |
| `$IndexSource`    | `"$PSScriptRoot\index.html"`         | The location of the `index.html` file to be copied.  |
| `$NginxConf`      | `"$NginxRoot\conf\nginx.conf"`       | The path to the Nginx configuration file.            |
| `$NginxUrl`       | `"https://nginx.org/download/nginx-1.26.2.zip"` | The URL for the Nginx Windows package.             |
| `$ZipPath`        | `"$env:TEMP\nginx.zip"`              | The temporary path for the downloaded zip file.      |

## Usage

1.  **Place `index.html`:** Ensure that you have an `index.html` file in the same directory as the `ngixdeployment.ps1` script.
2.  **Run the Script:** Open a PowerShell terminal, navigate to the directory containing the script, and execute it:

    ```powershell
    .\ngixdeployment.ps1
    ```

3.  **Administrator Privileges:** The script will require administrator privileges to modify the `hosts` file and install software.

## Verification

After the script has completed, you can verify the deployment by opening a web browser and navigating to the site domain you configured (by default, `http://docs.secureedge.local`). If the deployment was successful, you will see the content of your `index.html` file.
