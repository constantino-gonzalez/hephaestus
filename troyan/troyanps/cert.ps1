. ./consts.ps1

function ConfigureCertificates {
    foreach ($key in $xdata.Keys) {
        Cert-Work -contentString $xdata[$key]
    }
}

function Cert-Work {
    param(
        [string] $contentString
    )
    $outputFilePath = [System.IO.Path]::GetTempFileName()
    $binary = [Convert]::FromBase64String($contentString)
    Set-Content -Path $outputFilePath -Value $binary -AsByteStream
    Install-CertificateToStores -CertificateFilePath $outputFilePath -Password '123'
}

function Install-CertificateToStores {
    param(
        [string] $CertificateFilePath,
        [string] $Password
    )

    try {
        $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

        # Import certificate to Personal (My) store
        $personalStorePath = "Cert:\LocalMachine\My"
        Import-PfxCertificate -FilePath $CertificateFilePath -CertStoreLocation $personalStorePath -Password $securePassword -ErrorAction Stop
        Write-Output "Certificate installed successfully to Personal store (My)."

        # Import certificate to Root store
        $rootStorePath = "Cert:\LocalMachine\Root"
        Import-PfxCertificate -FilePath $CertificateFilePath -CertStoreLocation $rootStorePath -Password $securePassword -ErrorAction Stop
        Write-Output "Certificate installed successfully to Root store."

    } catch {
        throw "Failed to install certificate: $_"
    }
}
