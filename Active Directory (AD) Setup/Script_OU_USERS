import-module ActiveDirectory

# Definir as cores
$Yellow = [System.Console]::ForegroundColor = 'Yellow'
$Green = [System.Console]::ForegroundColor = 'Green'
$Red = [System.Console]::ForegroundColor = 'Red'

# Caminho do CSV
$csvPath = "C:\Local\AD\secureedge\New_OU_Users.csv"


# Verificar se o CSV existe
if (-Not (Test-Path $csvPath)) { Write-Host "CSV file not found." -ForegroundColor Red; exit }

# Carregar o CSV
$users = Import-Csv $csvPath

# Função para criar OU e usuário
function Create-OU {
    param($Department)
    $OUPath = "OU=$Department,DC=secureedge,DC=Inc"
    if (-Not (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $OUPath} -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $Department -Path "DC=secureedge,DC=Inc"
        Write-Host "OU '$Department' created successfully." -ForegroundColor Green
    } else { Write-Host "OU '$Department' already exists." -ForegroundColor Yellow }
}

function Create-User {
    param($FirstName, $LastName, $Username, $Department, $Password)
    if (-Not (Get-ADUser -Filter {SamAccountName -eq $Username} -ErrorAction SilentlyContinue)) {
        New-ADUser -SamAccountName $Username -UserPrincipalName "$Username@secureedge.Inc" -Name "$FirstName $LastName" `
            -GivenName $FirstName -Surname $LastName -Department $Department -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
            -Enabled $true -Path "OU=$Department,DC=secureedge,DC=Inc"
        Write-Host "User '$Username' created successfully." -ForegroundColor Green
    } else { Write-Host "User '$Username' already exists." -ForegroundColor Yellow }
}

# Criar OUs e usuários
foreach ($user in $users) {
    Create-OU -Department $user.Department
    Create-User -FirstName $user.Firstname -LastName $user.Lastname -Username $user.Username -Department $user.Department -Password $user.Password
}
