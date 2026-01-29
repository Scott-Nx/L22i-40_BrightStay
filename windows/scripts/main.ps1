param(
    [Parameter(Mandatory=$false)]
    [switch]$toggle
)

# Task Scheduler toggle functionality
if ($Toggle) {
    Add-Type -AssemblyName System.Windows.Forms
    $taskName = "BrightStay"
    $taskPath = "\NChalapinyo\"

    try {
        $task = Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction Stop

        if ($task.State -eq 'Disabled') {
            Enable-ScheduledTask -TaskName $taskName -TaskPath $taskPath | Out-Null
            [System.Windows.Forms.MessageBox]::Show("BrightStay task is now enabled.", "Task Scheduler", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } else {
            Disable-ScheduledTask -TaskName $taskName -TaskPath $taskPath | Out-Null
            [System.Windows.Forms.MessageBox]::Show("BrightStay task is now disabled.", "Task Scheduler", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to toggle task: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }

    exit
}

# Default behavior: Monitor brightness/color preset fix
# Get all monitors and find the one matching the specific InstanceName
$monitor = Get-Monitor | Where-Object { $_.InstanceName -eq "DISPLAY\LEN67AE\5&16e23401&0&UID277" }

# Check if the monitor was found
if ($monitor) {
    Write-Host "Monitor found: $($monitor.FriendlyName)"

    # Extract the LogicalDisplay value
    $logicalDisplay = $monitor.LogicalDisplay

    # Re-apply Color Preset (VCP 0x14, Value 11) to restore brightness and fix RGB Range
    Write-Host "Re-applying color preset for monitor: $logicalDisplay"
    Set-MonitorVcpValue -Monitor "$logicalDisplay" -VCPCode 0x14 -Value 11
} else {
    Write-Host "Monitor with the specified InstanceName not found."
}
