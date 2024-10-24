using cp.Code;
using Microsoft.Extensions.FileProviders;
using model;

namespace cp;

public static class Program1
{
    public static void P1Work(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);
        builder.Services.AddControllersWithViews();
        builder.Services.AddSingleton<ServerService>();
        builder.Services.AddHostedService<BackSvc>();

        var app = builder.Build();

        app.UseDeveloperExceptionPage();

        try
        {
            app.UseStaticFiles(new StaticFileOptions
            {
                FileProvider = new PhysicalFileProvider(ServerModelLoader.PublishedAdsDirStatic),
                RequestPath = "/ftp"
            });

        }
        catch (Exception e)
        {
            
        }

        app.UseRouting();

        app.MapControllers();

        app.Run();
    }
}