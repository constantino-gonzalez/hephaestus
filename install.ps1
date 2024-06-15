Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PSPKI

Install-WindowsFeature -Name DNS -IncludeManagementTools

Install-WindowsFeature -Name Web-Server, Web-Ftp-Server, Web-FTP-Ext, Web-Windows-Auth -IncludeManagementTools
Install-WindowsFeature web-scripting-tools

# Specify the download URL
$downloadUrl = "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi"

# Specify the destination path for the MSI file
$msiPath = "$env:TEMP\rewrite_amd64_en-US.msi"

# Download the MSI file
Invoke-WebRequest -Uri $downloadUrl -OutFile $msiPath

# Install the MSI file silently
Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$msiPath`" /quiet" -Wait

# Remove the downloaded MSI file
Remove-Item -Path $msiPath -Force

Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication

Install-Module -Name IISAdministration                                        