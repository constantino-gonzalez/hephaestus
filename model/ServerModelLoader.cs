namespace model;

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
            if (Directory.Exists(@"C:\_temp"))
                return @"C:\_temp";
            throw new InvalidOperationException("Root folder is not exists");
        }
    }
    
    public static string CpDirStatic => Path.Combine(RootDirStatic, "cp");
    
    public static string CertDirStatic => Path.Combine(RootDirStatic, "cert");
}