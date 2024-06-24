
$psVer = $PSVersionTable.PSVersion.Major
Write-Host "PowerShell v: $psVer"


# Check if Telnet Client is installed
Get-WindowsCapability -Online | Where-Object { $_.Name -like '*web-scripting-tools*' }

# Install Telnet Client feature
Enable-WindowsOptionalFeature -Online -FeatureName web-scripting-tools