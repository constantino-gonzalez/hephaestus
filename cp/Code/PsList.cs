using cp.Models;

namespace cp.Code;

public class PsList : PsBase
{
    public PsList(ServerModel serverModel) : base(serverModel.Server, serverModel.Login, serverModel.Password)
    {
    }

    public override List<string> Run()
    {
        return ExecuteRemoteScript("list");
    }
}
