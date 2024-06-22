using System.Diagnostics;
using System.Management.Automation;
using System.Text;
using System.Text.Json;
using cp.Code;
using cp.Models;

namespace cp.Services;

public class ServerService
{
    private static string RootDir
    {
        get
        {
            var scriptDirectory = AppDomain.CurrentDomain.BaseDirectory;
            var webRootPath = Path.Combine(scriptDirectory, "../../../../");
            webRootPath = Path.GetFullPath(webRootPath);
            return webRootPath;
        }
    }
    
    private static string DataDir
    {
        get
        {
            var scriptDirectory = AppDomain.CurrentDomain.BaseDirectory;
            var webRootPath = Path.Combine(RootDir, "data");
            webRootPath = Path.GetFullPath(webRootPath);
            return webRootPath;
        }
    }
    
    internal string ServakDir
    {
        get
        {
            var scriptDirectory = AppDomain.CurrentDomain.BaseDirectory;
            var webRootPath = Path.Combine(RootDir, "servak");
            webRootPath = Path.GetFullPath(webRootPath);
            return webRootPath;
        }
    }
    
    public string ScriptFile(string scriptName)
    {
        return Path.Combine(RootDir, scriptName + ".ps1");
    }


    internal string Script(string scriptName) =>
        System.IO.File.ReadAllText(ScriptFile(scriptName));

    private static string ServerDir(string serverName)
    {
        return Path.Combine(DataDir, serverName);
    }
    
    public string EmbeddingsDir(string serverName)
    {
        return Path.Combine(ServerDir(serverName), "embeddings");
    }
    
    public string FrontDir(string serverName)
    {
        return Path.Combine(ServerDir(serverName), "front");
    }

    private static string DataFile(string serverName)
    {
        return Path.Combine(ServerDir(serverName), "server.json");
    }
    
    public string GetIcon(string serverName)
    {
        return Path.Combine(ServerDir(serverName), "server.ico");
    }
    
    public string GetEmbedding(string serverName, string embeddingName)
    {
        return Path.Combine(EmbeddingsDir(serverName), embeddingName);
    }
    
    public void DeleteEmbedding(string serverName, string embeddingName)
    {
        File.Delete(GetEmbedding(serverName, embeddingName));
    }
    
    public string GetFront(string serverName, string embeddingName)
    {
        return Path.Combine(FrontDir(serverName), embeddingName);
    }
    
    public void DeleteFront(string serverName, string embeddingName)
    {
        File.Delete(GetFront(serverName, embeddingName));
    }

    public ServerModel? GetServer(string serverName)
    {
        if (!Directory.Exists(ServerDir(serverName)))
            return null;
        
        var server = new ServerModel();
        try
        {
            if (File.Exists(DataFile(serverName)))
                server = JsonSerializer.Deserialize<ServerModel>(File.ReadAllText(DataFile(serverName)))!;
        }
        catch
        {
            // ignored
        }

        server.Server = serverName;

        server.Interfaces = new PsList(server).Run().Where(a => a != server.Server).ToList();

        server.PrimaryDns = server.Interfaces[0];
        server.SecondaryDns = server.PrimaryDns;
        if (server.Interfaces.Count >= 2)
            server.SecondaryDns = server.Interfaces[1];

        server.Embeddings = new List<string>();
        if (Directory.Exists(EmbeddingsDir(serverName)))
            server.Embeddings = Directory.GetFiles(EmbeddingsDir(serverName)).Select(a => Path.GetFileName(a))
                .ToList();
        
        server.Front = new List<string>();
        if (Directory.Exists(FrontDir(serverName)))
            server.Front = Directory.GetFiles(FrontDir(serverName)).Select(a => Path.GetFileName(a))
                .ToList();
        return server;
    }

    public string PostServer(string serverName, ServerModel serverModel, string action)
    {
        if (!Directory.Exists(ServerDir(serverName)))
            Directory.CreateDirectory(ServerDir(serverName));
        File.WriteAllText(DataFile(serverName), JsonSerializer.Serialize(serverModel, new JsonSerializerOptions(){WriteIndented = true}));
        var result = RunPowerShellScript("compile", serverModel) ;
        
        System.IO.File.WriteAllText(Path.Combine(ServerDir(serverName),"compile.bat"),$@"pwsh -File ..\..\compile.ps1 -serverName {serverModel.Server}");
        
        return result;
    }
    
    public string RunPowerShellScript(string scriptFile, ServerModel serverModel)
    {
        var script = ScriptFile(scriptFile); 
        using (Process process = new Process())
        {
            process.StartInfo.FileName = "pwsh.exe";
            process.StartInfo.Arguments = $"-File \"{script}\" -serverName \"{serverModel.Server}\"";
            process.StartInfo.RedirectStandardOutput = true;
            process.StartInfo.RedirectStandardError = true;
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.CreateNoWindow = true;
            process.StartInfo.WorkingDirectory = RootDir;

            StringBuilder output = new StringBuilder();
            StringBuilder error = new StringBuilder();

            process.OutputDataReceived += (sender, e) =>
            {
                if (!string.IsNullOrEmpty(e.Data))
                {
                    output.AppendLine(e.Data);
                }
            };

            process.ErrorDataReceived += (sender, e) =>
            {
                if (!string.IsNullOrEmpty(e.Data))
                {
                    error.AppendLine(e.Data);
                }
            };

            process.Start();

            process.BeginOutputReadLine();
            process.BeginErrorReadLine();

            process.WaitForExit();

            return error.ToString() + "\r\n" + output.ToString();
        }
    }
}