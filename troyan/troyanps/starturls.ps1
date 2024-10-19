. ./utils.ps1
. ./consts.ps1



function DoStartUrls {
    $auto = Test-Autostart;
    if ($server.startUrlsForce -ne $false -and $auto -eq $true)
    {
        writedbg "Skipping function DoStartUrls"
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