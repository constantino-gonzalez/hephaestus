using cp.Models;
using cp.Services;
using Microsoft.AspNetCore.Mvc;

namespace cp.Controllers;

[Route("")]
public class CpController : Controller
{
    private readonly ServerService _serverService;

    public CpController(ServerService serverService)
    {
        _serverService = serverService;
    }
    
    [HttpGet("{server}", Name = "Index")]
    public IActionResult Index(string server)
    {
        var serverModel = _serverService.GetServer(server);
        if (serverModel == null)
        {
            return NotFound();
        }

        return View(serverModel);
    }
    
    [HttpGet("GetIcon/{server}")]
    public IActionResult GetIcon(string server)
    {
        try
        {
            if (!System.IO.File.Exists(_serverService.GetIcon(server))) return NotFound();
            var fileBytes = System.IO.File.ReadAllBytes(_serverService.GetIcon(server));
            Response.Headers.Add("Content-Type", "image/x-icon");
            return File(fileBytes, "image/x-icon");
        }
        catch (Exception)
        {
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost("SaveChanges")]
    public IActionResult SaveChanges(ServerModel updatedModel, string action, IFormFile iconFile, List<IFormFile> newEmbeddings, List<IFormFile> newFront)
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

        updatedModel.Pushes = updatedModel.Pushes.SelectMany(a => a.Split(Environment.NewLine))
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
        updatedModel.Interfaces = existingModel.Interfaces;
        foreach (var item in updatedModel.IpDomains)
        {
            if (existingModel.Interfaces.Contains(item.Key))
            {
                existingModel.Domains[existingModel.Interfaces.IndexOf(item.Key)] = item.Value;
            }
        }
        
        //service
        _serverService.PostServer(existingModel.Server, existingModel);

        return RedirectToAction("Index", new { server = existingModel.Server });
    }
}