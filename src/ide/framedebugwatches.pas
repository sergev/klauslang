unit FrameDebugWatches;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, FrameDebugView, ComCtrls, ActnList,
  Dialogs, StdCtrls;

type
  tDebugWatchesFrame = class(tDebugViewContent)
    actAdd: TAction;
    actEdit: TAction;
    actDelete: TAction;
    actRefresh: TAction;
    actionImages: TImageList;
    actionList: TActionList;
    lbContent: TListBox;
    toolBar: TToolBar;
    tbAdd: TToolButton;
    tbEdit: TToolButton;
    tbDelete: TToolButton;
    ToolButton2: TToolButton;
    procedure actAddExecute(Sender: TObject);
  private
  protected
    function getActions: tCustomActionList; override;
  public
    procedure updateContent; override;
  end;

implementation

uses
  FormMain;

{$R *.lfm}

{ tDebugWatchesFrame }

procedure tDebugWatchesFrame.actAddExecute(Sender: TObject);
begin
  mainForm.actDebugEvaluateWatch.execute;
end;

function tDebugWatchesFrame.getActions: tCustomActionList;
begin
  result := actionList;
end;

procedure tDebugWatchesFrame.updateContent;
begin

end;

initialization
  //!!!debugViewContentClass[dvtWatches] := tDebugWatchesFrame;
end.

