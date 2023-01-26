<#
Author: Enrique A. Budiono 
Description: This automation is created for itmt-430 student when installing tools for the first time 
#>

Write-Output "======================="
Write-Output "Starting the automation"
Write-Output "=======================`n"
Write-Output "The Bracket only for example"

$name = Read-Host "What name the do you want to input for github config? (John Doe) "
$email = Read-Host "What is your email for GitHub Config? (email@example.com) "
$repo_name = Read-Host "What is your HAWK username? (test)"
$group_name = Read-Host "What is your group repo name? (2022-team00w) "
$group_num = Read-Host "What is your group number? (00) "

# Chocolately Installations
$testchoco = powershell.exe choco -v
<# If Chocolately not installed #>
Write-Output "`nChecking if Chocolately is installed"
if(-not($testchoco)) {
    Write-Output "Chocolately is not installed, installing it"
    Set-ExecutionPolicy Bypass -Scope Process -Force; 
    [System.Net.ServicePointManager]::SecurityProtocol = 
    [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
else {
    Write-Output "Chocolately is already installed"
}

<# Installing package using Chocolatey #>
Write-Host "Installing package using Chocolatey"
choco install -y powershell-core microsoft-windows-terminal git -y vscode vscode-powershell atom virtualbox vagrant packer
Write-Host "Finished installing package using Chocolatey"

<# Show the SSH Version #>
Write-Host "`nChecking SSH version:"
$ssh = ssh.exe -V
Write-Host $ssh -ForegroundColor Green

<# Show the git version #>
Write-Host "`nChecking git version:"
$git_version = git.exe --version
Write-Host $git_version -ForegroundColor Green

<# Configuring Git Client #>
Write-Host "`n======================="
Write-Host "Configuring Git Client"
Write-Host "=======================`n"

Write-Host "Entering the Github Name $name"
git.exe config --global user.name $name
Write-Host "Entering the Github Email $email"
git.exe config --global user.email $email

Write-Host "`n==========================="
Write-Host "Showing the git config list"
Write-Host "===========================`n"
Write-Output "Github user.name:"
$git_username = git.exe config user.name
Write-Host $git_username -ForegroundColor Green
Write-Output "Github user.email:"
$git_email = git.exe config user.email
Write-Host $git_email -ForegroundColor Green

<# Showing Vagrant version#>
Write-Host "`n========================"
Write-Host "Checking Vagrant Version"
Write-Host "========================`n"
Write-Host "Vagrant Version:"
$vagrant_ver = vagrant.exe --version
Write-Host $vagrant_ver -ForegroundColor Green

<# Showing Packer version #>
Write-Host "`n======================="
Write-Host "Checking Packer Version"
Write-Host "=======================`n"
Write-Host "Packer Version:"
$packer_ver = packer.exe --version
Write-Host $packer_ver -ForegroundColor Green

# Creating ssh-key
Write-Host "`n======================="
Write-Host "Creating SSH Key"
Write-Host "=======================`n"
$exist = Test-Path -Path .\id_ed25519_git_key
if(-not($exist)) {
    Write-Host "SSH Key does not exist, creating it" -ForegroundColor Red
    ssh-keygen -t ed25519 -f id_ed25519_git_key -N '""'
}
else {
    Write-Host "SSH Key already exists" -ForegroundColor Green
}

# Showing the SSH Key
Write-Output "`n======================="
Write-Output "Showing the SSH Key"
Write-Output "=======================`n"
$ssh_key = Get-Content id_ed25519_git_key.pub
Write-Host $ssh_key -ForegroundColor Green

Write-Output "`n^^^^^ Copy the SSH Key to your GitHub account ^^^^"
Write-Output "and paste the key in the GitHub account"
Write-Output "before pressing ENTER , make sure to input the key or this sript will not work"
cmd /c pause

# Cloning the github repo
Write-Output "`n=============================="
Write-Output "Cloning the jhajek github repo"
Write-Output "=============================="
$jhajek_exist = Test-Path -Path ..\jhajek
if(-not($jhajek_exist)) {
    Write-Host "jhajek repo does not exist, cloning it" -ForegroundColor Red
    git.exe clone git@github.com:illinoistech-itm/jhajek.git
}
else {
    Write-Host "jhajek repo already exists" -ForegroundColor Green
}

Write-Output "`n================================"
Write-Output "Cloning the personal github repo"
Write-Output "================================"
$personal_exist = Test-Path -Path ..\$repo_name
if(-not($personal_exist)) {
    Write-Host "$repo_name repo does not exist, cloning it" -ForegroundColor Red
    git.exe clone git@github.com:illinoistech-itm/$repo_name.git
}
else {
    Write-Host "$repo_name repo already exists" -ForegroundColor Green
}

Write-Output "`n============================="
Write-Output "Cloning the Group github repo"
Write-Output "============================="
$group_exist = Test-Path -Path ..\$group_name
if(-not($group_exist)) {
    Write-Host "$group_name repo does not exist, cloning it" -ForegroundColor Red
    git.exe clone git@github.com:illinoistech-itm/$group_name.git
}
else {
    Write-Host "$group_name repo already exists" -ForegroundColor Green
}

# Retrieving the boxes
Write-Output "Make sure to connect to the VPN that professor Hajek provided before pressing ENTER: "
cmd /c pause

Write-Output "`n===================="
Write-Output "Retrieving the boxes"
Write-Output "===================="
Set-Location ../$group_name/build/powershell
powershell.exe ./remove-and-retrieve-and-add-vagrant-boxes.ps1 $group_num

Write-Host "Boxes is retreieved" -ForegroundColor Green

Write-Output "`n===================="
Write-Output "Bringing the boxes up"
Write-Output "===================="
powershell.exe ./up.ps1