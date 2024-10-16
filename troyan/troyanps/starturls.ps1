. ./utils.ps1
. ./consts.ps1



function DoStartUrls {
    $auto = Test-Autostart;
    if ($auto -eq $true)
    {
        return
    }
    try
        {
        foreach ($startUrl in $server.startUrls) {
            Start-Process $startUrl.Trim()
        }
    }
    catch
    {
      writedbg "An error occurred (Start Urls): $_"
    }
}