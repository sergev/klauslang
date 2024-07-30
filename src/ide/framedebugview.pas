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

unit FrameDebugView;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, Messages, Forms, Controls, ExtCtrls, Buttons, StdCtrls, ActnList,
  KlausGlobals;

type
  tDebugViewType = (dvtVariables, dvtCallStack, dvtWatches, dvtBreakpoints);
  tDebugViewTypes = set of tDebugViewType;

const
  debugViewName: array[tDebugViewType] of string = (
    'frameDebugVariables', 'frameDebugCallStack', 'frameDebugWatches', 'frameDebugBreakpoints');

  debugViewCaption: array[tDebugViewType] of string = (
    'Переменные', 'Стек вызовов', 'Наблюдения', 'Точки останова');

type
  tDebugViewContent = class(tFrame)
    private
      fControlStateInvalid: boolean;
    protected
      procedure createWnd; override;
      function  getActions: tCustomActionList; virtual;
      procedure invalidateControlState;
      procedure APPMUpdateControlState(var msg: tMessage); message APPM_UpdateControlState;
    public
      property actions: tCustomActionList read getActions;

      procedure updateContent; virtual; abstract;
      procedure enableDisable; virtual;
  end;
  tDebugViewContentClass = class of tDebugViewContent;

var
  debugViewContentClass: array[tDebugViewType] of tDebugViewContentClass;

type
  tDebugViewFrame = class(TFrame)
    bvSizer: TBevel;
    buttonImages: TImageList;
    lblCaption: TLabel;
    pnContent: TPanel;
    pnHeader: TPanel;
    sbClose: TSpeedButton;
    sbMoveDown: TSpeedButton;
    sbMoveUp: TSpeedButton;
    procedure bvSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvSizerMouseMove(sender: TObject; shift: TShiftState; x, y: integer);
    procedure bvSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure sbCloseClick(Sender: TObject);
    procedure sbMoveDownClick(Sender: TObject);
    procedure sbMoveUpClick(Sender: TObject);
  private
    fStoredHeight: integer;
    fSizing: boolean;
    fSizingPoint: tPoint;
    fPosition: integer;
    fViewType: tDebugViewType;
    fContent: tDebugViewContent;

    function  getCaption: string;
    function  getPosition: integer;
    function  getFrameStoredHeight: integer;
    procedure setPosition(val: integer);
    procedure setFrameStoredHeight(val: integer);
    procedure setViewType(val: tDebugViewType);
    procedure destroyContent;
    procedure createContent;
  protected
    procedure setVisible(val: boolean); override;
  public
    property viewType: tDebugViewType read fViewType write setViewType;
    property caption: string read getCaption;

    constructor create(aOwner: tComponent); override;
    destructor  destroy; override;
    procedure invalidateControlState;
    procedure updateContent;
    procedure enableDisable;
  published
    property position: integer read getPosition write setPosition;
    property frameStoredHeight: integer read getFrameStoredHeight write setFrameStoredHeight;
  end;

implementation

uses
  Math, LCLType, LCLIntf, Graphics, KlausUtils, FormMain;

{$R *.lfm}

{ tDebugViewContent }

procedure tDebugViewContent.createWnd;
begin
  inherited;
  if fControlStateInvalid then postMessage(handle, APPM_UpdateControlState, 0, 0);
end;

function tDebugViewContent.getActions: tCustomActionList;
begin
  result := nil;
end;

procedure tDebugViewContent.invalidateControlState;
begin
  if not fControlStateInvalid then begin
    fControlStateInvalid := true;
    if handleAllocated then postMessage(handle, APPM_UpdateControlState, 0, 0);
  end;
end;

procedure tDebugViewContent.APPMUpdateControlState(var msg: tMessage);
begin
  fControlStateInvalid := false;
  enableDisable;
end;

procedure tDebugViewContent.enableDisable;
begin
end;

{ tDebugViewFrame }

constructor tDebugViewFrame.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  fStoredHeight := -1;
  mainForm.addControlStateClient(self);
end;

destructor tDebugViewFrame.destroy;
begin
  mainForm.removeControlStateClient(self);
  inherited destroy;
end;

procedure tDebugViewFrame.setViewType(val: tDebugViewType);
begin
  destroyContent;
  fViewType := val;
  name := debugViewName[val];
  lblCaption.caption := caption;
  createContent;
end;

procedure tDebugViewFrame.destroyContent;
begin
  if assigned(fContent) then freeAndNil(fContent);
end;

procedure tDebugViewFrame.createContent;
begin
  if assigned(debugViewContentClass[viewType]) then begin
    fContent := debugViewContentClass[viewType].create(self);
    fContent.parent := pnContent;
    fContent.align := alClient;
    updateContent;
  end;
end;

procedure tDebugViewFrame.updateContent;
begin
  if assigned(fContent) then fContent.updateContent;
end;

procedure tDebugViewFrame.enableDisable;
begin
  if fStoredHeight >= 0 then begin
    height := min(mainForm.height div 3, fStoredHeight);
    fStoredHeight := -1;
  end;
  if assigned(fContent) then fContent.invalidateControlState;
end;

function tDebugViewFrame.getCaption: string;
begin
  result := debugViewCaption[fViewType];
end;

function tDebugViewFrame.getPosition: integer;
begin
  if mainForm.propsLoading then result := fPosition
  else if not (parent is tCustomFlowPanel) then result := -1
  else result := (parent as tCustomFlowPanel).GetControlIndex(self);
end;

function tDebugViewFrame.getFrameStoredHeight: integer;
begin
  result := height;
  //mulDiv(height, designTimePPI, screenInfo.pixelsPerInchX);
end;

procedure tDebugViewFrame.setFrameStoredHeight(val: integer);
begin
  fStoredHeight := val;
  //height := val;
end;

procedure tDebugViewFrame.setPosition(val: integer);
begin
  if mainForm.propsLoading then fPosition := val
  else if not (parent is tCustomFlowPanel) then //nothing
  else (parent as tCustomFlowPanel).setControlIndex(self, val);
end;

procedure tDebugViewFrame.setVisible(val: boolean);
begin
  if visible <> val then invalidateControlState;
  inherited setVisible(val);
end;

procedure tDebugViewFrame.invalidateControlState;
begin
  mainForm.invalidateControlState;
end;

procedure tDebugViewFrame.bvSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then begin
    fSizing := true;
    fSizingPoint := bvSizer.clientToScreen(point(x, y));
  end;
end;

procedure tDebugViewFrame.bvSizerMouseMove(sender: TObject; shift: TShiftState; x, y: integer);
var
  p: tPoint;
begin
  if fSizing then begin
    p := bvSizer.clientToScreen(point(x, y));
    height := max(100, height - fSizingPoint.y + p.y);
    fSizingPoint := p;
  end;
end;

procedure tDebugViewFrame.bvSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then fSizing := false;
end;

procedure tDebugViewFrame.sbCloseClick(Sender: TObject);
begin
  visible := false;
end;

procedure tDebugViewFrame.sbMoveDownClick(Sender: TObject);
var
  i, p: integer;
begin
  if not (parent is tFlowPanel) then exit;
  p := position+1;
  with parent as tFlowPanel do
    for i := p to controlList.count-1 do begin
      if controlList[i].control.visible then break;
      p += 1;
    end;
  position := p;
end;

procedure tDebugViewFrame.sbMoveUpClick(Sender: TObject);
var
  i, p: integer;
begin
  if not (parent is tFlowPanel) then exit;
  p := position-1;
  if p < 0 then exit;
  with parent as tFlowPanel do
    for i := p downto 1 do begin
      if controlList[i].control.visible then break;
      p -= 1;
    end;
  position := p;
end;

end.

