#ico
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

function Extract-Icon
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

. .\current.ps1
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$server = $global:server;
#delphi embeddings
function Create-EmbeddingFiles {
    param (
        [string]$name,
        [int]$startIndex
    )

    $srcFolder = Join-Path -Path $dataDir -ChildPath ".\\$name"

    $rcFile = Join-Path -Path $scriptDir -ChildPath "_$name.rc"
    $delphiFile = Join-Path -Path $scriptDir -ChildPath "_$name.pas"
    $unitName = "_$name";
    $iconFile = Join-Path -Path $scriptDir -ChildPath "_icon.ico"
    $currentIconFile = Join-Path -Path $dataDir -ChildPath "server.ico"

    if ($server.extractIconFromFront -eq $false){
        Copy-Item -Path $currentIconFile -Destination $iconFile -Force
    }

    $files = (Get-ChildItem -Path $srcFolder -File) 
    if ($null -eq $files){
        $files = @()
    }
    if (-not ($files.GetType().Name -eq 'Object[]')) {
        $files = @($files)
    }
    
    $idx=$startIndex;
    $rcContent = ""
    $delphiArray = @()
    foreach ($file in $files) {
        if ($name -eq "front")
        {
            if ($server.extractIconFromFront -eq $true -and $iconFile -ne ""){
                Extract-Icon -filePath $file.FullName -outPath $iconFile
                Copy-Item -Path $iconFile -Destination $currentIconFile -Force
                $iconFile=""
            }
        }
        $filename = [System.IO.Path]::GetFileName($file.FullName)
        $rcContent = $rcContent + "$idx RCDATA ""..\..\current\$name\$filename"""+ [System.Environment]::NewLine
        $idx++
        $delphiArray += "'" + $filename + "'"
    }

    $template = @"
unit NAME;

interface

const
xembeddings: array[0..NUMBER] of string = (CONTENT);

implementation

end.
"@
    Set-Content -Path $rcFile -Value $rcContent -Encoding UTF8NoBOM

    & "C:\Program Files (x86)\Borland\Delphi7\Bin\brcc32.exe" "$rcFile"

    $number = $files.Length-1
    if ($number -lt 0) {
        $number = 0
    }
    $content = ($delphiArray -join ', ')
    if ($content -eq ""){
        $content="''"
    }

    $template  = $template -replace "CONTENT", $content
    $template  = $template -replace "NAME", $unitName
    $template  = $template -replace "NUMBER", $number.ToString()

    Set-Content -Path $delphiFile -Value $template -Encoding UTF8NoBOM
}

Create-EmbeddingFiles -name "front" -startIndex 8000
Create-EmbeddingFiles -name "embeddings" -startIndex 9000