using model;

namespace cp;

public static class Program
{
    public static string SuperHost =>
        System.Environment.GetEnvironmentVariable("SuperHost", EnvironmentVariableTarget.Machine)!;
    public static bool IsSuperHost => !string.IsNullOrEmpty(SuperHost);

    public static async Task Main(string[] args)
    {
        if (!IsSuperHost)
            Program1.P1Work(args);
        else
            Program2.P2Work(args, SuperHost);
    }
}