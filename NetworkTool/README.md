# SECURITY EDGE NETWORK TOOL

This is a single-file, cross-platform network utility script written in Python. It provides a simple, interactive command-line menu to perform common network tasks. The tool is designed to be easy to use and requires minimal dependencies.

## Features

- **Cross-Platform:** Works on Windows, macOS, and Linux.
- **Interactive Menu:** An easy-to-use menu for selecting different network tasks.
- **Colored Output:** Uses colored terminal output for better readability (with a fallback for unsupported terminals).
- **Concurrent Port Scanning:** Utilizes a thread pool to perform fast TCP port scans.
- **Device Discovery:** Discovers devices on the local network using the ARP table and presents them in a clean, tabulated format.
- **Configurable Ping:** Allows you to specify the number of ping packets to send.
- **Network Traffic Monitoring:** Measures network traffic over a specified duration (requires the `psutil` library).

## Installation and Usage

To avoid conflicts with system-wide packages, it is highly recommended to run this tool in a virtual environment.

### 1. Create and Activate a Virtual Environment

**On macOS and Linux:**

```bash
# Create a virtual environment named 'venv'
python3 -m venv venv

# Activate the environment
source venv/bin/activate
```

**On Windows (Command Prompt or PowerShell):**

```powershell
# Create a virtual environment named 'venv'
python -m venv venv

# Activate the environment
.\\venv\\Scripts\\activate
```

_You will know the environment is active because your shell prompt will change to show `(venv)`._

### 2. Install Optional Dependency (psutil)

The **Measure network traffic** feature (Option 3) requires the `psutil` library. With your virtual environment activated, install it using pip:

```bash
pip install psutil
```
This command will now work safely within the virtual environment.

### 3. Run the Tool

With the virtual environment still active, run the script:

```bash
python3 network_tool.py
```

### 4. Deactivate the Environment

When you are finished using the tool, you can deactivate the virtual environment and return to your normal shell session:

```bash
deactivate
```

### Menu Options

The script provides an interactive menu with the following options:

| Option | Function                  | Description                                                                                                                              |
| :----: | ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
|   1    | **Ping a host**           | Pings a specified host or IP address to check if it's online. You can configure the number of ping packets to send.                      |
|   2    | **Scan open TCP ports**   | Performs a concurrent TCP port scan on a specified host and port range to identify open ports.                                             |
|   3    | **Measure network traffic** | Measures network traffic (bytes sent and received) over a specified duration. Requires `psutil` installed in your virtual environment.     |
|   4    | **Discover devices**      | Discovers devices on the local network by parsing the ARP table and displays a clean list of IP and MAC addresses. May require privileges. |
|   5    | **Exit**                  | Exits the application.                                                                                                                   |
