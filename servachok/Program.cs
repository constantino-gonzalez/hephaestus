using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;
using System.Net.Http;
using System.Threading.Tasks;
using System.Linq;
using System.Text.Json;
using cp.Models;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

ServerModel server = JsonSerializer.Deserialize<ServerModel>(System.IO.File.ReadAllText(@"C:\_x\data\server.json")); 

string remoteUrl = @$"http://{server.DomainController}/{server.Server}";

// Function to forward requests to the remote server
async Task ForwardRequest(HttpContext context)
{
    using var client = new HttpClient();

    var path = context.Request.Path.ToString();
    path = path.Replace($"{server.Server}/", $"");
    
    // Construct the target URL by combining the remote URL with the request path and query string
    var targetUrl = $"{remoteUrl}{path}{context.Request.QueryString}";

   

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
            requestMessage.Content?.Headers.TryAddWithoutValidation(header.Key, (IEnumerable<string>)header.Value);
        }
    }

    // Copy the content if it is a POST or PUT request
    if (context.Request.Method == HttpMethod.Post.Method || context.Request.Method == HttpMethod.Put.Method)
    {
        if (context.Request.HasFormContentType)
        {
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
        else
        {
            requestMessage.Content = new StreamContent(context.Request.Body);
        }
    }

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

// Use a catch-all route to handle all incoming requests
app.Map("/", async context =>
{
    await ForwardRequest(context);
});

app.Map("/{string}/GetIcon", async context =>
{
    await ForwardRequest(context);
});

app.Map("/{string}/GetExe", async context =>
{
    await ForwardRequest(context);
});

app.Map("/{string}/BuildExe", async context =>
{
    await ForwardRequest(context);
});

var additionalStaticFilesPath = server.UserWebFolder;
var additionalStaticFileProvider = new PhysicalFileProvider(additionalStaticFilesPath);

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = additionalStaticFileProvider,
    RequestPath = "/web"
});

app.UseDeveloperExceptionPage();

app.Run();