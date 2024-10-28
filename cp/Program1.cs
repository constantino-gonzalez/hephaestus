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

        Program.FtpServe(app);
        Program.DataServe(app);

        app.UseRouting();

        app.MapControllers();

        app.Run();
    }
}