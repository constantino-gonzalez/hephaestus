﻿using System.Security.Cryptography;
using cp.Models;
using cp.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Server.Kestrel.Core.Features;

namespace cp.Controllers;

[Route("")]
public class CpController : Controller
{
    private readonly ServerService _serverService;

    public CpController(ServerService serverService)
    {
        _serverService = serverService;
    }
    
    private string Server(string server)
    {
        if (!string.IsNullOrEmpty(server))
            return server;
        if (Request.Host.Host == "localhost")
            return ServerModel.DomainControllerStatic;
        return Request.Host.Host;
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
            var serverModel = _serverService.GetServer(server);
            if (serverModel == null)
            {
                return View("noserver", new ServerModel(){AllSevers = ServerService.AllServers()});
            }

            return View("Index", serverModel);
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
            if (!System.IO.File.Exists(_serverService.GetExe(server)))
                return NotFound();
            var fileBytes = System.IO.File.ReadAllBytes(_serverService.GetExe(server));
            Response.Headers.Add("Content-Type", "application/octet-stream");
            return File(fileBytes, "application/octet-stream");
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
            Response.Headers.Add("Content-Type", "image/x-icon");
            return File(fileBytes, "image/x-icon");
        }
        catch (Exception)
        {
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost("{server}", Name = "Index")]
    public IActionResult Index(ServerModel updatedModel, string action, IFormFile iconFile, List<IFormFile> newEmbeddings, List<IFormFile> newFront)
    {
        try
        {
            var existingModel = _serverService.GetServer(updatedModel.Server);
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

            //model
            existingModel.Server = updatedModel.Server;
            existingModel.Login = updatedModel.Login;
            existingModel.Password = updatedModel.Password;
            existingModel.Track = updatedModel.Track;
            existingModel.TrackingUrl = updatedModel.TrackingUrl;
            existingModel.AutoStart = updatedModel.AutoStart;
            existingModel.AutoUpdate = updatedModel.AutoUpdate;
            existingModel.Pushes = updatedModel.Pushes;
            existingModel.Front = updatedModel.Front;
            existingModel.ExtractIconFromFront = updatedModel.ExtractIconFromFront;
            existingModel.Embeddings = updatedModel.Embeddings;
            existingModel.Domains = updatedModel.IpDomains.Values.ToList();

            //service
            var result = _serverService.PostServer(existingModel.Server, existingModel, action);

            existingModel.Result = result;
            return View(existingModel);
        }
        catch (Exception e)
        {
            return View(new ServerModel() {Server = updatedModel.Server, Result = e.Message + "\r\n" + e.StackTrace });
        }
    }
}