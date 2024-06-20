using System.Text.Json;
using cp.Code;
using cp.Models;

namespace cp.Services;

public class ServerService
{
    private static string DataDir
    {
        get
        {
            var scriptDirectory = AppDomain.CurrentDomain.BaseDirectory;
            var webRootPath = Path.Combine(scriptDirectory, "../../../../data");
            webRootPath = Path.GetFullPath(webRootPath);
            return webRootPath;
        }
    }
    
    internal string ServakDir
    {
        get
        {
            var scriptDirectory = AppDomain.CurrentDomain.BaseDirectory;
            var webRootPath = Path.Combine(scriptDirectory, "../../../../servak");
            webRootPath = Path.GetFullPath(webRootPath);
            return webRootPath;
        }
    }

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

        server.Interfaces = new PsNetwork(server).Run();

        server.PrimaryDns = server.Interfaces[0];
        server.SecondaryDns = server.PrimaryDns;
        if (server.Interfaces.Count >= 2)
            server.SecondaryDns = server.Interfaces[1];

        server.Embeddings = Directory.GetFiles(EmbeddingsDir(serverName)).Select(a => Path.GetFileName(a))
            .ToList();
        
        server.Front = Directory.GetFiles(FrontDir(serverName)).Select(a => Path.GetFileName(a))
            .ToList();

        server.ServakDir = ServakDir;
        
        if (!Directory.Exists(ServerDir(serverName)))
            Directory.CreateDirectory(ServerDir(serverName));
        File.WriteAllText(DataFile(serverName), JsonSerializer.Serialize(server, new JsonSerializerOptions(){WriteIndented = true}));      
        return server;
    }

    public void PostServer(string serverName, ServerModel serverModel)
    {
        if (!Directory.Exists(ServerDir(serverName)))
            Directory.CreateDirectory(ServerDir(serverName));
        File.WriteAllText(DataFile(serverName), JsonSerializer.Serialize(serverModel, new JsonSerializerOptions(){WriteIndented = true}));   
    }
}