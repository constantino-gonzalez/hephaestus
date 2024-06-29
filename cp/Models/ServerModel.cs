using System.Text.Json.Serialization;

namespace cp.Models;

public class ServerModel
{
    [JsonPropertyName("server")] 
    
    public string Server { get; set; }
    
    [JsonPropertyName("login")] 
    public string Login { get; set; }
    
    [JsonPropertyName("password")]
    public string Password { get; set; }
    
    [JsonPropertyName("primaryDns")]
    public string PrimaryDns { get; set; }
    
    [JsonPropertyName("secondaryDns")]
    public string SecondaryDns { get; set; }

    [JsonPropertyName("track")]
    public bool Track { get; set; }

    [JsonPropertyName("trackingUrl")]
    public string TrackingUrl { get; set; }

    [JsonPropertyName("autoStart")]
    public bool AutoStart { get; set; }

    [JsonPropertyName("autoUpdate")]
    public bool AutoUpdate { get; set; }

    [JsonPropertyName("updateUrl")] public string UpdateUrl => $"http://{Server}/data/update.ps1";

    [JsonPropertyName("domains")]
    public List<string> Domains { get; set; }
    
    [JsonPropertyName("interfaces")]
    public List<string> Interfaces { get; set; }
    
    [JsonPropertyName("ipDomains")]
    public Dictionary<string, string> IpDomains { get; set; }
    
    [JsonPropertyName("pushes")]
    public List<string> Pushes { get; set; }

    [JsonPropertyName("front")]
    public List<string> Front { get; set; }
    
    [JsonPropertyName("extractIconFromFront")]
    public bool ExtractIconFromFront { get; set; }

    [JsonPropertyName("embeddings")]
    public List<string> Embeddings { get; set; }

    public ServerModel()
    {
        Server = "1.1.1.1";
        Login = "login";
        Password = "password";
        Track = false;
        TrackingUrl = string.Empty;
        AutoStart = false;
        AutoUpdate = false;
        Domains = new List<string>();
        Interfaces = new List<string>();
        Pushes = new List<string>();
        IpDomains = new();
        Front = new List<string>();
        ExtractIconFromFront = false;
        Embeddings = new List<string>();
    }

    [JsonPropertyName("domainController")]
    public string DomainController => "185.247.141.76";
    
    [JsonPropertyName("userRootFolder")] public string UserRootFolder => @"C:\_x";
    
    [JsonPropertyName("userCertDir")] public string UserCertDir => Path.Combine(UserRootFolder, "cert");
    
    [JsonPropertyName("userServakDir")] public string UserServakDir => Path.Combine(UserRootFolder, "servak");
    
    [JsonPropertyName("userServachokDir")] public string UserServachokDir => Path.Combine(UserRootFolder, "servachok");

    [JsonPropertyName("userDataFolder")] public string UserDataFolder => @"C:\_x\data";
    
    [JsonPropertyName("userServerFile")] public string UserServerFile => Path.Combine(UserDataFolder, "server.json");
    
    [JsonPropertyName("updateFile")] public string UpdateFile => Path.Combine(UserDataFolder, "update.ps1");
    
    [JsonPropertyName("userWebFolder")] public string UserWebFolder => @"C:\inetpub\wwwroot\_web";
    
    
    [JsonPropertyName("ftpWeb")]
    public string FtpWeb => $@"ftp://ftpweb:Abc12345!@{Server}";

    [JsonPropertyName("ftpUserData")] public string FtpUserData { get; set; }
    
    [JsonPropertyName("ftpWebAsHttp")]
    public string FtpWebAsHttp => $@"http://{Server}/web";
    
    [JsonPropertyName("ftpUserDataAsHttp")]
    public string FtpUserDataAsHttp =>  $@"http://{Server}/data";
    
    [JsonIgnore]
    public string[] AllSevers { get; set; }
    
    [JsonIgnore]
    public string? Result { get; set; }
}