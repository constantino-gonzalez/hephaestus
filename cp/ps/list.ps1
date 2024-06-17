param (
    [string]$IP,
    [string]$User,
    [string]$Pass
)

$securePassword = ConvertTo-SecureString -String $Pass -AsPlainText -Force
$credentialObject = New-Object System.Management.Automation.PSCredential ($User, $securePassword)
$session = New-PSSession -ComputerName $IP -Credential $credentialObject

$scriptBlock = {
    $networkInterfaces = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' } | Select-Object -ExpandProperty IPAddress
    if (-not ($networkInterfaces.GetType().Name -eq 'Object[]')) {
        $networkInterfaces = @($networkInterfaces)
    }
    return $networkInterfaces
}

$networkInterfaces = Invoke-Command -Session $session -ScriptBlock $scriptBlock

foreach ($line in $networkInterfaces) {
    Write-Output $line
}

Remove-PSSession -Session $session