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

unit FormSplash;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type
  tSplashForm = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    lblRepository: TLabel;
    lblCompanyName: TLabel;
    lblComments: TLabel;
    lblLegalCopyright: TLabel;
    lblVersion: TLabel;
    shpFrame: TShape;
    tmrClose: TTimer;
    procedure anythingClick(sender: tObject);
    procedure formCreate(sender: tObject);
    procedure formKeyDown(sender: tObject; var key: word; shift: tShiftState);
    procedure shpFrameMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tmrCloseTimer(sender: tObject);
  private
    function  detectURL(const s: string): string;
    function  getCloseOnTimer: boolean;
    procedure setCloseOnTimer(value: boolean);
    procedure urlLabelClick(sender: tObject);
  public
    property closeOnTimer: boolean read getCloseOnTimer write setCloseOnTimer;
  end;

var
  SplashForm: tSplashForm;

implementation

uses FileInfo, LCLType, LCLIntf, U8;

{$R *.lfm}

resourcestring
  strVersion = 'Версия %s';
  strDeveloper = 'Разработчик %s';

{ tSplashForm }

procedure tSplashForm.formCreate(sender: tObject);
var
  i: integer;
  lbl: tLabel;
  ver: tFileVersionInfo;
begin
  ver := tFileVersionInfo.create(application);
  try
    ver.enabled := true;
    with ver.versionStrings do begin
      lblVersion.caption := format(strVersion, [values['FileVersion']]);
      lblCompanyName.caption := format(strDeveloper, [values['CompanyName']]);
      lblComments.caption := values['Comments'];
      lblLegalCopyright.caption := values['LegalCopyright'];
      lblRepository.caption := values['LegalTrademarks'];
    end;
  finally
    freeAndNil(ver);
  end;
  for i := 0 to componentCount-1 do begin
    if not (components[i] is tLabel) then continue;
    lbl := components[i] as tLabel;
    if detectURL(lbl.caption) <> '' then begin
      lbl.cursor := crHandPoint;
      lbl.onClick := @urlLabelClick;
    end;
  end;
end;

procedure tSplashForm.formKeyDown(sender: tObject; var key: word; shift: tShiftState);
begin
  if (key = VK_ESCAPE) or (key = VK_RETURN) then close;
end;

procedure tSplashForm.shpFrameMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  anythingClick(shpFrame);
end;

procedure tSplashForm.tmrCloseTimer(sender: tObject);
begin
  close;
end;

function tSplashForm.detectURL(const s: string): string;
var
  tmp: string;
  i, idx: integer;
begin
  result := '';
  tmp := u8Lower(s);
  idx := pos('http://', tmp);
  if idx <= 0 then idx := pos('https://', tmp);
  if idx <= 0 then exit;
  for i := idx to length(s) do begin
    if s[i] in [#9, #32] then exit;
    result += s[i];
  end;
end;

function tSplashForm.getCloseOnTimer: boolean;
begin
  result := tmrClose.enabled;
end;

procedure tSplashForm.setCloseOnTimer(value: boolean);
begin
  tmrClose.enabled := value;
end;

procedure tSplashForm.urlLabelClick(sender: tObject);
var
  url: string;
begin
  url := detectURL((sender as tLabel).caption);
  if url <> '' then begin
    openURL(url);
    close;
  end;
end;

procedure tSplashForm.anythingClick(sender: tObject);
begin
  close;
end;

end.

