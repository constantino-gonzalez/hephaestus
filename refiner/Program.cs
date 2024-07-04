using model;

namespace refiner;

class Program
{
    static void Main(string[] args)
    {
        var x = new ServerService();
        x.GetServer(args[0]);
    }
}