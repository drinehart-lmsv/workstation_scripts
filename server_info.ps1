# 17-MAR-2026
# Duane Rinehart
# Purpose: Capture critical compute info for host

Write-Host "`e[32mDATE:`e[0m `t`t`t$(Get-Date -Format 'yyyy-MM-dd')"
Write-Host "`e[32mHOST:`e[0m `t`t`t$env:COMPUTERNAME"
Write-Host "`e[32mRAM:`e[0m `t`t`t$(Get-CimInstance -Class Win32_ComputerSystem | ForEach-Object { [Math]::Round($_.TotalPhysicalMemory / 1GB) }) GB"
Write-Host "`e[32mCPU Cores:`e[0m `t`t$(Get-CimInstance -Class Win32_Processor | Select-Object -ExpandProperty NumberOfCores)"
Write-Host "`e[32mCPU Threads (Logical Processors):`e[0m `t$(Get-CimInstance -Class Win32_Processor | Select-Object -ExpandProperty NumberOfLogicalProcessors)"

Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" | 
    Select-Object DeviceID, VolumeName, FileSystem, 
    @{Name="TotalSize(GB)"; Expression={[math]::Round($_.Size / 1GB, 2)}}, 
    @{Name="FreeSpace(GB)"; Expression={[math]::Round($_.FreeSpace / 1GB, 2)}}, 
    @{Name="PercentFree"; Expression={[math]::Round(($_.FreeSpace / $_.Size) * 100, 2)}} |
    Format-Table -AutoSize

Get-NetIPConfiguration -Detailed