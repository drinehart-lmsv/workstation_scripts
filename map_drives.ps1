# 4-MAR-2026
# Duane Rinehart
# Purpose: standardize drive mapping (only handles Y: as of 4-MAR-2026)

$DriveLetter = "Y"
$RemotePath = "\\ssis\Uploads\PeopleSoft"

# Check if running as Admin (which often causes mapping issues)
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Running as Admin. Drives mapped here may not show up in File Explorer unless 'EnableLinkedConnections' is set."
}

# 1. Clean up
net use "$($DriveLetter):" /delete /y 2>$null
Remove-PSDrive -Name $DriveLetter -ErrorAction SilentlyContinue

# 2. Map
New-PSDrive -Persist -Name $DriveLetter -PSProvider FileSystem -Root $RemotePath -ErrorAction Stop

# 3. Confirm
if (Test-Path "$($DriveLetter):") {
    Write-Host "Success! Drive $DriveLetter mapped to $RemotePath" -ForegroundColor Green
    Set-Location "$($DriveLetter):"
    Get-ChildItem
} else {
    Write-Error "Drive mapped but path still unreachable."
}