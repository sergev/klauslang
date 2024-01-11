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

unit FrameDebugVariables;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ActnList, ComCtrls, KlausSrc,
  FrameDebugView;

type
  tDebugVariablesFrame = class(tDebugViewContent)
    actGoto: TAction;
    actionImages: TImageList;
    actionList: TActionList;
    actRefresh: TAction;
    lbVariables: TListBox;
    toolBar: TToolBar;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    procedure actGotoExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure lbVariablesClick(Sender: TObject);
    procedure lbVariablesDblClick(Sender: TObject);
  private
  protected
    function getActions: tCustomActionList; override;
  public
    procedure updateContent; override;
    procedure enableDisable; override;
  end;

implementation

{$R *.lfm}

uses FormMain, FormScene;

{ tDebugVariablesFrame }

procedure tDebugVariablesFrame.actRefreshExecute(Sender: TObject);
begin
  updateContent;
end;

procedure tDebugVariablesFrame.lbVariablesClick(Sender: TObject);
begin
  enableDisable;
end;

procedure tDebugVariablesFrame.lbVariablesDblClick(Sender: TObject);
begin
  actGoto.execute;
end;

function tDebugVariablesFrame.getActions: tCustomActionList;
begin
  result := actionList;
end;

procedure tDebugVariablesFrame.actGotoExecute(Sender: TObject);
var
  v: tKlausVariable;
  l, c: integer;
begin
  with lbVariables do begin
    if itemIndex < 0 then exit;
    v := items.objects[itemIndex] as tKlausVariable;
  end;
  l := v.decl.point.line;
  c := v.decl.point.pos;
  mainForm.gotoSrcPoint(mainForm.scene.fileName, l, c);
end;

procedure tDebugVariablesFrame.updateContent;
var
  s: string;
  i, idx: integer;
  r: tKlausRuntime;
  v: tKlausVariable;
  fr: tKlausStackFrame;
begin
  try
    lbVariables.clear;
    if not mainForm.isRunning then exit;
    if sasHasExecPoint in mainForm.scene.actionState then begin
      r := mainForm.scene.thread.runtime;
      idx := mainForm.focusedStackFrame;
      if (idx >= 0) and (idx < r.stackCount) then fr := r.stackFrames[idx]
      else fr := r.stackTop;
      if fr <> nil then
        for i := 0 to fr.varCount-1 do begin
          v := fr.vars[i];
          {$ifndef debugide}if v.decl.hidden then continue;{$endif}
          s := v.decl.name + ': ' + v.displayValue;
          lbVariables.items.addObject(s, v);
        end;
    end;
  finally
    enableDisable;
  end;
end;

procedure tDebugVariablesFrame.enableDisable;
begin
  actRefresh.enabled := mainForm.isRunning;
  actGoto.enabled := lbVariables.itemIndex >= 0;
end;

initialization
  debugViewContentClass[dvtVariables] := tDebugVariablesFrame;
end.

