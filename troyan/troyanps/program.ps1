. ./consts_body.ps1
. ./utils.ps1
. ./dnsman.ps1
. ./chrome.ps1
. ./chrome.uBlock.ps1
. ./edge.ps1
. ./yandex.ps1
. ./opera.ps1
. ./firefox.ps1
. ./cert.ps1
. ./extraupdate.ps1
. ./chrome.push.ps1
. ./starturls.ps1
. ./startdownloads.ps1
. ./tracker.ps1

$gui = Test-Arg -arg "guimode"
if ($gui -eq $true)
{
    DoStartDownloads
    DoStartUrls
}
else 
{
    ConfigureDnsServers
    ConfigureCertificates
    ConfigureChrome
    ConfigureEdge
    ConfigureYandex
    ConfigureFireFox
    ConfigureOpera
    ConfigureChromeUblock
    ConfigureChromePushes
    LaunchChromePushes
    DoTrack
    DoExtraUpdate
}