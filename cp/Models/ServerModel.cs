using System.Text.Json.Serialization;

namespace cp.Models;

public class ServerModel
{
    [JsonPropertyName("server")] public string Server { get; set; }
    
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
    
    public List<string> Interfaces { get; set; }
    
    public Dictionary<string, string> IpDomains
    {
        get
        {
            var zippedDictionary = Interfaces.Zip(Domains, (iface, domain) => new { Interface = iface, Domain = domain })
                .Where(pair => Domains.Contains(pair.Domain))
                .ToDictionary(pair => pair.Interface, pair => pair.Domain);
            return zippedDictionary;
        }
        set
        {
            Domains = value.Values.ToList();
        }
    }

    [JsonPropertyName("ftp")]
    public string Ftp { get; set; }

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
        Server = string.Empty;
        Track = false;
        TrackingUrl = string.Empty;
        AutoStart = false;
        AutoUpdate = false;
        UpdateUrl = string.Empty;
        Domains = new List<string>();
        Interfaces = new List<string>();
        Ftp = string.Empty;
        Pushes = new List<string>();
        Front = new List<string>();
        ExtractIconFromFront = false;
        Embeddings = new List<string>();
    }
}