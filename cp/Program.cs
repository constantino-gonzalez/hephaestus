namespace cp;

public static class Program
{
    public static void Main(string[] args)
    {
        var superHost = System.Environment.GetEnvironmentVariable("SuperHost", EnvironmentVariableTarget.Machine);
        if (string.IsNullOrEmpty(superHost))
            Program1.P1Work(args);
        else
            Program2.P2Work(args, superHost);
    }
}