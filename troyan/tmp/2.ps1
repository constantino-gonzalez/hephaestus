# Define the path to the Chrome executable
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

# Define the URL to navigate to
$url = "https://www.rambler.ru"

# Create a new ProcessStartInfo object
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $chromePath
$startInfo.Arguments = "--headless --disable-gpu  --window-size=1280,720 $url"
$startInfo.UseShellExecute = $false
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true

# Start the Chrome process
$process = [System.Diagnostics.Process]::Start($startInfo)

Start-Sleep -Seconds 5

# Wait for the process to exit and capture output
$process.Close()
$output = $process.StandardOutput.ReadToEnd()
$error1 = $process.StandardError.ReadToEnd()

# Output the results
Write-Output "Standard Output: $output"
Write-Output "Standard Error: $error1"