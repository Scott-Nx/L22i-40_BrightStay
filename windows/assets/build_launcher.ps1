$ErrorActionPreference = "Stop"

# Paths relative to this script (assumed in windows/assets/)
$scriptDir = $PSScriptRoot
$binDir = Join-Path $scriptDir "..\dist"
$outputExe = Join-Path $binDir "launcher.exe"
# The C# launcher will look for this file in the SAME directory as itself (which will be bin/)
$targetScript = "main.ps1"

# Create bin dir if not exists
if (-not (Test-Path $binDir)) {
    New-Item -Path $binDir -ItemType Directory -Force | Out-Null
}

$sourceCode = @"
using System;
using System.Diagnostics;
using System.IO;
using System.Text;

class Program
{
    static void Main(string[] args)
    {
        // 1. Determine path to the PowerShell script (same dir as this exe)
        string exePath = Process.GetCurrentProcess().MainModule.FileName;
        string exeDir = Path.GetDirectoryName(exePath);
        string scriptPath = Path.Combine(exeDir, "$targetScript");

        if (!File.Exists(scriptPath))
        {
            // Fallback: try looking for main.ps1
            scriptPath = Path.Combine(exeDir, "main.ps1");
        }

        if (!File.Exists(scriptPath))
        {
            // Script missing. Exit silently with error code.
            Environment.Exit(1);
        }

        // 2. Build Arguments
        StringBuilder sbArgs = new StringBuilder();
        sbArgs.Append("-NoProfile -ExecutionPolicy Bypass -File \"");
        sbArgs.Append(scriptPath);
        sbArgs.Append("\"");

        if (args.Length > 0)
        {
            sbArgs.Append(" ");
            // Pass all arguments as-is (simple join)
            // If args contain spaces, we wrap them in quotes
            for (int i = 0; i < args.Length; i++)
            {
                string arg = args[i];
                if (arg.Contains(" "))
                {
                    sbArgs.Append("\"" + arg + "\"");
                }
                else
                {
                    sbArgs.Append(arg);
                }

                if (i < args.Length - 1) sbArgs.Append(" ");
            }
        }

        // 3. Start PowerShell
        ProcessStartInfo startInfo = new ProcessStartInfo();
        startInfo.FileName = "powershell.exe";
        startInfo.Arguments = sbArgs.ToString();

        // Critical for hiding the window
        startInfo.WindowStyle = ProcessWindowStyle.Hidden;
        startInfo.CreateNoWindow = true;
        startInfo.UseShellExecute = false;

        try
        {
            Process.Start(startInfo);
        }
        catch (Exception)
        {
            Environment.Exit(1);
        }
    }
}
"@

# Define output path for temporary C# source (in bin dir to keep assets clean)
$sourceFile = Join-Path $binDir "Launcher.cs"
Set-Content -Path $sourceFile -Value $sourceCode -Encoding UTF8

# Compile
Write-Host "Compiling C# Launcher..." -ForegroundColor Cyan
$cscPath = Join-Path ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) "csc.exe"

if (-not (Test-Path $cscPath)) {
    $cscPath = Get-ChildItem -Path "C:\Windows\Microsoft.NET\Framework64" -Filter "csc.exe" -Recurse | Select-Object -Last 1 -ExpandProperty FullName
}

if (-not $cscPath) {
    Write-Error "C# Compiler (csc.exe) not found."
}

$buildArgs = @(
    "/target:winexe",     # WinExe = Windows Application (no console)
    "/out:`"$outputExe`"",
    "`"$sourceFile`""
)

Start-Process -FilePath $cscPath -ArgumentList $buildArgs -Wait -NoNewWindow -PassThru | Out-Null

# Cleanup
if (Test-Path $outputExe) {
    Write-Host "Success! Launcher created at: $outputExe" -ForegroundColor Green
    Remove-Item $sourceFile
} else {
    Write-Error "Compilation failed."
}
