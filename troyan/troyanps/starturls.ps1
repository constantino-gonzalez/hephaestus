. ./utils.ps1
. ./consts.ps1



function DoStartUrls {
    foreach ($startUrl in $xstartUrls) {
        Start-Process $startUrl.Trim()
    }
}