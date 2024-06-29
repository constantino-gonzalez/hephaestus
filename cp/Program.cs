using System.Text.Json;
using cp.Models;
using cp.Services;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllersWithViews();
builder.Services.AddSingleton<ServerService>();

var app = builder.Build();

app.UseDeveloperExceptionPage();

try
{
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new PhysicalFileProvider(@"C:\inetpub\wwwroot\_web"),
        RequestPath = "/web"
    });
}
catch (Exception e)
{
    Console.WriteLine(e);
}

try
{
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new PhysicalFileProvider(@"C:\_x\data"),
        RequestPath = "/data"
    });

}
catch (Exception e)
{
    Console.WriteLine(e);
}

app.UseRouting();

app.MapControllers();

app.Run();