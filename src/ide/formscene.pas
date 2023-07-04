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

unit FormScene;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, Messages, LMessages, Forms, Controls, Graphics, Dialogs,
  ActnList, KlausGlobals, KlausConsole, KlausSrc, KlausLex, KlausSyn, KlausErr;

type
  tSceneActionStateFlag = (
    sasCanRun,
    sasCanStop,
    sasCanPause,
    sasCanStepInto,
    sasCanStepOver,
    sasHasExecPoint);
  tSceneActionState = set of tSceneActionStateFlag;

type
  tSceneForm = class(tForm)
    actCloseFinished: TAction;
    actionList: TActionList;
    procedure actCloseFinishedExecute(Sender: TObject);
    procedure formClose(sender: tObject; var closeAction: tCloseAction);
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    procedure formShow(sender: tObject);
  private
    fConsole: tKlausConsole;
    fFileName: string;
    fCmdLine: string;
    fStepMode: boolean;
    fSource: tKlausSource;
    fThread: tKlausDebugThread;
    fExitCode: integer;

    function  getActionState: tSceneActionState;
    function  getFinished: boolean;
    function  getPreviewShortCuts: boolean;
    function  getRunning: boolean;
    function  getStepMode: boolean;
    procedure setFileName(val: string);
    procedure consoleInput(sender: tObject; var input: string; aborted: boolean);
    procedure setPreviewShortCuts(val: boolean);
    procedure startDebugThread(args: tStrings);
    procedure threadTerminate(sender: tObject);
    procedure threadStateChange(sender: tObject);
    procedure threadAssignStdIO(sender: tObject; var io: tKlausInOutMethods);
    procedure setConsoleRawMode(raw: boolean);
  protected
    procedure enableDisable(var msg: tMessage); message APPM_UpdateControlState;
  public
    property source: tKlausSource read fSource;
    property fileName: string read fFileName;
    property cmdLine: string read fCmdLine;
    property stepMode: boolean read getStepMode;
    property thread: tKlausDebugThread read fThread;
    property actionState: tSceneActionState read getActionState;
    property running: boolean read getRunning;
    property finished: boolean read getFinished;
    property exitCode: integer read fExitCode;
    property previewShortCuts: boolean read getPreviewShortCuts write setPreviewShortCuts;

    constructor create(aOwner: tComponent); override;
    constructor create(aSource: tKlausSource; aFileName: string; aCmdLine: string; aStepMode: boolean);
    destructor  destroy; override;
    procedure invalidateControlState;
    procedure updateBreakpointList;
    procedure pause;
    procedure resume;
    procedure step(over: boolean);
    procedure displayException(e: tObject);
  end;

implementation

{$R *.lfm}

uses
  LCLIntf, LazFileUtils, FormMain;

resourcestring
  strExecuting = 'Выполняется: %s';
  strFinished = 'Завершено с кодом %d: %s';
  strRuntimeError = 'Исключение %s';
  strAtLinePos = 'Строка %d, символ %d.';
  strConfirmAbort = 'Прервать выполнение программы?';

{ tSceneForm }

constructor tSceneForm.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  assert(mainForm.scene = nil, 'Cannot open multiple execution scenes');
  mainForm.scene := self;
  fSource := nil;
  fConsole := tKlausConsole.create(self);
  fConsole.parent := self;
  fConsole.borderStyle := bsSingle;
  fConsole.borderSpacing.around := 4;
  {$ifdef windows} fConsole.font.name := 'Courier New';
  {$else} fConsole.font.name := 'Monospace'; {$endif}
  fConsole.font.size := 11;
  fConsole.autoSize := true;
  fConsole.caretType := kctHorzLine;
  fConsole.onInput := @consoleInput;
  fConsole.tabStop := true;
  mainForm.addControlStateClient(self);
  invalidateControlState;
end;

constructor tSceneForm.create(aSource: tKlausSource; aFileName: string; aCmdLine: string; aStepMode: boolean);
begin
  create(application);
  fSource := aSource;
  setFileName(aFileName);
  fCmdLine := aCmdLine;
  fStepMode := aStepMode;
end;

destructor tSceneForm.destroy;
begin
  invalidateControlState;
  mainForm.removeControlStateClient(self);
  if fThread <> nil then freeAndNil(fThread);
  if fSource <> nil then freeAndNil(fSource);
  if mainForm.scene = self then mainForm.scene := nil;
  inherited destroy;
end;

procedure tSceneForm.invalidateControlState;
begin
  mainForm.invalidateControlState;
end;

procedure tSceneForm.pause;
begin
  fThread.stepMode := true;
  invalidateControlState;
end;

procedure tSceneForm.resume;
begin
  fThread.stepMode := false;
  invalidateControlState;
end;

procedure tSceneForm.step(over: boolean);
begin
  fThread.step(over);
end;

procedure tSceneForm.displayException(e: tObject);
var
  s: string;
  l: integer = 0;
  p: integer = 0;
begin
  s := e.className;
  if e is eKlausLangException then s := (e as eKlausLangException).message
  else if e is exception then s += ': ' + (e as exception).message;
  fConsole.write(format(strRuntimeError, [s])+#10);
  if (e is eKlausError) then begin
    l := (e as eKlausError).line;
    p := (e as eKlausError).pos;
  end else if (e is eKlausLangException) then begin
    l := (e as eKlausLangException).line;
    p := (e as eKlausLangException).pos;
  end;
  if (p > 0) then begin
    fConsole.write(format(strAtLinePos, [l, p])+#10);
    mainForm.showErrorInfo(fileName, s, l, p, false);
  end;
end;

procedure tSceneForm.formClose(sender: tObject; var closeAction: tCloseAction);
begin
  closeAction := caFree;
end;

procedure tSceneForm.actCloseFinishedExecute(Sender: TObject);
begin
  if finished then close;
end;

procedure tSceneForm.formCloseQuery(sender: tObject; var canClose: boolean);
begin
  if not running and not fConsole.inputMode then
    canClose := true
  else begin
    canClose := messageDlg(strConfirmAbort, mtConfirmation, [mbYes, mbNo], 0) = mrYes;
    if canClose and running then begin
      fThread.terminate;
      fThread.waitFor;
    end;
  end;
end;

procedure tSceneForm.formShow(sender: tObject);
var
  sl: tStringList = nil;
begin
  try
    if cmdLine <> '' then begin
      sl := tStringList.create;
      splitCmdLineParams(cmdLine, sl, true);
    end;
    startDebugThread(sl);
  except
    freeAndNil(sl);
    raise;
  end;
end;

procedure tSceneForm.setFileName(val: string);
begin
  if fFileName <> val then begin
    fFileName := val;
    invalidateControlState;
  end;
end;

procedure tSceneForm.consoleInput(sender: tObject; var input: string; aborted: boolean);
begin
  if fThread = nil then exit;
  fThread.inputDone;
end;

procedure tSceneForm.setPreviewShortCuts(val: boolean);
begin
  fConsole.previewShortCuts := val;
end;

procedure tSceneForm.startDebugThread(args: tStrings);
begin
  if (fFileName = '') or not assigned(source) then exit;
  fThread := tKlausDebugThread.create(source, fileName, args);
  fThread.onTerminate := @threadTerminate;
  fThread.onStateChange := @threadStateChange;
  fThread.onAssignStdIO := @threadAssignStdIO;
  fThread.stepMode := fStepMode;
  fThread.waitForInput := true;
  updateBreakpointList;
  fThread.start;
end;

procedure tSceneForm.threadTerminate(sender: tObject);
var
  e: tObject;
begin
  fConsole.endInput(true);
  e := fThread.fatalException;
  if assigned(e) then displayException(e);
  fExitCode := fThread.returnValue;
  invalidateControlState;
  if canFocus then setFocus;
end;

procedure tSceneForm.threadStateChange(sender: tObject);
begin
  mainForm.updateDebugInfo;
  invalidateControlState;
  if fThread = nil then exit;
  if fThread.state = kdsWaitInput then begin
    fConsole.beginInput;
    if canFocus then setFocus;
  end;
end;

procedure tSceneForm.threadAssignStdIO(sender: tObject; var io: tKlausInOutMethods);
begin
  io.setRaw := @setConsoleRawMode;
  io.hasChar := @fConsole.hasChar;
  io.readChar := @fConsole.readChar;
  io.writeOut := @fConsole.write;
  io.writeErr := @fConsole.write;
end;

procedure tSceneForm.setConsoleRawMode(raw: boolean);
begin
  fConsole.rawMode := raw;
end;

procedure tSceneForm.updateBreakpointList;
begin
  if fThread <> nil then
    fThread.setBreakpoints(mainForm.getBreakpoints);
end;

procedure tSceneForm.enableDisable(var msg: tMessage);
var
  s: string;
begin
  s := extractFileName(fFileName);
  if finished then caption := format(strFinished, [exitCode, s])
  else caption := format(strExecuting, [s]);
  actCloseFinished.enabled := finished;
end;

function tSceneForm.getActionState: tSceneActionState;
begin
  result := [sasCanStop];
  if fThread = nil then exit;
  case fThread.state of
    kdsWaitStep: result += [sasCanRun, sasCanStepInto, sasCanStepOver, sasHasExecPoint];
    kdsWaitInput: if not fThread.stepMode then result += [sasCanPause];
    kdsRunning: result += [sasCanPause];
  end;
end;

function tSceneForm.getFinished: boolean;
begin
  if fThread = nil then result := false
  else result := fThread.state = kdsFinished;
end;

function tSceneForm.getPreviewShortCuts: boolean;
begin
  result := fConsole.previewShortCuts;
end;

function tSceneForm.getRunning: boolean;
begin
  if fThread = nil then result := false
  else result := fThread.state <> kdsFinished;
end;

function tSceneForm.getStepMode: boolean;
begin
  if fThread = nil then result := fStepMode
  else result := fThread.stepMode;
end;

end.

