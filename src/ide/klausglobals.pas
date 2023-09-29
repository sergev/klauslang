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

implementation

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
  storage.doWriteString(section, 'autoIndent', boolToStr(autoIndent));
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

end.

