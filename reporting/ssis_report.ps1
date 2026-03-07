# 6-MAR-2026
# Duane Rinehart
# Purpose: Query and report all jobs from A) task scheduler or B) SQL Server

# Note: Run this once you are connected via SSH

Import-Module SqlServer -ErrorAction SilentlyContinue

# Relative to where script is run (assumes after SSH connection)
$ServerName = "localhost" 

# Query Windows Task Scheduler for tasks related to SSIS or owned by Sergey
$windowsTasks = Get-ScheduledTask | 
    Where-Object { $_.Principal.UserId -like "*ssisasql*" -or $_.Principal.UserId -like "*Sergey*" } | 
    ForEach-Object {
        try {
            # We pass BOTH TaskPath and TaskName to ensure it finds the file
            $info = Get-ScheduledTaskInfo -TaskPath $_.TaskPath -TaskName $_.TaskName -ErrorAction Stop
            $lastRun = $info.LastRunTime
            $nextRun = $info.NextRunTime
        } catch {
            $lastRun = "Error"
            $nextRun = "Error"
        }

        [PSCustomObject]@{
            Source   = 'TaskScheduler'
            TaskName = $_.TaskName
            State    = $_.State
            User     = $_.Principal.UserId
            LastRun  = $lastRun
            NextRun  = $nextRun
            Command  = $_.Actions.Execute
        }
    }

$sqlJobs = Get-SqlAgentJob -ServerInstance $ServerName | 
    Select-Object @{N='Source';E={'SQLServer'}}, 
                  @{N='TaskName';E={$_.Name}}, 
                  @{N='State';E={if($_.IsEnabled){"Enabled"}else{"Disabled"}}}, 
                  @{N='User';E={$_.Owner}}, 
                  @{N='LastRun';E={$_.LastRunDate}}, 
                  @{N='NextRun';E={$_.NextRunDate}}, 
                  @{N='Command';E={$_.JobSteps[0].Command}}

# Combine and output
$combined = $windowsTasks + $sqlJobs

# Output to console (but may truncate some columns)
#$combined | Sort-Object Source, TaskName | Format-Table -AutoSize

# Output to CSV
$combined | Sort-Object Source, TaskName | ConvertTo-Csv -NoTypeInformation