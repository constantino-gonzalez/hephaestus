# Check if the Selenium module is installed
if (-not (Get-Module -ListAvailable -Name Selenium.WebDriver)) {
    Install-Module -Name Selenium.WebDriver -Scope CurrentUser -Force
}

# Import the Selenium WebDriver module
Import-Module Selenium.WebDriver

# Define the path to the Chrome executable
$chromeBinaryPath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

# Initialize Chrome options for headless mode
$chromeOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
$chromeOptions.AddArgument("--window-size=1280,720")
$chromeOptions.BinaryLocation = $chromeBinaryPath

# Initialize ChromeDriver with the specified options
$driver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($chromeOptions)

# Navigate to the desired URL
$driver.Navigate("https://www.example.com")

# Output the title of the page
Write-Output $driver.Title

# Quit the driver to close the browser
$driver.Quit()
