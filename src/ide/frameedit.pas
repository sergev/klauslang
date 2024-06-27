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

unit FrameEdit;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Types, Classes, Messages, SysUtils, Graphics, Forms, Controls, StdCtrls, ExtCtrls, Buttons,
  ComCtrls, KlausGlobals, KlausEdit, KlausSrc, KlausLex, KlausSyn, KlausErr;

type
  tKlausEditErrorInfo = record
    msg: string;
    line, pos: integer;
  end;

type
  tSearchInfo = record
    searchText: string;
    replaceText: string;
    replace: boolean;
    matchCase: boolean;
  end;

type
  tToggleBreakpointMode = (tbmSet, tbmDelete, tbmToggle);

type
  tEditFrame = class(tFrame)
    Image1: TImage;
    lblErrorInfo: TLabel;
    pnErrorInfoCloseBtn: TPanel;
    pnErrorInfo: TPanel;
    pnErrorInfoCloseBtn1: TPanel;
    sbClose: TSpeedButton;

    procedure errorInfoClick(Sender: TObject);
    procedure sbCloseClick(Sender: TObject);
  private
    fEdit: tKlausEdit;
    fFileName: string;
    fModified: boolean;
    fErrorInfo: tKlausEditErrorInfo;
    fErrorLine: integer;
    fRunOptions: tKlausRunOptions;

    function  getCaption: string;
    procedure editChange(sender: tObject);
    procedure editMoveCaret(sender: tObject; newPos: tPoint);
    procedure editGetLineStyle(sender: tObject; line: integer; var style: tKlausEditStyleIndex);
    procedure editGetLineImages(sender: tObject; line: integer; out imgIdx: tIntegerDynArray);
    procedure editSetLineFlags(sender: tObject; line: integer; old, new: tKlausEditLineFlags);
    procedure editLineDelete(sender: tObject; line: integer);
    procedure editChangeFocus(sender: tObject; focus: boolean);
    procedure editMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure setErrorLine(line: integer);
    procedure removeErrorLine;
  protected
    procedure enableDisable(var msg: tMessage); message APPM_UpdateControlState;
  public
    property edit: tKlausEdit read fEdit;
    property fileName: string read fFileName;
    property modified: boolean read fModified;
    property caption: string read getCaption;
    property runOptions: tKlausRunOptions read fRunOptions write fRunOptions;

    constructor create(aOwner: tComponent); override;
    destructor  destroy; override;
    procedure loadFromFile(const fn: string);
    procedure saveToFile(const fn: string);
    procedure invalidateControlState;
    procedure showErrorInfo(msg: string; line, pos: integer; focus: boolean = true);
    function  createSource: tKlausSource;
    procedure toggleBookmark(n: integer);
    procedure gotoBookmark(n: integer);
    procedure toggleBreakpoint(line: integer = -1; mode: tToggleBreakpointMode = tbmToggle);
    procedure searchReplace(info: tSearchInfo);
    procedure replaceAll(info: tSearchInfo);
    procedure deleteLine;
    procedure indentBlock;
    procedure unindentBlock;
  end;

implementation

{$R *.lfm}

uses
  LazFileUtils, GraphUtils, Dialogs, formMain;

resourcestring
  strNewFile = '(новый)';
  strNotFound = 'Текст не найден.';

{ tEditFrame }

constructor tEditFrame.create(aOwner: tComponent);
var
  opt: tKlausEditOptions = [keoWantReturns, keoWantTabs, keoLineNumbers];
begin
  inherited create(aOwner);
  mainForm.addControlStateClient(self);
  fModified := false;
  fErrorLine := -1;
  fRunOptions := tKlausRunOptions.create;
  fEdit := tKlausEdit.create(self);
  fEdit.parent := self;
  fEdit.align := alClient;
  fEdit.margins.rect := rect(4, 4, 4, 4);
  fEdit.gutterWidth := 75;
  fEdit.gutterBevel := kgbRaised;
  fEdit.gutterTextColor := lighterOrDarker(clBtnText, 0.3);
  if mainForm.editStyles.autoIndent then include(opt, keoAutoIndent);
  fEdit.options := opt;
  fEdit.styles := mainForm.editStyles;
  fEdit.font.assign(mainForm.editStyles.font);
  fEdit.tabSize := mainForm.editStyles.tabSize;
  fEdit.lineImages := mainForm.editLineImages;
  fEdit.onChange := @editChange;
  fEdit.onMoveCaret := @editMoveCaret;
  fEdit.onGetLineStyle := @editGetLineStyle;
  fEdit.onGetLineImages := @editGetLineImages;
  fEdit.onSetLineFlags := @editSetLineFlags;
  fEdit.onLineDelete := @editLineDelete;
  fEdit.onMouseDown := @editMouseDown;
  fEdit.onChangeFocus := @editChangeFocus;
end;

destructor tEditFrame.destroy;
begin
  mainForm.invalidateBreakpointList;
  mainForm.removeControlStateClient(self);
  freeAndNil(fRunOptions);
  inherited destroy;
end;

procedure tEditFrame.sbCloseClick(Sender: TObject);
begin
  fErrorInfo.msg := '';
  removeErrorLine;
  invalidateControlState;
end;

procedure tEditFrame.errorInfoClick(Sender: TObject);
begin
  if fErrorInfo.msg <> '' then begin
    fEdit.selStart := point(fErrorInfo.pos, fErrorInfo.line-1);
    fEdit.makeCharVisible(fEdit.selStart);
    setErrorLine(fErrorInfo.line-1);
    if fEdit.canFocus then fEdit.setFocus;
  end;
end;

function tEditFrame.getCaption: string;
var
  s: string;
begin
  if fFileName = '' then
    result := strNewFile
  else begin
    result := extractFileName(fFileName);
    s := extractFileExt(result);
    result := copy(result, 1, length(result)-length(s));
  end;
end;

procedure tEditFrame.editChange(sender: tObject);
begin
  fModified := true;
  removeErrorLine;
  invalidateControlState;
end;

procedure tEditFrame.editMoveCaret(sender: tObject; newPos: tPoint);
begin
  removeErrorLine;
  invalidateControlState;
end;

procedure tEditFrame.editGetLineStyle(sender: tObject; line: integer; var style: tKlausEditStyleIndex);
begin
  style := esiNone;
  with fEdit.lines as tKlausEditStrings do
    if elfBreakpoint in flags[line] then style := esiBreakpoint;
  with mainForm.execPoint do
    if visible and (srcToEdit(point).y = line)
    and (fileName = self.fileName) then style := esiExecPoint;
  if line = fErrorLine then style := esiErrorLine;
end;

procedure tEditFrame.editGetLineImages(sender: tObject; line: integer; out imgIdx: tIntegerDynArray);
var
  i: integer;
begin
  imgIdx := [-1, -1, -1];
  with fEdit.lines as tKlausEditStrings do begin
    for i := 0 to 9 do
      if tKlausEditLineFlag(i) in flags[line] then begin
        imgIdx[0] := i;
        break;
      end;
    if elfBreakpoint in flags[line] then imgIdx[1] := 10;
  end;
  with mainForm.execPoint do
    if visible and (srcToEdit(point).y = line)
    and (fileName = self.fileName) then imgIdx[2] := 11;
end;

procedure tEditFrame.editSetLineFlags(sender: tObject; line: integer; old, new: tKlausEditLineFlags);
begin
  if elfBreakpoint in (old >< new) then mainForm.invalidateBreakPointList;
end;

procedure tEditFrame.editLineDelete(sender: tObject; line: integer);
begin
  with fEdit.lines as tKlausEditStrings do
    if elfBreakpoint in flags[line] then mainForm.invalidateBreakPointList;
end;

procedure tEditFrame.editChangeFocus(sender: tObject; focus: boolean);
begin
  invalidateControlState;
end;

procedure tEditFrame.editMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
var
  r: tRect;
  l: integer;
begin
  r := edit.areaRect[keaGutter];
  r.top += edit.margins.top;
  shift := shift * [ssShift, ssAlt, ssCtrl];
  if (button = mbLeft) and (shift = []) and ptInRect(r, point(x, y)) then begin
    l := edit.topLine + (y-r.top) div edit.lineHeight;
    toggleBreakpoint(l);
  end;
end;

procedure tEditFrame.setErrorLine(line: integer);
begin
  if fErrorLine <> line then begin
    if fErrorLine >= 0 then edit.invalidateText(fErrorLine, fErrorLine);
    fErrorLine := line;
    if fErrorLine >= 0 then edit.invalidateText(fErrorLine, fErrorLine);
  end;
end;

procedure tEditFrame.removeErrorLine;
begin
  setErrorLine(-1);
end;

procedure tEditFrame.enableDisable(var msg: tMessage);
begin
  pnErrorInfo.visible := fErrorInfo.msg <> '';
  fEdit.readOnly := mainForm.scene <> nil;
  fEdit.invalidate;
end;

procedure tEditFrame.loadFromFile(const fn: string);
begin
  fFileName := fn;
  try
    fEdit.lines.loadFromFile(fn);
    fModified := false;
  finally
    invalidateControlState;
  end;
end;

procedure tEditFrame.saveToFile(const fn: string);
begin
  fFileName := fn;
  try
    fEdit.lines.saveToFile(fn);
    fModified := false;
  finally
    invalidateControlState;
  end;
end;

procedure tEditFrame.invalidateControlState;
begin
  mainForm.invalidateControlState;
end;

procedure tEditFrame.showErrorInfo(msg: string; line, pos: integer; focus: boolean = true);
begin
  fErrorInfo.msg := msg;
  fErrorInfo.line := line;
  fErrorInfo.pos := pos;
  lblErrorInfo.caption := msg;
  if msg <> '' then begin
    fEdit.selStart := point(pos, line-1);
    fEdit.makeCharVisible(fEdit.selStart);
    if focus and fEdit.canFocus then fEdit.setFocus;
    setErrorLine(line-1);
  end else
    setErrorLine(-1);
  invalidateControlState;
end;

function tEditFrame.createSource: tKlausSource;
var
  p: tKlausLexParser;
begin
  result := nil;
  showErrorInfo('', 0, 0);
  try
    p := tKlausLexParser.create(tStringReadStream.create(edit.text));
    p.fileName := fileName;
    try result := tKlausSource.create(p);
    finally freeAndNil(p); end;
  except
    on e: eKlausError do mainForm.showErrorInfo(e.message, e.point);
    else raise;
  end;
end;

procedure tEditFrame.toggleBookmark(n: integer);
var
  l: integer;
  f: tKlausEditLineFlag;
begin
  if (n < 0) or (n > 9) then exit;
  f := tKlausEditLineFlag(n);
  l := fEdit.caretPos.y;
  with fEdit.lines as tKlausEditStrings do begin
    if l >= count then exit;
    if f in flags[l] then flags[l] := flags[l]-[f]
    else flags[l] := flags[l]+[f];
  end;
end;

procedure tEditFrame.gotoBookmark(n: integer);
var
  i: integer;
  f: tKlausEditLineFlag;
begin
  if (n < 0) or (n > 9) then exit;
  f := tKlausEditLineFlag(n);
  with fEdit.lines as tKlausEditStrings do
    for i := 0 to count-1 do
      if f in flags[i] then begin
        fEdit.selStart := point(1, i);
        fEdit.makeCharVisible(fEdit.selStart);
        break;
      end;
end;

procedure tEditFrame.toggleBreakpoint(line: integer; mode: tToggleBreakpointMode);
begin
  if line < 0 then line := fEdit.caretPos.y;
  with fEdit.lines as tKlausEditStrings do begin
    if line >= count then exit;
    case mode of
      tbmSet: flags[line] := flags[line]+[elfBreakpoint];
      tbmDelete: flags[line] := flags[line]-[elfBreakpoint];
      else begin
        if elfBreakpoint in flags[line] then flags[line] := flags[line]-[elfBreakpoint]
        else flags[line] := flags[line]+[elfBreakpoint];
      end;
    end;
  end;
end;

procedure tEditFrame.searchReplace(info: tSearchInfo);
var
  rslt: boolean;
  p1, p2: tPoint;
begin
  rslt := fEdit.search(fEdit.caretPos, info.searchText, info.matchCase, p1, p2);
  if rslt then begin
    if info.replace then begin
      fEdit.replaceText(p1, p2, info.replaceText);
      p2 := fEdit.caretPos;
    end;
    fEdit.selectText(p2, p1);
    fEdit.makeCharVisible(fEdit.caretPos);
  end else
    messageDlg(application.title, strNotFound, mtInformation, [mbOk], 0);
end;

procedure tEditFrame.replaceAll(info: tSearchInfo);
var
  rslt: boolean;
  p1, p2: tPoint;
begin
  rslt := fEdit.search(fEdit.caretPos, info.searchText, info.matchCase, p1, p2);
  if not rslt then begin
    messageDlg(application.title, strNotFound, mtInformation, [mbOk], 0);
    exit;
  end;
  fEdit.beginEdit(kegOther);
  try
    while rslt do begin
      fEdit.replaceText(p1, p2, info.replaceText);
      rslt := fEdit.search(fEdit.caretPos, info.searchText, info.matchCase, p1, p2);
    end;
  finally
    fEdit.endEdit;
  end;
end;

procedure tEditFrame.deleteLine;
var
  p: tPoint;
begin
  p := fEdit.caretPos;
  if p.y >= fEdit.lines.count then exit;
  fEdit.beginEdit(kegDeleting);
  try
    fEdit.deleteText(point(1, p.y), point(1, p.y+1));
  finally
    fEdit.endEdit;
  end;
end;

procedure tEditFrame.indentBlock;
var
  spc: integer;
  p1, p2: tPoint;
begin
  fEdit.beginEdit;
  try
    p1 := fEdit.selStart;
    p2 := fEdit.selEnd;
    spc := fEdit.tabSize;
    fEdit.indentText(p1, p2, spc);
    fEdit.selStart := point(p1.x, p1.y);
    fEdit.selEnd := point(p2.x, p2.y);
  finally
    fEdit.endEdit;
  end;
end;

procedure tEditFrame.unindentBlock;
var
  spc: integer;
  p1, p2: tPoint;
begin
  fEdit.beginEdit;
  try
    p1 := fEdit.selStart;
    p2 := fEdit.selEnd;
    spc := -fEdit.tabSize;
    fEdit.indentText(p1, p2, spc);
    fEdit.selStart := point(p1.x, p1.y);
    fEdit.selEnd := point(p2.x, p2.y);
  finally
    fEdit.endEdit;
  end;
end;

end.

