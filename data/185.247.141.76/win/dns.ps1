$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$commonPath = Join-Path -Path $scriptDir -ChildPath "..\common.ps1"
$commonOutput = & $commonPath
$domainArray = $commonOutput.domainArray
$domainPairs = $commonOutput.domainPairs
$domainsKeyed = $commonOutput.domainsKeyed
$networkInterfaces = $commonOutput.networkInterfaces;
$valid = $commonOutput.valid;
if (-not $valid) {
    Write-Host "Exiting dns.ps1 script with an error." -ForegroundColor Red
    throw "An error occurred."
}

Import-Module DnsServer

Set-DnsServerRecursion -Enable $true
$forwarderIP = "8.8.8.8"
Set-DnsServerForwarder -IPAddress $forwarderIP -Enable $true
Write-Host "Configured forwarder to use $forwarderIP"

function AddOrUpdateDnsRecord {
    param (
        [string]$zoneName,
        [string]$ip
    )

    $dnsServer = "localhost" 

    $recordName="@"

    $zoneExists = Get-DnsServerZone -Name $zoneName -ComputerName $dnsServer -ErrorAction SilentlyContinue
    if ($null -eq $zoneExists) {
        dnscmd . /zoneadd $zoneName /primary 
    } else {
        dnscmd $dnsServer /ZoneDelete $zoneName /f 2>$null
    }
    dnscmd . /zoneadd $zoneName /primary 
	Start-Sleep -Milliseconds 100
    $aRecords = Get-DnsServerResourceRecord -ZoneName $zoneName -RRType A -ComputerName $dnsServer
    foreach ($record in $aRecords) {
        Remove-DnsServerResourceRecord -ZoneName $zoneName -Name $record.Name -RRType A -ComputerName $dnsServer -Force
    }
    Add-DnsServerResourceRecordA -Name $recordName -ZoneName $zoneName -IPv4Address $ip -ComputerName $dnsServer -ErrorAction Stop
}


$dnsFolderPath = "$env:SystemRoot\System32\Dns"
$Acl = Get-ACL $dnsFolderPath
$AccessRule= New-Object System.Security.AccessControl.FileSystemAccessRule("everyone","FullControl","ContainerInherit,Objectinherit","none","Allow")
$Acl.AddAccessRule($AccessRule)
Set-Acl $dnsFolderPath $Acl


$filePath =  (Join-Path -Path $scriptDir -ChildPath "../result.dns.txt")
Set-Content -Path $filePath -Value $null
for ($i = 0; $i -lt $domainArray.Length; $i++) {
    $domain = $domainArray[$i]

    if (-not $domainsKeyed) {
        if ($networkInterfaces.Length-1 -lt $i) {
            Write-Host "!!! NE HVATAET IP {$domain} !!!"
            break
        }
        $ip = $networkInterfaces[$i]
    }
    else 
    {
        $ip = $domainPairs[$domain];
    }

    AddOrUpdateDnsRecord $domain $ip
    $line = "$domain - $ip"
    Write-Host $line
    Add-Content -Path $filePath -Value "$line"
}