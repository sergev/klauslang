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
  tKlausPaintBoxCanvasLink = class;

type
  tKlausPaintBoxCanvasLink = class(tKlausCanvasLink)
    private
      fTmpStr: string;
      fTmpInt: array[0..9] of integer;
      fTmpPoints: tKlausPointArray;
      fTmpObj: tObject;
      fPaintBox: tKlausPaintBox;
    private
      procedure syncCreatePaintBox;
      procedure syncDestroyPaintBox;
      procedure syncSetSize;
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
    protected
      procedure doInvalidate; override;
      function  getCanvas: tCanvas; override;
    public
      constructor create(aRuntime: tKlausRuntime; const cap: string); override;
      destructor  destroy; override;
      procedure setSize(w, h: integer); override;
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
      procedure draw(x, y: integer; picture: tKlausPictureLink); override;
  end;

type
  tKlausPaintBoxPictureLink = class(tKlausPictureLink)
    private
      fPicture: tPicture;
      fTmpStr: string;
      fTmpInt: array[0..9] of integer;
      fTmpObj: tObject;

      procedure syncCreatePicture;
      procedure syncDestroyPicture;
      procedure syncLoadFromFile;
      procedure syncSaveToFile;
      procedure syncGetSize;
      procedure syncCopyFrom;
    protected
      function getPicture: tPicture; override;
    public
      constructor create(aRuntime: tKlausRuntime); override;
      destructor  destroy; override;
      procedure loadFromFile(const fileName: string); override;
      procedure saveToFile(const fileName: string); override;
      function  getSize: tPoint; override;
      procedure copyFrom(src: tObject; x1, y1, x2, y2: integer); override;
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

{ tKlausPaintBoxCanvas }

constructor tKlausPaintBoxCanvasLink.create(aRuntime: tKlausRuntime; const cap: string);
begin
  inherited create(aRuntime, cap);
  if not assigned(createWindowMethod) then raise eKlausError.create(ercCanvasUnavailable, 0, 0);
  fTmpStr := cap;
  runtime.synchronize(@syncCreatePaintBox);
end;

destructor tKlausPaintBoxCanvasLink.destroy;
begin
  runtime.synchronize(@syncDestroyPaintBox);
  inherited destroy;
end;

procedure tKlausPaintBoxCanvasLink.syncCreatePaintBox;
begin
  fPaintBox := createWindowMethod(fTmpStr, self) as tKlausPaintBox;
  fPaintBox.content.canvas.font := defaultFont;
end;

procedure tKlausPaintBoxCanvasLink.syncDestroyPaintBox;
begin
  destroyWindowMethod(fPaintBox);
end;

procedure tKlausPaintBoxCanvasLink.doInvalidate;
begin
  runtime.synchronize(@fPaintBox.invalidateAll);
end;

function tKlausPaintBoxCanvasLink.getCanvas: tCanvas;
begin
  result := fPaintBox.content.canvas;
end;

procedure tKlausPaintBoxCanvasLink.setSize(w, h: integer);
begin
  fTmpInt[0] := w;
  fTmpInt[1] := h;
  runtime.synchronize(@syncSetSize);
end;

procedure tKlausPaintBoxCanvasLink.syncSetSize;
begin
  fPaintBox.setSize(fTmpInt[0], fTmpInt[1]);
end;

procedure tKlausPaintBoxCanvasLink.setPenProps(what: tKlausPenProps; color: tColor; width: integer; style: tPenStyle);
begin
  fTmpInt[0] := integer(what);
  fTmpInt[1] := integer(color);
  fTmpInt[2] := integer(width);
  fTmpInt[3] := integer(style);
  runtime.synchronize(@syncSetPenProps);
end;

procedure tKlausPaintBoxCanvasLink.syncSetPenProps;
var
  what: tKlausPenProps;
begin
  what := tKlausPenProps(fTmpInt[0]);
  with fPaintBox.content.canvas do begin
    if kppColor in what then pen.color := tColor(fTmpInt[1]);
    if kppWidth in what then pen.width := fTmpInt[2];
    if kppStyle in what then pen.style := tPenStyle(fTmpInt[3]);
  end;
end;

procedure tKlausPaintBoxCanvasLink.setBrushProps(what: tKlausBrushProps; color: tColor; style: tBrushStyle);
begin
  fTmpInt[0] := integer(what);
  fTmpInt[1] := integer(color);
  fTmpInt[2] := integer(style);
  runtime.synchronize(@syncSetBrushProps);
end;

procedure tKlausPaintBoxCanvasLink.syncSetBrushProps;
var
  what: tKlausBrushProps;
begin
  what := tKlausBrushProps(fTmpInt[0]);
  with fPaintBox.content.canvas do begin
    if kbpColor in what then brush.color := tColor(fTmpInt[1]);
    if kbpStyle in what then brush.style := tBrushStyle(fTmpInt[2]);
  end;
end;

procedure tKlausPaintBoxCanvasLink.setFontProps(what: tKlausFontProps; const name: string; size: integer; style: tFontStyles; color: tColor);
begin
  fTmpInt[0] := integer(what);
  fTmpStr := name;
  fTmpInt[1] := size;
  fTmpInt[2] := integer(style);
  fTmpInt[3] := integer(color);
  runtime.synchronize(@syncSetFontProps);
end;

procedure tKlausPaintBoxCanvasLink.syncSetFontProps;
var
  what: tKlausFontProps;
begin
  what := tKlausFontProps(fTmpInt[0]);
  with fPaintBox.content.canvas do begin
    if kfpName in what then begin
      if fTmpStr <> '' then font.name := fTmpStr
      else font.name := defaultFont.name;
    end;
    if kfpSize in what then begin
      if fTmpInt[1] <> 0 then font.size := fTmpInt[1]
      else font.size := defaultFont.size;
    end;
    if kfpStyle in what then font.style := tFontStyles(fTmpInt[2]);
    if kfpColor in what then font.color := tColor(fTmpInt[3]);
  end;
end;

procedure tKlausPaintBoxCanvasLink.ellipse(x1, y1, x2, y2: integer);
begin
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  runtime.synchronize(@syncEllipse);
end;

procedure tKlausPaintBoxCanvasLink.syncEllipse;
begin
  fPaintBox.content.canvas.ellipse(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3]);
  invalidate;
end;

procedure tKlausPaintBoxCanvasLink.arc(x1, y1, x2, y2, start, finish: integer);
begin
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  fTmpInt[4] := start;
  fTmpInt[5] := finish;
  runtime.synchronize(@syncArc);
end;

procedure tKlausPaintBoxCanvasLink.syncArc;
begin
  fPaintBox.content.canvas.arc(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3], fTmpInt[4], fTmpInt[5]);
  invalidate;
end;

procedure tKlausPaintBoxCanvasLink.line(x1, y1, x2, y2: integer);
begin
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  runtime.synchronize(@syncLine);
end;

procedure tKlausPaintBoxCanvasLink.syncLine;
begin
  fPaintBox.content.canvas.line(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3]);
  invalidate;
end;

procedure tKlausPaintBoxCanvasLink.rectangle(x1, y1, x2, y2: integer);
begin
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  runtime.synchronize(@syncRectangle);
end;

procedure tKlausPaintBoxCanvasLink.syncRectangle;
begin
  fPaintBox.content.canvas.rectangle(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3]);
  invalidate;
end;

procedure tKlausPaintBoxCanvasLink.roundRect(x1, y1, x2, y2, rx, ry: integer);
begin
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  fTmpInt[4] := rx;
  fTmpInt[5] := ry;
  runtime.synchronize(@syncRoundRect);
end;

procedure tKlausPaintBoxCanvasLink.syncRoundRect;
begin
  fPaintBox.content.canvas.roundRect(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3], fTmpInt[4], fTmpInt[5]);
  invalidate;
end;

function tKlausPaintBoxCanvasLink.getPoint(x, y: integer): tColor;
begin
  fTmpInt[0] := x;
  fTmpInt[1] := y;
  runtime.synchronize(@syncGetPoint);
  result := fTmpInt[2];
end;

procedure tKlausPaintBoxCanvasLink.syncGetPoint;
begin
  fTmpInt[2] := fPaintBox.content.canvas.pixels[fTmpInt[0], fTmpInt[1]];
end;

function tKlausPaintBoxCanvasLink.setPoint(x, y: integer; color: tColor): tColor;
begin
  fTmpInt[0] := x;
  fTmpInt[1] := y;
  fTmpInt[2] := color;
  runtime.synchronize(@syncSetPoint);
  result := fTmpInt[3];
end;

procedure tKlausPaintBoxCanvasLink.syncSetPoint;
begin
  with fPaintBox.content.canvas do begin
    fTmpInt[3] := pixels[fTmpInt[0], fTmpInt[1]];
    pixels[fTmpInt[0], fTmpInt[1]] := fTmpInt[2];
  end;
  invalidate;
end;

procedure tKlausPaintBoxCanvasLink.sector(x1, y1, x2, y2, start, finish: integer);
begin
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  fTmpInt[4] := start;
  fTmpInt[5] := finish;
  runtime.synchronize(@syncSector);
end;

procedure tKlausPaintBoxCanvasLink.syncSector;
begin
  fPaintBox.content.canvas.radialPie(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3], fTmpInt[4], fTmpInt[5]);
  invalidate;
end;

procedure tKlausPaintBoxCanvasLink.polyLine(points: tKlausPointArray);
begin
  fTmpPoints := points;
  runtime.synchronize(@syncPolyLine);
  fTmpPoints := nil;
end;

procedure tKlausPaintBoxCanvasLink.syncPolyLine;
begin
  fPaintBox.content.canvas.polyLine(fTmpPoints);
  invalidate;
end;

procedure tKlausPaintBoxCanvasLink.polygone(points: tKlausPointArray);
begin
  fTmpPoints := points;
  runtime.synchronize(@syncPolygone);
  fTmpPoints := nil;
end;

procedure tKlausPaintBoxCanvasLink.syncPolygone;
begin
  fPaintBox.content.canvas.polygon(fTmpPoints);
  invalidate;
end;

function tKlausPaintBoxCanvasLink.textOut(x, y: integer; const s: string): tPoint;
begin
  fTmpStr := s;
  fTmpInt[0] := x;
  fTmpInt[1] := y;
  runtime.synchronize(@syncTextOut);
  result.x := fTmpInt[2];
  result.y := fTmpInt[3];
end;

procedure tKlausPaintBoxCanvasLink.syncTextOut;
var
  sz: tSize;
begin
  sz := fPaintBox.content.canvas.textExtent(fTmpStr);
  fTmpInt[2] := sz.cx;
  fTmpInt[3] := sz.cy;
  fPaintBox.content.canvas.textOut(fTmpInt[0], fTmpInt[1], fTmpStr);
  invalidate;
end;

function tKlausPaintBoxCanvasLink.textSize(const s: string): tPoint;
begin
  fTmpStr := s;
  runtime.synchronize(@syncTextSize);
  result.x := fTmpInt[0];
  result.y := fTmpInt[1];
end;

procedure tKlausPaintBoxCanvasLink.syncTextSize;
var
  sz: tSize;
begin
  sz := fPaintBox.content.canvas.textExtent(fTmpStr);
  fTmpInt[0] := sz.cx;
  fTmpInt[1] := sz.cy;
end;

procedure tKlausPaintBoxCanvasLink.clipRect(x1, y1, x2, y2: integer);
begin
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  runtime.synchronize(@syncClipRect);
end;

procedure tKlausPaintBoxCanvasLink.syncClipRect;
begin
  with fPaintBox.content.canvas do begin
    clipping := true;
    clipRect := rect(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3]);
  end;
end;

procedure tKlausPaintBoxCanvasLink.setClipping(val: boolean);
begin
  fTmpInt[0] := integer(val);
  runtime.synchronize(@syncSetClipping);
end;

procedure tKlausPaintBoxCanvasLink.syncSetClipping;
begin
  fPaintBox.content.canvas.clipping := fTmpInt[0] <> 0;
end;

procedure tKlausPaintBoxCanvasLink.draw(x, y: integer; picture: tKlausPictureLink);
begin
  fTmpInt[0] := x;
  fTmpInt[1] := y;
  fTmpObj := picture;
  runtime.synchronize(@syncDraw);
end;

procedure tKlausPaintBoxCanvasLink.syncDraw;
var
  g: tGraphic;
begin
  g := (fTmpObj as tKlausPictureLink).picture.graphic;
  fPaintBox.content.canvas.draw(fTmpInt[0], fTmpInt[1], g);
  invalidate;
end;

procedure tKlausPaintBoxCanvasLink.chord(x1, y1, x2, y2, start, finish: integer);
begin
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  fTmpInt[4] := start;
  fTmpInt[5] := finish;
  runtime.synchronize(@syncChord);
end;

procedure tKlausPaintBoxCanvasLink.syncChord;
begin
  fPaintBox.content.canvas.chord(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3], fTmpInt[4], fTmpInt[5]);
  invalidate;
end;

{ tKlausPaintBoxPictureLink }

constructor tKlausPaintBoxPictureLink.create(aRuntime: tKlausRuntime);
begin
  inherited create(aRuntime);
  runtime.synchronize(@syncCreatePicture);
end;

destructor tKlausPaintBoxPictureLink.destroy;
begin
  runtime.synchronize(@syncDestroyPicture);
  inherited destroy;
end;

procedure tKlausPaintBoxPictureLink.syncCreatePicture;
begin
  fPicture := tPicture.create;
end;

procedure tKlausPaintBoxPictureLink.syncDestroyPicture;
begin
  freeAndNil(fPicture);
end;

function tKlausPaintBoxPictureLink.getPicture: tPicture;
begin
  result := fPicture;
end;

procedure tKlausPaintBoxPictureLink.loadFromFile(const fileName: string);
begin
  fTmpStr := fileName;
  runtime.synchronize(@syncLoadFromFile);
end;

procedure tKlausPaintBoxPictureLink.syncLoadFromFile;
begin
  fPicture.loadFromFile(fTmpStr);
end;

procedure tKlausPaintBoxPictureLink.saveToFile(const fileName: string);
begin
  fTmpStr := fileName;
  runtime.synchronize(@syncSaveToFile);
end;

procedure tKlausPaintBoxPictureLink.syncSaveToFile;
begin
  fPicture.saveToFile(fTmpStr);
end;

function tKlausPaintBoxPictureLink.getSize: tPoint;
begin
  runtime.synchronize(@syncGetSize);
  result.x := fTmpInt[0];
  result.y := fTmpInt[1];
end;

procedure tKlausPaintBoxPictureLink.syncGetSize;
begin
  fTmpInt[0] := fPicture.width;
  fTmpInt[1] := fPicture.height;
end;

procedure tKlausPaintBoxPictureLink.copyFrom(src: tObject; x1, y1, x2, y2: integer);
begin
  fTmpObj := src;
  fTmpInt[0] := x1;
  fTmpInt[1] := y1;
  fTmpInt[2] := x2;
  fTmpInt[3] := y2;
  runtime.synchronize(@syncCopyFrom);
end;

procedure tKlausPaintBoxPictureLink.syncCopyFrom;
var
  cnv: tCanvas;
  g: tGraphic;
  r: tRect;
begin
  r := rect(fTmpInt[0], fTmpInt[1], fTmpInt[2], fTmpInt[3]);
  fPicture := tPicture.create;
  fPicture.bitmap := tBitmap.create;
  fPicture.bitmap.setSize(r.width, r.height);
  if fTmpObj is tKlausCanvasLink then begin
    cnv := (fTmpObj as tKlausCanvasLink).canvas;
    fPicture.bitmap.canvas.copyRect(rect(0, 0, r.width, r.height), cnv, r);
  end else if fTmpObj is tKlausPictureLink then begin
    g := (fTmpObj as tKlausPictureLink).picture.graphic;
    if g <> nil then fPicture.bitmap.canvas.draw(-r.left, -r.top, g);
  end;
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
  invalidateAll;
end;

procedure tKlausPaintBox.updateSize;
begin
  content.setSize(fSize.cx, fSize.cy);
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

