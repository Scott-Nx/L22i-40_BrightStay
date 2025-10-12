# Get all monitors and find the one matching the specific InstanceName
$monitor = Get-Monitor | Where-Object { $_.InstanceName -eq "DISPLAY\LEN67AE\5&16e23401&0&UID277" }

# Check if the monitor was found
if ($monitor) {
    Write-Host "Monitor found: $($monitor.FriendlyName)"

    # Extract the LogicalDisplay value
    $logicalDisplay = $monitor.LogicalDisplay

    # Use the LogicalDisplay value in the Set-MonitorBrightness command
    Write-Host "Setting brightness for monitor: $logicalDisplay"
    Set-MonitorBrightness -Monitor "$logicalDisplay" -Value 5
} else {
    Write-Host "Monitor with the specified InstanceName not found."
}
