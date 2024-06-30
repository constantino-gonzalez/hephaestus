# REMOVE SERTS
function Remove-CertificatesByFriendlyName {
    # List of certificate stores to search
    $stores = @(
        "CurrentUser\My",
        "LocalMachine\My",
        "CurrentUser\Root",
        "LocalMachine\Root",
        "CurrentUser\CA",
        "LocalMachine\CA",
        "CurrentUser\AuthRoot",
        "LocalMachine\AuthRoot"
    )
    foreach ($storeLocation in $stores) {
        $certs = Get-ChildItem -Path "cert:\$storeLocation" | Where-Object { $_.FriendlyName -like "*$friendlyName*" }

        foreach ($cert in $certs) {
            Remove-Item -LiteralPath $cert.PSPath -Force
            Write-Host "Certificate with FriendlyName containing '$friendlyName' removed from $storeLocation store."
        }
    }
}
Remove-CertificatesByFriendlyName 