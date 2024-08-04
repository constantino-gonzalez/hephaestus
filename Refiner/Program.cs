using model;

namespace Refiner;

class Program
{
    static void Main(string[] args)
    {
        var dirs = System.IO.Directory.GetDirectories(@"C:\data");
        foreach (var dir in dirs)
        {
            try
            {
                var x = new ServerService();
                var serverFile = System.IO.Path.GetFileName(dir);
                x.RefineServer(serverFile);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }
    }
}