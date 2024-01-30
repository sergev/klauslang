unit DlgEvaluate;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  IniPropStorage;

type

  { tEvaluateDlg }

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
    procedure cbTextChange(Sender: TObject);
    procedure formClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure pbEvaluateClick(Sender: TObject);
  private
    function  getAllowFunctions: boolean;
    function  getText: string;
    function  getValue: string;
    procedure setAllowFunctions(val: boolean);
    procedure setText(val: string);
    procedure setValue(val: string);
    procedure updateCombo;
  public
    property text: string read getText write setText;
    property allowFunctions: boolean read getAllowFunctions write setAllowFunctions;
    property value: string read getValue write setValue;

    procedure enableDisable;
  end;

implementation

uses
  LCLType, FormMain, KlausSrc, U8;

{$R *.lfm}

{ tEvaluateDlg }

procedure tEvaluateDlg.pbEvaluateClick(Sender: TObject);
var
  s: string;
  fr: tKlausStackFrame;
begin
  updateCombo;
  mlResult.text := '';
  if cbText.text = '' then exit;
  fr := mainForm.focusedStackFrame;
  if fr <> nil then begin
    s := fr.owner.evaluate(fr, cbText.text, allowFunctions);
    mlResult.text := u8Copy(s, 0, 65535);
  end;
end;

procedure tEvaluateDlg.formClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if modalResult = mrOK then updateCombo;
end;

procedure tEvaluateDlg.cbTextChange(Sender: TObject);
begin
  enableDisable;
end;

procedure tEvaluateDlg.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (shift = [ssCtrl]) then begin
    if pbAddWatch.enabled then modalResult := mrOK;
    key := 0;
  end;
end;

procedure tEvaluateDlg.FormShow(Sender: TObject);
begin
  enableDisable;
end;

function tEvaluateDlg.getAllowFunctions: boolean;
begin
  result := chAllowFunctions.checked;
end;

function tEvaluateDlg.getText: string;
begin
  result := cbText.text;
end;

function tEvaluateDlg.getValue: string;
begin
  result := mlResult.text;
end;

procedure tEvaluateDlg.setAllowFunctions(val: boolean);
begin
  chAllowFunctions.checked := val;
end;

procedure tEvaluateDlg.setText(val: string);
begin
  cbText.text := val;
end;

procedure tEvaluateDlg.setValue(val: string);
begin
  mlResult.text := val;
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

procedure tEvaluateDlg.enableDisable;
begin
  pbEvaluate.enabled := cbText.text <> '';
  pbAddWatch.enabled := cbText.text <> '';
end;

end.

