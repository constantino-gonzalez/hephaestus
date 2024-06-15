. ./utils.ps1

function ConfigureFireFox 
{
    Set-FirefoxRegistry -KeyPaths @(
        'SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS',
        'SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS'
    ) -ValueNames @('Enabled', 'Locked') -Values @(0, 1)

    foreach ($dir in Get-EnvPaths) 
    {
        $path = Join-Path -Path $dir -ChildPath "Mozilla\Firefox\Profiles\user.js"

        try 
        {
            $UserJSContent = 'user_pref("network.trr.mode", 5);'
            
            if (!(Test-Path -Path $path -PathType Leaf)) 
            {
                $null = New-Item -Path $path -ItemType File
                Add-Content -Path $path -Value $UserJSContent
            }
        }
        catch 
        {
            Write-Error "Failed to write to user.js file: $_"
        }
    }
}


function Set-FirefoxRegistry {
    param (
        [string[]]$KeyPaths,
        [string[]]$ValueNames,
        [int[]]$Values
    )

    $ErrorActionPreference = 'Stop'
    $regKey = [Microsoft.Win32.Registry]::LocalMachine

    try {
        foreach ($i in 0..($KeyPaths.Length - 1)) {
            $key = $regKey.OpenSubKey($KeyPaths[$i], $true)
            if ($key -eq $null) {
                Write-Error "Failed to open registry key: $($KeyPaths[$i])"
                return
            }

            $key.SetValue($ValueNames[$i], $Values[$i], [Microsoft.Win32.RegistryValueKind]::DWord)
            $key.Close()
        }
    }
    catch {
        Write-Error "Error accessing or modifying registry: $_"
    }
}