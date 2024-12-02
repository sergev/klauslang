unit FrameDoer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, ComCtrls, Dialogs,
  ActnList, LMessages, KlausPract, KlausDoer;

type

  { tDoerFrame }

  tDoerFrame = class(tFrame)
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
    procedure actSettingDeleteExecute(Sender: TObject);
    procedure actSettingMoveDownExecute(Sender: TObject);
    procedure actSettingMoveUpExecute(Sender: TObject);
    procedure actSettingRenameExecute(Sender: TObject);
    procedure bvListSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvListSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
    procedure bvListSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure cbDoerChange(sender: tObject);
    procedure lbSettingDblClick(Sender: TObject);
    procedure lbSettingSelectionChange(Sender: TObject; User: boolean);
  private
    fListSizing: boolean;
    fSizingPoint: tPoint;
    fTask: tKlausTask;
    fView: tKlausDoerView;

    procedure setTask(val: tKlausTask);
    procedure refreshSettingList;
    procedure moveSettingListItem(delta: integer);
    function  selectedSetting: tKlausDoerSetting;
    procedure updateDoerView;
    procedure doerViewChange(sender: tObject);
  public
    property task: tKlausTask read fTask write setTask;

    constructor create(aOwner: tComponent); override;
    procedure refreshWindow;
    procedure enableDisable;
    function  isShortcut(var msg: tLMKey): boolean;
  end;

implementation

{$R *.lfm}

uses Math, FormMain;

resourcestring
  strNone = '(нет)';
  strNoname = '(без названия)';
  strIdxCap = '%d - %s';
  strAddSetting = 'Добавить обстановку';
  strRenameSetting = 'Переименовать обстановку';
  strDeleteSetting = 'Удалить обстановку "%s"?';
  strCaption = 'Название: ';
  strConfirmChangeDoer = 'При смене исполнителя все существующие обстановки будут удалены. Продолжить?';

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
      cbDoer.itemIndex := cbDoer.items.indexOfObject(tObject(task.doer));
      refreshSettingList;
      updateDoerView;
    end else begin
      cbDoer.itemIndex := 0;
      lbSetting.items.clear;
      freeAndNil(fView);
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
end;

function tDoerFrame.isShortcut(var msg: tLMKey): boolean;
begin
  result := false;
  if screen.activeControl = lbSetting then result := listActions.isShortCut(msg);
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

procedure tDoerFrame.actSettingDeleteExecute(Sender: TObject);
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

procedure tDoerFrame.actSettingMoveDownExecute(Sender: TObject);
begin
  moveSettingListItem(1);
end;

procedure tDoerFrame.actSettingMoveUpExecute(Sender: TObject);
begin
  moveSettingListItem(-1);
end;

procedure tDoerFrame.actSettingRenameExecute(Sender: TObject);
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

procedure tDoerFrame.lbSettingDblClick(Sender: TObject);
begin
  actSettingRename.execute;
end;

procedure tDoerFrame.lbSettingSelectionChange(Sender: TObject; User: boolean);
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
  ds: tKlausDoerSetting;
begin
  ds := selectedSetting;
  if ds = nil then
    freeAndNil(fView)
  else begin
    if fView = nil then cls := nil else cls := fView.doerClass;
    if cls <> task.doer then begin
      freeAndNil(fView);
      fView := task.doer.createView(self);
      fView.parent := pnDoer;
      fView.align := alClient;
      fView.borderStyle := bsSingle;
      fView.borderSpacing.around := 2;
      fView.onChange := @doerViewChange;
    end;
    fView.setting := ds;
  end;
end;

procedure tDoerFrame.doerViewChange(sender: tObject);
begin
  mainForm.modified := true;
  enableDisable;
end;

end.

