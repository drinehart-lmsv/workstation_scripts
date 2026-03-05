# 5-MAR-2026
# AUTHOR: Duane Rinehart (duane.rinehart@lmsvsd.net)
# Purpose: Windows Powershell user profile mod to emulate linux 'which' command

# HOWTO:
# 1) Open Powershell and run: code $PROFILE
# 2) Paste the following code into the profile file and save it.

function which ($Command) {
    $path = Get-Command $Command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path
    if ($path) { return $path } 
    else { Write-Warning "Command '$Command' not found in PATH." }
}