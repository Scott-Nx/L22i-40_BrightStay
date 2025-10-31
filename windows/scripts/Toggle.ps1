Add-Type -AssemblyName System.Windows.Forms
$taskName = "BrightStay"
$taskPath = "\NChalapinyo\"
$task = Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath
if ($task.Settings.Enabled) {
    Disable-ScheduledTask -TaskName $taskName -TaskPath $taskPath
    [System.Windows.Forms.MessageBox]::Show("Task now disabled.")
} else {
    Enable-ScheduledTask -TaskName $taskName -TaskPath $taskPath
    [System.Windows.Forms.MessageBox]::Show("Task now enabled.")
}
