{
Этот файл — часть KlausLang.

KlausLang — свободное программное обеспечение: вы можете перераспространять 
его и/или изменять его на условиях Стандартной общественной лицензии GNU 
в том виде, в каком она была опубликована Фондом свободного программного 
обеспечения; либо версии 3 лицензии, либо (по вашему выбору) любой более 
поздней версии.

Программное обеспечение KlausLang распространяется в надежде, что оно будет 
полезным, но БЕЗО ВСЯКИХ ГАРАНТИЙ; даже без неявной гарантии ТОВАРНОГО ВИДА 
или ПРИГОДНОСТИ ДЛЯ ОПРЕДЕЛЕННЫХ ЦЕЛЕЙ. 

Подробнее см. в Стандартной общественной лицензии GNU.
Вы должны были получить копию Стандартной общественной лицензии GNU вместе 
с этим программным обеспечением. Кроме того, с текстом лицензии  можно
ознакомиться здесь: <https://www.gnu.org/licenses/>.
}

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

