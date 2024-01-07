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

unit KlausEdit;

{$mode objfpc}{$H+}
{$i ../klaus.inc}

interface

uses
  Messages, SysUtils, Classes, Graphics, Menus, Controls, Forms, Dialogs,
  ExtCtrls, GraphUtils, Clipbrd, LMessages, Types, LCLType, U8,
  CustomTimer, KlausLex, IniPropStorage;

const
  klausEditWheelVScrollDistance = 3;
  klausEditWheelHScrollDistance = 2;
  klausEditMinUndoLimit         = 1024;
  klausEditDefaultTabSize       = 4;
  klausEditScrollSpeed          = 20;

const
  klausEditAlphanumerics = '_'+
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'+
    'abcdefghijklmnopqrstuvwxyz'+
    'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'+
    'абвгдеёжзийклмнопрстуфхцчшщъыьэюя'+
    '0123456789';

type
  tKlausEditArea  = (
    keaNone,
    keaGutter,
    keaLeftMargin,
    keaTopMargin,
    keaRightMargin,
    keaBottomMargin,
    keaText);

type
  tKlausEditOption  = (
    keoNoThumbTrack,
    keoHideSelection,
    keoWantReturns,
    keoWantTabs,
    keoAutoIndent,
    keoLineNumbers);
  tKlausEditOptions = set of tKlausEditOption;

type
  tKlausEditGutterBevel = (kgbNone, kgbSpacer, kgbLine, kgbLowered, kgbRaised);

type
  tMouseScrollDirection = (msdNone, msdLeft, msdRight, msdUp, msdDown);

type
  {$push}{$packenum 1}
  tKlausEditStyleIndex = (
    esiNone       = ord(klxEOF),
    esiInvalid    = ord(klxInvalid),
    esiKeyword    = ord(klxKeyword),
    esiID         = ord(klxID),
    esiChar       = ord(klxChar),
    esiString     = ord(klxString),
    esiInteger    = ord(klxInteger),
    esiFloat      = ord(klxFloat),
    esiMoment     = ord(klxMoment),
    esiSymbol     = ord(klxSymbol),
    esiSLComment  = ord(klxSLComment),
    esiMLComment  = ord(klxMLComment),
    esiExecPoint  = ord(high(tKlausLexem))+1,
    esiBreakpoint = ord(high(tKlausLexem))+2,
    esiErrorLine  = ord(high(tKlausLexem))+3);

  tKlausEditLineFlag = (
    elfBookmark0  =  0,
    elfBookmark1  =  1,
    elfBookmark2  =  2,
    elfBookmark3  =  3,
    elfBookmark4  =  4,
    elfBookmark5  =  5,
    elfBookmark6  =  6,
    elfBookmark7  =  7,
    elfBookmark8  =  8,
    elfBookmark9  =  9,
    elfBreakpoint = 10);
  {$pop}

type
  tKlausEditLineFlags = packed set of tKlausEditLineFlag;

const
  klausEditStyleCaption: array[tKlausEditStyleIndex] of string = (
    'Пробелы',                   // esiNone
    'Неверный символ',           // esiInvalid
    'Ключевое слово',            // esiKeyword
    'Идентификатор',             // esiID
    'Символьный литерал',        // esiChar
    'Строковый литерал',         // esiString
    'Целочисленный литерал',     // esiInteger
    'Вещественный литерал',      // esiFloat
    'Литерал момента',           // esiMoment
    'Знак языка',                // esiSymbol
    'Однострочный комментарий',  // esiSLComment
    'Многострочный комментарий', // esiMLComment
    'Выполняемая строка',        // esiExecPoint
    'Точка останова',            // esiBreakpoint
    'Строка с ошибкой'           // esiErrorLine
  );

const
  klausEditDefaultOptions = [keoHideSelection, keoWantTabs, keoWantReturns];

type
  tKlausEditPaintAreaEvent = procedure(sender: tObject; canvas: tCanvas; area: tKlausEditArea; const r: tRect; var handled: boolean) of object;
  tKlausEditMoveCaretEvent = procedure(sender: tObject; newPos: tPoint) of object;
  tKlausEditLineEvent      = procedure(sender: tObject; line: integer) of object;
  tKlausEditLineFlagsEvent = procedure(sender: tObject; line: integer; old, new: tKlausEditLineFlags) of object;
  tKlausEditLineStyleEvent = procedure(sender: tObject; line: integer; var style: tKlausEditStyleIndex) of object;
  tKlausEditLineImageEvent = procedure(sender: tObject; line: integer; out imgIdx: tIntegerDynArray) of object;
  tKlausEditFocusEvent     = procedure(sender: tObject; focus: boolean) of object;

type
  eKlausEditError = class;
  tKlausEditStyle = class;
  tKlausEditStyleSheet = class;
  tKlausEditMargins = class;
  tKlausEditStrings = class;
  tCustomKlausEdit = class;
  tKlausEdit = class;

type
  eKlausEditError = class(exception);

type
  tKlausEditCharFmt = packed array of tKlausEditStyleIndex;

type
  pStringData = ^tStringData;
  tStringData = record
    text: string;
    fmt: tKlausEditCharFmt;
    flags: tKlausEditLineFlags;
    hl: packed record
      valid: boolean;
      whole: boolean;
      plex: tKlausLexem;
      nlex: tKlausLexem;
      ppos: integer;
      npos: integer;
    end;
    charCount: integer;
    data: pointer;
  end;

type
  pKlausEditHitTestInfo = ^tKlausEditHitTestInfo;
  tKlausEditHitTestInfo = record
    x, y: integer;
    area: tKlausEditArea;
    position: tPoint;
  end;

type
  tKlausEditGoal = (kegOther, kegTyping, kegDeleting);
  tKlausUndoOperation = (kuoInsert, kuoDelete, kuoDataChange);
  tKlausCopyDataOperation = (kcoCopy, kcoSave, kcoRestore);

type
  pKlausEditUndoData = ^tKlausEditUndoData;
  tKlausEditUndoData = record
    operation: tKlausUndoOperation;
    start: tPoint;
    finish: tPoint;
    text: string;
    data: pointer;
    flags: tKlausEditLineFlags;
    dataIndex: integer;
    groupIndex: integer;
  end;

type
  tKlausEditStyle = class(tPersistent)
    private
      fOwner: tKlausEditStyleSheet;
      fChangeCount: integer;
      fIndex: tKlausEditStyleIndex;
      fName: string;
      fCaption: string;
      fFontColor: tColor;
      fBackColor: tColor;
      fFontStyle: tFontStyles;
      fDefaultFontStyle: boolean;
      fDefaultFontColor: boolean;
      fDefaultBackColor: boolean;

      function  getActualBackColor: tColor;
      function  getActualFontColor: tColor;
      function  getActualFontStyles: tFontStyles;
      procedure setFontColor(value: tColor);
      procedure setFontStyle(value: tFontStyles);
      procedure setDefaultFontColor(value: boolean);
      procedure setDefaultFontStyle(value: boolean);
      procedure setDefaultBackColor(value: boolean);
      procedure setBackColor(value: tColor);
    protected
      procedure doChange;
      procedure setDefaults(theme: tUITheme); virtual;
      procedure assignTo(dest: tPersistent); override;
    public
      property owner: tKlausEditStyleSheet read fOwner;
      property index: tKlausEditStyleIndex read fIndex;
      property name: string read fName;
      property caption: string read fCaption;
      property actualFontColor: tColor read getActualFontColor;
      property actualBackColor: tColor read getActualBackColor;
      property actualFontStyle: tFontStyles read getActualFontStyles;

      constructor create(aOwner: tKlausEditStyleSheet; idx: tKlausEditStyleIndex);
      procedure beginUpdate;
      procedure endUpdate;
      procedure saveToIni(const sect: string; storage: TIniPropStorage);
      procedure loadFromIni(const sect: string; storage: TIniPropStorage);
      procedure setTextAttrs(canvas: tCanvas);
    published
      property fontColor: tColor read fFontColor write setFontColor;
      property backColor: tColor read fBackColor write setBackColor;
      property fontStyle: tFontStyles read fFontStyle write setFontStyle;
      property defaultFontStyle: boolean read fDefaultFontStyle write setDefaultFontStyle;
      property defaultFontColor: boolean read fDefaultFontColor write setDefaultFontColor;
      property defaultBackColor: boolean read fDefaultBackColor write setDefaultBackColor;
  end;

type
  tKlausEditStyleSheet = class(tPersistent)
    private
      fChangeHandlers: tFPList;
      fStyles: array[tKlausEditStyleIndex] of tKlausEditStyle;
      fChangeCount: integer;
      fFontStyle: tFontStyles;
      fFontColor: tColor;
      fBackColor: tColor;
      fSelFontColor: tColor;
      fSelBackColor: tColor;
      fOnChange: tNotifyEvent;

      function  getStyle(idx: tKlausEditStyleIndex): tKlausEditStyle;
      procedure setBackColor(value: tColor);
      procedure setFontColor(value: tColor);
      procedure setFontStyle(value: tFontStyles);
      procedure setSelBackColor(value: tColor);
      procedure setSelFontColor(value: tColor);
    protected
      procedure doChange; virtual;
      procedure setDefaults(theme: tUITheme); virtual;
      procedure assignTo(dest: tPersistent); override;
      procedure doSaveToIni(storage: TIniPropStorage; const section: string); virtual;
      procedure doLoadFromIni(storage: TIniPropStorage; const section: string); virtual;
      procedure updateChangeHandler(edit: tCustomKlausEdit); virtual;
    public
      property style[idx: tKlausEditStyleIndex]: tKlausEditStyle read getStyle; default;

      constructor create;
      destructor  destroy; override;
      procedure beginUpdate;
      procedure endUpdate;
      procedure addChangeHandler(handler: tCustomKlausEdit);
      procedure removeChangeHandler(handler: tCustomKlausEdit);
      procedure saveToIni(storage: TIniPropStorage);
      procedure loadFromIni(storage: TIniPropStorage);
    published
      property fontStyle: tFontStyles read fFontStyle write setFontStyle;
      property fontColor: tColor read fFontColor write setFontColor;
      property backColor: tColor read fBackColor write setBackColor;
      property selFontColor: tColor read fSelFontColor write setSelFontColor;
      property selBackColor: tColor read fSelBackColor write setSelBackColor;
      property onChange: tNotifyEvent read fOnChange write fOnChange;
  end;

type
  tKlausEditStrings = class(tStrings)
    private
      fOwner: tCustomKlausEdit;
      fItems: array of tStringData;
      fCount: integer;
      fQuantum: integer;
      fCapacity: integer;
      fEditCount: integer;

      procedure incCount;
      procedure decCount;
      procedure beginEdit;
      procedure endEdit;
      procedure expandTabs(var s: string);
      procedure doPut(index: integer; const s: string);
      procedure doInsert(index: integer; const s: String);
      function  getData(index: integer): pointer;
      function  getCharCount(index: integer): integer;
      function  getFlags(index: integer): tKlausEditLineFlags;
      procedure setFlags(index: integer; value: tKlausEditLineFlags);
    protected
      function  getCount: integer; override;
      function  get(index: integer): string; override;
      procedure put(index: integer; const s: string); override;
      procedure setUpdateState(updating: boolean); override;
      procedure setTextStr(const value: string); override;
      procedure setFormatting(style: tKlausEditStyleIndex; line: integer; startPos, endPos: integer);
    public
      property owner: tCustomKlausEdit read fOwner;
      property charCount[index: integer]: integer read getCharCount;
      property flags[index: integer]: tKlausEditLineFlags read getFlags write setFlags;
      property data[index: integer]: pointer read getData;

      constructor create(aOwner: tCustomKlausEdit);
      destructor  destroy; override;
      procedure clear; override;
      procedure delete(index: integer); override;
      procedure insert(index: integer; const s: string); override;
  end;

type
  tKlausEditMargins = class(tPersistent)
    private
      fRect: tRect;
      fUpdateCount: integer;
      fOnChange: tNotifyEvent;

      function  getBottom: integer;
      function  getBottomRight: tPoint;
      function  getLeft: integer;
      function  getRight: integer;
      function  getTop: integer;
      function  getTopLeft: tPoint;
      procedure setBottom(const value: integer);
      procedure setBottomRight(const value: tPoint);
      procedure setLeft(const value: integer);
      procedure setRect(const value: tRect);
      procedure setRight(const value: integer);
      procedure setTop(const value: integer);
      procedure setTopLeft(const value: tPoint);
    protected
      procedure change; virtual;
      procedure assignTo(dest: tPersistent); override;
    public
      property rect: tRect read fRect write setRect;
      property topLeft: tPoint read getTopLeft write setTopLeft;
      property bottomRight: tPoint read getBottomRight write setBottomRight;
      property onChange: tNotifyEvent read fOnChange write fOnChange;

      procedure beginUpdate;
      procedure endUpdate;
    published
      property left: integer read getLeft write setLeft default 0;
      property top: integer read getTop write setTop default 0;
      property right: integer read getRight write setRight default 0;
      property bottom: integer read getBottom write setBottom default 0;
  end;

type
  tCustomKlausEdit = class(TCustomControl)
    private
      fLines: tKlausEditStrings;
      fStyles: tKlausEditStyleSheet;
      fOptions: tKlausEditOptions;
      fTabSize: integer;
      fGutterWidth: integer;
      fGutterColor: tColor;
      fGutterTextColor: tColor;
      fGutterBevel: tKlausEditGutterBevel;
      fMargins: tKlausEditMargins;
      fScrollTimer: tCustomTimer;
      fCaretPos: tPoint;
      fCaretVisible: boolean;
      fNewCursor: tCursor;
      fLineHeight: integer;
      fAvgCharWidth: integer;
      fMaxCharWidth: integer;
      fTopLine: integer;
      fScrollPos: integer;
      fSelFixed: tPoint;
      fSelVariable: tPoint;
      fSelVarPtr: pChar;
      fLastHorzPos: integer;
      fValidLastHorzPos: boolean;
      fSelBackColor: tColor;
      fSelTextColor: tColor;
      fBtnDown: set of tMouseButton;
      fEditCount: integer;
      fReadOnly: boolean;
      fUndo: tList;
      fUndoing: integer;
      fUndoGroup: longWord;
      fUndoTyping: longWord;
      fUndoDeleting: longWord;
      fUndoLimit: integer;
      fMouseScroll: tMouseScrollDirection;
      fLexParser: tKlausLexParser;
      fLineImages: tImageList;

      fOnPaintArea: tKlausEditPaintAreaEvent;
      fOnGetLineStyle: tKlausEditLineStyleEvent;
      fOnGetLineImages: tKlausEditLineImageEvent;
      fOnMoveCaret: tKlausEditMoveCaretEvent;
      fOnChange: tNotifyEvent;
      fOnLineAdd: tKlausEditLineEvent;
      fOnLineDelete: tKlausEditLineEvent;
      fOnLineChange: tKlausEditLineEvent;
      fOnSetLineFlags: tKlausEditLineFlagsEvent;
      fOnChangeFocus: tKlausEditFocusEvent;

      function  getLines: tStrings;
      function  getText: string;
      procedure setGutterBevel(val: tKlausEditGutterBevel);
      procedure setGutterColor(val: tColor);
      procedure setLineImages(value: tImageList);
      procedure setLines(const value: tStrings);
      function  getLinePtr(line: integer; out p: pChar; out count: integer): integer;
      function  getLinePtrFmt(line: integer; out p: pChar; out count: integer; out fmt: tKlausEditCharFmt): integer;
      function  getLinePtrAt(pt: tPoint): pChar;
      procedure setGutterWidth(const value: integer);
      procedure setGutterTextColor(val: tColor);
      procedure setMargins(const value: tKlausEditMargins);
      procedure marginsChange(sender: tObject);
      function  getAreaRect(index: tKlausEditArea): tRect;
      procedure setOptions(const value: tKlausEditOptions);
      procedure setStyles(value: tKlausEditStyleSheet);
      procedure updateTextMetrics;
      function  getSelExists: boolean;
      function  getSelStart: tPoint;
      function  getSelEnd: tPoint;
      procedure setSelVariable(value: tPoint);
      function  getSelVarPtr: pChar;
      procedure setSelStart(value: tPoint);
      procedure setSelEnd(value: tPoint);
      procedure setSelBackColor(const value: tColor);
      procedure setSelTextColor(const value: tColor);
      procedure invalidateAfter(line: integer);
      function  getSelText: string;
      procedure setUndoLimit(value: integer);
      procedure createCaret;
      procedure destroyCaret;
      procedure hideCaret;
      procedure showCaret;
      procedure updateCaretPos;
      function  validateLastHorzPos: integer;
      procedure mouseScroll(sender: tObject);
      procedure updateMouseScrolling(x, y: integer);
    protected
      procedure WMEraseBkgnd(var msg: tMessage); message WM_EraseBkgnd;
      procedure WMSize(var msg: tWMSize); message WM_Size;
      procedure CMFontChanged(var msg: tMessage); message CM_FontChanged;
      procedure WMVScroll(var msg: tWMVScroll); message WM_VScroll;
      procedure WMHScroll(var msg: tWMHScroll); message WM_HScroll;
      procedure WMSetFocus(var msg: tMessage); message WM_SetFocus;
      procedure WMKillFocus(var msg: tMessage); message WM_KillFocus;
      procedure WMGetDlgCode(var msg: tLMGetDlgCode); message LM_GetDlgCode;
      procedure CMWantSpecialKey(var msg: tCMWantSpecialKey); message CM_WantSpecialKey;
      procedure WMCancelMode(var msg: tMessage); message WM_CancelMode;
    protected
      procedure notification(aComponent: tComponent; aOperation: tOperation); override;
      procedure updateSize;
      function  horzScrollRange: integer; virtual;
      procedure paintArea(cnv: tCanvas; area: tKlausEditArea; const r: tRect); virtual;
      procedure paintMargin(area: tKlausEditArea; cnv: tCanvas; r: tRect); virtual;
      procedure paintGutter(cnv: tCanvas; r: tRect); virtual;
      procedure paintText(cnv: tCanvas; r: tRect); virtual;
      procedure paintLine(cnv: tCanvas; r: tRect; line: integer; selStart, selEnd: integer); virtual;
      procedure doGetLineStyle(line: integer; out style: tKlausEditStyleIndex); virtual;
      procedure doGetLineImages(line: integer; out imgIdx: tIntegerDynArray); virtual;
      procedure updateScrollRange;
      function  getCursor: tCursor; override;
      procedure updateCursor(x, y: integer);
      procedure stringsChanged;
      procedure doMoveCaret(newPos: tPoint; force: boolean = false); virtual;
      procedure moveCaretTo(pt: tPoint; selecting: boolean; retainLastHorzPos: boolean = false);
      procedure moveCaretBy(delta: tPoint; selecting: boolean; retainLastHorzPos: boolean = false);
      procedure doLineAdd(line: integer); virtual;
      procedure doLineChange(line: integer); virtual;
      procedure doLineDelete(line: integer); virtual;
      procedure doSetLineFlags(line: integer; old, new: tKlausEditLineFlags); virtual;
      procedure doTextChange; virtual;
      function  allocStringsData: pointer; virtual;
      procedure disposeStringsData(var p: pointer); virtual;
      procedure copyStringsData(src, dst: pointer; operation: tKlausCopyDataOperation); virtual;
      procedure beginUndo;
      procedure endUndo;
      procedure disposeUndoData(p: pKlausEditUndoData);
      procedure clearUndo;
      procedure checkUndoLimit;
      procedure recordUndoInsertText(pt1, pt2: tPoint; txt: string);
      procedure recordUndoDeleteText(pt1, pt2: tPoint; txt: String);
      procedure recordUndoDataChange(line: integer);
      procedure createParams(var params: tCreateParams); override;
      procedure createWnd; override;
      procedure destroyWnd; override;
      procedure paint; override;
      function  doMouseWheelDown(shift: tShiftState; mousePos: tPoint): boolean; override;
      function  doMouseWheelUp(shift: tShiftState; mousePos: tPoint): boolean; override;
      procedure keyDown(var key: word; shift: tShiftState); override;
      procedure utf8KeyPress(var key: tUTF8Char); override;
      procedure mouseDown(button: tMouseButton; shift: tShiftState; x, y: integer); override;
      procedure mouseMove(shift: tShiftState; x, y: integer); override;
      procedure mouseUp(button: tMouseButton; shift: tShiftState; x, y: integer); override;
      procedure invalidateHighlight(line: integer);
      procedure validateHighlight;
      procedure updateHighlight(line: integer; clex: tKlausLexem; autoStop: boolean);

      property styles: tKlausEditStyleSheet read fStyles write setStyles;
      property gutterWidth: integer read fGutterWidth write setGutterWidth default 0;
      property gutterColor: tColor read fGutterColor write setGutterColor default clBtnFace;
      property gutterTextColor: tColor read fGutterTextColor write setGutterTextColor default clBtnText;
      property gutterBevel: tKlausEditGutterBevel read fGutterBevel write setGutterBevel default kgbRaised;
      property margins: tKlausEditMargins read fMargins write setMargins;
      property parentColor default FALSE;
      property tabStop default TRUE;
      property readOnly: boolean read fReadOnly write fReadOnly default false;
      property selBackColor: tColor read fSelBackColor write setSelBackColor default clHighlight;
      property selTextColor: tColor read fSelTextColor write setSelTextColor default clHighlightText;
      property undoLimit: integer read fUndoLimit write setUndoLimit default 0;
      property lineImages: tImageList read fLineImages write setLineImages;

      property onPaintArea: tKlausEditPaintAreaEvent read fOnPaintArea write fOnPaintArea;
      property onMoveCaret: tKlausEditMoveCaretEvent read fOnMoveCaret write fOnMoveCaret;
      property onChange: tNotifyEvent read fOnChange write fOnChange;
      property onLineAdd: tKlausEditLineEvent read fOnLineAdd write fOnLineAdd;
      property onLineDelete: tKlausEditLineEvent read fOnLineDelete write fOnLineDelete;
      property onLineChange: tKlausEditLineEvent read fOnLineChange write fOnLineChange;
      property onSetLineFlags: tKlausEditLineFlagsEvent read fOnSetLineFlags write fOnSetLineFlags;
      property onGetLineStyle: tKlausEditLineStyleEvent read fOnGetLineStyle write fOnGetLineStyle;
      property onGetLineImages: tKlausEditLineImageEvent read fOnGetLineImages write fOnGetLineImages;
      property onChangeFocus: tKlausEditFocusEvent read fOnChangeFocus write fOnChangeFocus;
    public
      property canvas;
      property color default clWindow;
      property areaRect[index: tKlausEditArea]: tRect read getAreaRect;
      property lines: tStrings read getLines write setLines;
      property text: string read getText;
      property options: tKlausEditOptions read fOptions write setOptions default klausEditDefaultOptions;
      property lineHeight: integer read fLineHeight;
      property topLine: integer read fTopLine;
      property scrollPos: integer read fScrollPos;
      property selExists: boolean read getSelExists;
      property selStart: tPoint read getSelStart write setSelStart;
      property selEnd: tPoint read getSelEnd write setSelEnd;
      property selText: string read getSelText;
      property caretPos: tPoint read fSelVariable;
      property tabSize: integer read fTabSize write fTabSize default klausEditDefaultTabSize;

      constructor create(aOwner: tComponent); override;
      destructor  destroy; override;
      procedure beginEdit(goal: tKlausEditGoal = kegOther);
      procedure endEdit;
      procedure clear;
      procedure scrollTo(aScrollPos, aTopLine: integer);
      procedure makeCharVisible(pt: tPoint);
      function  areaAtCursor(x, y: integer): tKlausEditArea;
      function  hitTest(x, y: integer): tKlausEditHitTestInfo;
      procedure selectAll;
      function  getTextRange(startPos, endPos: tPoint; out startPtr, endPtr: pChar): string;
      function  getTextRange(startPos, endPos: tPoint): string;
      procedure selectText(pt1, pt2: tPoint);
      procedure selectWord(pt: tPoint);
      procedure removeSelection;
      procedure insertText(pt: tPoint; const txt: string);
      procedure deleteText(pt1, pt2: tPoint);
      procedure indentText(pt1, pt2: tPoint; var spaces: integer);
      procedure copyToClipboard;
      procedure cutToClipboard;
      procedure pasteFromClipboard;
      function  canUndo: boolean;
      procedure undo;
      function  search(start: tPoint; txt: string; matchCase: boolean; out pt1, pt2: tPoint): boolean;
      procedure replaceText(pt1, pt2: tPoint; const replaceWith: string);
      function  validPoint(pt: tPoint): tPoint;
      function  prevPage(line: integer; forcePrevLine: boolean = true): integer;
      function  nextPage(line: integer; forceNextLine: boolean = true): integer;
      function  prevChar(pt: tPoint): tPoint;
      function  nextChar(pt: tPoint): tPoint;
      function  prevWord(pt: tPoint): tPoint;
      function  nextWord(pt: tPoint): tPoint;
      procedure invalidateText(startLine, endLine: integer);
      function  charAtPos(line, x: integer): integer;
      function  lineRect(line: integer; shrink: boolean = true): tRect;
      function  horzCharPos(pt: tPoint): integer;
      function  isAlphanumeric(c: u8Char): boolean; virtual;
  end;

type
  tKlausEdit = class(tCustomKlausEdit)
    published
      property align;
      property anchors;
      property borderStyle;
      property color;
      property constraints;
      property cursor;
      property dragCursor;
      property dragKind;
      property dragMode;
      property enabled;
      property font;
      property gutterWidth;
      property gutterColor;
      property gutterTextColor;
      property gutterBevel;
      property lineImages;
      property margins;
      property options;
      property parentColor;
      property parentFont;
      property parentShowHint;
      property popupMenu;
      property readOnly;
      property selBackColor;
      property selTextColor;
      property showHint;
      property styles;
      property tabOrder;
      property tabSize;
      property tabStop;
      property visible;
      property lines;
    published
      property onChange;
      property onChangeFocus;
      property onClick;
      property onContextPopup;
      property onDblClick;
      property onDragDrop;
      property onDragOver;
      property onEndDock;
      property onEndDrag;
      property onEnter;
      property onExit;
      property onGetLineStyle;
      property onGetLineImages;
      property onKeyDown;
      property onKeyPress;
      property onKeyUp;
      property onLineAdd;
      property onLineChange;
      property onLineDelete;
      property onMouseDown;
      property onMouseMove;
      property onMouseUp;
      property onMoveCaret;
      property onPaintArea;
      property onSetLineFlags;
      property onStartDock;
      property onStartDrag;
  end;

implementation

uses
  LCLIntf, WSLCLClasses, TypInfo, Math, klausUtils;

const
  klausEditStyleIniSection = 'KlausSourceEditorColors';

resourcestring
  errInvalidStrIndex = 'Invalid string list index: %d.';

const
  // Раскраска по умолчанию
  klausDefaultEditStyles: array[tUITheme] of record
    fontStyle: tFontStyles;
    fontColor: tColor;
    backColor: tColor;
    selFontColor: tColor;
    selBackColor: tColor;
    styles: array [tKlausEditStyleIndex] of record
      fontColor: tColor;
      backColor: tColor;
      fontStyle: tFontStyles;
      defaultFontStyle: boolean;
      defaultFontColor: boolean;
      defaultBackColor: boolean;
    end;
  end = (
    // thLight
    (fontStyle: [];
    fontColor: clWindowText;
    backColor: clWindow;
    selFontColor: clHighlightText;
    selBackColor: clHighlight;
    styles: (
      // esiNone
      (fontColor: clWindowText; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: true; defaultBackColor: true),
      // esiInvalid
      (fontColor: clRed; backColor: clWindow; fontStyle: [fsBold];
        defaultFontStyle: false; defaultFontColor: false; defaultBackColor: true),
      // esiKeyword
      (fontColor: clWindowText; backColor: clWindow; fontStyle: [fsBold];
        defaultFontStyle: false; defaultFontColor: true; defaultBackColor: true),
      // esiID
      (fontColor: clNavy; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiChar
      (fontColor: $585800; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiString
      (fontColor: $005800; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiInteger
      (fontColor: clMaroon; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiFloat
      (fontColor: clMaroon; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiMoment
      (fontColor: clPurple; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiSymbol
      (fontColor: clBlack; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiSLComment
      (fontColor: clGray; backColor: clWindow; fontStyle: [fsItalic];
        defaultFontStyle: false; defaultFontColor: false; defaultBackColor: true),
      // esiMLComment
      (fontColor: clGray; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiExecPoint
      (fontColor: clBlack; backColor: clAqua; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: false),
      // esiBreakpoint
      (fontColor: clWhite; backColor: clMaroon; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: false),
      // esiErrorLine
      (fontColor: clYellow; backColor: clRed; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: false))),
    // thDark
    (fontStyle: [];
    fontColor: $F0F0F0;
    backColor: $001C00;
    selFontColor: clHighlightText;
    selBackColor: clHighlight;
    styles: (
      // esiNone
      (fontColor: clWindowText; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: true; defaultBackColor: true),
      // esiInvalid
      (fontColor: clRed; backColor: clWindow; fontStyle: [fsBold];
        defaultFontStyle: false; defaultFontColor: false; defaultBackColor: true),
      // esiKeyword
      (fontColor: clWindowText; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: true; defaultBackColor: true),
      // esiID
      (fontColor: $00B8ED; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiChar
      (fontColor: $D0D000; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiString
      (fontColor: $00D000; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiInteger
      (fontColor: $3080FF; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiFloat
      (fontColor: $3080FF; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiMoment
      (fontColor: $E700E7; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiSymbol
      (fontColor: clWindowText; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: true; defaultBackColor: true),
      // esiSLComment
      (fontColor: clGray; backColor: clWindow; fontStyle: [fsItalic];
        defaultFontStyle: false; defaultFontColor: false; defaultBackColor: true),
      // esiMLComment
      (fontColor: clGray; backColor: clWindow; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: true),
      // esiExecPoint
      (fontColor: clBlack; backColor: clAqua; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: false),
      // esiBreakpoint
      (fontColor: clWhite; backColor: clMaroon; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: false),
      // esiErrorLine
      (fontColor: clYellow; backColor: clRed; fontStyle: [];
        defaultFontStyle: true; defaultFontColor: false; defaultBackColor: false)))
  );

{ Globals }

function ptCompare(p1, p2: tPoint): integer;
begin
  if p1.y < p2.y then result := -1
  else if p1.y > p2.y then result := 1
  else if p1.x < p2.x then result := -1
  else if p1.x > p2.x then result := 1
  else result := 0;
end;

function klausEditStyleName(idx: tKlausEditStyleIndex): string;
begin
  result := copy(getEnumName(typeInfo(tKlausEditStyleIndex), ord(idx)), 4);
end;

{ tKlausEditStyle }

constructor tKlausEditStyle.create(aOwner: tKlausEditStyleSheet; idx: tKlausEditStyleIndex);
begin
  inherited create;
  fOwner := aOwner;
  fIndex := idx;
  fName := klausEditStyleName(idx);
  fCaption := klausEditStyleCaption[idx];
  fFontColor := clWindowText;
  fBackColor := clWindow;
  fFontStyle := [];
  fDefaultFontStyle := true;
  fDefaultFontColor := true;
  fDefaultBackColor := true;
end;

procedure tKlausEditStyle.beginUpdate;
begin
  inc(fChangeCount);
end;

procedure tKlausEditStyle.endUpdate;
begin
  if fChangeCount > 0 then begin
    dec(fChangeCount);
    if fChangeCount = 0 then doChange;
  end;
end;

procedure tKlausEditStyle.saveToIni(const sect: string; storage: TIniPropStorage);
begin
  storage.doWriteString(sect, 'fontStyle', fontStyleToString(fontStyle));
  storage.doWriteString(sect, 'fontColor', colorToString(fontColor));
  storage.doWriteString(sect, 'backColor', colorToString(backColor));
  storage.doWriteString(sect, 'defaultFontStyle', BoolToStr(defaultFontStyle, 'true', 'false'));
  storage.doWriteString(sect, 'defaultFontColor', BoolToStr(defaultFontColor, 'true', 'false'));
  storage.doWriteString(sect, 'defaultBackColor', BoolToStr(defaultBackColor, 'true', 'false'));
end;

procedure tKlausEditStyle.loadFromIni(const sect: string; storage: TIniPropStorage);
var
  s: string;
begin
  s := storage.doReadString(sect, 'fontStyle', 'default');
  if s <> 'default' then fontStyle := stringToFontStyle(s);
  s := storage.doReadString(sect, 'fontColor', 'default');
  if s <> 'default' then fontColor := stringToColor(s);
  s := storage.doReadString(sect, 'backColor', 'default');
  if s <> 'default' then backColor := stringToColor(s);
  s := storage.doReadString(sect, 'defaultFontStyle', 'default');
  if s <> 'default' then defaultFontStyle := strToBool(s);
  s := storage.doReadString(sect, 'defaultFontColor', 'default');
  if s <> 'default' then defaultFontColor := strToBool(s);
  s := storage.doReadString(sect, 'defaultBackColor', 'default');
  if s <> 'default' then defaultBackColor := strToBool(s);
end;

procedure tKlausEditStyle.setTextAttrs(canvas: tCanvas);
begin
  if defaultFontStyle then canvas.font.style := owner.fontStyle
  else canvas.font.style := self.fontStyle;
  if defaultFontColor then canvas.font.color := owner.fontColor
  else canvas.font.color := self.fontColor;
  if defaultBackColor then canvas.brush.color := owner.backColor
  else canvas.brush.color := self.backColor;
end;

procedure tKlausEditStyle.doChange;
begin
  with fOwner do begin
    beginUpdate;
    endUpdate;
  end;
end;

procedure tKlausEditStyle.setDefaults(theme: tUITheme);
begin
  with klausDefaultEditStyles[theme].styles[index] do begin
    fFontColor := fontColor;
    fBackColor := backColor;
    fFontStyle := fontStyle;
    fDefaultFontStyle := defaultFontStyle;
    fDefaultFontColor := defaultFontColor;
    fDefaultBackColor := defaultBackColor;
  end;
end;

procedure tKlausEditStyle.assignTo(dest: tPersistent);
begin
  if not (dest is tKLausEditStyle) then inherited
  else with dest as tKlausEditStyle do begin
    beginUpdate;
    try
      fontColor := self.fontColor;
      backColor := self.backColor;
      fontStyle := self.fontStyle;
      defaultFontStyle := self.defaultFontStyle;
      defaultFontColor := self.defaultFontColor;
      defaultBackColor := self.defaultBackColor;
    finally
      endUpdate;
    end;
  end;
end;

procedure tKlausEditStyle.setFontColor(value: tColor);
begin
  if fFontColor <> value then begin
    beginUpdate;
    fDefaultFontColor := false;
    fFontColor := value;
    endUpdate;
  end;
end;

function tKlausEditStyle.getActualBackColor: tColor;
begin
  if defaultBackColor then result := fOwner.backColor
  else result := self.backColor;
end;

function tKlausEditStyle.getActualFontColor: tColor;
begin
  if defaultFontColor then result := fOwner.fontColor
  else result := self.fontColor;
end;

function tKlausEditStyle.getActualFontStyles: tFontStyles;
begin
  if defaultFontStyle then result := fOwner.fontStyle
  else result := self.fontStyle;
end;

procedure tKlausEditStyle.setFontStyle(value: tFontStyles);
begin
  if fFontStyle <> value then begin
    beginUpdate;
    fDefaultFontStyle := false;
    fFontStyle := value;
    endUpdate;
  end;
end;

procedure tKlausEditStyle.setDefaultFontColor(value: boolean);
begin
  if fDefaultFontColor <> value then begin
    beginUpdate;
    fDefaultFontColor := value;
    endUpdate;
  end;
end;

procedure tKlausEditStyle.setDefaultFontStyle(value: boolean);
begin
  if fDefaultFontStyle <> value then begin
    beginUpdate;
    fDefaultFontStyle := value;
    endUpdate;
  end;
end;

procedure tKlausEditStyle.setDefaultBackColor(value: boolean);
begin
  if fDefaultBackColor <> value then begin
    beginUpdate;
    fDefaultBackColor := value;
    endUpdate;
  end;
end;

procedure tKlausEditStyle.setBackColor(value: tColor);
begin
  if value <> fBackColor then begin
    beginUpdate;
    fDefaultBackColor := false;
    fBackColor := value;
    endUpdate;
  end;
end;

{ tKlausEditStyleSheet }

constructor tKlausEditStyleSheet.create;
var
  theme: tUITheme;
  idx: tKlausEditStyleIndex;
begin
  inherited;
  fChangeHandlers := tFPList.create;
  for idx := low(idx) to high(idx) do
    fStyles[idx] := tKlausEditStyle.create(self, idx);
  theme := getCurrentTheme;
  setDefaults(theme);
end;

destructor tKlausEditStyleSheet.destroy;
var
  idx: tKlausEditStyleIndex;
begin
  for idx := low(idx) to high(idx) do fStyles[idx].free;
  freeAndNil(fChangeHandlers);
  inherited;
end;

function tKlausEditStyleSheet.getStyle(idx: tKlausEditStyleIndex): tKlausEditStyle;
begin
  result := fStyles[idx];
end;

procedure tKlausEditStyleSheet.doChange;
var
  i: integer;
begin
  for i := 0 to fChangeHandlers.count-1 do
    updateChangeHandler(tCustomKlausEdit(fChangeHandlers[i]));
  if assigned(fOnChange) then fOnChange(self);
end;

procedure tKlausEditStyleSheet.setDefaults(theme: tUITheme);
var
  idx: tKlausEditStyleIndex;
begin
  with klausDefaultEditStyles[theme] do begin
    fFontStyle := fontStyle;
    fFontColor := fontColor;
    fBackColor := backColor;
    fSelFontColor := selFontColor;
    fSelBackColor := selBackColor;
    for idx := low(idx) to high(idx) do fStyles[idx].setDefaults(theme);
  end;
end;

procedure tKlausEditStyleSheet.assignTo(dest: tPersistent);
var
  idx: tKlausEditStyleIndex;
begin
  if not (dest is tKlausEditStyleSheet) then inherited
  else with dest as tKlausEditStyleSheet do begin
    beginUpdate;
    try
      fontStyle := self.fontStyle;
      fontColor := self.fontColor;
      backColor := self.backColor;
      selFontColor := self.selFontColor;
      selBackColor := self.selBackColor;
      for idx := low(idx) to high(idx) do
        self.style[idx].assignTo(style[idx]);
    finally
      endUpdate;
    end;
  end;
end;

procedure tKlausEditStyleSheet.endUpdate;
begin
  if fChangeCount > 0 then begin
    dec(fChangeCount);
    if fChangeCount = 0 then doChange;
  end;
end;

procedure tKlausEditStyleSheet.addChangeHandler(handler: tCustomKlausEdit);
begin
  fChangeHandlers.add(handler);
end;

procedure tKlausEditStyleSheet.removeChangeHandler(handler: tCustomKlausEdit);
begin
  fChangeHandlers.remove(handler);
end;

procedure tKlausEditStyleSheet.doSaveToIni(storage: TIniPropStorage; const section: string);
var
  idx: tKlausEditStyleIndex;
begin
  storage.doWriteString(section, 'fontStyle', fontStyleToString(fontStyle));
  storage.doWriteString(section, 'fontColor', colorToString(fontColor));
  storage.doWriteString(section, 'backColor', colorToString(backColor));
  storage.doWriteString(section, 'selFontColor', colorToString(selFontColor));
  storage.doWriteString(section, 'selBackColor', colorToString(selBackColor));
  for idx := low(idx) to high(idx) do
    style[idx].saveToIni(section+'.'+style[idx].name, storage);
end;

procedure tKlausEditStyleSheet.saveToIni(storage: TIniPropStorage);
var
  sect, theme: string;
begin
  theme := uiThemeName[getCurrentTheme];
  sect := klausEditStyleIniSection+'.'+theme;
  doSaveToIni(storage, sect);
end;

procedure tKlausEditStyleSheet.doLoadFromIni(storage: TIniPropStorage; const section: string);
var
  s: string;
  idx: tKlausEditStyleIndex;
begin
  s := storage.doReadString(section, 'fontStyle', 'default');
  if s <> 'default' then fontStyle := stringToFontStyle(s);
  s := storage.doReadString(section, 'fontColor', 'default');
  if s <> 'default' then fontColor := stringToColor(s);
  s := storage.doReadString(section, 'backColor', 'default');
  if s <> 'default' then backColor := stringToColor(s);
  s := storage.doReadString(section, 'selFontColor', 'default');
  if s <> 'default' then selFontColor := stringToColor(s);
  s := storage.doReadString(section, 'selBackColor', 'default');
  if s <> 'default' then selBackColor := stringToColor(s);
  for idx := low(idx) to high(idx) do
    style[idx].loadFromIni(section+'.'+style[idx].name, storage);
end;

procedure tKlausEditStyleSheet.updateChangeHandler(edit: tCustomKlausEdit);
begin
  edit.invalidate;
end;

procedure tKlausEditStyleSheet.loadFromIni(storage: TIniPropStorage);
var
  sect, theme: string;
begin
  theme := uiThemeName[getCurrentTheme];
  sect := klausEditStyleIniSection+'.'+theme;
  beginUpdate;
  try
    doLoadFromIni(storage, sect);
  finally
    endUpdate;
  end;
end;

procedure tKlausEditStyleSheet.beginUpdate;
begin
  inc(fChangeCount);
end;

procedure tKlausEditStyleSheet.setBackColor(value: tColor);
begin
  if value <> fBackColor then begin
    beginUpdate;
    fBackColor := value;
    endUpdate;
  end;
end;

procedure tKlausEditStyleSheet.setFontColor(value: tColor);
begin
  if value <> fFontColor then begin
    beginUpdate;
    fFontColor := value;
    endUpdate;
  end;
end;

procedure tKlausEditStyleSheet.setFontStyle(value: tFontStyles);
begin
  if value <> fFontStyle then begin
    beginUpdate;
    fFontStyle := value;
    endUpdate;
  end;
end;

procedure tKlausEditStyleSheet.setSelBackColor(value: tColor);
begin
  if fSelBackColor <> value then begin
    beginUpdate;
    fSelBackColor := value;
    endUpdate;
  end;
end;

procedure tKlausEditStyleSheet.setSelFontColor(value: tColor);
begin
  if fSelFontColor <> value then begin
    beginUpdate;
    fSelFontColor := value;
    endUpdate;
  end;
end;

{ tKlausEditStrings }

constructor tKlausEditStrings.create(aOwner: tCustomKlausEdit);
begin
  inherited create;
  fOwner := aOwner;
  fQuantum := 256;
end;

destructor tKlausEditStrings.destroy;
begin
  clear;
  inherited;
end;

function tKlausEditStrings.getCount: integer;
begin
  result := fCount;
end;

function tKlausEditStrings.get(index: integer): string;
begin
  if (index < 0) or (index >= fCount) then raise eKlausEditError.createFmt(errInvalidStrIndex, [index]);
  result := fItems[index].text;
end;

procedure tKlausEditStrings.clear;
var
  i: integer;
begin
  beginUpdate;
  try
    for i := 0 to fCount-1 do
      fOwner.disposeStringsData(fItems[i].data);
    setLength(fItems, 0);
    fCapacity := 0;
    fCount := 0;
  finally
    owner.stringsChanged;
    endUpdate;
  end;
end;

procedure tKlausEditStrings.doInsert(index: integer; const s: String);
begin
  if (index < 0) or (index > fCount) then raise eKlausEditError.createFmt(errInvalidStrIndex, [index]);
  beginUpdate;
  try
    incCount;
    if index < fCount-1 then
      system.move(fItems[index], fItems[index+1], (fCount-index-1) * sizeOf(tStringData));
    fillChar(fItems[index], sizeOf(tStringData), 0);
    fItems[index].data := fOwner.allocStringsData;
    fItems[index].text := s;
    expandTabs(fItems[index].text);
    fItems[index].charCount := -1;
    fItems[index].fmt := nil;
    fItems[index].hl.valid := false;
  finally
    owner.stringsChanged;
    endUpdate;
  end;
end;

procedure tKlausEditStrings.delete(index: integer);
begin
  if (index < 0) or (index >= fCount) then raise eKlausEditError.createFmt(errInvalidStrIndex, [index]);
  beginUpdate;
  try
    finalize(fItems[index].text);
    fOwner.disposeStringsData(fItems[index].data);
    if index < fCount-1 then
      system.move(fItems[index+1], fItems[index], (fCount-index-1) * SizeOf(tStringData));
    fillChar(fItems[fCount-1], sizeOf(tStringData), 0);
    decCount;
  finally
    owner.stringsChanged;
    endUpdate;
  end;
end;

procedure tKlausEditStrings.doPut(index: integer; const s: string);
begin
  if (index < 0) or (index >= fCount) then raise eKlausEditError.createFmt(errInvalidStrIndex, [index]);
  beginUpdate;
  try
    fItems[index].text := s;
    expandTabs(fItems[index].text);
    fItems[index].charCount := -1;
    fItems[index].fmt := nil;
    fItems[index].hl.valid := false;
  finally
    owner.stringsChanged;
    endUpdate;
  end;
end;

procedure tKlausEditStrings.insert(index: integer; const s: string);
var
  p, start: pChar;
  tmp: String;
begin
  beginUpdate;
  try
    p := pointer(s);
    if p = nil then
      doInsert(index, '')
    else begin
      while p^ <> #0 do begin
        start := p;
        while not (p^ in [#0, #10, #13]) do inc(p);
        setString(tmp, start, p-start);
        doInsert(index, tmp);
        inc(index);
        if p^ = #13 then inc(p);
        if p^ = #10 then inc(p);
      end;
    end;
  finally
    endUpdate;
  end;
end;

procedure tKlausEditStrings.put(index: integer; const s: string);
var
  idx: integer;
  p, start: pChar;
  tmp: String;
begin
  beginUpdate;
  try
    p := pointer(S);
    if p = nil then
      doPut(index, '')
    else begin
      idx := index;
      while p^ <> #0 do begin
        start := p;
        while not (p^ in [#0, #10, #13]) do inc(p);
        setString(tmp, start, p-start);
        if idx = index then doPut(idx, tmp)
        else doInsert(idx, tmp);
        inc(idx);
        if p^ = #13 then inc(p);
        if p^ = #10 then inc(p);
      end;
    end;
  finally
    endUpdate;
  end;
end;

procedure tKlausEditStrings.setTextStr(const value: string);
begin
  beginUpdate;
  try
    clear;
    if value <> '' then insert(0, value);
  finally
    endUpdate;
  end;
end;

procedure tKlausEditStrings.setFormatting(
  style: tKlausEditStyleIndex; line: integer; startPos, endPos: integer);
var
  l: integer;
begin
  assert((line >= 0) and (line < fCount), 'Invalid line index');
  l := getCharCount(line);
  if endPos > l then endPos := l;
  if startPos <= 0 then startPos := 1;
  if startPos > endPos then exit;
  fillChar(fItems[line].fmt[startPos-1], endPos-startPos+1, byte(style));
  fOwner.invalidateText(line, line);
end;

procedure tKlausEditStrings.setUpdateState(updating: boolean);
begin
  if updating or (fEditCount <> 0) then exit;
  with fOwner do try
    if csDestroying in componentState then exit;
    updateScrollRange;
    scrollTo(0, 0);
    selStart := point(0, 0);
    validateHighlight;
    fOwner.doTextChange;
  finally
    invalidate;
  end;
end;

procedure tKlausEditStrings.decCount;
begin
  dec(fCount);
  if fCount < fCapacity-fQuantum then begin
    fCapacity := max(0, fCapacity-fQuantum);
    setLength(fItems, fCapacity);
  end;
end;

procedure tKlausEditStrings.incCount;
begin
  inc(fCount);
  if fCount > fCapacity then begin
    inc(fCapacity, fQuantum);
    setLength(fItems, fCapacity);
  end;
end;

procedure tKlausEditStrings.beginEdit;
begin
  inc(fEditCount);
end;

procedure tKlausEditStrings.endEdit;
begin
  if fEditCount > 0 then begin
    dec(fEditCount);
    if fEditCount = 0 then fOwner.doTextChange;
  end;
end;

procedure tKlausEditStrings.expandTabs(var s: string);
var
  ts, idx, cnt: integer;
begin
  ts := fOwner.tabSize;
  idx := pos(#9, s);
  while idx > 0 do begin
    cnt := ((idx-1) div ts)*ts+ts-idx+1;
    s[idx] := #32;
    system.insert(stringOfChar(#32, cnt-1), s, idx);
    idx := pos(#9, S, idx+1);
  end;
end;

function tKlausEditStrings.getData(index: integer): pointer;
begin
  if (index < 0) or (index >= fCount) then
    raise eKlausEditError.createFmt(errInvalidStrIndex, [index]);
  result := fItems[index].data;
end;

function tKlausEditStrings.getCharCount(index: integer): integer;
begin
  if (index < 0) or (index >= fCount) then
    raise eKlausEditError.createFmt(errInvalidStrIndex, [index]);
  with fItems[index] do begin
    if charCount < 0 then begin
      charCount := u8CharCount(text);
      setLength(fmt, charCount);
      if charCount > 0 then fillChar(fmt[0], charCount, ord(low(tKlausEditStyleIndex)));
    end;
    result := charCount;
  end;
end;

function tKlausEditStrings.getFlags(index: integer): tKlausEditLineFlags;
begin
  if (index < 0) or (index >= fCount) then
    raise eKlausEditError.createFmt(errInvalidStrIndex, [index]);
  result := fItems[index].flags;
end;

procedure tKlausEditStrings.setFlags(index: integer; value: tKlausEditLineFlags);
var
  old: tKlausEditLineFlags;
begin
  if (index < 0) or (index >= fCount) then
    raise eKlausEditError.createFmt(errInvalidStrIndex, [index]);
  old := fItems[index].flags;
  if old <> value then begin
    fItems[index].flags := value;
    fOwner.doSetLineFlags(index, old, value);
    fOwner.invalidateText(index, index);
  end;
end;

{ tKlausEditMargins }

procedure tKlausEditMargins.assignTo(dest: tPersistent);
begin
  if dest is tKlausEditMargins then
    (dest as tKlausEditMargins).rect := self.rect
  else
    inherited;
end;

procedure tKlausEditMargins.beginUpdate;
begin
  inc(fUpdateCount);
end;

procedure tKlausEditMargins.change;
begin
  if assigned(fOnChange) then fOnChange(self);
end;

procedure tKlausEditMargins.endUpdate;
begin
  if fUpdateCount > 0 then begin
    dec(fUpdateCount);
    if fUpdateCount = 0 then change;
  end;
end;

function tKlausEditMargins.getLeft: integer; begin result := fRect.left; end;
function tKlausEditMargins.getTop: integer; begin result := fRect.top; end;
function tKlausEditMargins.getRight: integer; begin result := fRect.right; end;
function tKlausEditMargins.getBottom: integer; begin result := fRect.bottom; end;
function tKlausEditMargins.getTopLeft: tPoint; begin result := fRect.topLeft; end;
function tKlausEditMargins.getBottomRight: tPoint; begin result := fRect.bottomRight; end;

procedure tKlausEditMargins.setBottom(const value: integer);
begin
  if fRect.Bottom <> value then begin
    beginUpdate;
    try fRect.bottom := value;
    finally endUpdate; end;
  end;
end;

procedure tKlausEditMargins.setBottomRight(const value: tPoint);
begin
  if (fRect.right <> value.x)
  or (fRect.bottom <> value.y) then begin
    beginUpdate;
    try fRect.bottomRight := value;
    finally endUpdate; end;
  end;
end;

procedure tKlausEditMargins.setLeft(const value: integer);
begin
  if fRect.left <> value then begin
    beginUpdate;
    try fRect.left := value;
    finally endUpdate; end;
  end;
end;

procedure tKlausEditMargins.setRect(const value: tRect);
begin
  if (fRect.left <> value.left)
  or (fRect.top <> value.top)
  or (fRect.right <> value.right)
  or (fRect.bottom <> value.bottom) then begin
    beginUpdate;
    try fRect := value;
    finally endUpdate; end;
  end;
end;

procedure tKlausEditMargins.setRight(const value: integer);
begin
  if fRect.right <> value then begin
    beginUpdate;
    try fRect.right := value;
    finally endUpdate; end;
  end;
end;

procedure tKlausEditMargins.setTop(const value: integer);
begin
  if fRect.top <> value then begin
    beginUpdate;
    try fRect.top := value;
    finally endUpdate; end;
  end;
end;

procedure tKlausEditMargins.setTopLeft(const value: tPoint);
begin
  if (fRect.left <> value.x)
  or (fRect.top <> value.y) then begin
    beginUpdate;
    try fRect.topLeft := value;
    finally endUpdate; end;
  end;
end;

{ tCustomKlausEdit }

constructor tCustomKlausEdit.create(aOwner: tComponent);
begin
  inherited;
  fScrollTimer := tCustomTimer.create(nil);
  fScrollTimer.interval := klausEditScrollSpeed;
  fScrollTimer.OnTimer := @mouseScroll;
  fMouseScroll := msdNone;
  fCaretPos := point(0, 0);
  fNewCursor := crDefault;
  width := 300;
  height := 200;
  parentColor := false;
  color := clWindow;
  tabStop := true;
  fMargins := tKlausEditMargins.create;
  fMargins.onChange := @marginsChange;
  fLines := tKlausEditStrings.create(self);
  fOptions := [];
  fTabSize := klausEditDefaultTabSize;
  fGutterWidth := 0;
  fGutterColor := clBtnFace;
  fGutterTextColor := clBtnText;
  fGutterBevel := kgbRaised;
  fSelFixed := point(1, 0);
  fSelVariable := point(1, 0);
  fSelVarPtr := nil;
  fSelBackColor := clHighlight;
  fSelTextColor := clHighlightText;
  fUndoLimit := 0;
  setOptions(klausEditDefaultOptions);
  fLexParser := tKlausLexParser.create('');
  fLexParser.raiseErrors := false;
  clearUndo;
end;

destructor tCustomKlausEdit.destroy;
begin
  freeAndNil(fScrollTimer);
  clearUndo;
  freeAndNil(fUndo);
  freeAndNil(fLines);
  freeAndNil(fMargins);
  freeAndNil(fLexParser);
  if fStyles <> nil then fStyles.removeChangeHandler(self);
  inherited;
end;

procedure tCustomKlausEdit.clear;
begin
  lines.clear;
end;

procedure tCustomKlausEdit.createParams(var params: tCreateParams);
begin
  inherited;
  with Params do begin
    Style := Style or WS_VSCROLL or WS_HSCROLL;
    WindowClass.Style:=WindowClass.Style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

function tCustomKlausEdit.getLines: tStrings;
begin
  result := fLines;
end;

function tCustomKlausEdit.getText: string;
begin
  result := fLines.text;
end;

procedure tCustomKlausEdit.setGutterBevel(val: tKlausEditGutterBevel);
begin
  if fGutterBevel <> val then begin
    fGutterBevel := val;
    invalidate;
  end;
end;

procedure tCustomKlausEdit.setGutterColor(val: tColor);
begin
  if fGutterColor <> val then begin
    fGutterColor := val;
    invalidate;
  end;
end;

procedure tCustomKlausEdit.setLineImages(value: tImageList);
begin
  if fLineImages<> value then begin
    if fLineImages <> nil then fLineImages.removeFreeNotification(self);
    fLineImages := value;
    if fLineImages <> nil then fLineImages.freeNotification(self);
  end;
end;

procedure tCustomKlausEdit.setGutterTextColor(val: tColor);
begin
  if fGutterTextColor <> val then begin
    fGutterTextColor := val;
    invalidate;
  end;
end;

procedure tCustomKlausEdit.setLines(const value: tStrings);
begin
  fLines.assign(value);
end;

function tCustomKlausEdit.getLinePtr(line: integer; out p: pChar; out count: integer): integer;
var
  fmt: tKlausEditCharFmt;
begin
  result := getLinePtrFmt(line, p, count, fmt);
end;

function tCustomKlausEdit.getLinePtrFmt(line: integer; out p: pChar; out count: integer; out fmt: tKlausEditCharFmt): integer;
var
  s: string;
begin
  if line >= fLines.count then begin
    p := nil;
    count := 0;
    fmt := nil;
    exit(0);
  end;
  s := fLines[line];
  result := length(s);
  p := pChar(s);
  count := fLines.charCount[line];
  fmt := fLines.fItems[line].fmt;
end;

function tCustomKlausEdit.getLinePtrAt(pt: tPoint): pChar;
begin
  pt := validPoint(pt);
  if pt.y >= fLines.count then result := nil
  else if pt = fSelVariable then result := getSelVarPtr
  else result := u8SkipChars(pChar(fLines[pt.y]), pt.x-1);
end;

procedure tCustomKlausEdit.paint;
const
  l = succ(low(tKlausEditArea));
  h = high(tKlausEditArea);
var
  a: tKlausEditArea;
begin
  hideCaret;
  for a := l to h do
    paintArea(canvas, a, areaRect[a]);
  updateCaretPos;
end;

procedure tCustomKlausEdit.updateCaretPos;
var
  lr: tRect;
begin
  if handleAllocated then begin
    hideCaret;
    if focused then begin
      lr := lineRect(fSelVariable.y, false);
      fCaretPos := point(horzCharPos(fSelVariable)-1, lr.top+2);
      with fCaretPos do lr := rect(x, y, x+2, y+fLineHeight-2);
      if lr.intersectsWith(areaRect[keaText]) then begin
        LCLIntf.setCaretPos(fCaretPos.x, fCaretPos.y);
        showCaret;
      end;
    end;
  end;
end;

function tCustomKlausEdit.validateLastHorzPos: integer;
begin
  if not fValidLastHorzPos then begin
    fLastHorzPos := horzCharPos(fSelVariable)-areaRect[keaText].left+fScrollPos;
    fValidLastHorzPos := true;
  end;
  result := fLastHorzPos;
end;

procedure tCustomKlausEdit.mouseScroll(sender: tObject);
begin
  case fMouseScroll of
    msdUp: perform(WM_VScroll, SB_LINEUP, 0);
    msdDown: perform(WM_VScroll, SB_LINEDOWN, 0);
    msdLeft: perform(WM_HScroll, SB_LINELEFT, 0);
    msdRight: perform(WM_HScroll, SB_LINERIGHT, 0);
  end;
end;

procedure tCustomKlausEdit.updateMouseScrolling(x, y: integer);
var
  r: tRect;
begin
  if mbLeft in fBtnDown then begin
    r := areaRect[keaText];
    if y < r.top then fMouseScroll := msdUp
    else if y > r.bottom then fMouseScroll := msdDown
    else if x < r.left then fMouseScroll := msdLeft
    else if x > r.right then fMouseScroll := msdRight
    else fMouseScroll := msdNone;
    fScrollTimer.enabled := fMouseScroll <> msdNone;
  end else begin
    fMouseScroll := msdNone;
    fScrollTimer.enabled := false;
  end;
end;

procedure tCustomKlausEdit.WMEraseBkgnd(var msg: tMessage);
begin
  msg.result := 1;
end;

procedure tCustomKlausEdit.updateSize;
begin
  updateScrollRange;
  updateCaretPos;
  makeCharVisible(fSelVariable);
  invalidate;
end;

procedure tCustomKlausEdit.setGutterWidth(const value: integer);
begin
  if fGutterWidth <> value then begin
    fGutterWidth := Value;
    updateSize;
  end;
end;

procedure tCustomKlausEdit.setMargins(const value: tKlausEditMargins);
begin
  fMargins.assign(value);
end;

procedure tCustomKlausEdit.marginsChange(sender: tObject);
begin
  updateSize;
end;

function tCustomKlausEdit.getAreaRect(index: tKlausEditArea): tRect;
begin
  with clientRect do begin
    case index of
      keaNone         :result := rect(0, 0, 0, 0);
      keaGutter       :result := rect(left, top, left+fGutterWidth, bottom);
      keaLeftMargin   :result := rect(Left+fGutterWidth, top, left+fGutterWidth+fMargins.left, bottom);
      keaTopMargin    :result := rect(left+fGutterWidth+fMargins.left, top, right-fMargins.right, top+fMargins.top);
      keaRightMargin  :result := rect(right-fMargins.right, top, right, bottom);
      keaBottomMargin :result := rect(left+fGutterWidth+fMargins.left, bottom-fMargins.bottom, right-fMargins.right, bottom);
      keaText         :result := rect(left+fGutterWidth+fMargins.left, top+fMargins.top, right-fMargins.right, bottom-fMargins.bottom);
    else
      result := rect(0, 0, 0, 0);
      assert(false, 'Invalid tKlausEditArea value');
    end;
  end;
end;

procedure tCustomKlausEdit.paintArea(cnv: tCanvas; area: tKlausEditArea; const r: tRect);
var
  int: tRect = (left: 0; top: 0; right: 0; bottom: 0);
  handled: boolean;
begin
  if area = keaNone then exit;
  handled := not intersectRect(int, r, cnv.clipRect);
  if not handled and assigned(fOnPaintArea) then fOnPaintArea(self, cnv, area, r, handled);
  if handled then exit;
  case area of
    keaGutter:       paintGutter(cnv, r);
    keaText:         paintText(cnv, r);
    keaLeftMargin,
    keaTopMargin,
    keaRightMargin,
    keaBottomMargin: paintMargin(area, cnv, r);
  else
    assert(false, 'Invalid tKlausEditArea value');
  end;
end;

procedure tCustomKlausEdit.paintGutter(cnv: tCanvas; r: tRect);
var
  s: string;
  clip, lr, mr: tRect;
  img: TIntegerDynArray;
  line, w, bw, i, x, y, imgx: integer;
begin
  with cnv do begin
    with brush do begin color := fGutterColor; style := bsSolid; end;
    with pen do begin style := psSolid; mode := pmCopy; width := 1; end;
    case fGutterBevel of
      kgbSpacer: begin
        pen.color := fGutterColor;
        polyline([point(r.right-2, 0), point(r.right-2, r.bottom)]);
        polyline([point(r.right-1, 0), point(r.right-1, r.bottom)]);
        bw := 2;
      end;
      kgbLine: begin
        pen.color := lighterOrDarker(fGutterColor, 0.25);
        polyline([point(r.right-1, 0), point(r.right-1, r.bottom)]);
        bw := 1;
      end;
      kgbLowered: begin
        pen.color := darker(fGutterColor, 0.2);
        polyline([point(r.right-2, 0), point(r.right-2, r.bottom)]);
        pen.color := lighter(fGutterColor, 0.2);
        polyline([point(r.right-1, 0), point(r.right-1, r.bottom)]);
        bw := 2;
      end;
      kgbRaised: begin
        pen.color := lighter(fGutterColor, 0.2);
        polyline([point(r.right-2, 0), point(r.right-2, r.bottom)]);
        pen.color := darker(fGutterColor, 0.2);
        polyline([point(r.right-1, 0), point(r.right-1, r.bottom)]);
        bw := 2;
      end;
    else
      bw := 0;
    end;
    mr := areaRect[keaTopMargin];
    cnv.fillRect(r.left, mr.top, r.right-bw, mr.bottom);
  end;
  if (keoLineNumbers in fOptions) or (fLineImages <> nil) then begin
    cnv.font := self.font;
    cnv.font.color := fGutterTextColor;
    line := fTopLine;
    clip := cnv.clipRect;
    lr := rect(r.left, mr.bottom, r.right-bw, mr.bottom);
    while line < fLines.count do begin
      lr.bottom := min(r.bottom, lr.top+fLineHeight);
      if lr.intersectsWith(clip) then begin
        imgx := lr.left + 2;
        cnv.fillRect(lr.left, lr.top, lr.right, lr.bottom);
        if lineImages <> nil then begin
          doGetLineImages(line, img);
          x := lr.left + 2;
          y := lr.top + trunc(fLineHeight/2 - lineImages.height/2);
          for i := low(img) to high(img) do begin
            if img[i] >= 0 then begin
              lineImages.draw(cnv, x, y, img[i], true);
              imgx := x + lineImages.width;
            end;
            x += lineImages.width;
          end;
        end;
        if keoLineNumbers in fOptions then begin
          s := intToStr(line+1);
          w := cnv.textWidth(s);
          if imgx < lr.right-w-2 then
            textOut(cnv.handle, lr.right-w-2, lr.top, pChar(s), length(s));
        end;
      end;
      lr.top := lr.bottom;
      if lr.top >= r.bottom then break;
      inc(line);
    end;
    if lr.bottom < r.bottom then
      cnv.fillRect(lr.left, lr.bottom, lr.right, r.bottom);
  end else begin
    r.right -= bw;
    cnv.fillRect(r);
  end;
end;

procedure tCustomKlausEdit.paintMargin(area: tKlausEditArea; cnv: tCanvas; r: tRect);
begin
  with cnv do begin
    with brush do begin color := self.color; style := bsSolid; end;
    fillRect(r);
  end;
end;

procedure tCustomKlausEdit.paintText(cnv: tCanvas; r: tRect);
var
  line, ss, se: integer;
  lr, clip: tRect;
  sStart, sEnd: tPoint;
  sel: boolean;
begin
  line := fTopLine;
  clip := cnv.clipRect;
  cnv.font := self.font;
  lr := rect(r.left, r.top, r.right, r.top);
  sel := selExists and (focused or not (keoHideSelection in fOptions));
  if sel then begin
    sStart := getSelStart;
    sEnd := getSelEnd;
  end else begin
    sStart := point(0, 0);
    sEnd := point(0, 0);
  end;
  while line < fLines.count do begin
    lr.bottom := min(r.bottom, lr.top+fLineHeight);
    if lr.intersectsWith(clip) then begin
      if selExists and (line >= sStart.y) and (line <= sEnd.y) then begin
        if line > sStart.y then ss := 0 else ss := sStart.x-1;
        if line < sEnd.y then se := -1 else se := sEnd.x-1;
      end else begin
        ss := -1;
        se := -1;
      end;
      paintLine(cnv, lr, line, ss, se);
    end;
    lr.top := lr.bottom;
    if lr.top >= r.bottom then break;
    inc(line);
  end;
  if lr.bottom < r.bottom then begin
    lr := rect(lr.left, lr.bottom, lr.right, r.bottom);
    with cnv.brush do begin
      if fStyles = nil then color := self.color
      else color := fStyles.backColor;
      style := bsSolid;
    end;
    cnv.fillRect(lr);
  end;
end;

procedure tCustomKlausEdit.doGetLineStyle(line: integer; out style: tKlausEditStyleIndex);
begin
  style := esiNone;
  if system.assigned(fOnGetLineStyle) then fOnGetLineStyle(self, line, style);
end;

procedure tCustomKlausEdit.doGetLineImages(line: integer; out imgIdx: tIntegerDynArray);
begin
  if assigned(fOnGetLineImages) then fOnGetLineImages(self, line, imgIdx);
end;

procedure tCustomKlausEdit.paintLine(cnv: tCanvas; r: tRect; line: integer; selStart, selEnd: integer);
// if selStart is -1, no text is selected.
// if selEnd is -1, the entire line after selStart is selected (including LF).
var
  defFC, defBC, selFC, selBC: tColor;

  procedure setTextAttrs(cnv: tCanvas; stl: tKlausEditStyleIndex; highlight: boolean);
  begin
    if highlight then begin
      cnv.brush.color := selBC;
      cnv.font.color := selFC;
    end else if fStyles <> nil then begin
      fStyles[stl].setTextAttrs(cnv);
    end else begin
      cnv.brush.color := defBC;
      cnv.font.color := defFC;
    end;
  end;

  function getTextWidth(p: pChar; l: integer): integer;
  var
    size: tSize = (cx: 0; cy: 0);
  begin
    getTextExtentPoint(cnv.handle, p, l, size);
    result := size.cx;
  end;

  function getNextPortion(
    chr, len: integer;
    const fmt: tKlausEditCharFmt;
    out style: tKlausEditStyleIndex;
    out highlight: boolean): integer;
  var
    i, stop: integer;
  begin
    result := chr;
    highlight := (selStart >= 0) and (chr >= selStart) and ((selEnd < 0) or (chr < selEnd));
    if highlight then begin
      if selEnd < 0 then result := len
      else result := min(len, selEnd);
    end else begin
      if (selStart >= 0) and (chr < selStart) then stop := selStart else stop := len;
      if chr >= stop then style := esiNone else style := fmt[chr];
      for i := chr+1 to stop do begin
        result := i;
        if i < len then if fmt[i] <> style then break;
      end;
    end;
    result -= chr;
  end;

const
  Flg = ETO_CLIPPED or ETO_OPAQUE;
var
  stl, lstl: tKlausEditStyleIndex;
  fmt: tKlausEditCharFmt;
  p, pp: pChar;
  chr, pl, len: integer;
  x, y, w: Integer;
  highlight: Boolean;
  pr: tRect = (left: 0; top: 0; right: 0; bottom: 0);
  dr: tRect = (left: 0; top: 0; right: 0; bottom: 0);
begin
  if fStyles = nil then begin
    defBC := self.color;
    defFC := self.font.color;
    selBC := self.selBackColor;
    selFC := self.selTextColor;
  end else begin
    defBC := fStyles.backColor;
    defFC := fStyles.fontColor;
    selBC := fStyles.selBackColor;
    selFC := fStyles.selFontColor;
  end;
  x := r.left - fScrollPos;
  y := r.top;
  cnv.brush.style := bsSolid;
  cnv.font := self.font;
  doGetLineStyle(line, lstl);
  getLinePtrFmt(line, p, len, fmt);
  chr := 0;
  repeat
    pl := getNextPortion(chr, len, fmt, stl, highlight);
    pp := u8SkipChars(p, pl);
    if lstl <> esiNone then stl := lstl;
    setTextAttrs(cnv, stl, highlight);
    w := getTextWidth(p, pp-p);
    pr := rect(x, r.top, x+w, r.bottom);
    if intersectRect(dr, r, pr) then
      extTextOut(cnv.handle, x, y, flg, @dr, p, pp-p, nil);
    pr.Left := max(r.left, pr.right);
    pr.right := r.right;
    setTextAttrs(cnv, lstl, highlight);
    cnv.fillRect(pr);
    chr += pl;
    p := pp;
    x += w;
  until chr >= len;
  if (selStart >= len) or (selEnd >= len) then begin
    if selStart >= len then cnv.brush.color := selBC
    else cnv.brush.color := defBC;
    cnv.fillRect(rect(x, r.top, r.right, r.bottom));
  end;
end;

procedure tCustomKlausEdit.updateTextMetrics;
begin
  if not handleAllocated then begin
    fLineHeight := abs(self.font.height);
    fAvgCharWidth := fLineHeight;
    fMaxCharWidth := fLineHeight;
  end else begin
    canvas.font := self.font;
    fLineHeight := canvas.textHeight('fp');
    fAvgCharWidth := canvas.textWidth('n');
    fMaxCharWidth := canvas.textWidth('M');
    if focused then createCaret;
  end;
end;

procedure tCustomKlausEdit.WMSize(var msg: tWMSize);
begin
  inherited;
  updateSize;
end;

procedure tCustomKlausEdit.updateScrollRange;
var
  vsr, hsr: integer;
begin
  if handleAllocated then begin
    canvas.font := self.font;
    vsr := max(0, fLines.count-1);
    hsr := horzScrollRange;
    setScrollRange(handle, SB_HORZ, 0, max(1, hsr), true);
    setScrollRange(handle, SB_VERT, 0, max(1, vsr), true);
    scrollTo(min(fScrollPos, hsr), min(fTopLine, vsr));
  end;
end;

procedure tCustomKlausEdit.createWnd;
begin
  inherited;
  updateTextMetrics;
  updateSize;
end;

procedure tCustomKlausEdit.destroyWnd;
begin
  destroyCaret;
  inherited;
  updateTextMetrics;
  updateSize;
end;

procedure tCustomKlausEdit.CMFontChanged(var msg: tMessage);
begin
  inherited;
  updateTextMetrics;
  updateSize;
end;

procedure tCustomKlausEdit.setOptions(const value: tKlausEditOptions);
begin
  if fOptions <> value then begin
    fOptions := value;
    invalidate;
  end;
end;

procedure tCustomKlausEdit.setStyles(value: tKlausEditStyleSheet);
begin
  if fStyles <> value then begin
    if fStyles <> nil then fStyles.removeChangeHandler(self);
    fStyles := value;
    if fStyles <> nil then fStyles.addChangeHandler(self);
    invalidate;
  end;
end;

procedure tCustomKlausEdit.stringsChanged;
begin
  if csDestroying in componentState then exit;
  if fEditCount = 0 then begin
    setSelVariable(fSelVariable);
    clearUndo;
  end;
end;

function tCustomKlausEdit.allocStringsData: pointer;
begin
  result := nil;
end;

procedure tCustomKlausEdit.disposeStringsData(var p: pointer);
begin
  if p <> nil then freeMem(p);
  p := nil;
end;

procedure tCustomKlausEdit.copyStringsData(src, dst: pointer; operation: tKlausCopyDataOperation);
begin
end;

procedure tCustomKlausEdit.doTextChange;
begin
  if assigned(fOnChange) then fOnChange(self);
end;

function tCustomKlausEdit.getSelExists: boolean;
begin
  result := fSelFixed <> fSelVariable;
end;

function tCustomKlausEdit.getSelEnd: tPoint;
begin
  if ptCompare(fSelFixed, fSelVariable) > 0 then result := fSelFixed
  else result := fSelVariable;
end;

function tCustomKlausEdit.getSelStart: tPoint;
begin
  if ptCompare(fSelFixed, fSelVariable) > 0 then result := fSelVariable
  else result := fSelFixed;
end;

function tCustomKlausEdit.horzScrollRange: integer;
begin
  result := max(clientWidth*3, fAvgCharWidth*1024);
end;

procedure tCustomKlausEdit.scrollTo(aScrollPos, aTopLine: integer);
var
  r: TRect;
  dx, dy: Integer;
begin
  if (csDestroying in componentState) then exit;
  aScrollPos := max(0, min(aScrollPos, horzScrollRange));
  aTopLine := max(0, min(aTopLine, fLines.count-1));
  if handleAllocated then begin
    dx := fScrollPos-aScrollPos;
    dy := (fTopLine-aTopLine)*fLineHeight;
    fTopLine := aTopLine;
    fScrollPos := aScrollPos;
    r := areaRect[keaText];
    scrollWindowEx(handle, dx, dy, @r, @r, 0, nil, SW_INVALIDATE);
    r := areaRect[keaGutter];
    scrollWindowEx(handle, 0, dy, @r, @r, 0, nil, SW_INVALIDATE);
    updateWindow(handle);
    setScrollPos(handle, SB_HORZ, fScrollPos, true);
    setScrollPos(handle, SB_VERT, fTopLine, true);
  end else begin
    fTopLine := aTopLine;
    fScrollPos := aScrollPos;
  end;
  updateCaretPos;
end;

procedure tCustomKlausEdit.WMVScroll(var msg: tWMVScroll);
begin
  case msg.scrollCode of
    SB_TOP            :scrollTo(fScrollPos, 0);
    SB_BOTTOM         :scrollTo(fScrollPos, maxInt);
    SB_PAGEUP         :scrollTo(fScrollPos, prevPage(fTopLine));
    SB_PAGEDOWN       :scrollTo(fScrollPos, nextPage(fTopLine));
    SB_LINEUP         :scrollTo(fScrollPos, fTopLine - 1);
    SB_LINEDOWN       :scrollTo(fScrollPos, fTopLine + 1);
    SB_THUMBPOSITION  :scrollTo(fScrollPos, msg.pos);
    SB_THUMBTRACK     :if not (keoNoThumbTrack in fOptions) then scrollTo(fScrollPos, msg.pos);
  end;
end;

procedure tCustomKlausEdit.WMHScroll(var msg: tWMHScroll);
var
  w: integer;
begin
  with areaRect[keaText] do w := right-left;
  case msg.scrollCode of
    SB_TOP            :scrollTo(0, fTopLine);
    SB_BOTTOM         :scrollTo(MaxInt, fTopLine);
    SB_PAGELEFT       :scrollTo(fScrollPos - w + fAvgCharWidth, fTopLine);
    SB_PAGERIGHT      :scrollTo(fScrollPos + w - FAvgCharWidth, fTopLine);
    SB_LINELEFT       :scrollTo(fScrollPos - fAvgCharWidth, fTopLine);
    SB_LINERIGHT      :scrollTo(fScrollPos + fAvgCharWidth, fTopLine);
    SB_THUMBPOSITION  :scrollTo(msg.pos, fTopLine);
    SB_THUMBTRACK     :if not (keoNoThumbTrack in fOptions) then scrollTo(msg.pos, fTopLine);
  end;
end;

function tCustomKlausEdit.prevPage(line: integer; forcePrevLine: boolean = true): integer;
var
  h: integer;
begin
  with areaRect[keaText] do h := bottom-top;
  result := line-(h div fLineHeight)+1;
  if (result >= line) and forcePrevLine then result := line-1;
end;

function tCustomKlausEdit.nextPage(line: integer; forceNextLine: boolean = true): integer;
var
  h: integer;
begin
  with areaRect[keaText] do h := bottom-top;
  result := line+(h div fLineHeight)-1;
  if (result <= line) and forceNextLine then result := line+1;
end;

function tCustomKlausEdit.doMouseWheelDown(shift: tShiftState; mousePos: tPoint): boolean;
begin
  result := inherited doMouseWheelDown(shift, mousePos);
  if not result then begin
    shift := shift * [ssShift, ssAlt, ssCtrl];
    if shift = [] then scrollTo(fScrollPos, fTopLine + klausEditWheelVScrollDistance)
    else if shift = [ssCtrl] then scrollTo(fScrollPos, nextPage(fTopLine))
    else if shift = [ssShift, ssCtrl] then scrollTo(fScrollPos + fAvgCharWidth * klausEditWheelVScrollDistance, fTopLine);
  end;
  result := true;
end;

function tCustomKlausEdit.doMouseWheelUp(shift: tShiftState; mousePos: tPoint): boolean;
begin
  result := inherited doMouseWheelUp(shift, mousePos);
  if not result then begin
    shift := shift * [ssShift, ssAlt, ssCtrl];
    if shift = [] then scrollTo(fScrollPos, fTopLine - klausEditWheelVScrollDistance)
    else if shift = [ssCtrl] then scrollTo(fScrollPos, prevPage(fTopLine))
    else if shift = [ssShift, ssCtrl] then scrollTo(fScrollPos - fAvgCharWidth * klausEditWheelVScrollDistance, fTopLine);
  end;
  result := true;
end;

procedure tCustomKlausEdit.WMSetFocus(var msg: tMessage);
begin
  inherited;
  createCaret;
  updateCaretPos;
  if selExists and (keoHideSelection in fOptions) then invalidate;
  if assigned(fOnChangeFocus) then fOnChangeFocus(self, true);
end;

procedure tCustomKlausEdit.WMKillFocus(var msg: tMessage);
begin
  destroyCaret;
  inherited;
  if selExists and (keoHideSelection in fOptions) then invalidate;
  if assigned(fOnChangeFocus) then fOnChangeFocus(self, false);
end;

procedure tCustomKlausEdit.setSelVariable(value: tPoint);
var
  p: pChar;
  prev: tPoint;
begin
  prev := fSelVariable;
  fSelVariable := value;
  if (value <> prev) and (fEditCount = 0) then begin
    fUndoTyping := 0;
    fUndoDeleting := 0;
  end;
  if (value.y < 0) or (value.y >= fLines.count) then begin
    fSelVarPtr := nil;
    exit;
  end;
  p := pChar(fLines[value.y]);
  if (fSelVarPtr = nil) or (prev.y <> value.y) then
    fSelVarPtr := u8SkipChars(p, value.x-1)
  else if prev.x <> fSelVariable.x then begin
    if value.x > prev.x then fSelVarPtr := u8SkipChars(fSelVarPtr, value.x-prev.x)
    else if value.x > prev.x div 2 then fSelVarPtr := u8SkipCharsLeft(fSelVarPtr, p, prev.x-value.x)
    else fSelVarPtr := u8SkipChars(p, value.x-1);
  end;
end;

function  tCustomKlausEdit.getSelVarPtr: pChar;
begin
  setSelVariable(fSelVariable);
  result := fSelVarPtr;
end;

procedure tCustomKlausEdit.setSelStart(value: tPoint);
var
  p1, p2: TPoint;
begin
  fValidLastHorzPos := false;
  value := validPoint(value);
  p1 := fSelFixed;
  p2 := fSelVariable;
  if (p1 = value) and (p2 = value) then exit;
  doMoveCaret(value);
  setSelVariable(value);
  fSelFixed := value;
  invalidateText(p1.y, p2.y);
  updateCaretPos;
end;

procedure tCustomKlausEdit.setSelEnd(value: tPoint);
var
  P: TPoint;
begin
  fValidLastHorzPos := false;
  value := validPoint(value);
  p := fSelFixed;
  if p <> value then begin
    fSelFixed := value;
    invalidateText(p.y, fSelFixed.y);
    updateCaretPos;
  end;
end;

procedure tCustomKlausEdit.doMoveCaret(newPos: tPoint; force: boolean = false);
begin
  if not force and (newPos = fSelVariable) then exit;
  if assigned(fOnMoveCaret) then fOnMoveCaret(self, newPos);
end;

procedure tCustomKlausEdit.moveCaretTo(pt: tPoint; selecting: boolean; retainLastHorzPos: boolean = false);
var
  tmp: tPoint;
  wasValid: boolean;
begin
  wasValid := fValidLastHorzPos;
  pt := validPoint(pt);
  if not selecting then removeSelection;
  tmp := fSelVariable;
  if fSelVariable <> pt then begin
    doMoveCaret(pt);
    setSelVariable(pt);
  end;
  if not selecting then fSelFixed := fSelVariable
  else invalidateText(tmp.y, fSelVariable.y);
  updateCaretPos;
  if retainLastHorzPos then fValidLastHorzPos := wasValid;
end;

procedure tCustomKlausEdit.moveCaretBy(delta: tPoint; selecting: boolean; retainLastHorzPos: boolean = false);
var
  i: integer;
  wasValid: boolean;
  tmp, sv, saveSV: tPoint;
begin
  wasValid := fValidLastHorzPos;
  if not selecting then removeSelection;
  tmp := fSelVariable;
  saveSV := fSelVariable;
  if delta.Y = 0 then begin
    sv := fSelVariable;
    if delta.x < 0 then for i := delta.x to -1 do sv := prevChar(sv)
    else for i := 1 to delta.x do sv := nextChar(sv);
  end else begin
    sv := point(tmp.x + delta.x, tmp.y + delta.y);
  end;
  if fSelVariable <> sv then begin
    if not retainLastHorzPos then fValidLastHorzPos := false;
    doMoveCaret(sv);
    setSelVariable(sv);
  end;
  if not selecting then fSelFixed := fSelVariable
  else invalidateText(saveSV.y, fSelVariable.y);
  if retainLastHorzPos then fValidLastHorzPos := wasValid;
  updateCaretPos;
end;

function tCustomKlausEdit.nextChar(pt: tPoint): tPoint;
var
  p: pChar;
  cnt: integer;
begin
  pt := validPoint(pt);
  if pt.y = fLines.count then
    result := point(1, pt.y)
  else begin
    getLinePtr(pt.y, p, cnt);
    if pt.x >= cnt+1 then result := point(1, pt.y+1)
    else result := point(pt.x+1, pt.y);
  end;
end;

function tCustomKlausEdit.prevChar(pt: tPoint): tPoint;
var
  p: pChar;
  cnt: integer;
begin
  pt := validPoint(pt);
  if pt.x = 1 then begin
    if pt.y = 0 then
      result := point(1, 0)
    else begin
      getLinePtr(pt.y-1, p, cnt);
      result := point(cnt+1, pt.y-1);
    end;
  end else
    result := point(pt.x-1, pt.y);
end;

procedure tCustomKlausEdit.invalidateText(startLine, endLine: integer);

  procedure exchange(var n1, n2: integer); inline;
  var tmp: integer; begin tmp := n1; n1 := n2; n2 := tmp; end;

var
  r, tr: tRect;
begin
  if HandleAllocated then begin
    tr := areaRect[keaText];
    if startLine > endLine then exchange(startLine, endLine);
    if startLine < fTopLine then startLine := fTopLine;
    r := lineRect(startLine);
    with clientRect do begin r.left := left; r.right := right; end;
    r.bottom := min(tr.bottom, r.top + (endLine-fTopLine+1)*fLineHeight);
    if not isRectEmpty(r) then invalidateRect(handle, @r, false);
  end;
end;

procedure tCustomKlausEdit.removeSelection;
var
  p1, p2: tPoint;
begin
  fValidLastHorzPos := false;
  p1 := fSelFixed;
  p2 := fSelVariable;
  fSelFixed := p2;
  if p1 <> p2 then begin
    doMoveCaret(p2, true);
    invalidateText(p1.y, p2.y);
  end;
end;

procedure tCustomKlausEdit.setSelBackColor(const value: tColor);
begin
  if fSelBackColor <> value then begin
    fSelBackColor := value;
    if selExists then invalidate;
  end;
end;

procedure tCustomKlausEdit.setSelTextColor(const value: tColor);
begin
  if fSelTextColor <> value then begin
    fSelTextColor := value;
    if selExists then invalidate;
  end;
end;

function tCustomKlausEdit.charAtPos(line, x: integer): integer;
var
  p: pChar;
  r: tRect;
  size: tSize = (cx: 0; cy: 0);
  i, len, cnt: integer;
  charPos: array of Integer = nil;
begin
  result := 0;
  r := areaRect[keaText];
  len := getLinePtr(line, p, cnt);
  if (cnt > 0) and handleAllocated then begin
    setLength(charPos, cnt);
    canvas.font := self.font;
    getTextExtentExPoint(canvas.handle, p, len, maxInt, nil, pointer(charPos), size);
    for i := 0 to cnt-1 do
      if charPos[i] > x-r.left+fScrollPos then begin
        result := i+1;
        exit;
      end;
    result := cnt+1;
  end;
end;

procedure tCustomKlausEdit.keyDown(var key: word; shift: tShiftState);
var
  newPos: tPoint;
  x, cnt: integer;
begin
  inherited;
  shift := shift * [ssShift, ssAlt, ssCtrl];
  case key of
    0: exit;
    VK_LEFT: if not (ssAlt in shift) then begin
      if ssCtrl in shift then begin
        newPos := prevWord(fSelVariable);
        moveCaretTo(newPos, ssShift in Shift);
      end else
        moveCaretBy(point(-1, 0), ssShift in shift);
      makeCharVisible(fSelVariable);
      key := 0;
    end;
    VK_RIGHT: if not (ssAlt in shift) then begin
      if ssCtrl in Shift then begin
        newPos := nextWord(fSelVariable);
        moveCaretTo(newPos, ssShift in Shift);
      end else
        moveCaretBy(point(1, 0), ssShift in shift);
      makeCharVisible(fSelVariable);
      key := 0;
    end;
    VK_UP: if not (ssAlt in shift) then begin
      x := validateLastHorzPos;
      newPos := validPoint(point(1, fSelVariable.y-1));
      newPos.x := charAtPos(newPos.y, x+areaRect[keaText].left-fScrollPos);
      moveCaretTo(newPos, ssShift in shift, true);
      if ssCtrl in shift then perform(WM_VSCROLL, SB_LINEUP, 0);
      makeCharVisible(fSelVariable);
      key := 0;
    end;
    VK_DOWN: if not (ssAlt in shift) then begin
      x := validateLastHorzPos;
      newPos := validPoint(point(1, fSelVariable.y+1));
      NewPos.x := charAtPos(newPos.y, x+areaRect[keaText].left-fScrollPos);
      moveCaretTo(newPos, ssShift in shift, true);
      if ssCtrl in shift then perform(WM_VSCROLL, SB_LINEDOWN, 0);
      makeCharVisible(fSelVariable);
      key := 0;
    end;
    VK_HOME: if not (ssAlt in shift) then begin
      if ssCtrl in shift then moveCaretTo(point(1, 0), ssShift in shift)
      else moveCaretTo(point(1, fSelVariable.y), ssShift in shift);
      makeCharVisible(fSelVariable);
      key := 0;
    end;
    VK_END:if not (ssAlt in shift) then begin
      if ssCtrl in Shift then moveCaretTo(point(1, fLines.count), ssShift in shift)
      else moveCaretTo(point(maxInt, fSelVariable.y), ssShift in shift);
      makeCharVisible(fSelVariable);
      key := 0;
    end;
    VK_PRIOR: if not (ssAlt in shift) then begin
      newPos := point(fSelVariable.x, prevPage(fSelVariable.y));
      moveCaretTo(newPos, ssShift in shift);
      makeCharVisible(fSelVariable);
      key := 0;
    end;
    VK_NEXT: if not (ssAlt in shift) then begin
      newPos := point(fSelVariable.x, nextPage(fSelVariable.y));
      moveCaretTo(newPos, ssShift in shift);
      makeCharVisible(fSelVariable);
      key := 0;
    end;
    VK_A: if shift = [ssCtrl] then begin
      selectAll;
      key := 0;
    end;
    VK_C: if shift = [ssCtrl] then begin
      copyToClipboard;
      key := 0;
    end;
    VK_V: if shift = [ssCtrl] then begin
      pasteFromClipboard;
      key := 0;
    end;
    VK_X: if shift = [ssCtrl] then begin
      cutToClipboard;
      key := 0;
    end;
    VK_BACK: if not readOnly and ((Shift = []) or (Shift = [ssCtrl])) then begin
      if selExists then
        deleteText(selStart, selEnd)
      else begin
        if Shift = [] then newPos := prevChar(selStart)
        else newPos := prevWord(selStart);
        beginEdit(kegDeleting);
        try deleteText(newPos, selStart);
        finally endEdit; end;
      end;
      makeCharVisible(fSelVariable);
      key := 0;
    end;
    VK_DELETE: if not readOnly and ((Shift = []) or (Shift = [ssCtrl])) then begin
      if SelExists then
        deleteText(selStart, selEnd)
      else begin
        if Shift = [] then newPos := nextChar(selStart)
        else newPos := nextWord(selStart);
        beginEdit(kegDeleting);
        try deleteText(selStart, newPos);
        finally endEdit; end;
      end;
      makeCharVisible(fSelVariable);
      key := 0;
    end;
    VK_Z: if not readOnly and (shift = [ssCtrl]) then begin
      if canUndo then undo;
      key := 0;
    end;
    VK_TAB: if not readOnly and (keoWantTabs in fOptions) and (shift = []) then begin
      cnt := ((selStart.x-1) div tabSize)*tabSize+tabSize-selStart.x+1;
      beginEdit(kegTyping);
      try
        if selExists then deleteText(selStart, selEnd);
        insertText(selStart, stringOfChar(#32, cnt));
      finally
        endEdit;
      end;
      key := 0;
    end;
  end;
end;

procedure tCustomKlausEdit.utf8KeyPress(var key: tUTF8Char);
var
  i: integer = 1;
  s: string = '';
begin
  inherited;
  if readOnly or ((key <> #13) and (key < #32)) then exit;
  if (key = #13) and not (keoWantReturns in fOptions) then exit;
  beginEdit(kegTyping);
  try
    if selExists then deleteText(selStart, selEnd);
    if key = #13 then begin
      if (keoAutoIndent in fOptions) and (selStart.y < fLines.count) then begin
        s := fLines[selStart.y];
        if s <> '' then begin
          while (i <= length(s)) and (s[i] = #32) do inc(i);
          s := stringOfChar(#32, i-1);
        end;
      end;
      insertText(selStart, #10+s)
    end else if key >= #32 then
      insertText(selStart, key);
  finally
    endEdit;
  end;
  makeCharVisible(selStart);
  key := #0;
end;

function tCustomKlausEdit.prevWord(pt: tPoint): tPoint;

  function calcWordLeft(pt: tPoint): integer;
  var
    s, p: pChar;
    i, cnt: integer;
    alphaNum, inWord: boolean;
  begin
    result := 0;
    inWord := false;
    getLinePtr(pt.y, s, cnt);
    p := getLinePtrAt(pt);
    p := u8SkipCharsLeft(p, s, 1);
    for i := pt.x-1 downto 1 do begin
      alphaNum := isAlphanumeric(u8Chr(p));
      if not inWord then inWord := alphaNum
      else if not alphaNum then exit(i+1);
      p := u8SkipCharsLeft(p, s, 1);
    end;
    if pt.x > 1 then result := 1;
  end;

var
  idx: Integer;
begin
  pt := validPoint(pt);
  if pt.y >= fLines.count then begin
    result.y := max(0, fLines.count-1);
    if result.y >= fLines.count then result.x := 1
    else result.x := fLines.charCount[result.y]+1;
  end else begin
    idx := calcWordLeft(pt);
    if idx = 0 then begin
      if pt.y <= 0 then
        result := point(1, 0)
      else begin
        result.y := pt.y-1;
        result.x := fLines.charCount[result.y]+1;
      end;
    end else
      result := point(idx, pt.y);
  end;
end;

function tCustomKlausEdit.nextWord(pt: tPoint): tPoint;

  function calcWordRight(pt: tPoint): integer;
  var
    p: pChar;
    i, cnt: integer;
    alphaNum, inWord: boolean;
  begin
    result := 0;
    inWord := true;
    getLinePtr(pt.y, p, cnt);
    p := getLinePtrAt(pt);
    for i := pt.x to maxInt do begin
      if p^ = #0 then break;
      alphaNum := isAlphanumeric(u8Chr(p));
      if inWord then inWord := alphaNum
      else if alphaNum then exit(i);
      p := u8SkipChars(p, 1);
    end;
    if pt.x <= cnt then result := cnt + 1;
  end;

var
  idx: integer;
begin
  pt := validPoint(pt);
  if pt.y >= fLines.count then begin
    result.y := max(0, fLines.count);
    result.x := 1;
  end else begin
    idx := calcWordRight(pt);
    if idx = 0 then result := point(1, pt.y+1)
    else result := point(idx, pt.y);
  end;
end;

function tCustomKlausEdit.areaAtCursor(x, y: integer): tKlausEditArea;
const
  la = low(tKlausEditArea);
  ha = high(tKlausEditArea);
var
  r: tRect;
  a: tKlausEditArea;
begin
  r := rect(0, 0, 0, 0);
  for a := la to ha do begin
    if a = keaNone then continue;
    r := areaRect[a];
    if ptInRect(r, point(x, y)) then exit(a);
  end;
  result := keaNone;
end;

function tCustomKlausEdit.hitTest(x, y: integer): tKlausEditHitTestInfo;
var
  r: tRect;
  line: Integer;
begin
  result.x := x;
  result.x := y;
  result.position := point(0, 0);
  if not handleAllocated then exit;
  result.area := areaAtCursor(x, y);
  if result.area <> keaText then exit;
  r := areaRect[keaText];
  line := ((y-r.top) div fLineHeight) + fTopLine;
  if (line >= fLines.count) then begin
    result.position := point(1, fLines.count);
    exit;
  end else
    result.position.y := line;
  result.position.x := charAtPos(line, x);
end;

procedure tCustomKlausEdit.mouseDown(button: tMouseButton; shift: tShiftState; x, y: integer);
var
  hti: tKlausEditHitTestInfo;
begin
  if not (csDesigning in componentState)
  and (canFocus or (getParentForm(self) = nil)) then begin
    setFocus;
    if not focused then begin mouseCapture := false; exit; end;
  end;
  if Button = mbLeft then begin
    hti := hitTest(x, y);
    if hti.area = keaText then begin
      moveCaretTo(hti.position, ssShift in shift);
      if (ssDouble in shift) and not (ssShift in shift) then selectWord(fSelVariable);
    end;
  end;
  include(fBtnDown, button);
  updateMouseScrolling(x, y);
  inherited;
end;

procedure tCustomKlausEdit.mouseMove(shift: tShiftState; x, y: integer);
var
  hti: tKlausEditHitTestInfo;
begin
  if fBtnDown = [mbLeft] then begin
    hti := hitTest(x, y);
    if hti.Area = keaText then begin
      moveCaretTo(hti.position, true);
      makeCharVisible(hti.position);
    end;
  end;
  updateCursor(x, y);
  updateMouseScrolling(x, y);
  inherited;
end;

procedure tCustomKlausEdit.mouseUp(button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  exclude(fBtnDown, button);
  updateMouseScrolling(x, y);
  inherited;
end;

procedure tCustomKlausEdit.invalidateHighlight(line: integer);
begin
  assert((line >= 0) and (line < fLines.count), 'Invalid string index');
  fLines.fItems[line].hl.valid := false;
end;

procedure tCustomKlausEdit.validateHighlight;
var
  i: integer;
  lex: tKlausLexem;
begin
  for i := 0 to fLines.fCount-1 do begin
    if fLines.fItems[i].hl.valid then continue;
    if i > 0 then lex := fLines.fItems[i-1].hl.nlex else lex := klxEOF;
    updateHighlight(i, lex, true);
  end;
end;

procedure tCustomKlausEdit.updateHighlight(line: integer; clex: tKlausLexem; autoStop: boolean);

  procedure analyzeLine(line: integer);
  var
    s, tmp: string;
    li: tKlausLexInfo;
    st: tKlausEditStyleIndex;
    chars1, chars2, pos1, pos2: integer;
  begin
    if fLines.fItems[line].hl.whole then begin
      st := tKlausEditStyleIndex(fLines.fItems[line].hl.plex);
      fLines.setFormatting(st, line, 1, maxInt)
    end else begin
      s := fLines.fItems[line].text;
      if fLines.fItems[line].hl.plex <> klxEOF then begin
        st := tKlausEditStyleIndex(fLines.fItems[line].hl.plex);
        pos1 := fLines.fItems[line].hl.ppos;
        chars1 := u8CharCount(pChar(s), pos1);
        fLines.setFormatting(st, line, 1, chars1);
      end else begin
        pos1 := 0;
        chars1 := 0;
      end;
      if fLines.fItems[line].hl.nlex <> klxEOF then begin
        pos2 := fLines.fItems[line].hl.npos;
        chars2 := u8CharCount(pChar(s), pos2)-1;
        st := tKlausEditStyleIndex(fLines.fItems[line].hl.nlex);
        fLines.setFormatting(st, line, chars2, maxInt);
      end else begin
        pos2 := length(s);
        chars2 := fLines.charCount[line];
      end;
      tmp := copy(s, pos1+1, pos2-pos1);
      (fLexParser.stream as tStringReadStream).data := tmp;
      repeat
        fLexParser.getNextLexem(li);
        if li.lexem = klxEOF then break;
        st := tKlausEditStyleIndex(li.lexem);
        fLines.setFormatting(st, line, chars1+li.pos, chars1+li.pos+u8CharCount(li.text)-1);
      until false;
    end;
  end;

var
  i, idx: integer;
  pend, nbeg, stop: boolean;
  lex: tKlausLexem;
begin
  if fLexParser = nil then exit;
  stop := false;
  for i := line to fLines.fCount-1 do begin
    fLines.fItems[i].hl.plex := clex;
    pend := fLexParser.wideLexEnds(fLines.fItems[i].text, 1, clex, fLines.fItems[i].hl.ppos);
    fLines.fItems[i].hl.whole := (clex <> klxEOF) and not pend;
    if pend then clex := klxEOF;
    if not fLines.fItems[i].hl.whole then begin
      if pend then idx := fLines.fItems[i].hl.ppos+1 else idx := 1;
      nbeg := fLexParser.wideLexBegins(fLines.fItems[i].text, idx, lex, fLines.fItems[i].hl.npos);
      if autoStop then begin
        stop := not (nbeg or ((fLines.fItems[i].hl.nlex <> klxEOF) and not nbeg));
        if i < fLines.fCount-1 then
          if fLines.fItems[i+1].hl.valid and (lex <> klxEOF)
          and (fLines.fItems[i+1].hl.plex = lex) then stop := true;
      end;
      if nbeg then begin
        fLines.fItems[i].hl.nlex := lex;
        clex := lex;
      end else
        fLines.fItems[i].hl.nlex := klxEOF;
    end else begin
      fLines.fItems[i].hl.nlex := fLines.fItems[i].hl.plex;
      stop := false;
    end;
    analyzeLine(i);
    fLines.fItems[i].hl.valid := true;
    if stop then exit;
  end;
end;

procedure tCustomKlausEdit.makeCharVisible(pt: tPoint);
var
  r: tRect;
  x, w: integer;
  dest: tPoint;
begin
  if not handleAllocated then exit;
  pt := validPoint(pt);
  r := areaRect[keaText];
  w := r.right - r.left;
  x := horzCharPos(pt) - r.left + fScrollPos;
  if x < fScrollPos then dest.x := x
  else if x > fScrollPos+w-1 then dest.x := x-w+1
  else dest.x := fScrollPos;
  if pt.y < fTopLine then dest.y := pt.y
  else if pt.y > nextPage(fTopLine, false) then dest.y := max(fTopLine, prevPage(pt.Y, false))
  else dest.y := fTopLine;
  scrollTo(dest.x, dest.y);
end;

procedure tCustomKlausEdit.WMCancelMode(var msg: tMessage);
begin
  inherited;
  fBtnDown := [];
  updateMouseScrolling(0, 0);
end;

procedure tCustomKlausEdit.notification(aComponent: tComponent; aOperation: tOperation);
begin
  inherited;
  if aOperation = opRemove then begin
    if aComponent = lineImages then lineImages := nil;
  end;
end;

procedure tCustomKlausEdit.WMGetDlgCode(var msg: tLMGetDlgCode);
begin
  inherited;
  case msg.charCode of
    VK_TAB: begin
      if keoWantTabs in fOptions then
        msg.result := msg.result or (DLGC_WANTTAB or DLGC_WANTALLKEYS)
      else
        msg.result := msg.result and not (DLGC_WANTTAB or DLGC_WANTALLKEYS);
    end;
    VK_RETURN: begin
      if keoWantReturns in fOptions then
        msg.result := msg.result or DLGC_WANTALLKEYS
      else
        msg.result := msg.result and not DLGC_WANTALLKEYS;
    end;
    VK_ESCAPE:
      msg.result := msg.result and not DLGC_WANTALLKEYS;
  end;
end;

procedure tCustomKlausEdit.CMWantSpecialKey(var msg: tCMWantSpecialKey);
begin
  case msg.charCode of
    VK_TAB: if keoWantTabs in fOptions then msg.result := 1;
    VK_RETURN: if keoWantReturns in fOptions then msg.result := 1;
    VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN: msg.result := 1;
  else
    inherited;
  end;
end;

procedure tCustomKlausEdit.updateCursor(x, y: integer);
var
  cur: tCursor;
  a: tKlausEditArea;
begin
  if csDesigning in componentState then exit;
  cur := getCursor;
  a := areaAtCursor(x, y);
  if a = keaText then fNewCursor := crIBeam else fNewCursor := crDefault;
  if cur <> getCursor then perform(CM_CURSORCHANGED, 0, 0);
end;

function tCustomKlausEdit.getCursor: tCursor;
begin
  if fNewCursor <> crDefault then result := fNewCursor
  else result := inherited getCursor;
end;

procedure tCustomKlausEdit.doLineAdd(line: integer);
begin
  invalidateHighlight(line);
  if assigned(fOnLineAdd) then fOnLineAdd(self, line);
end;

procedure tCustomKlausEdit.doLineDelete(line: integer);
begin
  invalidateHighlight(line);
  if assigned(fOnLineDelete) then fOnLineDelete(self, line);
end;

procedure tCustomKlausEdit.doSetLineFlags(line: integer; old, new: tKlausEditLineFlags);
begin
  if assigned(fOnSetLineFlags) then fOnSetLineFlags(self, line, old, new);
end;

procedure tCustomKlausEdit.doLineChange(line: integer);
begin
  invalidateHighlight(line);
  if assigned(fOnLineChange) then fOnLineChange(self, line);
end;

procedure tCustomKlausEdit.selectAll;
begin
  selStart := point(1, 0);
  selEnd := point(1, maxInt);
end;

procedure tCustomKlausEdit.invalidateAfter(line: integer);
var
  r: tRect;
begin
  if handleAllocated then begin
    r := lineRect(max(fTopLine, line));
    with clientRect do begin r.left := left; r.right := right; end;
    r.bottom := areaRect[keaText].bottom;
    invalidateRect(handle, @r, false);
  end;
end;

function tCustomKlausEdit.getSelText: string;
begin
  result := getTextRange(selStart, selEnd);
end;

function tCustomKlausEdit.getTextRange(startPos, endPos: tPoint): string;
var
  p1, p2: pChar;
begin
  result := getTextRange(startPos, endPos, p1, p2);
end;

function tCustomKlausEdit.getTextRange(startPos, endPos: tPoint; out startPtr, endPtr: pChar): string;
var
  s: string;
  i: integer;
  p: pChar;
begin
  startPos := validPoint(startPos);
  endPos := validPoint(endPos);
  if startPos = endPos then begin
    startPtr := getLinePtrAt(startPos);
    endPtr := startPtr;
    result := '';
  end else if startPos.y = endPos.y then begin
    startPtr := getLinePtrAt(startPos);
    endPtr := getLinePtrAt(endPos);
    setString(result, startPtr, endPtr-startPtr);
  end else begin
    startPtr := getLinePtrAt(startPos);
    endPtr := getLinePtrAt(endPos);
    p := pChar(fLines[startPos.y])+length(fLines[startPos.y]);
    setString(result, startPtr, p-startPtr);
    for i := startPos.y+1 to endPos.y-1 do result += #10+fLines[i];
    if endPos.y < fLines.count then begin
      p := pChar(fLines[endPos.y]);
      setString(s, p, endPtr-p);
      result := result+#10+s;
    end else
      result += #10;
  end;
end;

procedure tCustomKlausEdit.selectText(pt1, pt2: tPoint);
begin
  selStart := pt1;
  selEnd := pt2;
end;

procedure tCustomKlausEdit.selectWord(pt: tPoint);
var
  p, b, pr, pl: pChar;
  cntr, cntl: integer;
begin
  p := getLinePtrAt(pt);
  if p = nil then exit;
  if not isAlphanumeric(u8Chr(p)) then begin
    selectText(pt, point(pt.x+1, pt.y));
    exit;
  end;
  cntr := 1;
  pr := u8SkipChars(p, 1);
  while isAlphanumeric(u8Chr(pr)) do begin
    inc(cntr);
    pr := u8SkipChars(pr, 1);
  end;
  cntl := 0;
  b := pChar(fLines[pt.y]);
  pl := u8SkipCharsLeft(p, b, 1);
  while pl < p do begin
    if isAlphanumeric(u8Chr(pl)) then inc(cntl) else break;
    if pl <= b then break;
    pl := u8SkipCharsLeft(pl, b, 1);
  end;
  selectText(point(pt.x-cntl, pt.y), point(pt.x+cntr, pt.y));
end;

function pinsert(const substr, s: string; p: pChar): string;
begin
  result := s;
  system.insert(substr, result, p-pChar(s)+1);
end;

function pdelete(const s: string; p1, p2: pChar): string;
begin
  result := s;
  system.delete(result, p1-pChar(result)+1, p2-p1);
end;

function pcopy(const s: string; p1: pChar = nil; p2: pChar = nil): string;
begin
  if p1 = nil then p1 := pChar(s);
  if p2 = nil then p2 := pChar(s)+length(s);
  result := system.copy(s, p1-pChar(s)+1, p2-p1);
end;

procedure tCustomKlausEdit.insertText(pt: tPoint; const txt: string);

  function getNextPortion(const txt: string; const idx: integer; out s: string; out multiLine: boolean): integer;
  var
    p, start: PChar;
  begin
    multiLine := false;
    p := pChar(txt)+idx-1;
    start := p;
    while not (p^ in [#0, #10, #13]) do inc(p);
    setString(s, start, p-start);
    if p^ = #13 then begin inc(p); multiLine := true; end;
    if p^ = #10 then begin inc(p); multiLine := true; end;
    result := p-start+idx;
  end;

var
  newPos: tPoint;
  ptr: pChar;
  s, tail: string;
  i, idx: integer;
  multiLine, appending: boolean;
begin
  if txt = '' then exit;
  pt := validPoint(pt);
  ptr := getLinePtrAt(pt);
  fSelVarPtr := nil;
  self.beginEdit;
  try
    fLines.beginEdit;
    try
      idx := getNextPortion(txt, 1, s, multiLine);
      if not multiLine then begin
        if pt.y = fLines.fCount then begin
          fLines.insert(pt.y, s);
          doLineAdd(pt.y);
        end else begin
          fLines[pt.y] := pinsert(s, fLines[pt.y], ptr);
          doLineChange(pt.y);
        end;
        newPos := point(pt.x+u8CharCount(s), pt.y);
      end else begin
        appending := pt.y >= fLines.fCount;
        if not appending then begin
          tail := pcopy(fLines[pt.y], ptr);
          fLines[pt.y] := pcopy(fLines[pt.y], nil, ptr) + s;
          doLineChange(pt.y);
        end else begin
          tail := '';
          fLines.insert(pt.Y, s);
          doLineAdd(pt.y);
        end;
        i := pt.y+1;
        repeat
          idx := getNextPortion(txt, idx, s, multiLine);
          if multiLine then begin
            fLines.insert(i, s);
            doLineAdd(i);
          end else begin
            if (s <> '') or not appending then begin
              fLines.insert(i, s+tail);
              doLineAdd(i);
            end;
            break;
          end;
          inc(i);
        until false;
        newPos := point(u8CharCount(s)+1, i);
      end;
      invalidateAfter(pt.y);
      recordUndoInsertText(pt, newPos, txt);
      doMoveCaret(newPos);
      setSelVariable(newPos);
      fSelFixed := fSelVariable;
      updateScrollRange;
      updateCaretPos;
    finally
      fLines.EndEdit;
    end;
  finally
    self.EndEdit;
    validateHighlight;
  end;
end;

procedure tCustomKlausEdit.deleteText(pt1, pt2: tPoint);
var
  i: integer;
  p1, p2: pChar;
  txt, tail: String;
  newPos: tPoint;
begin
  pt1 := validPoint(pt1);
  pt2 := validPoint(pt2);
  if ptCompare(pt1, pt2) >= 0 then exit;
  self.beginEdit;
  try
    fLines.beginEdit;
    try
      txt := getTextRange(pt1, pt2, p1, p2);
      fSelVarPtr := nil;
      if pt1.y = pt2.y then begin
        fLines[pt1.y] := pdelete(fLines[pt1.y], p1, p2);
        doLineChange(pt1.y);
      end else begin
        if pt2.y = fLines.fCount then tail := ''
        else tail := pcopy(fLines[pt2.y], p2);
        fLines[pt1.y] := pcopy(fLines[pt1.y], nil, p1) + tail;
        doLineChange(pt1.y);
        for i := min(pt2.y, fLines.count-1) downto pt1.y+1 do begin
          recordUndoDataChange(i);
          doLineDelete(i);
          fLines.delete(i);
        end;
        i := min(pt2.y, fLines.count);
        if (i = fLines.count) and (fLines[i-1] = '') then begin
          recordUndoDataChange(i-1);
          doLineDelete(i-1);
          fLines.Delete(i-1);
        end;
      end;
      invalidateAfter(pt1.y);
      recordUndoDeleteText(pt1, pt2, txt);
      newPos := validPoint(pt1);
      doMoveCaret(newPos);
      setSelVariable(newPos);
      fSelFixed := fSelVariable;
      updateScrollRange;
      updateCaretPos;
    finally
      fLines.endEdit;
    end;
  finally
    self.endEdit;
    validateHighlight;
  end;
end;

procedure tCustomKlausEdit.indentText(pt1, pt2: tPoint; var spaces: integer);

  function leadingSpaces(const s: string): integer;
  var
    i: integer;
  begin
    result := 0;
    for i := 1 to length(s) do begin
      if s[i] <> ' ' then break;
      inc(result);
    end;
  end;

var
  s: string;
  i, cnt: integer;
begin
  if spaces = 0 then exit;
  pt1 := validPoint(pt1);
  pt2 := validPoint(pt2);
  if pt2.y >= fLines.count then dec(pt2.y)
  else if (pt1.y <> pt2.y) and (pt2.x <= 1) then dec(pt2.y);
  if pt1.y > pt2.y then exit;
  if spaces > 0 then begin
    beginEdit;
    try
      s := stringOfChar(' ', spaces);
      for i := pt1.y to pt2.y do
        insertText(point(1, i), s);
    finally
      endEdit;
    end;
  end else begin
    spaces := -spaces;
    for i := pt1.y to pt2.y do begin
      cnt := leadingSpaces(fLines[i]);
      if cnt < spaces then spaces := cnt;
    end;
    if spaces > 0 then begin
      beginEdit;
      try
        for i := pt1.y to pt2.y do
          deleteText(point(1, i), point(spaces+1, i));
      finally
        endEdit;
      end
    end;
    spaces := -spaces;
  end;
end;

procedure tCustomKlausEdit.copyToClipboard;
begin
  if selExists then begin
    clipboard.open;
    try clipboard.asText := selText;
    finally clipboard.close; end;
  end;
end;

procedure tCustomKlausEdit.cutToClipboard;
begin
  if selExists then begin
    clipboard.open;
    try clipboard.asText := selText;
    finally clipboard.close; end;
    if not readOnly then deleteText(selStart, selEnd);
    makeCharVisible(selStart);
  end;
end;

procedure tCustomKlausEdit.pasteFromClipboard;
begin
  if readOnly or not clipboard.hasFormat(CF_TEXT) then exit;
  beginEdit;
  try
    if selExists then deleteText(selStart, selEnd);
    insertText(selStart, clipboard.asText);
  finally
    endEdit;
  end;
  makeCharVisible(selStart);
end;

procedure tCustomKlausEdit.beginEdit(goal: tKlausEditGoal = kegOther);
begin
  if (fEditCount = 0) then case goal of
    kegTyping: begin
        if fUndoGroup = fUndoTyping+1 then dec(fUndoGroup);
        fUndoTyping := fUndoGroup;
        fUndoDeleting := 0;
    end;
    kegDeleting: begin
        if fUndoGroup = fUndoDeleting+1 then dec(fUndoGroup);
        fUndoTyping := 0;
        fUndoDeleting := fUndoGroup;
    end;
    else
      fUndoTyping := 0;
      fUndoDeleting := 0;
  end;
  inc(fEditCount);
  fValidLastHorzPos := false;
end;

procedure tCustomKlausEdit.endEdit;
begin
  if fEditCount > 0 then begin
    dec(fEditCount);
    if fEditCount = 0 then inc(fUndoGroup);
  end;
end;

procedure tCustomKlausEdit.beginUndo;
begin
  inc(fUndoing);
end;

procedure tCustomKlausEdit.endUndo;
begin
  if fUndoing > 0 then dec(fUndoing);
end;

procedure tCustomKlausEdit.disposeUndoData(p: pKlausEditUndoData);
begin
  if p^.data <> nil then disposeStringsData(p^.data);
  dispose(P);
end;

procedure tCustomKlausEdit.clearUndo;
var
  i: integer;
begin
  if fUndo <> nil then begin
    for i := fUndo.count-1 downto 0 do
      disposeUndoData(pKlausEditUndoData(fUndo[i]));
    freeAndNil(fUndo);
  end;
  fUndoGroup := 10;
  fUndoTyping := 0;
  fUndoDeleting := 0;
end;

procedure tCustomKlausEdit.setUndoLimit(value: integer);
begin
  if value <= 0 then value := 0
  else value := max(value, klausEditMinUndoLimit);
  if fUndoLimit <> value then begin
    fUndoLimit := value;
    checkUndoLimit;
  end;
end;

procedure tCustomKlausEdit.createCaret;
begin
  destroyCaret;
  if not (csDesigning in componentState) and handleAllocated then begin
    LCLIntf.createCaret(handle, 0, 2, fLineHeight-2);
    LCLIntf.setCaretRespondToFocus(handle, false);
  end;
end;

procedure tCustomKlausEdit.destroyCaret;
begin
  fCaretVisible := false;
  if handleAllocated then
    LCLIntf.destroyCaret(handle);
end;

procedure tCustomKlausEdit.hideCaret;
begin
  if handleAllocated then
    if fCaretVisible then begin
      LCLIntf.hideCaret(handle);
      fCaretVisible := false;
    end;
end;

procedure tCustomKlausEdit.showCaret;
begin
  if handleAllocated then
    if not fCaretVisible then begin
      LCLIntf.showCaret(handle);
      fCaretVisible := true;
    end;
end;

procedure tCustomKlausEdit.checkUndoLimit;
var
  group: integer;
begin
  if (fUndo = nil) or (fUndoLimit <= 0) then exit;
  while fUndo.count > fUndoLimit do begin
    group := pKlausEditUndoData(fUndo[0])^.groupIndex;
    while pKlausEditUndoData(fUndo[0])^.groupIndex = group do begin
      disposeUndoData(pKlausEditUndoData(fUndo[0]));
      fUndo.delete(0);
    end;
  end;
end;

procedure tCustomKlausEdit.recordUndoInsertText(pt1, pt2: tPoint; txt: string);
var
  p: pKlausEditUndoData;
begin
  if fUndoing > 0 then exit;
  p := new(pKlausEditUndoData);
  p^.operation := kuoInsert;
  p^.start := pt1;
  p^.finish := pt2;
  p^.text := txt;
  p^.dataIndex := -1;
  p^.data := nil;
  p^.groupIndex := fUndoGroup;
  if fUndo = nil then fUndo := tList.create;
  fUndo.add(p);
  checkUndoLimit;
end;

procedure tCustomKlausEdit.recordUndoDeleteText(pt1, pt2: tPoint; txt: String);
var
  p: pKlausEditUndoData;
begin
  if fUndoing > 0 then exit;
  p := new(pKlausEditUndoData);
  p^.operation := kuoDelete;
  p^.start := pt1;
  p^.finish := pt2;
  p^.text := txt;
  p^.dataIndex := -1;
  p^.data := nil;
  p^.groupIndex := fUndoGroup;
  if fUndo = nil then fUndo := tList.Create;
  fUndo.add(p);
  checkUndoLimit;
end;

procedure tCustomKlausEdit.recordUndoDataChange(line: integer);
var
  p: pKlausEditUndoData;
begin
  if fUndoing > 0 then exit;
  p := new(pKlausEditUndoData);
  p^.operation := kuoDataChange;
  p^.start := point(0, 0);
  p^.finish := point(0, 0);
  p^.text := '';
  p^.dataIndex := line;
  p^.data := allocStringsData;
  copyStringsData(fLines.data[line], p^.data, kcoSave);
  p^.flags := fLines.flags[line];
  p^.groupIndex := fUndoGroup;
  if fUndo = nil then fUndo := tList.Create;
  fUndo.add(p);
  checkUndoLimit;
end;

function tCustomKlausEdit.canUndo: boolean;
begin
  result := fUndo <> nil;
  if result then result := fUndo.count > 0;
end;

procedure tCustomKlausEdit.undo;

  procedure doUndo(var pt: tPoint);
  var
    p: pKlausEditUndoData;
    data: pointer;
  begin
    p := pKlausEditUndoData(fUndo[fUndo.count-1]);
    try
      beginUndo;
      try
        case p^.operation of
          kuoInsert: begin
            deleteText(p^.start, p^.finish);
            pt := p^.start;
          end;
          kuoDelete: begin
            insertText(p^.start, p^.text);
            pt := p^.start;
          end;
          kuoDataChange: begin
            data := fLines.data[p^.dataIndex];
            copyStringsData(p^.data, data, kcoRestore);
            fLines.flags[p^.dataIndex] := p^.flags;
            invalidateText(p^.dataIndex, p^.dataIndex+1);
          end;
        end;
      finally
        endUndo;
      end;
    finally
      disposeUndoData(p);
      fUndo.delete(fUndo.count-1);
    end;
  end;

var
  pt: tPoint;
  group: integer;
begin
  if not canUndo then exit;
  fUndoTyping := 0;
  fUndoDeleting := 0;
  pt := fSelVariable;
  group := pKlausEditUndoData(fUndo[fUndo.count-1])^.groupIndex;
  while fUndo.count > 0 do begin
    if pKlausEditUndoData(fUndo[fUndo.count-1])^.groupIndex <> group then break;
    doUndo(pt);
  end;
  makeCharVisible(pt);
end;

procedure tCustomKlausEdit.replaceText(pt1, pt2: tPoint; const replaceWith: string);
begin
  beginEdit;
  try
    deleteText(pt1, pt2);
    insertText(pt1, replaceWith);
  finally
    endEdit;
  end;
  makeCharVisible(selStart);
end;

function tCustomKlausEdit.search(start: tPoint; txt: string; matchCase: boolean; out pt1, pt2: tPoint): boolean;
var
  s: string;
  i, idx: integer;
begin
  result := false;
  start := validPoint(start);
  if not matchCase then txt := u8Upper(txt);
  idx := getLinePtrAt(start)-pChar(fLines[start.y])+1;
  for i := start.y to lines.count-1 do begin
    s := lines[i];
    if not matchCase then s := u8Upper(s);
    idx := pos(txt, s, idx);
    if idx > 0 then begin
      pt1.y := i;
      pt1.x := u8CharCount(pChar(s), idx-1)+1;
      pt2 := point(pt1.x + u8CharCount(txt), i);
      result := true;
      break;
    end;
    idx := 1;
  end;
end;

function tCustomKlausEdit.validPoint(pt: tPoint): tPoint;
var
  cnt: Integer;
begin
  if pt.y < 0 then exit(point(1, 0));
  cnt := fLines.count;
  result.y := min(pt.y, cnt);
  if result.y = cnt then result.x := 1
  else result.x := min(max(1, pt.x), fLines.charCount[result.y]+1);
end;

function tCustomKlausEdit.horzCharPos(pt: tPoint): integer;
var
  p, p2: pChar;
  size: tSize = (cx: 0; cy: 0);
begin
  if not handleAllocated then exit(0);
  result := areaRect[keaText].left-fScrollPos;
  pt := validPoint(pt);
  if (pt.x <= 1) or (pt.y >= fLines.count) then exit;
  p := pChar(fLines[pt.y]);
  p2 := getLinePtrAt(pt);
  if p = p2 then exit;
  canvas.font := self.font;
  getTextExtentPoint(canvas.handle, p, p2-p, size);
  result += size.cx;
end;

function tCustomKlausEdit.isAlphanumeric(c: u8Char): boolean;
begin
  result := pos(c, klausEditAlphanumerics) > 0;
end;

function tCustomKlausEdit.lineRect(line: integer; shrink: boolean = true): tRect;
var
  tr: tRect;
begin
  tr := areaRect[keaText];
  result := tr;
  result.top += (line-fTopLine)*fLineHeight;
  result.bottom := result.top+fLineHeight;
  if shrink then result.bottom := min(result.bottom, tr.bottom);
end;

end.
