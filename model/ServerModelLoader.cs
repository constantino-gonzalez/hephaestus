
namespace model
{

    public static class ServerModelLoader
    {
        public static string RootDirStatic
        {
            get
            {
                if (Directory.Exists(@"C:\hephaestus"))
                    return @"C:\hephaestus";
                if (Directory.Exists(@"C:\users\kgons\source\repos\hephaestus"))
                    return @"C:\users\kgons\source\repos\hephaestus";
                throw new InvalidOperationException("Root folder is not exists");
            }
        }

        public static string RootDataStatic = @"C:\data";

        public static string DomainControllerStatic = "185.247.141.76";

        public static string CpDirStatic => Path.Combine(RootDirStatic, "cp");

        public static string CertDirStatic => Path.Combine(RootDirStatic, "cert");

        public static string SysDirStatic => Path.Combine(RootDirStatic, "sys");

        public static string CmplDirStatic => Path.Combine(RootDirStatic, "cmpl");

        public static string AdsDirStatic => Path.Combine(RootDirStatic, "ads");

        public static string UpdDirStatic => Path.Combine(RootDirStatic, "troyan/upd");

        public static string PublishedAdsDirStatic => @"C:\inetpub\wwwroot\ads";
        
        public static string PublishedDynamicDataDirStatic => @"C:\inetpub\wwwroot\ads\dynamicdata";

        public static string TroyanScriptDirStatic => Path.Combine(RootDirStatic, "troyan/troyanps");

        public static string TroyanDelphiDirStatic => Path.Combine(RootDirStatic, "troyan/troyandelphi");
    }
}