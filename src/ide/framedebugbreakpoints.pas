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

unit FrameDebugBreakpoints;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ActnList, ComCtrls, KlausSrc,
  FrameDebugView;

type
  TDebugBreakpointsFrame = class(tDebugViewContent)
    actGoto: TAction;
    actDelete: TAction;
    actionImages: TImageList;
    actionList: TActionList;
    lbBreakpoints: TListBox;
    toolBar: TToolBar;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    procedure actDeleteExecute(Sender: TObject);
    procedure actGotoExecute(Sender: TObject);
    procedure lbBreakpointsClick(Sender: TObject);
    procedure lbBreakpointsDblClick(Sender: TObject);
  private
  protected
    function getActions: tCustomActionList; override;
  public
    procedure updateContent; override;
    procedure enableDisable; override;
  end;

implementation

uses LCLType, FormMain, FrameEdit;

{$R *.lfm}

resourcestring
  strBreakpointInfo = 'стр. %d - %s';

{ TDebugBreakpointsFrame }

procedure TDebugBreakpointsFrame.lbBreakpointsDblClick(Sender: TObject);
begin
  mainForm.gotoBreakpoint(lbBreakpoints.itemIndex);
end;

function TDebugBreakpointsFrame.getActions: tCustomActionList;
begin
  result := actionList;
end;

procedure TDebugBreakpointsFrame.actGotoExecute(Sender: TObject);
begin
  mainForm.gotoBreakpoint(lbBreakpoints.itemIndex);
end;

procedure TDebugBreakpointsFrame.lbBreakpointsClick(Sender: TObject);
begin
  enableDisable;
end;

procedure TDebugBreakpointsFrame.actDeleteExecute(Sender: TObject);
var
  idx: integer;
  bp: tKlausBreakpoint;
  frm: tEditFrame;
begin
  idx := lbBreakpoints.itemIndex;
  if idx < 0 then exit;
  bp := mainForm.breakpoint[idx];
  frm := mainForm.findEditFrame(bp.fileName);
  if frm <> nil then frm.toggleBreakpoint(bp.line-1, tbmDelete);
end;

procedure TDebugBreakpointsFrame.updateContent;
var
  i: integer;
  b: tKlausBreakpoint;
begin
  try
    lbBreakpoints.clear;
    for i := 0 to mainForm.breakpointCount-1 do begin
      b := mainForm.breakpoint[i];
      lbBreakpoints.items.add(format(strBreakpointInfo, [b.line, extractFileName(b.fileName)]));
    end;
  finally
    enableDisable;
  end;
end;

procedure TDebugBreakpointsFrame.enableDisable;
begin
  actGoto.enabled := lbBreakpoints.itemIndex >= 0;
  actDelete.enabled := lbBreakpoints.itemIndex >= 0;
end;

initialization
  debugViewContentClass[dvtBreakpoints] := tDebugBreakpointsFrame;
end.

