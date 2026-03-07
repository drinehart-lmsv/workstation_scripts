# 6-MAR-2026
# Duane Rinehart
# Purpose: Establish connection to SSIS server and remote execute Powershell script

$remote_server = 'ssis'
$report_script = 'ssis_report.ps1'
$local_output_dir = "C:\temp"

if (!(Test-Path $local_output_dir)) { New-Object Item -ItemType Directory -Path $local_output_dir }
$local_path = "$local_output_dir\SSIS_Job_Report_$(Get-Date -Format 'yyyyMMdd_HHmm').csv"

$user = (whoami).Split('\')[-1]
$rawOutput = Get-Content $report_script | ssh $user@$remote_server "pwsh -NoProfile -Command -" | Out-String

# Convert returned content (CSV)
$reportObjects = $rawOutput | ConvertFrom-Csv

# Save to local filesystem
$reportObjects | Sort-Object Source, TaskName | Format-Table -AutoSize
$reportObjects | Export-Csv -Path $local_path -NoTypeInformation

Write-Host "`nReport saved locally to: $local_path" -ForegroundColor Cyan