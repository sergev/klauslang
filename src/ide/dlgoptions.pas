unit DlgOptions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  KlausGlobals, FrameEditorOptions;

type
  TOptionsDlg = class(TForm)
    pageControl: TPageControl;
    tsEditor: TTabSheet;
    pnButtons: TPanel;
    pbCancel: TButton;
    pbSave: TButton;
  private
    fRefreshCount: integer;
    fEditorOptions: tEditorOptionsFrame;

    function  getRefreshing: boolean;
    function  getEditorOptions: tKlausEditorOptions;
    procedure setEditorOptions(val: tKlausEditorOptions);
  protected
    procedure beginRefresh;
    procedure endRefresh;
  public
    property refreshing: boolean read getRefreshing;
    property editorOptions: tKlausEditorOptions read getEditorOptions write setEditorOptions;

    constructor create(aOwner: tComponent); override;
    procedure refreshWindow;
    procedure enableDisable;
  end;

implementation

{$R *.lfm}

{ TOptionsDlg }

constructor TOptionsDlg.create(aOwner: tComponent);
begin
  inherited;
  fEditorOptions := tEditorOptionsFrame.create(self);
  fEditorOptions.parent := tsEditor;
  fEditorOptions.align := alClient;
end;

procedure TOptionsDlg.refreshWindow;
begin
  beginRefresh;
  try
    fEditorOptions.refreshWindow;
  finally
    endRefresh;
  end;
end;

function TOptionsDlg.getRefreshing: boolean;
begin
  result := fRefreshCount > 0;
end;

function TOptionsDlg.getEditorOptions: tKlausEditorOptions;
begin
  result := fEditorOptions.editorOptions;
end;

procedure TOptionsDlg.setEditorOptions(val: tKlausEditorOptions);
begin
  fEditorOptions.editorOptions := val;
end;

procedure TOptionsDlg.beginRefresh;
begin
  inc(fRefreshCount);
end;

procedure TOptionsDlg.endRefresh;
begin
  if fRefreshCount > 0 then dec(fRefreshCount);
end;

procedure TOptionsDlg.enableDisable;
begin
  fEditorOptions.enableDisable;
end;

end.

