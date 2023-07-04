unit FrameDebugBreakpoints;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, KlausSrc, FrameDebugView;

type
  TDebugBreakpointsFrame = class(tDebugViewContent)
    lbBreakpoints: TListBox;
    procedure lbBreakpointsDblClick(Sender: TObject);
    procedure lbBreakpointsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private

  public
    procedure updateContent; override;
  end;

implementation

uses LCLType, FormMain;

{$R *.lfm}

resourcestring
  strBreakpointInfo = 'стр. %d - %s';

{ TDebugBreakpointsFrame }

procedure TDebugBreakpointsFrame.lbBreakpointsDblClick(Sender: TObject);
begin
  mainForm.gotoBreakpoint(lbBreakpoints.itemIndex);
end;

procedure TDebugBreakpointsFrame.lbBreakpointsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (key = VK_RETURN) and (shift = []) then
    mainForm.gotoBreakpoint(lbBreakpoints.itemIndex);
end;

procedure TDebugBreakpointsFrame.updateContent;
var
  i: integer;
  b: tKlausBreakpoint;
begin
  lbBreakpoints.clear;
  for i := 0 to mainForm.breakpointCount-1 do begin
    b := mainForm.breakpoint[i];
    lbBreakpoints.items.add(format(strBreakpointInfo, [b.line, extractFileName(b.fileName)]));
  end;
end;

initialization
  debugViewContentClass[dvtBreakpoints] := tDebugBreakpointsFrame;
end.

