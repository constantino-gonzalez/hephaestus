@echo off
set file_to_delete=".\troyan.vbs"


if exist %file_to_delete% (
    del %file_to_delete%
    echo File %file_to_delete% deleted.
) else (
    echo File %file_to_delete% not found.
)

powershell ./win/dns.ps1
powershell ./win/iis.ps1
powershell ./troyan/compile.ps1