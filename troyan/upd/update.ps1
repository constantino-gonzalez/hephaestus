# Create a new WScript.Shell COM object
$shell = New-Object -ComObject WScript.Shell

# Display a simple message box
$shell.Popup("Hello, PowerShell!", 0, "Title", 0x40)