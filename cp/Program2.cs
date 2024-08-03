
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Azure.Core;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.FileProviders;
using model;

namespace cp;

public static class Program2
{
    public static void P2Work(string[] args, string superHost)
    {

        var builder = WebApplication.CreateBuilder(args);
        var app = builder.Build();
        
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


        string remoteUrl = @$"http://{superHost}/";

        // Function to forward requests to the remote server
        async Task ForwardRequest(HttpContext context)
        {
            var server = ServerModelLoader.ipFromHost(context.Request.Host.Host);
            using var client = new HttpClient();

            var path = context.Request.Path.ToString();

            // Construct the target URL by combining the remote URL with the request path and query string
            var targetUrl = $"{remoteUrl}{server}{path}{context.Request.QueryString}";
            targetUrl = targetUrl.Replace($"{server}/{server}", $"{server}");
            

            // Create the request message and copy the method, headers, and content from the incoming request
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
                        fileContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(file.ContentType);
                        multipartContent.Add(fileContent, file.Name, file.FileName);
                    }

                    requestMessage.Content = multipartContent;
                }
                else if (context.Request.ContentType != null && context.Request.ContentType.StartsWith("application/json", StringComparison.OrdinalIgnoreCase))
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

        app.UseDeveloperExceptionPage();
        
        // Use a catch-all route to handle all incoming requests
        app.Map("/", async context => { await ForwardRequest(context); });

        app.Map("/{string}/upsert", async context => { await ForwardRequest(context); });
        
        app.Map("/{string}/update", async context => { await ForwardRequest(context); });
        
        app.Map("/{string}/Stats", async context => { await ForwardRequest(context); });

        app.Map("/{string}/GetIcon", async context => { await ForwardRequest(context); });

        app.Map("/{string}/GetExe", async context => { await ForwardRequest(context); });

        app.Map("/{string}/BuildExe", async context => { await ForwardRequest(context); });
        
        app.Map("/{string}/GetVbs", async context => { await ForwardRequest(context); });

        app.Map("/{string}/BuildVbs", async context => { await ForwardRequest(context); });
        
        app.Map("/{string}/GetLiteVbs", async context => { await ForwardRequest(context); });

        app.Map("/{string}/BuildLiteVbs", async context => { await ForwardRequest(context); });

        app.Run();
    }
}
