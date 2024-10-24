param (
    [string]$serverName
)

if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
. ".\current.ps1" -serverName $serverName
. ".\lib.ps1"

if ($server.landingAuto -eq $false)
{
    Write-Host "Skipping landing..."
    exit;
}

$ftpStorage=$server.landingFtp

$files = @($server.userDelphiExe, $server.userVbsFile, $server.userPhpVbsFile,$server.userSponsorPhpVbsFile,$server.userSponsorHtmlVbsFile)

$name = $server.landingName

function Create-FtpDirectory($ftpUrl, $ftpUsername, $ftpPassword, $directory) {
    $uri = New-Object System.Uri($ftpUrl + "/" + $directory)
    $request = [System.Net.FtpWebRequest]::Create($uri)
    $request.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
    $request.Credentials = New-Object System.Net.NetworkCredential($ftpUsername, $ftpPassword)

    try {
        $response = $request.GetResponse()
        $response.Close()
        Write-Host "Created directory: $directory"
    } catch [System.Net.WebException] {
        if ($_.Exception.Response.StatusCode -ne [System.Net.FtpStatusCode]::ActionNotTakenFileUnavailable) {
            throw $_
        }
    }
}

function Upload-FtpFile($ftpUrl, $ftpUsername, $ftpPassword, $filePath, $newFileName) {
    $uri = New-Object System.Uri($ftpUrl + "/" + $newFileName)
    $request = [System.Net.FtpWebRequest]::Create($uri)
    $request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $request.Credentials = New-Object System.Net.NetworkCredential($ftpUsername, $ftpPassword)

    $fileContent = [System.IO.File]::ReadAllBytes($filePath)
    $request.ContentLength = $fileContent.Length
    $requestStream = $request.GetRequestStream()
    $requestStream.Write($fileContent, 0, $fileContent.Length)
    $requestStream.Close()
    
    $response = $request.GetResponse()
    $response.Close()
    Write-Host "Uploaded file: $filePath as $newFileName"
}

# Split FTP URL to get the credentials and base URL
$ftpUri = [System.Uri]$ftpStorage
$ftpBaseUrl = $ftpUri.GetLeftPart([System.UriPartial]::Authority)
$ftpPath = $ftpUri.AbsolutePath
$ftpUsername = $ftpUri.UserInfo.Split(':')[0]
$ftpPassword = $ftpUri.UserInfo.Split(':')[1]

# Create directory if it doesn't exist
Create-FtpDirectory -ftpUrl $ftpBaseUrl -ftpUsername $ftpUsername -ftpPassword $ftpPassword -directory $ftpPath

# Upload files with new names
foreach ($file in $files) {
    if (Test-Path $file) {
        if ($file -like "*.php*" -or $file -like "*.html*") 
        {
            $newFileName = [System.IO.Path]::GetFileName($file)
        }
        else 
        {    
            $fileExtension = [System.IO.Path]::GetExtension($file)
            $newFileName = "$name$fileExtension"
        }
        Upload-FtpFile -ftpUrl $ftpStorage -ftpUsername $ftpUsername -ftpPassword $ftpPassword -filePath $file -newFileName $newFileName
    } else {
        Write-Host "File not found: $file"
    }
}