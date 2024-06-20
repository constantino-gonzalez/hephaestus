using cp.Models;

namespace cp.Code;

public class PsNetwork : PsBase
{
    public PsNetwork(ServerModel serverModel) : base(serverModel.Server, serverModel.Login, serverModel.Password)
    {
    }

    public override List<string> Run()
    {
        return ExecuteRemoteScript("list");
    }
}
