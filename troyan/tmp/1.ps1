Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public static class ProcessMonitor
{
    private const int WM_HIDE = 0x0010;

    [DllImport("user32.dll")]
    private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll")]
    private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    private const int SW_HIDE = 0;

    public static void StartProcess(string fileName, string arguments)
    {
        var process = new Process();
        process.StartInfo.FileName = fileName;
        process.StartInfo.Arguments = arguments;
        process.StartInfo.UseShellExecute = false;
        process.StartInfo.CreateNoWindow = true;
        process.EnableRaisingEvents = true;

        process.Start();

        IntPtr handle = FindWindow(null, process.MainWindowTitle);
        if (handle != IntPtr.Zero)
        {
            ShowWindow(handle, SW_HIDE);
        }

        process.Exited += (sender, e) =>
        {
            // Optional: Add any additional logic when the process exits
        };
    }
}
"@

# Start Chrome and pass a URL as an argument
[ProcessMonitor]::StartProcess("C:\Program Files\Google\Chrome\Application\chrome.exe", "https://www.example.com")

# Optionally, wait if needed
Start-Sleep -Seconds 10  # Adjust the wait time as needed

Write-Output "Monitoring completed."
