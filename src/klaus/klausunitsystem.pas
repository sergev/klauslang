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

unit KlausUnitSystem;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, KlausLex, KlausDef, KlausSyn, KlausErr, KlausSrc;

const
  klausUnitName_System = 'Клаус';

const
  klausExceptionName_InOutError = 'ОшибкаВводаВывода';
  klausExceptionName_ConvertError = 'ОшибкаКонвертации';
  klausExceptionName_IndexError = 'НеверныйИндекс';
  klausExceptionName_KeyError = 'НеверныйКлюч';
  klausExceptionName_TypeMismatch = 'НеверныйТип';
  klausExceptionName_InvalidName = 'НеверноеИмя';
  klausExceptionName_SyntaxError = 'НеверныйСинтаксис';
  klausExceptionName_InvalidChar = 'НеверныйСимвол';
  klausExceptionName_RuntimeError = 'ОшибкаВыполнения';
  klausExceptionName_NotANumber = 'НеверноеЧисло';
  klausExceptionName_InternalError = 'ВнутренняяОшибка';

const
  klausProcName_Destroy = 'уничтожить';
  klausProcName_ReadLn = 'ввести';
  klausProcName_Write = 'вывести';
  klausProcName_Report = 'сообщить';
  klausProcName_Date = 'дата';
  klausProcName_Time = 'время';
  klausProcName_Now = 'сейчас';
  klausProcName_exceptionName = 'имя_исключения';
  klausProcName_exceptionText = 'текст_исключения';
  klausProcName_Length = 'длина';
  klausProcName_Char = 'симв';
  klausProcName_Next = 'след';
  klausProcName_Prev = 'пред';
  klausProcName_Part = 'часть';
  klausProcName_Add = 'добавить';
  klausProcName_Insert = 'вставить';
  klausProcName_Delete = 'удалить';
  klausProcName_Clear = 'очистить';
  klausProcName_Overwrite = 'вписать';
  klausProcName_Find = 'найти';
  klausProcName_Replace = 'заменить';
  klausProcName_Format = 'формат';
  klausProcName_Upper = 'загл';
  klausProcName_Lower = 'строч';
  klausProcName_IsNaN = 'нечисло';
  klausProcName_IsFinite = 'конечно';
  klausProcName_Round = 'округл';
  klausProcName_RoundTo = 'окр';
  klausProcName_Int = 'цел';
  klausProcName_Frac = 'дроб';
  klausProcName_Sin = 'sin';
  klausProcName_Cos = 'cos';
  klausProcName_Tan = 'tg';
  klausProcName_ArcSin = 'arcsin';
  klausProcName_ArcCos = 'arccos';
  klausProcName_ArcTan = 'arctg';
  klausProcName_Ln = 'ln';
  klausProcName_Exp = 'exp';
  klausProcName_Delay = 'пауза';
  klausProcName_Random = 'случайное';
  klausProcName_ProgramName = 'имя_программы';
  klausProcName_CourseName = 'имя_практикума';

const
  klausConstName_Newline = 'НС';
  klausConstName_Tab = 'Таб';
  klausConstName_EOF = 'КФ';
  klausConstName_CR = 'ВК';
  klausConstName_LF = 'ПС';
  klausConstName_MinInt = 'минЦелое';
  klausConstName_MaxInt = 'максЦелое';
  klausConstName_MinFloat = 'минДробное';
  klausConstName_MaxFloat = 'максДробное';
  klausConstName_Pi = 'Pi';
  klausConstName_PiRus = 'Пи';

const
  klausVarName_CmdLineParams = '$cmdLineParams';
  klausVarName_ExecFilename = '$execFileName';

var
  globalErrorInfo: record
    name: string;
    text: string;
  end = (name: ''; text: '');

type
  // Встроенный модуль, содержащий системные определения и подпрограммы.
  // Запускается в корневом фрейме стека при запуске программы.
  tKlausUnitSystem = class(tKlausStdUnit)
    private
      fStdErrors: array[tKlausStdexception] of tKlausExceptDecl;
      fFileName: string;
      fArgs: tStrings;

      procedure setArgs(val: tStrings);
      procedure createStdExceptions;
      procedure createSystemTypes;
      procedure createSystemVariables;
      procedure createSystemRoutines;
    protected
      procedure beforeInit(frame: tKlausStackFrame); override;
    public
      property fileName: string read fFileName write fFileName;
      property args: tStrings read fArgs write setArgs;

      constructor create(aSource: tKlausSource); override;
      destructor  destroy; override;
      class function stdUnitName: string; override;
  end;

type
  // Базовый класс встроенной подпрограммы -- добавляет методы для более удобного
  // написания кода встроенных функций. Позволяет быстро проверять типы данных, бросать
  // часто используемые исключения и пр.
  tKlausSysProcDecl = class(tKlausInternalProcDecl)
    protected
      function  findTypeDef(const typeName: string): tKlausTypeDef;
      procedure errWrongParamCount(given, min, max: integer; const at: tSrcPoint);
      procedure errTypeMismatch(const at: tSrcPoint);
      procedure checkCanAssign(dst: tKlausSimpleType; src: tKlausTypeDef; const at: tSrcPoint; strict: boolean = false);
      procedure checkCanAssign(dst, src: tKlausTypeDef; const at: tSrcPoint; strict: boolean = false);
      procedure checkCanAssign(dst: tKlausSimpleType; val: tKlausVarValueAt; strict: boolean = false);
      procedure checkCanAssign(dst: tKlausTypeDef; val: tKlausVarValueAt; strict: boolean = false);
      procedure checkKeyType(dst, key: tKlausTypeDef; const at: tSrcPoint; strict: boolean = false);
      procedure checkKeyType(dst, key: tKlausVarValue; const at: tSrcPoint; strict: boolean = false);
      procedure checkElmtType(dst, elmt: tKlausTypeDef; const at: tSrcPoint; strict: boolean = false);
      procedure checkElmtType(dst, elmt: tKlausVarValue; const at: tSrcPoint; strict: boolean = false);
      procedure declareRetValue(dt: tKlausSimpleType);
      procedure declareRetValue(dt: tKlausTypeDef);
      procedure returnSimple(frame: tKlausStackFrame; rslt: tKlausSimpleValue);
      function  getSimple(val: tKlausVarValueAt): tKlausSimpleValue;
      function  getSimpleChar(val: tKlausVarValueAt): tKlausChar;
      function  getSimpleStr(val: tKlausVarValueAt): tKlausString;
      function  getSimpleInt(val: tKlausVarValueAt): tKlausInteger;
      function  getSimpleFloat(val: tKlausVarValueAt): tKlausFloat;
      function  getSimpleMoment(val: tKlausVarValueAt): tKlausMoment;
      function  getSimpleBool(val: tKlausVarValueAt): tKlausBoolean;
      function  getSimpleObj(val: tKlausVarValueAt): tKlausObject;
      function  getSimple(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausSimpleValue;
      function  getSimpleChar(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausChar;
      function  getSimpleStr(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausString;
      function  getSimpleInt(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausInteger;
      function  getSimpleFloat(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausFloat;
      function  getSimpleMoment(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausMoment;
      function  getSimpleBool(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausBoolean;
      function  getSimpleObj(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausObject;
      procedure setSimple(frame: tKlausStackFrame; vd: tKlausVarDecl; const sv: tKlausSimpleValue; const at: tSrcPoint);
      procedure setSimpleChar(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausChar; const at: tSrcPoint);
      procedure setSimpleStr(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausString; const at: tSrcPoint);
      procedure setSimpleInt(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausInteger; const at: tSrcPoint);
      procedure setSimpleFloat(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausFloat; const at: tSrcPoint);
      procedure setSimpleMoment(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausMoment; const at: tSrcPoint);
      procedure setSimpleBool(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausBoolean; const at: tSrcPoint);
      procedure setSimpleObj(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausObject; const at: tSrcPoint);
      function  getKlausObject(frame: tKlausStackFrame; h: tKlausObject; cls: tClass; const at: tSrcPoint): tObject;
  end;

function  klausStdError(frame: tKlausStackFrame; ksx: tKlausStdException; pt: tSrcPoint): eKlausLangException;
function  klausStdError(frame: tKlausStackFrame; ksx: tKlausStdException; msg: string; pt: tSrcPoint): eKlausLangException;
function  klausStdError(frame: tKlausStackFrame; ksx: tKlausStdexception; msg: string; const args: array of const; pt: tSrcPoint): eKlausLangException;

const
  klausConst_StdOut = 1;
  klausConst_StdErr = 2;
  klausConst_FontBold = 1;
  klausConst_FontItalic = 2;
  klausConst_FontUnderline = 4;
  klausConst_FontStrikeOut = 8;
  klausConst_psClear = 0;
  klausConst_psSolid = 1;
  klausConst_psDot = 2;
  klausConst_psDash = 3;
  klausConst_psDashDot = 4;
  klausConst_psDashDotDot = 5;
  klausConst_bsClear = 0;
  klausConst_bsSolid = 1;
  klausConst_EvtKeyDown = 1;
  klausConst_EvtKeyUp = 2;
  klausConst_EvtKeyChar = 4;
  klausConst_EvtMouseDown = 8;
  klausConst_EvtMouseUp = 16;
  klausConst_EvtMouseWheel = 32;
  klausConst_EvtMouseEnter = 64;
  klausConst_EvtMouseLeave = 128;
  klausConst_EvtMouseMove = 256;
  klausConst_KeyStateShift = 1;
  klausConst_KeyStateCtrl = 2;
  klausConst_KeyStateAlt = 4;
  klausConst_KeyStateLeft = 8;
  klausConst_KeyStateRight = 16;
  klausConst_KeyStateMiddle = 32;
  klausConst_KeyStateDouble = 64;
  klausConst_MouseBtnLeft = 8;
  klausConst_MouseBtnRight = 16;
  klausConst_MouseBtnMiddle = 32;

procedure klausRegisterStdUnit(unitClass: tKlausStdUnitClass);
function  klausFindStdUnit(const name: string): tKlausStdUnitClass;
procedure klausEnumStdUnits(sl: tStrings; clsType: tKlausStdUnitClass = nil);

implementation

uses
  U8, KlausUtils, KlausUnitSystem_Proc;

var
  klausStdUnits: tStringList = nil;

resourcestring
  strFromTo = 'от %d до %d';
  strAtLeast = 'не менее %d';
  strInOutError = 'Ошибка ввода/вывода данных.';
  strConvertError = 'Ошибка конвертации данных.';
  strIndexError = 'Неверный индекс.';
  strKeyError = 'Неверный ключ.';
  strTypeMismatch = 'Несоответствие типов данных.';
  strInvalidName = 'Указанное имя не существует.';
  strSyntaxError = 'Синтаксическая ошибка.';
  strRuntimeError = 'Ошибка при выполнении программы.';
  strInvalidChar = 'Неверный символ.';
  strInternalError = 'Внутренняя ошибка Клаус. Пожалуйста, сообщите разработчикам!';

function klausStdError(frame: tKlausStackFrame; ksx: tKlausStdException; pt: tSrcPoint): eKlausLangException;
begin
  result := klausStdError(frame, ksx, '', [], pt);
end;

function klausStdError(frame: tKlausStackFrame; ksx: tKlausStdException; msg: string; pt: tSrcPoint): eKlausLangException;
begin
  result := klausStdError(frame, ksx, msg, [], pt);
end;

function klausStdError(frame: tKlausStackFrame; ksx: tKlausStdException; msg: string; const args: array of const; pt: tSrcPoint): eKlausLangException;
var
  d: tKlausExceptDecl;
begin
  d := (frame.owner.source.systemUnit as tKlausUnitSystem).fStdErrors[ksx];
  if msg = '' then msg := d.message;
  if msg = '' then msg := d.name;
  msg := format(msg, args);
  result := eKlausLangException.create(msg, d, nil, pt);
end;

procedure klausRegisterStdUnit(unitClass: tKlausStdUnitClass);
begin
  if klausStdUnits = nil then begin
    klausStdUnits := tStringList.create;
    klausStdUnits.sorted := true;
    klausStdUnits.caseSensitive := false;
    klausStdUnits.duplicates := dupError;
  end;
  klausStdUnits.addObject(u8Lower(unitClass.stdUnitName), tObject(unitClass));
end;

function klausFindStdUnit(const name: string): tKlausStdUnitClass;
var
  idx: integer;
begin
  if klausStdUnits = nil then exit(nil);
  idx := klausStdUnits.indexOf(u8Lower(name));
  if idx < 0 then result := nil
  else result := tKlausStdUnitClass(klausStdUnits.objects[idx]);
end;

procedure klausEnumStdUnits(sl: tStrings; clsType: tKlausStdUnitClass = nil);
var
  i: integer;
  u: tKlausStdUnitClass;
begin
  if klausStdUnits = nil then exit;
  for i := 0 to klausStdUnits.count-1 do begin
    u := tKlausStdUnitClass(klausStdUnits.objects[i]);
    if clsType <> nil then if not u.inheritsFrom(clsType) then continue;
    sl.addObject(u.stdUnitName, tObject(u));
  end;
end;

{ tKlausUnitSystem }

constructor tKlausUnitSystem.create(aSource: tKlausSource);
begin
  inherited create(aSource);
  fFileName := '';
  fArgs := tStringList.create;
  createStdExceptions;
  createSystemTypes;
  createSystemVariables;
  createSystemRoutines;
end;

destructor tKlausUnitSystem.destroy;
begin
  freeAndNil(fArgs);
  inherited destroy;
end;

procedure tKlausUnitSystem.createStdExceptions;
begin
  fStdErrors[ksxInOutError] := tKlausExceptDecl.create(self, klausExceptionName_InOutError, zeroSrcPt, strInOutError);
  fStdErrors[ksxConvertError] := tKlausExceptDecl.create(self, klausExceptionName_ConvertError, zeroSrcPt, strConvertError);
  fStdErrors[ksxIndexError] := tKlausExceptDecl.create(self, klausExceptionName_IndexError, zeroSrcPt, strIndexError);
  fStdErrors[ksxKeyError] := tKlausExceptDecl.create(self, klausExceptionName_KeyError, zeroSrcPt, strKeyError);
  fStdErrors[ksxTypeMismatch] := tKlausExceptDecl.create(self, klausExceptionName_TypeMismatch, zeroSrcPt, strTypeMismatch);
  fStdErrors[ksxInvalidName] := tKlausExceptDecl.create(self, klausExceptionName_InvalidName, zeroSrcPt, strInvalidName);
  fStdErrors[ksxSyntaxError] := tKlausExceptDecl.create(self, klausExceptionName_SyntaxError, zeroSrcPt, strSyntaxError);
  fStdErrors[ksxInvalidChar] := tKlausExceptDecl.create(self, klausExceptionName_InvalidChar, zeroSrcPt, strInvalidChar);
  fStdErrors[ksxRuntimeError] := tKlausExceptDecl.create(self, klausExceptionName_RuntimeError, zeroSrcPt, strRuntimeError);
  fStdErrors[ksxBadNumber] := tKlausExceptDecl.create(self, klausExceptionName_NotANumber, zeroSrcPt, strRuntimeError);
  fStdErrors[ksxInternalError] := tKlausExceptDecl.create(self, klausExceptionName_InternalError, zeroSrcPt, strInternalError);
end;

procedure tKlausUnitSystem.createSystemTypes;
begin
end;

procedure tKlausUnitSystem.createSystemVariables;
var
  dtString: tKlausTypeDef;
  dtStrArray: tKlausTypeDef;
begin
  dtString := source.simpleTypes[kdtString];
  dtStrArray := source.arrayTypes[kdtString];
  // константы
  tKlausConstDecl.create(self, [klausConstName_Newline], zeroSrcPt, klausSimpleS(#13#10));
  tKlausConstDecl.create(self, [klausConstName_Tab], zeroSrcPt, klausSimpleC(tKlausChar(#9)));
  tKlausConstDecl.create(self, [klausConstName_CR], zeroSrcPt, klausSimpleC(tKlausChar(#13)));
  tKlausConstDecl.create(self, [klausConstName_LF], zeroSrcPt, klausSimpleC(tKlausChar(#10)));
  tKlausConstDecl.create(self, [klausConstName_EOF], zeroSrcPt, klausSimpleC(tKlausChar(#26)));
  tKlausConstDecl.create(self, [klausConstName_MaxInt], zeroSrcPt, klausSimpleI(high(tKlausInteger)));
  tKlausConstDecl.create(self, [klausConstName_MinInt], zeroSrcPt, klausSimpleI(low(tKlausInteger)));
  tKlausConstDecl.create(self, [klausConstName_MaxFloat], zeroSrcPt, klausSimpleF(klausMaxFloat));
  tKlausConstDecl.create(self, [klausConstName_MinFloat], zeroSrcPt, klausSimpleF(klausMinFloat));
  tKlausConstDecl.create(self, [klausConstName_Pi], zeroSrcPt, klausSimpleF(Pi));
  tKlausConstDecl.create(self, [klausConstName_PiRus], zeroSrcPt, klausSimpleF(Pi));
  // имя исполняемого файла
  tKlausVarDecl.create(self, [klausVarName_ExecFilename], zeroSrcPt, dtString, nil);
  // аргументы командной строки
  tKlausVarDecl.create(self, [klausVarName_CmdLineParams], zeroSrcPt, dtStrArray, nil);
end;

procedure tKlausUnitSystem.createSystemRoutines;
begin
  tKlausSysProc_Destroy.create(self, zeroSrcPt);
  tKlausSysProc_ReadLn.create(self, zeroSrcPt);
  tKlausSysProc_Write.create(self, zeroSrcPt);
  tKlausSysProc_Report.create(self, zeroSrcPt);
  tKlausSysProc_Date.create(self, zeroSrcPt);
  tKlausSysProc_Time.create(self, zeroSrcPt);
  tKlausSysProc_Now.create(self, zeroSrcPt);
  tKlausSysProc_ExceptionName.create(self, zeroSrcPt);
  tKlausSysProc_ExceptionText.create(self, zeroSrcPt);
  tKlausSysProc_Length.create(self, zeroSrcPt);
  tKlausSysProc_Add.create(self, zeroSrcPt);
  tKlausSysProc_Insert.create(self, zeroSrcPt);
  tKlausSysProc_Delete.create(self, zeroSrcPt);
  tKlausSysProc_Clear.create(self, zeroSrcPt);
  tKlausSysProc_Char.create(self, zeroSrcPt);
  tKlausSysProc_Part.create(self, zeroSrcPt);
  tKlausSysProc_Next.create(self, zeroSrcPt);
  tKlausSysProc_Prev.create(self, zeroSrcPt);
  tKlausSysProc_Overwrite.create(self, zeroSrcPt);
  tKlausSysProc_Find.create(self, zeroSrcPt);
  tKlausSysProc_Replace.create(self, zeroSrcPt);
  tKlausSysProc_Format.create(self, zeroSrcPt);
  tKlausSysProc_Upper.create(self, zeroSrcPt);
  tKlausSysProc_Lower.create(self, zeroSrcPt);
  tKlausSysProc_IsNaN.create(self, zeroSrcPt);
  tKlausSysProc_IsFinite.create(self, zeroSrcPt);
  tKlausSysProc_Round.create(self, zeroSrcPt);
  tKlausSysProc_RoundTo.create(self, zeroSrcPt);
  tKlausSysProc_Int.create(self, zeroSrcPt);
  tKlausSysProc_Frac.create(self, zeroSrcPt);
  tKlausSysProc_Sin.create(self, zeroSrcPt);
  tKlausSysProc_Cos.create(self, zeroSrcPt);
  tKlausSysProc_Tan.create(self, zeroSrcPt);
  tKlausSysProc_ArcSin.create(self, zeroSrcPt);
  tKlausSysProc_ArcCos.create(self, zeroSrcPt);
  tKlausSysProc_ArcTan.create(self, zeroSrcPt);
  tKlausSysProc_Ln.create(self, zeroSrcPt);
  tKlausSysProc_Exp.create(self, zeroSrcPt);
  tKlausSysProc_Delay.create(self, zeroSrcPt);
  tKlausSysProc_Random.create(self, zeroSrcPt);
  tKlausSysProc_ProgramName.create(self, zeroSrcPt);
  tKlausSysProc_CourseName.create(self, zeroSrcPt);
end;

class function tKlausUnitSystem.stdUnitName: string;
begin
  result := klausUnitName_System;
end;

procedure tKlausUnitSystem.setArgs(val: tStrings);
begin
  if val = nil then fArgs.clear
  else fArgs.assign(val);
end;

procedure tKlausUnitSystem.beforeInit(frame: tKlausStackFrame);
var
  i: integer;
  v: tKlausVariable;
  vv: tKlausVarValueSimple;
begin
  inherited;
  // имя исполняемого файла
  v := frame.varByName(klausVarName_ExecFilename, point);
  (v.value as tKlausVarValueSimple).setSimple(klausSimpleS(fileName), zeroSrcPt);
  // аргументы командной строки
  v := frame.varByName(klausVarName_CmdLineParams, point);
  for i := 0 to fArgs.count-1 do begin
    vv := tKlausVarValueSimple.create(source.simpleTypes[kdtString]);
    vv.setSimple(klausSimpleS(fArgs[i]), zeroSrcPt);
    (v.value as tKlausVarValueArray).insert(i, vv, zeroSrcPt);
  end;
end;

{ tKlausSysProcDecl }

procedure tKlausSysProcDecl.declareRetValue(dt: tKlausSimpleType);
begin
  assert(retValue = nil, 'Internal function return value already declared');
  setRetValue(tKlausProcParam.create(self, '', point, kpmOutput, source.simpleTypes[dt]));
end;

procedure tKlausSysProcDecl.declareRetValue(dt: tKlausTypeDef);
begin
  assert(retValue = nil, 'Internal function return value already declared');
  setRetValue(tKlausProcParam.create(self, '', point, kpmOutput, dt));
end;

procedure tKlausSysProcDecl.returnSimple(frame: tKlausStackFrame; rslt: tKlausSimpleValue);
begin
  assert(retValue <> nil, 'Internal procedure cannot return a value');
  (frame.varByDecl(retValue, point).value as tKlausVarValueSimple).setSimple(rslt, point);
end;

function tKlausSysProcDecl.findTypeDef(const typeName: string): tKlausTypeDef;
begin
  result := (findDecl(typeName, knsGlobal) as tKlausTypeDecl).dataType;
end;

procedure tKlausSysProcDecl.errWrongParamCount(given, min, max: integer; const at: tSrcPoint);
var
  s: string;
begin
  if min = max then s := intToStr(min)
  else if max < 0 then s := format(strAtLeast, [min])
  else s := format(strFromTo, [min, max]);
  raise eKlausError.createFmt(ercWrongNumberOfParams, at, [given, s])
  at get_caller_addr(get_frame);
end;

procedure tKlausSysProcDecl.errTypeMismatch(const at: tSrcPoint);
begin
  raise eKlausError.create(ercTypeMismatch, at)
  at get_caller_addr(get_frame);
end;

procedure tKlausSysProcDecl.checkCanAssign(dst: tKlausSimpleType; src: tKlausTypeDef; const at: tSrcPoint; strict: boolean = false);
begin
  if not source.simpleTypes[dst].canAssign(src, strict) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
end;

procedure tKlausSysProcDecl.checkCanAssign(dst: tKlausSimpleType; val: tKlausVarValueAt; strict: boolean = false);
begin
  if not source.simpleTypes[dst].canAssign(val.v.dataType, strict) then
    raise eKlausError.create(ercTypeMismatch, val.at)
    at get_caller_addr(get_frame);
end;

procedure tKlausSysProcDecl.checkCanAssign(dst, src: tKlausTypeDef; const at: tSrcPoint; strict: boolean = false);
begin
  if not dst.canAssign(src, strict) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
end;

procedure tKlausSysProcDecl.checkCanAssign(dst: tKlausTypeDef; val: tKlausVarValueAt; strict: boolean = false);
begin
  if not dst.canAssign(val.v.dataType, strict) then
    raise eKlausError.create(ercTypeMismatch, val.at)
    at get_caller_addr(get_frame);
end;

procedure tKlausSysProcDecl.checkKeyType(dst, key: tKlausTypeDef; const at: tSrcPoint; strict: boolean = false);
var
  kt: tKlausSimpleType;
begin
  if dst is tKlausTypeDefArray then begin
    if not source.simpleTypes[kdtInteger].canAssign(key, strict) then
      raise eKlausError.create(ercTypeMismatch, at)
      at get_caller_addr(get_frame);
  end else if dst is tKlausTypeDefDict then begin
    kt := (dst as tKlausTypeDefDict).keyType;
    if not source.simpleTypes[kt].canAssign(key, strict) then
      raise eKlausError.create(ercTypeMismatch, at)
      at get_caller_addr(get_frame);
  end else
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
end;

procedure tKlausSysProcDecl.checkKeyType(dst, key: tKlausVarValue; const at: tSrcPoint; strict: boolean = false);
var
  kt: tKlausSimpleType;
begin
  if dst is tKlausVarValueArray then begin
    if not source.simpleTypes[kdtInteger].canAssign(key.dataType, strict) then
      raise eKlausError.create(ercTypeMismatch, at)
      at get_caller_addr(get_frame);
  end else if dst is tKlausVarValueDict then begin
    kt := (dst.dataType as tKlausTypeDefDict).keyType;
    if not source.simpleTypes[kt].canAssign(key.dataType, strict) then
      raise eKlausError.create(ercTypeMismatch, at)
      at get_caller_addr(get_frame);
  end else
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
end;

procedure tKlausSysProcDecl.checkElmtType(dst, elmt: tKlausTypeDef; const at: tSrcPoint; strict: boolean = false);
var
  et: tKlausTypeDef;
begin
  if dst is tKlausTypeDefArray then
    et := (dst as tKlausTypeDefArray).elmtType
  else if dst is tKlausTypeDefDict then
    et := (dst as tKlausTypeDefDict).valueType
  else
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  if not et.canAssign(elmt, strict) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
end;

procedure tKlausSysProcDecl.checkElmtType(dst, elmt: tKlausVarValue; const at: tSrcPoint; strict: boolean = false);
var
  et: tKlausTypeDef;
begin
  if dst is tKlausVarValueArray then
    et := (dst.dataType as tKlausTypeDefArray).elmtType
  else if dst is tKlausVarValueDict then
    et := (dst.dataType as tKlausTypeDefDict).valueType
  else
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  if not et.canAssign(elmt.dataType, strict) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
end;

function tKlausSysProcDecl.getSimple(val: tKlausVarValueAt): tKlausSimpleValue;
begin
  if not (val.v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, val.at)
    at get_caller_addr(get_frame);
  result := (val.v as tKlausVarValueSimple).simple;
end;

function tKlausSysProcDecl.getSimpleChar(val: tKlausVarValueAt): tKlausChar;
begin
  if not source.simpleTypes[kdtChar].canAssign(val.v.dataType) then
    raise eKlausError.create(ercTypeMismatch, val.at)
    at get_caller_addr(get_frame);
  result := klausTypecast((val.v as tKlausVarValueSimple).simple, kdtChar, val.at).cValue;
end;

function tKlausSysProcDecl.getSimpleStr(val: tKlausVarValueAt): tKlausString;
begin
  if not source.simpleTypes[kdtString].canAssign(val.v.dataType) then
    raise eKlausError.create(ercTypeMismatch, val.at)
    at get_caller_addr(get_frame);
  result := klausTypecast((val.v as tKlausVarValueSimple).simple, kdtString, val.at).sValue;
end;

function tKlausSysProcDecl.getSimpleInt(val: tKlausVarValueAt): tKlausInteger;
begin
  if not source.simpleTypes[kdtinteger].canAssign(val.v.dataType) then
    raise eKlausError.create(ercTypeMismatch, val.at)
    at get_caller_addr(get_frame);
  result := klausTypecast((val.v as tKlausVarValueSimple).simple, kdtInteger, val.at).iValue;
end;

function tKlausSysProcDecl.getSimpleFloat(val: tKlausVarValueAt): tKlausFloat;
begin
  if not source.simpleTypes[kdtFloat].canAssign(val.v.dataType) then
    raise eKlausError.create(ercTypeMismatch, val.at)
    at get_caller_addr(get_frame);
  result := klausTypecast((val.v as tKlausVarValueSimple).simple, kdtFloat, val.at).fValue;
end;

function tKlausSysProcDecl.getSimpleMoment(val: tKlausVarValueAt): tKlausMoment;
begin
  if not source.simpleTypes[kdtMoment].canAssign(val.v.dataType) then
    raise eKlausError.create(ercTypeMismatch, val.at)
    at get_caller_addr(get_frame);
  result := klausTypecast((val.v as tKlausVarValueSimple).simple, kdtMoment, val.at).mValue;
end;

function tKlausSysProcDecl.getSimpleBool(val: tKlausVarValueAt): tKlausBoolean;
begin
  if not source.simpleTypes[kdtBoolean].canAssign(val.v.dataType) then
    raise eKlausError.create(ercTypeMismatch, val.at)
    at get_caller_addr(get_frame);
  result := klausTypecast((val.v as tKlausVarValueSimple).simple, kdtBoolean, val.at).bValue;
end;

function tKlausSysProcDecl.getSimpleObj(val: tKlausVarValueAt): tKlausObject;
begin
  if not source.simpleTypes[kdtObject].canAssign(val.v.dataType) then
    raise eKlausError.create(ercTypeMismatch, val.at)
    at get_caller_addr(get_frame);
  result := klausTypecast((val.v as tKlausVarValueSimple).simple, kdtObject, val.at).oValue;
end;

function tKlausSysProcDecl.getSimple(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausSimpleValue;
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  result := (v as tKlausVarValueSimple).simple;
end;

function tKlausSysProcDecl.getSimpleChar(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausChar;
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not source.simpleTypes[kdtChar].canAssign(v.dataType) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  result := klausTypecast((v as tKlausVarValueSimple).simple, kdtChar, at).cValue;
end;

function tKlausSysProcDecl.getSimpleStr(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausString;
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not source.simpleTypes[kdtString].canAssign(v.dataType) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  result := klausTypecast((v as tKlausVarValueSimple).simple, kdtString, at).sValue;
end;

function tKlausSysProcDecl.getSimpleInt(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausInteger;
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not source.simpleTypes[kdtInteger].canAssign(v.dataType) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  result := klausTypecast((v as tKlausVarValueSimple).simple, kdtInteger, at).iValue;
end;

function tKlausSysProcDecl.getSimpleFloat(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausFloat;
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not source.simpleTypes[kdtFloat].canAssign(v.dataType) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  result := klausTypecast((v as tKlausVarValueSimple).simple, kdtFloat, at).fValue;
end;

function tKlausSysProcDecl.getSimpleMoment(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausMoment;
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not source.simpleTypes[kdtMoment].canAssign(v.dataType) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  result := klausTypecast((v as tKlausVarValueSimple).simple, kdtMoment, at).mValue;
end;

function tKlausSysProcDecl.getSimpleBool(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausBoolean;
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not source.simpleTypes[kdtBoolean].canAssign(v.dataType) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  result := klausTypecast((v as tKlausVarValueSimple).simple, kdtBoolean, at).bValue;
end;

function tKlausSysProcDecl.getSimpleObj(frame: tKlausStackFrame; vd: tKlausVarDecl; const at: tSrcPoint): tKlausObject;
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not source.simpleTypes[kdtObject].canAssign(v.dataType) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  result := klausTypecast((v as tKlausVarValueSimple).simple, kdtObject, at).oValue;
end;

procedure tKlausSysProcDecl.setSimple(frame: tKlausStackFrame; vd: tKlausVarDecl; const sv: tKlausSimpleValue; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(sv, at);
end;

procedure tKlausSysProcDecl.setSimpleChar(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausChar; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimpleC(val), at);
end;

procedure tKlausSysProcDecl.setSimpleStr(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausString; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimpleS(val), at);
end;

procedure tKlausSysProcDecl.setSimpleInt(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausInteger; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimpleI(val), at);
end;

procedure tKlausSysProcDecl.setSimpleFloat(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausFloat; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimpleF(val), at);
end;

procedure tKlausSysProcDecl.setSimpleMoment(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausMoment; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimpleM(val), at);
end;

procedure tKlausSysProcDecl.setSimpleBool(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausBoolean; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimpleB(val), at);
end;

procedure tKlausSysProcDecl.setSimpleObj(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausObject; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimpleO(val), at);
end;

function tKlausSysProcDecl.getKlausObject(frame: tKlausStackFrame; h: tKlausObject; cls: tClass; const at: tSrcPoint): tObject;
var
  cn, rn: string;
begin
  result := frame.owner.objects.get(h, at);
  if not (result is cls) then begin
    cn := tKlausObjects.klausObjectName(cls);
    rn := tKlausObjects.klausObjectName(result.classType);
    raise eKlausError.createFmt(ercUnexpectedObjectClass, at, [cn, rn]);
  end;
end;

initialization
  klausRegisterStdUnit(tKlausUnitSystem);
end.


