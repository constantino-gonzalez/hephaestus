using Microsoft.Extensions.FileProviders;
using model;

namespace cp;

public static class Program
{
    public static void Main(string[] args)
    {
        var superHost = System.Environment.GetEnvironmentVariable("SuperHost", EnvironmentVariableTarget.Machine);
        if (string.IsNullOrEmpty(superHost))
            Program1.P1Wrok(args);
        else
            Program2.P2Work(args, superHost);
    }
}
