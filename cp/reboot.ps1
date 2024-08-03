

$Username = "Administrator"
$Password = "19ojjvXivbc6"

# Convert the plain text password to a secure string
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

# Create the PSCredential object
$Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)

# Define the remote computer name
$RemoteComputerName = "1.superhost.pw"

# Restart the remote computer
Restart-Computer -ComputerName $RemoteComputerName -Credential $Credential -Force