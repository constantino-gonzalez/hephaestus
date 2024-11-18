using model;

namespace cp;

public class BackSvc: BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        try
        {
            await DoWork();
        }
        catch (Exception e)
        {
       
        }
        await Task.Delay(1 * 1000 * 60 * 7, stoppingToken);
    }

    public static Dictionary<string, string> Map = new Dictionary<string, string >();

    public static string GetServer(string host)
    {
        try
        {
            if (host == "" || host == "localhost" || host == "127.0.0.1")
                return ServerModelLoader.DomainControllerStatic;
            return Map[host];
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }
    }
    public static string GetServer(HostString host)
    {
        return GetServer(host.Host);
    }
    
    public static async Task DoWork()
    {
        var dirs = System.IO.Directory.GetDirectories(@"C:\data");
        var result = new Dictionary<string, string>();
        foreach (var dir in dirs)
        {
            var x = new ServerService();
            var serverFile = System.IO.Path.GetFileName(dir);
            var a = x.GetServer(serverFile, false).ServerModel!;
            result.Add(a.Alias, a.Server);
        }
        Map = result;
    }
}