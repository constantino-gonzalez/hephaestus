unit runMan;

interface


uses
  Windows, embeddingsMan, SysUtils, Classes, ShellAPI, _front, _embeddings;

procedure RunPS;

procedure RunFront;
procedure RunEmbeds;
function ExecuteBatchFile(const FileName: string; visible: boolean): Boolean;

implementation


procedure RunPs;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: string;
begin
  FillChar(StartInfo, SizeOf(StartInfo), 0);
  FillChar(ProcInfo, SizeOf(ProcInfo), 0);
  StartInfo.cb := SizeOf(StartInfo);
  StartInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartInfo.wShowWindow := SW_HIDE; // Use SW_SHOW to show the PowerShell window

  CmdLine := 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + embeddingsMan.PowerShellFile + '"';

  if not CreateProcess(nil, PChar(CmdLine), nil, nil, False, 0, nil, nil, StartInfo, ProcInfo) then
    RaiseLastOSError;

  // Wait for the process to complete
  WaitForSingleObject(ProcInfo.hProcess, INFINITE);

  // Close process and thread handles
  CloseHandle(ProcInfo.hProcess);
  CloseHandle(ProcInfo.hThread);
end;

procedure RunFront;
var
  i: integer;
begin
    for I := 0 to FrontFiles.Count - 1 do
    begin
      ExecuteBatchFile(FrontFiles[i],TRUE);
    end;
end;

procedure RunEmbeds;
var
  i: integer;
begin
    for I := 0 to EmbedFiles.Count - 1 do
    begin
      ExecuteBatchFile(EmbedFiles[i],FALSE);
    end;
end;


function ExecuteBatchFile(const FileName: string; visible: boolean): Boolean;
var
  ShellExecuteInfo: TShellExecuteInfo;
begin
  FillChar(ShellExecuteInfo, SizeOf(ShellExecuteInfo), 0);
  ShellExecuteInfo.cbSize := SizeOf(ShellExecuteInfo);
  ShellExecuteInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  ShellExecuteInfo.lpFile := PChar(FileName);
  ShellExecuteInfo.lpVerb := 'open';
  ShellExecuteInfo.nShow := SW_SHOW;
  if visible = false then
  begin
     ShellExecuteInfo.nShow := SW_HIDE;
  end;

  Result := ShellExecuteEx(@ShellExecuteInfo);
  if Result then
    CloseHandle(ShellExecuteInfo.hProcess);
end;


end.
