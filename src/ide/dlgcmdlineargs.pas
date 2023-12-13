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

unit DlgCmdLineArgs;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  IniPropStorage, Buttons;

type
  tCmdLineArgsDlg = class(TForm)
    cbStdIn: TComboBox;
    cbStdOut: TComboBox;
    chAppendStdOut: TCheckBox;
    lblCaption1: TLabel;
    lblCaption2: TLabel;
    stdOutDialog: TSaveDialog;
    stdInDialog: TOpenDialog;
    propStorage: TIniPropStorage;
    pbCancel: TButton;
    pbSave: TButton;
    cbArgs: TComboBox;
    lblCaption: TLabel;
    sbStdInBrowse: TSpeedButton;
    sbStdOutBrowse: TSpeedButton;
    procedure formClose(sender: tObject; var closeAction: tCloseAction);
    procedure sbStdInBrowseClick(Sender: TObject);
    procedure sbStdOutBrowseClick(Sender: TObject);
  private
    fFileName: string;

    function  getAppendStdOut: boolean;
    function  getArgs: string;
    function  getStdIn: string;
    function  getStdOut: string;
    procedure setAppendStdOut(val: boolean);
    procedure setArgs(val: string);
    procedure setStdIn(val: string);
    procedure setStdOut(val: string);
    procedure updateCombo(cb: tComboBox);
  public
    property fileName: string read fFileName;
    property args: string read getArgs write setArgs;
    property stdIn: string read getStdIn write setStdIn;
    property stdOut: string read getStdOut write setStdOut;
    property appendStdOut: boolean read getAppendStdOut write setAppendStdOut;

    constructor create(aOwner: tComponent; aFileName: string); overload;
  end;

implementation

{$R *.lfm}

uses LazFileUtils, FormMain;

resourcestring
  strCaption = 'Аргументы для %s';

{ tCmdLineArgsDlg }

constructor tCmdLineArgsDlg.create(aOwner: tComponent; aFileName: string);
begin
  create(aOwner);
  fFileName := aFileName;
  caption := format(strCaption, [extractFileName(fFileName)]);
  propStorage.iniFileName := mainForm.configFileName;
  propStorage.iniSection := fileName;
end;

procedure tCmdLineArgsDlg.updateCombo(cb: tComboBox);
var
  s: string;
  idx: integer;
begin
  s := cb.text;
  if s <> '' then with cb.items do begin
    idx := indexOf(s);
    if idx >= 0 then delete(idx);
    insert(0, s);
    while count > maxCmdLineArgHistoryItems do delete(count-1);
    cb.text := s;
  end;
end;

procedure tCmdLineArgsDlg.formClose(sender: tObject; var closeAction: tCloseAction);
begin
  if modalResult = mrOK then begin
    updateCombo(cbArgs);
    updateCombo(cbStdIn);
    updateCombo(cbStdOut);
  end else
    propStorage.active := false;
end;

procedure tCmdLineArgsDlg.sbStdInBrowseClick(Sender: TObject);
begin
  if stdInDialog.execute then cbStdIn.text := stdInDialog.fileName;
end;

procedure tCmdLineArgsDlg.sbStdOutBrowseClick(Sender: TObject);
begin
  if stdOutDialog.execute then cbStdOut.text := stdOutDialog.fileName;
end;

function tCmdLineArgsDlg.getArgs: string;
begin
  result := cbArgs.text;
end;

function tCmdLineArgsDlg.getAppendStdOut: boolean;
begin
  result := chAppendStdOut.checked;
end;

function tCmdLineArgsDlg.getStdIn: string;
begin
  result := cbStdIn.text;
end;

function tCmdLineArgsDlg.getStdOut: string;
begin
  result := cbStdOut.text;
end;

procedure tCmdLineArgsDlg.setAppendStdOut(val: boolean);
begin
  chAppendStdOut.checked := val;
end;

procedure tCmdLineArgsDlg.setArgs(val: string);
begin
  cbArgs.text := val;
end;

procedure tCmdLineArgsDlg.setStdIn(val: string);
begin
  cbStdIn.text := val;
end;

procedure tCmdLineArgsDlg.setStdOut(val: string);
begin
  cbStdOut.text := val;
end;

end.

