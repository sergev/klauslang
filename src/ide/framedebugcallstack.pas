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

unit FrameDebugCallStack;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ActnList, ComCtrls,
  FrameDebugView, KlausSrc;

type
  tDebugCallStackFrame = class(tDebugViewContent)
    actGoto: TAction;
    actionImages: TImageList;
    actionList: TActionList;
    lbCallStack: TListBox;
    toolBar: TToolBar;
    ToolButton3: TToolButton;
    procedure actGotoExecute(Sender: TObject);
    procedure lbCallStackClick(Sender: TObject);
    procedure lbCallStackDblClick(Sender: TObject);
  private
  protected
    function getActions: tCustomActionList; override;
  public
    procedure updateContent; override;
    procedure enableDisable; override;
  end;

implementation

{$R *.lfm}

uses LCLType, FormMain, FormScene;

{ tDebugCallStackFrame }

procedure tDebugCallStackFrame.lbCallStackClick(Sender: TObject);
begin
  with lbCallStack do begin
    if itemIndex < 0 then exit;
    mainForm.focusedStackFrame := ptrInt(items.objects[itemIndex]);
  end;
end;

procedure tDebugCallStackFrame.actGotoExecute(Sender: TObject);
var
  idx, l, c: integer;
  r: tKlausRuntime;
  fr: tKlausStackFrame;
begin
  if not mainForm.isRunning then exit;
  if sasHasExecPoint in mainForm.scene.actionState then begin
    with lbCallStack do begin
      if itemIndex < 0 then exit;
      idx := ptrInt(items.objects[itemIndex]);
    end;
    r := mainForm.scene.thread.runtime;
    if (idx <= 0) or (idx > r.stackCount) then exit;
    fr := r.stackFrames[idx];
    l := fr.callerPoint.line;
    c := fr.callerPoint.pos;
    if fr <> nil then mainForm.gotoSrcPoint(mainForm.scene.fileName, l, c);
  end;
end;

procedure tDebugCallStackFrame.lbCallStackDblClick(Sender: TObject);
begin
  actGoto.execute;
end;

function tDebugCallStackFrame.getActions: tCustomActionList;
begin
  result := actionList;
end;

procedure tDebugCallStackFrame.updateContent;
var
  i: integer;
  r: tKlausRuntime;
begin
  try
    lbCallStack.clear;
    if not mainForm.isRunning then exit;
    if sasHasExecPoint in mainForm.scene.actionState then begin
      r := mainForm.scene.thread.runtime;
      if r <> nil then
        for i := r.stackCount-1 downto 0 do begin
          {$ifndef debugide}if r.stackFrames[i].routine.hidden then continue;{$endif}
          lbCallStack.items.addObject(r.stackFrames[i].routine.displayName, tObject(ptrInt(i)));
        end;
    end;
  finally
    enableDisable;
  end;
end;

procedure tDebugCallStackFrame.enableDisable;
begin
  actGoto.enabled := lbCallStack.itemIndex >= 0;
end;

initialization
  debugViewContentClass[dvtCallStack] := tDebugCallStackFrame;
end.

