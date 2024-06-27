unit KlausPaintBox;

{$mode ObjFPC}{$H+}

interface

uses
  Messages, LMessages, SysUtils, Classes, Graphics, Controls, Dialogs, Types, LCLType,
  LCLIntf, Forms, CustomTimer, U8, GraphUtils, KlausErr, KlausSrc;

const
  KM_Invalidate = $7FFB;

type
  tKlausPaintBox = class;
  tKlausCustomCanvasLink = class;
  tKlausPaintBoxLink = class;
  tKlausPictureLink = class;

type
  // Обработчик создания окна графического вывода
  tKlausCanvasCreateWindowMethod = function(const cap: string; link: tKlausCanvasLink): tObject of object;

  // Обработчик уничтожения окна графического вывода
  tKlausCanvasDestroyWindowMethod = procedure(const win: tObject) of object;

type
  tKlausCustomCanvasLink = class(tKlausCanvasLink)
    public
      class var defaultFontName: string;
      class var defaultFontSize: integer;
    private
      fTmpStr: string;
      fTmpInt: array[0..9] of integer;
      fTmpPoints: tKlausPointArray;
      fTmpObj: tObject;

      procedure syncSetPenProps;
      procedure syncSetBrushProps;
      procedure syncSetFontProps;
      procedure syncEllipse;
      procedure syncArc;
      procedure syncChord;
      procedure syncLine;
      procedure syncRectangle;
      procedure syncRoundRect;
      procedure syncGetPoint;
      procedure syncSetPoint;
      procedure syncSector;
      procedure syncPolyLine;
      procedure syncPolygone;
      procedure syncTextOut;
      procedure syncTextSize;
      procedure syncClipRect;
      procedure syncSetClipping;
      procedure syncDraw;
      procedure syncSaveToFile;
    protected
      procedure canvasRequired; virtual;
    public
      procedure setPenProps(what: tKlausPenProps; color: tColor; width: integer; style: tPenStyle); override;
      procedure setBrushProps(what: tKlausBrushProps; color: tColor; style: tBrushStyle); override;
      procedure setFontProps(what: tKlausFontProps; const name: string; size: integer; style: tFontStyles; color: tColor); override;
      function  getPoint(x, y: integer): tColor; override;
      function  setPoint(x, y: integer; color: tColor): tColor; override;
      procedure ellipse(x1, y1, x2, y2: integer); override;
      procedure arc(x1, y1, x2, y2, start, finish: integer); override;
      procedure sector(x1, y1, x2, y2, start, finish: integer); override;
      procedure chord(x1, y1, x2, y2, start, finish: integer); override;
      procedure line(x1, y1, x2, y2: integer); override;
      procedure polyLine(points: tKlausPointArray); override;
      procedure rectangle(x1, y1, x2, y2: integer); override;
      procedure roundRect(x1, y1, x2, y2, rx, ry: integer); override;
      procedure polygone(points: tKlausPointArray); override;
      function  textOut(x, y: integer; const s: string): tPoint; override;
      function  textSize(const s: string): tPoint; override;
      procedure clipRect(x1, y1, x2, y2: integer); override;
      procedure setClipping(val: boolean); override;
      procedure draw(x, y: integer; picture: tKlausCanvasLink); override;
      procedure copyFrom(source: tKlausCanvasLink; x1, y1, x2, y2: integer); override;
      procedure loadFromFile(const fileName: string); override;
      procedure saveToFile(const fileName: string); override;
  end;

type
  tKlausEventBuffer = array[0..klausEventBufferSize-1] of tKlausEvent;

type
  tKlausEventQueue = class(tObject)
    private
      fBuffer: tKlausEventBuffer;
      fHead, fTail: integer;

      procedure purge;
    protected
      function  getCount: integer;
    public
      property count: integer read getCount;

      constructor create;
      function put(const evt: tKlausEvent): boolean;
      function update(const evt: tKlausEvent): boolean;
      function get(out evt: tKlausEvent): boolean;
      function peek(idx: integer = 0): tKlausEvent;
  end;

type
  tKlausPaintBoxEventQueue = class(tObject, iKlausEventQueue)
    private
      fLatch: tRTLCriticalSection;
      fLink: tKlausPaintBoxLink;
      fWhat: tKlausEventTypes;
      fQueue: tKlausEventQueue;

      procedure paintBoxKeyDown(sender: tObject; var key: word; shift: tShiftState);
      procedure paintBoxKeyUp(sender: tObject; var key: word; shift: tShiftState);
      procedure paintBoxKeyPress(sender: tObject; var key: tUTF8Char);
      procedure paintBoxMouseEnter(sender: tObject);
      procedure paintBoxMouseLeave(sender: tObject);
      procedure paintBoxMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
      procedure paintBoxMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
      procedure paintBoxMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
      procedure paintBoxMouseWheel(sender: tObject; shift: tShiftState; delta: integer; pos: tPoint; var handled: boolean);
    protected
      function _AddRef: Longint; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
      function _Release: Longint; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
      function QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} IID: TGUID; out Obj): HResult; virtual; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    public
      constructor create(aLink: tKlausPaintBoxLink);
      destructor  destroy; override;
      procedure lock;
      procedure unlock;
      procedure eventSubscribe(const what: tKlausEventTypes);
      function  eventExists: boolean;
      function  eventGet(out evt: tKlausEvent): boolean;
      function  eventCount: integer;
      function  eventPeek(index: integer = 0): tKlausEvent;
  end;

type
  tKlausPaintBoxLink = class(tKlausCustomCanvasLink, iKlausEventQueue)
    public
      class var createWindowMethod: tKlausCanvasCreateWindowMethod;
      class var destroyWindowMethod: tKlausCanvasDestroyWindowMethod;
    private
      fPaintBox: tKlausPaintBox;
      fEventQueue: tKlausPaintBoxEventQueue;

      procedure syncCreatePaintBox;
      procedure syncDestroyPaintBox;
      procedure syncGetSize;
      procedure syncSetSize;
    protected
      procedure doInvalidate; override;
      function  getCanvas: tCanvas; override;
    public
      property eventQueue: tKlausPaintBoxEventQueue read fEventQueue implements iKlausEventQueue;

      constructor create(aRuntime: tKlausRuntime; const cap: string = ''); override;
      destructor  destroy; override;
      function  getSize: tSize; override;
      function  setSize(val: tSize): tSize; override;
  end;

type
  tKlausPictureLink = class(tKlausCustomCanvasLink)
    private
      fPicture: tPicture;

      procedure syncCreatePicture;
      procedure syncDestroyPicture;
      procedure syncLoadFromFile;
      procedure syncSaveToFile;
      procedure syncGetSize;
      procedure syncSetSize;
      procedure syncCopyFrom;
    protected
      procedure canvasRequired; override;
      procedure doInvalidate; override;
      function  getCanvas: tCanvas; override;
    public
      property picture: tPicture read fPicture;

      constructor create(aRuntime: tKlausRuntime; const cap: string = ''); override;
      destructor  destroy; override;
      function  getSize: tSize; override;
      function  setSize(val: tSize): tSize; override;
      procedure loadFromFile(const fileName: string); override;
      procedure saveToFile(const fileName: string); override;
      procedure copyFrom(source: tKlausCanvasLink; x1, y1, x2, y2: integer); override;
  end;

type
  tKlausPaintBox = class(tCustomControl)
    private
      fContent: tBitmap;
      fSize: tSize;
    protected
      procedure createWnd; override;
      procedure paint; override;
      procedure updateSize;
    public
      property content: tBitmap read fContent;

      constructor create(aOwner: tComponent); override;
      destructor  destroy; override;
      procedure invalidateAll;
      procedure setSize(w, h: integer);
  end;

implementation

uses
  KlausUnitSystem;

resourcestring
  strGraphicWindow = 'графическое окно';
  strKlausPaintBoxLink = 'Графическое окно';
  strKlausPictureLink = 'Изображение';

{ tKlausCustomCanvasLink }

procedure tKlausCustomCanvasLink.setPenProps(what: tKlausPenProps; color: tColor; width: integer; style: tPenStyle);
begin
  canvasRequired;
  fTmpInt[0] := integer(what);
  fTmpInt[1] := integer(color);
  fTmpInt[2] := integer(width);
  fTmpInt[3] := integer(style);
  runtime.synchronize(@syncSetPenProps);
end;

procedure tKlausCustomCanvasLink.syncSetPenProps;
var
  what: tKlausPenProps;
begin
  what := tKlausPenProps(fTmpInt[0]);
  with canvas do begin
    if kppColor in what then pen.color := tColor(fTmpInt[1]);
    if kppWidth in what then pen.width := fTmpInt[2];
    if kppStyle in what then pen.style := tPenStyle(fTmpInt[3]);
  end;
end;

procedure tKlausCustomCanvasLink.setBrushProps(what: tKlausBrushProps; color: tColor; style: tBrushStyle);
begin
  canvasRequired;
  fTmpInt[0] := integer(what);
  fTmpInt[1] := integer(color);
  fTmpInt[2] := integer(style);
  runtime.synchronize(@syncSetBrushProps);
end;

procedure tKlausCustomCanvasLink.syncSetBrushProps;
var
  what: tKlausBrushProps;
begin
  what := tKlausBrushProps(fTmpInt[0]);
  with canvas do begin
    if kbpColor in what then brush.color := tColor(fTmpInt[1]);
    if kbpStyle in what then brush.style := tBrushStyle(fTmpInt[2]);
  end;
end;

procedure tKlausCustomCanvasLink.setFontProps(what: tKlausFontProps; const name: string; size: integer; style: tFontStyles; color: tColor);
begin
  canvasRequired;
  fTmpInt[0] := integer(what);
  fTmpStr := name;
  fTmpInt[1] := size;
  fTmpInt[2] := integer(style);
  fTmpInt[3] := integer(color);
  runtime.synchronize(@syncSetFontProps);
end;

procedure tKlausCustomCanvasLink.syncSetFontProps;
var
  what: tKlausFontProps;
begin
  what := tKlausFontProps(fTmpInt[0]);
  with canvas do begin
    if kfpName in what then begin
      if fTmpStr <> '' then font.name := fTmpStr
      else font.name := defaultFontName;
    end;
    if kfpSize in what then begin
      if fTmpInt[1] <> 0 then font.size := fTmpInt[1]
      else font.size := defaultFontSize;
    end;
    if kfpStyle in what then font.style := tFontStyles(fTmpInt[2]);
    if kfpColor in what then font.color := tColor(fTmpInt[3]);
  end;
end;

procedure tKlausCustomCanvasLink.ellipse(x1, y1, x2, y2: integer);
begin
  canvasRequired;
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  runtime.synchronize(@syncEllipse);
end;

procedure tKlausCustomCanvasLink.syncEllipse;
begin
  canvas.ellipse(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3]);
  invalidate;
end;

procedure tKlausCustomCanvasLink.arc(x1, y1, x2, y2, start, finish: integer);
begin
  canvasRequired;
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  fTmpInt[4] := start;
  fTmpInt[5] := finish;
  runtime.synchronize(@syncArc);
end;

procedure tKlausCustomCanvasLink.syncArc;
begin
  canvas.arc(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3], fTmpInt[4], fTmpInt[5]);
  invalidate;
end;

procedure tKlausCustomCanvasLink.line(x1, y1, x2, y2: integer);
begin
  canvasRequired;
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  runtime.synchronize(@syncLine);
end;

procedure tKlausCustomCanvasLink.syncLine;
begin
  canvas.line(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3]);
  invalidate;
end;

procedure tKlausCustomCanvasLink.rectangle(x1, y1, x2, y2: integer);
begin
  canvasRequired;
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  runtime.synchronize(@syncRectangle);
end;

procedure tKlausCustomCanvasLink.syncRectangle;
begin
  canvas.rectangle(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3]);
  invalidate;
end;

procedure tKlausCustomCanvasLink.roundRect(x1, y1, x2, y2, rx, ry: integer);
begin
  canvasRequired;
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  fTmpInt[4] := rx;
  fTmpInt[5] := ry;
  runtime.synchronize(@syncRoundRect);
end;

procedure tKlausCustomCanvasLink.syncRoundRect;
begin
  canvas.roundRect(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3], fTmpInt[4], fTmpInt[5]);
  invalidate;
end;

function tKlausCustomCanvasLink.getPoint(x, y: integer): tColor;
begin
  canvasRequired;
  fTmpInt[0] := x;
  fTmpInt[1] := y;
  runtime.synchronize(@syncGetPoint);
  result := fTmpInt[2];
end;

procedure tKlausCustomCanvasLink.syncGetPoint;
begin
  fTmpInt[2] := canvas.pixels[fTmpInt[0], fTmpInt[1]];
end;

function tKlausCustomCanvasLink.setPoint(x, y: integer; color: tColor): tColor;
begin
  canvasRequired;
  fTmpInt[0] := x;
  fTmpInt[1] := y;
  fTmpInt[2] := color;
  runtime.synchronize(@syncSetPoint);
  result := fTmpInt[3];
end;

procedure tKlausCustomCanvasLink.syncSetPoint;
begin
  with canvas do begin
    fTmpInt[3] := pixels[fTmpInt[0], fTmpInt[1]];
    pixels[fTmpInt[0], fTmpInt[1]] := fTmpInt[2];
  end;
  invalidate;
end;

procedure tKlausCustomCanvasLink.sector(x1, y1, x2, y2, start, finish: integer);
begin
  canvasRequired;
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  fTmpInt[4] := start;
  fTmpInt[5] := finish;
  runtime.synchronize(@syncSector);
end;

procedure tKlausCustomCanvasLink.syncSector;
begin
  canvas.radialPie(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3], fTmpInt[4], fTmpInt[5]);
  invalidate;
end;

procedure tKlausCustomCanvasLink.polyLine(points: tKlausPointArray);
begin
  canvasRequired;
  fTmpPoints := points;
  runtime.synchronize(@syncPolyLine);
  fTmpPoints := nil;
end;

procedure tKlausCustomCanvasLink.syncPolyLine;
begin
  canvas.polyLine(fTmpPoints);
  invalidate;
end;

procedure tKlausCustomCanvasLink.polygone(points: tKlausPointArray);
begin
  canvasRequired;
  fTmpPoints := points;
  runtime.synchronize(@syncPolygone);
  fTmpPoints := nil;
end;

procedure tKlausCustomCanvasLink.syncPolygone;
begin
  canvas.polygon(fTmpPoints);
  invalidate;
end;

function tKlausCustomCanvasLink.textOut(x, y: integer; const s: string): tPoint;
begin
  canvasRequired;
  fTmpStr := s;
  fTmpInt[0] := x;
  fTmpInt[1] := y;
  runtime.synchronize(@syncTextOut);
  result.x := fTmpInt[2];
  result.y := fTmpInt[3];
end;

procedure tKlausCustomCanvasLink.syncTextOut;
var
  sz: tSize;
begin
  sz := canvas.textExtent(fTmpStr);
  fTmpInt[2] := sz.cx;
  fTmpInt[3] := sz.cy;
  canvas.textOut(fTmpInt[0], fTmpInt[1], fTmpStr);
  invalidate;
end;

function tKlausCustomCanvasLink.textSize(const s: string): tPoint;
begin
  canvasRequired;
  fTmpStr := s;
  runtime.synchronize(@syncTextSize);
  result.x := fTmpInt[0];
  result.y := fTmpInt[1];
end;

procedure tKlausCustomCanvasLink.syncTextSize;
var
  sz: tSize;
begin
  sz := canvas.textExtent(fTmpStr);
  fTmpInt[0] := sz.cx;
  fTmpInt[1] := sz.cy;
end;

procedure tKlausCustomCanvasLink.clipRect(x1, y1, x2, y2: integer);
begin
  canvasRequired;
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  runtime.synchronize(@syncClipRect);
end;

procedure tKlausCustomCanvasLink.syncClipRect;
begin
  with canvas do begin
    clipping := true;
    clipRect := rect(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3]);
  end;
end;

procedure tKlausCustomCanvasLink.setClipping(val: boolean);
begin
  canvasRequired;
  fTmpInt[0] := integer(val);
  runtime.synchronize(@syncSetClipping);
end;

procedure tKlausCustomCanvasLink.syncSetClipping;
begin
  canvas.clipping := fTmpInt[0] <> 0;
end;

procedure tKlausCustomCanvasLink.draw(x, y: integer; picture: tKlausCanvasLink);
begin
  canvasRequired;
  fTmpInt[0] := x;
  fTmpInt[1] := y;
  fTmpObj := picture;
  runtime.synchronize(@syncDraw);
end;

procedure tKlausCustomCanvasLink.syncDraw;
var
  sz: tSize;
  x, y: integer;
begin
  x := fTmpInt[0];
  y := fTmpInt[1];
  if fTmpObj is tKlausPictureLink then
    canvas.draw(x, y, (fTmpObj as tKlausPictureLink).picture.graphic)
  else with fTmpObj as tKlausCanvasLink do begin
    sz := getSize;
    self.canvas.copyRect(rect(x, y, x+sz.cx, y+sz.cy), canvas, rect(0, 0, sz.cx, sz.cy));
  end;
  invalidate;
end;

procedure tKlausCustomCanvasLink.copyFrom(source: tKlausCanvasLink; x1, y1, x2, y2: integer);
begin
  raise eKlausError.createFmt(ercGraphicOperationNA, zeroSrcPt, [strGraphicWindow]);
end;

procedure tKlausCustomCanvasLink.loadFromFile(const fileName: string);
begin
  raise eKlausError.createFmt(ercGraphicOperationNA, zeroSrcPt, [strGraphicWindow]);
end;

procedure tKlausCustomCanvasLink.saveToFile(const fileName: string);
begin
  fTmpStr := fileName;
  runtime.synchronize(@syncSaveToFile);
end;

procedure tKlausCustomCanvasLink.syncSaveToFile;
var
  r: tRect;
  p: tPicture;
begin
  p := tPicture.create;
  try
    r := rect(0, 0, canvas.width, canvas.height);
    p.bitmap.setSize(r.width, r.height);
    p.bitmap.canvas.copyRect(r, canvas, r);
    p.saveToFile(fTmpStr);
  finally
    freeAndNil(p);
  end;
end;

procedure tKlausCustomCanvasLink.canvasRequired;
begin
end;

procedure tKlausCustomCanvasLink.chord(x1, y1, x2, y2, start, finish: integer);
begin
  canvasRequired;
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  fTmpInt[4] := start;
  fTmpInt[5] := finish;
  runtime.synchronize(@syncChord);
end;

procedure tKlausCustomCanvasLink.syncChord;
begin
  canvas.chord(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3], fTmpInt[4], fTmpInt[5]);
  invalidate;
end;

{ tKlausPaintBoxLink }

constructor tKlausPaintBoxLink.create(aRuntime: tKlausRuntime; const cap: string);
begin
  inherited create(aRuntime, cap);
  fEventQueue := tKlausPaintBoxEventQueue.create(self);
  if not assigned(createWindowMethod) then raise eKlausError.create(ercCanvasUnavailable, zeroSrcPt);
  fTmpStr := cap;
  runtime.synchronize(@syncCreatePaintBox);
end;

destructor tKlausPaintBoxLink.destroy;
begin
  runtime.synchronize(@syncDestroyPaintBox);
  freeAndNil(fEventQueue);
  inherited destroy;
end;

procedure tKlausPaintBoxLink.syncCreatePaintBox;
begin
  fPaintBox := createWindowMethod(fTmpStr, self) as tKlausPaintBox;
  with canvas.font do begin
    name := defaultFontName;
    size := defaultFontSize;
  end;
  fPaintBox.onKeyDown := @fEventQueue.paintBoxKeyDown;
  fPaintBox.onKeyUp := @fEventQueue.paintBoxKeyUp;
  fPaintBox.onUTF8KeyPress := @fEventQueue.paintBoxKeyPress;
  fPaintBox.onMouseEnter := @fEventQueue.paintBoxMouseEnter;
  fPaintBox.onMouseLeave := @fEventQueue.paintBoxMouseLeave;
  fPaintBox.onMouseMove := @fEventQueue.paintBoxMouseMove;
  fPaintBox.onMouseDown := @fEventQueue.paintBoxMouseDown;
  fPaintBox.onMouseUp := @fEventQueue.paintBoxMouseUp;
  fPaintBox.onMouseWheel := @fEventQueue.paintBoxMouseWheel;
end;

procedure tKlausPaintBoxLink.syncDestroyPaintBox;
begin
  destroyWindowMethod(fPaintBox);
end;

procedure tKlausPaintBoxLink.doInvalidate;
begin
  runtime.synchronize(@fPaintBox.invalidateAll);
end;

function tKlausPaintBoxLink.getCanvas: tCanvas;
begin
  result := fPaintBox.content.canvas;
end;

function tKlausPaintBoxLink.getSize: tSize;
begin
  runtime.synchronize(@syncGetSize);
  result.cx := fTmpInt[0];
  result.cy := fTmpInt[1];
end;

procedure tKlausPaintBoxLink.syncGetSize;
begin
  fTmpInt[0] := fPaintBox.fSize.cx;
  fTmpInt[1] := fPaintBox.fSize.cy;
end;

function tKlausPaintBoxLink.setSize(val: tSize): tSize;
begin
  fTmpInt[0] := val.cx;
  fTmpInt[1] := val.cy;
  runtime.synchronize(@syncSetSize);
  result.cx := fTmpInt[2];
  result.cy := fTmpint[3];
end;

procedure tKlausPaintBoxLink.syncSetSize;
begin
  fTmpInt[2] := fPaintBox.fSize.cx;
  fTmpInt[3] := fPaintBox.fSize.cy;
  fPaintBox.setSize(fTmpInt[0], fTmpInt[1]);
end;

{ tKlausPictureLink }

constructor tKlausPictureLink.create(aRuntime: tKlausRuntime; const cap: string = '');
begin
  inherited create(aRuntime);
  runtime.synchronize(@syncCreatePicture);
end;

destructor tKlausPictureLink.destroy;
begin
  runtime.synchronize(@syncDestroyPicture);
  inherited destroy;
end;

procedure tKlausPictureLink.syncCreatePicture;
begin
  fPicture := tPicture.create;
end;

procedure tKlausPictureLink.syncDestroyPicture;
begin
  freeAndNil(fPicture);
end;

procedure tKlausPictureLink.loadFromFile(const fileName: string);
begin
  fTmpStr := fileName;
  runtime.synchronize(@syncLoadFromFile);
end;

procedure tKlausPictureLink.syncLoadFromFile;
begin
  fPicture.loadFromFile(fTmpStr);
end;

procedure tKlausPictureLink.saveToFile(const fileName: string);
begin
  fTmpStr := fileName;
  runtime.synchronize(@syncSaveToFile);
end;

procedure tKlausPictureLink.syncSaveToFile;
begin
  fPicture.saveToFile(fTmpStr);
end;

function tKlausPictureLink.getSize: tSize;
begin
  runtime.synchronize(@syncGetSize);
  result.cx := fTmpInt[0];
  result.cy := fTmpInt[1];
end;

procedure tKlausPictureLink.syncGetSize;
begin
  fTmpInt[0] := fPicture.width;
  fTmpInt[1] := fPicture.height;
end;

function tKlausPictureLink.setSize(val: tSize): tSize;
begin
  canvasRequired;
  fTmpInt[0] := val.cx;
  fTmpInt[1] := val.cy;
  runtime.synchronize(@syncSetSize);
  result.cx := fTmpInt[2];
  result.cy := fTmpint[3];
end;

procedure tKlausPictureLink.syncSetSize;
begin
  fTmpInt[2] := fPicture.width;
  fTmpInt[3] := fPicture.height;
  picture.bitmap.setSize(fTmpInt[0], fTmpInt[1]);
end;

procedure tKlausPictureLink.canvasRequired;
begin
  if assigned(picture.graphic) and not (picture.graphic is tBitmap) then
    raise eKlausError.createFmt(ercGraphicOperationNA, zeroSrcPt, [picture.graphic.mimeType])
    at get_caller_addr(get_frame);
end;

procedure tKlausPictureLink.doInvalidate;
begin
end;

function tKlausPictureLink.getCanvas: tCanvas;
begin
  canvasRequired;
  result := fPicture.bitmap.canvas;
end;

procedure tKlausPictureLink.copyFrom(source: tKlausCanvasLink; x1, y1, x2, y2: integer);
begin
  canvasRequired;
  fTmpObj := source;
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  runtime.synchronize(@syncCopyFrom);
end;

procedure tKlausPictureLink.syncCopyFrom;
var
  cnv: tCanvas;
  g: tGraphic;
  r: tRect;
begin
  r := rect(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3]);
  fPicture.clear;
  fPicture.bitmap.setSize(r.width, r.height);
  if fTmpObj is tKlausPictureLink then begin
    g := (fTmpObj as tKlausPictureLink).picture.graphic;
    if g <> nil then canvas.draw(-r.left, -r.top, g);
  end else if fTmpObj is tKlausCanvasLink then begin
    cnv := (fTmpObj as tKlausCanvasLink).canvas;
    canvas.copyRect(rect(0, 0, r.width, r.height), cnv, r);
  end
end;

{ tKlausPaintBox }

constructor tKlausPaintBox.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  fSize.cx := klausDefaultCanvasWidth;
  fSize.cy := klausDefaultCanvasHeight;
  fContent := tBitmap.create;
  fContent.setSize(fSize.cx, fSize.cy);
  with fContent.canvas.pen do begin
    cosmetic := false;
    color := clWhite;
    width := 1;
    mode := pmCopy;
    style := psSolid;
  end;
  with fContent.canvas.brush do begin
    color := clGray;
    style := bsSolid;
  end;
end;

destructor tKlausPaintBox.destroy;
begin
  freeAndNil(fContent);
  inherited destroy;
end;

procedure tKlausPaintBox.createWnd;
begin
  inherited createWnd;
  invalidateAll;
end;

procedure tKlausPaintBox.invalidateAll;
begin
  updateSize;
  invalidate;
end;

procedure tKlausPaintBox.setSize(w, h: integer);
begin
  fSize.cx := w;
  fSize.cy := h;
  with content do
    if (width <> w) or (height <> h) then setSize(w, h);
  invalidateAll;
end;

procedure tKlausPaintBox.updateSize;
begin
  if fSize.cx <> clientWidth then clientWidth := fSize.cx;
  if fSize.cy <> clientHeight then clientHeight := fSize.cy;
end;

procedure tKlausPaintBox.paint;
var
  r: tRect;
begin
  r := clientRect;
  canvas.draw(r.left, r.top, fContent);
end;

{ tKlausEventQueue }

constructor tKlausEventQueue.create;
begin
  inherited;
  fHead := 0;
  fTail := 0;
end;

function tKlausEventQueue.getCount: integer;
begin
  result := fTail-fHead;
end;

procedure tKlausEventQueue.purge;
begin
  if fHead > 0 then begin
    if fTail > fHead then
      move(fBuffer[fHead], fBuffer[0], (fTail-fHead)*sizeOf(tKlausEvent));
    fTail := fTail - fHead;
    fHead := 0;
  end;
end;

function tKlausEventQueue.put(const evt: tKlausEvent): boolean;
begin
  if fTail > high(fBuffer) then begin
    purge;
    if fTail > high(fBuffer) then exit(false);
  end;
  fBuffer[fTail] := evt;
  fTail += 1;
  result := true;
end;

function tKlausEventQueue.update(const evt: tKlausEvent): boolean;
var
  t: integer;
begin
  t := fTail-1;
  if t >= fHead then with fBuffer[t] do begin
    if (what = evt.what) and (code = evt.code) and (shift = evt.shift) then begin
      point := evt.point;
      result := true;
    end else
      result := put(evt);
  end else
    result := put(evt);
end;

function tKlausEventQueue.get(out evt: tKlausEvent): boolean;
begin
  result := fHead < fTail;
  if result then begin
    evt := fBuffer[fHead];
    fHead += 1;
    if fHead >= fTail then begin
      fHead := 0;
      fTail := 0;
    end;
  end;
end;

function tKlausEventQueue.peek(idx: integer): tKlausEvent;
begin
  if (idx < 0) or (idx >= count) then raise eKlausError.createFmt(ercInvalidListIndex, zeroSrcPt, [idx]);
  result := fBuffer[fHead + idx];
end;

{ tKlausPaintBoxEventQueue }

constructor tKlausPaintBoxEventQueue.create(aLink: tKlausPaintBoxLink);
begin
  inherited create;
  fLink := aLink;
  initCriticalSection(fLatch);
  fWhat := [];
  fQueue := nil;
end;

destructor tKlausPaintBoxEventQueue.destroy;
begin
  freeAndNil(fQueue);
  doneCriticalSection(fLatch);
  inherited destroy;
end;

function tKlausPaintBoxEventQueue._AddRef: Longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  result := -1;
end;


function tKlausPaintBoxEventQueue._Release: Longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  result := -1;
end;


function tKlausPaintBoxEventQueue.QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} IID: TGUID; out Obj): HResult; {$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  if getInterface(IID, obj) then result := 0
  else result := hResult($80004002);
end;

procedure tKlausPaintBoxEventQueue.paintBoxKeyDown(sender: tObject; var key: word; shift: tShiftState);
var
  evt: tKlausEvent;
begin
  lock;
  try
    if not assigned(fQueue) then exit;
    if ketKeyDown in fWhat then begin
      evt.what := ketKeyDown;
      evt.code := key;
      evt.shift := shift * klausValidKeyStates;
      evt.point.x := 0;
      evt.point.y := 0;
      fQueue.put(evt);
    end;
  finally
    unlock;
  end;
end;

procedure tKlausPaintBoxEventQueue.paintBoxKeyUp(sender: tObject; var key: word; shift: tShiftState);
var
  evt: tKlausEvent;
begin
  lock;
  try
    if not assigned(fQueue) then exit;
    if ketKeyUp in fWhat then begin
      evt.what := ketKeyUp;
      evt.code := key;
      evt.shift := shift * klausValidKeyStates;
      evt.point.x := 0;
      evt.point.y := 0;
      fQueue.put(evt);
    end;
  finally
    unlock;
  end;
end;

procedure tKlausPaintBoxEventQueue.paintBoxKeyPress(sender: tObject; var key: tUTF8Char);
var
  evt: tKlausEvent;
begin
  lock;
  try
    if not assigned(fQueue) then exit;
    if ketChar in fWhat then begin
      evt.what := ketChar;
      evt.code := u8ToUni(key);
      evt.shift := [];
      evt.point.x := 0;
      evt.point.y := 0;
      fQueue.put(evt);
    end;
  finally
    unlock;
  end;
end;

procedure tKlausPaintBoxEventQueue.paintBoxMouseEnter(sender: tObject);
var
  evt: tKlausEvent;
begin
  lock;
  try
    if not assigned(fQueue) then exit;
    if ketMouseEnter in fWhat then begin
      evt.what := ketMouseEnter;
      evt.code := 0;
      evt.shift := [];
      evt.point.x := 0;
      evt.point.y := 0;
      fQueue.put(evt);
    end;
  finally
    unlock;
  end;
end;

procedure tKlausPaintBoxEventQueue.paintBoxMouseLeave(sender: tObject);
var
  evt: tKlausEvent;
begin
  lock;
  try
    if not assigned(fQueue) then exit;
    if ketMouseLeave in fWhat then begin
      evt.what := ketMouseLeave;
      evt.code := 0;
      evt.shift := [];
      evt.point.x := 0;
      evt.point.y := 0;
      fQueue.put(evt);
    end;
  finally
    unlock;
  end;
end;

procedure tKlausPaintBoxEventQueue.paintBoxMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
var
  evt: tKlausEvent;
begin
  lock;
  try
    if not assigned(fQueue) then exit;
    if ketMouseMove in fWhat then begin
      evt.what := ketMouseMove;
      evt.code := 0;
      evt.shift := shift * klausValidKeyStates;
      evt.point.x := x;
      evt.point.y := y;
      fQueue.update(evt);
    end;
  finally
    unlock;
  end;
end;

const
  mouseButtonFlag: array[tMouseButton] of integer = (
    klausConst_MouseBtnLeft, klausConst_MouseBtnRight, klausConst_MouseBtnMiddle, 0, 0);

procedure tKlausPaintBoxEventQueue.paintBoxMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
var
  evt: tKlausEvent;
begin
  lock;
  try
    if not assigned(fQueue) then exit;
    if ketMouseDown in fWhat then begin
      evt.what := ketMouseDown;
      evt.code := mouseButtonFlag[button];
      evt.shift := shift * klausValidKeyStates;
      evt.point.x := x;
      evt.point.y := y;
      fQueue.put(evt);
    end;
  finally
    unlock;
  end;
end;

procedure tKlausPaintBoxEventQueue.paintBoxMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
var
  evt: tKlausEvent;
begin
  lock;
  try
    if not assigned(fQueue) then exit;
    if ketMouseUp in fWhat then begin
      evt.what := ketMouseUp;
      evt.code := mouseButtonFlag[button];
      evt.shift := shift * klausValidKeyStates;
      evt.point.x := x;
      evt.point.y := y;
      fQueue.put(evt);
    end;
  finally
    unlock;
  end;
end;

procedure tKlausPaintBoxEventQueue.paintBoxMouseWheel(sender: tObject; shift: tShiftState; delta: integer; pos: tPoint; var handled: boolean);
var
  evt: tKlausEvent;
begin
  lock;
  try
    if not assigned(fQueue) then exit;
    if ketMouseWheel in fWhat then begin
      evt.what := ketMouseWheel;
      evt.code := delta;
      evt.shift := shift * klausValidKeyStates;
      evt.point.x := pos.x;
      evt.point.y := pos.y;
      fQueue.put(evt);
    end;
    handled := true;
  finally
    unlock;
  end;
end;

procedure tKlausPaintBoxEventQueue.lock;
begin
  enterCriticalSection(fLatch);
end;

procedure tKlausPaintBoxEventQueue.unlock;
begin
  leaveCriticalSection(fLatch);
end;

procedure tKlausPaintBoxEventQueue.eventSubscribe(const what: tKlausEventTypes);
begin
  lock;
  try
    fWhat := what;
    if fWhat = [] then freeAndNil(fQueue)
    else if fQueue = nil then fQueue := tKlausEventQueue.create;
  finally
    unlock;
  end;
end;

function tKlausPaintBoxEventQueue.eventExists: boolean;
begin
  lock;
  try
    if fQueue = nil then result := false
    else result := fQueue.count > 0;
  finally
    unlock;
  end;
end;

function tKlausPaintBoxEventQueue.eventGet(out evt: tKlausEvent): boolean;
begin
  lock;
  try
    if fQueue = nil then result := false
    else result := fQueue.get(evt);
  finally
    unlock;
  end;
end;

function tKlausPaintBoxEventQueue.eventCount: integer;
begin
  lock;
  try
    if fQueue = nil then result := 0
    else result := fQueue.count;
  finally
    unlock;
  end;
end;

function tKlausPaintBoxEventQueue.eventPeek(index: integer = 0): tKlausEvent;
begin
  lock;
  try
    if fQueue = nil then raise eKlausError.createFmt(ercInvalidListIndex, zeroSrcPt, [index]);
    result := fQueue.peek(index);
  finally
    unlock;
  end;
end;

initialization
  tKlausObjects.registerKlausObject(tKlausPaintBoxLink, strKlausPaintBoxLink);
  tKlausObjects.registerKlausObject(tKlausPictureLink, strKlausPictureLink);
end.

