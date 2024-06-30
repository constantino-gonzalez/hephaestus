Import-Module WebAdministration

# Define paths
$hostX = (Get-Item "Env:SuperHost").Value
$password = (Get-Item "Env:SuperPassword").Value
$siteName = "_cp"
$username = "$env:COMPUTERNAME\Administrator"
$ipAddress = $hostX
$appPoolName = "DefaultAppPool"
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$destinationDirectory = "C:\inetpub\wwwroot\$siteName"

Write-Host $hostX
Write-Host $passX

Stop-Service -Name W3SVC
Start-Service -Name W3SVC

Import-Module WebAdministration

#remove site
$iisSite = Get-Website -Name $siteName -ErrorAction SilentlyContinue
if ($null -ne $iisSite)
{
    Stop-Website -Name $siteName -ErrorAction SilentlyContinue
    Remove-WebSite -Name $siteName -ErrorAction SilentlyContinue
}
if (-Not (Test-Path -Path $destinationDirectory)) {
    New-Item -Path $destinationDirectory -ItemType Directory | Out-Null
}
Get-ChildItem -Path $destinationDirectory | Remove-Item -Recurse -Force


#remove pool
if (Test-Path "IIS:\AppPools\$appPoolName") {
    Stop-WebAppPool -Name $appPoolName -ErrorAction SilentlyContinue
    Remove-Item "IIS:\AppPools\$appPoolName" -Recurse
    Write-Output "Existing identity for '$appPoolName' removed."
}
New-Item "IIS:\AppPools\$appPoolName"
Get-Item "IIS:\AppPools\$appPoolName"
Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "processModel.identityType" -Value "SpecificUser"
Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "processModel.userName" -Value $username
Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "processModel.password" -Value $password
Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "managedRuntimeVersion" -Value ""
Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "managedPipelineMode" -Value "Integrated"
Set-WebConfigurationProperty -Filter '/system.webServer/httpErrors' -Name errorMode -Value Detailed
Start-WebAppPool -Name $appPoolName


#build site
dotnet build
dotnet publish $scriptDirectory -o $destinationDirectory

#create permisssons
New-Website -Name $siteName -PhysicalPath $destinationDirectory -Port 80 -IPAddress $ipAddress -ApplicationPool $appPoolName
Start-Website -Name $siteName -ErrorAction SilentlyContinue

Write-Host "Publish CP complete"