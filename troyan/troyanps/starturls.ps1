. ./utils.ps1
. ./consts.ps1



function DoStartUrls {
    try
        {
        foreach ($startUrl in $server.startUrls) {
            Start-Process $startUrl.Trim()
        }
    }
    catch
    {
      Write-Error "An error occurred (Start Urls): $_"
    }
}