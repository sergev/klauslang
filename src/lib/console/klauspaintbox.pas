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
  tKlausPaintBoxLink = class(tKlausCustomCanvasLink)
    public
      class var createWindowMethod: tKlausCanvasCreateWindowMethod;
      class var destroyWindowMethod: tKlausCanvasDestroyWindowMethod;
    private
      fPaintBox: tKlausPaintBox;

      procedure syncCreatePaintBox;
      procedure syncDestroyPaintBox;
      procedure syncGetSize;
      procedure syncSetSize;
    protected
      procedure doInvalidate; override;
      function  getCanvas: tCanvas; override;
    public
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

resourcestring
  strGraphicWindow = 'графическое окно';

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
  raise eKlausError.createFmt(ercGraphicOperationNA, 0, 0, [strGraphicWindow]);
end;

procedure tKlausCustomCanvasLink.loadFromFile(const fileName: string);
begin
  raise eKlausError.createFmt(ercGraphicOperationNA, 0, 0, [strGraphicWindow]);
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
  if not assigned(createWindowMethod) then raise eKlausError.create(ercCanvasUnavailable, 0, 0);
  fTmpStr := cap;
  runtime.synchronize(@syncCreatePaintBox);
end;

destructor tKlausPaintBoxLink.destroy;
begin
  runtime.synchronize(@syncDestroyPaintBox);
  inherited destroy;
end;

procedure tKlausPaintBoxLink.syncCreatePaintBox;
begin
  fPaintBox := createWindowMethod(fTmpStr, self) as tKlausPaintBox;
  with canvas.font do begin
    name := defaultFontName;
    size := defaultFontSize;
  end;
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
    raise eKlausError.createFmt(ercGraphicOperationNA, 0, 0, [picture.graphic.mimeType])
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

end.

