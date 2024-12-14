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

unit KlausDoer_Mouse;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, KlausLex, KlausDef, KlausSyn, KlausErr, Controls, Forms,
  Graphics, LCLType, KlausDoer, FpJson, BGRABitmap, BGRABitmapTypes, BGRASVG;

const
  klausDoerName_Mouse = 'Мышка';

type
  tKlausDoerMouse = class;
  tKlausMouseCell = class;
  tKlausMouseSetting = class;
  tKlausMouseView = class;
  tKlausMouseViewColors = class;

type
  tKlausMouseDirection = (kmdHere, kmdLeft, kmdUp, kmdRight, kmdDown);
  tKlausMouseDirections = set of kmdLeft..kmdDown;

const
  kmdNone = kmdHere;

type
  tKlausMouseCell = class(tPersistent)
    private
      fOwner: tKlausMouseSetting;
      fHorz: integer;
      fVert: integer;
      fWalls: tKlausMouseDirections;
      fPainted: boolean;
      fArrow: tKlausMouseDirection;
      fText: string;

      function  getWall(idx: tKlausMouseDirection): boolean;
      function  getWalls: tKlausMouseDirections;
      procedure setArrow(val: tKlausMouseDirection);
      procedure setPainted(val: boolean);
      procedure setText(val: string);
      procedure setWall(idx: tKlausMouseDirection; val: boolean);
      procedure setWalls(val: tKlausMouseDirections);
    protected
      procedure updating;
      procedure updated;
      procedure assignTo(dest: tPersistent); override;
    public
      property owner: tKlausMouseSetting read fOwner;
      property horz: integer read fHorz;
      property vert: integer read fVert;
      property wall[idx: tKlausMouseDirection]: boolean read getWall write setWall;
      property walls: tKlausMouseDirections read getWalls write setWalls;
      property painted: boolean read fPainted write setPainted;
      property text: string read fText write setText;
      property arrow: tKlausMouseDirection read fArrow write setArrow;

      constructor create(aOwner: tKlausMouseSetting; aHorz, aVert: integer);
      function  toJson: tJsonData;
      procedure fromJson(data: tJsonData);
      procedure toggleArrow(dir: tKlausMouseDirection);
  end;

type
  tKlausMouseSetting = class(tKlausDoerSetting)
    private
      fWidth: integer;
      fHeight: integer;
      fCells: array of array of tKlausMouseCell;
      fMouseX: integer;
      fMouseY: integer;
      fMouseDir: tKlausMouseDirection;

      function  getCells(x, y: integer): tKlausMouseCell;
      procedure setHeight(val: integer);
      procedure setMouseDir(val: tKlausMouseDirection);
      procedure setMouseX(val: integer);
      procedure setMouseY(val: integer);
      procedure setWidth(val: integer);
    protected
      procedure assignTo(dest: tPersistent); override;
    public
      property width: integer read fWidth write setWidth;
      property height: integer read fHeight write setHeight;
      property cells[x, y: integer]: tKlausMouseCell read getCells; default;
      property mouseX: integer read fMouseX write setMouseX;
      property mouseY: integer read fMouseY write setMouseY;
      property mouseDir: tKlausMouseDirection read fMouseDir write setMouseDir;

      constructor create(aWidth, aHeight: integer);
      destructor  destroy; override;
      function  toJson: tJsonData; override;
      procedure fromJson(data: tJsonData); override;
  end;

type
  tKlausDoerMouse = class(tKlausDoer)
    public
      class function stdUnitName: string; override;
      class function createSetting: tKlausDoerSetting; override;
      class function createView(aOwner: tComponent): tKlausDoerView; override;
  end;

type
  tKlausMouseViewColors = class(tPersistent)
    private
      fOwner: tKlausMouseView;
      fUpdateCount: integer;
      fCell: tColor;
      fCellPainted: tColor;
      fWallSet: tColor;
      fWallUnset: tColor;
      fCellArrow: tColor;
      fCellText: tColor;

      procedure setCell(val: tColor);
      procedure setCellArrow(val: tColor);
      procedure setCellPainted(val: tColor);
      procedure setCellText(val: tColor);
      procedure setWallSet(val: tColor);
      procedure setWallUnset(val: tColor);
    protected
      procedure assignTo(dest: tPersistent); override;
      procedure setDefaults; virtual;
    public
      property owner: tKlausMouseView read fOwner;

      constructor create(aOwner: tKlausMouseView);
      procedure updating;
      procedure updated;
    published
      property cell: tColor read fCell write setCell default $a4cd8c;
      property cellPainted: tColor read fCellPainted write setCellPainted default clGray;
      property wallSet: tColor read fWallSet write setWallSet default clBlack;
      property wallUnset: tColor read fWallUnset write setWallUnset default $9fc787;
      property cellArrow: tColor read fCellArrow write setCellArrow default clWhite;
      property cellText: tColor read fCellText write setCellText default clWhite;
  end;

type
  tKlausMouseImageCache = class(tObject)
    private
      fSize: integer;
      fFit: tRect;
      fWidth, fHeight: integer;
      fImg: array[kmdLeft..kmdDown] of array of tBGRABitmap;

      function getImg(dir: tKlausMouseDirection; idx: integer): tBGRABitmap;
    public
      property img[dir: tKlausMouseDirection; idx: integer]: tBGRABitmap read getImg; default;

      constructor create;
      destructor  destroy; override;
      procedure clear;
      procedure rebuild(aSize: integer);
      procedure draw(canvas: tCanvas; cell: tRect; dir: tKlausMouseDirection; idx: integer);
  end;

type
  tKlausMouseView = class(tKlausDoerView)
    private
      fOrigin: tPoint;
      fCellSize: integer;
      fFocusX: integer;
      fFocusY: integer;
      fColors: tKlausMouseViewColors;
      fImg: tKlausMouseImageCache;

      function  getSetting: tKlausMouseSetting;
      procedure setColors(val: tKlausMouseViewColors);
      procedure setFocusX(val: integer);
      procedure setFocusY(val: integer);
      procedure setSetting(val: tKlausMouseSetting);
    protected
      procedure paint; override;
      procedure setSetting(aSetting: tKlausDoerSetting); override;
      procedure setReadOnly(val: boolean); override;
      procedure settingChange(sender: tObject); virtual;
      procedure doOnResize; override;
      procedure mouseDown(button: tMouseButton; shift: tShiftState; x, y: integer); override;
      procedure keyDown(var key: word; shift: tShiftState); override;
      procedure UTF8KeyPress(var key: tUTF8Char); override;
    public
      property focusX: integer read fFocusX write setFocusX;
      property focusY: integer read fFocusY write setFocusY;
      property setting: tKlausMouseSetting read getSetting write setSetting;

      class function doerClass: tKlausDoerClass; override;

      constructor create(aOwner: tComponent); override;
      destructor  destroy; override;
      function cellRect(x, y: integer): tRect;
      function cellFromPoint(x, y: integer): tPoint;
    published
      property color;
      property colors: tKlausMouseViewColors read fColors write setColors;
      property tabStop default true;
  end;

implementation

{$R *.rc}

uses
  Types, Math, Clipbrd, U8, KlausUnitSystem;

const
  mouseImageInfo: record
    count: integer;
    size: tSize;
    fit: tRect;
    resName: string;
  end = (
    count: 6;
    size: (cx: 185; cy: 514);
    fit: (left: 0; top: 0; right: 186; bottom: 301);
    resName: 'klaus_doer_mouse%.2d_svg';
  );

var
  mouseSVG: array of tBGRASVG = nil;

{ Globals }

function mouseDirToInt(md: tKlausMouseDirection): integer;
begin
  result := integer(md);
end;

function intToMouseDir(md: integer): tKlausMouseDirection;
begin
  if md < integer(low(result)) then result := low(result)
  else if md > integer(high(result)) then result := high(result)
  else result := tKlausMouseDirection(md);
end;

function mouseDirsToInt(md: tKlausMouseDirections): integer;
var
  i: integer = 0;
  d: tKlausMouseDirection;
begin
  result := 0;
  for d := low(md) to high(md) do begin
    if d in md then result := result or (1 shl i);
    inc(i);
  end;
end;

function intToMouseDirs(md: integer): tKlausMouseDirections;
var
  i: integer = 0;
  d: tKlausMouseDirection;
begin
  result := [];
  for d := low(result) to high(result) do begin
    if md and (1 shl i) <> 0 then include(result, d);
    inc(i);
  end;
end;

{ tKlausMouseCell }

constructor tKlausMouseCell.create(aOwner: tKlausMouseSetting; aHorz, aVert: integer);
begin
  inherited create;
  fOwner := aOwner;
  fHorz := aHorz;
  fVert := aVert;
end;

function tKlausMouseCell.toJson: tJsonData;
begin
  result := tJsonObject.create;
  with result as tJsonObject do begin
    add('walls', mouseDirsToInt(walls));
    add('painted', painted);
    add('text', text);
    add('arrow', mouseDirToInt(arrow));
  end;
end;

procedure tKlausMouseCell.fromJson(data: tJsonData);
begin
  if not (data is tJsonObject) then raise eKlausError.create(ercInvalidFileFormat, zeroSrcPt);
  updating;
  with data as tJsonObject do try
    walls := intToMouseDirs(get('walls', 0));
    painted := get('painted', false);
    text := get('text', '');
    arrow := intToMouseDir(get('arrow', 0));
  finally
    updated;
  end;
end;

procedure tKlausMouseCell.toggleArrow(dir: tKlausMouseDirection);
begin
  if arrow = dir then arrow := kmdNone else arrow := dir;
end;

procedure tKlausMouseCell.updating;
begin
  owner.updating;
end;

procedure tKlausMouseCell.updated;
begin
  owner.updated;
end;

procedure tKlausMouseCell.assignTo(dest: tPersistent);
begin
  if dest is tKlausMouseCell then
    with dest as tKlausMouseCell do begin
      updating;
      try
        walls := self.walls;
        painted := self.painted;
        text := self.text;
        arrow := self.arrow;
      finally
        updated;
      end;
    end
  else
    inherited assignTo(dest);
end;

function tKlausMouseCell.getWall(idx: tKlausMouseDirection): boolean;
begin
  case idx of
    kmdHere: result := false;
    kmdLeft: result := (horz <= 0) or (idx in fWalls);
    kmdUp: result := (vert <= 0) or (idx in fWalls);
    kmdRight: result := (horz >= owner.width-1) or (idx in fWalls);
    kmdDown: result := (vert >= owner.height-1) or (idx in fWalls);
  else
    assert(false, 'Invalid mouse direction');
  end;
end;

procedure tKlausMouseCell.setWall(idx: tKlausMouseDirection; val: boolean);
begin
  if (idx <> kmdHere) and ((idx in fWalls) <> val) then begin
    updating;
    try
      if val then include(fWalls, idx) else exclude(fWalls, idx);
      case idx of
        kmdLeft: if horz > 0 then owner.cells[horz-1, vert].wall[kmdRight] := val;
        kmdUp: if vert > 0 then owner.cells[horz, vert-1].wall[kmdDown] := val;
        kmdRight: if horz < owner.width-1 then owner.cells[horz+1, vert].wall[kmdLeft] := val;
        kmdDown: if vert < owner.height-1 then owner.cells[horz, vert+1].wall[kmdUp] := val;
      else
        assert(false, 'Invalid mouse direction');
      end;
    finally
      updated;
    end;
  end;
end;

function tKlausMouseCell.getWalls: tKlausMouseDirections;
var
  w: tKlausMouseDirection;
begin
  result := [];
  for w := low(w) to high(w) do
    if wall[w] then include(result, w);
end;

procedure tKlausMouseCell.setWalls(val: tKlausMouseDirections);
var
  w: tKlausMouseDirection;
begin
  if fWalls <> val then begin
    updating;
    try
      for w := low(val) to high(val) do wall[w] := w in val;
    finally
      updated;
    end;
  end;
end;

procedure tKlausMouseCell.setPainted(val: boolean);
begin
  if fPainted <> val then begin
    updating;
    try fPainted := val;
    finally updated; end;
  end;
end;

procedure tKlausMouseCell.setText(val: string);
begin
  if fText <> val then begin
    updating;
    try fText := trim(u8Upper(u8Copy(val, 0, 1)));
    finally updated; end;
  end;
end;

procedure tKlausMouseCell.setArrow(val: tKlausMouseDirection);
begin
  if fArrow <> val then begin
    updating;
    try fArrow := val;
    finally updated; end;
  end;
end;

{ tKlausMouseSetting }

constructor tKlausMouseSetting.create(aWidth, aHeight: integer);
var
  x, y: integer;
begin
  inherited create;
  fMouseDir := kmdLeft;
  fWidth := max(aWidth, 1);
  fHeight := max(aHeight, 1);
  setLength(fCells, fHeight, fWidth);
  for y := 0 to fHeight-1 do
    for x := 0 to fWidth-1 do
      fCells[y, x] := tKlausMouseCell.create(self, x, y);
end;

destructor tKlausMouseSetting.destroy;
var
  x, y: integer;
begin
  for y := 0 to height-1 do
    for x := 0 to width-1 do
      freeAndNil(fCells[y, x]);
  inherited destroy;
end;

function tKlausMouseSetting.toJson: tJsonData;
var
  x, y: integer;
  rws, cls: tJsonArray;
begin
  result := inherited toJson;
  with result as tJsonObject do begin
    add('width', width);
    add('height', height);
    add('mouseX', mouseX);
    add('mouseY', mouseY);
    add('mouseDir', mouseDirToInt(mouseDir));
    rws := tJsonArray.create;
    for y := 0 to height-1 do begin
      cls := tJsonArray.create;
      for x := 0 to width-1 do
        cls.add(cells[x, y].toJson);
      rws.add(cls);
    end;
    add('cells', rws);
  end;
end;

procedure tKlausMouseSetting.fromJson(data: tJsonData);
var
  x, y: integer;
  rws, cls: tJsonArray;
begin
  if not (data is tJsonObject) then raise eKlausError.create(ercInvalidFileFormat, zeroSrcPt);
  updating;
  with data as tJsonObject do try
    inherited fromJson(data);
    width := get('width', 1);
    height := get('height', 1);
    mouseX := get('mouseX', 0);
    mouseY := get('mouseY', 0);
    mouseDir := intToMouseDir(get('mouseDir', 0));
    rws := get('cells', tJsonArray(nil));
    if rws <> nil then
      for y := 0 to rws.count-1 do begin
        if y >= height then break;
        cls := rws.arrays[y];
        for x := 0 to cls.count-1 do begin
          if x >= width then break;
          cells[x, y].fromJson(cls.objects[x]);
        end;
      end;
  finally
    updated;
  end;
end;

function tKlausMouseSetting.getCells(x, y: integer): tKlausMouseCell;
begin
  if (x < 0) or (x >= width) or (y < 0) or (y >= height) then raise eKlausError.createFmt(ercInvalidCellIndex, zeroSrcPt, [x, y]);
  result := fCells[y, x];
end;

procedure tKlausMouseSetting.setHeight(val: integer);
var
  i, j: integer;
begin
  if val <= 0 then val := 1;
  if fHeight <> val then begin
    updating;
    try
      for i := val to height-1 do
        for j := 0 to width-1 do
          fCells[i, j].free;
      setLength(fCells, val, width);
      for i := height to val-1 do
        for j := 0 to width-1 do
          fCells[i, j] := tKlausMouseCell.create(self, j, i);
      fHeight := val;
      if mouseY >= height then mouseY := height - 1;
    finally
      updated;
    end;
  end;
end;

procedure tKlausMouseSetting.setWidth(val: integer);
var
  i, j: integer;
begin
  if val <= 0 then val := 1;
  if fWidth <> val then begin
    updating;
    try
      for i := 0 to height-1 do
        for j := val to width-1 do
          fCells[i, j].free;
      setLength(fCells, height, val);
      for i := 0 to height-1 do
        for j := width to val-1 do
          fCells[i, j] := tKlausMouseCell.create(self, j, i);
      fWidth := val;
      if mouseX >= width then mouseX := width - 1;
    finally
      updated;
    end;
  end;
end;

procedure tKlausMouseSetting.setMouseDir(val: tKlausMouseDirection);
begin
  if fMouseDir <> val then begin
    updating;
    try fMouseDir := val;
    finally updated; end;
  end;
end;

procedure tKlausMouseSetting.setMouseX(val: integer);
begin
  val := min(width-1, max(0, val));
  if fMouseX <> val then begin
    updating;
    try fMouseX := val;
    finally updated; end;
  end;
end;

procedure tKlausMouseSetting.setMouseY(val: integer);
begin
  val := min(height-1, max(0, val));
  if fMouseY <> val then begin
    updating;
    try fMouseY := val;
    finally updated; end;
  end;
end;

procedure tKlausMouseSetting.assignTo(dest: tPersistent);
var
  i, j: integer;
begin
  if dest is tKlausMouseSetting then
    with dest as tKlausMouseSetting do begin
      width := self.width;
      height := self.height;
      for i := 0 to width - 1 do
        for j := 0 to height - 1 do
          cells[j, i].assign(self.cells[j, i]);
      mouseX := self.mouseX;
      mouseY := self.mouseY;
      mouseDir := self.mouseDir;
    end
  else
    inherited assignTo(dest);
end;

{ tKlausDoerMouse }

class function tKlausDoerMouse.createSetting: tKlausDoerSetting;
begin
  result := tKlausMouseSetting.create(10, 10);
end;

class function tKlausDoerMouse.createView(aOwner: tComponent): tKlausDoerView;
begin
  result := tKlausMouseView.create(aOwner);
end;

class function tKlausDoerMouse.stdUnitName: string;
begin
  result := klausDoerName_Mouse;
end;

{ tKlausMouseViewColors }

constructor tKlausMouseViewColors.create(aOwner: tKlausMouseView);
begin
  inherited create;
  fOwner := aOwner;
  setDefaults;
end;

procedure tKlausMouseViewColors.updating;
begin
  inc(fUpdateCount);
end;

procedure tKlausMouseViewColors.updated;
begin
  if fUpdateCount > 0 then begin
    dec(fUpdateCount);
    if fUpdateCount = 0 then owner.invalidate;
  end;
end;

procedure tKlausMouseViewColors.setCell(val: tColor);
begin
  if fCell <> val then begin
    fCell := val;
    owner.invalidate;
  end;
end;

procedure tKlausMouseViewColors.setCellArrow(val: tColor);
begin
  if fCellArrow <> val then begin
    updating;
    try fCellArrow := val;
    finally updated; end
  end;
end;

procedure tKlausMouseViewColors.setCellPainted(val: tColor);
begin
  if fCellPainted <> val then begin
    updating;
    try fCellPainted := val;
    finally updated; end;
  end;
end;

procedure tKlausMouseViewColors.setCellText(val: tColor);
begin
  if fCellText <> val then begin
    updating;
    try fCellText := val;
    finally updated; end;
  end;
end;

procedure tKlausMouseViewColors.setWallSet(val: tColor);
begin
  if fWallSet <> val then begin
    updating;
    try fWallSet := val;
    finally updated; end;
  end;
end;

procedure tKlausMouseViewColors.setWallUnset(val: tColor);
begin
  if fWallUnset <> val then begin
    updating;
    try fWallUnset := val;
    finally updated; end;
  end;
end;

procedure tKlausMouseViewColors.assignTo(dest: tPersistent);
begin
  if dest is tKlausMouseViewColors then
    with dest as tKlausMouseViewColors do begin
      updating;
      try
        cell := self.cell;
        cellPainted := self.cellPainted;
        wallSet := self.wallSet;
        wallUnset := self.wallUnset;
        cellArrow := self.cellArrow;
        cellText := self.cellText;
      finally
        updated;
      end;
    end
  else inherited;
end;

procedure tKlausMouseViewColors.setDefaults;
begin
  fCell := $a4cd8c;
  fCellPainted := clGray;
  fWallSet := clBlack;
  fWallUnset := $9fc787;
  fCellArrow := clWhite;
  fCellText := clWhite;
end;

{ tKlausMouseImageCache }

function tKlausMouseImageCache.getImg(dir: tKlausMouseDirection; idx: integer): tBGRABitmap;
begin
  assert((idx >= 0) and (idx < mouseImageInfo.count), 'Invalid mouse image index.');
  if dir = kmdNone then dir := kmdLeft;
  result := fImg[dir, idx];
end;

constructor tKlausMouseImageCache.create;
var
  i: integer;
  d: tKlausMouseDirection;
begin
  inherited;
  for d := kmdLeft to kmdDown do begin
    setLength(fImg[d], mouseImageInfo.count);
    for i := 0 to mouseImageInfo.count-1 do fImg[d, i] := nil;
  end;
end;

destructor tKlausMouseImageCache.destroy;
begin
  clear;
  inherited destroy;
end;

procedure tKlausMouseImageCache.clear;
var
  i: integer;
  d: tKlausMouseDirection;
begin
  for d := kmdLeft to kmdDown do
    for i := 0 to mouseImageInfo.count-1 do freeAndNil(fImg[d, i]);
end;

procedure tKlausMouseImageCache.rebuild(aSize: integer);
var
  i: integer;
  scale: double;
begin
  if fSize <> aSize then begin
    clear;
    fSize := aSize;
    with mouseImageInfo do begin
      scale := min(fSize/fit.width, fSize/fit.height);
      fFit := rect(round(fit.left*scale), round(fit.top*scale), round(fit.right*scale), round(fit.bottom*scale));
      fWidth := round(size.cx*scale);
      fHeight := round(size.cy*scale);
      for i := 0 to count-1 do begin
        fImg[kmdUp, i] := tBGRABitmap.create(fWidth, fHeight, bgra(0, 0, 0, 0));
        mouseSVG[i].stretchDraw(fImg[kmdUp, i].canvas2D, rectf(0, 0, fWidth, fHeight));
        fImg[kmdLeft, i] := fImg[kmdUp, i].rotateCCW;
        fImg[kmdRight, i] := fImg[kmdUp, i].rotateCW;
        fImg[kmdDown, i] := fImg[kmdUp, i].rotateUD;
      end;
    end;
  end;
end;

procedure tKlausMouseImageCache.draw(canvas: tCanvas; cell: tRect; dir: tKlausMouseDirection; idx: integer);
var
  r: tRect;
  x, y: integer;
begin
  if dir < kmdLeft then dir := kmdLeft;
  rebuild(cell.width - (cell.width div 10)*2);
  with fFit do
    case dir of
      kmdLeft: begin
        r := rect(top, fWidth - right, bottom, fWidth - left);
        x := cell.left - r.left + cell.width div 10;
        y := cell.top - r.top + cell.height div 2 - r.height div 2;
      end;
      kmdUp: begin
        r := rect(left, top, right, bottom);
        x := cell.left - r.left + cell.width div 2 - r.width div 2;
        y := cell.top - r.top + cell.height div 10;
      end;
      kmdRight: begin
        r := rect(fHeight - bottom, left, fHeight - top, right);
        x := cell.right - r.width - r.left - cell.Width div 10;
        y := cell.top - r.top + cell.height div 2 - r.height div 2;
      end;
      kmdDown: begin
        r := rect(fWidth - right, fHeight - bottom, fWidth - left, fHeight - top);
        x := cell.left - r.left + cell.width div 2 - r.width div 2;
        y := cell.bottom - r.height - r.top - cell.height div 10;
      end;
    end;
  fImg[dir, idx].draw(canvas, x, y, false);
end;

{ tKlausMouseView }

constructor tKlausMouseView.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  doubleBuffered := true;
  borderSpacing.innerBorder := 3;
  tabStop := true;
  fColors := tKlausMouseViewColors.create(self);
  fImg := tKlausMouseImageCache.create;
end;

destructor tKlausMouseView.destroy;
begin
  freeAndNil(fColors);
  freeAndNil(fImg);
  inherited destroy;
end;

function tKlausMouseView.cellRect(x, y: integer): tRect;
begin
  result.left := fOrigin.x + x*fCellSize;
  result.top := fOrigin.y + y*fCellSize;
  result.width := fCellSize;
  result.height := fCellSize;
end;

function tKlausMouseView.cellFromPoint(x, y: integer): tPoint;
begin
  result.x := (x-fOrigin.x) div fCellSize;
  result.y := (y-fOrigin.y) div fCellSize;
end;

procedure tKlausMouseView.setColors(val: tKlausMouseViewColors);
begin
  fColors.assign(val);
end;

function tKlausMouseView.getSetting: tKlausMouseSetting;
begin
  result := inherited setting as tKlausMouseSetting;
end;

procedure tKlausMouseView.setFocusX(val: integer);
begin
  if setting = nil then val := -1
  else val := min(setting.width-1, max(val, 0));
  if fFocusX <> val then begin
    fFocusX := val;
    invalidate;
  end;
end;

procedure tKlausMouseView.setFocusY(val: integer);
begin
  if setting = nil then val := -1
  else val := min(setting.height-1, max(val, 0));
  if fFocusY <> val then begin
    fFocusY := val;
    invalidate;
  end;
end;

procedure tKlausMouseView.setReadOnly(val: boolean);
begin
  if readOnly <> val then begin
    inherited;
    invalidate;
  end;
end;

procedure tKlausMouseView.setSetting(val: tKlausMouseSetting);
begin
  setSetting(tKlausDoerSetting(val));
end;

procedure tKlausMouseView.paint;
const
  arrows: array[tKlausMouseDirection] of u8Char = ('', '←', '↑', '→', '↓');
var
  r: tRect;
  sz: tSize;
  s: string;
  x, y, w, h: integer;
begin
  r := clientRect;
  r.inflate(-3, -3);
  with canvas do begin
    with brush do begin style := bsSolid; color := self.color; end;
    fillRect(r);
  end;
  if setting = nil then exit;
  fCellSize := max(5, min(r.width div setting.width, r.height div setting.height));
  w := fCellSize * setting.width;
  h := fCellSize * setting.height;
  fOrigin.x := r.left + (r.width - w) div 2;
  fOrigin.y := r.top + (r.height - h) div 2;
  with canvas do begin
    brush.color := self.colors.cell;
    with pen do begin style := psSolid; width := max(1, fCellSize div 10); end;
    fillRect(fOrigin.x, fOrigin.y, fOrigin.x+w, fOrigin.y+h);
    pen.color := self.colors.wallUnset;
    for x := 0 to setting.width-1 do
      for y := 0 to setting.height-1 do begin
        r := cellRect(x, y);
        if (x > 0) and not setting[x, y].wall[kmdLeft] then
          line(r.left, r.top, r.left, r.bottom);
        if (y > 0) and not setting[x, y].wall[kmdUp] then
          line(r.left, r.top, r.right, r.top);
      end;
    brush.color := self.colors.cellPainted;
    for x := 0 to setting.width-1 do
      for y := 0 to setting.height-1 do begin
        r := cellRect(x, y);
        if setting[x, y].painted then
          fillRect(r.left, r.top, r.right, r.bottom);
      end;
    pen.color := self.colors.wallSet;
    font.color := self.colors.cellText;
    font.size := fCellSize div 3;
    font.style := [fsBold];
    brush.style := bsClear;
    for x := 0 to setting.width-1 do
      for y := 0 to setting.height-1 do begin
        r := cellRect(x, y);
        if (x > 0) and setting[x, y].wall[kmdLeft] then
          line(r.left, r.top, r.left, r.bottom);
        if (y > 0) and setting[x, y].wall[kmdUp] then
          line(r.left, r.top, r.right, r.top);
      end;
    for x := 0 to setting.width-1 do
      for y := 0 to setting.height-1 do begin
        r := cellRect(x, y);
        sz := textExtent(setting[x, y].text);
        textOut(r.left+(r.width-sz.cx) div 2, r.top+(r.height-sz.cy) div 2, setting[x, y].text);
        s := arrows[setting[x, y].arrow];
        if s <> '' then begin
          sz := textExtent(s);
          case setting[x, y].arrow of
            kmdLeft: textOut(r.left - fCellSize div 10, r.top + (r.height-sz.cy) div 2, s);
            kmdUp: textOut(r.left + (r.width-sz.cx) div 2, r.top - fCellSize div 10, s);
            kmdRight: textOut(r.right - sz.cx + fCellSize div 10 + 1, r.top + (r.height-sz.cy) div 2, s);
            kmdDown: textOut(r.left + (r.width-sz.cx) div 2, r.bottom - sz.cy + fCellSize div 10 + 1, s);
          end;
        end;
      end;
    line(fOrigin.x, fOrigin.y, fOrigin.x+w, fOrigin.y);
    line(fOrigin.x, fOrigin.y+h, fOrigin.x+w, fOrigin.y+h);
    line(fOrigin.x, fOrigin.y, fOrigin.x, fOrigin.y+h);
    line(fOrigin.x+w, fOrigin.y, fOrigin.x+w, fOrigin.y+h);
    r := cellRect(setting.mouseX, setting.mouseY);
    fImg.draw(canvas, r, setting.mouseDir, 0);
    if focused and not readOnly and (focusX >= 0) and (focusY >= 0) then begin
      r := cellRect(focusX, focusY);
      r.inflate(-fCellSize div 10, -fCellSize div 10);
      r.left := r.left + 1;
      r.top := r.top + 1;
      if fCellSize < 20 then w := 1 else w := 2;
      with pen do begin color := self.colors.wallSet; width := w; style := psDot; end;
      brush.style := bsClear;
      rectangle(r);
    end;
  end;
end;

procedure tKlausMouseView.setSetting(aSetting: tKlausDoerSetting);
begin
  if aSetting <> nil then assert(aSetting is tKlausMouseSetting, 'Invalid doer setting class');
  if setting <> nil then setting.onChange := nil;
  inherited setSetting(aSetting);
  if setting <> nil then setting.onChange := @settingChange;
  focusX := 0;
  focusY := 0;
  invalidate;
end;

procedure tKlausMouseView.settingChange(sender: tObject);
begin
  focusX := focusX;
  focusY := focusY;
  change;
  invalidate;
end;

procedure tKlausMouseView.doOnResize;
begin
  inherited doOnResize;
  if handleAllocated then invalidate;
end;

procedure tKlausMouseView.mouseDown(button: tMouseButton; shift: tShiftState; x, y: integer);
var
  r: tRect;
  cell: tPoint;
  mouseHere: boolean;
begin
  inherited mouseDown(button, shift, x, y);
  shift := shift * [ssShift, ssCtrl, ssAlt, ssDouble];
  if not readOnly then begin
    cell := cellFromPoint(x, y);
    focusX := cell.x;
    focusY := cell.y;
    with setting do mouseHere := (mouseX = cell.x) and (mouseY = cell.y);
    r := cellRect(focusX, focusY);
    with setting[focusX, focusY] do
      if ssDouble in shift then begin
        setting.mouseX := cell.x;
        setting.mouseY := cell.y;
      end else if abs(r.left-x) <= fCellSize div 5 then begin
        if shift = [] then wall[kmdLeft] := not wall[kmdLeft]
        else if shift = [ssCtrl] then toggleArrow(kmdLeft)
        else if (shift = [ssAlt]) and mouseHere then setting.mouseDir := kmdLeft;
      end else if abs(r.right-x) <= fCellSize div 5 then begin
        if shift = [] then wall[kmdRight] := not wall[kmdRight]
        else if shift = [ssCtrl] then toggleArrow(kmdRight)
        else if (shift = [ssAlt]) and mouseHere then setting.mouseDir := kmdRight;
      end else if abs(r.top-y) <= fCellSize div 5 then begin
        if shift = [] then wall[kmdUp] := not wall[kmdUp]
        else if shift = [ssCtrl] then toggleArrow(kmdUp)
        else if (shift = [ssAlt]) and mouseHere then setting.mouseDir := kmdUp;
      end else if abs(r.bottom-y) <= fCellSize div 5 then begin
        if shift = [] then wall[kmdDown] := not wall[kmdDown]
        else if shift = [ssCtrl] then toggleArrow(kmdDown)
        else if (shift = [ssAlt]) and mouseHere then setting.mouseDir := kmdDown;
      end;
  end;
end;

procedure tKlausMouseView.keyDown(var key: word; shift: tShiftState);
var
  x, y: integer;
begin
  x := focusX;
  y := focusY;
  if readOnly or (x < 0) or (y < 0) then begin
    inherited;
    exit;
  end;
  with setting[x, y] do case key of
    VK_LEFT: if shift = [] then begin
      focusX := x - 1;
      key := 0;
    end else if shift = [ssShift] then begin
      wall[kmdLeft] := not wall[kmdLeft];
      key := 0;
    end else if shift = [ssCtrl] then begin
      toggleArrow(kmdLeft);
      key := 0;
    end else if shift = [ssAlt] then begin
      setting.mouseDir := kmdLeft;
      key := 0;
    end;
    VK_RIGHT: if shift = [] then begin
      focusX := x + 1;
      key := 0;
    end else if shift = [ssShift] then begin
      wall[kmdRight] := not wall[kmdRight];
      key := 0;
    end else if shift = [ssCtrl] then begin
      toggleArrow(kmdRight);
      key := 0;
    end else if shift = [ssAlt] then begin
      setting.mouseDir := kmdRight;
      key := 0;
    end;
    VK_UP: if shift = [] then begin
      focusY := y - 1;
      key := 0;
    end else if shift = [ssShift] then begin
      wall[kmdUp] := not wall[kmdUp];
      key := 0;
    end else if shift = [ssCtrl] then begin
      toggleArrow(kmdUp);
      key := 0;
    end else if shift = [ssAlt] then begin
      setting.mouseDir := kmdUp;
      key := 0;
    end;
    VK_DOWN: if shift = [] then begin
      focusY := y + 1;
      key := 0;
    end else if shift = [ssShift] then begin
      wall[kmdDown] := not wall[kmdDown];
      key := 0;
    end else if shift = [ssCtrl] then begin
      toggleArrow(kmdDown);
      key := 0;
    end else if shift = [ssAlt] then begin
      setting.mouseDir := kmdDown;
      key := 0;
    end;
    VK_DELETE: if shift = [] then begin
      text := '';
      key := 0;
    end;
    VK_C: if shift = [ssCtrl] then begin
      if text <> '' then clipboard.asText := text;
      key := 0;
    end;
    VK_V: if shift = [ssCtrl] then begin
      if clipboard.hasFormat(CF_TEXT) then text := clipboard.asText;
      key := 0;
    end;
    VK_SPACE: if shift = [] then begin
      painted := not painted;
      key := 0;
    end;
    VK_RETURN: if shift = [] then begin
      setting.mouseX := x;
      setting.mouseY := y;
      key := 0;
    end;
  end;
  if key <> 0 then inherited;
end;

procedure tKlausMouseView.UTF8KeyPress(var key: tUTF8Char);
var
  x, y: integer;
begin
  if not readOnly then begin
    x := focusX;
    y := focusY;
    if (x < 0) or (y < 0) then exit;
    setting[x, y].text := key;
  end;
end;

class function tKlausMouseView.doerClass: tKlausDoerClass;
begin
  result := tKlausDoerMouse;
end;

var
  i: integer;
  stream: tResourceStream;
initialization
  klausRegisterStdUnit(tKlausDoerMouse);
  setLength(mouseSVG, mouseImageInfo.count);
  for i := 0 to mouseImageInfo.count-1 do begin
    stream := tResourceStream.create(hInstance, format(mouseImageInfo.resName, [i]), RT_RCDATA);
    try mouseSVG[i] := tBGRASVG.create(stream);
    finally freeAndNil(stream); end;
  end;
finalization
  for i := 0 to mouseImageInfo.count-1 do freeAndNil(mouseSVG[i]);
end.

