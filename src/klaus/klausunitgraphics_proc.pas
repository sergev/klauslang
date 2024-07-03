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

unit KlausUnitGraphics_Proc;

{$mode ObjFPC}{$H+}

interface

uses
  Types, Classes, SysUtils, U8, KlausErr, KlausLex, KlausDef, KlausSyn, KlausSrc,
  KlausUnitSystem, KlausUnitGraphics;

type
  // функция грОткрытьОкно(вх заголовок: строка): объект;
  tKlausSysProc_GrWindowOpen = class(tKlausSysProcDecl)
    private
      fCaption: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грУничтожить(вв холст: объект);
  tKlausSysProc_GrDestroy = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция грРазмер(вх холст: объект): Размер;
  // функция грРазмер(вх холст: объект; вх горз, верт: целое): Размер;
  tKlausSysProc_GrSize = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура грНачать(вх холст: объект);
  tKlausSysProc_GrBeginPaint = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грЗакончить(вх холст: объект);
  tKlausSysProc_GrEndPaint = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грПеро(вх холст: объект; вх цвет: целое);
  // процедура грПеро(вх холст: объект; вх цвет, толщина: целое);
  // процедура грПеро(вх холст: объект; вх цвет, толщина, стиль: целое);
  tKlausSysProc_GrPen = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура грКисть(вх холст: объект; вх цвет: целое);
  // процедура грКисть(вх холст: объект; вх цвет, стиль: целое);
  tKlausSysProc_GrBrush = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура грШрифт(вх холст: объект; вх цвет: целое);
  // процедура грШрифт(вх холст: объект; вх цвет, стиль: целое);
  // процедура грШрифт(вх холст: объект; вх цвет, стиль, размер: целое);
  // процедура грШрифт(вх холст: объект; вх цвет, стиль, размер: целое; вх имя: строка);
  tKlausSysProc_GrFont = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура грКруг(вх холст: объект; вх г, в, радиус: целое);
  tKlausSysProc_GrCircle = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
      fX, fY, fR: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грЭллипс(вх холст: объект; вх г1, в1, г2, в2: целое);
  tKlausSysProc_GrEllipse = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
      fX1, fY1, fX2, fY2: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грДуга(вх холст: объект; вх г1, в1, г2, в2: целое; вх начало, размер: дробное);
  tKlausSysProc_GrArc = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
      fX1, fY1, fX2, fY2: tKlausProcParam;
      fStart, fLength: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грСектор(вх холст: объект; вх г1, в1, г2, в2: целое; вх начало, размер: дробное);
  tKlausSysProc_GrSector = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
      fX1, fY1, fX2, fY2: tKlausProcParam;
      fStart, fLength: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грСегмент(вх холст: объект; вх г1, в1, г2, в2: целое; вх начало, размер: дробное);
  tKlausSysProc_GrChord = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
      fX1, fY1, fX2, fY2: tKlausProcParam;
      fStart, fLength: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грОтрезок(вх холст: объект; вх г1, в1, г2, в2: целое);
  tKlausSysProc_GrLine = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
      fX1, fY1, fX2, fY2: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грЛоманая(вх холст: объект; вх точки: МассивТочек);
  tKlausSysProc_GrPolyLine = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
      fPoints: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грПрямоугольник(вх холст: объект; вх г1, в1, г2, в2: целое);
  // процедура грПрямоугольник(вх холст: объект; вх г1, в1, г2, в2, р: целое);
  // процедура грПрямоугольник(вх холст: объект; вх г1, в1, г2, в2, рг, рв: целое);
  tKlausSysProc_GrRectangle = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура грМногоугольник(вх холст: объект; вх точки: МассивТочек);
  tKlausSysProc_GrPolygon = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
      fPoints: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция грТочка(вх холст: объект; вх г, в: целое): целое;
  // функция грТочка(вх холст: объект; вх г, в, цвет: целое): целое;
  tKlausSysProc_GrPoint = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция грРазмерТекста(вх холст: объект; вх текст: строка): Размер;
  tKlausSysProc_GrTextSize = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
      fText: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грТекст(вх холст: объект; вх г, в: целое; вх текст: строка);
  tKlausSysProc_GrText = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
      fX, fY: tKlausProcParam;
      fText: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грОбрезка(вх холст: объект; вх г1, в1, г2, в2: целое);
  // процедура грОбрезка(вх холст: объект; вх вкл: логическое);
  tKlausSysProc_GrClipRect = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура грИзоЗагрузить(вх имяФайла: строка);
  tKlausSysProc_GrImgLoad = class(tKlausSysProcDecl)
    private
      fFileName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция изоСоздать(вх источник: объект; вх г1, в1, г2, в2: целое): объект;
  tKlausSysProc_GrImgCreate = class(tKlausSysProcDecl)
    private
      fSource: tKlausProcParam;
      fX1, fY1, fX2, fY2: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грИзоСохранить(вх изо: объект);
  tKlausSysProc_GrImgSave = class(tKlausSysProcDecl)
    private
      fImg: tKlausProcParam;
      fFileName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура грИзоВывести(вх холст: объект; вх г, в: целое; вх изо: объект);
  tKlausSysProc_GrImgDraw = class(tKlausSysProcDecl)
    private
      fCanvas: tKlausProcParam;
      fImg: tKlausProcParam;
      fX, fY: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

implementation

uses
  Math, LCLIntf, Graphics, GraphType, GraphUtils, KlausUtils;

resourcestring
  strNumOrNum = '%d или %d';

{ tKlausSysProc_GrWindowOpen }

constructor tKlausSysProc_GrWindowOpen.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrWindowOpen, aPoint);
  fCaption := tKlausProcParam.create(self, 'заголовок', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fCaption);
  declareRetValue(kdtObject);
end;

procedure tKlausSysProc_GrWindowOpen.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  cap: tKlausString;
  rslt: tKlausObject;
begin
  cap := getSimpleStr(frame, fCaption, at);
  rslt := frame.owner.objects.allocate(tObject(klausInvalidPointer), at);
  try
    if klausCanvasLinkClass = nil then raise eKlausError.create(ercCanvasUnavailable, at);
    frame.owner.objects.put(rslt, klausCanvasLinkClass.create(frame.owner, cap), at);
    returnSimple(frame, klausSimpleObj(rslt));
  except
    frame.owner.objects.release(rslt, at);
    raise;
  end;
end;

{ tKlausSysProc_GrDestroy }

constructor tKlausSysProc_GrDestroy.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrDestroy, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInOut, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
end;

procedure tKlausSysProc_GrDestroy.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
begin
  h := getSimpleObj(frame, fCanvas, at);
  getKlausObject(frame, h, tKlausCanvasLink, at);
  frame.owner.objects.releaseAndFree(h, at);
  setSimple(frame, fCanvas, klausZeroValue(kdtObject), at);
end;

{ tKlausSysProc_GrSize }

constructor tKlausSysProc_GrSize.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrSize, aPoint);
  declareRetValue(findTypeDef(klausTypeName_Size));
end;

function tKlausSysProc_GrSize.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_GrSize.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt <> 1) and (cnt <> 3) then
    raise eKlausError.createFmt(ercWrongNumberOfParams, at, [cnt, format(strNumOrNum, [1, 3])]);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  if cnt > 1 then begin
    checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
    checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
  end;
end;

procedure tKlausSysProc_GrSize.getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_GrSize.customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  sz: tSize;
  v: tKlausVarValueStruct;
begin
  cnt := length(values);
  if (cnt <> 1) and (cnt <> 3) then
    raise eKlausError.createFmt(ercWrongNumberOfParams, at, [cnt, format(strNumOrNum, [1, 3])]);
  h := getSimpleObj(values[0]);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  if cnt =  1 then sz := cnv.getSize
  else begin
    sz.cx := getSimpleInt(values[1]);
    sz.cy := getSimpleInt(values[2]);
    sz := cnv.setSize(sz);
  end;
  v := frame.varByDecl(retValue, at).value as tKlausVarValueStruct;
  (v.getMember('г', at) as tKlausVarValueSimple).setSimple(klausSimple(tKlausInteger(sz.cx)), at);
  (v.getMember('в', at) as tKlausVarValueSimple).setSimple(klausSimple(tKlausInteger(sz.cy)), at);
end;

{ tKlausSysProc_GrBeginPaint }

constructor tKlausSysProc_GrBeginPaint.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrBeginPaint, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
end;

procedure tKlausSysProc_GrBeginPaint.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  cnv: tKlausCanvasLink;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  cnv.beginPaint;
end;

{ tKlausSysProc_GrEndPaint }

constructor tKlausSysProc_GrEndPaint.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrEndPaint, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
end;

procedure tKlausSysProc_GrEndPaint.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  cnv: tKlausCanvasLink;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  cnv.endPaint;
end;

{ tKlausSysProc_GrPen }

constructor tKlausSysProc_GrPen.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrPen, aPoint);
end;

function tKlausSysProc_GrPen.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_GrPen.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 2) or (cnt > 4) then errWrongParamCount(cnt, 2, 4, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
  if cnt > 2 then checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
  if cnt > 3 then checkCanAssign(kdtInteger, expr[3].resultTypeDef, expr[3].point);
end;

procedure tKlausSysProc_GrPen.getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_GrPen.customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
const
  penStyles: array[klausConst_psClear..klausConst_psDashDotDot] of tPenStyle = (
    psClear, psSolid, psDot, psDash, psDashDot, psDashDotDot);
var
  cnt, ps: integer;
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  what: tKlausPenProps;
  color: tColor = 0;
  style: tPenStyle = psSolid;
  width: tKlausInteger = 0;
begin
  cnt := length(values);
  if (cnt < 2) or (cnt > 4) then errWrongParamCount(cnt, 2, 4, at);
  h := getSimpleObj(values[0]);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  what := [kppColor];
  color := getSimpleInt(values[1]) and $FFFFFF;
  if cnt > 2 then begin
    include(what, kppWidth);
    width := getSimpleInt(values[2]);
  end;
  if cnt > 3 then begin
    include(what, kppStyle);
    ps := max(low(penStyles), min(high(penStyles), getSimpleInt(values[3])));
    style := penStyles[ps];
  end;
  cnv.setPenProps(what, color, width, style);
end;

{ tKlausSysProc_GrBrush }

constructor tKlausSysProc_GrBrush.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrBrush, aPoint);
end;

function tKlausSysProc_GrBrush.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_GrBrush.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 2) or (cnt > 3) then errWrongParamCount(cnt, 2, 3, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
  if cnt > 2 then checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
end;

procedure tKlausSysProc_GrBrush.getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_GrBrush.customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
const
  brushStyles: array[klausConst_bsClear..klausConst_bsSolid] of tBrushStyle = (bsClear, bsSolid);
var
  cnt, bs: integer;
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  what: tKlausBrushProps;
  color: tColor = 0;
  style: tBrushStyle = bsSolid;
begin
  cnt := length(values);
  if (cnt < 2) or (cnt > 3) then errWrongParamCount(cnt, 2, 3, at);
  h := getSimpleObj(values[0]);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  what := [kbpColor];
  color := getSimpleInt(values[1]) and $FFFFFF;
  if cnt > 2 then begin
    include(what, kbpStyle);
    bs := max(low(brushStyles), min(high(brushStyles), getSimpleInt(values[2])));
    style := brushStyles[bs];
  end;
  cnv.setBrushProps(what, color, style);
end;

{ tKlausSysProc_GrFont }

constructor tKlausSysProc_GrFont.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrFont, aPoint);
end;

function tKlausSysProc_GrFont.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_GrFont.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 2) or (cnt > 5) then errWrongParamCount(cnt, 2, 5, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
  if cnt > 2 then checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
  if cnt > 3 then checkCanAssign(kdtInteger, expr[3].resultTypeDef, expr[3].point);
  if cnt > 4 then checkCanAssign(kdtString, expr[4].resultTypeDef, expr[4].point);
end;

procedure tKlausSysProc_GrFont.getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_GrFont.customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt, fs: integer;
  w: tKlausObject;
  cnv: tKlausCanvasLink;
  what: tKlausFontProps;
  fontName: string = '';
  size: integer = 0;
  style: tFontStyles = [];
  color: tColor = 0;
begin
  cnt := length(values);
  if (cnt < 2) or (cnt > 5) then errWrongParamCount(cnt, 2, 5, at);
  w := getSimpleObj(values[0]);
  cnv := getKlausObject(frame, w, tKlausCanvasLink, at) as tKlausCanvasLink;
  what := [kfpColor];
  color := getSimpleInt(values[1]);
  if cnt > 2 then begin
    include(what, kfpStyle);
    fs := getSimpleInt(values[2]);
    if (fs and klausConst_FontBold) <> 0 then include(style, fsBold);
    if (fs and klausConst_FontItalic) <> 0 then include(style, fsItalic);
    if (fs and klausConst_FontUnderline) <> 0 then include(style, fsUnderline);
    if (fs and klausConst_FontStrikeOut) <> 0 then include(style, fsStrikeOut);
  end;
  if cnt > 3 then begin
    include(what, kfpSize);
    size := getSimpleInt(values[3]);
  end;
  if cnt > 4 then begin
    include(what, kfpName);
    fontName := getSimpleStr(values[4]);
  end;
  cnv.setFontProps(what, fontName, size, style, color);
end;

{ tKlausSysProc_GrCircle }

constructor tKlausSysProc_GrCircle.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrCircle, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
  fX := tKlausProcParam.create(self, 'г', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX);
  fY := tKlausProcParam.create(self, 'в', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY);
  fR := tKlausProcParam.create(self, 'радиус', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fR);
end;

procedure tKlausSysProc_GrCircle.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  x, y, r: tKlausInteger;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  x := getSimpleInt(frame, fX, at);
  y := getSimpleInt(frame, fY, at);
  r := getSimpleInt(frame, fR, at);
  cnv.ellipse(x-r, y-r, x+r, y+r);
end;

{ tKlausSysProc_GrEllipse }

constructor tKlausSysProc_GrEllipse.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrEllipse, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
  fX1 := tKlausProcParam.create(self, 'г1', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX1);
  fY1 := tKlausProcParam.create(self, 'в1', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY1);
  fX2 := tKlausProcParam.create(self, 'г2', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX2);
  fY2 := tKlausProcParam.create(self, 'в2', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY2);
end;

procedure tKlausSysProc_GrEllipse.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  x1, y1, x2, y2: tKlausInteger;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  x1 := getSimpleInt(frame, fX1, at);
  y1 := getSimpleInt(frame, fY1, at);
  x2 := getSimpleInt(frame, fX2, at);
  y2 := getSimpleInt(frame, fY2, at);
  cnv.ellipse(x1, y1, x2, y2);
end;

{ tKlausSysProc_GrArc }

constructor tKlausSysProc_GrArc.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrArc, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
  fX1 := tKlausProcParam.create(self, 'г1', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX1);
  fY1 := tKlausProcParam.create(self, 'в1', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY1);
  fX2 := tKlausProcParam.create(self, 'г2', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX2);
  fY2 := tKlausProcParam.create(self, 'в2', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY2);
  fStart := tKlausProcParam.create(self, 'начало', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fStart);
  fLength := tKlausProcParam.create(self, 'размер', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fLength);
end;

procedure tKlausSysProc_GrArc.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  x1, y1, x2, y2: tKlausInteger;
  start, len: tKlausFloat;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  x1 := getSimpleInt(frame, fX1, at);
  y1 := getSimpleInt(frame, fY1, at);
  x2 := getSimpleInt(frame, fX2, at);
  y2 := getSimpleInt(frame, fY2, at);
  start := getSimpleFloat(frame, fStart, at);
  len := getSimpleFloat(frame, fLength, at);
  cnv.arc(x1, y1, x2, y2, round(start/PI*180*16), round(len/PI*180*16));
end;

{ tKlausSysProc_GrSector }

constructor tKlausSysProc_GrSector.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrSector, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
  fX1 := tKlausProcParam.create(self, 'г1', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX1);
  fY1 := tKlausProcParam.create(self, 'в1', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY1);
  fX2 := tKlausProcParam.create(self, 'г2', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX2);
  fY2 := tKlausProcParam.create(self, 'в2', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY2);
  fStart := tKlausProcParam.create(self, 'начало', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fStart);
  fLength := tKlausProcParam.create(self, 'размер', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fLength);
end;

procedure tKlausSysProc_GrSector.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  x1, y1, x2, y2: tKlausInteger;
  start, len: tKlausFloat;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  x1 := getSimpleInt(frame, fX1, at);
  y1 := getSimpleInt(frame, fY1, at);
  x2 := getSimpleInt(frame, fX2, at);
  y2 := getSimpleInt(frame, fY2, at);
  start := getSimpleFloat(frame, fStart, at);
  len := getSimpleFloat(frame, fLength, at);
  cnv.sector(x1, y1, x2, y2, round(start/PI*180*16), round(len/PI*180*16));
end;

{ tKlausSysProc_GrChord }

constructor tKlausSysProc_GrChord.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrChord, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
  fX1 := tKlausProcParam.create(self, 'г1', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX1);
  fY1 := tKlausProcParam.create(self, 'в1', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY1);
  fX2 := tKlausProcParam.create(self, 'г2', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX2);
  fY2 := tKlausProcParam.create(self, 'в2', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY2);
  fStart := tKlausProcParam.create(self, 'начало', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fStart);
  fLength := tKlausProcParam.create(self, 'размер', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fLength);
end;

procedure tKlausSysProc_GrChord.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  x1, y1, x2, y2: tKlausInteger;
  start, len: tKlausFloat;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  x1 := getSimpleInt(frame, fX1, at);
  y1 := getSimpleInt(frame, fY1, at);
  x2 := getSimpleInt(frame, fX2, at);
  y2 := getSimpleInt(frame, fY2, at);
  start := getSimpleFloat(frame, fStart, at);
  len := getSimpleFloat(frame, fLength, at);
  cnv.chord(x1, y1, x2, y2, round(start/PI*180*16), round(len/PI*180*16));
end;

{ tKlausSysProc_GrLine }

constructor tKlausSysProc_GrLine.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrLine, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
  fX1 := tKlausProcParam.create(self, 'г1', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX1);
  fY1 := tKlausProcParam.create(self, 'в1', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY1);
  fX2 := tKlausProcParam.create(self, 'г2', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX2);
  fY2 := tKlausProcParam.create(self, 'в2', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY2);
end;

procedure tKlausSysProc_GrLine.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  x1, y1, x2, y2: tKlausInteger;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  x1 := getSimpleInt(frame, fX1, at);
  y1 := getSimpleInt(frame, fY1, at);
  x2 := getSimpleInt(frame, fX2, at);
  y2 := getSimpleInt(frame, fY2, at);
  cnv.line(x1, y1, x2, y2);
end;

{ tKlausSysProc_GrPolyLine }

constructor tKlausSysProc_GrPolyLine.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrPolyLine, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
  fPoints := tKlausProcParam.create(self, 'точки', aPoint, kpmInput, findTypeDef(klausTypeName_PointArray));
  addParam(fPoints);
end;

procedure tKlausSysProc_GrPolyLine.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  i: integer;
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  va: tKlausVarValueArray;
  vs: tKlausVarValueStruct;
  pts: tKlausPointArray = nil;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  va := frame.varByDecl(fPoints, at).value as tKlausVarValueArray;
  setLength(pts, va.count);
  for i := 0 to va.count-1 do begin
    vs := va.getElmt(i, at) as tKlausVarValueStruct;
    pts[i].x := (vs.getMember('г', at) as tKlausVarValueSimple).simple.iValue;
    pts[i].y := (vs.getMember('в', at) as tKlausVarValueSimple).simple.iValue;
  end;
  cnv.polyLine(pts);
end;

{ tKlausSysProc_GrPolygon }

constructor tKlausSysProc_GrPolygon.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrPolygon, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
  fPoints := tKlausProcParam.create(self, 'точки', aPoint, kpmInput, findTypeDef(klausTypeName_PointArray));
  addParam(fPoints);
end;

procedure tKlausSysProc_GrPolygon.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  i: integer;
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  va: tKlausVarValueArray;
  vs: tKlausVarValueStruct;
  pts: tKlausPointArray = nil;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  va := frame.varByDecl(fPoints, at).value as tKlausVarValueArray;
  setLength(pts, va.count);
  for i := 0 to va.count-1 do begin
    vs := va.getElmt(i, at) as tKlausVarValueStruct;
    pts[i].x := (vs.getMember('г', at) as tKlausVarValueSimple).simple.iValue;
    pts[i].y := (vs.getMember('в', at) as tKlausVarValueSimple).simple.iValue;
  end;
  cnv.polygone(pts);
end;

{ tKlausSysProc_GrRectangle }

constructor tKlausSysProc_GrRectangle.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrRectangle, aPoint);
end;

function tKlausSysProc_GrRectangle.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_GrRectangle.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 5) or (cnt > 7) then errWrongParamCount(cnt, 5, 7, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
  checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
  checkCanAssign(kdtInteger, expr[3].resultTypeDef, expr[3].point);
  checkCanAssign(kdtInteger, expr[4].resultTypeDef, expr[4].point);
  if cnt > 5 then checkCanAssign(kdtInteger, expr[5].resultTypeDef, expr[5].point);
  if cnt > 6 then checkCanAssign(kdtInteger, expr[6].resultTypeDef, expr[6].point);
end;

procedure tKlausSysProc_GrRectangle.getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_GrRectangle.customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  x1, y1, x2, y2, rx, ry: integer;
begin
  cnt := length(values);
  if (cnt < 5) or (cnt > 7) then errWrongParamCount(cnt, 5, 7, at);
  h := getSimpleObj(values[0]);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  x1 := getSimpleInt(values[1]);
  y1 := getSimpleInt(values[2]);
  x2 := getSimpleInt(values[3]);
  y2 := getSimpleInt(values[4]);
  if cnt > 5 then begin
    rx := getSimpleInt(values[5]);
    if cnt > 6 then ry := getSimpleInt(values[6]) else ry := rx;
    cnv.roundRect(x1, y1, x2, y2, rx, ry);
  end else
    cnv.rectangle(x1, y1, x2, y2);
end;

{ tKlausSysProc_GrPoint }

constructor tKlausSysProc_GrPoint.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrPoint, aPoint);
  declareRetValue(kdtInteger);
end;

function tKlausSysProc_GrPoint.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_GrPoint.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 3) or (cnt > 4) then errWrongParamCount(cnt, 3, 4, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
  checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
  if cnt > 3 then checkCanAssign(kdtInteger, expr[3].resultTypeDef, expr[3].point);
end;

procedure tKlausSysProc_GrPoint.getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_GrPoint.customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  x, y, color: integer;
begin
  cnt := length(values);
  if (cnt < 3) or (cnt > 4) then errWrongParamCount(cnt, 3, 4, at);
  h := getSimpleObj(values[0]);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  x := getSimpleInt(values[1]);
  y := getSimpleInt(values[2]);
  if cnt > 3 then begin
    color := getSimpleInt(values[3]);
    returnSimple(frame, klausSimple(tKlausInteger(cnv.setPoint(x, y, color))));
  end else
    returnSimple(frame, klausSimple(tKlausInteger(cnv.getPoint(x, y))));
end;

{ tKlausSysProc_GrTextSize }

constructor tKlausSysProc_GrTextSize.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrTextSize, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
  fText := tKlausProcParam.create(self, 'текст', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fText);
  declareRetValue(findTypeDef(klausTypeName_Size));
end;

procedure tKlausSysProc_GrTextSize.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  text: tKlausString;
  p: tPoint;
  v: tKlausVarValueStruct;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  text := getSimpleStr(frame, fText, at);
  p := cnv.textSize(text);
  v := frame.varByDecl(retValue, at).value as tKlausVarValueStruct;
  (v.getMember('г', at) as tKlausVarValueSimple).setSimple(klausSimple(tKlausInteger(p.x)), at);
  (v.getMember('в', at) as tKlausVarValueSimple).setSimple(klausSimple(tKlausInteger(p.y)), at);
end;

{ tKlausSysProc_GrText }

constructor tKlausSysProc_GrText.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrText, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
  fX := tKlausProcParam.create(self, 'г', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX);
  fY := tKlausProcParam.create(self, 'в', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY);
  fText := tKlausProcParam.create(self, 'текст', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fText);
  declareRetValue(findTypeDef(klausTypeName_Size));
end;

procedure tKlausSysProc_GrText.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  x, y: tKlausInteger;
  text: tKlausString;
  p: tPoint;
  v: tKlausVarValueStruct;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  x := getSimpleInt(frame, fX, at);
  y := getSimpleInt(frame, fY, at);
  text := getSimpleStr(frame, fText, at);
  p := cnv.textOut(x, y, text);
  v := frame.varByDecl(retValue, at).value as tKlausVarValueStruct;
  (v.getMember('г', at) as tKlausVarValueSimple).setSimple(klausSimple(tKlausInteger(p.x)), at);
  (v.getMember('в', at) as tKlausVarValueSimple).setSimple(klausSimple(tKlausInteger(p.y)), at);
end;

{ tKlausSysProc_GrClipRect }

constructor tKlausSysProc_GrClipRect.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrClipRect, aPoint);
end;

function tKlausSysProc_GrClipRect.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_GrClipRect.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt <> 2) and (cnt <> 5) then raise eKlausError.createFmt(ercWrongNumberOfParams, at, [cnt, format(strNumOrNum, [2, 5])]);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  if cnt = 5 then begin
    checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
    checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
    checkCanAssign(kdtInteger, expr[3].resultTypeDef, expr[3].point);
    checkCanAssign(kdtInteger, expr[4].resultTypeDef, expr[4].point);
  end else
    checkCanAssign(kdtBoolean, expr[1].resultTypeDef, expr[1].point);
end;

procedure tKlausSysProc_GrClipRect.getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_GrClipRect.customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  h: tKlausObject;
  cnv: tKlausCanvasLink;
  x1, y1, x2, y2: integer;
begin
  cnt := length(values);
  if (cnt <> 2) and (cnt <> 5) then raise eKlausError.createFmt(ercWrongNumberOfParams, at, [cnt, format(strNumOrNum, [2, 5])]);
  h := getSimpleObj(values[0]);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  if cnt = 5 then begin
    x1 := getSimpleInt(values[1]);
    y1 := getSimpleInt(values[2]);
    x2 := getSimpleInt(values[3]);
    y2 := getSimpleInt(values[4]);
    cnv.clipRect(x1, y1, x2, y2);
  end else
    cnv.setClipping(getSimpleBool(values[1]));
end;

{ tKlausSysProc_GrImgLoad }

constructor tKlausSysProc_GrImgLoad.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrImgLoad, aPoint);
  fFileName := tKlausProcParam.create(self, 'имяФайла', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fFileName);
  declareRetValue(kdtObject);
end;

procedure tKlausSysProc_GrImgLoad.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  fileName: tKlausString;
  lnk: tKlausCanvasLink;
  rslt: tKlausObject;
begin
  fileName := getSimpleStr(frame, fFileName, at);
  rslt := frame.owner.objects.allocate(tObject(klausInvalidPointer), at);
  try
    if klausPictureLinkClass = nil then raise eKlausError.create(ercCanvasUnavailable, at);
    lnk := klausPictureLinkClass.create(frame.owner);
    try
      lnk.loadFromFile(fileName);
      frame.owner.objects.put(rslt, lnk, at);
      returnSimple(frame, klausSimpleObj(rslt));
    except
      freeAndNil(lnk);
      raise;
    end;
  except
    frame.owner.objects.release(rslt, at);
    raise;
  end;
end;

{ tKlausSysProc_GrImgCreate }

constructor tKlausSysProc_GrImgCreate.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrImgCreate, aPoint);
  fSource := tKlausProcParam.create(self, 'источник', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fSource);
  fX1 := tKlausProcParam.create(self, 'г1', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX1);
  fY1 := tKlausProcParam.create(self, 'в1', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY1);
  fX2 := tKlausProcParam.create(self, 'г2', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX2);
  fY2 := tKlausProcParam.create(self, 'в2', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY2);
  declareRetValue(kdtObject);
end;

procedure tKlausSysProc_GrImgCreate.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  src: tKlausObject;
  srclnk: tKlausCanvasLink;
  lnk: tKlausCanvasLink;
  x1, y1, x2, y2: integer;
  rslt: tKlausObject;
begin
  src := getSimpleObj(frame, fSource, at);
  if src = 0 then srclnk := nil
  else srclnk := getKlausObject(frame, src, tKlausCanvasLink, at) as tKlausCanvasLink;
  x1 := getSimpleInt(frame, fX1, at);
  y1 := getSimpleInt(frame, fY1, at);
  x2 := getSimpleInt(frame, fX2, at);
  y2 := getSimpleInt(frame, fY2, at);
  rslt := frame.owner.objects.allocate(tObject(klausInvalidPointer), at);
  try
    if klausPictureLinkClass = nil then raise eKlausError.create(ercCanvasUnavailable, at);
    lnk := klausPictureLinkClass.create(frame.owner);
    try
      lnk.copyFrom(srclnk, x1, y1, x2, y2);
      frame.owner.objects.put(rslt, lnk, at);
      returnSimple(frame, klausSimpleObj(rslt));
    except
      freeAndNil(lnk);
      raise;
    end;
  except
    frame.owner.objects.release(rslt, at);
    raise;
  end;
end;

{ tKlausSysProc_GrImgSave }

constructor tKlausSysProc_GrImgSave.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrImgSave, aPoint);
  fImg := tKlausProcParam.create(self, 'изо', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fImg);
  fFileName := tKlausProcParam.create(self, 'имяФайла', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fFileName);
end;

procedure tKlausSysProc_GrImgSave.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  img: tKlausObject;
  lnk: tKlausCanvasLink;
  fileName: string;
begin
  img := getSimpleObj(frame, fImg, at);
  lnk := getKlausObject(frame, img, tKlausCanvasLink, at) as tKlausCanvasLink;
  fileName := getSimpleStr(frame, fFileName, at);
  lnk.saveToFile(fileName);
end;

{ tKlausSysProc_GrImgDraw }

constructor tKlausSysProc_GrImgDraw.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_GrImgDraw, aPoint);
  fCanvas := tKlausProcParam.create(self, 'холст', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fCanvas);
  fX := tKlausProcParam.create(self, 'г', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fX);
  fY := tKlausProcParam.create(self, 'в', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fY);
  fImg := tKlausProcParam.create(self, 'изо', aPoint, kpmInOut, source.simpleTypes[kdtObject]);
  addParam(fImg);
end;

procedure tKlausSysProc_GrImgDraw.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h, img: tKlausObject;
  cnv: tKlausCanvasLink;
  pic: tKlausCanvasLink;
  x, y: tKlausInteger;
begin
  h := getSimpleObj(frame, fCanvas, at);
  cnv := getKlausObject(frame, h, tKlausCanvasLink, at) as tKlausCanvasLink;
  img := getSimpleObj(frame, fImg, at);
  pic := getKlausObject(frame, img, tKlausCanvasLink, at) as tKlausCanvasLink;
  x := getSimpleInt(frame, fX, at);
  y := getSimpleInt(frame, fY, at);
  cnv.draw(x, y, pic);
end;

end.

