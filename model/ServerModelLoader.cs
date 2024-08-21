using System.Diagnostics;
using System.Net;
using System.Net.Sockets;
using System.Text.RegularExpressions;

namespace model
{

    public static class ServerModelLoader
    {
        public static string ipFromHost(string host)
        {
            // Regular expression to match an IPv4 address
            string ipv4Pattern = @"^(\d{1,3}\.){3}\d{1,3}$";

            // Check if the host is already an IPv4 address
            if (Regex.IsMatch(host, ipv4Pattern))
            {
                // Validate if the matched string is a valid IPv4 address
                if (IPAddress.TryParse(host, out IPAddress ip))
                {
                    return host;
                }
            }

            try
            {
                // Get the IP addresses associated with the host
                IPAddress[] addresses = Dns.GetHostAddresses(host);

                // Return the first IPv4 address found
                foreach (IPAddress address in addresses)
                {
                    if (address.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
                    {
                        return address.ToString();
                    }
                }

                // If no addresses found, return the original host
                return host;
            }
            catch (ArgumentException argEx)
            {
                // Handle specific exception for invalid host names
                Console.WriteLine($"Argument error: {argEx.Message}");
                return host;
            }
            catch (SocketException sockEx)
            {
                // Handle specific exception for DNS errors
                Console.WriteLine($"DNS resolution error: {sockEx.Message}");
                return host;
            }
            catch (Exception ex)
            {
                // Handle any other exceptions
                Console.WriteLine($"General error: {ex.Message}");
                return host;
            }
        }
        
        public static string SourceCertDirStatic
        {
            get
            {
                if (System.IO.Directory.Exists(@"C:\Users\kgons\source\repos\hephaestus\cert"))
                    return @"C:\Users\kgons\source\repos\hephaestus\cert";
                return  @"C:\Users\Administrator\source\repos\hephaestus\cert";
            }
        }
        
        private static string _rootDirStatic = null;

        public static string RootDirStatic
        {
            get
            {
                // Get the stack trace for the current method
                StackTrace stackTrace = new StackTrace(true);
                // Get the first frame (the method that called this method)
                StackFrame frame = stackTrace.GetFrame(0);
                // Get the file path of the source file
                string sourceFilePath = frame.GetFileName();

                if (sourceFilePath != null)
                {
                    // Get the directory of the source file
                    string sourceDirectory = Path.GetDirectoryName(sourceFilePath);

                    // Assuming the solution folder is one level up from the project folder
                    string solutionDirectory = Directory.GetParent(sourceDirectory)?.FullName;

                    _rootDirStatic = solutionDirectory ?? "Solution directory not found";
                }
                return _rootDirStatic;
            }
        }

        public static string RootDataStatic
        {
            get
            {
                return @"C:\data";
            }
        }

        public static string DomainControllerStatic = "185.247.141.76";

        public static string CpDirStatic => Path.Combine(RootDirStatic, "cp");
        
        public static string PhpDirStatic => Path.Combine(RootDirStatic, "php");

        public static string CertDirStatic => Path.Combine(RootDirStatic, "cert");

        public static string SysDirStatic => Path.Combine(RootDirStatic, "sys");

        public static string AdsDirStatic => Path.Combine(RootDirStatic, "ads");
        
        public static string PublishedAdsDirStatic => @"C:\inetpub\wwwroot\ads";
        
        public static string PublishedDataDirStatic => @"C:\inetpub\wwwroot\ads\d-data";
        
        public static string TroyanDirStatic => Path.Combine(RootDirStatic, "troyan/");

        public static string TroyanScriptDirStatic => Path.Combine(RootDirStatic, "troyan/troyanps");

        public static string TroyanDelphiDirStatic => Path.Combine(RootDirStatic, "troyan/troyandelphi");
        
        public static string TroyanVbsDirStatic => Path.Combine(RootDirStatic, "troyan/troyanvbs");
    }
}