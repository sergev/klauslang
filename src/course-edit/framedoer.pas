unit FrameDoer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, ComCtrls, Dialogs,
  ActnList, LMessages, KlausPract, KlausDoer;

type
  tDoerSettingFrame = class(tFrame)
    private
      fSetting: tKlausDoerSetting;
      fOnChange: tNotifyEvent;
    protected
      procedure setSetting(val: tKlausDoerSetting); virtual;
      procedure change; virtual;
      function  handleShortCut(var msg: tLMKey): boolean; virtual;
    public
      property setting: tKlausDoerSetting read fSetting write setSetting;
      property onChange: tNotifyEvent read fOnChange write fOnChange;

      class function doerClass: tKlausDoerClass; virtual; abstract;
      function  isShortCut(var msg: tLMKey): boolean;
      procedure enableDisable; virtual;
  end;

type
  tDoerSettingFrameClass = class of tDoerSettingFrame;

type
  tDoerFrame = class(tFrame)
    actFieldSize: TAction;
    actArrowLeft: TAction;
    actArrowUp: TAction;
    actArrowRight: TAction;
    actArrowDown: TAction;
    actSymbolBullet: TAction;
    actMouseRotate: TAction;
    actMousePos: TAction;
    actSymbolOther: TAction;
    actSymbolB: TAction;
    actSymbolA: TAction;
    actPaint: TAction;
    actWallDown: TAction;
    actWallRight: TAction;
    actWallUp: TAction;
    actWallLeft: TAction;
    actSettingSave: tAction;
    actSettingLoad: tAction;
    actSettingMoveUp: tAction;
    actSettingMoveDown: tAction;
    actSettingDelete: tAction;
    actSettingRename: tAction;
    actSettingAdd: tAction;
    actionImages: tImageList;
    listActions: tActionList;
    Bevel3: tBevel;
    Bevel4: tBevel;
    bvListSizer: tBevel;
    cbDoer: tComboBox;
    Label10: tLabel;
    Label9: tLabel;
    lbSetting: tListBox;
    pnDoer: tPanel;
    Panel13: tPanel;
    Panel14: tPanel;
    pnList: tPanel;
    pnListContent: tPanel;
    pnSetting: tPanel;
    tbRename: TToolButton;
    tbDelete: TToolButton;
    toolBar: tToolBar;
    ToolButton1: tToolButton;
    tbAdd: TToolButton;
    tbMoveDown: TToolButton;
    tbMoveUp: TToolButton;
    ToolButton5: tToolButton;
    tbLoad: TToolButton;
    tbSave: TToolButton;
    procedure actSettingAddExecute(sender: tObject);
    procedure actSettingDeleteExecute(sender: tObject);
    procedure actSettingMoveDownExecute(sender: tObject);
    procedure actSettingMoveUpExecute(sender: tObject);
    procedure actSettingRenameExecute(sender: tObject);
    procedure bvListSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvListSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
    procedure bvListSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure cbDoerChange(sender: tObject);
    procedure lbSettingDblClick(sender: TObject);
    procedure lbSettingSelectionChange(sender: tObject; user: boolean);
  private
    fListSizing: boolean;
    fSizingPoint: tPoint;
    fTask: tKlausTask;
    fSettingFrame: tDoerSettingFrame;

    procedure setTask(val: tKlausTask);
    procedure refreshSettingList;
    procedure moveSettingListItem(delta: integer);
    function  selectedSetting: tKlausDoerSetting;
    procedure updateDoerView;
    procedure settingFrameChange(sender: tObject);
  public
    property task: tKlausTask read fTask write setTask;

    constructor create(aOwner: tComponent); override;
    procedure refreshWindow;
    procedure enableDisable;
    function  isShortcut(var msg: tLMKey): boolean;
  end;

  procedure registerDoerSettingFrame(doerClass: tKlausDoerClass; frameClass: tDoerSettingFrameClass);
  function  getDoerSettingFrame(doerClass: tKlausDoerClass): tDoerSettingFrameClass;

implementation

{$R *.lfm}

uses Math, U8, FormMain;

resourcestring
  strNone = '(нет)';
  strNoname = '(без названия)';
  strIdxCap = '%d - %s';
  strAddSetting = 'Добавить обстановку';
  strRenameSetting = 'Переименовать обстановку';
  strDeleteSetting = 'Удалить обстановку "%s"?';
  strCaption = 'Название: ';
  strConfirmChangeDoer = 'При смене исполнителя все существующие обстановки будут удалены. Продолжить?';

var
  doerFrameClass: tStringList = nil;

procedure registerDoerSettingFrame(doerClass: tKlausDoerClass; frameClass: tDoerSettingFrameClass);
begin
  if doerFrameClass = nil then begin
    doerFrameClass := tStringList.create;
    doerFrameClass.sorted := true;
    doerFrameClass.duplicates := dupError;
    doerFrameClass.caseSensitive := false;
  end;
  doerFrameClass.addObject(u8Lower(doerClass.className), tObject(frameClass));
end;

function getDoerSettingFrame(doerClass: tKlausDoerClass): tDoerSettingFrameClass;
var
  idx: integer;
begin
  if doerFrameClass = nil then exit(nil);
  idx := doerFrameClass.indexOf(u8Lower(doerClass.className));
  if idx < 0 then result := nil
  else result := tDoerSettingFrameClass(doerFrameClass.objects[idx]);
end;

{ tDoerSettingFrame }

procedure tDoerSettingFrame.setSetting(val: tKlausDoerSetting);
begin
  fSetting := val;
end;

procedure tDoerSettingFrame.change;
begin
  if assigned(fOnChange) then fOnChange(self);
end;

function tDoerSettingFrame.handleShortCut(var msg: tLMKey): boolean;
begin
  result := false;
end;

function tDoerSettingFrame.isShortCut(var msg: tLMKey): boolean;
var
  ctl: tWinControl;
begin
  result := false;
  ctl := screen.activeControl;
  while ctl <> nil do begin
    if ctl = self then begin
      result := handleShortcut(msg);
      exit;
    end;
    ctl := ctl.parent;
  end;
end;

procedure tDoerSettingFrame.enableDisable;
begin
end;

{ tDoerFrame }

constructor tDoerFrame.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  klausEnumDoers(cbDoer.items);
  cbDoer.items.insertObject(0, strNone, nil);
  cbDoer.itemIndex := 0;
end;

procedure tDoerFrame.refreshWindow;
begin
  try
    if task <> nil then begin
      with cbDoer do itemIndex := items.indexOfObject(tObject(task.doer));
      refreshSettingList;
      updateDoerView;
    end else begin
      cbDoer.itemIndex := 0;
      lbSetting.items.clear;
      freeAndNil(fSettingFrame);
    end;
  finally
    enableDisable;
  end;
end;

procedure tDoerFrame.enableDisable;
var
  i: integer;
  ds: tKlausDoerSettings = nil;
  sel: tObject = nil;
begin
  cbDoer.enabled := task <> nil;
  if task <> nil then ds := task.doerSettings;
  lbSetting.enabled := ds <> nil;
  if ds = nil then begin
    for i := 0 to listActions.actionCount-1 do
      (listActions.actions[i] as tCustomAction).enabled := false;
  end else begin
    actSettingAdd.enabled := true;
    actSettingLoad.enabled := true;
    actSettingSave.enabled := ds.count > 0;
    with lbSetting do if itemIndex >= 0 then sel := items.objects[itemIndex];
    actSettingRename.enabled := sel <> nil;
    actSettingDelete.enabled := sel <> nil;
    actSettingMoveDown.enabled := sel <> nil;
    actSettingMoveUp.enabled := sel <> nil;
  end;
  if fSettingFrame <> nil then fSettingFrame.enableDisable;
end;

function tDoerFrame.isShortcut(var msg: tLMKey): boolean;
var
  ctl: tWinControl;
begin
  result := false;
  ctl := screen.activeControl;
  if ctl = lbSetting then
    result := listActions.isShortCut(msg)
  else while ctl <> nil do begin
    if ctl = fSettingFrame then begin
      result := fSettingFrame.isShortCut(msg);
      exit;
    end;
    ctl := ctl.parent;
  end;
end;

procedure tDoerFrame.bvListSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then begin
    fListSizing := true;
    fSizingPoint := bvListSizer.clientToScreen(point(x, y));
  end;
end;

procedure tDoerFrame.actSettingAddExecute(sender: tObject);
var
  s: string = '';
  ds: tKlausDoerSetting;
begin
  if task = nil then exit;
  if task.doer = nil then exit;
  if inputQuery(strAddSetting, strCaption, s) then try
    ds := task.doerSettings.add;
    ds.caption := s;
    refreshSettingList;
    mainForm.modified := true;
    with lbSetting do begin
      itemIndex := items.indexOfObject(ds);
      setFocus;
    end;
  finally
    enableDisable;
  end;
end;

procedure tDoerFrame.actSettingDeleteExecute(sender: tObject);
var
  s: string;
  idx: integer;
  ds: tKlausDoerSetting;
begin
  if task = nil then exit;
  if task.doer = nil then exit;
  idx := lbSetting.itemIndex;
  if idx < 0 then exit;
  with lbSetting do ds := items.objects[idx] as tKlausDoerSetting;
  s := format(strDeleteSetting, [ds.caption]);
  if messageDlg(s, mtConfirmation, [mbYes, mbCancel], 0) = mrYes then try
    if fSettingFrame <> nil then fSettingFrame.setting := nil;
    task.doerSettings.remove(ds);
    refreshSettingList;
    mainForm.modified := true;
    with lbSetting do begin
      itemIndex := min(idx, items.count-1);
      setFocus;
    end;
  finally
    enableDisable;
  end;
end;

procedure tDoerFrame.actSettingMoveDownExecute(sender: tObject);
begin
  moveSettingListItem(1);
end;

procedure tDoerFrame.actSettingMoveUpExecute(sender: tObject);
begin
  moveSettingListItem(-1);
end;

procedure tDoerFrame.actSettingRenameExecute(sender: tObject);
var
  s: string;
  ds: tKlausDoerSetting;
begin
  if task = nil then exit;
  if task.doer = nil then exit;
  if lbSetting.itemIndex < 0 then exit;
  with lbSetting do ds := items.objects[itemIndex] as tKlausDoerSetting;
  s := ds.caption;
  if inputQuery(strRenameSetting, strCaption, s) then try
    ds.caption := s;
    refreshSettingList;
    mainForm.modified := true;
    with lbSetting do begin
      itemIndex := items.indexOfObject(ds);
      setFocus;
    end;
  finally
    enableDisable;
  end;
end;

procedure tDoerFrame.bvListSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
var
  p: tPoint;
  dw: integer;
begin
  if fListSizing then begin
    p := bvListSizer.clientToScreen(point(x, y));
    dw := p.x - fSizingPoint.x;
    with pnDoer do if width - dw < 100 then dw := width - 100;
    pnList.width := max(100, pnList.width + dw);
    fSizingPoint := p;
  end;
end;

procedure tDoerFrame.bvListSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then fListSizing := false;
end;

procedure tDoerFrame.cbDoerChange(sender: tObject);
var
  d: tKlausDoerClass;
begin
  if task <> nil then try
    with cbDoer do
      if itemIndex < 0 then d := nil
      else d := tKlausDoerClass(items.objects[itemIndex]);
    if task.doer <> d then begin
      if task.doer <> nil then
        if task.doerSettings.count > 0 then
          if messageDlg(strConfirmChangeDoer, mtConfirmation, [mbYes, mbCancel], 0) <> mrYes then exit;
      task.doer := d;
      mainForm.modified := true;
      refreshWindow;
    end;
  finally
    cbDoer.itemIndex := cbDoer.items.indexOfObject(tObject(task.doer));
  end;
end;

procedure tDoerFrame.lbSettingDblClick(sender: tObject);
begin
  actSettingRename.execute;
end;

procedure tDoerFrame.lbSettingSelectionChange(sender: tObject; user: boolean);
begin
  updateDoerView();
  enableDisable;
end;

procedure tDoerFrame.setTask(val: tKlausTask);
begin
  if fTask <> val then begin
    fTask := val;
    refreshWindow;
  end;
end;

procedure tDoerFrame.refreshSettingList;
var
  s: string;
  i: integer;
  ds: tObject = nil;
begin
  with lbSetting do try
    if itemIndex >= 0 then ds := items.objects[itemIndex];
    items.clear;
    if task <> nil then
      if task.doer <> nil then
        for i := 0 to task.doerSettings.count-1 do begin
          s := task.doerSettings[i].caption;
          if s = '' then s := strNoname;
          items.addObject(format(strIdxCap, [i+1, s]), task.doerSettings[i]);
        end;
    itemIndex := items.indexOfObject(ds);
  finally
    enableDisable;
  end;
end;

procedure tDoerFrame.moveSettingListItem(delta: integer);
var
  idx: integer;
  ds: tKlausDoerSetting;
begin
  if task = nil then exit;
  if task.doer = nil then exit;
  if lbSetting.itemIndex < 0 then exit;
  with lbSetting do ds := items.objects[itemIndex] as tKlausDoerSetting;
  idx := task.doerSettings.indexOf(ds);
  if (idx+delta < 0) or (idx+delta >= task.doerSettings.count) then exit;
  try
    task.doerSettings.move(idx, idx+delta);
    refreshSettingList;
    mainForm.modified := true;
    with lbSetting do begin
      itemIndex := items.indexOfObject(ds);
      setFocus;
    end;
  finally
    enableDisable;
  end;
end;

function tDoerFrame.selectedSetting: tKlausDoerSetting;
begin
  if task = nil then
    result := nil
  else with lbSetting do begin
    if itemIndex < 0 then result := nil
    else result := tklausDoerSetting(items.objects[itemIndex]);
  end;
end;

procedure tDoerFrame.updateDoerView;
var
  cls: tKlausDoerClass;
  fcls: tDoerSettingFrameClass;
  ds: tKlausDoerSetting;
begin
  ds := selectedSetting;
  if ds = nil then
    freeAndNil(fSettingFrame)
  else begin
    if fSettingFrame = nil then cls := nil
    else cls := fSettingFrame.doerClass;
    if cls <> task.doer then begin
      freeAndNil(fSettingFrame);
      fcls := getDoerSettingFrame(task.doer);
      fSettingFrame := fcls.create(self);
      fSettingFrame.parent := pnDoer;
      fSettingFrame.align := alClient;
      fSettingFrame.borderSpacing.around := 2;
      fSettingFrame.onChange := @settingFrameChange;
    end;
    fSettingFrame.setting := ds;
  end;
end;

procedure tDoerFrame.settingFrameChange(sender: tObject);
begin
  mainForm.modified := true;
  enableDisable;
end;

finalization
  freeAndNil(doerFrameClass);
end.

