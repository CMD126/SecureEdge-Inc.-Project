#!/usr/bin/env python3
"""
Simple Network tool Designed for Security Edge Inc.

Features:
- Ping a host (works on Windows/macOS/Linux)
- TCP port scan (connect scan)
- Measure network traffic (requires psutil; fallback message if missing)
- Discover devices via ARP (uses `arp -a`)
"""

from __future__ import annotations
import sys
import platform
import subprocess
import socket
import time
import shutil
import re
from concurrent.futures import ThreadPoolExecutor, as_completed

# Try to import psutil; if missing, we'll gracefully degrade.
try:
    import psutil
    _HAS_PSUTIL = True
except Exception:
    _HAS_PSUTIL = False

class NetworkTool:
    # Inner class for ANSI color codes for terminal output.
    class Colors:
        GREEN = '\033[92m'
        RED = '\033[91m'
        YELLOW = '\033[93m'
        BLUE = '\033[94m'
        ENDC = '\033[0m'

    # Inner class to provide a colorless fallback.
    # If colors are disabled, this class is used, and its attributes return empty strings.
    class NoColors:
        def __getattr__(self, name):
            return ""

    def __init__(self):
        # Disable colors on Windows by default as ANSI escape codes are not always supported.
        self.use_colors = sys.platform != "win32"
        self.colors = self.Colors() if self.use_colors else self.NoColors()

    def ping_host(self, host: str, timeout: float = 3.0, count: int = 1) -> bool:
        """
        Pings a host a specified number of times. Uses system ping but is cross-platform.
        Returns True if host responds, False otherwise.
        """
        # Determine the correct ping command based on the operating system.
        system = platform.system().lower()
        if system == "windows":
            # For Windows, '-n' specifies the number of echo requests to send.
            cmd = ["ping", "-n", str(count), host]
        else:
            # For Linux and macOS, '-c' specifies the number of pings.
            cmd = ["ping", "-c", str(count), host]

        try:
            # Execute the ping command.
            # stdout and stderr are redirected to DEVNULL to suppress output.
            # The timeout ensures the command doesn't hang indefinitely.
            # `check=True` raises a CalledProcessError if the command returns a non-zero exit code.
            subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=timeout, check=True)
            return True
        except subprocess.CalledProcessError:
            # This exception is raised if the ping command fails (e.g., host unreachable).
            return False
        except subprocess.TimeoutExpired:
            # This exception is raised if the ping command takes too long.
            return False
        except FileNotFoundError:
            # This is a fallback in the rare case that the 'ping' command is not found.
            # It attempts a simple TCP connection to port 80 as a basic connectivity test.
            try:
                sock = socket.create_connection((host, 80), timeout=1)
                sock.close()
                return True
            except Exception:
                return False

    def _scan_single_port(self, ip: str, port: int, timeout: float) -> int | None:
        """Helper to scan a single port; returns port if open, else None."""
        try:
            # Create a new TCP socket for each port scan.
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
                # Set a timeout for the connection attempt.
                sock.settimeout(timeout)
                # `connect_ex` returns 0 if the connection is successful, otherwise an error code.
                if sock.connect_ex((ip, port)) == 0:
                    return port
        except Exception:
            # Ignore any exceptions that occur during the scan of a single port.
            pass
        return None

    def scan_ports(self, host: str, start_port: int, end_port: int, timeout: float = 0.5, concurrency: int = 100) -> list[int]:
        """
        Concurrent TCP connect scan from start_port to end_port inclusive.
        Returns a sorted list of open ports.
        """
        open_ports: list[int] = []
        try:
            # Resolve the hostname to an IP address first.
            ip = socket.gethostbyname(host)
        except Exception as e:
            print(f"Could not resolve host '{host}': {e}")
            return open_ports

        print(f"Scanning {host} ({ip}) ports {start_port}-{end_port} with {concurrency} workers...")
        # Use a ThreadPoolExecutor to perform port scans concurrently.
        with ThreadPoolExecutor(max_workers=concurrency) as executor:
            # Submit a task to scan each port in the specified range.
            # This creates a set of 'future' objects, each representing a pending scan.
            futures = {executor.submit(self._scan_single_port, ip, port, timeout) for port in range(start_port, end_port + 1)}
            try:
                # `as_completed` yields futures as they complete, allowing for real-time results.
                for future in as_completed(futures):
                    result = future.result()
                    # If the result is not None, the port is open.
                    if result is not None:
                        open_ports.append(result)
                        print(f"{self.colors.GREEN}Port {result} is open.{self.colors.ENDC}")
            except KeyboardInterrupt:
                print("\nScan interrupted by user.")
                # If the user interrupts, cancel the remaining futures.
                for f in futures:
                    f.cancel()
                # Shut down the executor without waiting for the cancelled futures to complete.
                executor.shutdown(wait=False, cancel_futures=True)
        # Return a sorted list of the open ports found.
        return sorted(open_ports)

    def get_network_traffic(self, duration: float = 1.0) -> tuple[int, int]:
        """
        Measure bytes sent/received over `duration` seconds.
        Requires psutil. If psutil is not available, returns (0,0) and prints advice.
        """
        if not _HAS_PSUTIL:
            print("psutil not installed — cannot measure network traffic.")
            print("Install it with: pip install psutil")
            return 0, 0

        # Get network I/O counters before waiting.
        before = psutil.net_io_counters()
        time.sleep(duration)
        # Get network I/O counters after waiting.
        after = psutil.net_io_counters()
        # Calculate the difference to find the traffic during the interval.
        sent = after.bytes_sent - before.bytes_sent
        recv = after.bytes_recv - before.bytes_recv
        return sent, recv

    def discover_devices(self) -> None:
        """
        Run 'arp -a', parse the output, and display a clean, tabulated list of devices.
        Handles both Windows and Linux/macOS formats.
        """
        # Find the path to the 'arp' command.
        arp_cmd = shutil.which("arp")
        if not arp_cmd:
            print("ARP command not found. On some platforms, you may need elevated privileges or different tools.")
            return

        try:
            # Execute 'arp -a' and capture the output.
            completed = subprocess.run([arp_cmd, "-a"], capture_output=True, text=True, errors="replace")
            output = completed.stdout
            devices = []
            
            # Regex for Linux/macOS: e.g., NCE-Campus (192.168.1.1) at 00:1a:2b:3c:4d:5e [ether] on en0
            linux_mac_pattern = re.compile(r".*\((?P<ip>[\d\.]+)\)\s+at\s+(?P<mac>([0-9a-fA-F]{1,2}[:-]){5}[0-9a-fA-F]{1,2}).*")
            
            # Regex for Windows: e.g., 192.168.1.1   00-1a-2b-3c-4d-5e   dynamic
            windows_pattern = re.compile(r"\s*(?P<ip>[\d\.]+)\s+(?P<mac>([0-9a-fA-F]{1,2}-){5}[0-9a-fA-F]{1,2}).*")

            # Iterate through each line of the ARP output.
            for line in output.splitlines():
                # Try to match both Linux/macOS and Windows patterns.
                match = linux_mac_pattern.match(line) or windows_pattern.match(line)
                if match:
                    # If a match is found, extract the IP and MAC address.
                    # Standardize the MAC address format to use colons and be uppercase.
                    devices.append({"ip": match.group("ip"), "mac": match.group("mac").replace("-", ":").upper()})

            if devices:
                # If devices are found, print them in a formatted table.
                print(f"{self.colors.GREEN}Discovered {len(devices)} devices:{self.colors.ENDC}")
                print(f"{'IP Address':<18} {'MAC Address':<18}")
                print("-" * 37)
                for device in devices:
                    print(f"{device['ip']:<18} {device['mac']:<18}")
            else:
                print("No devices discovered in the ARP cache.")
        except Exception as e:
            print(f"Error running arp: {e}")

    def alert(self, message: str) -> None:
        """Simple alert printer (can be extended to email/webhook)."""
        print(f"\n{self.colors.YELLOW}[ALERT] {message}{self.colors.ENDC}\n")

    def _handle_ping(self):
        """Helper method to handle the ping menu option."""
        host = input("Host or IP to ping: ").strip()
        if not host:
            print("No host entered.")
            return
        try:
            # Get the number of pings from the user.
            count = int(input("Number of pings to send (default 1): ").strip() or "1")
        except ValueError:
            print("Invalid number, using 1.")
            count = 1
        
        print(f"Pinging {host} {count} time(s)...")
        up = self.ping_host(host, count=count)
        # Display the status in color.
        status = f"{self.colors.GREEN}UP{self.colors.ENDC}" if up else f"{self.colors.RED}DOWN{self.colors.ENDC}"
        print(f"{host} is {status}")
        if not up:
            self.alert(f"Host {host} did not respond to ping.")

    def _handle_scan(self):
        """Helper method to handle the port scan menu option."""
        host = input("Host to scan: ").strip()
        if not host:
            print("No host entered.")
            return
        try:
            # Get the port range from the user.
            start = int(input("Start port (e.g. 1): ").strip())
            end = int(input("End port (e.g. 1024): ").strip())
            if start < 0 or end < start:
                print("Invalid port range.")
                return
        except ValueError:
            print("Port numbers must be integers.")
            return
        ports = self.scan_ports(host, start, end)
        if ports:
            print(f"{self.colors.GREEN}Open ports on {host}: {ports}{self.colors.ENDC}")
        else:
            print(f"No open ports found on {host} in range {start}-{end}.")

    def _handle_traffic(self):
        """Helper method to handle the network traffic menu option."""
        if not _HAS_PSUTIL:
            print("psutil not installed. To enable traffic measurement run: pip install psutil")
            cont = input("Continue without measuring? (y/n): ").strip().lower()
            if cont != "y":
                return
        duration = 1.0
        try:
            # Get the measurement duration from the user.
            d = input("Duration in seconds to measure (default 1): ").strip()
            if d:
                duration = float(d)
        except ValueError:
            print("Invalid duration, using 1 second.")
            duration = 1.0
        sent, recv = self.get_network_traffic(duration)
        print(f"Bytes sent: {sent} | Bytes received: {recv}")
        # A simple threshold for alerting on high traffic.
        threshold = 1_000_000
        if sent > threshold or recv > threshold:
            self.alert("High network traffic detected!")

    def run(self):
        """The main interactive menu loop."""
        try:
            while True:
                print(f"\n{self.colors.BLUE}=== SECURITY EDGE INC NT ==={self.colors.ENDC}")
                print("1) Ping a host")
                print("2) Scan open TCP ports")
                print("3) Measure network traffic (requires psutil)")
                print("4) Discover devices (ARP - may require privileges)")
                print("5) Exit")

                choice = input("Choice (1-5): ").strip()
                # A simple dispatch mechanism based on user input.
                if choice == "1":
                    self._handle_ping()
                elif choice == "2":
                    self._handle_scan()
                elif choice == "3":
                    self._handle_traffic()
                elif choice == "4":
                    self.discover_devices()
                elif choice == "5":
                    print("Bye 👋")
                    break
                else:
                    print("Invalid choice, try again.")
        except KeyboardInterrupt:
            # Handle Ctrl+C gracefully.
            print("\nInterrupted by user. Exiting.")
            sys.exit(0)

if __name__ == "__main__":
    tool = NetworkTool()
    tool.run()
