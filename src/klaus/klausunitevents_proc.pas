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

unit KlausUnitEvents_Proc;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, KlausErr, KlausLex, KlausDef, KlausSyn, KlausSrc,
  KlausUnitSystem, KlausUnitEvents;

type
  // процедура сбтЗаказать(вх где: объект; что: целое);
  tKlausSysProc_EvtSubscribe = class(tKlausSysProcDecl)
    private
      fWhere: tKlausProcParam;
      fWhat: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура сбтЕсть(вх где: объект): логическое;
  tKlausSysProc_EvtExists = class(tKlausSysProcDecl)
    private
      fWhere: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // Базовый класс для сбтЗабрать() и сбтСмотреть()
  tKlausSysProc_EvtRet = class(tKlausSysProcDecl)
    protected
      procedure returnEvent(frame: tKlausStackFrame; at: tSrcPoint; evt: tKlausEvent);
  end;

type
  // процедура сбтЗабрать(вх где: объект): Событие;
  tKlausSysProc_EvtGet = class(tKlausSysProc_EvtRet)
    private
      fWhere: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура сбтСколько(вх где: объект): целое;
  tKlausSysProc_EvtCount = class(tKlausSysProcDecl)
    private
      fWhere: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура сбтСмотреть(вх где: объект): Событие;
  tKlausSysProc_EvtPeek = class(tKlausSysProc_EvtRet)
    private
      fWhere: tKlausProcParam;
      fIndex: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

implementation

uses
  LCLIntf, Graphics, GraphType, GraphUtils, KlausUtils;

resourcestring
  strEventQueue = 'источник событий';

const
  klausEventWhatCode: array[tKlausEventType] of tKlausInteger = (
    klausConst_EvtKeyDown,
    klausConst_EvtKeyUp,
    klausConst_EvtKeyChar,
    klausConst_EvtMouseDown,
    klausConst_EvtMouseUp,
    klausConst_EvtMouseWheel,
    klausConst_EvtMouseEnter,
    klausConst_EvtMouseLeave,
    klausConst_EvtMouseMove);

const
  klausKeyStateCode: array[tKlausKeyState] of tKlausInteger = (
    klausConst_KeyStateShift,
    klausConst_KeyStateAlt,
    klausConst_KeyStateCtrl,
    klausConst_KeyStateLeft,
    klausConst_KeyStateRight,
    klausConst_KeyStateMiddle,
    klausConst_KeyStateDouble);

{ tKlausSysProc_EvtSubscribe }

constructor tKlausSysProc_EvtSubscribe.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_EvtSubscribe, aPoint);
  fWhere := tKlausProcParam.create(self, 'окно', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fWhere);
  fWhat := tKlausProcParam.create(self, 'что', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fWhat);
end;

procedure tKlausSysProc_EvtSubscribe.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  obj: tObject;
  cn: string;
  intf: iKlausEventQueue;
  what: tKlausInteger;
  evt: tKlausEventType;
  subscr: tKlausEventTypes = [];
begin
  h := getSimpleObj(frame, fWhere, at);
  obj := getKlausObject(frame, h, tObject, at);
  if not obj.getInterface(iidKlausEventQueue, intf) then begin
    cn := tKlausObjects.klausObjectName(obj.classType);
    raise eKlausError.createFmt(ercUnexpectedObjectClass, at, [strEventQueue, cn]);
  end;
  what := getSimpleInt(frame, fWhat, at);
  for evt := low(klausEventWhatCode) to high(klausEventWhatCode) do
    if (what and klausEventWhatCode[evt]) <> 0 then include(subscr, evt);
  intf.eventSubscribe(subscr);
end;

{ tKlausSysProc_EvtExists }

constructor tKlausSysProc_EvtExists.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_EvtExists, aPoint);
  fWhere := tKlausProcParam.create(self, 'окно', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fWhere);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_EvtExists.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  obj: tObject;
  cn: string;
  intf: iKlausEventQueue;
begin
  h := getSimpleObj(frame, fWhere, at);
  obj := getKlausObject(frame, h, tObject, at);
  if not obj.getInterface(iidKlausEventQueue, intf) then begin
    cn := tKlausObjects.klausObjectName(obj.classType);
    raise eKlausError.createFmt(ercUnexpectedObjectClass, at, [strEventQueue, cn]);
  end;
  returnSimple(frame, klausSimpleB(intf.eventExists));
end;

{ tKlausSysProc_EvtRet }

procedure tKlausSysProc_EvtRet.returnEvent(frame: tKlausStackFrame; at: tSrcPoint; evt: tKlausEvent);
var
  v: tKlausVarValueStruct;
  mv: tKlausVarValueSimple;
  k: tKlausKeyState;
  ks: tKlausInteger = 0;
begin
  v := frame.varByDecl(retValue, at).value as tKlausVarValueStruct;
  mv := v.getMember('что', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimpleI(klausEventWhatCode[evt.what]), at);
  mv := v.getMember('код', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimpleI(evt.code), at);
  for k := low(k) to high(k) do
    if k in evt.shift then ks := ks or klausKeyStateCode[k];
  mv := v.getMember('инфо', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimpleI(ks), at);
  mv := v.getMember('г', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimpleI(evt.point.x), at);
  mv := v.getMember('в', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimpleI(evt.point.y), at);
end;

{ tKlausSysProc_EvtGet }

constructor tKlausSysProc_EvtGet.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_EvtGet, aPoint);
  fWhere := tKlausProcParam.create(self, 'окно', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fWhere);
  declareRetValue(findTypeDef(klausTypeName_Event));
end;

procedure tKlausSysProc_EvtGet.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  obj: tObject;
  cn: string;
  intf: iKlausEventQueue;
  evt: tKlausEvent;
begin
  h := getSimpleObj(frame, fWhere, at);
  obj := getKlausObject(frame, h, tObject, at);
  if not obj.getInterface(iidKlausEventQueue, intf) then begin
    cn := tKlausObjects.klausObjectName(obj.classType);
    raise eKlausError.createFmt(ercUnexpectedObjectClass, at, [strEventQueue, cn]);
  end;
  if not intf.eventGet(evt) then raise eKlausError.create(ercEventQueueEmpty, at);
  returnEvent(frame, at, evt);
end;

{ tKlausSysProc_EvtCount }

constructor tKlausSysProc_EvtCount.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_EvtCount, aPoint);
  fWhere := tKlausProcParam.create(self, 'окно', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fWhere);
  declareRetValue(kdtInteger);
end;

procedure tKlausSysProc_EvtCount.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  obj: tObject;
  cn: string;
  intf: iKlausEventQueue;
begin
  h := getSimpleObj(frame, fWhere, at);
  obj := getKlausObject(frame, h, tObject, at);
  if not obj.getInterface(iidKlausEventQueue, intf) then begin
    cn := tKlausObjects.klausObjectName(obj.classType);
    raise eKlausError.createFmt(ercUnexpectedObjectClass, at, [strEventQueue, cn]);
  end;
  returnSimple(frame, klausSimpleI(intf.eventCount));
end;

{ tKlausSysProc_EvtPeek }

constructor tKlausSysProc_EvtPeek.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_EvtPeek, aPoint);
  fWhere := tKlausProcParam.create(self, 'окно', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fWhere);
  fIndex := tKlausProcParam.create(self, 'идкс', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fIndex);
  declareRetValue(findTypeDef(klausTypeName_Event));
end;

procedure tKlausSysProc_EvtPeek.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  h: tKlausObject;
  obj: tObject;
  cn: string;
  intf: iKlausEventQueue;
  idx: tKlausInteger;
  evt: tKlausEvent;
begin
  h := getSimpleObj(frame, fWhere, at);
  obj := getKlausObject(frame, h, tObject, at);
  if not obj.getInterface(iidKlausEventQueue, intf) then begin
    cn := tKlausObjects.klausObjectName(obj.classType);
    raise eKlausError.createFmt(ercUnexpectedObjectClass, at, [strEventQueue, cn]);
  end;
  idx := getSimpleInt(frame, fIndex, at);
  evt := intf.eventPeek(idx);
  returnEvent(frame, at, evt);
end;

end.

