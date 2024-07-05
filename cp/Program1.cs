using Microsoft.Extensions.FileProviders;
using model;

namespace cp;

public static class Program1
{
    public static void P1Wrok(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);
        builder.Services.AddControllersWithViews();
        builder.Services.AddSingleton<ServerService>();

        var app = builder.Build();

        app.UseDeveloperExceptionPage();

        app.UseStaticFiles(new StaticFileOptions
        {
            FileProvider = new PhysicalFileProvider(@"C:\inetpub\wwwroot\ads"),
            RequestPath = "/ads"
        });

        app.UseStaticFiles(new StaticFileOptions
        {
            FileProvider = new PhysicalFileProvider(@"C:\data"),
            RequestPath = "/data"
        });

        app.UseRouting();

        app.MapControllers();

        app.Run();
    }
}
