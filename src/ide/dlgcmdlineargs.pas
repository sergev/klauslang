unit DlgCmdLineArgs;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  IniPropStorage;

type
  tCmdLineArgsDlg = class(TForm)
    propStorage: TIniPropStorage;
    pbCancel: TButton;
    pbSave: TButton;
    cbArgs: TComboBox;
    lblCaption: TLabel;
    procedure formClose(sender: tObject; var closeAction: tCloseAction);
  private
    fFileName: string;

    function  getArgs: string;
    procedure setArgs(val: string);
  public
    property fileName: string read fFileName;
    property args: string read getArgs write setArgs;

    constructor create(aOwner: tComponent; aFileName: string); overload;
  end;

implementation

{$R *.lfm}

uses LazFileUtils, FormMain;

resourcestring
  strCaption = 'Аргументы для %s';

{ tCmdLineArgsDlg }

procedure tCmdLineArgsDlg.formClose(sender: TObject; var closeAction: tCloseAction);
var
  s: string;
  idx: integer;
begin
  if modalResult = mrOK then begin
    s := cbArgs.text;
    if s <> '' then with cbArgs.items do begin
      idx := indexOf(s);
      if idx >= 0 then delete(idx);
      insert(0, s);
      while count > maxCmdLineArgHistoryItems do delete(count-1);
      cbArgs.text := s;
    end;
  end else
    propStorage.active := false;
end;

function tCmdLineArgsDlg.getArgs: string;
begin
  result := cbArgs.text;
end;

procedure tCmdLineArgsDlg.setArgs(val: string);
begin
  cbArgs.text := val;
end;

constructor tCmdLineArgsDlg.create(aOwner: tComponent; aFileName: string);
begin
  create(aOwner);
  fFileName := aFileName;
  lblCaption.caption := format(strCaption, [extractFileName(fFileName)]);
  propStorage.iniFileName := mainForm.configFileName;
  propStorage.iniSection := fileName;
end;


end.

