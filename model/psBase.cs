using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Security;

namespace model;

public abstract class PsBase
{
    private string Ip { get; }
    private string User { get; }
    private SecureString Password { get; }

    private ServerModel _serverModel { get; }

    private static string ScriptDir
    {
        get { return ServerModelLoader.SysDirStatic; }
    }

    public string ScriptFile(string scriptName)
    {
        return Path.Combine(ScriptDir, scriptName + ".ps1");
    }

    protected PsBase(ServerModel serverModel)
    {
        Ip = serverModel.Server;
        User = serverModel.Login;
        if (string.IsNullOrEmpty(serverModel.Password) || string.IsNullOrEmpty(serverModel.Password.Trim()) ||
            serverModel.Password == "password")
        {
            var pass = Environment.GetEnvironmentVariable("SuperPassword_" + serverModel.Server,
                EnvironmentVariableTarget.Machine);

            Password = ConvertToSecureString(pass);
        }
        else
        {
            Password = ConvertToSecureString(serverModel.Password);
        }

        _serverModel = serverModel;
    }

    private static SecureString ConvertToSecureString(string password)
    {
        var secureString = new SecureString();
        foreach (var c in password)
        {
            secureString.AppendChar(c);
        }

        secureString.MakeReadOnly();
        return secureString;
    }

    protected List<string> ExecuteRemoteScript(string scriptFile, params (string Name, object Value)[] parameters)
    {
        scriptFile = ScriptFile(scriptFile);
        var script = System.IO.File.ReadAllText(scriptFile);
        var results = new List<string>();

        // Create credentials object
        var credential = new PSCredential(User, Password);

        var ip = Ip;

        // Create connection info for the remote session
        var connectionUri = new Uri($"http://{ip}:5985/wsman");
        var connectionInfo = new WSManConnectionInfo(connectionUri,
            "http://schemas.microsoft.com/powershell/Microsoft.PowerShell", credential)
        {
            AuthenticationMechanism = AuthenticationMechanism.Basic,
            NoEncryption = true
        };

        // Create runspace
        using (var runspace = RunspaceFactory.CreateRunspace(connectionInfo))
        {
            runspace.Open();

            using (var pipeline = runspace.CreatePipeline())
            {
                // Add the script file as a command
                pipeline.Commands.AddScript(script);

                // Add parameters to the script
                foreach (var parameter in parameters)
                {
                    pipeline.Commands[0].Parameters.Add(parameter.Name, parameter.Value);
                }

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


    public abstract List<string> Run(params (string Name, object Value)[] parameters);
}