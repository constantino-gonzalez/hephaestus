using System.Data;
using Microsoft.Data.SqlClient;
using model;

namespace Refiner;

class Program
{
    static async Task Main(string[] args)
    {
        Console.WriteLine(DateTime.Now.ToString());
        var dirs = System.IO.Directory.GetDirectories(@"C:\data");
        foreach (var dir in dirs)
        {
            try
            {
                var x = new ServerService();
                var serverFile = System.IO.Path.GetFileName(dir);
                var result = x.RefineServer(serverFile);

                if (result.Exception != null || result.ServerModel == null)
                    continue;
                
                try
                {
                    await UnuIm(result.ServerModel);
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.Message);
                }
                
                try
                {
                    await DbJob();
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.Message);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message + e.StackTrace);
            }
        }
    }

    static async Task UnuIm(ServerModel serverModel)
    {
        try
        {
            //unu.im
            var unuSettings = serverModel.Bux.First(a => a.Id == "unu.im");
            if (unuSettings.Enabled)
            {
                var unu = new UnuIm(unuSettings);
                await unu.Process();
            }
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }

    static async Task DbJob()
    {
        await using var connection = new SqlConnection("Server=localhost\\SQLEXPRESS;Database=hephaestus;Trusted_Connection=True;TrustServerCertificate=True;");
        await connection.OpenAsync();
        await using var command = new SqlCommand("dbo.Clean", connection);
        command.CommandType = CommandType.StoredProcedure;
        await command.ExecuteNonQueryAsync();
    }
    
}