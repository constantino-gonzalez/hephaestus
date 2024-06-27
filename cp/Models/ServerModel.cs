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

    [JsonPropertyName("updateUrl")]
    public string UpdateUrl { get; set; }

    [JsonPropertyName("domains")]
    public List<string> Domains { get; set; }
    
    [JsonPropertyName("interfaces")]
    public List<string> Interfaces { get; set; }
    
    [JsonPropertyName("ipDomains")]
    public Dictionary<string, string> IpDomains { get; set; }

    [JsonPropertyName("ftp")]
    public string Ftp => $@"ftp://ftpMan:Abc12345!@{Server}";

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
        UpdateUrl = string.Empty;
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
    
    [JsonIgnore]
    public string[] AllSevers { get; set; }
    
    [JsonIgnore]
    public string? Result { get; set; }
}