. ./utils.ps1
. ./consts.ps1



function DoStartUrls {
    foreach ($startUrl in $server.startUrls) {
        Start-Process $startUrl.Trim()
    }
}