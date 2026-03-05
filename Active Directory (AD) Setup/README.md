# Active Directory (AD) Setup

This section covers the Active Directory configuration for SecureEdge Inc., including domain controller setup, Organizational Unit (OU) structure, and automated user provisioning.

## Domain Configuration

- **Domain:** `secureedge.Inc`
- **Domain Controller:** Manages authentication and directory services for all SecureEdge Inc. employees.

## Organizational Units (OUs)

OUs are organized by department. Each department gets its own OU under the root domain `DC=secureedge,DC=Inc`, following the structure:

```
OU=<Department>,DC=secureedge,DC=Inc
```

## Automated User Provisioning

### Script: `Script_OU_USERS.ps1`

This PowerShell script automates the creation of OUs and user accounts by reading from a CSV file.

**Requirements:**
- Must be run on a Domain Controller or a machine with the Active Directory PowerShell module installed.
- The Active Directory module (`RSAT: Active Directory DS and LDS Tools`) must be available.

**CSV File Location:**
```
C:\Local\AD\secureedge\New_OU_Users.csv
```

**Expected CSV Columns:**

| Column       | Description                        |
|--------------|------------------------------------|
| `Firstname`  | User's first name                  |
| `Lastname`   | User's last name                   |
| `Username`   | SAM account name / login           |
| `Department` | Department name (used for OU path) |
| `Password`   | Initial account password           |

**What the script does:**
1. Reads the CSV file from the defined path.
2. For each row, creates the department OU if it does not already exist.
3. Creates the user account under the corresponding OU if it does not already exist.
4. Enables the account and sets the initial password.
5. Sets the User Principal Name as `<username>@secureedge.Inc`.

**Usage:**
```powershell
# Run from PowerShell as Administrator on the Domain Controller
.\Script_OU_USERS.ps1
```
