# 6-MAR-2026
# Duane Rinehart
# Purpose: Creates public & private SSH keys on client and configures SSH client for passwordless login to 'ssis' server.

$user = (whoami).Split('\')[-1]
$keyPath = "$HOME\.ssh\id_ed25519"
$configFile = "$HOME\.ssh\config"

# 1. Check if the private key already exists
if (-not (Test-Path $keyPath)) {
    Write-Host "No SSH key found. Generating a new Ed25519 key..." -ForegroundColor Cyan
    # -N '' creates an empty passphrase for true passwordless login
    ssh-keygen -t ed25519 -f $keyPath -N ''
} else {
    Write-Host "SSH key already exists at $keyPath. Skipping generation." -ForegroundColor Yellow
}

# 2. Define the config block
$configContent = @"

Host ssis
    HostName ssis
    User "$user"
    IdentityFile ~/.ssh/id_ed25519
"@

# 3. Create .ssh directory if it's missing
if (-not (Test-Path "$HOME\.ssh")) { 
    New-Item -Path "$HOME\.ssh" -ItemType Directory 
}

# 4. Append to config (checks if the 'Host ssis' entry already exists to avoid duplicates)
if (Test-Path $configFile) {
    $existingConfig = Get-Content $configFile
    if ($existingConfig -match "Host ssis") {
        Write-Host "Config for 'ssis' already exists in $configFile. Skipping append." -ForegroundColor Yellow
    } else {
        Add-Content -Path $configFile -Value $configContent
        Write-Host "Config for 'ssis' added successfully." -ForegroundColor Green
    }
} else {
    Set-Content -Path $configFile -Value $configContent
    Write-Host "Config file created and 'ssis' added." -ForegroundColor Green
}