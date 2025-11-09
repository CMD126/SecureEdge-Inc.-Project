# SecureEdge Inc. - Nginx Deployment Automation

## 1. Synopsis

This PowerShell script provides a fully automated solution for deploying an Nginx web server on a Windows environment. Designed for reliability, it handles everything from dependency checks and installation to final configuration and service verification. The primary use case is to set up a secure and lightweight internal documentation portal, but it can be adapted for any local web hosting needs.

## 2. Key Features

- **Administrator Privileges Check:** Ensures the script is run with the required permissions to modify system files and install services.
- **Automated Nginx Installation:** Detects if Nginx is already installed. If not, it downloads the specified version from the official repository, extracts it, and renames the directory to a clean `C:\nginx`.
- **TLS 1.2 Enforcement:** Forces TLS 1.2 for secure file downloads, aligning with modern security best practices.
- **Dynamic Configuration:** Generates a custom `nginx.conf` file based on predefined PowerShell variables. File paths are automatically formatted with forward slashes for cross-platform compatibility.
- **Local DNS Resolution:** Automatically adds an entry to the `hosts` file to map a custom domain (e.g., `securedge.inc`) to `127.0.0.1`, simplifying local access.
- **Configuration Validation:** Before starting the server, it runs `nginx.exe -t` to validate the syntax of the generated configuration file, preventing start-up failures.
- **Process Management:** Gracefully stops any existing Nginx processes before attempting to start a new instance to avoid port conflicts.
- **Automated Verification:** After deployment, it confirms that the Nginx process is running and provides the direct URL for immediate access.

## 3. Prerequisites

- **Operating System:** Windows Server or a modern Windows Desktop OS.
- **Administrator Privileges:** The script must be executed from a PowerShell session running as an Administrator.
- **`index.html` File:** A valid `index.html` file must be located in the same directory as the `ngixdeployment.ps1` script.

## 4. Configuration

The script's behavior can be customized by modifying the variables at the top of the file.

| Variable          | Default Value                                      | Description                                                                 |
|-------------------|----------------------------------------------------|-----------------------------------------------------------------------------|
| `$SiteDomain`     | `"securedge.inc"`                                  | The local domain name for the documentation portal.                         |
| `$NginxRoot`      | `"C:\nginx"`                                       | The installation directory for Nginx.                                       |
| `$WebRoot`        | `"$NginxRoot\html"`                                | The root directory where website content (e.g., `index.html`) will be served. |
| `$IndexSource`    | `"$PSScriptRoot\index.html"`                       | The path to the source `index.html` file.                                   |
| `$NginxConf`      | `"$NginxRoot\conf\nginx.conf"`                     | The full path to the Nginx configuration file to be generated.              |
| `$NginxVersion`   | `"1.25.3"`                                         | The specific version of Nginx to download.                                  |
| `$NginxUrl`       | `"https://nginx.org/download/nginx-1.25.3.zip"`    | The download URL for the Nginx package. This is built using `$NginxVersion`.|
| `$ZipPath`        | `"$env:TEMP\nginx.zip"`                            | A temporary location for storing the downloaded Nginx zip file.             |

## 5. How to Use

1.  **Prepare `index.html`:** Ensure your main `index.html` file is in the same directory as the deployment script.
2.  **Open PowerShell as Administrator:** Right-click the PowerShell icon and select "Run as Administrator."
3.  **Set Execution Policy (If Required):** To allow the script to run, execute the following command:
    ```powershell
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    ```
4.  **Run the Script:** Navigate to the script's directory and execute it:
    ```powershell
    .\ngixdeployment.ps1
    ```

## 6. Script Breakdown

The script executes the following steps in order:

1.  **Check for Administrator Privileges:** Exits if not running as an admin.
2.  **Verify Nginx Installation:** Checks for `nginx.exe`. If not found, it downloads and installs Nginx.
3.  **Prepare Directories:** Creates the `html` and `logs` directories if they don't exist.
4.  **Copy `index.html`:** Copies the site's main page into the webroot.
5.  **Generate `nginx.conf`:** Creates a new Nginx configuration file with the correct paths and server name.
6.  **Add Local DNS Entry:** Modifies the Windows `hosts` file to resolve the site domain locally.
7.  **Stop Old Nginx Processes:** Ensures a clean start by stopping any running `nginx.exe` instances.
8.  **Validate and Start Nginx:** Tests the configuration and then starts the Nginx service.
9.  **Verify Service Status:** Confirms the `nginx` process is running and prints a success message.

## 7. Verification

After the script completes successfully, you can verify the deployment by:
- **Checking the Output:** The final message in the PowerShell terminal will confirm success and provide the URL.
- **Opening a Web Browser:** Navigate to the URL specified (e.g., `http://securedge.inc`). Your `index.html` page should be displayed.
- **Checking Nginx Logs:** If the site doesn't load, check the `access.log` and `error.log` files in `C:\nginx\logs` for more information.
