param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. ".\current.ps1" -serverName $serverName

Import-Module WebAdministration
Import-Module PSPKI


function CreateCertificate {
    param (
        [string]$domain
    )

    $friendlyNameX = "$domain $friendlyName"
    $expiryDate = (Get-Date).AddYears(25)
    
    $path = certFile($domain)
    $pathPfx = pfxFile($domain)

    if (-not (Test-Path $path)) {
        Write-Host "Certificate creating... $path"
  
        $cert = New-SelfSignedCertificate -DnsName $domain -CertStoreLocation "cert:\LocalMachine\My" -KeySpec KeyExchange -NotAfter $expiryDate -Subject "CN=$domain" -KeyExportPolicy Exportable -FriendlyName $friendlyNameX
    
        Move-Item -Path "Cert:\LocalMachine\My\$($cert.Thumbprint)" -Destination "Cert:\LocalMachine\Root" -Force:$force
    
        Write-Host $pathPfx
        Export-PfxCertificate -Cert $cert -FilePath $pathPfx -NoClobber -Force -Password $certPassword
    
        Export-Certificate -Cert $cert -FilePath $path -Force
    } else {
        Write-Host "Certificate exists. $pathPfx"
        $certificatePassword = ConvertTo-SecureString -String "123" -Force -AsPlainText
        $certificate = Import-PfxCertificate -FilePath $pathPfx -CertStoreLocation Cert:\LocalMachine\My -Password $certificatePassword -Exportable
        $certificate = Import-PfxCertificate -FilePath $pathPfx -CertStoreLocation Cert:\LocalMachine\Root -Password $certificatePassword -Exportable
        $certificate | Out-Null
    }
}

foreach ($domain in $server.domains) {
    CreateCertificate($domain)
}

Write-Host "Compile cert сomplete"