using System.Net;
using System.Net.NetworkInformation;
using Microsoft.Extensions.FileProviders;
using model;

namespace cp;

public static class Program
{
    public static string SuperHost =>
        System.Environment.GetEnvironmentVariable("SuperHost", EnvironmentVariableTarget.Machine)!;
    public static bool IsSuperHost => !string.IsNullOrEmpty(SuperHost);

    public static async Task Main(string[] args)
    {
        await BackSvc.DoWork();
        if (!IsSuperHost)
            Program1.P1Work(args);
        else
            Program2.P2Work(args, SuperHost);
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
        var allIps = GetPublicIPv4Addresses();
        var rec = BackSvc.Map.First(a => allIps.Contains(a.Value));
        var path = System.IO.Path.Join(ServerModelLoader.RootDataStatic, rec.Value);
        app.UseStaticFiles(new StaticFileOptions
        {
            FileProvider = new PhysicalFileProvider(path),
            RequestPath = $"/data"
        });
    }

    public static List<string> GetPublicIPv4Addresses()
    {
        List<string> ipv4Addresses = new List<string>();

        foreach (NetworkInterface ni in NetworkInterface.GetAllNetworkInterfaces())
        {
            if (ni.OperationalStatus == OperationalStatus.Up)
            {
                foreach (UnicastIPAddressInformation ip in ni.GetIPProperties().UnicastAddresses)
                {
                    if (ip.Address.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork) // IPv4
                    {
                        // Filter out private IP ranges
                        if (!IsPrivateIP(ip.Address))
                        {
                            ipv4Addresses.Add(ip.Address.ToString());
                        }
                    }
                }
            }
        }

        return ipv4Addresses;
    }

    public static bool IsPrivateIP(IPAddress ipAddress)
    {
        byte[] bytes = ipAddress.GetAddressBytes();
        return bytes[0] switch
        {
            10 => true, // 10.0.0.0 - 10.255.255.255
            172 => bytes[1] >= 16 && bytes[1] <= 31, // 172.16.0.0 - 172.31.255.255
            192 => bytes[1] == 168, // 192.168.0.0 - 192.168.255.255
            _ => false,
        };
    }
}