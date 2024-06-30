$networkInterfaces = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' } | Select-Object -ExpandProperty IPAddress
if (-not ($networkInterfaces.GetType().Name -eq 'Object[]')) {
    $networkInterfaces = @($networkInterfaces)
}
return $networkInterfaces