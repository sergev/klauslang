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

unit KlausConsole;

{$mode ObjFPC}{$H+}
{$i ../klaus.inc}

interface

uses
  Messages, LMessages, SysUtils, Classes, Graphics, Controls, Dialogs, Types, LCLType,
  Forms, CustomTimer, U8, GraphUtils, KlausConKeys;

const
  KM_InvalidateSize = $7FFA;
  KM_SetRedrawTimer = $7FFB;
  KM_UpdateCaretPos = $7FFC;

const
  klsConDefaultScreenWidth  = 80;
  klsConDefaultScreenHeight = 25;
  klsConDefaultFontColor    = cl16Silver;
  klsConDefaultBackColor    = cl16Black;
  klsConMinScreenWidth      = 16;
  klsConMinScreenHeight     = 5;
  klsConMaxScreenWidth      = 160;
  klsConMaxScreenHeight     = 50;
  klsConDefaultTabWidth     = 8;
  klsConMaxInputLength      = 2048;
  klsConMaxInputBuffer      = 16384;

const
  ctlCharBell      = #$07;
  ctlCharBackspace = #$08;
  ctlCharTab       = #$09;
  ctlCharLineFeed  = #$0A;
  ctlCharFormFeed  = #$0C;
  ctlCharReturn    = #$0D;
  ctlCharDataEsc   = #$10;
  ctlCharEscape    = #$1B;

const
  controlChars: set of char = [
    ctlCharBell, ctlCharBackspace, ctlCharTab, ctlCharLineFeed,
    ctlCharFormFeed, ctlCharReturn, ctlCharDataEsc, ctlCharEscape];

const
  cfsBold      = %00000001;
  cfsItalic    = %00000010;
  cfsUnderline = %00000100;
  cfsStrikeOut = %00001000;

type
  tKlsConCellAttr = packed record
    fc: byte;
    bc: byte;
    fs: byte;
    dummy: byte;
  end;

type
  tKlsConBufCell = packed record
    c: longWord;
    case integer of
      0: (attr: longWord);
      1: (fc: byte; bc: byte; fs: byte; dummy: byte);
  end;
  tKlsConBufRow = array of tKlsConBufCell;
  tKlsConBuf = array of tKlsConBufRow;

type
  tKlsConCaretType = (
    kctHorzLine,
    kctVertLine,
    kctBlock);

type
  tKlausConsoleInputEvent = procedure(sender: tObject; var input: string; aborted: boolean) of object;
  tKlausConBufFeedEvent = procedure(sender: tObject; lines: integer) of object;

type
  tCustomKlausConsole = class;
  tKlausConsole = class;

type
  tScreenBuffer = class
    private
      fBuf: tKlsConBuf;
      fSize: tSize;
      fOnFeed: tKlausConBufFeedEvent;

      function  getCell(x, y: integer): tKlsConBufCell;
    public
      property width: integer read fSize.cx;
      property height: integer read fSize.cy;
      property cell[x, y: integer]: tKlsConBufCell read getCell;
      property onFeed: tKlausConBufFeedEvent read fOnFeed write fOnFeed;

      constructor create(aOwner: tCustomKlausConsole; w, h: integer);
      destructor  destroy; override;
      procedure setSize(val: tSize; const attr: longWord);
      procedure setSize(w, h: integer; const attr: LongWord);
      procedure clear(const attr: longWord);
      procedure clearLine(y: integer; const attr: longWord);
      procedure clearLine(y: integer; x1, x2: integer; const attr: longWord);
      procedure feed(lines: integer; const attr: longWord);
      function  put(p: tPoint; const s: string; const attr: longWord): tPoint;
      function  put(x, y: integer; const s: string; const attr: longWord): tPoint;
      function  get(p: tPoint; buf: pChar; out len: integer; out attr: longWord): integer;
      function  get(x, y: integer; buf: pChar; out len: integer; out attr: longWord): integer;
  end;

type
  tCustomKlausConsole = class(tCustomControl)
    private class var
      fDefaultWidth: integer;
      fDefaultHeight: integer;
      fDefaultFontColor: byte;
      fDefaultBackColor: byte;
    public
      class property defaultWidth: integer read fDefaultWidth write fDefaultWidth;
      class property defaultHeight: integer read fDefaultHeight write fDefaultHeight;
      class property defaultFontColor: byte read fDefaultFontColor write fDefaultFontColor;
      class property defaultBackColor: byte read fDefaultBackColor write fDefaultBackColor;
    private
      fLatch: tRTLCriticalSection;
      fBuffer: tScreenBuffer;
      fCharSize: tSize;
      fCaretType: tKlsConCaretType;
      fCaretPos: tPoint;
      fSaveCaret: tPoint;
      fCaretOrigin: tPoint;
      fCaretEnabled: boolean;
      fCaretVisible: boolean;
      fCaretInvalid: boolean;
      fTextAttr: tKlsConCellAttr;
      fTabWidth: integer;
      fEscSequence: string;
      fRawMode: boolean;
      fInputMode: boolean;
      fInputBuffer: string;
      fInputBufPos: sizeInt;
      fInputValue: string;
      fInputStart: tPoint;
      fRedrawTimer: tCustomTimer;
      fRedrawPosted: boolean;
      fAllInvalid: boolean;
      fRectInvalid: tRect;
      fPreviewShortcuts: boolean;
      fOnInput: tKlausConsoleInputEvent;

      function  getBackColor: byte;
      function  getCaretEnabled: boolean;
      function  getCaretPos: tPoint;
      function  getCaretType: tKlsConCaretType;
      function  getFontStyle: byte;
      function  getInputMode: boolean;
      function  getOnInput: tKlausConsoleInputEvent;
      function  getPreviewShortCuts: boolean;
      function  getRawMode: boolean;
      function  getTabWidth: integer;
      function  getTextColor: byte;
      procedure setBackColor(val: byte);
      procedure setCaretEnabled(val: boolean);
      procedure setCaretPos(val: tPoint);
      procedure setCaretType(val: tKlsConCaretType);
      procedure setFontStyle(val: byte);
      procedure setOnInput(val: tKlausConsoleInputEvent);
      procedure setPreviewShortCuts(val: boolean);
      procedure setRawMode(val: boolean);
      procedure setTabWidth(val: integer);
      procedure setTextColor(val: byte);
      procedure createCaret;
      procedure destroyCaret;
      procedure hideCaret;
      procedure showCaret;
      procedure invalidateCaretPos;
      procedure doUpdateCaretPos;
      function  processCtlChar(var p: pChar; out s: string; out cnt: integer; out ctl: char): boolean;
      procedure processEscSequence(var p: pChar);
      procedure applyEscSequence(const s: string);
      procedure displayInputValue;
      procedure bufferFeed(sender: tObject; lines: integer);
      procedure setRedrawTimer;
      procedure killRedrawTimer;
    protected
      procedure WMEraseBkgnd(var msg: tMessage); message WM_EraseBkgnd;
      procedure CMFontChanged(var msg: tMessage); message CM_FontChanged;
      procedure WMSetFocus(var msg: tMessage); message WM_SetFocus;
      procedure WMKillFocus(var msg: tMessage); message WM_KillFocus;
      procedure KMInvalidateSize(var msg: tMessage); message KM_InvalidateSize;
      procedure KMSetRedrawTimer(var msg: tMessage); message KM_SetRedrawTimer;
      procedure KMUpdateCaretPos(var msg: tMessage); message KM_UpdateCaretPos;
      procedure CNKeyDown(var msg: tLMKeyDown); message CN_KeyDown;
      procedure CNSysKeyDown(var msg: tLMKeyDown); message CN_SysKeyDown;
      procedure redrawTimerTimer(sender: tObject);
      procedure createWnd; override;
      procedure destroyWnd; override;
      procedure updateTextMetrics;
      procedure paint; override;
      procedure paintLine(r: tRect; line: integer);
      procedure calculatePreferredSize(var preferredWidth, preferredHeight: integer; withThemeSpace: boolean); override;
      procedure feed(lines: integer = 1);
      procedure keyDown(var key: word; shift: tShiftState); override;
      procedure utf8KeyPress(var key: tUTF8Char); override;
      procedure appendInputBuffer(const s: string);
    public
      property caretType: tKlsConCaretType read getCaretType write setCaretType;
      property caretEnabled: boolean read getCaretEnabled write setCaretEnabled;
      property caretPos: tPoint read getCaretPos write setCaretPos;
      property textColor: byte read getTextColor write setTextColor;
      property backColor: byte read getBackColor write setBackColor;
      property fontStyle: byte read getFontStyle write setFontStyle;
      property tabWidth: integer read getTabWidth write setTabWidth;
      property inputMode: boolean read getInputMode;
      property rawMode: boolean read getRawMode write setRawMode;
      property onInput: tKlausConsoleInputEvent read getOnInput write setOnInput;
      property previewShortCuts: boolean read getPreviewShortCuts write setPreviewShortCuts;

      constructor create(aOwner: tComponent); override;
      destructor  destroy; override;
      procedure beforeDestruction; override;
      procedure lock;
      procedure unlock;
      procedure clear;
      procedure reset;
      procedure invalidateAll;
      procedure invalidateLines(y1, y2: integer);
      procedure clearLine(y, x1, x2: integer);
      procedure write(p: pChar);
      procedure write(const s: string);
      procedure setWindowSize(w, h: integer);
      procedure beginInput;
      procedure endInput(abort: boolean = false);
      function  hasChar: boolean;
      procedure readChar(out c: u8Char);
  end;

type
  tKlausConsole = class(tCustomKlausConsole)
    published
      property align;
      property anchors;
      property backColor;
      property borderStyle;
      property caretType;
      property caretEnabled;
      property color;
      property constraints;
      property cursor;
      property dragCursor;
      property dragKind;
      property dragMode;
      property enabled;
      property font;
      property fontStyle;
      property parentColor;
      property parentFont;
      property parentShowHint;
      property popupMenu;
      property previewShortCuts;
      property showHint;
      property tabOrder;
      property tabStop;
      property tabWidth;
      property textColor;
      property visible;
    published
      property onClick;
      property onContextPopup;
      property onDblClick;
      property onDragDrop;
      property onDragOver;
      property onEndDock;
      property onEndDrag;
      property onEnter;
      property onExit;
      property onInput;
      property onKeyDown;
      property onKeyPress;
      property onKeyUp;
      property onMouseDown;
      property onMouseMove;
      property onMouseUp;
      property onStartDock;
      property onStartDrag;
  end;

type
  eKlausConsoleError = class(exception);

implementation

uses
  LCLIntf, Math, Clipbrd, KlausUtils;

resourcestring
  errInvalidRowIndex = 'Номер строки вне допустимых пределов: %d.';
  errInvalidColIndex = 'Номер символа вне допустимых пределов: %d.';
  errInvalidScreenSize = 'Недопустимый размер экранного буфера: %d x %d.';

function getAttrFontColor(attr: tKlsConCellAttr): tColor;
begin
  result := colors256[attr.fc];
end;

function getAttrBackColor(attr: tKlsConCellAttr): tColor;
begin
  result := colors256[attr.bc];
end;

function getAttrFontStyle(attr: tKlsConCellAttr): tFontStyles;
begin
  result := [];
  if attr.fs and cfsBold <> 0 then include(result, fsBold);
  if attr.fs and cfsItalic <> 0 then include(result, fsItalic);
  if attr.fs and cfsUnderline <> 0 then include(result, fsUnderline);
  if attr.fs and cfsStrikeOut <> 0 then include(result, fsStrikeOut);
end;

{ tScreenBuffer }

constructor tScreenBuffer.create(aOwner: tCustomKlausConsole; w, h: integer);
var
  attr: tKlsConCellAttr;
begin
  inherited create;
  with attr do begin
    bc := tCustomKlausConsole.defaultBackColor;
    fc := tCustomKlausConsole.defaultFontColor;
    fs := 0;
    dummy := 0;
  end;
  setSize(size(w, h), longWord(attr));
end;

destructor tScreenBuffer.destroy;
begin
  inherited destroy;
end;

procedure tScreenBuffer.setSize(val: tSize; const attr: longWord);
begin
  if fSize <> val then begin
    if (val.cx < klsConMinScreenWidth) or (val.cy < klsConMinScreenHeight)
    or (val.cx > klsConMaxScreenWidth) or (val.cy > klsConMaxScreenHeight) then
      raise eKlausConsoleError.createFmt(errInvalidScreenSize, [val.cx, val.cy]);
    fSize := val;
    setLength(fBuf, fSize.cy, fSize.cx);
    clear(attr);
  end;
end;

procedure tScreenBuffer.setSize(w, h: integer; const attr: LongWord);
begin
  setSize(size(w, h), attr);
end;

procedure tScreenBuffer.clear(const attr: longWord);
var
  i: integer;
begin
  for i := 0 to fSize.cy-1 do clearLine(i, attr);
end;

procedure tScreenBuffer.clearLine(y: integer; const attr: longWord);
begin
  clearLine(y, 0, fSize.cx-1, attr);
end;

procedure tScreenBuffer.clearLine(y: integer; x1, x2: integer; const attr: longWord);
var
  c: tKlsConBufCell;
begin
  if (y < 0) or (y >= fSize.cy) then raise eKlausConsoleError.createFmt(errInvalidRowIndex, [y]);
  if (x1 < 0) or (x1 >= fSize.cx) then raise eKlausConsoleError.createFmt(errInvalidRowIndex, [y]);
  if (x2 < 0) or (x2 >= fSize.cx) then raise eKlausConsoleError.createFmt(errInvalidRowIndex, [y]);
  if x1 <= x2 then begin
    c.c := byte(' ');
    c.attr := attr;
    fillQWord(fBuf[y][x1], x2-x1+1, qWord(c));
  end;
end;

procedure tScreenBuffer.feed(lines: integer; const attr: longWord);
var
  i: integer;
begin
  if lines <= 0 then exit;
  if lines < fSize.cy then begin
    for i := 0 to lines-1 do finalize(fBuf[i]);
    system.move(fBuf[lines], fBuf[0], sizeOf(fBuf[0])*(fSize.cy-lines));
    fillChar(fBuf[fSize.cy-lines], sizeOf(fBuf[0])*lines, 0);
    for i := fSize.cy-lines to fSize.cy-1 do begin
      setLength(fBuf[i], fSize.cx);
      clearLine(i, attr);
    end;
  end else
    clear(attr);
  if assigned(fOnFeed) then fOnFeed(self, lines);
end;

function tScreenBuffer.put(p: tPoint; const s: string; const attr: longWord): tPoint;
begin
  result := put(p.x, p.y, s, attr);
end;

function tScreenBuffer.put(x, y: integer; const s: string; const attr: longWord): tPoint;
var
  p: pChar;
begin
  if (x < 0) or (x >= fSize.cx) then raise eKlausConsoleError.createFmt(errInvalidColIndex, [x]);
  if (y < 0) or (y >= fSize.cy) then raise eKlausConsoleError.createFmt(errInvalidRowIndex, [y]);
  if s = '' then exit(point(x, y));
  p := pChar(s);
  while (p^ <> #0) do begin
    fBuf[y][x].c := u8GetCharBytes(p);
    fBuf[y][x].attr := attr;
    inc(x);
    if x >= fSize.cx then begin
      x := 0;
      inc(y);
    end;
    if y >= fSize.cy then begin
      feed(y-fSize.cy+1, attr);
      y := fSize.cy-1;
    end;
  end;
  result := point(x, y);
end;

function tScreenBuffer.get(p: tPoint; buf: pChar; out len: integer; out attr: longWord): integer;
begin
  result := get(p.x, p.y, buf, len, attr);
end;

function tScreenBuffer.get(x, y: integer; buf: pChar; out len: integer; out attr: longWord): integer;
const
  repl: longWord = $BDBFEF;
var
  i, sz: integer;
begin
  result := 0;
  if (x < 0) or (x >= fSize.cx) then raise eKlausConsoleError.createFmt(errInvalidColIndex, [x]);
  if (y < 0) or (y >= fSize.cy) then raise eKlausConsoleError.createFmt(errInvalidRowIndex, [y]);
  len := 0;
  attr := fBuf[y][x].attr;
  for i := x to fSize.cx-1 do begin
    if fBuf[y][i].attr <> attr then break;
    sz := u8Size(pChar(@fBuf[y][i].c));
    if sz = 0 then begin
      move(repl, buf[len], 3);
      sz := 3;
    end else
      move(fBuf[y][i].c, buf[len], sz);
    len += sz;
    inc(result);
  end;
  buf[len] := #0;
end;

function tScreenBuffer.getCell(x, y: integer): tKlsConBufCell;
begin
  result := fBuf[y][x];
end;

{ tCustomKlausConsole }

constructor tCustomKlausConsole.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  initCriticalSection(fLatch);
  fBuffer := tScreenBuffer.create(self, defaultWidth, defaultHeight);
  fBuffer.onFeed := @bufferFeed;
  fCaretOrigin := point(0, 0);
  fCaretPos := point(0, 0);
  fSaveCaret := point(0, 0);
  fCaretEnabled := true;
  fCaretVisible := false;
  fTextAttr.bc := defaultBackColor;
  fTextAttr.fc := defaultFontColor;
  fTextAttr.fs := 0;
  fTabWidth := klsConDefaultTabWidth;
  fInputValue := '';
  fRedrawTimer := tCustomTimer.create(nil);
  fRedrawTimer.interval := 1;
  fRedrawTimer.enabled := false;
  fRedrawTimer.onTimer := @redrawTimerTimer;
  fRedrawPosted := false;
  fAllInvalid := false;
  fRectInvalid := rect(0, 0, 0, 0);
end;

destructor tCustomKlausConsole.destroy;
begin
  freeAndNil(fBuffer);
  doneCriticalSection(fLatch);
  inherited destroy;
end;

procedure tCustomKlausConsole.beforeDestruction;
begin
  endInput(true);
  inherited beforeDestruction;
end;

procedure tCustomKlausConsole.lock;
begin
  enterCriticalSection(fLatch);
end;

procedure tCustomKlausConsole.unlock;
begin
  leaveCriticalSection(fLatch);
end;

procedure tCustomKlausConsole.clear;
begin
  lock;
  try
    endInput(true);
    fBuffer.clear(longWord(fTextAttr));
    fCaretPos := point(0, 0);
    invalidateCaretPos;
    invalidateAll;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.reset;
begin
  lock;
  try
    endInput(true);
    fTextAttr.bc := defaultBackColor;
    fTextAttr.fc := defaultFontColor;
    fTextAttr.fs := 0;
    fBuffer.clear(longWord(fTextAttr));
    fCaretPos := point(0, 0);
    fSaveCaret := point(0, 0);
    fCaretEnabled := true;
    invalidateCaretPos;
    invalidateAll;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.invalidateAll;
begin
  lock;
  try
    if not handleAllocated then exit;
    fAllInvalid := true;
    setRedrawTimer;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.invalidateLines(y1, y2: integer);
var
  r: tRect;
begin
  lock;
  try
    if not handleAllocated then exit;
    r := clientRect;
    r.top := r.top + y1*fCharSize.cy;
    r.bottom := r.bottom + (y2+1)*fCharSize.cy;
    if isRectEmpty(fRectInvalid) then
      fRectInvalid := r
    else with fRectInvalid do begin
      if r.top < top then top := r.top;
      if r.bottom > bottom then bottom := r.bottom;
    end;
    setRedrawTimer;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.setRedrawTimer;
begin
  lock;
  try
    if not handleAllocated then exit;
    if not fRedrawTimer.enabled then begin
      {$if defined(windows) or defined(darwin)}
      if not fRedrawPosted then begin
        fRedrawPosted := true;
        postMessage(handle, KM_SetRedrawTimer, 0, 0);
      end;
      {$else}
      sendMessage(handle, KM_SetRedrawTimer, 0, 0);
      {$endif}
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.killRedrawTimer;
begin
  lock;
  try fRedrawTimer.enabled := false;
  finally unlock; end;
end;

procedure tCustomKlausConsole.redrawTimerTimer(sender: tObject);
begin
  lock;
  try
    killRedrawTimer;
    if fAllInvalid then invalidate
    else if not IsRectEmpty(fRectInvalid) then invalidateRect(handle, @fRectInvalid, false)
    else doUpdateCaretPos;
    fAllInvalid := false;
    fRectInvalid := rect(0, 0, 0, 0);
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.clearLine(y, x1, x2: integer);
begin
  lock;
  try
    fBuffer.clearLine(y, x1, x2, longWord(fTextAttr));
    invalidateLines(y, y);
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.displayInputValue;
var
  old, new: tPoint;
begin
  lock;
  try
    if fInputMode then begin
      old := fCaretPos;
      fCaretPos := fInputStart;
      if fInputValue <> '' then write(fInputValue)
      else invalidateCaretPos;
      while fCaretPos.y < old.y do begin
        dec(old.y);
        inc(old.x, fBuffer.width);
      end;
      new := fCaretPos;
      if (fCaretPos.y = old.y) and (fCaretPos.x < old.x) then
        new := fBuffer.put(fCaretPos, stringOfChar(' ', old.x-fCaretPos.x), longWord(fTextAttr));
      invalidateLines(old.y, new.y);
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.bufferFeed(sender: tObject; lines: integer);
begin
  lock;
  try
    fCaretPos.y := max(0, fCaretPos.y-lines);
    if fInputMode then fInputStart.y -= lines;
    if fInputStart.y < 0 then endInput(true);
    invalidateAll;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.write(const s: string);
begin
  lock;
  try
    if s = '' then exit;
    write(pChar(s));
  finally
    unlock;
  end;
end;

function  tCustomKlausConsole.processCtlChar(var p: pChar; out s: string; out cnt: integer; out ctl: char): boolean;
var
  c: u8Char;
  esc: boolean = false;
begin
  lock;
  try
    s := '';
    cnt := 0;
    ctl := #0;
    if p = nil then exit(false)
    else if p^ = #0 then exit(false);
    while p^ <> #0 do begin
      c := u8GetChar(p);
      if not esc and (c[1] < #$20) then begin
        if c[1] = ctlCharDataEsc then begin
          esc := true;
          continue;
        end;
        ctl := c[1];
        break;
      end else begin
        s += c;
        inc(cnt);
        esc := false;
      end;
    end;
    result := true;
  finally
    unlock;
  end;
end;

function isCSI(const s: string): boolean; inline;
begin
  if length(s) < 2 then exit(false);
  result := (s[1] = #27) and (s[2] = '[');
end;

procedure tCustomKlausConsole.processEscSequence(var p: pChar);
const
  stop = [#0..#32, 'A'..'Z', 'a'..'z', '`', '~', '@'];
var
  finished: boolean = false;
begin
  lock;
  try
    if p^ = #0 then exit;
    if isCSI(fEscSequence) then begin
      while not (p^ in stop) do begin
        fEscSequence += p^;
        inc(p);
      end;
      if p^ in [#0..#32] then exit;
      fEscSequence += p^;
      finished := true;
      inc(p);
    end else if (fEscSequence = #27) and (p^ = '[') then begin
      fEscSequence += p^;
      inc(p);
      processEscSequence(p);
    end else begin
      fEscSequence += p^;
      finished := true;
      inc(p);
    end;
    if finished then begin
      applyEscSequence(fEscSequence);
      fEscSequence := '';
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.write(p: pChar);
var
  old: tPoint;
  substr: string;
  cnt, x: integer;
  ctl: char;
begin
  lock;
  try
    if fEscSequence <> '' then processEscSequence(p);
    if p^ = #0 then exit;
    old := fCaretPos;
    while processCtlChar(p, substr, cnt, ctl) do begin
      fCaretPos := fBuffer.put(fCaretPos, substr, longWord(fTextAttr));
      case ctl of
        ctlCharBell: beep;
        ctlCharBackspace: if fCaretPos.x > 0 then dec(fCaretPos.x);
        ctlCharTab: begin
          x := (fCaretPos.x div fTabWidth)*fTabWidth + fTabWidth;
          write(stringOfChar(#32, x-fCaretPos.x));
        end;
        ctlCharLineFeed: begin
          fCaretPos.x := 0;
          inc(fCaretPos.y);
          if fCaretPos.y >= fBuffer.height then feed;
        end;
        ctlCharFormFeed: begin
          feed(fBuffer.height);
          fCaretPos := point(0, 0);
        end;
        ctlCharReturn: fCaretPos.x := 0;
        ctlCharEscape: begin
          fEscSequence := #27;
          processEscSequence(p);
        end;
      end;
    end;
    invalidateLines(old.y, fCaretPos.y);
    invalidateCaretPos;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.applyEscSequence(const s: string);

  function getCode(const seq: string): char; inline;
  begin
    result := seq[length(seq)];
  end;

  function getParams(const s: string): tStringArray;
  var
    tmp: string;
  begin
    tmp := copy(s, 3, length(s)-3);
    result := tmp.split([';']);
  end;

var
  c: char;
  x, y: word;
  caret: tPoint;
  prm: tStringArray;
begin
  lock;
  try
    try
      if s = #27'c' then
        reset // очистить и установить параметры по умолчанию
      else if s = #27'[2J' then
        clear // очистить
      else if s = #27'[?25l' then
        caretEnabled := false // скрыть курсор
      else if s = #27'[?25h' then
        caretEnabled := true // показать курсор
      else if isCSI(s) then begin
        c := getCode(s);
        case c of
          't': begin // установить размер окна
            prm := getParams(s);
            if length(prm) <> 3 then abort;
            if prm[0] <> '8' then abort;
            setWindowSize(strToInt(prm[2]), strToInt(prm[1]));
            fSaveCaret := point(0, 0);
          end;
          'K': begin // очистить строку
            prm := getParams(s);
            if length(prm) <> 1 then abort;
            caret := caretPos;
            case strToInt(prm[0]) of
              0: clearLine(caret.y, caret.x, fBuffer.width-1);
              1: clearLine(caret.y, 0, caret.x);
              2: clearLine(caret.y, 0, fBuffer.width-1);
            end;
          end;
          's': begin // запомнить позицию курсора
            fSaveCaret := caretPos;
          end;
          'u': begin // восстановить позицию курсора
            caretPos := fSaveCaret;
          end;
          'f': begin // установить курсор X, Y
            prm := getParams(s);
            if length(prm) <> 2 then abort;
            x := max(0, min(fBuffer.width-1, strToInt(prm[1])-1));
            y := max(0, min(fBuffer.height-1, strToInt(prm[0])-1));
            caretPos := point(x, y);
          end;
          'A', 'B', 'C', 'D': begin // подвинуть курсор
            prm := getParams(s);
            if length(prm) <> 1 then abort;
            x := caretPos.x;
            y := caretPos.y;
            case c of
              'C': x := max(0, min(fBuffer.width-1, x + strToInt(prm[0])));
              'D': x := max(0, min(fBuffer.width-1, x - strToInt(prm[0])));
              'A': y := max(0, min(fBuffer.height-1, y - strToInt(prm[0])));
              'B': y := max(0, min(fBuffer.height-1, y + strToInt(prm[0])));
            end;
            caretPos := point(x, y);
          end;
          'd': begin // установить курсор Y
            prm := getParams(s);
            if length(prm) <> 1 then abort;
            x := caretPos.x;
            y := max(0, min(fBuffer.height-1, strToInt(prm[0])-1));
            caretPos := point(x, y);
          end;
          '`': begin // установить курсор X
            prm := getParams(s);
            if length(prm) <> 1 then abort;
            x := max(0, min(fBuffer.width-1, strToInt(prm[0])-1));
            y := caretPos.y;
            caretPos := point(x, y);
          end;
          'm': begin // установить/сбросить атрибуты
            prm := getParams(s);
            if length(prm) < 1 then abort;
            case strToInt(prm[0]) of
              0: begin  // сбросить всё
                if length(prm) <> 1 then abort;
                fTextAttr.bc := defaultBackColor;
                fTextAttr.fc := defaultFontColor;
                fTextAttr.fs := 0;
              end;
              48: begin // цвет фона
                if length(prm) <> 3 then abort;
                if prm[1] <> '5' then abort;
                fTextAttr.bc := strToInt(prm[2]);
              end;
              38: begin // цвет текста
                if length(prm) <> 3 then abort;
                if prm[1] <> '5' then abort;
                fTextAttr.fc := strToInt(prm[2]);
              end;
              1: begin  // жирный
                if length(prm) <> 1 then abort;
                fTextAttr.fs := fTextAttr.fs or cfsBold;
              end;
              22: begin // не жирный
                if length(prm) <> 1 then abort;
                fTextAttr.fs := fTextAttr.fs and not cfsBold;
              end;
              3: begin  // курсив
                if length(prm) <> 1 then abort;
                fTextAttr.fs := fTextAttr.fs or cfsItalic;
              end;
              23: begin // не курсив
                if length(prm) <> 1 then abort;
                fTextAttr.fs := fTextAttr.fs and not cfsItalic;
              end;
              4: begin  // подчёркнутый
                if length(prm) <> 1 then abort;
                fTextAttr.fs := fTextAttr.fs or cfsUnderline;
              end;
              24: begin // не подчёркнутый
                if length(prm) <> 1 then abort;
                fTextAttr.fs := fTextAttr.fs and not cfsUnderline;
              end;
              9: begin  // зачёркнутый
                if length(prm) <> 1 then abort;
                fTextAttr.fs := fTextAttr.fs or cfsStrikeOut;
              end;
              29: begin // не зачёркнутый
                if length(prm) <> 1 then abort;
                fTextAttr.fs := fTextAttr.fs and not cfsStrikeOut;
              end;
            end;
          end;
        end;
      end;
    except
      // помолчим о неудачах...
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.setWindowSize(w, h: integer);
begin
  lock;
  try
    endInput(true);
    fBuffer.setSize(w, h, longWord(fTextAttr));
    invalidatePreferredSize;
    if handleAllocated then postMessage(handle, KM_InvalidateSize, 0, 0);
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.setCaretType(val: tKlsConCaretType);
begin
  lock;
  try
    if fCaretType <> val then begin
      fCaretType := val;
      invalidateCaretPos;
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.setCaretEnabled(val: boolean);
begin
  lock;
  try
    if fCaretEnabled <> val then begin
      fCaretEnabled := val;
      invalidateCaretPos;
    end;
  finally
    unlock;
  end;
end;

function tCustomKlausConsole.getBackColor: byte;
begin
  lock;
  try result := fTextAttr.bc;
  finally unlock; end;
end;

function tCustomKlausConsole.getCaretEnabled: boolean;
begin
  lock;
  try result := fCaretEnabled;
  finally unlock; end;
end;

function tCustomKlausConsole.getCaretPos: tPoint;
begin
  lock;
  try result := fCaretPos;
  finally unlock; end;
end;

function tCustomKlausConsole.getCaretType: tKlsConCaretType;
begin
  lock;
  try result := fCaretType;
  finally unlock; end;
end;

function tCustomKlausConsole.getFontStyle: byte;
begin
  lock;
  try result := fTextAttr.fs;
  finally unlock; end;
end;

function tCustomKlausConsole.getInputMode: boolean;
begin
  lock;
  try result := fInputMode;
  finally unlock; end;
end;

function tCustomKlausConsole.getOnInput: tKlausConsoleInputEvent;
begin
  lock;
  try result := fOnInput;
  finally unlock; end;
end;

function tCustomKlausConsole.getPreviewShortCuts: boolean;
begin
  lock;
  try result := fPreviewShortCuts;
  finally unlock; end;
end;

function tCustomKlausConsole.getRawMode: boolean;
begin
  lock;
  try result := fRawMode;
  finally unlock; end;
end;

function tCustomKlausConsole.getTabWidth: integer;
begin
  lock;
  try result := fTabWidth;
  finally unlock; end;
end;

function tCustomKlausConsole.getTextColor: byte;
begin
  lock;
  try result := fTextAttr.fc;
  finally unlock; end;
end;

procedure tCustomKlausConsole.setBackColor(val: byte);
begin
  lock;
  try fTextAttr.bc := val;
  finally unlock; end;
end;

procedure tCustomKlausConsole.setCaretPos(val: tPoint);
begin
  lock;
  try
    if (val.x < 0) or (val.x >= fBuffer.width) then raise eKlausConsoleError.createFmt(errInvalidColIndex, [val.x]);
    if (val.y < 0) or (val.y >= fBuffer.height) then raise eKlausConsoleError.createFmt(errInvalidRowIndex, [val.y]);
    if fCaretPos <> val then begin
      fCaretPos := val;
      invalidateCaretPos;
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.WMEraseBkgnd(var msg: tMessage);
begin
  msg.result := 1;
end;

procedure tCustomKlausConsole.CMFontChanged(var msg: tMessage);
begin
  lock;
  try updateTextMetrics;
  finally unlock; end;
end;

procedure tCustomKlausConsole.WMSetFocus(var msg: tMessage);
begin
  lock;
  try
    inherited;
    createCaret;
    invalidateCaretPos;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.WMKillFocus(var msg: tMessage);
begin
  lock;
  try
    destroyCaret;
    inherited;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.KMInvalidateSize(var msg: tMessage);
begin
  adjustSize;
end;

procedure tCustomKlausConsole.CNKeyDown(var msg: tLMKeyDown);
begin
  if not previewShortcuts then inherited
  else if application.isShortcut(msg) then msg.result := 1
  else inherited;
end;

procedure tCustomKlausConsole.CNSysKeyDown(var msg: tLMKeyDown);
begin
  if not previewShortcuts then inherited
  else if application.isShortcut(msg) then msg.result := 1
  else inherited;
end;

procedure tCustomKlausConsole.createWnd;
begin
  lock;
  try
    inherited;
    updateTextMetrics;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.destroyWnd;
begin
  lock;
  try
    killRedrawTimer;
    destroyCaret;
    inherited;
    updateTextMetrics;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.updateTextMetrics;
var
  h: integer;
begin
  lock;
  try
    if not handleAllocated then begin
      h := abs(self.font.height);
      fCharSize := size(h, h);
    end else begin
      canvas.font := self.font;
      fCharSize := canvas.textExtent('0');
      if focused then createCaret;
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.paint;
var
  line: integer;
  clip, cr, lr: tRect;
begin
  lock;
  try
    hideCaret;
    canvas.font := self.font;
    clip := canvas.clipRect;
    cr := clientRect;
    lr := cr;
    for line := 0 to fBuffer.height-1 do begin
      lr.bottom := min(cr.bottom, lr.top+fCharSize.cy);
      if lr.intersectsWith(clip) then paintLine(lr, line);
      lr.top := lr.bottom;
      if lr.top >= cr.bottom then break;
    end;
    if lr.bottom < cr.bottom then begin
      lr := rect(lr.left, lr.bottom, lr.right, cr.bottom);
      with canvas.brush do begin color := self.color; style := bsSolid; end;
      canvas.fillRect(lr);
    end;
    doUpdateCaretPos;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.paintLine(r: tRect; line: integer);

  procedure setTextAttrs(attr: tKlsConCellAttr);
  begin
    canvas.font := self.font;
    canvas.font.color := getAttrFontColor(attr);
    canvas.font.style := getAttrFontStyle(attr);
    canvas.brush.color := getAttrBackColor(attr);
    canvas.brush.style := bsSolid;
  end;

const
  Flg = ETO_CLIPPED or ETO_OPAQUE;
var
  pr: tRect;
  s: string = '';
  chr, cnt, len: integer;
  attr: tKlsConCellAttr;
  extent: tSize = (cx: 0; cy: 0);
begin
  lock;
  try
    pr := r;
    chr := 0;
    setLength(s, fBuffer.width*4);
    repeat
      cnt := fBuffer.get(chr, line, pChar(s), len, longWord(attr));
      setTextAttrs(attr);
      getTextExtentPoint(canvas.handle, pChar(s), len, extent);
      pr.right := pr.left + extent.cx;
      extTextOut(canvas.handle, pr.left, pr.top, flg, @pr, pChar(s), len, nil);
      pr.left := pr.right;
      chr += cnt;
    until chr >= fBuffer.width;
    if pr.right < r.right then begin
      with canvas.brush do begin color := self.color; style := bsSolid; end;
      canvas.fillRect(pr.right, pr.top, r.right, pr.bottom);
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.calculatePreferredSize(var preferredWidth, preferredHeight: integer; withThemeSpace: boolean);
begin
  lock;
  try
    if not handleAllocated then exit;
    preferredWidth := fCharSize.cx*fBuffer.width + 2;
    preferredHeight := fCharSize.cy*fBuffer.height + 2;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.feed(lines: integer);
begin
  lock;
  try fBuffer.feed(lines, longWord(fTextAttr));
  finally unlock; end;
end;

procedure tCustomKlausConsole.keyDown(var key: word; shift: tShiftState);
var
  p: pChar;
  s: string;
  idx: integer;
begin
  lock;
  try
    if fRawMode then begin
      if klausConIsCharKey(key, shift) then begin
        inherited;
        exit;
      end;
      s := fInputValue + klausConKeyToSequence(key, shift);
      if length(s) <= klsConMaxInputLength then fInputValue := s;
      if fInputMode then
        endInput
      else begin
        appendInputBuffer(s);
        fInputValue := '';
      end;
      key := 0;
    end else begin
      inherited;
      if not inputMode then exit;
      shift := shift * [ssShift, ssAlt, ssCtrl];
      case key of
        0: exit;
        VK_V: if (shift = [ssCtrl]) and (clipboard.HasFormat(CF_TEXT)) then begin
          s := clipboard.asText;
          idx := pos(#10, s);
          if idx > 0 then s := copy(s, 1, idx-1);
          s := fInputValue + s;
          if length(s) > klsConMaxInputLength then begin
            p := u8SkipChars(u8SkipCharsLeft(s, klsConMaxInputLength+1, 1), 1);
            fInputValue := copy(s, 1, p-pChar(s));
          end else
            fInputValue := s;
          displayInputValue;
          key := 0;
        end;
        VK_BACK: if (Shift = []) and (length(fInputValue) > 0) then begin
          p := u8SkipCharsLeft(fInputValue, length(fInputValue)+1, 1);
          fInputValue := copy(fInputValue, 1, p-pChar(fInputValue));
          displayInputValue;
          key := 0;
        end;
        VK_TAB: if shift = [] then begin
          if length(fInputValue) < klsConMaxInputLength then fInputValue += #9;
          displayInputValue;
          key := 0;
        end;
      end;
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.utf8KeyPress(var key: tUTF8Char);
var
  s: string;
begin
  lock;
  try
    inherited;
    if fRawMode then begin
      s := fInputValue + key;
      if length(s) <= klsConMaxInputLength then fInputValue := s;
      if fInputMode then
        endInput
      else begin
        appendInputBuffer(s);
        fInputValue := '';
      end;
      key := #0;
    end else begin
      if not inputMode then exit;
      if (key <> #13) and (key < #32) then exit;
      if key = #13 then begin
        fInputValue += #10;
        endInput;
        write(#10);
      end else begin
        s := fInputValue + key;
        if length(s) <= klsConMaxInputLength then fInputValue := s;
        displayInputValue;
      end;
      key := #0;
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.appendInputBuffer(const s: string);
begin
  lock;
  try
    if length(fInputBuffer) >= klsConMaxInputBuffer then exit;
    fInputBuffer += s;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.KMSetRedrawTimer(var msg: tMessage);
begin
  lock;
  try
    hideCaret;
    fRedrawPosted := false;
    fRedrawTimer.enabled := true;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.KMUpdateCaretPos(var msg: tMessage);
begin
  lock;
  try
    if fCaretInvalid then doUpdateCaretPos;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.invalidateCaretPos;
begin
  lock;
  try
    if not handleAllocated then exit;
    if not fCaretInvalid then begin
      fCaretInvalid := true;
      {$if defined(windows) or defined(darwin)}
      postMessage(handle, KM_UpdateCaretPos, 0, 0);
      {$else}
      sendMessage(handle, KM_UpdateCaretPos, 0, 0);
      {$endif}
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.doUpdateCaretPos;
var
  old: tPoint;
begin
  lock;
  try
    fCaretInvalid := false;
    if not handleAllocated then exit;
    hideCaret;
    if focused then begin
      old := fCaretOrigin;
      fCaretOrigin := point(fCaretPos.x*fCharSize.cx, fCaretPos.y*fCharSize.cy);
      with fCaretOrigin do case fCaretType of
        kctHorzLine: y := y+fCharSize.cy-3;
        kctVertLine: y := y+1;
      end;
      if fCaretOrigin <> old then LCLIntf.setCaretPos(fCaretOrigin.x, fCaretOrigin.y);
      showCaret;
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.hideCaret;
begin
  lock;
  try
    if handleAllocated then
      if fCaretVisible then begin
        LCLIntf.hideCaret(handle);
        fCaretVisible := false;
      end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.showCaret;
begin
  lock;
  try
    if not handleAllocated then exit;
    if fCaretEnabled and not fRedrawTimer.enabled then
      if not fCaretVisible then begin
        LCLIntf.showCaret(handle);
        fCaretVisible := true;
      end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.createCaret;
var
  w, h: integer;
begin
  lock;
  try
    destroyCaret;
    if not (csDesigning in componentState) and handleAllocated then begin
      case fCaretType of
        kctHorzLine: begin w := fCharSize.cx; h := 3; end;
        kctVertLine: begin w := 2; h := fCharSize.cy; end;
        else w := fCharSize.cx; h := fCharSize.cy;
      end;
      fCaretVisible := true;
      LCLIntf.createCaret(handle, 0, w, h);
      LCLIntf.setCaretRespondToFocus(handle, false);
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.destroyCaret;
begin
  lock;
  try
    fCaretVisible := false;
    if handleAllocated then LCLIntf.destroyCaret(handle);
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.setFontStyle(val: byte);
begin
  lock;
  try fTextAttr.fs := val;
  finally unlock; end;
end;

procedure tCustomKlausConsole.setOnInput(val: tKlausConsoleInputEvent);
begin
  lock;
  try fOnInput := val;
  finally unlock; end;
end;

procedure tCustomKlausConsole.setPreviewShortCuts(val: boolean);
begin
  lock;
  try fPreviewShortcuts := val;
  finally unlock; end;
end;

procedure tCustomKlausConsole.setRawMode(val: boolean);
begin
  lock;
  try
    if fRawMode <> val then begin
      endInput(true);
      fRawMode := val;
      invalidateCaretPos;
      invalidateAll;
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.setTabWidth(val: integer);
begin
  lock;
  try
    fTabWidth := val;
    invalidateAll;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.setTextColor(val: byte);
begin
  lock;
  try fTextAttr.fc := val;
  finally unlock; end;
end;

procedure tCustomKlausConsole.beginInput;
begin
  lock;
  try
    if fRawMode and hasChar then exit;
    if not fInputMode then begin
      fInputMode := true;
      fInputValue := '';
      fInputStart := fCaretPos;
    end;
  finally
    unlock;
  end;
end;

procedure tCustomKlausConsole.endInput(abort: boolean);
begin
  lock;
  try
    if fInputMode then begin
      fInputMode := false;
      fInputStart := point(0, 0);
      if assigned(fOnInput) then fOnInput(self, fInputValue, abort);
      if not abort then appendInputBuffer(fInputValue);
      fInputValue := '';
    end;
  finally
    unlock;
  end;
end;

function tCustomKlausConsole.hasChar: boolean;
begin
  lock;
  try result := fInputBufPos < length(fInputBuffer);
  finally unlock; end;
end;

procedure tCustomKlausConsole.readChar(out c: u8Char);
begin
  lock;
  try
    if fInputBufPos >= length(fInputBuffer) then begin
      fInputBufPos := 0;
      fInputBuffer := '';
      c := u8Chr(#26);
      exit;
    end;
    c := u8Chr(pChar(fInputBuffer)+fInputBufPos);
    fInputBufPos += max(1, length(c));
    if fInputBufPos > 255 then begin
      fInputBuffer := copy(fInputBuffer, fInputBufPos+1);
      fInputBufPos := 0;
    end;
  finally
    unlock;
  end;
end;

initialization
  with tCustomKlausConsole do begin
    defaultWidth := klsConDefaultScreenWidth;
    defaultHeight := klsConDefaultScreenHeight;
    defaultFontColor := klsConDefaultFontColor;
    defaultBackColor := klsConDefaultBackColor;
  end;
end.

