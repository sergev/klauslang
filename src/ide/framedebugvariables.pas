unit FrameDebugVariables;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, KlausSrc, FrameDebugView;

type
  tDebugVariablesFrame = class(tDebugViewContent)
    lbVariables: TListBox;
  private

  public
    procedure updateContent; override;
  end;

implementation

{$R *.lfm}

uses FormMain, FormScene;

{ tDebugVariablesFrame }

procedure tDebugVariablesFrame.updateContent;
var
  s: string;
  i, idx: integer;
  r: tKlausRuntime;
  v: tKlausVariable;
  fr: tKlausStackFrame;
begin
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
        lbVariables.items.add(s);
      end;
  end;
end;

initialization
  debugViewContentClass[dvtVariables] := tDebugVariablesFrame;
end.

