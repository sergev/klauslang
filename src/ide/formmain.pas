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

unit FormMain;

{$mode objfpc}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, Messages, LMessages, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, ActnList, ComCtrls, IniPropStorage, LazUTF8, KlausEdit,
  KlausGlobals, FrameEdit, FrameDebugView, KlausSrc, KlausErr, KlausLex, FormScene,
  Types, KlausPract, FrameCourseInfo, KlausDoer;

const
  configName = 'klaus-ide.ini';
  maxRecentFiles = 5;
  maxCmdLineArgHistoryItems = 100;
  maxSearchHistoryItems     = 100;
  maxReplaceHistoryItems    = 100;
  maxEvaluateHistoryItems   = 100;

type
  tRunMode = (rmNonStop, rmToCursor, rmStepOver, rmStepInto);

  tExecPointInfo = record
    enabled: boolean;
    point: tSrcPoint;
  end;

  tWatchInfo = record
    text: string;
    allowFunctions: boolean;
  end;

type
  tFixedPropStorage = class(tIniPropStorage)
    public
      procedure StorageNeeded(ReadOnly: Boolean); override;
  end;

type
  tCourseMenuItem = class(tMenuItem)
    private
      fCourse: tKlausCourse;
    public
      property course: tKlausCourse read fCourse write fCourse;
  end;

type
  tMainForm = class(tForm)
    actFileNew: tAction;
    actFileOpen: tAction;
    actFileSave: tAction;
    actFileSaveAs: tAction;
    actFileSaveAll: tAction;
    actFileClose: tAction;
    actFileExit: tAction;
    actEditReplace: tAction;
    actEditSearchNext: tAction;
    actEditSearch: tAction;
    actEditUndo: tAction;
    actEditCut: tAction;
    actEditCopy: tAction;
    actEditPaste: tAction;
    actEditSelectAll: tAction;
    actEditDeleteLine: tAction;
    actEditIndentBlock: tAction;
    actEditUnindentBlock: tAction;
    actHelpAbout: tAction;
    actFileOptions: tAction;
    actDebugWatches: tAction;
    actDebugEvaluateWatch: tAction;
    actHelpReferenceGuide: tAction;
    actRunImmediate: tAction;
    actRunAllSettings: tAction;
    actRunFast: tAction;
    actRunFastest: tAction;
    actRunMedium: tAction;
    actRunSlow: tAction;
    actRunSlowest: tAction;
    actRunInterceptKeyboard: tAction;
    actDebugRunToCursor: tAction;
    actDebugToggleBreakpoint: tAction;
    actRunShowScene: tAction;
    actRunStartArgs: tAction;
    actDebugShowExecPoint: tAction;
    actDebugStepInto: tAction;
    actDebugStepOver: tAction;
    actRunStop: tAction;
    actRunPause: tAction;
    actRunStart: tAction;
    actRunCheckSyntax: tAction;
    actToggleBookmark0: tAction;
    actToggleBookmark1: tAction;
    actToggleBookmark2: tAction;
    actToggleBookmark3: tAction;
    actToggleBookmark4: tAction;
    actToggleBookmark5: tAction;
    actToggleBookmark6: tAction;
    actToggleBookmark7: tAction;
    actToggleBookmark8: tAction;
    actToggleBookmark9: tAction;
    actGotoBookmark0: tAction;
    actGotoBookmark1: tAction;
    actGotoBookmark2: tAction;
    actGotoBookmark3: tAction;
    actGotoBookmark4: tAction;
    actGotoBookmark5: tAction;
    actGotoBookmark6: tAction;
    actGotoBookmark7: tAction;
    actGotoBookmark8: tAction;
    actGotoBookmark9: tAction;
    actDebugBreakpoints: tAction;
    actDebugCallStack: tAction;
    actDebugLocalVariables: tAction;
    actWindowMoveTabRight: tAction;
    actWindowMoveTabLeft: tAction;
    actWindowPrevTab: tAction;
    actWindowNextTab: tAction;
    actionList: tActionList;
    actionImages: tImageList;
    applicationProperties: tApplicationProperties;
    bvDebugSizer: tBevel;
    bvCourseSizer: tBevel;
    editLineImages: tImageList;
    MenuItem1: tMenuItem;
    MenuItem2: tMenuItem;
    MenuItem3: tMenuItem;
    miRunImmediate: tMenuItem;
    miRunAllSettings: tMenuItem;
    miRunFastest: tMenuItem;
    miRunFast: tMenuItem;
    miRunMedium: tMenuItem;
    miRunSlow: tMenuItem;
    miRunSlowest: tMenuItem;
    miRunDoerSpeed: tMenuItem;
    miPracticum: tMenuItem;
    miDebug: tMenuItem;
    miDebugBreakpoints: tMenuItem;
    miDebugCallStack: tMenuItem;
    miDebugLocalVariables: tMenuItem;
    miDebugRunToCursor: tMenuItem;
    miDebugShowExecPoint: tMenuItem;
    miDebugStepInto: tMenuItem;
    miDebugStepOver: tMenuItem;
    miDebugToggleBreakpoint: tMenuItem;
    miDebugWatches: tMenuItem;
    miFileOptions: tMenuItem;
    miRunInterceptKeyboard: tMenuItem;
    miHelpAbout: tMenuItem;
    miHelp: tMenuItem;
    miEditIndentBlock: tMenuItem;
    miEditUnindentBlock: tMenuItem;
    miRunToCursor: tMenuItem;
    miToggleBreakpoint: tMenuItem;
    miToggleBookmark9: tMenuItem;
    miToggleBookmark8: tMenuItem;
    miToggleBookmark7: tMenuItem;
    miToggleBookmark6: tMenuItem;
    miToggleBookmark5: tMenuItem;
    miToggleBookmark4: tMenuItem;
    miToggleBookmark3: tMenuItem;
    miToggleBookmark2: tMenuItem;
    miToggleBookmark1: tMenuItem;
    miToggleBookmark0: tMenuItem;
    miToggleBookmark: tMenuItem;
    miGotoBookmark9: tMenuItem;
    migotoBookmark8: tMenuItem;
    miGotoBookmark7: tMenuItem;
    miGotoBookmark6: tMenuItem;
    miGotoBookmark5: tMenuItem;
    miGotoBookmark4: tMenuItem;
    miGotoBookmark3: tMenuItem;
    miGotoBookmark2: tMenuItem;
    miGotoBookmark1: tMenuItem;
    miGotoBookmark0: tMenuItem;
    miGotoBookmark: tMenuItem;
    miRunShowScene: tMenuItem;
    miRunCheckSyntax: tMenuItem;
    miRunStart: tMenuItem;
    miRunStartArgs: tMenuItem;
    miRunPause: tMenuItem;
    miRunStop: tMenuItem;
    miSunStepInto: tMenuItem;
    miRunStepOver: tMenuItem;
    miRunShowExecPoint: tMenuItem;
    miRun: tMenuItem;
    miEditCut: tMenuItem;
    miEditCopy: tMenuItem;
    miEditPaste: tMenuItem;
    miEditSelectAll: tMenuItem;
    miWindowPrevTab: tMenuItem;
    miWindowNextTab: tMenuItem;
    miWindowMoveTabLeft: tMenuItem;
    miWindowMoveTabRight: tMenuItem;
    miWindowLocalVariables: tMenuItem;
    miWindowCallStack: tMenuItem;
    miWindowBreakpoints: tMenuItem;
    miWindow: tMenuItem;
    sbDebug: tScrollBox;
    pnDebugContent: tFlowPanel;
    saveDialog: tSaveDialog;
    sbCourse: tScrollBox;
    Separator1: tMenuItem;
    mainMenu: tMainMenu;
    miEditReplace: tMenuItem;
    miEditSearchNext: tMenuItem;
    miEditSearch: tMenuItem;
    miEditUndo: tMenuItem;
    miFileOpen: tMenuItem;
    miFileSave: tMenuItem;
    miFileSaveAs: tMenuItem;
    miFileSaveAll: tMenuItem;
    miFileExit: tMenuItem;
    miFileClose: tMenuItem;
    openDialog: tOpenDialog;
    pageControl: tPageControl;
    miSepRecent: tMenuItem;
    miEdit: tMenuItem;
    miFile: tMenuItem;
    miFileNew: tMenuItem;
    Separator10: tMenuItem;
    Separator11: tMenuItem;
    Separator12: tMenuItem;
    Separator13: tMenuItem;
    Separator14: tMenuItem;
    Separator2: tMenuItem;
    Separator3: tMenuItem;
    Separator4: tMenuItem;
    Separator5: tMenuItem;
    Separator6: tMenuItem;
    Separator7: tMenuItem;
    Separator8: tMenuItem;
    Separator9: tMenuItem;
    statusBar: tStatusBar;
    tbWindowWatches: tToolButton;
    toolBar: tToolBar;
    tbFileNew: tToolButton;
    tbEditReplace: tToolButton;
    tbFileOpen: tToolButton;
    tbFileSave: tToolButton;
    tbFileClose: tToolButton;
    ToolButton1: tToolButton;
    tbWindowLocalVariables: tToolButton;
    tbWindowCallStack: tToolButton;
    tbEditCut: tToolButton;
    tbEditCopy: tToolButton;
    tbEditPaste: tToolButton;
    ToolButton10: tToolButton;
    tbRunStepInto: tToolButton;
    tbRunStepOver: tToolButton;
    tbRunShowExecPoint: tToolButton;
    tbFileOptions: tToolButton;
    ToolButton11: tToolButton;
    ToolButton12: tToolButton;
    ToolButton13: tToolButton;
    ToolButton14: tToolButton;
    ToolButton15: tToolButton;
    ToolButton16: tToolButton;
    ToolButton17: tToolButton;
    ToolButton2: tToolButton;
    tbRunCheckSyntax: tToolButton;
    tbRunStart: tToolButton;
    ToolButton3: tToolButton;
    tbRunShowScene: tToolButton;
    ToolButton4: tToolButton;
    ToolButton5: tToolButton;
    tbEditUndo: tToolButton;
    tbWindowBreakpoints: tToolButton;
    tbRunStartArgs: tToolButton;
    ToolButton6: tToolButton;
    ToolButton7: tToolButton;
    tbEditSearch: tToolButton;
    tbEditSearchNext: tToolButton;
    tbRunPause: tToolButton;
    tbRunStop: tToolButton;
    ToolButton8: tToolButton;
    ToolButton9: tToolButton;
    procedure actDebugEvaluateWatchExecute(sender: tObject);
    procedure actEditCopyExecute(sender: tObject);
    procedure actEditCutExecute(sender: tObject);
    procedure actEditDeleteLineExecute(sender: tObject);
    procedure actEditIndentBlockExecute(sender: tObject);
    procedure actEditPasteExecute(sender: tObject);
    procedure actEditSearchNextExecute(sender: tObject);
    procedure actEditSearchReplaceExecute(sender: tObject);
    procedure actEditSelectAllExecute(sender: tObject);
    procedure actEditUndoExecute(sender: tObject);
    procedure actEditUnindentBlockExecute(sender: tObject);
    procedure actFileCloseExecute(sender: tObject);
    procedure actFileExitExecute(sender: tObject);
    procedure actFileNewExecute(sender: tObject);
    procedure actFileOpenExecute(sender: tObject);
    procedure actFileOptionsExecute(sender: tObject);
    procedure actFileSaveAllExecute(sender: tObject);
    procedure actFileSaveAsExecute(sender: tObject);
    procedure actFileSaveExecute(sender: tObject);
    procedure actHelpAboutExecute(sender: tObject);
    procedure actHelpReferenceGuideExecute(sender: tObject);
    procedure actRunAllSettingsExecute(sender: tObject);
    procedure actRunCheckSyntaxExecute(sender: tObject);
    procedure actRunFastestExecute(sender: tObject);
    procedure actRunFastExecute(sender: tObject);
    procedure actRunImmediateExecute(sender: tObject);
    procedure actRunInterceptKeyboardExecute(sender: tObject);
    procedure actRunMediumExecute(sender: tObject);
    procedure actRunPauseExecute(sender: tObject);
    procedure actDebugShowExecPointExecute(sender: tObject);
    procedure actRunShowSceneExecute(sender: tObject);
    procedure actRunSlowestExecute(sender: tObject);
    procedure actRunSlowExecute(sender: tObject);
    procedure actRunStartArgsExecute(sender: tObject);
    procedure actRunStartExecute(sender: tObject);
    procedure actDebugStepIntoExecute(sender: tObject);
    procedure actDebugStepOverExecute(sender: tObject);
    procedure actRunStopExecute(sender: tObject);
    procedure actDebugRunToCursorExecute(sender: tObject);
    procedure actDebugToggleBreakpointExecute(sender: tObject);
    procedure actToggleBookmarkExecute(sender: tObject);
    procedure actGotoBookmarkExecute(sender: tObject);
    procedure actDebugBreakpointsExecute(sender: tObject);
    procedure actDebugCallStackExecute(sender: tObject);
    procedure actDebugLocalVariablesExecute(sender: tObject);
    procedure actWindowMoveTabLeftExecute(sender: tObject);
    procedure actWindowMoveTabRightExecute(sender: tObject);
    procedure actWindowNextTabExecute(sender: tObject);
    procedure actWindowPrevTabExecute(sender: tObject);
    procedure actDebugWatchesExecute(sender: tObject);
    procedure applicationHint(sender: tObject);
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    procedure formShortCut(var msg: tLMKey; var handled: boolean);
    procedure formShow(sender: tObject);
    procedure pageControlChange(sender: tObject);
    procedure propStorageRestoreProperties(sender: tObject);
    procedure bvDebugSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvDebugSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
    procedure bvDebugSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvCourseSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvCourseSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
    procedure bvCourseSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure pnDebugContentResize(sender: tObject);
    procedure propStorageRestoringProperties(sender: tObject);
    procedure propStorageSavingProperties(sender: tObject);
    procedure miPracticumCourseClick(sender: tObject);
  private
    fCtlStateClients: tList;
    fPropsLoading: boolean;
    fControlStateInvalid: boolean;
    fRecentFiles: tStringList;
    fDebugPanelSizing: boolean;
    fCoursePanelSizing: boolean;
    fSizingPoint: tPoint;
    fDebugView: array[tDebugViewType] of tDebugViewFrame;
    fScene: tSceneForm;
    fExecPoint: tExecPointInfo;
    fRunToCursor: tKlausBreakpoint;
    fEditStyles: tKlausEditorOptions;
    fConsoleOptions: tKlausConsoleOptions;
    fPracticumOptions: tKlausPracticumOptions;
    fBreakpoints: tKlausBreakpoints;
    fBreakpointListInvalid: boolean;
    fStackFrameIdx: integer;
    fSearchInfo: tSearchInfo;
    fWatches: array of tWatchInfo;
    fCourseFrame: tCourseInfoFrame;
    fCourseInfoInvalid: boolean;

    function  getActiveFrame: tEditFrame;
    function  getBreakpointCount: integer;
    function  getBreakpoint(idx: integer): tKlausBreakpoint;
    function  getConfigFileName: string;
    function  getDebugViews: tDebugViewTypes;
    function  getDbgWgtStoredWidth: integer;
    function  getCourseStoredWidth: integer;
    function  getDoerSpeed: tKlausDoerSpeed;
    function  getFormStoredHeight: integer;
    function  getFormStoredWidth: integer;
    function  getIsRunning: boolean;
    function  getSelectedSetting: tKlausDoerSetting;
    function  getSelectedTask: tKlausTask;
    function  getWatchCount: integer;
    function  getWatches(idx: integer): tWatchInfo;
    procedure setDebugViews(val: tDebugViewTypes);
    function  getFrameCount: integer;
    function  getFrames(idx: integer): tEditFrame;
    function  getRecentFiles: tStrings;
    procedure setActiveFrame(val: tEditFrame; focus: boolean = true);
    procedure setDbgWgtStoredWidth(val: integer);
    procedure setCourseStoredWidth(val: integer);
    procedure setDoerSpeed(val: tKlausDoerSpeed);
    procedure setFormStoredHeight(val: integer);
    procedure setFormStoredWidth(val: integer);
    procedure setStackFrameIdx(value: integer);
    procedure setRecentFiles(val: tStrings);
    procedure updateRecentMenuItems;
    procedure enableRecentMenuItems;
    procedure recentMenuItemClick(sender: tObject);
    function  getDebugView(dvt: tDebugViewType): tDebugViewFrame;
    function  getSessionProperties: string;
    procedure createDebugViews;
    procedure updateDebugViewPositions;
    procedure editStylesChange(sender: tObject);
    procedure refreshPracticumMenu;
    procedure createCourseFrame;
  protected
    procedure createWnd; override;
    function  parentTabSheet(fr: tEditFrame): tTabSheet;
    procedure updateControlState(var msg: tMessage); message APPM_UpdateControlState;
    procedure updateBreakpoints(var msg: tMessage); message APPM_UpdateBreakpoints;
    procedure focusEditor(var msg: tMessage); message APPM_FocusEditor;
    procedure updateCourseInfo(var msg: tMessage); message APPM_UpdateCourseInfo;
    procedure addRecentFile(fn: string);
    procedure enableDisable;
  public
    propStorage: tFixedPropStorage;
    property configFileName: string read getConfigFileName;
    property propsLoading: boolean read fPropsLoading;
    property frameCount: integer read getFrameCount;
    property frames[idx: integer]: tEditFrame read getFrames;
    property activeFrame: tEditFrame read getActiveFrame;
    property scene: tSceneForm read fScene write fScene;
    property isRunning: boolean read getIsRunning;
    property execPoint: tExecPointInfo read fExecPoint;
    property debugView[dvt: tDebugViewType]: tDebugViewFrame read getDebugView;
    property editStyles: tKlausEditorOptions read fEditStyles;
    property consoleOptions: tKlausConsoleOptions read fConsoleOptions;
    property practicumOptions: tKlausPracticumOptions read fPracticumOptions;
    property runToCursor: tKlausBreakpoint read fRunToCursor;
    property breakpointCount: integer read getBreakpointCount;
    property breakpoint[idx: integer]: tKlausBreakpoint read getBreakpoint;
    property stackFrameIdx: integer read fStackFrameIdx write setStackFrameIdx;
    property watchCount: integer read getWatchCount;
    property watches[idx: integer]: tWatchInfo read getWatches;
    property courseFrame: tCourseInfoFrame read fCourseFrame;
    property selectedTask: tKlausTask read getSelectedTask;
    property selectedSetting: tKlausDoerSetting read getSelectedSetting;

    constructor create(aOwner: tComponent); override;
    destructor  destroy; override;
    procedure addControlStateClient(ctl: tControl);
    procedure removeControlStateClient(ctl: tControl);
    procedure invalidateControlState;
    function  findEditFrame(fn: string): tEditFrame;
    function  openEditFrame(fn: string = ''; focus: boolean = true): tEditFrame;
    procedure destroyEditFrame(fr: tEditFrame);
    function  saveEditFrame(fr: tEditFrame; saveAs: boolean = false): boolean;
    function  promptToSaveEditFrame(fr: tEditFrame): boolean;
    procedure createScene(fr: tEditFrame; stepMode, allSettings: boolean);
    procedure updateDebugInfo;
    procedure showExecPoint;
    procedure showErrorInfo(const msg: string; pt: tSrcPoint; focus: boolean = true);
    procedure run(mode: tRunMode; allSettings: boolean);
    procedure invalidateBreakpointList;
    procedure updateBreakpointList;
    function  getBreakpoints: tKlausBreakpoints;
    function  isBreakpoint(const fileName: string; line: integer): boolean;
    procedure gotoSrcPoint(const fileName: string; line, char: integer);
    procedure gotoBreakpoint(idx: integer);
    function  focusedStackFrame: tKlausStackFrame;
    procedure addWatch(const txt: string; allowFunctions: boolean);
    procedure editWatch(idx: integer; const txt: string; allowFunctions: boolean);
    procedure deleteWatch(idx: integer);
    procedure updateDebugViewTabOrder;
    procedure invalidateCourseInfo;
    procedure showCourseInfo(courseName, taskName: string; focus: boolean = false);
    procedure showOptionsDlg(tabName: string = '');
    procedure loadPracticum;
    procedure openTaskSolution(task: tKlausTask);
  published
    property recentFiles: tStrings read getRecentFiles write setRecentFiles;
    property debugViews: tDebugViewTypes read getDebugViews write setDebugViews;
    property dbgWgtStoredWidth: integer read getDbgWgtStoredWidth write setDbgWgtStoredWidth;
    property courseStoredWidth: integer read getCourseStoredWidth write setCourseStoredWidth;
    property formStoredWidth: integer read getFormStoredWidth write setFormStoredWidth;
    property formStoredHeight: integer read getFormStoredHeight write setFormStoredHeight;
    property doerSpeed: tKlausDoerSpeed read getDoerSpeed write setDoerSpeed;
  end;

var
  MainForm: tMainForm;

implementation

uses
  LCLIntf, LCLType, Math, Clipbrd, U8, KlausUtils, DlgCmdLineArgs, DlgSearchReplace, FormSplash, DlgOptions,
  DlgEvaluate;

resourcestring
  strKlaus = 'Клаус';
  strKlausDebugging = 'Клаус - идёт отладка';
  strModified = 'Изменён';
  strConfirmation = 'Подтверждение';
  strPromptToSave = 'Файл "%s" был изменён. Сохранить изменения?';
  strNoErrorFound = 'Ошибки не обнаружены.';
  strFileOpenError = 'Ошибка при открытии файла:'#13#10'%s';
  strListEmpty = '(Список пуст)';
  strPromptCreateDir = 'Каталог "%s" не существует. Создать его?';

{$R *.lfm}

var
  nextFrameIndex: integer = 1;

{ tFixedPropStorage }

procedure tFixedPropStorage.storageNeeded(readOnly: Boolean);
begin
  inherited storageNeeded(readOnly);
  {$PUSH}{$WARNINGS OFF}iniFile.stripQuotes := false;{$POP}
end;

{ tMainForm }

constructor tMainForm.create(aOwner: tComponent);
begin
  fPropsLoading := true;
  fCtlStateClients := tList.create;
  fEditStyles := tKlausEditorOptions.create;
  fConsoleOptions := tklausConsoleOptions.create;
  fPracticumOptions := tklausPracticumOptions.create;
  inherited create(aOwner);
  propStorage := tFixedPropStorage.create(self);
  with propStorage do begin
    onRestoreProperties := @propStorageRestoreProperties;
    onRestoringProperties := @propStorageRestoringProperties;
    onSavingProperties := @propStorageSavingProperties;
  end;
  fRecentFiles := tStringList.create;
  propStorage.iniFileName := configFileName;
  fControlStateInvalid := false;
  createDebugViews;
  createCourseFrame;
  fActionLists.clear;
end;

destructor tMainForm.destroy;
begin
  freeAndNil(fRecentFiles);
  freeAndNil(fCourseFrame);
  inherited destroy;
  freeAndNil(fCtlStateClients);
  freeAndNil(fEditStyles);
  freeAndNil(fConsoleOptions);
  freeAndNil(fPracticumOptions);
end;

procedure tMainForm.addControlStateClient(ctl: tControl);
begin
  fCtlStateClients.add(ctl);
end;

procedure tMainForm.removeControlStateClient(ctl: tControl);
begin
  fCtlStateClients.remove(ctl);
end;

procedure tMainForm.invalidateControlState;
begin
  if not fControlStateInvalid then begin
    fControlStateInvalid := true;
    if handleAllocated then postMessage(handle, APPM_UpdateControlState, 0, 0);
  end;
end;

procedure tMainForm.updateControlState(var msg: tMessage);
var
  i: integer;
begin
  if fPropsLoading then
    updateDebugViewPositions;
  fPropsLoading := false;
  if fControlStateInvalid then begin
    fControlStateInvalid := false;
    enableDisable;
    for i := 0 to fCtlStateClients.count-1 do
      tControl(fCtlStateClients[i]).perform(APPM_UpdateControlState, 0, 0);
  end;
end;

procedure tMainForm.updateBreakpoints(var msg: tMessage);
begin
  if fBreakpointListInvalid then updateBreakpointList;
end;

procedure tMainForm.focusEditor(var msg: tMessage);
begin
  if activeFrame <> nil then activeFrame.edit.setFocus;
end;

procedure tMainForm.updateCourseInfo(var msg: tMessage);
var
  fr: tEditFrame;
  tn, cn: string;
  b: boolean;
begin
  fCourseInfoInvalid := false;
  fr := activeFrame;
  if fr <> nil then begin
    fr.edit.textReadStream.position := 0;
    b := klausGetCourseTaskNames(fr.edit.textReadStream, cn, tn);
    if b then showCourseInfo(cn, tn) else showCourseInfo('', '');
  end;
end;

procedure tMainForm.enableDisable;
var
  s: string;
  i: integer;
  b: boolean;
  ss, se: tPoint;
  ts: tTabSheet;
  fr: tEditFrame;
  dvt: tDebugViewType;
  sas: tSceneActionState;
  editFocused: boolean;
  selExists: boolean;
begin
  for i := 0 to frameCount-1 do begin
    s := frames[i].caption;
    if frames[i].modified then s := '* '+s;
    pageControl.pages[i].caption := s;
  end;
  fr := activeFrame;
  if fr = nil then begin
    statusBar.panels[0].text := '';
    statusBar.panels[1].text := '';
    editFocused := false;
    selExists := false;
  end else with fr do begin
    if modified then statusBar.panels[1].text := strModified
    else statusBar.panels[1].text := '';
    ss := edit.selStart;
    se := edit.selEnd;
    if ss = se then begin
      selExists := false;
      statusBar.panels[0].text := format('%d: %d', [ss.y+1, ss.x])
    end else begin
      selExists := true;
      statusBar.panels[0].text := format('%d: %d - %d: %d', [ss.y+1, ss.x, se.y+1, se.x]);
    end;
    editFocused := fr.edit.focused;
  end;
  statusBar.panels[2].text := application.hint;
  enableRecentMenuItems;
  if scene <> nil then begin
    caption := strKlausDebugging;
    sas := scene.actionState;
    actRunStartArgs.enabled := false;
    actRunStart.enabled := sasCanRun in sas;
    actRunAllSettings.enabled := false;
    actDebugRunToCursor.enabled := sasCanRun in sas;
    actRunStop.enabled := sasCanStop in sas;
    actRunPause.enabled := sasCanPause in sas;
    actDebugStepInto.enabled := sasCanStepInto in sas;
    actDebugStepOver.enabled := sasCanStepOver in sas;
    actDebugShowExecPoint.enabled := sasHasExecPoint in sas;
    actRunShowScene.enabled := true;
  end else begin
    caption := strKlaus;
    actRunStartArgs.enabled := fr <> nil;
    actRunStart.enabled := fr <> nil;
    actRunAllSettings.enabled := fr <> nil;
    actDebugRunToCursor.enabled := fr <> nil;
    actRunStop.enabled := false;
    actRunPause.enabled := false;
    actDebugStepInto.enabled := fr <> nil;
    actDebugStepOver.enabled := fr <> nil;
    actDebugShowExecPoint.enabled := false;
    actRunShowScene.enabled := false;
  end;
  if fr <> nil then begin
    actFileClose.enabled := true;
    actFileSave.enabled := fr.modified;
    actFileSaveAs.enabled := true;
    actEditUndo.enabled := (scene = nil) and editFocused and fr.edit.canUndo;
    actEditCut.enabled := (scene = nil) and selExists;
    actEditCopy.enabled := selExists;
    actEditPaste.enabled := (scene = nil) and editFocused and clipboard.hasFormat(CF_TEXT);
    actEditDeleteLine.enabled := (scene = nil) and editFocused;
    actRunCheckSyntax.enabled := scene = nil;
  end else begin
    actFileClose.enabled := false;
    actFileSave.enabled := false;
    actFileSaveAs.enabled := false;
    actEditUndo.enabled := false;
    actEditCut.enabled := false;
    actEditCopy.enabled := false;
    actEditPaste.enabled := false;
    actRunCheckSyntax.enabled := false;
  end;
  actFileSaveAll.enabled := frameCount > 0;
  actWindowPrevTab.enabled := pageControl.pageCount > 1;
  actWindowNextTab.enabled := pageControl.pageCount > 1;
  actEditDeleteLine.enabled := editFocused;
  actEditIndentBlock.enabled := editFocused;
  actEditUnindentBlock.enabled := editFocused;
  actEditSearch.enabled := editFocused;
  actEditSearchNext.enabled := editFocused;
  actEditReplace.enabled := editFocused;
  actDebugToggleBreakpoint.enabled := editFocused;
  actToggleBookmark0.enabled := editFocused;
  actToggleBookmark1.enabled := editFocused;
  actToggleBookmark2.enabled := editFocused;
  actToggleBookmark3.enabled := editFocused;
  actToggleBookmark4.enabled := editFocused;
  actToggleBookmark5.enabled := editFocused;
  actToggleBookmark6.enabled := editFocused;
  actToggleBookmark7.enabled := editFocused;
  actToggleBookmark8.enabled := editFocused;
  actToggleBookmark9.enabled := editFocused;
  actGotoBookmark0.enabled := editFocused;
  actGotoBookmark1.enabled := editFocused;
  actGotoBookmark2.enabled := editFocused;
  actGotoBookmark3.enabled := editFocused;
  actGotoBookmark4.enabled := editFocused;
  actGotoBookmark5.enabled := editFocused;
  actGotoBookmark6.enabled := editFocused;
  actGotoBookmark7.enabled := editFocused;
  actGotoBookmark8.enabled := editFocused;
  actGotoBookmark9.enabled := editFocused;
  ts := pageControl.activePage;
  if ts <> nil then begin
    actWindowMoveTabLeft.enabled := ts.pageIndex > 0;
    actWindowMoveTabRight.enabled := ts.pageIndex < pageControl.pageCount-1;
  end else begin
    actWindowMoveTabLeft.enabled := false;
    actWindowMoveTabRight.enabled := false;
  end;
  b := false;
  for dvt := low(dvt) to high(dvt) do begin
    if debugView[dvt].visible then b := true;
    debugView[dvt].enableDisable;
  end;
  sbDebug.visible := b;
  actRunSlowest.checked := klausDoerSpeed = kdsSlowest;
  actRunSlow.checked := klausDoerSpeed = kdsSlow;
  actRunMedium.checked := klausDoerSpeed = kdsMedium;
  actRunFast.checked := klausDoerSpeed = kdsFast;
  actRunFastest.checked := klausDoerSpeed = kdsFastest;
  actRunImmediate.checked := klausDoerSpeed = kdsImmediate;
end;

procedure tMainForm.updateDebugInfo;
var
  dwt: tDebugViewType;
begin
  fStackFrameIdx := -1;
  for dwt := low(dwt) to high(dwt) do debugView[dwt].updateContent;
  showExecPoint;
  invalidateControlState;
end;

procedure tMainForm.showExecPoint;
var
  fr: tEditFrame;
  sas: tSceneActionState;
begin
  if scene = nil then sas := [] else sas := scene.actionState;
  if not (sasHasExecPoint in sas) then begin
    fExecPoint.enabled := false;
    fExecPoint.point := srcPoint('', 0, 0);
  end else begin
    fExecPoint.enabled := true;
    fExecPoint.point := scene.thread.execPoint;
    fr := openEditFrame(fExecPoint.point.fileName, false);
    if fr <> nil then begin
      fr.edit.selStart := srcToEdit(fExecPoint.point);
      fr.edit.makeCharVisible(fr.edit.selStart);
    end;
  end;
end;

procedure tMainForm.showErrorInfo(const msg: string; pt: tSrcPoint; focus: boolean = true);
var
  fr: tEditFrame;
begin
  if pt.fileName <> '' then begin
    fr := openEditFrame(pt.fileName, focus);
    if fr <> nil then fr.showErrorInfo(msg, pt.line, pt.pos, focus);
  end else
    messageDlg(msg, mtError, [mbOK], 0);
end;

procedure tMainForm.actFileNewExecute(sender: tObject);
begin
  openEditFrame;
end;

function tMainForm.openEditFrame(fn: string = ''; focus: boolean = true): tEditFrame;
var
  ts: tTabSheet;
begin
  if fn <> '' then fn := expandFileName(fn);
  result := findEditFrame(fn);
  if result <> nil then
    setActiveFrame(result, focus)
  else begin
    result := tEditFrame.create(self);
    result.name := 'klausEditFrame'+intToStr(nextFrameIndex);
    nextFrameIndex += 1;
    ts := pageControl.addTabSheet;
    result.parent := ts;
    result.align := alClient;
    pageControl.activePage := ts;
    if focus then result.edit.setFocus;
    if fn <> '' then try
      result.loadFromFile(fn);
    except
      destroyEditFrame(result);
      result := nil;
      raise;
    end;
    addRecentFile(fn);
  end;
  invalidateControlState;
end;

procedure tMainForm.destroyEditFrame(fr: tEditFrame);
var
  ts: tTabSheet;
begin
  if fr = nil then exit;
  ts := parentTabSheet(fr);
  freeAndNil(fr);
  freeAndNil(ts);
  invalidateControlState;
end;

function tMainForm.saveEditFrame(fr: tEditFrame; saveAs: boolean): boolean;
var
  fn: string;
begin
  if fr = nil then exit(false);
  if saveAs or (fr.fileName = '') then begin
    if not saveDialog.execute then exit(false);
    fn := expandFileName(saveDialog.fileName);
  end else
    fn := fr.fileName;
  fr.saveToFile(fn);
  addRecentFile(fn);
  result := true;
end;

function tMainForm.promptToSaveEditFrame(fr: tEditFrame): boolean;
var
  s: string;
begin
  if fr = nil then exit(false);
  if not fr.modified then exit(true);
  if fr.fileName = '' then s := format(strPromptToSave, [fr.caption])
  else s := format(strPromptToSave, [fr.fileName]);
  case messageDlg(strConfirmation, s, mtConfirmation, [mbYes, mbNo, mbCancel], 0, mbYes) of
    mrYes: result := saveEditFrame(fr);
    mrNo: result := true;
    else result := false;
  end;
end;

procedure tMainForm.createDebugViews;
var
  dvt: tDebugViewType;
begin
  for dvt := low(dvt) to high(dvt) do begin
    fDebugView[dvt] := tDebugViewFrame.create(self);
    with debugView[dvt] do begin
      viewType := dvt;
      width := pnDebugContent.width;
      parent := pnDebugContent;
      visible := false;
      updateContent;
    end;
  end;
end;

function cmpPos(f1, f2: pointer): integer;
begin
  if tDebugViewFrame(f1).position < tDebugViewFrame(f2).position then result := -1
  else if tDebugViewFrame(f1).position > tDebugViewFrame(f2).position then result := 1
  else result := 0;
end;

procedure tMainForm.updateDebugViewPositions;
var
  l: tList;
  i: integer;
  dvt: tDebugViewType;
begin
  l := tList.create;
  try
    for dvt := low(dvt) to high(dvt) do l.add(debugView[dvt]);
    l.sort(@cmpPos);
    for i := 0 to l.count-1 do
      pnDebugContent.setControlIndex(tDebugViewFrame(l[i]), i);
  finally
    freeAndNil(l);
    updateDebugViewTabOrder;
  end;
end;

procedure tMainForm.editStylesChange(sender: tObject);
var
  i: integer;
begin
  for i := 0 to frameCount-1 do frames[i].edit.invalidate;
end;

procedure tMainForm.loadPracticum;
var
  msg: string;
  cn, tn: string;
begin
  if scene <> nil then raise eKlausError.create(ercLoadPracticumRunning, zeroSrcPt);
  if courseFrame.visible then begin
    cn := courseFrame.activeCourse;
    tn := courseFrame.activeTask;
  end else begin
    cn := '';
    tn := '';
  end;
  showCourseInfo('', '');
  klausPracticum.loadCourses(fPracticumOptions.expandPath(fPracticumOptions.searchPath), msg);
  refreshPracticumMenu;
  if cn <> '' then showCourseInfo(cn, tn);
  if msg <> '' then messageDlg(msg, mtError, [mbOK], 0);
end;

procedure tMainForm.openTaskSolution(task: tKlausTask);
var
  path, fn, msg: string;
begin
  with practicumOptions do path := expandFileName(expandPath(workingDir));
  path := includeTrailingPathDelimiter(path) + task.owner.name;
  if not directoryExists(path) then begin
    msg := format(strPromptCreateDir, [path]);
    if messageDlg(msg, mtConfirmation, [mbYes, mbCancel], 0) <> mrYes then exit;
  end;
  fn := task.createSolution(path);
  openEditFrame(fn);
end;

procedure tMainForm.refreshPracticumMenu;
var
  i: integer;
  mi: tCourseMenuItem;
begin
  for i := miPracticum.count-1 downto 0 do
    if miPracticum.items[i] is tCourseMenuItem then miPracticum.items[i].free;
  if klausPracticum.count <= 0 then begin
    mi := tCourseMenuItem.create(self);
    mi.caption := strListEmpty;
    mi.enabled := false;
    mi.course := nil;
    miPracticum.insert(0, mi);
    miPracticum.visible := false;
  end else for i := 0 to klausPracticum.count-1 do begin
    mi := tCourseMenuItem.create(self);
    if klausPracticum[i].caption = '' then mi.caption := klausPracticum[i].name
    else mi.caption := klausPracticum[i].caption;
    mi.hint := klausPracticum[i].fileName;
    mi.enabled := true;
    mi.course := klausPracticum[i];
    mi.onClick := @miPracticumCourseClick;
    miPracticum.insert(i, mi);
    miPracticum.visible := true;
  end;
  showCourseInfo('', '');
  invalidateCourseInfo;
end;

procedure tMainForm.createCourseFrame;
begin
  fCourseFrame := tCourseInfoFrame.create(nil);
  fCourseFrame.parent := sbCourse;
  fCourseFrame.align := alClient;
  fCourseFrame.htmlInfo.fixedTypeface := editStyles.font.name;
end;

procedure tMainForm.actFileOpenExecute(sender: tObject);
var
  i: integer;
begin
  if openDialog.execute then
    for i := 0 to openDialog.files.count-1 do
      openEditFrame(openDialog.files[i]);
end;

procedure tMainForm.actFileOptionsExecute(sender: tObject);
begin
  showOptionsDlg;
end;

procedure tMainForm.actFileSaveAllExecute(sender: tObject);
var
  i: integer;
begin
  for i := 0 to frameCount-1 do
    if not saveEditFrame(frames[i]) then break;
end;

procedure tMainForm.actFileSaveAsExecute(sender: tObject);
begin
  saveEditFrame(activeFrame, true);
end;

procedure tMainForm.actFileSaveExecute(sender: tObject);
begin
  saveEditFrame(activeFrame);
end;

procedure tMainForm.actHelpAboutExecute(sender: tObject);
begin
  with tSplashForm.create(application) do begin
    closeOnTimer := false;
    showModal;
  end;
end;

procedure tMainForm.actHelpReferenceGuideExecute(sender: tObject);
var
  fn: string;
begin
  fn := getInstallDir+'/doc/klaus-reference-guide.pdf';
  openDocument(fn);
end;

procedure tMainForm.actRunAllSettingsExecute(sender: tObject);
begin
  run(rmNonStop, true);
end;

procedure tMainForm.actRunCheckSyntaxExecute(sender: tObject);
var
  fr: tEditFrame;
  src: tKlausSource;
begin
  fr := activeFrame;
  if fr = nil then exit;
  src := fr.createSource;
  if src <> nil then begin
    freeAndNil(src);
    messageDlg(application.title, strNoErrorFound, mtInformation, [mbOk], 0);
  end;
end;

procedure tMainForm.actRunFastestExecute(sender: tObject);
begin
  klausDoerSpeed(kdsFastest);
  invalidateControlState;
end;

procedure tMainForm.actRunFastExecute(sender: tObject);
begin
  klausDoerSpeed(kdsFast);
  invalidateControlState;
end;

procedure tMainForm.actRunImmediateExecute(sender: tObject);
begin
  klausDoerSpeed(kdsImmediate);
  invalidateControlState;
end;

procedure tMainForm.actRunInterceptKeyboardExecute(sender: tObject);
begin
  if scene <> nil then scene.previewShortCuts := actRunInterceptKeyboard.checked;
end;

procedure tMainForm.actRunMediumExecute(sender: tObject);
begin
  klausDoerSpeed(kdsMedium);
  invalidateControlState;
end;

procedure tMainForm.actRunPauseExecute(sender: tObject);
begin
  if isRunning then scene.pause;
end;

procedure tMainForm.actDebugShowExecPointExecute(sender: tObject);
begin
  showExecPoint;
end;

procedure tMainForm.actRunShowSceneExecute(sender: tObject);
begin
  if scene <> nil then scene.setFocus;
end;

procedure tMainForm.actRunSlowestExecute(sender: tObject);
begin
  klausDoerSpeed(kdsSlowest);
  invalidateControlState;
end;

procedure tMainForm.actRunSlowExecute(sender: tObject);
begin
  klausDoerSpeed(kdsSlow);
  invalidateControlState;
end;

procedure tMainForm.actRunStartArgsExecute(sender: tObject);
var
  fr: tEditFrame;
  dlg: tCmdLineArgsDlg;
begin
  fr := activeFrame;
  if fr = nil then exit;
  if not saveEditFrame(fr) then exit;
  dlg := tCmdLineArgsDlg.create(application, fr.fileName);
  try
    dlg.args := fr.runOptions.cmdLine;
    dlg.stdIn := fr.runOptions.stdIn;
    dlg.stdOut := fr.runOptions.stdOut;
    dlg.appendStdOut := fr.runOptions.appendStdOut;
    if dlg.showModal = mrOK then begin
      fr.runOptions.cmdLine := dlg.args;
      fr.runOptions.stdIn := dlg.stdIn;
      fr.runOptions.stdOut := dlg.stdOut;
      fr.runOptions.appendStdOut := dlg.appendStdOut;
    end;
  finally
    freeAndNil(dlg);
  end;
end;

procedure tMainForm.createScene(fr: tEditFrame; stepMode, allSettings: boolean);
var
  f: tSceneForm;
  src: tKlausSource;
begin
  if (scene <> nil) or (fr = nil) then exit;
  if fr.modified then if not saveEditFrame(fr) then exit;
  src := fr.createSource;
  if src <> nil then begin
    consoleOptions.updateConsoleDefaults;
    f := tSceneForm.create(src, fr.fileName, fr.runOptions, stepMode);
    if stepMode then f.allSettings := false else f.allSettings := allSettings;
    f.previewShortcuts := actRunInterceptKeyboard.checked;
    f.show;
  end;
end;

procedure tMainForm.run(mode: tRunMode; allSettings: boolean);
begin
  if mode = rmToCursor then begin
    if activeFrame = nil then exit;
    fRunToCursor.enabled := true;
    fRunToCursor.line := activeFrame.edit.caretPos.y+1;
    fRunToCursor.fileName := activeFrame.fileName;
  end else
    fRunToCursor.enabled := false;
  updateBreakpointList;
  if isRunning then case mode of
    rmStepOver: scene.step(true);
    rmStepInto: scene.step(false);
    else scene.resume
  end else
    createScene(activeFrame, mode in [rmStepOver, rmStepInto], allSettings);
end;

procedure tMainForm.invalidateBreakpointList;
begin
  if fBreakpointListInvalid then exit;
  fBreakpointListInvalid := true;
  postMessage(handle, APPM_UpdateBreakpoints, 0, 0);
end;

procedure tMainForm.updateBreakpointList;
var
  f, l, idx: integer;
  lines: tKlausEditStrings;
begin
  idx := 0;
  setLength(fBreakpoints, 0);
  for f := 0 to frameCount-1 do begin
    lines := frames[f].edit.lines as tKlausEditStrings;
    for l := 0 to lines.count-1 do
      if elfBreakpoint in lines.flags[l] then begin
        if idx >= length(fBreakpoints) then setLength(fBreakpoints, idx+10);
        fBreakpoints[idx].enabled := true;
        fBreakpoints[idx].fileName := frames[f].fileName;
        fBreakpoints[idx].line := l+1;
        inc(idx);
      end;
  end;
  setLength(fBreakpoints, idx);
  fBreakpointListInvalid := false;
  if isRunning then scene.updateBreakpointList;
  debugView[dvtBreakpoints].updateContent;
  invalidateControlState;
end;

function tMainForm.getBreakpoints: tKlausBreakpoints;
var
  idx: integer;
begin
  idx := length(fBreakpoints);
  result := copy(fBreakpoints, 0, idx);
  if fRunToCursor.enabled then begin
    setLength(result, idx+1);
    result[idx] := fRunToCursor;
  end;
end;

function tMainForm.isBreakpoint(const fileName: string; line: integer): boolean;
var
  i: integer;
begin
  result := false;
  if fRunToCursor.enabled then
    if (fRunToCursor.fileName = fileName)
    and (fRunToCursor.line = line) then exit(true);
  for i := 0 to length(fBreakpoints)-1 do begin
    if not fBreakpoints[i].enabled then continue;
    if (fBreakpoints[i].fileName = fileName)
    and (fBreakpoints[i].line = line) then exit(true);
  end;
end;

procedure tMainForm.gotoSrcPoint(const fileName: string; line, char: integer);
var
  fr: tEditFrame;
begin
  fr := findEditFrame(fileName);
  if fr = nil then exit;
  setActiveFrame(fr, true);
  with fr.edit do begin
    selStart := point(char, line-1);
    makeCharVisible(selStart);
  end;
  postMessage(handle, APPM_FocusEditor, 0, 0);
end;

procedure tMainForm.gotoBreakpoint(idx: integer);
begin
  if (idx < 0) or (idx >= length(fBreakpoints)) then exit;
  gotoSrcPoint(fBreakpoints[idx].fileName, fBreakpoints[idx].line, 1);
end;

function tMainForm.focusedStackFrame: tKlausStackFrame;
var
  idx: integer;
  r: tKlausRuntime;
begin
  result := nil;
  if not isRunning then exit;
  if sasHasExecPoint in scene.actionState then begin
    r := scene.thread.runtime;
    idx := stackFrameIdx;
    if (idx < 0) or (idx >= r.stackCount) then result := r.stackTop
    else result := r.stackFrames[idx];
  end;
end;

procedure tMainForm.addWatch(const txt: string; allowFunctions: boolean);
var
  idx: integer;
begin
  idx := watchCount;
  setLength(fWatches, idx+1);
  fWatches[idx].text := txt;
  fWatches[idx].allowFunctions := allowFunctions;
  debugView[dvtWatches].updateContent;
  invalidateControlState;
end;

procedure tMainForm.editWatch(idx: integer; const txt: string; allowFunctions: boolean);
begin
  assert((idx >= 0) and (idx < length(fWatches)), 'Invalid item index');
  fWatches[idx].text := txt;
  fWatches[idx].allowFunctions := allowFunctions;
  debugView[dvtWatches].updateContent;
  invalidateControlState;
end;

procedure tMainForm.deleteWatch(idx: integer);
var
  i, cnt: integer;
begin
  cnt := length(fWatches);
  assert((idx >= 0) and (idx < cnt), 'Invalid item index');
  for i := idx to cnt-2 do
    fWatches[idx] := fWatches[idx+1];
  setLength(fWatches, cnt-1);
  debugView[dvtWatches].updateContent;
  invalidateControlState;
end;

procedure tMainForm.updateDebugViewTabOrder;
var
  i: integer;
begin
  for i := pnDebugContent.controlList.count-1 downto 0 do
    (pnDebugContent.controlList[i].control as tWinControl).tabOrder := i;
end;

procedure tMainForm.invalidateCourseInfo;
begin
  if not fCourseInfoInvalid then begin
    fCourseInfoInvalid := true;
    if handleAllocated then postMessage(handle, APPM_UpdateCourseInfo, 0, 0);
  end;
end;

procedure tMainForm.actRunStartExecute(sender: tObject);
begin
  run(rmNonStop, false);
end;

procedure tMainForm.actDebugRunToCursorExecute(sender: tObject);
begin
  run(rmToCursor, false);
end;

procedure tMainForm.actDebugStepIntoExecute(sender: tObject);
begin
  run(rmStepInto, false);
end;

procedure tMainForm.actDebugStepOverExecute(sender: tObject);
begin
  run(rmStepOver, false);
end;

procedure tMainForm.actDebugToggleBreakpointExecute(sender: tObject);
begin
  if activeFrame <> nil then activeFrame.toggleBreakpoint;
end;

procedure tMainForm.actRunStopExecute(sender: tObject);
begin
  if scene <> nil then scene.close;
end;

procedure tMainForm.actToggleBookmarkExecute(sender: tObject);
begin
  if activeFrame <> nil then;
    activeFrame.toggleBookmark((sender as tComponent).tag);
end;

procedure tMainForm.actGotoBookmarkExecute(sender: tObject);
begin
  if activeFrame <> nil then;
    activeFrame.gotoBookmark((sender as tComponent).tag);
end;

procedure tMainForm.actDebugBreakpointsExecute(sender: tObject);
begin
  debugView[dvtBreakpoints].visible := true;
end;

procedure tMainForm.actDebugCallStackExecute(sender: tObject);
begin
  debugView[dvtCallStack].visible := true;
end;

procedure tMainForm.actDebugLocalVariablesExecute(sender: tObject);
begin
  debugView[dvtVariables].visible := true;
end;

procedure tMainForm.actWindowMoveTabLeftExecute(sender: tObject);
var
  ts: tTabSheet;
begin
  ts := pageControl.activePage;
  if ts = nil then exit;
  if ts.pageIndex > 0 then ts.pageIndex := ts.pageIndex-1;
end;

procedure tMainForm.actWindowMoveTabRightExecute(sender: tObject);
var
  ts: tTabSheet;
begin
  ts := pageControl.activePage;
  if ts = nil then exit;
  if ts.pageIndex < pageControl.PageCount-1 then ts.pageIndex := ts.pageIndex+1;
end;

procedure tMainForm.actWindowNextTabExecute(sender: tObject);
begin
  pageControl.selectNextPage(true);
end;

procedure tMainForm.actWindowPrevTabExecute(sender: tObject);
begin
  pageControl.selectNextPage(false);
end;

procedure tMainForm.actDebugWatchesExecute(sender: tObject);
begin
  debugView[dvtWatches].visible := true;
end;

procedure tMainForm.actFileExitExecute(sender: tObject);
begin
  close;
end;

procedure tMainForm.actFileCloseExecute(sender: tObject);
begin
  if not promptToSaveEditFrame(activeFrame) then exit;
  destroyEditFrame(activeFrame);
end;

procedure tMainForm.actEditUndoExecute(sender: tObject);
var
  fr: tEditFrame;
begin
  fr := activeFrame;
  if fr = nil then exit;
  fr.edit.undo;
end;

procedure tMainForm.actEditUnindentBlockExecute(sender: tObject);
var
  fr: tEditFrame;
begin
  fr := activeFrame;
  if fr = nil then exit;
  if not fr.edit.focused then exit;
  fr.unindentBlock;
end;

procedure tMainForm.actEditCutExecute(sender: tObject);
var
  fr: tEditFrame;
begin
  fr := activeFrame;
  if fr = nil then exit;
  fr.edit.cutToClipboard;
end;

procedure tMainForm.actEditDeleteLineExecute(sender: tObject);
var
  fr: tEditFrame;
begin
  fr := activeFrame;
  if fr = nil then exit;
  if not fr.edit.focused then exit;
  fr.deleteLine;
end;

procedure tMainForm.actEditIndentBlockExecute(sender: tObject);
var
  fr: tEditFrame;
begin
  fr := activeFrame;
  if fr = nil then exit;
  if not fr.edit.focused then exit;
  fr.indentBlock;
end;

procedure tMainForm.actEditPasteExecute(sender: tObject);
var
  fr: tEditFrame;
begin
  fr := activeFrame;
  if fr = nil then exit;
  fr.edit.pasteFromClipboard;
end;

procedure tMainForm.actEditSearchNextExecute(sender: tObject);
var
  fr: tEditFrame;
begin
  fr := activeFrame;
  if fr = nil then exit;
  if fSearchInfo.searchText <> '' then fr.searchReplace(fSearchInfo)
  else actEditSearch.execute;
end;

procedure tMainForm.actEditSearchReplaceExecute(sender: tObject);
var
  fr: tEditFrame;
  dlg: tSearchReplaceDlg;
begin
  fr := activeFrame;
  if fr = nil then exit;
  dlg := TSearchReplaceDlg.create(application, sender = actEditReplace);
  try
    if dlg.showModal <> mrCancel then begin
      fSearchInfo := dlg.info;
      case dlg.modalResult of
        mrOK: fr.searchReplace(fSearchInfo);
        mrAll: fr.replaceAll(fSearchInfo);
      end;
    end;
  finally
    freeAndNil(dlg);
  end;
end;

procedure tMainForm.actEditSelectAllExecute(sender: tObject);
var
  fr: tEditFrame;
begin
  fr := activeFrame;
  if fr = nil then exit;
  fr.edit.selectAll;
end;

procedure tMainForm.actEditCopyExecute(sender: tObject);
var
  fr: tEditFrame;
begin
  fr := activeFrame;
  if fr = nil then exit;
  fr.edit.copyToClipboard;
end;

procedure tMainForm.actDebugEvaluateWatchExecute(sender: tObject);
begin
  with tEvaluateDlg.create(application) do try
    if showModal = mrOK then
      if text <> '' then addWatch(text, allowFunctions);
  finally
    free;
  end;
end;

function tMainForm.getFrameCount: integer;
begin
  result := pageControl.pageCount;
end;

function tMainForm.getActiveFrame: tEditFrame;
begin
  if pageControl.activePage = nil then result := nil
  else result := pageControl.activePage.controls[0] as tEditFrame;
end;

function tMainForm.getBreakpointCount: integer;
begin
  result := length(fBreakpoints);
end;

function tMainForm.getBreakpoint(idx: integer): tKlausBreakpoint;
begin
  assert((idx >= 0) and (idx < length(fBreakpoints)), 'Invalid array index');
  result := fBreakpoints[idx];
end;

function tMainForm.getConfigFileName: string;
begin
  result := getAppConfigDir(false)+configName;
end;

function tMainForm.getDebugViews: tDebugViewTypes;
var
  dvt: tDebugViewType;
begin
  result := [];
  for dvt := low(dvt) to high(dvt) do
    if fDebugView[dvt].visible then include(result, dvt);
end;

function tMainForm.getDbgWgtStoredWidth: integer;
begin
  result := mulDiv(sbDebug.width, designTimePPI, screenInfo.pixelsPerInchX);
end;

procedure tMainForm.setDbgWgtStoredWidth(val: integer);
begin
  // здесь не масштабируем, иначе при высоких разрешениях экрана
  // размер растёт при каждом запуске среды
  sbDebug.width := min(val, self.width div 3);
end;

function tMainForm.getCourseStoredWidth: integer;
begin
  result := mulDiv(sbCourse.width, designTimePPI, screenInfo.pixelsPerInchX);
end;

function tMainForm.getDoerSpeed: tKlausDoerSpeed;
begin
  result := klausDoerSpeed;
end;

procedure tMainForm.setCourseStoredWidth(val: integer);
begin
  // здесь не масштабируем, иначе при высоких разрешениях экрана
  // размер растёт при каждом запуске среды
  sbCourse.width := min(val, self.width div 3);
end;

procedure tMainForm.setDoerSpeed(val: tKlausDoerSpeed);
begin
  klausDoerSpeed(val);
end;

function tMainForm.getFormStoredWidth: integer;
begin
  result := mulDiv(width, designTimePPI, screenInfo.pixelsPerInchX);
end;

procedure tMainForm.setFormStoredWidth(val: integer);
begin
  width := val;
end;

function tMainForm.getFormStoredHeight: integer;
begin
  result := mulDiv(height, designTimePPI, screenInfo.pixelsPerInchX);
end;

procedure tMainForm.setFormStoredHeight(val: integer);
begin
  height := val;
end;

function tMainForm.getIsRunning: boolean;
begin
  result := scene <> nil;
  if result then result := scene.thread <> nil;
  if result then result := not scene.thread.finished;
end;

function tMainForm.getSelectedSetting: tKlausDoerSetting;
begin
  if not sbCourse.visible then exit(nil);
  result := courseFrame.selectedSetting;
end;

function tMainForm.getSelectedTask: tKlausTask;
begin
  if not sbCourse.visible then exit(nil);
  result := courseFrame.selectedTask;
end;

function tMainForm.getWatchCount: integer;
begin
  result := length(fWatches);
end;

function tMainForm.getWatches(idx: integer): tWatchInfo;
begin
  assert((idx >= 0) and (idx < length(fWatches)), 'Invalid item index');
  result := fWatches[idx];
end;

procedure tMainForm.showCourseInfo(courseName, taskName: string; focus: boolean = false);
begin
  if courseName = '' then taskName := '';
  courseFrame.updateContent(courseName, taskName);
  sbCourse.visible := courseName <> '';
  if sbCourse.visible and focus then courseFrame.tree.setFocus;
  invalidateControlState;
end;

procedure tMainForm.showOptionsDlg(tabName: string);
var
  i: integer;
begin
  with tOptionsDlg.create(application) do try
    if tabName <> '' then begin
      tabName := u8Lower(tabName);
      for i := 0  to pageControl.pageCount-1 do
        if tabName = u8Lower(pageControl.pages[i].name) then
          pageControl.activePage := pageControl.pages[i];
    end;
    editorOptions := self.editStyles;
    consoleOptions := self.consoleOptions;
    practicumOptions := self.practicumOptions;
    if showModal = mrOK then begin
      self.editStyles.assign(editorOptions);
      self.consoleOptions.assign(consoleOptions);
      self.practicumOptions.assign(practicumOptions);
    end;
  finally
    free;
  end;
end;

procedure tMainForm.setDebugViews(val: tDebugViewTypes);
var
  dvt: tDebugViewType;
begin
  for dvt := low(dvt) to high(dvt) do
    debugView[dvt].visible := dvt in val;
end;

function tMainForm.getFrames(idx: integer): tEditFrame;
begin
  result := pageControl.pages[idx].controls[0] as tEditFrame;
end;

function tMainForm.getRecentFiles: tStrings;
begin
  result := fRecentFiles;
end;

procedure tMainForm.setActiveFrame(val: tEditFrame; focus: boolean = true);
var
  ts: tTabSheet;
begin
  ts := parentTabSheet(val);
  if ts = nil then exit;
  pageControl.activePage := ts;
  if focus then val.edit.setFocus;
end;

procedure tMainForm.setStackFrameIdx(value: integer);
begin
  if fStackFrameIdx <> value then begin
    fStackFrameIdx := value;
    debugView[dvtVariables].updateContent;
    debugView[dvtWatches].updateContent;
  end;
end;

procedure tMainForm.setRecentFiles(val: tStrings);
begin
  fRecentFiles.assign(val);
  updateRecentMenuItems;
end;

procedure tMainForm.updateRecentMenuItems;
var
  i: integer;
  mi: tMenuItem;
begin
  for i := 0 to fRecentFiles.count-1 do begin
    if i >= maxRecentFiles then break;
    mi := findComponent('miFileRecent'+intToStr(i)) as tMenuItem;
    if mi = nil then begin
      mi := tMenuItem.create(self);
      mi.name := 'miFileRecent'+intToStr(i);
      miFile.insert(miSepRecent.menuIndex, mi);
    end;
    mi.caption := extractFileName(fRecentFiles[i]);
    mi.hint := fRecentFiles[i];
    mi.onClick := @recentMenuItemClick;
    mi.tag := i;
    mi.visible := true;
  end;
  for i := fRecentFiles.count to maxRecentFiles-1 do begin
    mi := findComponent('miFileRecent'+intToStr(i))  as tMenuItem;
    if mi <> nil then begin
      mi.tag := -1;
      mi.visible := false;
      mi.enabled := false;
    end;
  end;
  miSepRecent.visible := fRecentFiles.count > 0;
  invalidateControlState;
end;

procedure tMainForm.enableRecentMenuItems;
var
  i: integer;
  mi: tMenuItem;
begin
  for i := 0 to fRecentFiles.count-1 do begin
    mi := findComponent('miFileRecent'+intToStr(i))  as tMenuItem;
    if mi <> nil then mi.enabled := findEditFrame(fRecentFiles[i]) = nil;
  end;
end;

procedure tMainForm.recentMenuItemClick(sender: tObject);
var
  idx: integer;
begin
  idx := (sender as tMenuItem).tag;
  if (idx < 0) or (idx >= fRecentFiles.count) then exit;
  openEditFrame(fRecentFiles[idx]);
end;

function tMainForm.getDebugView(dvt: tDebugViewType): tDebugViewFrame;
begin
  result := fDebugView[dvt];
end;

function tMainForm.parentTabSheet(fr: tEditFrame): tTabSheet;
var
  ts: tWinControl;
begin
  if fr = nil then exit(nil);
  ts := fr.parent;
  while (ts <> nil) and not (ts is tTabSheet) do ts := ts.parent;
  result := ts as tTabSheet;
end;

procedure tMainForm.addRecentFile(fn: string);
var
  idx: integer;
begin
  if fn = '' then exit;
  idx := fRecentFiles.indexOf(fn);
  if idx >= 0 then fRecentFiles.delete(idx);
  fRecentFiles.insert(0, fn);
  while fRecentFiles.count > maxRecentFiles do
    fRecentFiles.delete(fRecentFiles.count - 1);
  updateRecentMenuItems;
end;

function tMainForm.findEditFrame(fn: string): tEditFrame;
var
  i: integer;
begin
  result := nil;
  if fn = '' then exit;
  for i := 0 to frameCount-1 do
    if fn = frames[i].fileName then exit(frames[i]);
end;

procedure tMainForm.applicationHint(sender: tObject);
begin
  invalidateControlState;
end;

procedure tMainForm.formCloseQuery(sender: tObject; var canClose: boolean);
var
  i: integer;
begin
  canClose := false;
  if scene <> nil then
    if not scene.closeQuery then exit;
  for i := 0 to frameCount-1 do
    if not promptToSaveEditFrame(frames[i]) then exit;
  canClose := true;
end;

procedure tMainForm.formShortCut(var msg: tLMKey; var handled: boolean);
var
  ctl: tWinControl;
  frm: tDebugViewContent = nil;
  cfrm: tCourseInfoFrame = nil;
begin
  if assigned(fActionLists) then fActionLists.clear;
  handled := actionList.isShortCut(msg);
  if handled then exit;
  ctl := screen.activeControl;
  while ctl <> nil do begin
    if ctl is tDebugViewContent then begin
      frm := ctl as tDebugViewContent;
      if frm.actions <> nil then handled := frm.actions.isShortcut(msg);
      exit;
    end else if ctl is tCourseInfoFrame then begin
      cfrm := ctl as tCourseInfoFrame;
      if cfrm.actionList <> nil then handled := cfrm.actionList.isShortcut(msg);
      exit;
    end;
    ctl := ctl.parent;
  end;
end;

procedure tMainForm.formShow(sender: tObject);
var
  i: integer;
  fn, err, sep: string;
begin
  loadPracticum;
  err := '';
  sep := '';
  for i := 1 to paramCount do begin
    fn := expandFileName(paramStr(i));
    try
      openEditFrame(fn);
    except
      on e: exception do begin
        err += sep + e.message;
        sep := #13#10;
      end;
      else raise;
    end;
  end;
  if err <> '' then begin
    err := format(strFileOpenError, [err]);
    messageDlg(err, mtError, [mbOK], 0);
  end;
end;

procedure tMainForm.pageControlChange(sender: tObject);
begin
  invalidateCourseInfo;
  invalidateControlState;
end;

procedure tMainForm.bvDebugSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then begin
    fDebugPanelSizing := true;
    fSizingPoint := bvDebugSizer.clientToScreen(point(x, y));
  end;
end;

procedure tMainForm.bvDebugSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
var
  p: tPoint;
  dw: integer;
begin
  if fDebugPanelSizing then begin
    p := bvDebugSizer.clientToScreen(point(x, y));
    dw := fSizingPoint.x - p.x;
    with pageControl do if width - dw < 100 then dw := width - 100;
    sbDebug.width := max(100, sbDebug.width + dw);
    fSizingPoint := p;
  end;
end;

procedure tMainForm.bvDebugSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then fDebugPanelSizing := false;
end;

procedure tMainForm.bvCourseSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then begin
    fCoursePanelSizing := true;
    fSizingPoint := bvCourseSizer.clientToScreen(point(x, y));
  end;
end;

procedure tMainForm.bvCourseSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
var
  p: tPoint;
  dw: integer;
begin
  if fCoursePanelSizing then begin
    p := bvCourseSizer.clientToScreen(point(x, y));
    dw := p.x - fSizingPoint.x;
    with pageControl do if width - dw < 100 then dw := width - 100;
    sbCourse.width := max(100, sbCourse.width + dw);
    fSizingPoint := p;
  end;
end;

procedure tMainForm.bvCourseSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then fCoursePanelSizing := false;
end;

procedure tMainForm.pnDebugContentResize(sender: tObject);
var
  i: integer;
begin
  for i := 0 to pnDebugContent.controlCount-1 do
    pnDebugContent.controls[i].width := pnDebugContent.clientWidth;
end;

function tMainForm.getSessionProperties: string;
var
  n: string;
  dvt: tDebugViewType;
begin
  result :=
    'FormStoredHeight;Left;Top;FormStoredWidth;WindowState;recentFiles;debugViews;'+
    'actRunInterceptKeyboard.checked;dbgWgtStoredWidth;courseStoredWidth;doerSpeed';
  for dvt := low(dvt) to high(dvt) do begin
    if debugView[dvt] = nil then continue;
    n := debugView[dvt].name;
    result += ';'+n+'.FrameStoredHeight;'+n+'.Position';
  end;
end;

procedure tMainForm.createWnd;
begin
  inherited;
  if fControlStateInvalid then postMessage(handle, APPM_UpdateControlState, 0, 0);
end;

procedure tMainForm.propStorageRestoringProperties(sender: tObject);
begin
  fEditStyles.loadFromIni(propStorage);
  fConsoleOptions.loadFromIni(propStorage);
  fPracticumOptions.loadFromIni(propStorage);
  sessionProperties := getSessionProperties;
end;

procedure tMainForm.propStorageSavingProperties(sender: tObject);
begin
  sessionProperties := getSessionProperties;
  fEditStyles.saveToIni(propStorage);
  fConsoleOptions.saveToIni(propStorage);
  fPracticumOptions.saveToIni(propStorage);
end;

procedure tMainForm.miPracticumCourseClick(sender: tObject);
var
  course: tKlausCourse;
begin
  course := (sender as tCourseMenuItem).course;
  if course = nil then showCourseinfo('', '') else showCourseInfo(course.name, '', true);
end;

procedure tMainForm.propStorageRestoreProperties(sender: tObject);
begin
  updateRecentMenuItems;
end;

end.

