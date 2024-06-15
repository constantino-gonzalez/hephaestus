$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$temp = Get-Content (Join-Path -Path $scriptDir -ChildPath "domains.txt")
$networkInterfaces = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' } | Select-Object -ExpandProperty IPAddress

if (-not ($temp.GetType().Name -eq 'Object[]')) {
    $temp = @($temp)
}

$domainArray = $temp | ForEach-Object {
    $splitItem = $_ -split '='
    $splitItem[0].Trim()
}
if (-not ($domainArray.GetType().Name -eq 'Object[]')) {
    $domainArray = @($domainArray)
}

$valid = $true

$domainsKeyed = $false
$domainPairs = @{}
$temp | ForEach-Object {
    $key, $value = $_ -split '=', 2
    if ($key -ne $null) {
        $key = $key.Trim()
        if ([string]::IsNullOrEmpty($key)) {
            $valid = $false
        }
    }
    if ($value -ne $null) {
        $value = $value.Trim()
        if (-not [string]::IsNullOrEmpty($value)) {
            $domainsKeyed = $true
        }
    }
    if ($value -eq $null){
        $value = ""
    }
    $domainPairs[$key] = $value
}

if ($domainsKeyed)
{
    foreach ($value in $domainPairs.Values) {
        if ([string]::IsNullOrEmpty($value)) {
            $valid = $false
            break
        }
    }
    if (-not $valid) {
        Write-Host "! V domains.txt vse domeni doljni bit opredeleni ili ne odnogo"
    }
}

if (-not ($networkInterfaces.GetType().Name -eq 'Object[]')) {
    $networkInterfaces = @($networkInterfaces)
}

$publicInterface = $networkInterfaces[0]
$secondInterface = $networkInterfaces[0]
if ($networkInterfaces.Length -gt 1){
    $secondInterface = $networkInterfaces[1]
}

$optionalDnsPath = (Join-Path -Path $scriptDir -ChildPath "dns.txt")
if (Test-Path $optionalDnsPath) {
    $optionalDns = Get-Content $optionalDnsPath
    if ($null -eq $optionalDns){
        $optionalDns = @()
    }
    if (-not ($optionalDns.GetType().Name -eq 'Object[]')) {
        $optionalDns = @($optionalDns)
    }
    if ($optionalDns.Count -eq 0 -or $optionalDns.Count -eq 2) {
        if ($optionalDns -eq 2){
            $publicInterface = $optionalDns[0]
            $secondInterface = $optionalDns[1]
            Write-Host "Ispolzuem dns iz dns.txt: $publicInterface, $secondInterface"
        }
    } else {
        Write-Host "! V dns.txt doljno bit 2 zapisi ili pusto"
        $valid=$false
    }
}

$obj = New-Object PSObject -Property @{
    domainArray = $domainArray
    domainPairs = $domainPairs
    domainsKeyed = $domainsKeyed
    valid = $valid
    networkInterfaces = $networkInterfaces
    publicInterface = $publicInterface
    secondInterface = $secondInterface
}

if ($domainArray.Length -ne $networkInterfaces.Length) {
    Write-Host "! Warning. KOL_VO IP MENSHE KOL-VO DOMENOV"
}

$obj