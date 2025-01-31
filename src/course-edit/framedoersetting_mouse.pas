unit FrameDoerSetting_Mouse;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ActnList, ComCtrls, LMessages, KlausDoer,
  KlausDoer_Mouse, FrameDoer, Dialogs, ExtCtrls, StdCtrls, Menus;

type

  { tDoerSettingFrame_Mouse }

  tDoerSettingFrame_Mouse = class(tDoerSettingFrame)
    actArrowDown: tAction;
    actArrowLeft: tAction;
    actArrowRight: tAction;
    actArrowUp: tAction;
    actHideHelp: TAction;
    actShowHelp: TAction;
    actRadiation: TAction;
    actTemperature: TAction;
    actSettingMoveRight: tAction;
    actSettingClear: TAction;
    actionImages: tImageList;
    actMousePos: tAction;
    actMouseRotate: tAction;
    actPaint: tAction;
    actSymbolA: tAction;
    actSymbolB: tAction;
    actSymbolBullet: tAction;
    actCellProps: tAction;
    actWallDown: tAction;
    actWallLeft: tAction;
    actWallRight: tAction;
    actWallUp: tAction;
    actions: tActionList;
    lblKeyboardInfo: TLabel;
    miSettingMoveDown: TMenuItem;
    miSettingMoveUp: TMenuItem;
    miSettingMoveLeft: TMenuItem;
    miSettingMoveRight: TMenuItem;
    pmSettingMove: TPopupMenu;
    sbKeyboardInfo: TScrollBox;
    toolBar: tToolBar;
    ToolButton1: TToolButton;
    ToolButton10: tToolButton;
    ToolButton11: tToolButton;
    ToolButton12: tToolButton;
    ToolButton13: tToolButton;
    ToolButton14: tToolButton;
    ToolButton15: tToolButton;
    ToolButton16: tToolButton;
    ToolButton17: tToolButton;
    ToolButton18: tToolButton;
    ToolButton19: tToolButton;
    ToolButton2: tToolButton;
    ToolButton20: tToolButton;
    ToolButton21: tToolButton;
    ToolButton22: tToolButton;
    ToolButton23: tToolButton;
    ToolButton24: TToolButton;
    tbTemperature: TToolButton;
    tbRadiation: TToolButton;
    ToolButton25: TToolButton;
    ToolButton26: TToolButton;
    tbSettingMove: TToolButton;
    ToolButton3: tToolButton;
    ToolButton4: tToolButton;
    ToolButton5: TToolButton;
    ToolButton6: tToolButton;
    ToolButton7: tToolButton;
    ToolButton8: tToolButton;
    ToolButton9: tToolButton;
    procedure actArrowDownExecute(sender: tObject);
    procedure actArrowLeftExecute(sender: tObject);
    procedure actArrowRightExecute(sender: tObject);
    procedure actArrowUpExecute(sender: tObject);
    procedure actHideHelpExecute(Sender: TObject);
    procedure actSettingMoveDownExecute(Sender: TObject);
    procedure actSettingMoveLeftExecute(Sender: TObject);
    procedure actSettingMoveRightExecute(Sender: TObject);
    procedure actSettingMoveUpExecute(Sender: TObject);
    procedure actShowHelpExecute(Sender: TObject);
    procedure actRadiationExecute(sender: tObject);
    procedure actSettingClearExecute(sender: tObject);
    procedure actSettingSizeExecute(sender: tObject);
    procedure actMousePosExecute(sender: tObject);
    procedure actMouseRotateExecute(sender: tObject);
    procedure actPaintExecute(sender: tObject);
    procedure actSymbolAExecute(sender: tObject);
    procedure actSymbolBExecute(sender: tObject);
    procedure actSymbolBulletExecute(sender: tObject);
    procedure actCellPropsExecute(sender: tObject);
    procedure actTemperatureExecute(sender: tObject);
    procedure actWallDownExecute(sender: tObject);
    procedure actWallLeftExecute(sender: tObject);
    procedure actWallRightExecute(sender: tObject);
    procedure actWallUpExecute(sender: tObject);
    procedure tbSettingMoveClick(Sender: TObject);
  private
    fView: tKlausMouseView;

    procedure doerViewChange(sender: tObject);
    procedure doerViewDblClick(sender: tObject);
    function  getSetting: tKlausMouseSetting;
    procedure setSetting(val: tKlausMouseSetting);
  protected
    procedure setSetting(val: tKlausDoerSetting); override;
    function  handleShortCut(var msg: tLMKey): boolean; override;
  public
    property setting: tKlausMouseSetting read getSetting write setSetting;

    constructor create(aOwner: tComponent); override;
    class function doerClass: tKlausDoerClass; override;
    procedure enableDisable; override;
    function  focusedCell: tPoint;
  end;

implementation

uses DlgDoerMouseCellProps;

{$R *.lfm}

resourcestring
  strFieldSize = 'Размеры поля';
  strWidth = 'Ширина:';
  strHeight = 'Высота:';
  strConfirmSettingClear = 'Все стены и все свойства клеток будут удалены. Продолжить?';
  strKeyboardInfo =
    'Управление редактором обстановки:'#13#10+
    ' '#13#10+
    '- ЛКМ по краю клетки -- снять/поставить стену'#13#10+
    '- Ctrl+ЛКМ по краю клетки -- снять/поставить стрелку'#13#10+
    '- Alt+ЛКМ по краю клетки -- повернуть Мышку'#13#10+
    '- Двойной щелчок -- окно свойств клетки'#13#10+
    ' '#13#10+
    '- Shift+Стрелки -- снять/поставить стену'#13#10+
    '- Ctrl+Стрелки -- снять/поставить стрелку'#13#10+
    '- Alt+Стрелки -- повернуть Мышку'#13#10+
    '- Shift+Ctrl+Стрелки -- подвинуть обстановку'#13#10+
    '- Буквы -- поставить букву в нижний угол'#13#10+
    '- Shift+Буквы -- поставить букву в верхний угол'#13#10+
    '- Цифры, Минус -- набрать число'#13#10+
    '- Delete, Backspace -- удалить буквы и число'#13#10+
    '- Точка -- снять/поставить метку'#13#10+
    '- Пробел -- закрасить/очистить'#13#10+
    '- Enter -- поставить Мышку в текущую клетку'#13#10+
    '- Alt+Enter -- окно свойств клетки'#13#10+
    ' '#13#10+
    'В режиме редактирования температуры и радиации: '#13#10+
    '- Цифры, Минус, Точка и Запятая, Backspace -- набрать число'#13#10+
    '- Delete - обнулить значение';

{ tDoerSettingFrame_Mouse }

procedure tDoerSettingFrame_Mouse.actSettingSizeExecute(sender: tObject);
var
  val: array of string = nil;
  w, h: integer;
begin
  if setting <> nil then begin
    setLength(val, 2);
    val[0] := intToStr(setting.width);
    val[1] := intToStr(setting.height);
    if inputQuery(strFieldSize, [strWidth, strHeight], val) then begin
      w := strToInt(val[0]);
      h := strToInt(val[1]);
      setting.updating;
      try
        setting.width := w;
        setting.height := h;
      finally
        setting.updated;
      end;
    end;
  end;
end;

procedure tDoerSettingFrame_Mouse.actMousePosExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting do begin
    updating;
    try
      mouseX := p.x;
      mouseY := p.y;
    finally
      updated;
    end;
  end;
end;

procedure tDoerSettingFrame_Mouse.actMouseRotateExecute(sender: tObject);
const
  nextDir: array[tKlausMouseDirection] of tKlausMouseDirection = (kmdLeft, kmdUp, kmdRight, kmdDown, kmdLeft);
begin
  if setting = nil then exit;
  with setting do mouseDir := nextDir[mouseDir];
end;

procedure tDoerSettingFrame_Mouse.actPaintExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do painted := not painted;
end;

procedure tDoerSettingFrame_Mouse.actSymbolAExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do
    if text2 = 'А' then text2 := '' else text2 := 'А';
end;

procedure tDoerSettingFrame_Mouse.actSymbolBExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do
    if text1 = 'Б' then text1 := '' else text1 := 'Б';
end;

procedure tDoerSettingFrame_Mouse.actSymbolBulletExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do mark := not mark;
end;

procedure tDoerSettingFrame_Mouse.actCellPropsExecute(sender: tObject);
var
  cell: tKlausMouseCell;
begin
  if setting = nil then exit;
  with focusedCell do cell := setting[x, y];
  with tDoerMouseCellPropsDlg.create(application) do try
    text1 := cell.text1;
    text2 := cell.text2;
    number := cell.number;
    hasNumber := cell.hasNumber;
    mark := cell.mark;
    arrow := cell.arrow;
    temperature := cell.temperature;
    radiation := cell.radiation;
    if showModal = mrOk then begin
      setting.updating;
      try
        cell.text1 := text1;
        cell.text2 := text2;
        cell.number := number;
        cell.hasNumber := hasNumber;
        cell.mark := mark;
        cell.arrow := arrow;
        cell.temperature := temperature;
        cell.radiation := radiation;
      finally
        setting.updated;
      end;
    end;
  finally
    free;
  end;
end;

procedure tDoerSettingFrame_Mouse.actTemperatureExecute(sender: tObject);
begin
  if setting = nil then exit;
  if fView.mode = mvmTemperature then fView.mode := mvmNormal
  else fView.mode := mvmTemperature;
end;

procedure tDoerSettingFrame_Mouse.actArrowLeftExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do
    if arrow = kmdLeft then arrow := kmdNone
    else arrow := kmdLeft;
end;

procedure tDoerSettingFrame_Mouse.actArrowDownExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do
    if arrow = kmdDown then arrow := kmdNone
    else arrow := kmdDown;
end;

procedure tDoerSettingFrame_Mouse.actArrowRightExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do
    if arrow = kmdRight then arrow := kmdNone
    else arrow := kmdRight;
end;

procedure tDoerSettingFrame_Mouse.actArrowUpExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do
    if arrow = kmdUp then arrow := kmdNone
    else arrow := kmdUp;
end;

procedure tDoerSettingFrame_Mouse.actHideHelpExecute(Sender: TObject);
begin
  sbKeyboardInfo.visible := false;
  if fView <> nil then begin
    fView.visible := true;
    fView.setFocus;
  end;
  actHideHelp.enabled := false;
end;

procedure tDoerSettingFrame_Mouse.actSettingMoveDownExecute(Sender: TObject);
begin
  if setting = nil then exit;
  setting.move(kmdDown);
end;

procedure tDoerSettingFrame_Mouse.actSettingMoveLeftExecute(Sender: TObject);
begin
  if setting = nil then exit;
  setting.move(kmdLeft);
end;

procedure tDoerSettingFrame_Mouse.actSettingMoveRightExecute(Sender: TObject);
begin
  if setting = nil then exit;
  setting.move(kmdRight);
end;

procedure tDoerSettingFrame_Mouse.actSettingMoveUpExecute(Sender: TObject);
begin
  if setting = nil then exit;
  setting.move(kmdUp);
end;

procedure tDoerSettingFrame_Mouse.actShowHelpExecute(Sender: TObject);
begin
  if sbKeyboardInfo.visible then
    actHideHelp.execute
  else begin
    if fView <> nil then fView.visible := false;
    lblKeyboardInfo.caption := strKeyboardInfo;
    sbKeyboardInfo.visible := true;
    sbKeyboardInfo.setFocus;
    actHideHelp.enabled := true;
  end;
end;

procedure tDoerSettingFrame_Mouse.actRadiationExecute(sender: tObject);
begin
  if setting = nil then exit;
  if fView.mode = mvmRadiation then fView.mode := mvmNormal
  else fView.mode := mvmRadiation;
end;

procedure tDoerSettingFrame_Mouse.actSettingClearExecute(sender: tObject);
begin
  if setting = nil then exit;
  if messageDlg(strConfirmSettingClear, mtConfirmation, [mbYes, mbCancel], 0) <> mrYes then exit;
  setting.clear;
end;

procedure tDoerSettingFrame_Mouse.actWallDownExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do wall[kmdDown] := not wall[kmdDown];
end;

procedure tDoerSettingFrame_Mouse.actWallLeftExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do wall[kmdLeft] := not wall[kmdLeft];
end;

procedure tDoerSettingFrame_Mouse.actWallRightExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do wall[kmdRight] := not wall[kmdRight];
end;

procedure tDoerSettingFrame_Mouse.actWallUpExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do wall[kmdUp] := not wall[kmdUp];
end;

procedure tDoerSettingFrame_Mouse.tbSettingMoveClick(Sender: TObject);
begin
  tbSettingMove.checkMenuDropdown;
end;

procedure tDoerSettingFrame_Mouse.doerViewChange(sender: tObject);
begin
  change;
end;

procedure tDoerSettingFrame_Mouse.doerViewDblClick(sender: tObject);
begin
  actCellProps.execute;
end;

function tDoerSettingFrame_Mouse.getSetting: tKlausMouseSetting;
begin
  result := inherited setting as tKlausMouseSetting;
end;

procedure tDoerSettingFrame_Mouse.setSetting(val: tKlausMouseSetting);
begin
  setSetting(tKlausDoerSetting(val));
end;

procedure tDoerSettingFrame_Mouse.setSetting(val: tKlausDoerSetting);
begin
  inherited setSetting(val);
  fView.setting := setting;
  enableDisable;
end;

function tDoerSettingFrame_Mouse.handleShortCut(var msg: tLMKey): boolean;
begin
  result := actions.isShortCut(msg);
end;

constructor tDoerSettingFrame_Mouse.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  fView := tKlausDoerMouse.createView(self, kdvmEdit) as tKlausMouseView;
  fView.parent := self;
  fView.align := alClient;
  fView.borderStyle := bsSingle;
  fView.onChange := @doerViewChange;
  fView.OnDblClick := @doerViewDblClick;
end;

class function tDoerSettingFrame_Mouse.doerClass: tKlausDoerClass;
begin
  result := tKlausDoerMouse;
end;

procedure tDoerSettingFrame_Mouse.enableDisable;
var
  i: integer;
begin
  inherited enableDisable;
  for i := 0 to actions.actionCount-1 do
    (actions.actions[i] as tCustomAction).enabled := setting <> nil;
end;

function tDoerSettingFrame_Mouse.focusedCell: tPoint;
begin
  if fView = nil then result := point(-1, -1)
  else result := point(fView.focusX, fView.focusY);
end;

initialization
  registerDoerSettingFrame(tKlausDoerMouse, tDoerSettingFrame_Mouse);
end.

