Import-Module ActiveDirectory

# CSV file path
$csvPath = "C:\Local\AD\secureedge\New_OU_Users.csv"

# Check if CSV file exists
if (-Not (Test-Path $csvPath)) { Write-Host "CSV file not found." -ForegroundColor Red; exit 1 }

# Load the CSV file
$users = Import-Csv $csvPath

# Function to create an Organizational Unit (OU)
function Create-OU {
    param($Department)
    $OUPath = "OU=$Department,DC=secureedge,DC=Inc"
    if (-Not (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $OUPath} -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $Department -Path "DC=secureedge,DC=Inc"
        Write-Host "OU '$Department' created successfully." -ForegroundColor Green
    } else { Write-Host "OU '$Department' already exists." -ForegroundColor Yellow }
}

# Function to create a user account
function Create-User {
    param($FirstName, $LastName, $Username, $Department, $Password)
    if (-Not (Get-ADUser -Filter {SamAccountName -eq $Username} -ErrorAction SilentlyContinue)) {
        New-ADUser -SamAccountName $Username -UserPrincipalName "$Username@secureedge.Inc" -Name "$FirstName $LastName" `
            -GivenName $FirstName -Surname $LastName -Department $Department -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
            -Enabled $true -Path "OU=$Department,DC=secureedge,DC=Inc"
        Write-Host "User '$Username' created successfully." -ForegroundColor Green
    } else { Write-Host "User '$Username' already exists." -ForegroundColor Yellow }
}

# Create OUs and user accounts from the CSV
foreach ($user in $users) {
    Create-OU -Department $user.Department
    Create-User -FirstName $user.Firstname -LastName $user.Lastname -Username $user.Username -Department $user.Department -Password $user.Password
}
