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
  Classes, SysUtils, Messages, LMessages, KlausLex, KlausDef, KlausSyn, KlausErr,
  Controls, Forms, Dialogs, Graphics, LCLType, KlausDoer, FpJson, KlausSrc,
  KlausUnitSystem;

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
      fText1: string;
      fText2: string;
      fMark: boolean;
      fHasNumber: boolean;
      fNumber: integer;
      fTemperature: double;
      fRadiation: double;

      function  getWall(idx: tKlausMouseDirection): boolean;
      function  getWalls: tKlausMouseDirections;
      function  isNumberStored: Boolean;
      function  isRadiationStored: Boolean;
      function  isTemperatureStored: Boolean;
      function  isText1Stored: Boolean;
      function  isText2Stored: Boolean;
      function  isWallsStored: Boolean;
      procedure setArrow(val: tKlausMouseDirection);
      procedure setHasNumber(val: boolean);
      procedure setNumber(val: integer);
      procedure setMark(val: boolean);
      procedure setPainted(val: boolean);
      procedure setRadiation(val: double);
      procedure setTemperature(val: double);
      procedure setText1(val: string);
      procedure setText2(val: string);
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

      constructor create(aOwner: tKlausMouseSetting; aHorz, aVert: integer);
      procedure clear;
      function  toJson: tJsonObject;
      procedure fromJson(data: tJsonData);
      procedure toggleArrow(dir: tKlausMouseDirection);
    published
      property walls: tKlausMouseDirections read getWalls write setWalls stored isWallsStored;
      property painted: boolean read fPainted write setPainted default false;
      property text1: string read fText1 write setText1 stored isText1Stored;
      property text2: string read fText2 write setText2 stored isText2Stored;
      property hasNumber: boolean read fHasNumber write setHasNumber stored false;
      property number: integer read fNumber write setNumber stored isNumberStored;
      property mark: boolean read fMark write setMark default false;
      property arrow: tKlausMouseDirection read fArrow write setArrow default kmdNone;
      property temperature: double read fTemperature write setTemperature stored isTemperatureStored;
      property radiation: double read fRadiation write setRadiation stored isRadiationStored;
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
      function  getHere: tKlausMouseCell;
      procedure setWidth(val: integer);
      procedure setHeight(val: integer);
      procedure setMouseDir(val: tKlausMouseDirection);
      procedure setMouseX(val: integer);
      procedure setMouseY(val: integer);
    protected
      procedure assignTo(dest: tPersistent); override;
    public
      property width: integer read fWidth write setWidth;
      property height: integer read fHeight write setHeight;
      property cells[x, y: integer]: tKlausMouseCell read getCells; default;
      property here: tKlausMouseCell read getHere;
      property mouseX: integer read fMouseX write setMouseX;
      property mouseY: integer read fMouseY write setMouseY;
      property mouseDir: tKlausMouseDirection read fMouseDir write setMouseDir;

      constructor create(aWidth, aHeight: integer);
      destructor  destroy; override;
      function  toJson: tJsonData; override;
      procedure fromJson(data: tJsonData); override;
      procedure clear;
      function  turn(dir: integer): tKlausMouseDirection;
      procedure move(dir: tKlausMouseDirection);
  end;

type
  tKlausDoerMouse = class(tKlausDoer)
    private
      fIntParam: array[0..9] of integer;

      procedure createVariables;
      procedure createRoutines;
      function  getSetting: tKlausMouseSetting;
      function  getView: tKlausMouseView;
      procedure syncNextStep;
      procedure syncTurn;
      procedure syncPaint;
    private
      class procedure importKlausMouseSettings(settings: tKlausDoerSettings; fileName: string);
      class procedure importKumirRobotSetting(settings: tKlausDoerSettings; fileName: string);
    public
      class function  stdUnitName: string; override;
      class function  createSetting: tKlausDoerSetting; override;
      class function  createView(aOwner: tComponent; mode: tKlausDoerViewMode): tKlausDoerView; override;
      class function  capabilities: tKlausDoerCapabilities; override;
      class procedure importSettingsDlgSetup(dlg: tOpenDialog); override;
      class procedure importSettings(settings: tKlausDoerSettings; fileName: string); override;
      class procedure exportSettingsDlgSetup(dlg: tSaveDialog); override;
      class procedure exportSettings(settings: tKlausDoerSettings; fileName: string); override;
    public
      property view: tKlausMouseView read getView;
      property setting: tKlausMouseSetting read getSetting;

      constructor create(aSource: tKlausSource); override;
      procedure runStep(frame: tKlausStackFrame; dir: tKlausInteger; at: tSrcPoint);
      procedure runTurn(frame: tKlausStackFrame; dir: tKlausInteger; at: tSrcPoint);
      procedure runPaint(frame: tKlausStackFrame; at: tSrcPoint);
      procedure runClear(frame: tKlausStackFrame; at: tSrcPoint);
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
      fTemperature: tColor;
      fRadiation: tColor;

      procedure setCell(val: tColor);
      procedure setCellArrow(val: tColor);
      procedure setCellPainted(val: tColor);
      procedure setCellText(val: tColor);
      procedure setWallSet(val: tColor);
      procedure setWallUnset(val: tColor);
      procedure setTemperature(val: tColor);
      procedure setRadiation(val: tColor);
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
      property temperature: tColor read fTemperature write setTemperature default clRed;
      property radiation: tColor read fRadiation write setRadiation default clBlue;
  end;

type
  tKlausMouseImageCache = class(tObject)
    private
      fSize: integer;
      fFit: tRect;
      fWidth, fHeight: integer;
      fImg: array[kmdLeft..kmdDown] of array of tPortableNetworkGraphic;

      function getImg(dir: tKlausMouseDirection; idx: integer): tGraphic;
    public
      property img[dir: tKlausMouseDirection; idx: integer]: tGraphic read getImg; default;

      constructor create;
      destructor  destroy; override;
      procedure clear;
      procedure rebuild(aSize: integer);
      procedure draw(canvas: tCanvas; cell: tRect; dir: tKlausMouseDirection; idx: integer);
  end;

const
  klausMouseMinCellSize = 5;
  klausMouseMaxCellSize = 80;

type
  tKlausMouseViewMode = (mvmNormal, mvmTemperature, mvmRadiation);

type
  tNumKeyPressed = (kpNone, kpMinus, kpDigit);

type
  tKlausMouseView = class(tKlausDoerView)
    private
      fOrigin: tPoint;
      fCellSize: integer;
      fFocusX: integer;
      fFocusY: integer;
      fShiftX: integer;
      fShiftY: integer;
      fPhase: integer;
      fColors: tKlausMouseViewColors;
      fImg: tKlausMouseImageCache;
      fKeyPressed: tNumKeyPressed;
      fInputText: string;
      fMode: tKlausMouseViewMode;

      function  getSetting: tKlausMouseSetting;
      procedure setColors(val: tKlausMouseViewColors);
      procedure setFocusX(val: integer);
      procedure setFocusY(val: integer);
      procedure setMode(val: tKlausMouseViewMode);
      procedure setSetting(val: tKlausMouseSetting);
      procedure resetNumericInput;
    protected
      procedure doExit; override;
      procedure WMSetFocus(var Msg: tMessage); message LM_SetFocus;
      procedure WMKillFocus(var Msg: tMessage); message LM_KillFocus;
      procedure paint; override;
      procedure setSetting(aSetting: tKlausDoerSetting); override;
      procedure setReadOnly(val: boolean); override;
      procedure settingChange(sender: tObject); virtual;
      procedure doOnResize; override;
      procedure mouseDown(button: tMouseButton; shift: tShiftState; x, y: integer); override;
      procedure keyDown(var key: word; shift: tShiftState); override;
      procedure UTF8KeyPress(var key: tUTF8Char); override;
      procedure change; override;
      function  redrawDisabled: boolean; virtual;
    public
      property focusX: integer read fFocusX write setFocusX;
      property focusY: integer read fFocusY write setFocusY;
      property setting: tKlausMouseSetting read getSetting write setSetting;
      property mode: tKlausMouseViewMode read fMode write setMode;

      class function doerClass: tKlausDoerClass; override;

      constructor create(aOwner: tComponent); override;
      destructor  destroy; override;
      procedure invalidate; override;
      function  cellRect(x, y: integer): tRect;
      function  cellFromPoint(x, y: integer): tPoint;
      function  nextStep(immediate: boolean): boolean;
    published
      property color;
      property colors: tKlausMouseViewColors read fColors write setColors;
      property tabStop default true;
      property onDblClick;
  end;

const
  klausConstName_MouseLeft = 'влево';
  klausConstName_MouseLeft2 = 'слева';
  klausConstName_MouseLeft3 = 'налево';
  klausConstName_MouseRight = 'вправо';
  klausConstName_MouseRight2 = 'справа';
  klausConstName_MouseRight3 = 'направо';
  klausConstName_MouseFwd = 'вперед';
  klausConstName_MouseFwd2 = 'вперёд';
  klausConstName_MouseFwd3 = 'впереди';
  klausConstName_MouseBack = 'назад';
  klausConstName_MouseBack2 = 'сзади';
  klausConstName_MouseWest = 'наЗапад';
  klausConstName_MouseWest2 = 'наЗападе';
  klausConstName_MouseNorth = 'наСевер';
  klausConstName_MouseNorth2 = 'наСевере';
  klausConstName_MouseEast = 'наВосток';
  klausConstName_MouseEast2 = 'наВостоке';
  klausConstName_MouseSouth = 'наЮг';
  klausConstName_MouseSouth2 = 'наЮге';

const
  klausConst_MouseHere = 0;
  klausConst_MouseLeft = 1;
  klausConst_MouseRight = 2;
  klausConst_MouseFwd = 3;
  klausConst_MouseBack = 4;
  klausConst_MouseWest = 5;
  klausConst_MouseNorth = 6;
  klausConst_MouseEast = 7;
  klausConst_MouseSouth = 8;

const
  klausProcName_MouseLoadSetting = 'загрузитьОбстановку';
  klausProcName_MouseStep = 'шаг';
  klausProcName_MouseTurn = 'повернуть';
  klausProcName_MousePaint = 'закрасить';
  klausProcName_MouseClear = 'очистить';
  klausProcName_MouseWall = 'стена';
  klausProcName_MousePainted = 'закрашено';
  klausProcName_MouseArrow = 'стрелка';
  klausProcName_MouseHasNumber = 'естьЧисло';
  klausProcName_MouseNumber = 'число';
  klausProcName_MouseTemperature = 'температура';
  klausProcName_MouseRadiation = 'радиация';

const
  mouseMovementDelay: array[tKlausDoerSpeed] of integer = (100, 50, 25, 10, 0, 0);

type
  tKlausSysProc_MouseLoadSetting = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
      fIdx: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  tKlausSysProc_MouseStep = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  tKlausSysProc_MouseTurn = class(tKlausSysProcDecl)
    private
      fDir: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  tKlausSysProc_MousePaint = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  tKlausSysProc_MouseClear = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  tKlausSysProc_MouseWall = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  tKlausSysProc_MousePainted = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  tKlausSysProc_MouseArrow = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  tKlausSysProc_MouseHasNumber = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  tKlausSysProc_MouseNumber = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  tKlausSysProc_MouseTemperature = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  tKlausSysProc_MouseRadiation = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

implementation

{$R *.res}

uses
  Types, TypInfo, Math, Clipbrd, U8, KlausUtils;

resourcestring
  strMouseSettingsImportFilter = 'Все файлы обстановок|*.klaus-setting;*.fil|Клаус - обстановки исполнителей|*.klaus-setting|КуМир - обстановки Робота|*.fil|Все файлы|*';
  strMouseSettingsExportFilter = 'Клаус - обстановки исполнителей|*.klaus-setting|Все файлы|*';
  strKumirRobotSettingFileExt = '.fil';
  strAtLine = 'Строка %d: %s';
  strProgramRunning = 'Программа выполняется...';

const
  mouseImageInfo: record
    count: integer;
    size: tSize;
    fit: tRect;
    resName: string;
  end = (
    count: 6;
    size: (cx: 173; cy: 482); // размеры изображения (для направления на север)
    fit: (left: 0; top: 0; right: 174; bottom: 282); // прямоугольник, который должен влезть в клетку
    resName: 'klaus_doer_mouse%.2d%s_png';
  );

var
  mousePNG: array[kmdLeft..kmdDown] of array of tPortableNetworkGraphic = (nil, nil, nil, nil);

resourcestring
  strNumOrNum = '%d или %d';
  errMoveThroughWall = 'Мышка не может двигаться сквозь стену.';

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

procedure tKlausMouseCell.clear;
begin
  updating;
  try
    walls := [];
    painted := false;
    text1 := '';
    text2 := '';
    hasNumber := false;
    mark := false;
    temperature := 0;
    radiation := 0;
    arrow := kmdNone;
  finally
    updated;
  end;
end;

function tKlausMouseCell.toJson: tJsonObject;
var
  data: tJsonObject = nil;

  function rslt: tJsonObject;
  begin
    if data = nil then data := tJsonObject.create;
    result := data;
  end;

  function stored(pi: pPropInfo): boolean;
  const
    ordinal = [tkInteger, tkChar, tkEnumeration, tkBool, tkInt64, tkQWord];
  var
    v: int64;
  begin
    result := isStoredProp(self, pi);
    if result and (pi^.propType^.kind in ordinal)
    and ((pi^.propProcs shr 4) and 3 = ptConst) then begin
      v := getOrdProp(self, pi);
      result := pi^.default <> v;
    end;
  end;

var
  n: string;
  pl: pPropList;
  i, cnt: integer;
begin
  cnt := getPropList(self, pl);
  for i := 0 to cnt-1 do
    if stored(pl^[i]) then begin
      n := lowerCase(pl^[i]^.name);
      if n = 'walls' then rslt.add('walls', mouseDirsToInt(walls))
      else if n = 'painted' then rslt.add('painted', painted)
      else if n = 'text1' then rslt.add('text1', text1)
      else if n = 'text2' then rslt.add('text2', text2)
      else if n = 'number' then rslt.add('number', intToStr(number))
      else if n = 'mark' then rslt.add('mark', mark)
      else if n = 'temperature' then rslt.add('temperature', temperature)
      else if n = 'radiation' then rslt.add('radiation', radiation)
      else if n = 'arrow' then rslt.add('arrow', mouseDirToInt(arrow));
    end;
  {result := tJsonObject.create;
  with result as tJsonObject do begin
    add('walls', mouseDirsToInt(walls));
    add('painted', painted);
    add('text1', text1);
    add('text2', text2);
    if hasNumber then s := intToStr(number);
    add('number', s);
    add('mark', mark);
    add('temperature', temperature);
    add('radiation', radiation);
    add('arrow', mouseDirToInt(arrow));
  end;}
  result := data;
end;

procedure tKlausMouseCell.fromJson(data: tJsonData);
var
  s: string;
begin
  if not (data is tJsonObject) then raise eKlausError.create(ercInvalidFileFormat, zeroSrcPt);
  updating;
  with data as tJsonObject do try
    walls := intToMouseDirs(get('walls', 0));
    painted := get('painted', false);
    text1 := get('text1', '');
    text2 := get('text2', '');
    s := get('number', '');
    if s <> '' then number := strToInt(s) else hasNumber := false;
    mark := get('mark', false);
    temperature := get('temperature', tJsonFloat(0));
    radiation := get('radiation', tJsonFloat(0));
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
        text1 := self.text1;
        text2 := self.text2;
        number := self.number;
        hasNumber := self.hasNumber;
        mark := self.mark;
        temperature := self.temperature;
        radiation := self.radiation;
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
    result := false;
    assert(false, 'Invalid mouse direction');
  end;
end;

procedure tKlausMouseCell.setWall(idx: tKlausMouseDirection; val: boolean);
begin
  case idx of
    kmdLeft: if horz <= 0 then val := false;
    kmdUp: if vert <= 0 then val := false;
    kmdRight: if horz >= owner.width-1 then val := false;
    kmdDown: if vert >= owner.height-1 then val := false;
  end;
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
  for w := low(result) to high(result) do
    if wall[w] then include(result, w);
end;

function tKlausMouseCell.isNumberStored: Boolean;
begin
  result := hasNumber;
end;

function tKlausMouseCell.isRadiationStored: Boolean;
begin
  result := radiation <> 0;
end;

function tKlausMouseCell.isTemperatureStored: Boolean;
begin
  result := temperature <> 0;
end;

function tKlausMouseCell.isText1Stored: Boolean;
begin
  result := text1 <> '';
end;

function tKlausMouseCell.isText2Stored: Boolean;
begin
  result := text2 <> '';
end;

function tKlausMouseCell.isWallsStored: Boolean;
var
  w: tKlausMouseDirections;
begin
  w := walls;
  if horz <= 0 then exclude(w, kmdLeft);
  if horz >= owner.width-1 then exclude(w, kmdRight);
  if vert <= 0 then exclude(w, kmdUp);
  if vert >= owner.height-1 then exclude(w, kmdDown);
  result := w <> [];
end;

procedure tKlausMouseCell.setWalls(val: tKlausMouseDirections);
var
  w: tKlausMouseDirection;
begin
  if walls <> val then begin
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

procedure tKlausMouseCell.setRadiation(val: double);
begin
  if fRadiation <> val then begin
    updating;
    try fRadiation := val;
    finally updated; end;
  end;
end;

procedure tKlausMouseCell.setTemperature(val: double);
begin
  if fTemperature <> val then begin
    updating;
    try fTemperature := val;
    finally updated; end;
  end;
end;

procedure tKlausMouseCell.setText1(val: string);
begin
  if fText1 <> val then begin
    updating;
    try fText1 := trim(u8Upper(u8Copy(val, 0, 1)));
    finally updated; end;
  end;
end;

procedure tKlausMouseCell.setText2(val: string);
begin
  if fText2 <> val then begin
    updating;
    try fText2 := trim(u8Upper(u8Copy(val, 0, 1)));
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

procedure tKlausMouseCell.setHasNumber(val: boolean);
begin
  if fHasNumber <> val then begin
    updating;
    try
      if not val then number := 0;
      fHasNumber := val;
    finally
      updated;
    end;
  end;
end;

procedure tKlausMouseCell.setMark(val: boolean);
begin
  if fMark <> val then begin
    updating;
    try fMark := val;
    finally updated; end;
  end;
end;

procedure tKlausMouseCell.setNumber(val: integer);
begin
  val := max(-99, min(99, val));
  if not hasNumber or (fNumber <> val) then begin
    updating;
    try
      hasNumber := true;
      fNumber := val;
    finally
      updated;
    end;
  end;
end;

{ tKlausMouseSetting }

constructor tKlausMouseSetting.create(aWidth, aHeight: integer);
var
  x, y: integer;
begin
  inherited create;
  fMouseDir := kmdRight;
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
  cls: tJsonArray;
  obj: tJsonObject;
begin
  result := inherited toJson;
  with result as tJsonObject do begin
    add('ver', 2);
    add('width', width);
    add('height', height);
    add('mouseX', mouseX);
    add('mouseY', mouseY);
    add('mouseDir', mouseDirToInt(mouseDir));
    cls := tJsonArray.create;
    for y := 0 to height-1 do
      for x := 0 to width-1 do begin
        obj := cells[x, y].toJson;
        if obj <> nil then begin
          obj.add('x', cells[x, y].horz);
          obj.add('y', cells[x, y].vert);
          cls.add(obj);
        end;
      end;
    {for y := 0 to height-1 do begin
      cls := tJsonArray.create;
      for x := 0 to width-1 do
        cls.add(cells[x, y].toJson);
      rws.add(cls);
    end;}
    add('cells', cls);
  end;
end;

procedure tKlausMouseSetting.fromJson(data: tJsonData);
var
  i, x, y, ver: integer;
  rws, cls: tJsonArray;
begin
  if not (data is tJsonObject) then raise eKlausError.create(ercInvalidFileFormat, zeroSrcPt);
  updating;
  with data as tJsonObject do try
    inherited fromJson(data);
    ver := get('ver', 1);
    width := get('width', 1);
    height := get('height', 1);
    mouseX := get('mouseX', 0);
    mouseY := get('mouseY', 0);
    mouseDir := intToMouseDir(get('mouseDir', 0));
    if ver >= 2 then begin
      cls := get('cells', tJsonArray(nil));
      for i := 0 to cls.count-1 do
        with cls.objects[i] do begin
          x := get('x', 0);
          y := get('y', 0);
          cells[x, y].fromJson(cls.objects[i]);
        end;
    end else begin
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
    end
  finally
    updated;
  end;
end;

procedure tKlausMouseSetting.clear;
var
  i, j: integer;
begin
  updating;
  try
    for i := 0 to width-1 do
      for j := 0 to height-1 do
        cells[i, j].clear;
  finally
    updated;
  end;
end;

function tKlausMouseSetting.turn(dir: integer): tKlausMouseDirection;
const
  turnLeft: array[tKlausMouseDirection] of tKlausMouseDirection = (kmdDown, kmdDown, kmdLeft, kmdUp, kmdRight);
  turnRight: array[tKlausMouseDirection] of tKlausMouseDirection = (kmdUp, kmdUp, kmdRight, kmdDown, kmdLeft);
  turnBack: array[tKlausMouseDirection] of tKlausMouseDirection = (kmdRight, kmdRight, kmdDown, kmdLeft, kmdUp);
begin
  case dir of
    klausConst_MouseLeft:  result := turnLeft[mouseDir];
    klausConst_MouseRight: result := turnRight[mouseDir];
    klausConst_MouseBack:  result := turnBack[mouseDir];
    klausConst_MouseWest:  result := kmdLeft;
    klausConst_MouseNorth: result := kmdUp;
    klausConst_MouseEast:  result := kmdRight;
    klausConst_MouseSouth: result := kmdDown;
  else
    result := mouseDir;
  end;
end;

procedure tKlausMouseSetting.move(dir: tKlausMouseDirection);
var
  x, y: integer;
  ms: tKlausMouseSetting = nil;
begin
  if dir = kmdNone then exit;
  updating;
  try
    ms := tKlausMouseSetting.create(width, height);
    ms.assign(self);
    case dir of
      kmdLeft: begin
        for y := 0 to height-1 do begin
          for x := 1 to width-1 do
            cells[x-1, y].assign(ms.cells[x, y]);
          cells[width-1, y].clear;
        end;
        mouseX := mouseX-1;
      end;
      kmdRight: begin
        for y := 0 to height-1 do begin
          for x := 0 to width-2 do
            cells[x+1, y].assign(ms.cells[x, y]);
          cells[0, y].clear;
        end;
        mouseX := mouseX+1;
      end;
      kmdUp: begin
        for x := 0 to width-1 do begin
          for y := 1 to height-1 do
            cells[x, y-1].assign(ms.cells[x, y]);
          cells[x, height-1].clear;
        end;
        mouseY := mouseY-1;
      end;
      kmdDown: begin
        for x := 0 to width-1 do begin
          for y := 0 to height-2 do
            cells[x, y+1].assign(ms.cells[x, y]);
          cells[x, 0].clear;
        end;
        mouseY := mouseY+1;
      end;
    end;
  finally
    freeAndNil(ms);
    updated;
  end;
end;

function tKlausMouseSetting.getCells(x, y: integer): tKlausMouseCell;
begin
  if (x < 0) or (x >= width) or (y < 0) or (y >= height) then raise eKlausError.createFmt(ercInvalidCellIndex, zeroSrcPt, [x, y]);
  result := fCells[y, x];
end;

function tKlausMouseSetting.getHere: tKlausMouseCell;
begin
  result := cells[mouseX, mouseY];
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
  if val = kmdHere then val := fMouseDir;
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
  inherited;
  if dest is tKlausMouseSetting then
    with dest as tKlausMouseSetting do begin
      width := self.width;
      height := self.height;
      for i := 0 to width - 1 do
        for j := 0 to height - 1 do
          cells[i, j].assign(self.cells[i, j]);
      mouseX := self.mouseX;
      mouseY := self.mouseY;
      mouseDir := self.mouseDir;
    end;
end;

{ tKlausDoerMouse }

constructor tKlausDoerMouse.create(aSource: tKlausSource);
begin
  inherited create(aSource);
  createVariables;
  createRoutines;
end;

class function tKlausDoerMouse.createSetting: tKlausDoerSetting;
begin
  result := tKlausMouseSetting.create(10, 10);
end;

class function tKlausDoerMouse.createView(aOwner: tComponent; mode: tKlausDoerViewMode): tKlausDoerView;
begin
  result := tKlausMouseView.create(aOwner);
  if mode <> kdvmEdit then begin
    result.readOnly := true;
    result.enabled := false;
    result.tabStop := false;
  end;
end;

class function tKlausDoerMouse.capabilities: tKlausDoerCapabilities;
begin
  result := [kdcImportSettings, kdcExportSettings];
end;

class procedure tKlausDoerMouse.importSettingsDlgSetup(dlg: tOpenDialog);
begin
  dlg.filter := strMouseSettingsImportFilter;
  dlg.defaultExt := strKlausDoerSettingFileExt;
end;

class procedure tKlausDoerMouse.importSettings(settings: tKlausDoerSettings; fileName: string);
var
  ext: string;
begin
  assert(settings.doerClass = self.classType, 'Cannot import settigns of this doer class.');
  ext := u8Lower(extractFileExt(fileName));
  if ext = u8Lower(strKlausDoerSettingFileExt) then importKlausMouseSettings(settings, fileName)
  else if ext = u8Lower(strKumirRobotSettingFileExt) then importKumirRobotSetting(settings, fileName)
  else raise eKlausError.createFmt(ercInvalidSettingFileType, zeroSrcPt, [ext]);
end;

class procedure tKlausDoerMouse.exportSettingsDlgSetup(dlg: tSaveDialog);
begin
  dlg.filter := strMouseSettingsExportFilter;
  dlg.defaultExt := strKlausDoerSettingFileExt;
end;

class procedure tKlausDoerMouse.exportSettings(settings: tKlausDoerSettings; fileName: string);
var
  obj: tJsonObject;
begin
  assert(settings.doerClass = self.classType, 'Cannot export settigns of this doer class.');
  obj := tJsonObject.create;
  try
    obj.add('doer', settings.doerClass.stdUnitName);
    obj.add('settigns', settings.toJson);
    saveJsonData(fileName, obj);
  finally
    freeAndNil(obj);
  end;
end;

procedure tKlausDoerMouse.runStep(frame: tKlausStackFrame; dir: tKlausInteger; at: tSrcPoint);
var
  b: boolean;
  ds: tKlausDoerSpeed;
  md: tKlausMouseDirection;
begin
  md := setting.turn(dir);
  if setting.here.wall[md] then
    raise eKlausError.createFmt(ercDoerFailure, at, [errMoveThroughWall]);
  if view.redrawDisabled then begin
    setting.mouseDir := md;
    view.nextStep(true);
  end else begin
    fIntParam[0] := integer(md);
    repeat
      frame.owner.synchronize(@syncNextStep);
      b := boolean(fIntParam[1]);
      ds := tKlausDoerSpeed(fIntParam[2]);
      sleep(mouseMovementDelay[ds]);
      if klausDebugThread <> nil then
        klausDebugThread.checkTerminated;
    until not b;
  end;
end;

procedure tKlausDoerMouse.syncNextStep;
var
  md: tKlausMouseDirection;
begin
  md := tKlausMouseDirection(fIntParam[0]);
  with setting do begin
    mouseDir := md;
    fIntParam[1] := integer(view.nextStep(false));
  end;
  fIntParam[2] := integer(klausDoerSpeed);
end;

procedure tKlausDoerMouse.runTurn(frame: tKlausStackFrame; dir: tKlausInteger; at: tSrcPoint);
begin
  fIntParam[0] := integer(setting.turn(dir));
  if view.redrawDisabled then syncTurn
  else frame.owner.synchronize(@syncTurn);
end;

procedure tKlausDoerMouse.syncTurn;
begin
  setting.mouseDir := tKlausMouseDirection(fIntParam[0]);
end;

procedure tKlausDoerMouse.runPaint(frame: tKlausStackFrame; at: tSrcPoint);
begin
  fIntParam[0] := integer(true);
  if view.redrawDisabled then syncPaint
  else frame.owner.synchronize(@syncPaint);
end;

procedure tKlausDoerMouse.runClear(frame: tKlausStackFrame; at: tSrcPoint);
begin
  fIntParam[0] := integer(false);
  if view.redrawDisabled then syncPaint
  else frame.owner.synchronize(@syncPaint);
end;

procedure tKlausDoerMouse.syncPaint;
begin
  setting.here.painted := boolean(fIntParam[0]);
end;

class procedure tKlausDoerMouse.importKlausMouseSettings(settings: tKlausDoerSettings; fileName: string);
var
  arr: tJsonArray;
  obj: tJsonData;
  s: string;
begin
  obj := loadJsonData(fileName);
  try
    if not (obj is tJsonObject) then raise eKlausError.create(ercInvalidSettingFileFmt, zeroSrcPt);
    s := (obj as tJsonObject).get('doer', '');
    if s = '' then raise eKlausError.create(ercInvalidSettingFileFmt, zeroSrcPt);
    if u8Lower(s) <> u8Lower(settings.doerClass.stdUnitName) then raise eKlausError.createFmt(ercWrongDoerSettingClass, zeroSrcPt, [s]);
    arr := (obj as tJsonObject).find('settigns', jtArray) as tJsonArray;
    if arr = nil then raise eKlausError.create(ercInvalidSettingFileFmt, zeroSrcPt);
    settings.fromJson(arr);
  finally
    freeAndNil(obj);
  end;
end;

class procedure tKlausDoerMouse.importKumirRobotSetting(settings: tKlausDoerSettings; fileName: string);
var
  i, n: integer;
  idx: integer = 0;
  sl: tStringList;
  s: string;
  sa: tStringArray;
  p: tPoint;
  ms: tKlausMouseSetting;
begin
  assert(settings.doerClass = self.classType, 'Invalid setting class');
  ms := settings.add as tKlausMouseSetting;
  try
    ms.updating;
    sl := tStringList.create;
    try
      sl.loadFromFile(fileName);
      for i := 0 to sl.count-1 do begin
        s := trim(sl[i]);
        if s = '' then continue;
        if s[1] = ';' then continue;
        try
          case idx of
            0: begin // размеры поля
              sa := s.split(' ');
              if length(sa) < 2 then raise eKlausError.create(ercInvalidFileFormat, zeroSrcPt);
              ms.width := strToInt(sa[0]);
              ms.height := strToInt(sa[1]);
              inc(idx);
            end;
            1: begin // положение Мышки
              sa := s.split(' ');
              if length(sa) < 2 then raise eKlausError.create(ercInvalidFileFormat, zeroSrcPt);
              ms.mouseX := strToInt(sa[0]);
              ms.mouseY := strToInt(sa[1]);
              inc(idx);
            end;
            else begin // свойства клеток
              sa := s.split(' ');
              if length(sa) < 8 then raise eKlausError.create(ercInvalidFileFormat, zeroSrcPt);
              p.x := strToInt(sa[0]);
              p.y := strToInt(sa[1]);
              with ms[p.x, p.y] do begin
                n := strToint(sa[2]);
                if (n and 1) > 0 then wall[kmdLeft] := true;
                if (n and 2) > 0 then wall[kmdRight] := true;
                if (n and 4) > 0 then wall[kmdDown] := true;
                if (n and 8) > 0 then wall[kmdUp] := true;
                n := strToint(sa[3]);
                painted := n > 0;
                radiation := strToFloat(sa[4].replace(',', '.'));
                temperature := strToFloat(sa[5].replace(',', '.'));
                text1 := sa[6].replace('$', '');
                text2 := sa[7].replace('$', '');
                if length(sa) > 8 then begin
                  n := strToInt(sa[8]);
                  mark := n > 0;
                end;
              end;
              inc(idx);
            end;
          end;
        except
          on e: exception do begin
            e.message := format(strAtLine, [e.message]);
            raise;
          end;
        end;
      end;
    finally
      freeAndNil(sl);
      ms.updated;
    end;
  except
    settings.remove(ms);
    raise;
  end;
end;

procedure tKlausDoerMouse.createVariables;
begin
  tKlausConstDecl.create(self, [klausConstName_MouseLeft, klausConstName_MouseLeft2, klausConstName_MouseLeft3], zeroSrcPt, klausSimpleI(klausConst_MouseLeft));
  tKlausConstDecl.create(self, [klausConstName_MouseRight, klausConstName_MouseRight2, klausConstName_MouseRight3], zeroSrcPt, klausSimpleI(klausConst_MouseRight));
  tKlausConstDecl.create(self, [klausConstName_MouseFwd, klausConstName_MouseFwd2, klausConstName_MouseFwd3], zeroSrcPt, klausSimpleI(klausConst_MouseFwd));
  tKlausConstDecl.create(self, [klausConstName_MouseBack, klausConstName_MouseBack2], zeroSrcPt, klausSimpleI(klausConst_MouseBack));
  tKlausConstDecl.create(self, [klausConstName_MouseWest, klausConstName_MouseWest2], zeroSrcPt, klausSimpleI(klausConst_MouseWest));
  tKlausConstDecl.create(self, [klausConstName_MouseNorth, klausConstName_MouseNorth2], zeroSrcPt, klausSimpleI(klausConst_MouseNorth));
  tKlausConstDecl.create(self, [klausConstName_MouseEast, klausConstName_MouseEast2], zeroSrcPt, klausSimpleI(klausConst_MouseEast));
  tKlausConstDecl.create(self, [klausConstName_MouseSouth, klausConstName_MouseSouth2], zeroSrcPt, klausSimpleI(klausConst_MouseSouth));
end;

procedure tKlausDoerMouse.createRoutines;
begin
  tKlausSysProc_MouseLoadSetting.create(self, zeroSrcPt);
  tKlausSysProc_MouseStep.create(self, zeroSrcPt);
  tKlausSysProc_MouseTurn.create(self, zeroSrcPt);
  tKlausSysProc_MousePaint.create(self, zeroSrcPt);
  tKlausSysProc_MouseClear.create(self, zeroSrcPt);
  tKlausSysProc_MouseWall.create(self, zeroSrcPt);
  tKlausSysProc_MousePainted.create(self, zeroSrcPt);
  tKlausSysProc_MouseArrow.create(self, zeroSrcPt);
  tKlausSysProc_MouseHasNumber.create(self, zeroSrcPt);
  tKlausSysProc_MouseNumber.create(self, zeroSrcPt);
  tKlausSysProc_MouseTemperature.create(self, zeroSrcPt);
  tKlausSysProc_MouseRadiation.create(self, zeroSrcPt);
end;

function tKlausDoerMouse.getSetting: tKlausMouseSetting;
begin
  result := inherited setting as tklausMouseSetting;
end;

function tKlausDoerMouse.getView: tKlausMouseView;
begin
  result := inherited view as tKlausMouseView;
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

procedure tKlausMouseViewColors.setTemperature(val: tColor);
begin
  if fTemperature <> val then begin
    updating;
    try fTemperature := val;
    finally updated; end;
  end;
end;

procedure tKlausMouseViewColors.setRadiation(val: tColor);
begin
  if fRadiation <> val then begin
    updating;
    try fRadiation := val;
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
        temperature := self.temperature;
        radiation := self.radiation;
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
  fTemperature := clRed;
  fRadiation := clBlue;
end;

{ tKlausMouseImageCache }

function tKlausMouseImageCache.getImg(dir: tKlausMouseDirection; idx: integer): tGraphic;
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
      // Здесь можно было бы закешировать набор картинок нужного размера,
      // но средствами стандартной библиотеки это сделать невозможно,
      // а BGRABitmap не собирается под Alt Linux.
      // Поэтому только canvas.stretchDraw(), только хардкор!
    end;
  end;
end;

procedure tKlausMouseImageCache.draw(canvas: tCanvas; cell: tRect; dir: tKlausMouseDirection; idx: integer);
var
  r: tRect;
  x: integer = 0;
  y: integer = 0;
begin
  if dir < kmdLeft then dir := kmdLeft;
  rebuild(cell.width - (cell.width div 10)*3);
  with fFit do
    case dir of
      kmdLeft: begin
        r := rect(top, fWidth - right, bottom, fWidth - left);
        x := cell.left - r.left + cell.width div 10;
        y := cell.top - r.top + cell.height div 2 - r.height div 2;
        canvas.stretchDraw(rect(x, y, x+fHeight, y+fWidth), mousePNG[dir, idx]);
      end;
      kmdUp: begin
        r := rect(left, top, right, bottom);
        x := cell.left - r.left + cell.width div 2 - r.width div 2;
        y := cell.top - r.top + cell.height div 10;
        canvas.stretchDraw(rect(x, y, x+fWidth, y+fHeight), mousePNG[dir, idx]);
      end;
      kmdRight: begin
        r := rect(fHeight - bottom, left, fHeight - top, right);
        x := cell.right - r.width - r.left - cell.Width div 10;
        y := cell.top - r.top + cell.height div 2 - r.height div 2;
        canvas.stretchDraw(rect(x, y, x+fHeight, y+fWidth), mousePNG[dir, idx]);
      end;
      kmdDown: begin
        r := rect(fWidth - right, fHeight - bottom, fWidth - left, fHeight - top);
        x := cell.left - r.left + cell.width div 2 - r.width div 2;
        y := cell.bottom - r.height - r.top - cell.height div 10;
        canvas.stretchDraw(rect(x, y, x+fWidth, y+fHeight), mousePNG[dir, idx]);
      end;
    end;
end;

{ tKlausMouseView }

constructor tKlausMouseView.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  fCellSize := klausMouseMinCellSize;
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

procedure tKlausMouseView.invalidate;
begin
  if not redrawDisabled then inherited;
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

function tKlausMouseView.nextStep(immediate: boolean): boolean;
const
  dx: array[tKlausMouseDirection] of integer = (0, -1, 0, 1, 0);
  dy: array[tKlausMouseDirection] of integer = (0, 0, -1, 0, 1);
var
  shx, shy: integer;
begin
  if setting = nil then exit(false);
  shx := dx[setting.mouseDir] * (fCellSize div mouseImageInfo.count);
  shy := dy[setting.mouseDir] * (fCellSize div mouseImageInfo.count);
  inc(fPhase);
  result := not immediate and (fPhase < mouseImageInfo.count);
  if not result then begin
    fPhase := 0;
    fShiftX := 0;
    fShiftY := 0;
    with setting do begin
      mouseX := mouseX + dx[mouseDir];
      mouseY := mouseY + dy[mouseDir];
    end;
  end else begin
    fShiftX += shx;
    fShiftY += shy;
  end;
  invalidate;
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
    resetNumericInput;
    invalidate;
  end;
end;

procedure tKlausMouseView.setFocusY(val: integer);
begin
  if setting = nil then val := -1
  else val := min(setting.height-1, max(val, 0));
  if fFocusY <> val then begin
    fFocusY := val;
    resetNumericInput;
    invalidate;
  end;
end;

procedure tKlausMouseView.setMode(val: tKlausMouseViewMode);
begin
  if fMode <> val then begin
    fMode := val;
    resetNumericInput;
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

procedure tKlausMouseView.resetNumericInput;
begin
  fKeyPressed := kpNone;
  fInputText := '';
end;

procedure tKlausMouseView.doExit;
begin
  resetNumericInput;
  inherited
end;

procedure tKlausMouseView.WMSetFocus(var Msg: tMessage);
begin
  resetNumericInput;
  invalidate;
  inherited;
end;

procedure tKlausMouseView.WMKillFocus(var Msg: tMessage);
begin
  resetNumericInput;
  invalidate;
  inherited;
end;

procedure tKlausMouseView.paint;
const
  bullet = ' • ';
  arrows: array[tKlausMouseDirection] of u8Char = ('', '←', '↑', '→', '↓');
  {$ifdef windows}
  scale = 1.3;
  {$else}
  scale = 1;
  {$endif}
var
  r: tRect;
  sz: tSize;
  s: string;
  x, y, w, h: integer;
  n: double;
begin
  r := clientRect;
  r.inflate(-3, -3);
  with canvas do begin
    with brush do begin style := bsSolid; color := self.color; end;
    fillRect(r);
  end;
  if setting = nil then exit;
  if running and (klausDoerSpeed = kdsImmediate) then
    with canvas do begin
      font := self.font;
      sz := textExtent(strProgramRunning);
      textOut(r.left+(r.width-sz.cx) div 2, r.top+(r.height-sz.cy) div 2, strProgramRunning);
      exit;
    end;
  fCellSize := min(klausMouseMaxCellSize, max(klausMouseMinCellSize,
    min(r.width div setting.width, r.height div setting.height)));
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
    font.style := [];
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
        font.color := self.colors.cellText;
        with setting[x, y] do begin
          if (text1 <> '') or (text2 <> '') or mark then begin
            font.height := round(scale * fCellSize / 2.2);
            if text1 <> '' then
              textOut(r.left + fCellSize div 10, r.top, setting[x, y].text1);
            if text2 <> '' then begin
              sz := textExtent(text2);
              textOut(r.left + fCellSize div 10, r.bottom - sz.cy, setting[x, y].text2);
            end;
            if mark then begin
              sz := textExtent(bullet);
              textOut(r.right - sz.cx - fCellSize div 10, r.bottom - sz.cy, bullet);
            end;
          end;
          if hasNumber then begin
            s := intToStr(number);
            if length(s) > 2 then font.height := round(scale * fCellSize / 3)
            else font.height := round(scale * fCellSize / 2.5);
            sz := textExtent(s);
            textOut(r.right - sz.cx - fCellSize div 10, r.top, s);
          end;
          s := arrows[arrow];
          if s <> '' then begin
            font.height := round(scale * fCellSize / 2);
            sz := textExtent(s);
            case arrow of
              kmdLeft: textOut(r.left - fCellSize div 10, r.top + (r.height-sz.cy) div 2, s);
              kmdUp: textOut(r.left + (r.width-sz.cx) div 2, r.top - fCellSize div 10, s);
              kmdRight: textOut(r.right - sz.cx + fCellSize div 10 + 1, r.top + (r.height-sz.cy) div 2, s);
              kmdDown: textOut(r.left + (r.width-sz.cx) div 2, r.bottom - sz.cy + fCellSize div 10 + 1, s);
            end;
          end;
          if mode <> mvmNormal then begin
            case mode of
              mvmTemperature: begin
                n := temperature;
                font.color := self.colors.temperature;
              end;
              mvmRadiation: begin
                n := radiation;
                font.color := self.colors.radiation;
              end;
            else
              n := 0;
            end;
            s := format('%.4g', [n]);
            font.height := round(scale * fCellSize / max(3, length(s)/2));
            sz := textExtent(s);
            textOut(r.left + (r.width-sz.cx) div 2, r.top + (r.height-sz.cy) div 2, s);
          end;
        end;
      end;
    line(fOrigin.x, fOrigin.y, fOrigin.x+w, fOrigin.y);
    line(fOrigin.x, fOrigin.y+h, fOrigin.x+w, fOrigin.y+h);
    line(fOrigin.x, fOrigin.y, fOrigin.x, fOrigin.y+h);
    line(fOrigin.x+w, fOrigin.y, fOrigin.x+w, fOrigin.y+h);
    r := cellRect(setting.mouseX, setting.mouseY);
    r.offset(fShiftX, fShiftY);
    fImg.draw(canvas, r, setting.mouseDir, fPhase);
    if focused and not readOnly and (focusX >= 0) and (focusY >= 0) then begin
      r := cellRect(focusX, focusY);
      r.inflate(-fCellSize div 10, -fCellSize div 10);
      r.left := r.left + 1;
      r.top := r.top + 1;
      {$ifdef windows}
      drawFocusRect(r);
      {$else}
      with pen do begin color := self.colors.wallSet; width := 1; style := psDot; end;
      brush.style := bsClear;
      rectangle(r);
      {$endif}
    end;
  end;
end;

procedure tKlausMouseView.setSetting(aSetting: tKlausDoerSetting);
begin
  resetNumericInput;
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
  resetNumericInput;
  if canFocus then setFocus;
  inherited mouseDown(button, shift, x, y);
  shift := shift * [ssShift, ssCtrl, ssAlt, ssDouble];
  if (setting <> nil) and not readOnly then begin
    cell := cellFromPoint(x, y);
    focusX := cell.x;
    focusY := cell.y;
    if mode = mvmNormal then begin
      with setting do mouseHere := (mouseX = cell.x) and (mouseY = cell.y);
      r := cellRect(focusX, focusY);
      with setting[focusX, focusY] do
        if abs(r.left-x) <= fCellSize div 5 then begin
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
end;

procedure tKlausMouseView.keyDown(var key: word; shift: tShiftState);
var
  x, y: integer;
begin
  x := focusX;
  y := focusY;
  if (setting = nil) or readOnly or (x < 0) or (y < 0) then begin
    inherited;
    exit;
  end;
  with setting[x, y] do case key of
    VK_LEFT: if shift = [] then begin
      focusX := x - 1;
      key := 0;
    end else if mode = mvmNormal then begin
      if shift = [ssShift] then begin
        wall[kmdLeft] := not wall[kmdLeft];
        key := 0;
      end else if shift = [ssCtrl] then begin
        toggleArrow(kmdLeft);
        key := 0;
      end else if shift = [ssAlt] then begin
        setting.mouseDir := kmdLeft;
        key := 0;
      end;
    end;
    VK_RIGHT: if shift = [] then begin
      focusX := x + 1;
      key := 0;
    end else if mode = mvmNormal then begin
      if shift = [ssShift] then begin
        wall[kmdRight] := not wall[kmdRight];
        key := 0;
      end else if shift = [ssCtrl] then begin
        toggleArrow(kmdRight);
        key := 0;
      end else if shift = [ssAlt] then begin
        setting.mouseDir := kmdRight;
        key := 0;
      end;
    end;
    VK_UP: if shift = [] then begin
      focusY := y - 1;
      key := 0;
    end else if mode = mvmNormal then begin
      if shift = [ssShift] then begin
        wall[kmdUp] := not wall[kmdUp];
        key := 0;
      end else if shift = [ssCtrl] then begin
        toggleArrow(kmdUp);
        key := 0;
      end else if shift = [ssAlt] then begin
        setting.mouseDir := kmdUp;
        key := 0;
      end;
    end;
    VK_DOWN: if shift = [] then begin
      focusY := y + 1;
      key := 0;
    end else if mode = mvmNormal then begin
      if shift = [ssShift] then begin
        wall[kmdDown] := not wall[kmdDown];
        key := 0;
      end else if shift = [ssCtrl] then begin
        toggleArrow(kmdDown);
        key := 0;
      end else if shift = [ssAlt] then begin
        setting.mouseDir := kmdDown;
        key := 0;
      end;
    end;
    VK_DELETE, VK_BACK: if shift = [] then begin
      if mode = mvmNormal then begin
        text1 := '';
        text2 := '';
        hasNumber := false;
        key := 0;
      end else if key = VK_DELETE then begin
        case mode of
          mvmTemperature: temperature := 0;
          mvmRadiation: radiation := 0;
        end;
        resetNumericInput;
      end;
    end;
    VK_SPACE: if (shift = []) and (mode = mvmNormal) then begin
      painted := not painted;
      key := 0;
    end;
    VK_RETURN: if (shift = []) and (mode = mvmNormal) then begin
      setting.mouseX := x;
      setting.mouseY := y;
      key := 0;
    end;
  end;
  if key = 0 then resetNumericInput else inherited;
end;

procedure tKlausMouseView.UTF8KeyPress(var key: tUTF8Char);
const
  validChars = '-0123456789.,';
var
  c: char;
  f: double;
  b: boolean;
  x, y, n: integer;
begin
  if (setting <> nil) and not readOnly then begin
    x := focusX;
    y := focusY;
    if (x < 0) or (y < 0) then exit;
    if mode <> mvmNormal then begin
      if key = #13 then
        resetNumericInput
      else if (pos(key, validChars) > 0) or (key = #8) then begin
        if key = #8 then begin
          if fInputText <> '' then
            fInputText := copy(fInputText, 1, length(fInputText)-1);
        end else begin
          c := key[1];
          case c of
            '-': if fInputText = '' then fInputText += '-';
            '.', ',': if pos('.', fInputText) = 0 then fInputText += '.';
            else fInputText += key;
          end;
        end;
        b := true;
        if fInputText = '' then f := 0
        else b := tryStrToFloat(fInputText, f);
        if b then
          case mode of
            mvmTemperature: setting[x, y].temperature := f;
            mvmRadiation: setting[x, y].radiation := f;
          end;
      end;
    end else if key > ' ' then begin
      if key = '.' then begin
        resetNumericInput;
        with setting[x, y] do mark := not mark;
      end else if ((key >= 'A') and (key <= 'Z'))
      or ((key >= 'А') and (key <= 'Я')) then begin
        resetNumericInput;
        with setting[x, y] do
          if u8Upper(text1) = u8Upper(key) then text1 := '' else text1 := key;
      end else if ((key >= 'a') and (key <= 'z'))
      or ((key >= 'а') and (key <= 'я')) then begin
        resetNumericInput;
        with setting[x, y] do
          if u8Upper(text2) = u8Upper(key) then text2 := '' else text2 := key;
      end else if key = '-' then begin
        fKeyPressed := kpMinus;
        setting[x, y].hasNumber := false;
      end else if ((key >= '0') and (key <= '9')) then begin
        if not setting[x, y].hasNumber then begin
          n := strToInt(key);
          if fKeyPressed = kpMinus then n := -n;
          fKeyPressed := kpDigit;
        end else begin
          n := setting[x, y].number;
          if (n < -9) or (n > 9) or (fKeyPressed <> kpDigit) then begin
            n := strToInt(key);
            fKeyPressed := kpDigit;
          end else begin
            n := n * 10 + sign(n)*strToInt(key);
            resetNumericInput;
          end;
        end;
        setting[x, y].number := n;
      end;
    end;
  end;
end;

procedure tKlausMouseView.change;
begin
  if not redrawDisabled then inherited;
end;

function tKlausMouseView.redrawDisabled: boolean;
begin
  result := running and (klausDoerSpeed = kdsImmediate);
end;

class function tKlausMouseView.doerClass: tKlausDoerClass;
begin
  result := tKlausDoerMouse;
end;

{ tKlausSysProc_MouseLoadSetting }

constructor tKlausSysProc_MouseLoadSetting.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_MouseLoadSetting, aPoint);
  fName := tKlausProcParam.create(self, 'файл', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  fIdx := tKlausProcParam.create(self, 'индекс', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fIdx);
end;

procedure tKlausSysProc_MouseLoadSetting.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  idx: tKlausInteger;
  stng: tKlausDoerSettings;
begin
  idx := getSimpleInt(frame, fIdx, at);
  stng := tKlausDoerSettings.create(tKlausDoerClass(owner.classType));
  try
    (owner as tKlausDoerMouse).importSettings(stng, getSimpleStr(frame, fName, at));
    if (idx < 0) or (idx >= stng.count) then raise eKlausError.createFmt(ercInvalidListIndex, at, [idx]);
    (owner as tKlausDoerMouse).setting.assign(stng[idx]);
  finally
    freeAndNil(stng);
  end;
end;

{ tKlausSysProc_MouseStep }

constructor tKlausSysProc_MouseStep.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_MouseStep, aPoint);
end;

function tKlausSysProc_MouseStep.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_MouseStep.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt <> 0) and (cnt <> 1) then
    raise eKlausError.createFmt(ercWrongNumberOfParams, at, [cnt, format(strNumOrNum, [0, 1])]);
  if cnt > 0 then checkCanAssign(kdtInteger, expr[0].resultTypeDef, expr[0].point);
end;

procedure tKlausSysProc_MouseStep.getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_MouseStep.customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  dir: tKlausInteger;
begin
  cnt := length(values);
  if (cnt <> 0) and (cnt <> 1) then
    raise eKlausError.createFmt(ercWrongNumberOfParams, at, [cnt, format(strNumOrNum, [0, 1])]);
  if cnt > 0 then dir := getSimpleInt(values[0]) else dir := klausConst_MouseHere;
  (owner as tKlausDoerMouse).runStep(frame, dir, at);
end;

{ tKlausSysProc_MouseTurn }

constructor tKlausSysProc_MouseTurn.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_MouseTurn, aPoint);
  fDir := tKlausProcParam.create(self, 'куда', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fDir);
end;

procedure tKlausSysProc_MouseTurn.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  dir: tKlausInteger;
begin
  dir := getSimpleInt(frame, fDir, at);
  (owner as tKlausDoerMouse).runTurn(frame, dir, at);
end;

{ tKlausSysProc_MousePaint }

constructor tKlausSysProc_MousePaint.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_MousePaint, aPoint);
end;

procedure tKlausSysProc_MousePaint.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  (owner as tKlausDoerMouse).runPaint(frame, at);
end;

{ tKlausSysProc_MouseClear }

constructor tKlausSysProc_MouseClear.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_MouseClear, aPoint);
end;

procedure tKlausSysProc_MouseClear.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  (owner as tKlausDoerMouse).runClear(frame, at);
end;

{ tKlausSysProc_MouseWall }

constructor tKlausSysProc_MouseWall.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_MouseWall, aPoint);
  declareRetValue(kdtBoolean);
end;

function tKlausSysProc_MouseWall.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_MouseWall.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt <> 0) and (cnt <> 1) then
    raise eKlausError.createFmt(ercWrongNumberOfParams, at, [cnt, format(strNumOrNum, [0, 1])]);
  if cnt > 0 then checkCanAssign(kdtInteger, expr[0].resultTypeDef, expr[0].point);
end;

procedure tKlausSysProc_MouseWall.getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_MouseWall.customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  dir: tKlausInteger;
  md: tKlausMouseDirection;
begin
  cnt := length(values);
  if (cnt <> 0) and (cnt <> 1) then
    raise eKlausError.createFmt(ercWrongNumberOfParams, at, [cnt, format(strNumOrNum, [0, 1])]);
  if cnt > 0 then dir := getSimpleInt(values[0]) else dir := klausConst_MouseFwd;
  with (owner as tKlausDoerMouse).setting do begin
    md := turn(dir);
    returnSimple(frame, klausSimpleB(here.wall[md]));
  end;
end;

{ tKlausSysProc_MousePainted }

constructor tKlausSysProc_MousePainted.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_MousePainted, aPoint);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_MousePainted.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleB((owner as tKlausDoerMouse).setting.here.painted));
end;

{ tKlausSysProc_MouseArrow }

constructor tKlausSysProc_MouseArrow.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_MouseArrow, aPoint);
  declareRetValue(kdtInteger);
end;

procedure tKlausSysProc_MouseArrow.run(frame: tKlausStackFrame; const at: tSrcPoint);
const
  dir: array[tKlausMouseDirection] of tKlausInteger = (
    klausConst_MouseHere, klausConst_MouseWest, klausConst_MouseNorth, klausConst_MouseEast, klausConst_MouseSouth);
var
  md: tKlausMouseDirection;
begin
  md := (owner as tKlausDoerMouse).setting.here.arrow;
  returnSimple(frame, klausSimpleI(dir[md]));
end;

{ tKlausSysProc_MouseHasNumber }

constructor tKlausSysProc_MouseHasNumber.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_MouseHasNumber, aPoint);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_MouseHasNumber.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleB((owner as tKlausDoerMouse).setting.here.hasNumber));
end;

{ tKlausSysProc_MouseNumber }

constructor tKlausSysProc_MouseNumber.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_MouseNumber, aPoint);
  declareRetValue(kdtInteger);
end;

function tKlausSysProc_MouseNumber.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_MouseNumber.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt <> 0) and (cnt <> 1) then
    raise eKlausError.createFmt(ercWrongNumberOfParams, at, [cnt, format(strNumOrNum, [0, 1])]);
  if cnt > 0 then begin
    if not (source.simpleTypes[kdtInteger].canAssign(expr[0].resultTypeDef)
    or source.simpleTypes[kdtBoolean].canAssign(expr[0].resultTypeDef)) then
      raise eKlausError.create(ercTypeMismatch, expr[0].point);
  end;
end;

procedure tKlausSysProc_MouseNumber.getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_MouseNumber.customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  n: tKlausInteger;
  b: tKlausBoolean;
begin
  cnt := length(values);
  if (cnt <> 0) and (cnt <> 1) then
    raise eKlausError.createFmt(ercWrongNumberOfParams, at, [cnt, format(strNumOrNum, [0, 1])]);
  returnSimple(frame, klausSimpleI((owner as tKlausDoerMouse).setting.here.number));
  if cnt > 0 then begin
    if source.simpleTypes[kdtInteger].canAssign(values[0].v.dataType) then begin
      n := getSimpleInt(values[0]);
      (owner as tKlausDoerMouse).setting.here.number := n;
    end else if source.simpleTypes[kdtBoolean].canAssign(values[0].v.dataType) then begin
      b := getSimpleBool(values[0]);
      (owner as tKlausDoerMouse).setting.here.hasNumber := b;
    end else
      raise eKlausError.create(ercTypeMismatch, values[0].at);
  end;
end;

{ tKlausSysProc_MouseTemperature }

constructor tKlausSysProc_MouseTemperature.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_MouseTemperature, aPoint);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_MouseTemperature.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleF((owner as tKlausDoerMouse).setting.here.temperature));
end;

{ tKlausSysProc_MouseRadiation }

constructor tKlausSysProc_MouseRadiation.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_MouseRadiation, aPoint);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_MouseRadiation.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleF((owner as tKlausDoerMouse).setting.here.radiation));
end;

{ Locals }

procedure loadMousePNG;
const
  dir: array[tKlausMouseDirection] of string = ('', 'w', 'n', 'e', 's');
var
  i: integer;
  d: tKlausMouseDirection;
  stream: tResourceStream;
begin
  for d := kmdLeft to kmdDown do begin
    setLength(mousePNG[d], mouseImageInfo.count);
    for i := 0 to mouseImageInfo.count-1 do begin
      stream := tResourceStream.create(hInstance, format(mouseImageInfo.resName, [i, dir[d]]), RT_RCDATA);
      try
        mousePNG[d, i] := tPortableNetworkGraphic.create;
        mousePNG[d, i].loadFromStream(stream);
      finally
        freeAndNil(stream);
      end;
    end;
  end;
end;

procedure freeMousePNG;
var
  i: integer;
  d: tKlausMouseDirection;
begin
  for d := kmdLeft to kmdDown do
    for i := 0 to mouseImageInfo.count-1 do
      freeAndNIL(mousePNG[d, i]);
end;

initialization
  klausRegisterStdUnit(tKlausDoerMouse);
  loadMousePNG;
finalization
  freeMousePNG
end.

