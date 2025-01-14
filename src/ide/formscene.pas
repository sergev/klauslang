{
Этот файл — часть KlausLang.

KlausLang — свободное программное обеспечение: вы можете перераспространять 
его и/или изменять его на условиях Стандартной общественной лицензии GNU 
в том виде, в каком она была опубликована Фондом свободного программного 
обеспечения; либо версии 3 лицензии, либо (по вашему выбору) любой более 
поздней версии.

Программное обеспечение KlausLang распространяется в надежде, что оно будет 
полезным, но БЕЗ ВСЯКИХ ГАРАНТИЙ; даже без неявной гарантии ТОВАРНОГО ВИДА 
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
  ActnList, ComCtrls, ExtCtrls, Buttons, StdCtrls, U8, KlausGlobals,
  KlausConsole, KlausPaintBox, KlausSrc, KlausLex, KlausSyn, KlausErr,
  KlausPract;

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
    actCloseFinished: tAction;
    actNextTab: tAction;
    actPrevTab: tAction;
    actionList: tActionList;
    PageControl: tPageControl;
    ScrollBox: tScrollBox;
    tsConsole: tTabSheet;
    procedure actCloseFinishedExecute(sender: tObject);
    procedure actNextTabExecute(sender: tObject);
    procedure actPrevTabExecute(sender: tObject);
    procedure formClose(sender: tObject; var closeAction: tCloseAction);
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    procedure formShow(sender: tObject);
  private
    fConsole: tKlausConsole;
    fFileName: string;
    fRunOptions: tKlausRunOptions;
    fStepMode: boolean;
    fSource: tKlausSource;
    fThread: tKlausDebugThread;
    fExitCode: integer;
    fInStream: tFileStream;
    fOutStream: tFileStream;
    fAutoClose: boolean;
    fTask: tKlausTask;
    fAllSettings: boolean;

    function  getActionState: tSceneActionState;
    function  getFinished: boolean;
    function  getPreviewShortCuts: boolean;
    function  getRunning: boolean;
    function  getStepMode: boolean;
    procedure setFileName(val: string);
    procedure consoleInput(sender: tObject; var input: string; aborted: boolean);
    procedure setPreviewShortCuts(val: boolean);
    procedure startDebugThread;
    procedure destroyDebugThread;
    procedure threadTerminate(sender: tObject);
    procedure threadStateChange(sender: tObject);
    procedure threadAssignStdIO(sender: tObject; var io: tKlausInOutMethods);
    procedure setConsoleRawMode(raw: boolean);
  protected
    procedure enableDisable(var msg: tMessage); message APPM_UpdateControlState;
    function  inStreamHasChar: boolean;
    procedure inStreamReadChar(out c: u8Char);
    procedure outStreamWrite(const s: string);
    function  createGraphTab(const cap: string; link: tKlausCanvasLink): tObject;
    procedure destroyGraphTab(const win: tObject);
    function  createDoerTab(const cap: string): tWinControl;
    procedure destroyDoerTab(tab: tWinControl);
    procedure runNextSetting(var msg: tMessage); message APPM_RunNextSetting;
  public
    property source: tKlausSource read fSource;
    property fileName: string read fFileName;
    property runOptions: tKlausRunOptions read fRunOptions;
    property stepMode: boolean read getStepMode;
    property thread: tKlausDebugThread read fThread;
    property actionState: tSceneActionState read getActionState;
    property running: boolean read getRunning;
    property finished: boolean read getFinished;
    property exitCode: integer read fExitCode;
    property previewShortCuts: boolean read getPreviewShortCuts write setPreviewShortCuts;
    property autoClose: boolean read fAutoClose write fAutoClose;
    property allSettings: boolean read fAllSettings write fAllSettings;

    constructor create(aOwner: tComponent); override;
    constructor create(aSource: tKlausSource; aFileName: string; aRunOptions: tKlausRunOptions; aStepMode: boolean);
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
  LCLIntf, LazFileUtils, Math, FormMain, KlausDoer;

resourcestring
  strExecuting = 'Выполняется: %s';
  strFinishedOK = 'Завершено успешно: %s';
  strFinishedErr = 'Завершено с ошибкой %d: %s';
  strRuntimeError = 'Исключение %s';
  strAtLinePos = 'В файле "%s" (строка %d, символ %d).';
  strConfirmAbort = 'Прервать выполнение программы?';

{ tSceneForm }

constructor tSceneForm.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  tKlausPaintBoxLink.createWindowMethod := @createGraphTab;
  tKlausPaintBoxLink.destroyWindowMethod := @destroyGraphTab;
  tKlausDoer.createWindowMethod := @createDoerTab;
  tKlausDoer.destroyWindowMethod := @destroyDoerTab;
  fRunOptions := tKlausRunOptions.create;
  assert(mainForm.scene = nil, 'Cannot open multiple execution scenes');
  mainForm.scene := self;
  fSource := nil;
  fConsole := tKlausConsole.create(self);
  fConsole.parent := scrollBox;
  fConsole.borderStyle := bsSingle;
  with mainForm.consoleOptions do begin
    fConsole.font := font;
    tKlausPaintBoxLink.defaultFontName := font.name;
    tKlausPaintBoxLink.defaultFontSize := font.size;
    if stayOnTop then self.formStyle := fsStayOnTop;
    self.autoClose := autoClose;
  end;
  fConsole.autoSize := true;
  fConsole.caretType := kctHorzLine;
  fConsole.onInput := @consoleInput;
  fConsole.tabStop := true;
  activeControl := fConsole;
  mainForm.addControlStateClient(self);
  invalidateControlState;
end;

constructor tSceneForm.create(aSource: tKlausSource; aFileName: string; aRunOptions: tKlausRunOptions; aStepMode: boolean);
begin
  create(application);
  fSource := aSource;
  fTask := klausPracticum.findTask(source.module);
  setFileName(aFileName);
  fRunOptions.assign(aRunOptions);
  fStepMode := aStepMode;
end;

destructor tSceneForm.destroy;
begin
  if fTask <> nil then fTask.runningSetting := -1;
  invalidateControlState;
  mainForm.removeControlStateClient(self);
  destroyDebugThread;
  if fSource <> nil then freeAndNil(fSource);
  if mainForm.scene = self then mainForm.scene := nil;
  freeAndNil(fRunOptions);
  tKlausPaintBoxLink.createWindowMethod := nil;
  tKlausPaintBoxLink.destroyWindowMethod := nil;
  tKlausDoer.createWindowMethod := nil;
  tKlausDoer.destroyWindowMethod := nil;
  inherited destroy;
end;

procedure tSceneForm.destroyDebugThread;
begin
  freeAndNil(fThread);
  freeAndNil(fInStream);
  freeAndNil(fOutStream);
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
  pt: tSrcPoint;
begin
  s := e.className;
  if e is eKlausLangException then s := (e as eKlausLangException).message
  else if e is exception then s += ': ' + (e as exception).message;
  fConsole.write(format(strRuntimeError, [s])+#10);
  if (e is eKlausError) then pt := (e as eKlausError).point
  else if (e is eKlausLangException) then pt := (e as eKlausLangException).point
  else pt := zeroSrcPt;
  if not srcPointEmpty(pt) then begin
    fConsole.write(format(strAtLinePos, [pt.fileName, pt.line, pt.pos])+#10);
    if pt.fileName <> '' then mainForm.showErrorInfo(s, pt, false);
  end;
end;

procedure tSceneForm.formClose(sender: tObject; var closeAction: tCloseAction);
begin
  closeAction := caFree;
end;

procedure tSceneForm.actCloseFinishedExecute(sender: tObject);
begin
  if finished then close;
end;

procedure tSceneForm.actNextTabExecute(sender: tObject);
begin
  pageControl.selectNextPage(true);
end;

procedure tSceneForm.actPrevTabExecute(sender: tObject);
begin
  pageControl.selectNextPage(false);
end;

procedure tSceneForm.formCloseQuery(sender: tObject; var canClose: boolean);
begin
  if not running and not fConsole.inputMode then
    canClose := true
  else begin
    fThread.paused := true;
    canClose := messageDlg(strConfirmAbort, mtConfirmation, [mbYes, mbNo], 0) = mrYes;
    if canClose and running then begin
      fThread.terminate;
      fThread.paused := false;
      fThread.waitFor;
    end else
      fThread.paused := false;
  end;
end;

procedure tSceneForm.formShow(sender: tObject);
begin
  if allSettings and (fTask <> nil) then fTask.runningSetting := 0;
  startDebugThread;
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

procedure tSceneForm.startDebugThread;
const
  outStreamMode: array[boolean] of word = (fmCreate, fmOpenWrite);
var
  sl: tStringList = nil;
begin
  try
    if runOptions.cmdLine <> '' then begin
      sl := tStringList.create;
      splitCmdLineParams(runOptions.cmdLine, sl, true);
    end;
    try
      if (fFileName = '') or not assigned(source) then abort;
      if runOptions.stdIn <> '' then
        fInStream := tFileStream.create(runOptions.stdIn, fmOpenRead or fmShareDenyNone);
      if runOptions.stdOut <> '' then begin
        fOutStream := tFileStream.create(runOptions.stdOut, outStreamMode[runOptions.appendStdOut] or fmShareDenyWrite);
        fOutStream.seek(0, soFromEnd);
      end;
    except
      fExitCode := -1;
      raise;
    end;
    fThread := tKlausDebugThread.create(source, fileName, sl);
  except
    freeAndNil(sl);
    raise;
  end;
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
  if allSettings and (fExitCode = 0) then postMessage(handle, APPM_RunNextSetting, 0, 0);
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
  if runOptions.stdIn = '' then begin
    io.hasChar := @fConsole.hasChar;
    io.readChar := @fConsole.readChar;
  end else begin
    io.hasChar := @inStreamHasChar;
    io.readChar := @inStreamReadChar;
  end;
  if runOptions.stdOut = '' then io.writeOut := @fConsole.write
  else io.writeOut := @outStreamWrite;
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
  if finished then begin
    if exitCode = 0 then caption := format(strFinishedOK, [s])
    else caption := format(strFinishedErr, [exitCode, s]);
  end else
    caption := format(strExecuting, [s]);
  actCloseFinished.enabled := finished;
  if assigned(fThread) and (fThread.state = kdsFinished) and autoClose then actCloseFinished.execute;
end;

function tSceneForm.inStreamHasChar: boolean;
begin
  result := true;
end;

procedure tSceneForm.inStreamReadChar(out c: u8Char);
begin
  if fInStream = nil then raise eKlausError.create(ercStreamNotOpen, zeroSrcPt);
  with fInStream do
    if position >= size then c := #26
    else c := u8ReadChar(fInStream);
end;

procedure tSceneForm.outStreamWrite(const s: string);
begin
  if fOutStream = nil then raise eKlausError.create(ercStreamNotOpen, zeroSrcPt);
  if s <> '' then fOutStream.write(pChar(s)^, length(s));
end;

function tSceneForm.createGraphTab(const cap: string; link: tKlausCanvasLink): tObject;
var
  ts: tTabSheet;
  sb: tScrollBox;
  pb: tKlausPaintBox;
begin
  ts := pageControl.addTabSheet;
  ts.caption := cap;
  ts.autoSize := true;
  pageControl.activePage := ts;
  sb := tScrollBox.create(ts);
  sb.autoSize := true;
  sb.autoScroll := true;
  sb.align := alClient;
  sb.parent := ts;
  pb := tKlausPaintBox.create(sb);
  pb.parent := sb;
  pb.tabStop := true;
  activeControl := pb;
  result := pb;
end;

procedure tSceneForm.destroyGraphTab(const win: tObject);
var
  w: tWinControl;
begin
  w := win as tWinControl;
  while not (w is tTabSheet) do begin
    if not assigned(w) then exit;
    w := w.parent;
  end;
  w.free;
end;

function tSceneForm.createDoerTab(const cap: string): tWinControl;
var
  ts: tTabSheet;
begin
  ts := pageControl.addTabSheet;
  ts.caption := cap;
  pageControl.activePage := ts;
  result := ts;
end;

procedure tSceneForm.destroyDoerTab(tab: tWinControl);
begin
  freeAndNil(tab);
end;

procedure tSceneForm.runNextSetting(var msg: tMessage);
var
  idx: integer;
begin
  if (fTask <> nil) and (fTask.doerSettings <> nil) then begin
    idx := max(0, fTask.runningSetting);
    if idx >= fTask.doerSettings.count-1 then exit;
    fTask.runningSetting := idx + 1;
    destroyDebugThread;
    startDebugThread;
  end;
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
  if fThread = nil then result := true
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

initialization
  klausCanvasLinkClass := tKlausPaintBoxLink;
  klausPictureLinkClass := tKlausPictureLink;
end.

