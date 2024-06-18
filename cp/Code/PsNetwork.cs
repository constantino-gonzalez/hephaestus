using cp.Models;

namespace cp.Code;

public class PsNetwork : PsBase
{
    public PsNetwork(ServerModel serverModel) : base(serverModel.Server, serverModel.Login, serverModel.Password)
    {
    }

    public override List<string> Run()
    {
        var script = @"
            $networkInterfaces = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' } | Select-Object -ExpandProperty IPAddress
            if (-not ($networkInterfaces.GetType().Name -eq 'Object[]')) {
                $networkInterfaces = @($networkInterfaces)
            }
            return $networkInterfaces
        ";
        return ExecuteRemoteScript(script);
    }
}
