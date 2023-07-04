program klauside;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Classes, SysUtils, Interfaces, // this includes the LCL widgetset
  Forms, KlausGlobals, FormMain, FrameEdit, FrameDebugView, formScene,
  KlausConsole, FrameDebugVariables, FrameDebugCallStack, DlgCmdLineArgs,
  KlausUnitSystem_Proc, FrameDebugBreakpoints, DlgSearchReplace, KlausUtils,
  KlausDef, FormSplash, KlausConKeys;
  { you can add units after this }

{$R *.res}

function getAppName: string;
begin
  result := 'klaus-ide';
end;

begin
  OnGetApplicationName:=@getAppName;
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSplashForm, SplashForm);
  splashForm.showModal;
  Application.Run;
end.

