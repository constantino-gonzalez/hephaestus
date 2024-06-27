param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. .\current.ps1 -serverName $serverName
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$PSSessionConfigurationName = 'PowerShell.5';


$credentialObject = New-Object System.Management.Automation.PSCredential ($server.login, (ConvertTo-SecureString -String $server.password -AsPlainText -Force))
$session = New-PSSession -ComputerName $server.server -Credential $credentialObject

Invoke-Command -Session $session -ScriptBlock {
    param($serverName)
    if (Test-Path 'C:\_x')
    {
        Remove-Item -Path 'C:\_x' -Recurse -Force
    }

    if (-not (Test-Path "C:\_x\data"))
    {
        New-Item -Path "C:\_x\data" -ItemType Directory -Force
    }
}  -ArgumentList $serverName

Copy-Item -Path $servakDir -Destination 'C:\_x\servak' -ToSession $session -Recurse -Force

$subfoldersToDelete = @(".idea", "bin", "obj")
foreach ($subfolder in $subfoldersToDelete) {
    $fullPath = Join-Path -Path $servachokDir -ChildPath $subfolder
    if (Test-Path -Path $fullPath) {
        try {
            Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Deleted $fullPath"
        } catch {
            Write-Host "Failed to delete $fullPath : $_"
        }
    } else {
        Write-Host "Subfolder $fullPath does not exist."
    }
}


Copy-Item -Path $servachokDir -Destination 'C:\_x\servachok' -ToSession $session -Recurse -Force

Copy-Item -Path $certDir -Destination 'C:\_x\cert' -ToSession $session -Recurse -Force

Copy-Item -Path $serverPath -Destination "C:\_x\data\server.json" -ToSession $session -Force

Copy-Item -Path (Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "current.ps1")) -Destination "C:\_x\current.ps1" -ToSession $session -Force

Copy-Item -Path (Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "elevatedScript.ps1")) -Destination "C:\_x\elevatedScript.ps1" -ToSession $session -Force

$scriptBlock = {
    param (
        $serverName,
        $usePath,
        $scriptPath,
        $ipAddress=""
    )
    $tempFile = [System.IO.Path]::GetTempFileName()
    $completeFile = "$tempFile.complete"
    $isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isElevated) {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\elevatedScript.ps1`" -serverName $serverName -usePath $usePath -scriptPath $scriptPath -ipAddress $ipaAddress -tempFile $tempFile" -Verb RunAs
        while (-not (Test-Path $completeFile)) {
            Start-Sleep -Seconds 1
        }
        $output = Get-Content $tempFile
        Remove-Item $tempFile, $completeFile
        $output
        exit
    }
    & $scriptPath -serverName $serverName -usePath $usePath
}

Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $serverName, 'C:\_x', "C:\_x\servak\dns.ps1" 

Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $serverName, 'C:\_x', "C:\_x\servak\iis.ps1" 

if ($server.server -ne $server.domainController)
{
    $ip = $server.Server
    Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $serverName, 'C:\_x', "C:\_x\servachok\publishServachok.ps1", $ip 
}
else {
   Write-Host "Publish Servachok is not intended on domain controller"
}

Remove-PSSession -Session $session

Write-Host "Compile Web complete"