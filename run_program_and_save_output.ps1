# PowerShell script to run a program and save outputs to shared path
param(
    [Parameter(Mandatory=$true)]
    [string]$ProgramPath,
    
    [Parameter(Mandatory=$false)]
    [string]$Arguments = "",
    
    [Parameter(Mandatory=$false)]
    [string]$SharedPath = "\\server\shared\outputs",
    
    [Parameter(Mandatory=$false)]
    [switch]$UseIP = $false
)

# Get computer information
$ComputerName = $env:COMPUTERNAME
$IPAddress = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet* | Where-Object {$_.IPAddress -notlike "169.254.*"} | Select-Object -First 1).IPAddress

# Create timestamp
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Create shared directory if it doesn't exist
if (-not (Test-Path $SharedPath)) {
    Write-Host "Creating shared directory: $SharedPath"
    New-Item -ItemType Directory -Path $SharedPath -Force | Out-Null
}

# Determine identifier (computer name or IP)
$Identifier = if ($UseIP) { $IPAddress } else { $ComputerName }

# Create output file name
$OutputFile = Join-Path $SharedPath "$($Identifier)_$($Timestamp).txt"

Write-Host "Running program: $ProgramPath"
Write-Host "Arguments: $Arguments"
Write-Host "Output will be saved to: $OutputFile"

# Start the program and capture output
try {
    $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
    $ProcessInfo.FileName = $ProgramPath
    $ProcessInfo.Arguments = $Arguments
    $ProcessInfo.UseShellExecute = $false
    $ProcessInfo.RedirectStandardOutput = $true
    $ProcessInfo.RedirectStandardError = $true
    $ProcessInfo.CreateNoWindow = $true

    $Process = New-Object System.Diagnostics.Process
    $Process.StartInfo = $ProcessInfo
    $Process.Start() | Out-Null

    # Capture output
    $Output = $Process.StandardOutput.ReadToEnd()
    $ErrorOutput = $Process.StandardError.ReadToEnd()
    $Process.WaitForExit()

    # Save output to file
    $Header = @"
Program: $ProgramPath
Arguments: $Arguments
Computer: $ComputerName
IP Address: $IPAddress
Started: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Exit Code: $($Process.ExitCode)

"@

    $Header | Out-File -FilePath $OutputFile -Encoding UTF8
    $Output | Out-File -FilePath $OutputFile -Append -Encoding UTF8
    
    if ($ErrorOutput) {
        "`nERROR OUTPUT:`n" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
        $ErrorOutput | Out-File -FilePath $OutputFile -Append -Encoding UTF8
    }

    Write-Host "Program completed successfully!"
    Write-Host "Output saved to: $OutputFile"
    Write-Host "Exit code: $($Process.ExitCode)"

} catch {
    Write-Error "Error running program: $($_.Exception.Message)"
    exit 1
}