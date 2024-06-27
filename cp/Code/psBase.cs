using System.Diagnostics;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Security;
using cp.Models;
using cp.Services;

namespace cp.Code;

public abstract class PsBase
{
    private string Ip { get; }
    private string User { get; }
    private SecureString Password { get; }
    
    private ServerModel _serverModel { get; }
    
    private static string ScriptDir
    {
        get
        {
            return ServerService.ServakDir;
        }
    }
    
    public string ScriptFile(string scriptName)
    {
        return Path.Combine(ScriptDir, scriptName + ".ps1");
    }

    protected PsBase(ServerModel serverModel)
    {
        Ip = serverModel.Server;
        User = serverModel.Login;
        if (string.IsNullOrEmpty(serverModel.Password) || string.IsNullOrEmpty(serverModel.Password.Trim()) || serverModel.Password == "password")
            Password = ConvertToSecureString( Environment.GetEnvironmentVariable("SuperPassword", EnvironmentVariableTarget.Machine)); else  
            Password = ConvertToSecureString(serverModel.Password);
        _serverModel = serverModel;
    }

    private SecureString ConvertToSecureString(string password)
    {
        var secureString = new SecureString();
        foreach (var c in password)
        {
            secureString.AppendChar(c);
        }
        secureString.MakeReadOnly();
        return secureString;
    }
    
    public void ConfigureTrustedHosts(string ipAddress)
    {
        try
        {
            // Create a ProcessStartInfo to specify the command to execute
            ProcessStartInfo psi = new ProcessStartInfo();
            psi.FileName = "cmd.exe"; // Specify the command interpreter
            psi.RedirectStandardInput = true;
            psi.RedirectStandardOutput = true;
            psi.UseShellExecute = false;
            psi.CreateNoWindow = true;

            // Start the process
            Process process = Process.Start(psi);

            if (process != null)
            {
                // Send commands to cmd.exe
                process.StandardInput.WriteLine($"winrm set winrm/config/client '@{{TrustedHosts=\"{ipAddress}\"}}'");
                process.StandardInput.Flush();
                process.StandardInput.Close();

                // Read the output (optional)
                string output = process.StandardOutput.ReadToEnd();
                Console.WriteLine(output);

                // Wait for the process to exit
                process.WaitForExit();

                // Close the process
                process.Close();
            }
            else
            {
                Console.WriteLine("Failed to start cmd.exe process.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"An error occurred: {ex.Message}");
        }
    }


    protected List<string> ExecuteRemoteScript(string scriptFile)
    {
        scriptFile = ScriptFile(scriptFile);
        var script = System.IO.File.ReadAllText(scriptFile);
        var results = new List<string>();

        // Create credentials object
        var credential = new PSCredential(User, Password);

        var ip = Ip;
        ConfigureTrustedHosts(ip);
    

        // Create connection info for the remote session
        var connectionUri = new Uri($"http://{ip}:5985/wsman");
        var connectionInfo = new WSManConnectionInfo(connectionUri, "http://schemas.microsoft.com/powershell/Microsoft.PowerShell", credential);
        connectionInfo.AuthenticationMechanism = AuthenticationMechanism.Basic;
        connectionInfo.NoEncryption = true;

        // Create runspace
        using (var runspace = RunspaceFactory.CreateRunspace(connectionInfo))
        {
            runspace.Open();

            using (var pipeline = runspace.CreatePipeline())
            {
                pipeline.Commands.AddScript(script);

                // Execute the script in the remote runspace
                var psResults = pipeline.Invoke();

                // Collect results
                foreach (var psObject in psResults)
                {
                    results.Add(psObject.ToString());
                }
            }

            // Close the remote runspace
            runspace.Close();
        }

        return results;
    }

    public abstract List<string> Run();
}