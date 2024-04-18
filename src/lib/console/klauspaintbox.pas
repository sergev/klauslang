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

  { tKlausPaintBoxCanvasLink }

  tKlausPaintBoxCanvasLink = class(tKlausCanvasLink)
    private
      fTmpStr: string;
      fTmpInt: array[0..9] of integer;
      fPaintBox: tKlausPaintBox;
    private
      procedure syncCreatePaintBox;
      procedure syncDestroyPaintBox;
      procedure syncSetSize;
      procedure syncSetPenProps;
      procedure syncSetBrushProps;
      procedure syncEllipse;
      procedure syncArc;
      procedure syncChord;
      procedure syncLine;
      procedure syncRectangle;
      procedure syncRoundRect;
    protected
      procedure doInvalidate; override;
    public
      constructor create(aRuntime: tKlausRuntime; const cap: string); override;
      destructor  destroy; override;
      procedure setSize(w, h: integer); override;
      procedure setPenProps(what: tKlausPenProps; color: tColor; width: integer; style: tPenStyle); override;
      procedure setBrushProps(what: tKlausBrushProps; color: tColor; style: tBrushStyle); override;
      procedure ellipse(x1, y1, x2, y2: integer); override;
      procedure arc(x1, y1, x2, y2, start, finish: integer); override;
      procedure chord(x1, y1, x2, y2, start, finish: integer); override;
      procedure line(x1, y1, x2, y2: integer); override;
      procedure rectangle(x1, y1, x2, y2: integer); override;
      procedure roundRect(x1, y1, x2, y2, rx, ry: integer); override;
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
end;

procedure tKlausPaintBoxCanvasLink.syncDestroyPaintBox;
begin
  destroyWindowMethod(fPaintBox);
end;

procedure tKlausPaintBoxCanvasLink.doInvalidate;
begin
  runtime.synchronize(@fPaintBox.invalidateAll);
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

