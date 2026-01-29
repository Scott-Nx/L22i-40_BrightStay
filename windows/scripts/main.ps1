param(
    [Parameter(Mandatory=$false)]
    [switch]$toggle
)

if ($toggle) {
    Add-Type -AssemblyName System.Windows.Forms
    $taskName = "BrightStay"
    $taskPath = "\NChalapinyo\"

    try {
        $task = Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction Stop
        $isDisabled = $task.State -eq 'Disabled'

        if ($isDisabled) {
            Enable-ScheduledTask -TaskName $taskName -TaskPath $taskPath | Out-Null
            $message = "BrightStay now enabled"
        } else {
            Disable-ScheduledTask -TaskName $taskName -TaskPath $taskPath | Out-Null
            $message = "BrightStay now disabled"
        }

        [System.Windows.Forms.MessageBox]::Show($message, "Task Scheduler", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to toggle task: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    }

    exit 0
}

$targetInstanceName = "DISPLAY\LEN67AE\5&16e23401&0&UID277"
$vcpCode = 0x14
$vcpValue = 11

try {
    # Use -ErrorAction Stop for faster failure detection
    $monitor = Get-Monitor -ErrorAction Stop | Where-Object { $_.InstanceName -eq $targetInstanceName } | Select-Object -First 1

    if ($monitor -and $monitor.LogicalDisplay) {
        # Apply Color Preset (VCP 0x14, Value 11) to restore brightness and fix RGB Range
        Set-MonitorVcpValue -Monitor $monitor.LogicalDisplay -VCPCode $vcpCode -Value $vcpValue -ErrorAction Stop
        exit 0
    }

    exit 1
} catch {
    exit 1
}
