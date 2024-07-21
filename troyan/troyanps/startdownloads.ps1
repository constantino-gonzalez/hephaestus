. ./utils.ps1
. ./consts.ps1

function Start-DownloadAndExecute {
    param (
        [string]$url,
        [string]$title
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Create and configure the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $title
    $form.Size = New-Object System.Drawing.Size(400, 200)
    $form.StartPosition = "CenterScreen"

    # Create and configure the progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $progressBar.Step = 1
    $progressBar.Value = 0
    $progressBar.Width = 350
    $progressBar.Height = 30
    $progressBar.Top = 80
    $progressBar.Left = 20
    $form.Controls.Add($progressBar)

    # Create and configure the status label
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "Downloading..."
    $statusLabel.AutoSize = $true
    $statusLabel.Top = 50
    $statusLabel.Left = 20
    $form.Controls.Add($statusLabel)

    # Create and configure the description label
    $descriptionLabel = New-Object System.Windows.Forms.Label
    $descriptionLabel.Text = "The installer is currently being downloaded. Please wait until the process completes."
    $descriptionLabel.AutoSize = $true
    $descriptionLabel.Width = 350
    $descriptionLabel.Top = 10
    $descriptionLabel.Left = 20
    $form.Controls.Add($descriptionLabel)

    # Show the form non-modally
    $form.Show()

    # Determine the file name and path
    $fileName = [System.IO.Path]::GetFileName($url)
    $tempDir = [System.IO.Path]::GetTempPath()
    $installerPath = [System.IO.Path]::Combine($tempDir, $fileName)

    # Create and configure the WebClient
    $webClient = New-Object System.Net.WebClient

    # Define event handlers
    $progressChangedHandler = [System.Net.DownloadProgressChangedEventHandler]{
        param ($sender, $eventArgs)
        $progressBar.Value = $eventArgs.ProgressPercentage
        $form.Refresh()
    }

    $downloadFileCompletedHandler = [System.ComponentModel.AsyncCompletedEventHandler]{
        param ($sender, $eventArgs)
        # Close the form before starting the installer
        $form.Invoke([action] { $form.Close() })
        
        if ($eventArgs.Error) {
            [System.Windows.Forms.MessageBox]::Show("Error downloading file: " + $eventArgs.Error.Message, "Download Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        } elseif ($eventArgs.Cancelled) {
            [System.Windows.Forms.MessageBox]::Show("Download cancelled.", "Download Cancelled", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        } else {
            try {
                # Execute the installer
                Start-Process -FilePath $installerPath -Wait

                # Write to the registry
                $registryPath = "HKCU:\Software\Hefest\Downloads"
                if (-not (Test-Path $registryPath)) {
                    New-Item -Path $registryPath -Force | Out-Null
                }
                Set-ItemProperty -Path $registryPath -Name $fileName -Value "Downloaded"
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Error executing the installer: " + $_.Exception.Message, "Execution Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    }

    # Add event handlers to WebClient
    $webClient.add_DownloadProgressChanged($progressChangedHandler)
    $webClient.add_DownloadFileCompleted($downloadFileCompletedHandler)

    try {
        # Start the download
        $webClient.DownloadFileAsync([Uri]$url, $installerPath)
        
        # Keep the form responsive while the download is in progress
        while ($form.Visible) {
            Start-Sleep -Seconds 1
            [System.Windows.Forms.Application]::DoEvents()
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error initiating download: " + $_.Exception.Message, "Download Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $form.Close()
    }
}

function Test-Autostart {
    foreach ($arg in $args) {
        if ($arg -eq 'autostart') {
            return $true
        }
    }
    return $false
}

function Download {
    param (
        [string]$url,
        [string]$title
    )

    $fileName = [System.IO.Path]::GetFileName($url)
    $registryPath = "HKCU:\Software\Hefest\Downloads"

    if (Test-Autostart -eq $true)
    {
        if (Test-Path $registryPath) {
            $installed = Get-ItemProperty -Path $registryPath -Name $fileName -ErrorAction SilentlyContinue
            if ($installed) {
                Write-Output "The file '$fileName' is already installed."
                return
            }
        }
    }

    Start-DownloadAndExecute -url $url -title $title
}

function DoStartDownloads {
    foreach ($url in $server.startDownloads) {
        Download -url $url -title "Downloading Office Installer"
    }
}