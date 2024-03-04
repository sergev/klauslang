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

unit KlausGlobals;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, Graphics, GraphUtils, IniPropStorage, KlausEdit;

const
  APPM_UpdateControlState    = $9801;
  APPM_UpdateBreakpoints     = $9802;
  APPM_FocusEditor           = $9803;

type
  tKlausEditorOptions = class(tKlausEditStyleSheet)
    private
      fFont: tFont;
      fTabSize: integer;
      fAutoIndent: boolean;

      procedure setAutoIndent(val: boolean);
      procedure setFont(val: tFont);
      procedure setTabSize(val: integer);
      procedure fontChange(sender: tObject);
    protected
      procedure assignTo(dest: tPersistent); override;
      procedure setDefaults(theme: tUITheme); override;
      procedure updateChangeHandler(edit: tCustomKlausEdit); override;
    public
      property font: tFont read fFont write setFont;
      property tabSize: integer read fTabSize write setTabSize;
      property autoIndent: boolean read fAutoIndent write setAutoIndent;

      constructor create;
      destructor destroy; override;
      procedure doSaveToIni(storage: TIniPropStorage; const section: string); override;
      procedure doLoadFromIni(storage: TIniPropStorage; const section: string); override;
  end;

type
  tKlausConsoleOptions = class(tPersistent)
    private
      fFont: tFont;
      fWidth: integer;
      fHeight: integer;
      fFontColor: byte;
      fBackColor: byte;
      fAutoClose: boolean;
      fStayOnTop: boolean;

      procedure setFont(val: tFont);
    protected
      procedure assignTo(dest: tPersistent); override;
      procedure setDefaults;
    public
      property font: tFont read fFont write setFont;
      property width: integer read fWidth write fWidth;
      property height: integer read fHeight write fHeight;
      property fontColor: byte read fFontColor write fFontColor;
      property backColor: byte read fBackColor write fBackColor;
      property autoClose: boolean read fAutoClose write fAutoClose;
      property stayOnTop: boolean read fStayOnTop write fStayOnTop;

      constructor create;
      destructor destroy; override;
      procedure saveToIni(storage: tIniPropStorage);
      procedure loadFromIni(storage: tIniPropStorage);
      procedure updateConsoleDefaults;
  end;

type
  tKlausRunOptions = class(tPersistent)
    private
      fCmdLine: string;
      fStdIn: string;
      fStdOut: string;
      fAppendStdOut: boolean;
    protected
      procedure assignTo(dest: tPersistent); override;
    public
      property cmdLine: string read fCmdLine write fCmdLine;
      property stdIn: string read fStdIn write fStdIn;
      property stdOut: string read fStdOut write fStdOut;
      property appendStdOut: boolean read fAppendStdOut write fAppendStdOut;
  end;

implementation

uses
  klausConsole;

resourcestring
  klausConsoleOptionsIniSection = 'KlausConsoleOptions';

{ tKlausRunOptions }

procedure tKlausRunOptions.assignTo(dest: tPersistent);
begin
  if not (dest is tKlausRunOptions) then inherited
  else with dest as tKlausRunOptions do begin
    cmdLine := self.cmdLine;
    stdIn := self.stdIn;
    stdOut := self.stdOut;
    appendStdOut := self.appendStdOut;
  end;
end;

{ tKlausEditorOptions }

constructor tKlausEditorOptions.create;
begin
  fFont := tFont.create;
  inherited;
end;

destructor tKlausEditorOptions.destroy;
begin
  inherited destroy;
  freeAndNil(fFont);
end;

procedure tKlausEditorOptions.setAutoIndent(val: boolean);
begin
  if fAutoIndent <> val then begin
    beginUpdate;
    try fAutoIndent := val;
    finally endUpdate; end;
  end;
end;

procedure tKlausEditorOptions.setFont(val: tFont);
begin
  if fFont.isEqual(val) then exit;
  fFont.assign(val);
end;

procedure tKlausEditorOptions.setTabSize(val: integer);
begin
  if fTabSize <> val then begin
    beginUpdate;
    try fTabSize := val;
    finally endUpdate; end;
  end;
end;

procedure tKlausEditorOptions.fontChange(sender: tObject);
begin
  beginUpdate;
  endUpdate;
end;

procedure tKlausEditorOptions.assignTo(dest: tPersistent);
begin
  if not (dest is tKlausEditStyleSheet) then inherited
  else with dest as tKlausEditStyleSheet do begin
    beginUpdate;
    try
      inherited;
      if dest is tKlausEditorOptions then
        with dest as tKlausEditorOptions do begin
          font := self.font;
          tabSize := self.tabSize;
          autoIndent := self.autoIndent;
        end;
    finally
      endUpdate;
    end;
  end;
end;

procedure tKlausEditorOptions.setDefaults(theme: tUITheme);
begin
  inherited;
  {$if defined(windows)} fFont.name := 'Courier New';
  {$elseif defined(darwin)} fFont.name := 'Menlo';
  {$else} fFont.name := 'Monospace'; {$endif}
  fFont.size := 11;
  fTabSize := 4;
  fAutoIndent := true;
end;

procedure tKlausEditorOptions.updateChangeHandler(edit: tCustomKlausEdit);
var
  opt: tKlausEditOptions;
begin
  edit.font.assign(font);
  edit.tabSize := tabSize;
  opt := edit.options;
  if autoIndent then include(opt, keoAutoIndent) else exclude(opt, keoAutoIndent);
  edit.options := opt;
  inherited;
end;

procedure tKlausEditorOptions.doSaveToIni(storage: TIniPropStorage; const section: string);
begin
  inherited;
  storage.doWriteString(section, 'fontName', font.name);
  storage.doWriteString(section, 'fontSize', intToStr(font.size));
  storage.doWriteString(section, 'tabSize', intToStr(tabSize));
  storage.doWriteString(section, 'autoIndent', boolToStr(autoIndent, true));
end;

procedure tKlausEditorOptions.doLoadFromIni(storage: TIniPropStorage; const section: string);
var
  s: string;
begin
  inherited;
  s := storage.doReadString(section, 'fontName', 'default');
  if s <> 'default' then font.name := s;
  s := storage.doReadString(section, 'fontSize', 'default');
  if s <> 'default' then font.size := strToInt(s);
  s := storage.doReadString(section, 'tabSize', 'default');
  if s <> 'default' then tabSize := strToInt(s);
  s := storage.doReadString(section, 'autoIndent', 'default');
  if s <> 'default' then autoIndent := strToBool(s);
end;

{ tKlausConsoleOptions }

constructor tKlausConsoleOptions.create;
begin
  inherited;
  fFont := tFont.create;
  setDefaults;
end;

destructor tKlausConsoleOptions.destroy;
begin
  freeAndNil(fFont);
  inherited destroy;
end;

procedure tKlausConsoleOptions.setFont(val: tFont);
begin
  if fFont.isEqual(val) then exit;
  fFont.assign(val);
end;

procedure tKlausConsoleOptions.assignTo(dest: tPersistent);
begin
  if not (dest is tKlausConsoleOptions) then
    inherited assignTo(dest)
  else with dest as tKlausConsoleOptions do begin
    font := self.font;
    width := self.width;
    height := self.height;
    fontColor := self.fontColor;
    backColor := self.backColor;
    autoClose := self.autoClose;
    stayOnTop := self.stayOnTop;
  end;
end;

procedure tKlausConsoleOptions.setDefaults;
begin
  {$if defined(windows)} font.name := 'Courier New';
  {$elseif defined(darwin)} font.name := 'Menlo';
  {$else} font.name := 'Monospace'; {$endif}
  font.size := 11;
  width := klsConDefaultScreenWidth;
  height := klsConDefaultScreenHeight;
  fontColor := cl16Silver;
  backColor := cl16Black;
  autoClose := false;
  stayOnTop := true;
end;

procedure tKlausConsoleOptions.loadFromIni(storage: tIniPropStorage);
var
  section, s: string;
begin
  section := klausConsoleOptionsIniSection;
  s := storage.doReadString(section, 'fontName', 'default');
  if s <> 'default' then font.name := s;
  s := storage.doReadString(section, 'fontSize', 'default');
  if s <> 'default' then font.size := strToInt(s);
  s := storage.doReadString(section, 'windowWidth', 'default');
  if s <> 'default' then width := strToInt(s);
  s := storage.doReadString(section, 'windowHeight', 'default');
  if s <> 'default' then height := strToInt(s);
  s := storage.doReadString(section, 'autoClose', 'default');
  if s <> 'default' then autoClose := strToBool(s);
  s := storage.doReadString(section, 'stayOnTop', 'default');
  if s <> 'default' then stayOnTop := strToBool(s);
  s := storage.doReadString(section, 'fontColor', 'default');
  if s <> 'default' then fontColor := byte(strToInt(s));
  s := storage.doReadString(section, 'backColor', 'default');
  if s <> 'default' then backColor := byte(strToInt(s));
end;

procedure tKlausConsoleOptions.updateConsoleDefaults;
begin
  with tCustomKlausConsole do begin
    defaultWidth := self.width;
    defaultHeight := self.height;
    defaultFontColor := self.fontColor;
    defaultBackColor := self.backColor;
  end;
end;

procedure tKlausConsoleOptions.saveToIni(storage: tIniPropStorage);
var
  sect: string;
begin
  sect := klausConsoleOptionsIniSection;
  storage.doWriteString(sect, 'fontName', font.name);
  storage.doWriteString(sect, 'fontSize', intToStr(font.size));
  storage.doWriteString(sect, 'windowWidth', intToStr(width));
  storage.doWriteString(sect, 'windowHeight', intToStr(height));
  storage.doWriteString(sect, 'autoClose', boolToStr(autoClose, true));
  storage.doWriteString(sect, 'stayOnTop', boolToStr(stayOnTop, true));
  storage.doWriteString(sect, 'fontColor', intToStr(fontColor));
  storage.doWriteString(sect, 'backColor', intToStr(backColor));
end;

end.

