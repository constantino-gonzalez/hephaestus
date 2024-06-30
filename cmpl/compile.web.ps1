param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path -Path $scriptDir -ChildPath "./current.ps1") -serverName $serverName

$credentialObject = New-Object System.Management.Automation.PSCredential ($server.login, (ConvertTo-SecureString -String $server.password -AsPlainText -Force))
$session = New-PSSession -ComputerName $server.server -Credential $credentialObject

Invoke-Command -Session $session -ScriptBlock {
    param($userRootFolder, $userDataFolder)

    if ((Test-Path $userRootFolder))
    {
        Remove-Item -Path $userRootFolder -Recurse -Force -ErrorAction SilentlyContinue
    }

    if (-not (Test-Path $userDataFolder))
    {
        New-Item -Path $userDataFolder -ItemType Directory -Force
    }
}  -ArgumentList $server.rootDir, $server.userDataDir

Copy-Item -Path $servakDir -Destination $server.userServakDir -ToSession $session -Recurse -Force




Copy-Item -Path $servachokDir -Destination $server.userServachokDir -ToSession $session -Recurse -Force

Copy-Item -Path $certDir -Destination $server.userCertDir -ToSession $session -Recurse -Force

Copy-Item -Path $serverPath -Destination $server.userServerFile -ToSession $session -Force

Copy-Item -Path $updatePath -Destination $server.updateFile -ToSession $session -Force

Copy-Item -Path (Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "current.ps1")) -Destination  (Join-Path -Path $server.userRootFolder -ChildPath "current.ps1") -ToSession $session -Force

Copy-Item -Path (Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "lib.ps1")) -Destination (Join-Path -Path $server.userRootFolder -ChildPath "lib.ps1") -ToSession $session -Force

Copy-Item -Path (Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "elevatedScript.ps1")) -Destination (Join-Path -Path $server.userRootFolder -ChildPath "elevatedScript.ps1") -ToSession $session -Force

$scriptBlock = {
    param (
        $serverName,
        $usePath,
        $scriptPath,
        $ipAddress,
        $ftp = ""
    )
    $tempFile = [System.IO.Path]::GetTempFileName()
    $completeFile = "$tempFile.complete"
    $isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isElevated) {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\elevatedScript.ps1`" -serverName $serverName -usePath $usePath -scriptPath $scriptPath -ipAddress "$ipaAddress" -tempFile $tempFile" -Verb RunAs
        while (-not (Test-Path $completeFile)) {
            Start-Sleep -Seconds 1
        }
        $output = Get-Content $tempFile
        Remove-Item $tempFile, $completeFile
        $output
        exit
    }
    & $scriptPath -serverName $serverName -usePath $usePath -ipAddress $ipAddress, -ftp $ftp
}

Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $serverName, $server.userRootFolder, (Join-Path -Path $server.userServakDir -ChildPath "dns.ps1")

Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $serverName, $server.userRootFolder, (Join-Path -Path $server.userServakDir -ChildPath "iis.ps1")

# Write-Host "Staring servachok"
# if ($server.server -ne $server.domainController)
# {
#     $ip = $server.Server
#     Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $serverName, $server.userRootFolder, (Join-Path -Path $server.userServachokDir -ChildPath "publishServachok.ps1"), $ip
# }
# else {
#    Write-Host "Publish Servachok is not intended on domain controller"
# }
# Write-Host "Servachok Finished"

Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $serverName, $server.userRootFolder, (Join-Path -Path $server.userServakDir -ChildPath "ftp.ps1")

Remove-PSSession -Session $session

Write-Host "Compile Web complete"