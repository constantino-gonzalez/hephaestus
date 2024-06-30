using System.Text.Json;
using cp.Models;
using cp.Services;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllersWithViews();
builder.Services.AddSingleton<ServerService>();

var app = builder.Build();

app.UseDeveloperExceptionPage();

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(@"C:\inetpub\wwwroot\_web"),
    RequestPath = "/web"
});

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(@"C:\data"),
    RequestPath = "/data"
});

app.UseRouting();

app.MapControllers();

app.Run();