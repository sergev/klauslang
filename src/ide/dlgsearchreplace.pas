{
Этот файл — часть KlausLang.

KlausLang — свободное программное обеспечение: вы можете перераспространять 
его и/или изменять его на условиях Стандартной общественной лицензии GNU 
в том виде, в каком она была опубликована Фондом свободного программного 
обеспечения; либо версии 3 лицензии, либо (по вашему выбору) любой более 
поздней версии.

Программное обеспечение KlausLang распространяется в надежде, что оно будет 
полезным, но БЕЗО ВСЯКИХ ГАРАНТИЙ; даже без неявной гарантии ТОВАРНОГО ВИДА 
или ПРИГОДНОСТИ ДЛЯ ОПРЕДЕЛЕННЫХ ЦЕЛЕЙ. 

Подробнее см. в Стандартной общественной лицензии GNU.
Вы должны были получить копию Стандартной общественной лицензии GNU вместе 
с этим программным обеспечением. Кроме того, с текстом лицензии  можно
ознакомиться здесь: <https://www.gnu.org/licenses/>.
}

unit DlgSearchReplace;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  IniPropStorage, FormMain, FrameEdit;

type

  { TSearchReplaceDlg }

  TSearchReplaceDlg = class(TForm)
    chReplace: TCheckBox;
    chMatchCase: TCheckBox;
    cbSearch: TComboBox;
    cbReplace: TComboBox;
    Label1: TLabel;
    pbCancel: TButton;
    pbOK: TButton;
    pbAll: TButton;
    propStorage: TIniPropStorage;
    procedure cbReplaceChange(Sender: TObject);
    procedure cbSearchChange(Sender: TObject);
    procedure chReplaceChange(Sender: TObject);
    procedure formClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure propStorageRestoreProperties(Sender: TObject);
  private
    function getSearchInfo: tSearchInfo;
  public
    property info: tSearchInfo read getSearchInfo;

    constructor create(aOwner: tComponent); override;
    constructor create(aOwner: tComponent; aReplace: boolean);
    procedure enableDisable;
  end;

implementation

{$R *.lfm}

resourcestring
  strSearch = 'Найти';
  strReplace = 'Заменить';

{ TSearchReplaceDlg }

constructor TSearchReplaceDlg.create(aOwner: tComponent);
begin
  inherited;
end;

constructor TSearchReplaceDlg.create(aOwner: tComponent; aReplace: boolean);
begin
  create(aOwner);
  chReplace.checked := aReplace;
  propStorage.iniFileName := mainForm.configFileName;
end;

procedure TSearchReplaceDlg.enableDisable;
begin
  pbOK.enabled := cbSearch.text <> '';
  pbAll.visible := chReplace.checked;
  if chReplace.checked then pbOK.caption := strReplace
  else pbOK.caption := strSearch;
end;

procedure TSearchReplaceDlg.chReplaceChange(Sender: TObject);
begin
  if not chReplace.checked then cbReplace.text := '';
  enableDisable;
end;

procedure TSearchReplaceDlg.formClose(Sender: TObject; var CloseAction: TCloseAction);
var
  s: string;
  idx: integer;
begin
  if modalResult <> mrCancel then begin
    s := cbSearch.text;
    if s <> '' then with cbSearch.items do begin
      idx := indexOf(s);
      if idx >= 0 then delete(idx);
      insert(0, s);
      while count > maxSearchHistoryItems do delete(count-1);
      cbSearch.text := s;
    end;
    s := cbReplace.text;
    if s <> '' then with cbReplace.items do begin
      idx := indexOf(s);
      if idx >= 0 then delete(idx);
      insert(0, s);
      while count > maxReplaceHistoryItems do delete(count-1);
      cbReplace.text := s;
    end;
  end else
    propStorage.active := false;
end;

procedure TSearchReplaceDlg.FormShow(Sender: TObject);
begin
  enableDisable;
end;

procedure TSearchReplaceDlg.propStorageRestoreProperties(Sender: TObject);
begin
  if not chReplace.checked then cbReplace.text := '';
end;

function TSearchReplaceDlg.getSearchInfo: tSearchInfo;
begin
  result.replace := chReplace.checked;
  result.searchText := cbSearch.text;
  result.replaceText := cbReplace.text;
  result.matchCase := chMatchCase.checked;
end;

procedure TSearchReplaceDlg.cbReplaceChange(Sender: TObject);
begin
  if cbReplace.text <> '' then begin
    chReplace.checked := true;
    enableDisable;
  end;
end;

procedure TSearchReplaceDlg.cbSearchChange(Sender: TObject);
begin
  enableDisable;
end;

end.

