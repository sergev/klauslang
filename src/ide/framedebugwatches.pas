unit FrameDebugWatches;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, FrameDebugView, ComCtrls, ActnList,
  Dialogs, StdCtrls, Grids;

type

  { tDebugWatchesFrame }

  tDebugWatchesFrame = class(tDebugViewContent)
    actAdd: TAction;
    actEdit: TAction;
    actDelete: TAction;
    actRefresh: TAction;
    actionImages: TImageList;
    actionList: TActionList;
    sgContent: TStringGrid;
    toolBar: TToolBar;
    tbAdd: TToolButton;
    tbEdit: TToolButton;
    tbDelete: TToolButton;
    ToolButton2: TToolButton;
    procedure actAddExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure sgContentDblClick(Sender: TObject);
    procedure sgContentGetCellHint(Sender: TObject; ACol, ARow: Integer; var HintText: String);
  private
  protected
    function getActions: tCustomActionList; override;
  public
    procedure updateContent; override;
    procedure enableDisable; override;
  end;

implementation

uses
  U8, KlausSrc, FormMain, DlgEvaluate;

{$R *.lfm}

{ tDebugWatchesFrame }

procedure tDebugWatchesFrame.actAddExecute(Sender: TObject);
begin
  mainForm.actDebugEvaluateWatch.execute;
end;

procedure tDebugWatchesFrame.actDeleteExecute(Sender: TObject);
var
  idx: integer;
begin
  idx := sgContent.row-1;
  if idx >= 0 then mainForm.deleteWatch(idx);
end;

procedure tDebugWatchesFrame.actEditExecute(Sender: TObject);
var
  idx: integer;
begin
  idx := sgContent.row-1;
  if idx < 0 then exit;
  with tEvaluateDlg.create(application) do try
    text := mainForm.watches[idx].text;
    allowFunctions := mainForm.watches[idx].allowFunctions;
    value := sgContent.cells[1, idx+1];
    if showModal = mrOK then
      if text <> '' then mainForm.editWatch(idx, text, allowFunctions);
  finally
    free;
  end;
end;

procedure tDebugWatchesFrame.actRefreshExecute(Sender: TObject);
begin
  updateContent;
end;

procedure tDebugWatchesFrame.sgContentDblClick(Sender: TObject);
begin
  actEdit.execute;
end;

procedure tDebugWatchesFrame.sgContentGetCellHint(Sender: TObject; ACol, ARow: Integer; var HintText: String);
begin
  hintText := u8Copy(sgContent.cells[aCol, aRow], 0, 1023);
end;

function tDebugWatchesFrame.getActions: tCustomActionList;
begin
  result := actionList;
end;

procedure tDebugWatchesFrame.updateContent;
var
  x, s: string;
  i, cnt: integer;
  fr: tKlausStackFrame;
begin
  fr := mainForm.focusedStackFrame;
  cnt := mainForm.watchCount;
  sgContent.rowCount := cnt+1;
  for i := 0 to cnt-1 do begin
    x := mainForm.watches[i].text;
    sgContent.cells[0, i+1] := x;
    if fr <> nil then begin
      s := fr.owner.evaluate(fr, x, mainForm.watches[i].allowFunctions);
      sgContent.cells[1, i+1] := u8Copy(s, 0, 65535);
    end else
      sgContent.cells[1, i+1] := '';
  end;
  enableDisable;
end;

procedure tDebugWatchesFrame.enableDisable;
begin
  actEdit.enabled := sgContent.row >= 1;
  actDelete.enabled := sgContent.row >= 1;
end;

initialization
  debugViewContentClass[dvtWatches] := tDebugWatchesFrame;
end.

