﻿using cp.Models;

namespace cp.Code;

public class PsInstall : PsBase
{
    public PsInstall(ServerModel serverModel) : base(serverModel.Server, serverModel.Login, serverModel.Password)
    {
    }

    public override List<string> Run()
    {
        return ExecuteRemoteScript("install");
    }
}
