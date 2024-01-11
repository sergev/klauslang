unit DlgEvaluate;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  IniPropStorage;

type
  tEvaluateDlg = class(TForm)
    cbText: TComboBox;
    chAllowFunctions: TCheckBox;
    lblExpression: TLabel;
    lblResult: TLabel;
    mlResult: TMemo;
    pbCancel: TButton;
    pbEvaluate: TButton;
    pbAddWatch: TButton;
    propStorage: TIniPropStorage;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure pbEvaluateClick(Sender: TObject);
  private
    function  getAllowFunctions: boolean;
    function  getText: string;
    procedure setAllowFunctions(val: boolean);
    procedure setText(val: string);
    procedure updateCombo;
  public
     property text: string read getText write setText;
     property allowFunctions: boolean read getAllowFunctions write setAllowFunctions;
  end;

implementation

uses
  FormMain;

{$R *.lfm}

{ tEvaluateDlg }

procedure tEvaluateDlg.pbEvaluateClick(Sender: TObject);
begin
  updateCombo;
end;

procedure tEvaluateDlg.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if modalResult = mrOK then updateCombo;
end;

function tEvaluateDlg.getAllowFunctions: boolean;
begin
  result := chAllowFunctions.checked;
end;

function tEvaluateDlg.getText: string;
begin
  result := cbText.text;
end;

procedure tEvaluateDlg.setAllowFunctions(val: boolean);
begin
  chAllowFunctions.checked := val;
end;

procedure tEvaluateDlg.setText(val: string);
begin
  cbText.text := val;
end;

procedure tEvaluateDlg.updateCombo;
var
  s: string;
  idx: integer;
begin
  s := cbText.text;
  if s <> '' then with cbText.items do begin
    idx := indexOf(s);
    if idx >= 0 then delete(idx);
    insert(0, s);
    while count > maxEvaluateHistoryItems do delete(count-1);
    cbText.text := s;
  end;
end;

end.

