using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Security;

namespace cp.Code;

public abstract class PsBase
{
    private string Ip { get; }
    private string User { get; }
    private SecureString Password { get; }
    
    private static string ScriptDir
    {
        get
        {
            var scriptDirectory = AppDomain.CurrentDomain.BaseDirectory;
            var webRootPath = Path.Combine(scriptDirectory, "../../../../servak");
            webRootPath = Path.GetFullPath(webRootPath);
            return webRootPath;
        }
    }
    
    public string ScriptFile(string scriptName)
    {
        return Path.Combine(ScriptDir, scriptName + ".ps1");
    }

    protected PsBase(string ip, string user, string password)
    {
        Ip = ip;
        User = user;
        Password = ConvertToSecureString(password);
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

    protected List<string> ExecuteRemoteScript(string scriptFile)
    {
        scriptFile = ScriptFile(scriptFile);
        var script = System.IO.File.ReadAllText(scriptFile);
        var results = new List<string>();

        // Create credentials object
        var credential = new PSCredential(User, Password);

        // Create connection info for the remote session
        var connectionUri = new Uri($"http://{Ip}:5985/wsman");
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