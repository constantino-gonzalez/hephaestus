# Add-Type to include shell32.dll
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    using System.Text;

    public class Win32Api {
        [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Auto)]
        public struct SHFILEINFO {
            public IntPtr hIcon;
            public int iIcon;
            public uint dwAttributes;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst=260)]
            public string szDisplayName;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst=80)]
            public string szTypeName;
        };

        public class Shell32 {
            [DllImport("shell32.dll", CharSet=CharSet.Auto)]
            public static extern IntPtr SHGetFileInfo(string pszPath, uint dwFileAttributes, ref SHFILEINFO psfi, uint cbSizeFileInfo, uint uFlags);

            [DllImport("User32.dll", CharSet=CharSet.Auto)]
            public static extern int DestroyIcon(IntPtr hIcon);
        }
    }
"@

# Function to get default icon for a file extension
function Get-DefaultIconForExtension {
    param (
        [string] $Extension
    )

    $iconPath = [System.Text.StringBuilder]::new(260)
    $iconIndex = 0
    $SHGFI_ICON = 0x000000100
    $SHGFI_USEFILEATTRIBUTES = 0x000000010
    $SHGFI_ICONLOCATION = 0x000001000

    try {
        $shFileInfo = New-Object Win32Api+SHFILEINFO
        $null = [Win32Api+Shell32]::SHGetFileInfo("$Extension", 0, [ref]$shFileInfo, [uint]([System.Runtime.InteropServices.Marshal]::SizeOf($shFileInfo)), $SHGFI_ICON -bor $SHGFI_USEFILEATTRIBUTES -bor $SHGFI_ICONLOCATION)

        $icon = [System.Drawing.Icon]::FromHandle($shFileInfo.hIcon).Clone()
        [Win32Api+Shell32]::DestroyIcon($shFileInfo.hIcon) | Out-Null

        if ($icon -ne $null) {
            return $icon
        } else {
            Write-Host "Failed to get icon for $Extension" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error occurred: $_" -ForegroundColor Red
    }

    return $null
}

function Extract-IconFromExe {
    param (
        [string] $FilePath
    )

    try {
        $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($FilePath)
        if ($icon -ne $null) {
            return $icon
        } else {
            Write-Host "Failed to extract icon from $FilePath" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error occurred: $_" -ForegroundColor Red
    }

    return $null
}

function ExtractIcon 
{
    param (
        [string] $filePath,
        [string] $outPath
    )
    $fileExtension = [System.IO.Path]::GetExtension($filePath)
    if ($fileExtension -eq ".exe") 
    {
        $icon = Extract-IconFromExe -FilePath $filePath
        if ($icon -ne $null) {
            try {
                $fileStream = [System.IO.File]::OpenWrite($outPath)
                $icon.Save($fileStream)
                $fileStream.Close()
            } catch {
                Write-Host "Failed to save icon to $outPath"
            } finally {
                $icon.Dispose()
            }
        }
    } 
    else 
    {
        $icon = Get-DefaultIconForExtension -Extension $fileExtension
        if ($icon -ne $null) 
        {
            try {
            
                $fileStream = [System.IO.File]::OpenWrite($outPath)
                $icon.Save($fileStream)
                $fileStream.Close()
            } catch {
                Write-Host "Failed to save icon to $outPath"
            } finally 
            {
                $icon.Dispose()
            }
        }
    }
}