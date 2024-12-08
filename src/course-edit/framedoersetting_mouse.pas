unit FrameDoerSetting_Mouse;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ActnList, ComCtrls, LMessages, KlausDoer,
  KlausDoer_Mouse, FrameDoer, Dialogs;

type

  { tDoerSettingFrame_Mouse }

  tDoerSettingFrame_Mouse = class(tDoerSettingFrame)
    actArrowDown: tAction;
    actArrowLeft: tAction;
    actArrowRight: tAction;
    actArrowUp: tAction;
    actFieldSize: tAction;
    actionImages: tImageList;
    actMousePos: tAction;
    actMouseRotate: tAction;
    actPaint: tAction;
    actSymbolA: tAction;
    actSymbolB: tAction;
    actSymbolBullet: tAction;
    actSymbolOther: tAction;
    actWallDown: tAction;
    actWallLeft: tAction;
    actWallRight: tAction;
    actWallUp: tAction;
    actions: tActionList;
    toolBar: tToolBar;
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
    ToolButton3: tToolButton;
    ToolButton4: tToolButton;
    ToolButton6: tToolButton;
    ToolButton7: tToolButton;
    ToolButton8: tToolButton;
    ToolButton9: tToolButton;
    procedure actArrowDownExecute(sender: tObject);
    procedure actArrowLeftExecute(sender: tObject);
    procedure actArrowRightExecute(sender: tObject);
    procedure actArrowUpExecute(sender: tObject);
    procedure actFieldSizeExecute(sender: tObject);
    procedure actMousePosExecute(sender: tObject);
    procedure actMouseRotateExecute(Sender: TObject);
    procedure actPaintExecute(sender: tObject);
    procedure actSymbolAExecute(sender: tObject);
    procedure actSymbolBExecute(sender: tObject);
    procedure actSymbolBulletExecute(sender: tObject);
    procedure actSymbolOtherExecute(sender: tObject);
    procedure actWallDownExecute(sender: tObject);
    procedure actWallLeftExecute(sender: tObject);
    procedure actWallRightExecute(sender: tObject);
    procedure actWallUpExecute(sender: tObject);
  private
    fView: tKlausMouseView;

    procedure doerViewChange(sender: tObject);
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

{$R *.lfm}

resourcestring
  strFieldSize = 'Размеры поля';
  strWidth = 'Ширина:';
  strHeight = 'Высота:';
  strCellSymbol = 'Символ в ячейке';
  strSymbol = 'Символ';

{ tDoerSettingFrame_Mouse }

procedure tDoerSettingFrame_Mouse.actFieldSizeExecute(sender: tObject);
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

procedure tDoerSettingFrame_Mouse.actMouseRotateExecute(Sender: TObject);
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
    if text = 'А' then text := '' else text := 'А';
end;

procedure tDoerSettingFrame_Mouse.actSymbolBExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do
    if text = 'Б' then text := '' else text := 'Б';
end;

procedure tDoerSettingFrame_Mouse.actSymbolBulletExecute(sender: tObject);
var
  p: tPoint;
begin
  if setting = nil then exit;
  p := focusedCell;
  with setting[p.x, p.y] do
    if text = '•' then text := '' else text := '•';
end;

procedure tDoerSettingFrame_Mouse.actSymbolOtherExecute(sender: tObject);
var
  p: tPoint;
  val: string;
begin
  if setting = nil then exit;
  p := focusedCell;
  val := setting[p.x, p.y].text;
  if inputQuery(strCellSymbol, strSymbol, val) then setting[p.x, p.y].text := val;
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

procedure tDoerSettingFrame_Mouse.doerViewChange(sender: tObject);
begin
  change;
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
  fView := tKlausDoerMouse.createView(self) as tKlausMouseView;
  fView.parent := self;
  fView.align := alClient;
  fView.borderStyle := bsSingle;
  fView.onChange := @doerViewChange;
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

