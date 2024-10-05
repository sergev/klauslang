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

unit KlausUnitSystem_Proc;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, U8, KlausErr, KlausLex, KlausDef, KlausSyn, KlausSrc, KlausUnitSystem;

type
  // процедура уничтожить(вв о: объект);
  tKlausSysProc_Destroy = class(tKlausSysProcDecl)
    private
      fObj: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция ввести(вых арг0, арг1, арг2, ...): целое;
  tKlausSysProc_ReadLn = class(tKlausSysProcDecl)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  //  Базовый класс процедуры вывода в стандартный поток
  tKlausSysProcOutput = class(tKlausSysProcDecl)
    protected
      procedure doWrite(frame: tKlausStackFrame; const s: string); virtual; abstract;
    public
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура вывести(вх арг0, арг1, арг2, ...);
  tKlausSysProc_Write = class(tKlausSysProcOutput)
    protected
      procedure doWrite(frame: tKlausStackFrame; const s: string); override;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
  end;

type
  // процедура сообщить(вх арг0, арг1, арг2, ...);
  tKlausSysProc_Report = class(tKlausSysProcOutput)
    protected
      procedure doWrite(frame: tKlausStackFrame; const s: string); override;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
  end;

type
  // функция дата: момент;
  // функция дата(м: момент): момент;
  tKlausSysProc_Date = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция время: момент;
  // функция время(м: момент): момент;
  tKlausSysProc_Time = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция сейчас: момент;
  tKlausSysProc_Now = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция имя_исключения: строка;
  tKlausSysProc_ExceptionName = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция текст_исключения: строка;
  tKlausSysProc_ExceptionText = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция длина(вх м: массив): целое;
  // функция длина(вв м: массив; вх размер: целое): целое;
  // функция длина(вх сл: словарь): целое;
  // функция длина(вх стр: строка): целое;
  // функция длина(вв стр: строка; вх размер: целое): целое;
  tKlausSysProc_Length = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура добавить(вв м: массив; вх элемент);
  // процедура добавить(вв сл: словарь; вх ключ);
  // процедура добавить(вв сл: словарь; вх ключ, значение);
  // процедура добавить(вв стр1: строка; вх стр2: строка);
  tKlausSysProc_Add = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура вставить(вв м: массив; вх индекс: целое; вх элемент);
  // процедура вставить(вв сл: словарь; вх ключ, значение);
  // процедура вставить(вв стр: строка; вх индекс: целое; вх подстр: строка);
  tKlausSysProc_Insert = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура удалить(вв м: массив; вх индекс: целое);
  // процедура удалить(вв м: массив; вх индекс, кво: целое);
  // процедура удалить(вв сл: словарь; вх ключ);
  // процедура удалить(вв стр: строка; вх индекс, число: целое);
  tKlausSysProc_Delete = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура очистить(вв м: массив);
  // процедура очистить(вв сл: словарь);
  tKlausSysProc_Clear = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция часть(вх стр: строка; вх индекс: целое): строка;
  // функция часть(вх стр: строка; вх индекс, размер: целое): строка;
  tKlausSysProc_Part = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция симв(вх стр: строка): символ;
  // функция симв(вх стр: строка; вх индекс: целое): символ;
  tKlausSysProc_Char = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // Базовый класс для функций "пред" и "след"
  tKlausSysProc_PrevNext = class(tKlausSysProcDecl)
    protected
      function doPrevNext(
        const s: tKlausString; idx, count: tKlausInteger;
        out chars: tKlausInteger; const at: tSrcPoint): tKlausInteger; virtual; abstract;
    public
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция след(вх стр: строка; вх индекс: целое): целое;
  // функция след(вх стр: строка; вх индекс, кво: целое): целое;
  // функция след(вх стр: строка; вх индекс, кво: целое; вых симв: целое): целое;
  tKlausSysProc_Next = class(tKlausSysProc_PrevNext)
    protected
      function doPrevNext(
        const s: tKlausString; idx, count: tKlausInteger;
        out chars: tKlausInteger; const at: tSrcPoint): tKlausInteger; override;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
  end;

type
  // функция пред(вх стр: строка; вх индекс: целое): целое;
  // функция пред(вх стр: строка; вх индекс, кво: целое): целое;
  // функция пред(вх стр: строка; вх индекс, кво: целое; вых симв: целое): целое;
  tKlausSysProc_Prev = class(tKlausSysProc_PrevNext)
    protected
      function doPrevNext(
        const s: tKlausString; idx, count: tKlausInteger;
        out chars: tKlausInteger; const at: tSrcPoint): tKlausInteger; override;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
  end;

type
  // процедура вписать(вв стр1: строка; вх индекс: целое; вх стр2: строка);
  // процедура вписать(вв стр1: строка; вх индекс: целое; вх стр2: строка; вх индекс2: целое);
  // процедура вписать(вв стр1: строка; вх индекс: целое; вх стр2: строка; вх индекс2, число: целое);
  tKlausSysProc_Overwrite = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция найти(вх что, где: строка): целое;
  // функция найти(вх что, где: строка; вх начИдкс: целое): целое;
  // функция найти(вх что, где: строка; вх начИдкс: целое; вх учтРегистр: логическое): целое;
  tKlausSysProc_Find = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура заменить(вв стр: строка; вх индекс, число: целое; вх чем: строка);
  tKlausSysProc_Replace = class(tKlausSysProcDecl)
    private
      fStr: tKlausProcParam;
      fIdx: tKlausProcParam;
      fCount: tKlausProcParam;
      fWith: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция формат(вх формат: строка; арг0, арг1, арг2, ...): строка;
  tKlausSysProc_Format = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция загл(вх ст: строка): строка;
  tKlausSysProc_Upper = class(tKlausSysProcDecl)
    private
      fStr: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция строч(вх ст: строка): строка;
  tKlausSysProc_Lower = class(tKlausSysProcDecl)
    private
      fStr: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция нечисло(вх число: дробное): логическое;
  tKlausSysProc_IsNaN = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция конечно(вх число: дробное): логическое;
  tKlausSysProc_IsFinite = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция округл(вх число: дробное): целое;
  tKlausSysProc_Round = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция окр(вх число: дробное; вх знаков: целое): дробное;
  tKlausSysProc_RoundTo = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
      fDigits: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция цел(вх число: дробное): дробное;
  tKlausSysProc_Int = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция дроб(вх число: дробное): дробное;
  tKlausSysProc_Frac = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция sin(вх число: дробное): дробное;
  tKlausSysProc_Sin = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция cos(вх число: дробное): дробное;
  tKlausSysProc_Cos = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция tg(вх число: дробное): дробное;
  tKlausSysProc_Tan = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция arcsin(вх число: дробное): дробное;
  tKlausSysProc_ArcSin = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция arccos(вх число: дробное): дробное;
  tKlausSysProc_ArcCos = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция arctg(вх число: дробное): дробное;
  tKlausSysProc_ArcTan = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция ln(вх число: дробное): дробное;
  tKlausSysProc_Ln = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция exp(вх число: дробное): дробное;
  tKlausSysProc_Exp = class(tKlausSysProcDecl)
    private
      fNum: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура пауза(вх число: целое);
  tKlausSysProc_Delay = class(tKlausSysProcDecl)
    private
      fDelay: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция случайное(вх макс: целое): целое;
  tKlausSysProc_Random = class(tKlausSysProcDecl)
    private
      fRange: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция имя_программы(): строка;
  tKlausSysProc_ProgramName = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция имя_практикума(): строка;
  tKlausSysProc_CourseName = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

implementation

uses
  Math, LCLIntf, Graphics, GraphType, GraphUtils, KlausUtils;

resourcestring
  strOneOrMore = '1 или более';

{ tKlausSysProc_Destroy }

constructor tKlausSysProc_Destroy.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Destroy, aPoint);
  fObj := tKlausProcParam.create(self, 'о', aPoint, kpmInOut, source.simpleTypes[kdtObject]);
  addParam(fObj);
end;

procedure tKlausSysProc_Destroy.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  v: tKlausObject;
begin
  v := getSimpleObj(frame, fObj, at);
  if frame.owner.objects.exists(v) then
    frame.owner.objects.releaseAndFree(v, at);
  setSimple(frame, fObj, klausZeroValue(kdtObject), at);
end;

{ tKlausSysProc_Date }

constructor tKlausSysProc_Date.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Date, aPoint);
  declareRetValue(kdtMoment);
end;

function tKlausSysProc_Date.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_Date.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if cnt > 1 then errWrongParamCount(cnt, 0, 1, at);
  if cnt > 0 then checkCanAssign(kdtMoment, expr[0].resultTypeDef, expr[0].point);
end;

procedure tKlausSysProc_Date.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  modes := nil;
  setLength(modes, length(types));
  if length(modes) > 0 then modes[0] := kpmInput;
end;

procedure tKlausSysProc_Date.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  dt: tKlausMoment;
begin
  cnt := length(values);
  if cnt > 1 then errWrongParamCount(cnt, 2, 3, at);
  if cnt = 0 then dt := now else dt := getSimpleMoment(values[0]);
  returnSimple(frame, klausSimpleM(int(dt)));
end;

{ tKlausSysProc_Time }

constructor tKlausSysProc_Time.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Time, aPoint);
  declareRetValue(kdtMoment);
end;

function tKlausSysProc_Time.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_Time.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if cnt > 1 then errWrongParamCount(cnt, 0, 1, at);
  if cnt > 0 then checkCanAssign(kdtMoment, expr[0].resultTypeDef, expr[0].point);
end;

procedure tKlausSysProc_Time.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  modes := nil;
  setLength(modes, length(types));
  if length(modes) > 0 then modes[0] := kpmInput;
end;

procedure tKlausSysProc_Time.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  dt: tKlausMoment;
begin
  cnt := length(values);
  if cnt > 1 then errWrongParamCount(cnt, 2, 3, at);
  if cnt = 0 then dt := now else dt := getSimpleMoment(values[0]);
  returnSimple(frame, klausSimpleM(frac(dt)));
end;

{ tKlausSysProc_Now }

constructor tKlausSysProc_Now.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Now, aPoint);
  declareRetValue(kdtMoment);
end;

procedure tKlausSysProc_Now.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleM(now));
end;

{ tKlausSysProc_exceptionName }

constructor tKlausSysProc_ExceptionName.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_exceptionName, aPoint);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_ExceptionName.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleS(globalErrorInfo.name));
end;

{ tKlausSysProc_exceptionText }

constructor tKlausSysProc_ExceptionText.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_exceptionText, aPoint);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_ExceptionText.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleS(globalErrorInfo.text));
end;

{ tKlausSysProc_ReadLn }

constructor tKlausSysProc_ReadLn.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_ReadLn, aPoint);
  declareRetValue(kdtInteger);
end;

function tKlausSysProc_ReadLn.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_ReadLn.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  i: integer;
  dt: tKlausDataType;
begin
  for i := 0 to length(expr)-1 do begin
    dt := expr[i].resultType;
    if dt = kdtComplex then raise eKlausError.create(ercCannotReadComplexType, expr[i].point);
    if dt = kdtObject then raise eKlausError.createFmt(ercValueCannotBeRead, expr[i].point, [klausDataTypeCaption[dt]]);
    if not expr[i].isVarPath then raise eKlausError.create(ercInvalidOutputParam, expr[i].point);
  end;
end;

procedure tKlausSysProc_ReadLn.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInOut;
end;

procedure tKlausSysProc_ReadLn.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  s: string;
  i, cnt: integer;
  r: tKlausInputReader;
  sv: tKlausSimpleValue;
begin
  r := frame.owner.inputReader;
  if length(values) = 0 then begin
    r.readNextValue(kdtString, s);
    returnSimple(frame, klausSimpleI(0));
  end else begin
    cnt := 0;
    for i := 0 to length(values)-1 do try
      if not r.readNextValue(values[i].v.dataType.dataType, sv, values[i].at) then break;
      (values[i].v as tKlausVarValueSimple).setSimple(sv, at);
      cnt += 1;
    except
      klausTranslateException(frame, values[i].at);
    end;
    returnSimple(frame, klausSimpleI(cnt));
  end;
end;

{ tKlausSysProcOutput }

function tKlausSysProcOutput.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProcOutput.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  i: integer;
begin
  for i := 0 to length(expr)-1 do
    if expr[i].resultType = kdtComplex then
      raise eKlausError.create(ercCannotWriteComplexType, expr[i].point);
end;

procedure tKlausSysProcOutput.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProcOutput.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  i: integer;
begin
  try
    for i := 0 to length(values)-1 do begin
      if not (values[i].v is tKlausVarValueSimple) then
        raise eKlausError.create(ercCannotWriteComplexType, values[i].at);
      doWrite(frame, klausTypecast(getSimple(values[i]), kdtString, values[i].at).sValue);
    end;
  except
    klausTranslateException(frame, at);
  end;
end;

{ tKlausSysProc_Write }

constructor tKlausSysProc_Write.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Write, aPoint);
end;

procedure tKlausSysProc_Write.doWrite(frame: tKlausStackFrame; const s: string);
begin
  frame.owner.writeStdOut(s);
end;

{ tKlausSysProc_Report }

constructor tKlausSysProc_Report.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Report, aPoint);
end;

procedure tKlausSysProc_Report.doWrite(frame: tKlausStackFrame; const s: string);
begin
  frame.owner.writeStdErr(s);
end;

{ tKlausSysProc_Length }

constructor tKlausSysProc_Length.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Length, aPoint);
  declareRetValue(kdtInteger);
end;

function tKlausSysProc_Length.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_Length.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
  dt: tKlausTypeDef;
begin
  cnt := length(expr);
  if (cnt < 1) or (cnt > 2) then errWrongParamCount(cnt, 1, 2, at);
  dt := expr[0].resultTypeDef;
  if dt is tKlausTypeDefArray then begin
    // массив
    if cnt > 1 then begin
      checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
      if not expr[0].isVarPath then raise eKlausError.create(ercInvalidOutputParam, expr[0].point);
    end;
  end else if dt is tKlausTypeDefDict then begin
    // словарь
    if cnt > 1 then errWrongParamCount(cnt, 1, 1, at);
  end else if dt is tKlausTypeDefSimple then begin
    // строка
    checkCanAssign(kdtString, dt, expr[0].point, cnt > 1);
    if cnt > 1 then begin
      checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
      if not expr[0].isVarPath then raise eKlausError.create(ercInvalidOutputParam, expr[0].point);
    end;
  end else
    errTypeMismatch(expr[0].point);
end;

procedure tKlausSysProc_Length.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  case length(types) of
    1: modes := [kpmInput];
    2: modes := [kpmInOut, kpmInput];
  else
    errWrongParamCount(length(types), 1, 2, at);
  end;
end;

procedure tKlausSysProc_Length.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  rslt: tKlausInteger;
begin
  cnt := length(values);
  if (cnt < 1) or (cnt > 2) then errWrongParamCount(cnt, 1, 2, at);
  if values[0].v is tKlausVarValueArray then begin
    // массив
    if cnt > 1 then (values[0].v as tKlausVarValueArray).count := getSimpleInt(values[1]);
    returnSimple(frame, klausSimpleI((values[0].v as tKlausVarValueArray).count));
  end else if values[0].v is tKlausVarValueDict then begin
    // словарь
    returnSimple(frame, klausSimpleI((values[0].v as tKlausVarValueDict).count));
  end else if values[0].v is tKlausVarValueSimple then begin
    // строка
    if cnt > 1 then begin
      rslt := getSimpleInt(values[1]);
      rslt := (values[0].v as tKlausVarValueSimple).stringSetLength(rslt, at);
      returnSimple(frame, klausSimpleI(rslt));
    end else
      returnSimple(frame, klausSimpleI(length(getSimpleStr(values[0]))));
  end else
    errTypeMismatch(values[0].at);
end;

{ tKlausSysProc_Add }

constructor tKlausSysProc_Add.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Add, aPoint);
end;

function tKlausSysProc_Add.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_Add.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
  dt: tKlausTypeDef;
begin
  cnt := length(expr);
  if (cnt < 2) or (cnt > 3) then errWrongParamCount(cnt, 2, 3, at);
  if not expr[0].isVarPath then raise eKlausError.create(ercInvalidOutputParam, expr[0].point);
  dt := expr[0].resultTypeDef;
  if dt is tKlausTypeDefArray then begin
    // массив
    if cnt <> 2 then errWrongParamCount(cnt, 2, 2, at);
    checkElmtType(dt, expr[1].resultTypeDef, expr[1].point);
  end else if dt is tKlausTypeDefDict then begin
    // словарь
    checkKeyType(dt, expr[1].resultTypeDef, expr[1].point);
    if cnt = 3 then checkElmtType(dt, expr[2].resultTypeDef, expr[2].point);
  end else if dt is tKlausTypeDefSimple then begin
    // строка
    if cnt <> 2 then errWrongParamCount(cnt, 2, 2, at);
    checkCanAssign(kdtString, expr[0].resultTypeDef, expr[0].point, true);
    checkCanAssign(kdtString, expr[1].resultTypeDef, expr[1].point);
  end else
    errTypeMismatch(expr[0].point);
end;

procedure tKlausSysProc_Add.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  case length(types) of
    2: modes := [kpmInOut, kpmInput];
    3: modes := [kpmInOut, kpmInput, kpmInput];
  else
    errWrongParamCount(length(types), 2, 3, at);
  end;
end;

procedure tKlausSysProc_Add.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  arr: tKlausVarValueArray;
  dict: tKlausVarValueDict;
begin
  cnt := length(values);
  if (cnt < 2) or (cnt > 3) then errWrongParamCount(cnt, 2, 3, at);
  if values[0].v is tKlausVarValueArray then begin
    // массив
    arr := values[0].v as tKlausVarValueArray;
    arr.count := arr.count+1;
    arr.getElmt(arr.count-1, at, vpmAsgnTarget).assign(values[1].v, at);
  end else if values[0].v is tKlausVarValueDict then begin
    // словарь
    dict := values[0].v as tKlausVarValueDict;
    if length(values) = 3 then
      dict.setElmt(getSimple(values[1]), values[2].v, at)
    else
      dict.getElmt(getSimple(values[1]), at, vpmAsgnTarget);
  end else if values[0].v is tKlausVarValueSimple then begin
    // строка
    (values[0].v as tKlausVarValueSimple).stringAdd(getSimpleStr(values[1]), at);
  end else
    errTypeMismatch(values[0].at);
end;

{ tKlausSysProc_Insert }

constructor tKlausSysProc_Insert.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Insert, aPoint);
end;

function tKlausSysProc_Insert.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_Insert.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
  dt: tKlausTypeDef;
begin
  cnt := length(expr);
  if cnt <> 3 then errWrongParamCount(cnt, 3, 3, at);
  if not expr[0].isVarPath then raise eKlausError.create(ercInvalidOutputParam, expr[0].point);
  dt := expr[0].resultTypeDef;
  if (dt is tKlausTypeDefArray) or (dt is tKlausTypeDefDict) then begin
    // массив или словарь
    checkKeyType(dt, expr[1].resultTypeDef, expr[1].point);
    checkElmtType(dt, expr[2].resultTypeDef, expr[2].point);
  end else if dt is tKlausTypeDefSimple then begin
    // строка
    checkCanAssign(kdtString, expr[0].resultTypeDef, expr[0].point, true);
    checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
    checkCanAssign(kdtString, expr[2].resultTypeDef, expr[2].point);
  end else
    errTypeMismatch(expr[0].point);
end;

procedure tKlausSysProc_Insert.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  modes := [kpmInOut, kpmInput, kpmInput];
end;

procedure tKlausSysProc_Insert.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  idx: integer;
  arr: tKlausVarValueArray;
  dict: tKlausVarValueDict;
begin
  if length(values) <> 3 then errWrongParamCount(length(values), 3, 3, at);
  if values[0].v is tKlausVarValueArray then begin
    // массив
    arr := values[0].v as tKlausVarValueArray;
    idx := getSimpleInt(values[1]);
    arr.insert(idx, values[2].v, at);
  end else if values[0].v is tKlausVarValueDict then begin
    // словарь
    dict := values[0].v as tKlausVarValueDict;
    dict.setElmt(getSimple(values[1]), values[2].v, at)
  end else if values[0].v is tKlausVarValueSimple then begin
    // строка
    (values[0].v as tKlausVarValueSimple).stringInsert(getSimpleInt(values[1]), getSimpleStr(values[2]), at);
  end else
    errTypeMismatch(values[0].at);
end;

{ tKlausSysProc_Delete }

constructor tKlausSysProc_Delete.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Delete, aPoint);
end;

function tKlausSysProc_Delete.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_Delete.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
  dt: tKlausTypeDef;
begin
  cnt := length(expr);
  if (cnt < 2) or (cnt > 3) then errWrongParamCount(cnt, 2, 3, at);
  if not expr[0].isVarPath then raise eKlausError.create(ercInvalidOutputParam, expr[0].point);
  dt := expr[0].resultTypeDef;
  if dt is tKlausTypeDefArray then begin
    // массив
    checkKeyType(dt, expr[1].resultTypeDef, expr[1].point);
    if cnt = 3 then checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
  end else if dt is tKlausTypeDefDict then begin
    // словарь
    if cnt <> 2 then errWrongParamCount(cnt, 2, 2, at);
    checkKeyType(dt, expr[1].resultTypeDef, expr[1].point);
  end else if dt is tKlausTypeDefSimple then begin
    // строка
    if cnt <> 3 then errWrongParamCount(cnt, 3, 3, at);
    checkCanAssign(kdtString, expr[0].resultTypeDef, expr[0].point, true);
    checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
    checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
  end else
    errTypeMismatch(expr[0].point);
end;

procedure tKlausSysProc_Delete.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  case length(types) of
    2: modes := [kpmInOut, kpmInput];
    3: modes := [kpmInOut, kpmInput, kpmInput];
  else
    errWrongParamCount(length(types), 2, 3, at);
  end;
end;

procedure tKlausSysProc_Delete.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  l: integer;
  idx, cnt: tKlausInteger;
  arr: tKlausVarValueArray;
  dict: tKlausVarValueDict;
begin
  l := length(values);
  if (l < 2) or (l > 3) then errWrongParamCount(l, 2, 3, at);
  if values[0].v is tKlausVarValueArray then begin
    // массив
    arr := values[0].v as tKlausVarValueArray;
    idx := getSimpleInt(values[1]);
    if l = 3 then cnt := getSimpleInt(values[2]) else cnt := 1;
    arr.delete(idx, cnt, at);
  end else if values[0].v is tKlausVarValueDict then begin
    // словарь
    if l <> 2 then errWrongParamCount(l, 2, 2, at);
    dict := values[0].v as tKlausVarValueDict;
    dict.delete(getSimple(values[1]), at)
  end else if values[0].v is tKlausVarValueSimple then begin
    // строка
    if l <> 3 then errWrongParamCount(l, 3, 3, at);
    (values[0].v as tKlausVarValueSimple).stringDelete(getSimpleInt(values[1]), getSimpleInt(values[2]), at);
  end else
    errTypeMismatch(values[0].at);
end;

{ tKlausSysProc_Clear }

constructor tKlausSysProc_Clear.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Clear, aPoint);
end;

function tKlausSysProc_Clear.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_Clear.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
  dt: tKlausTypeDef;
begin
  cnt := length(expr);
  if cnt <> 1 then errWrongParamCount(cnt, 1, 1, at);
  if not expr[0].isVarPath then raise eKlausError.create(ercInvalidOutputParam, expr[0].point);
  dt := expr[0].resultTypeDef;
  if not (dt is tKlausTypeDefArray) and not (dt is tKlausTypeDefDict) then errTypeMismatch(expr[0].point);
end;

procedure tKlausSysProc_Clear.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  if length(types) = 1 then modes := [kpmInOut]
  else errWrongParamCount(length(types), 1, 1, at);
end;

procedure tKlausSysProc_Clear.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  l: integer;
  arr: tKlausVarValueArray;
  dict: tKlausVarValueDict;
begin
  l := length(values);
  if l <> 1 then errWrongParamCount(l, 1, 1, at);
  if values[0].v is tKlausVarValueArray then begin
    // массив
    arr := values[0].v as tKlausVarValueArray;
    arr.clear;
  end else if values[0].v is tKlausVarValueDict then begin
    // словарь
    dict := values[0].v as tKlausVarValueDict;
    dict.clear;
  end else
    errTypeMismatch(values[0].at);
end;

{ tKlausSysProc_Part }

constructor tKlausSysProc_Part.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Part, aPoint);
  declareRetValue(kdtString);
end;

function tKlausSysProc_Part.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_Part.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 2) or (cnt > 3) then errWrongParamCount(cnt, 2, 3, at);
  checkCanAssign(kdtString, expr[0].resultTypeDef, expr[0].point);
  checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
  if cnt > 2 then checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
end;

procedure tKlausSysProc_Part.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  case length(types) of
    2: modes := [kpmInput, kpmInput];
    3: modes := [kpmInput, kpmInput, kpmInput];
  else
    errWrongParamCount(length(types), 2, 3, at);
  end;
end;

procedure tKlausSysProc_Part.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  rslt: tKlausString;
  count: tKlausInteger;
begin
  cnt := length(values);
  if (cnt < 2) or (cnt > 3) then errWrongParamCount(cnt, 2, 3, at);
  if cnt = 2 then count := high(tKlausInteger) else count := getSimpleInt(values[2]);
  rslt := klstrPart(getSimpleStr(values[0]), getSimpleInt(values[1]), count, at);
  returnSimple(frame, klausSimpleS(rslt));
end;

{ tKlausSysProc_Char }

constructor tKlausSysProc_Char.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Char, aPoint);
  declareRetValue(kdtChar);
end;

function tKlausSysProc_Char.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_Char.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 1) or (cnt > 2) then errWrongParamCount(cnt, 1, 2, at);
  checkCanAssign(kdtString, expr[0].resultTypeDef, expr[0].point);
  if cnt > 1 then checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
end;

procedure tKlausSysProc_Char.getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  case length(types) of
    1: modes := [kpmInput];
    2: modes := [kpmInput, kpmInput];
  else
    errWrongParamCount(length(types), 1, 2, at);
  end;
end;

procedure tKlausSysProc_Char.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  idx: tKlausInteger;
  rslt: tklausChar;
begin
  cnt := length(values);
  if (cnt < 1) or (cnt > 2) then errWrongParamCount(cnt, 1, 2, at);
  if cnt = 1 then idx := 0 else idx := getSimpleInt(values[1]);
  rslt := klstrChar(getSimpleStr(values[0]), idx, at);
  returnSimple(frame, klausSimpleC(rslt));
end;

{ tKlausSysProc_PrevNext }

function tKlausSysProc_PrevNext.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_PrevNext.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 2) or (cnt > 4) then errWrongParamCount(cnt, 2, 4, at);
  checkCanAssign(kdtString, expr[0].resultTypeDef, expr[0].point);
  checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
  if cnt > 2 then
    checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
  if cnt > 3 then begin
    checkCanAssign(kdtInteger, expr[3].resultTypeDef, expr[3].point, true);
    if not expr[3].isVarPath then raise eKlausError.create(ercInvalidOutputParam, expr[3].point);
  end;
end;

procedure tKlausSysProc_PrevNext.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  case length(types) of
    2: modes := [kpmInput, kpmInput];
    3: modes := [kpmInput, kpmInput, kpmInput];
    4: modes := [kpmInput, kpmInput, kpmInput, kpmOutput];
  else
    errWrongParamCount(length(types), 2, 4, at);
  end;
end;

procedure tKlausSysProc_PrevNext.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  rslt, count, chars: tKlausInteger;
begin
  cnt := length(values);
  if (cnt < 2) or (cnt > 4) then errWrongParamCount(cnt, 2, 4, at);
  if cnt = 2 then count := 1 else count := getSimpleInt(values[2]);
  rslt := doPrevNext(getSimpleStr(values[0]), getSimpleInt(values[1]), count, chars, at);
  if cnt = 4 then (values[3].v as tKlausVarValueSimple).setSimple(klausSimpleI(chars), at);
  returnSimple(frame, klausSimpleI(rslt));
end;

{ tKlausSysProc_Next }

constructor tKlausSysProc_Next.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Next, aPoint);
  declareRetValue(kdtInteger);
end;

function tKlausSysProc_Next.doPrevNext(
  const s: tKlausString; idx, count: tKlausInteger;
  out chars: tKlausInteger; const at: tSrcPoint): tKlausInteger;
begin
  result := klstrNext(s, idx, count, chars, at);
end;

{ tKlausSysProc_Prev }

constructor tKlausSysProc_Prev.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Prev, aPoint);
  declareRetValue(kdtInteger);
end;

function tKlausSysProc_Prev.doPrevNext(
  const s: tKlausString; idx, count: tKlausInteger;
  out chars: tKlausInteger; const at: tSrcPoint): tKlausInteger;
begin
  result := klstrPrev(s, idx, count, chars, at);
end;

{ tKlausSysProc_Overwrite }

constructor tKlausSysProc_Overwrite.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Overwrite, aPoint);
end;

function tKlausSysProc_Overwrite.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_Overwrite.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 3) or (cnt > 5) then errWrongParamCount(cnt, 3, 5, at);
  checkCanAssign(kdtString, expr[0].resultTypeDef, expr[0].point, true);
  checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
  checkCanAssign(kdtString, expr[2].resultTypeDef, expr[2].point);
  if cnt > 3 then checkCanAssign(kdtInteger, expr[3].resultTypeDef, expr[3].point);
  if cnt > 4 then checkCanAssign(kdtInteger, expr[4].resultTypeDef, expr[4].point);
end;

procedure tKlausSysProc_Overwrite.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  case length(types) of
    3: modes := [kpmInOut, kpmInput, kpmInput];
    4: modes := [kpmInOut, kpmInput, kpmInput, kpmInput];
    5: modes := [kpmInOut, kpmInput, kpmInput, kpmInput, kpmInput];
  else
    errWrongParamCount(length(types), 3, 5, at);
  end;
end;

procedure tKlausSysProc_Overwrite.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  index, count: tKlausInteger;
begin
  cnt := length(values);
  if (cnt < 3) or (cnt > 5) then errWrongParamCount(cnt, 3, 5, at);
  if cnt <= 3 then index := 0 else index := getSimpleInt(values[3]);
  if cnt <= 4 then count := high(tKlausInteger) else count := getSimpleInt(values[4]);
  (values[0].v as tKlausVarValueSimple).stringOverwrite(
    getSimpleInt(values[1]), getSimpleStr(values[2]), index, count, at);
end;

{ tKlausSysProc_Find }

constructor tKlausSysProc_Find.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Find, aPoint);
  declareRetValue(kdtInteger);
end;

function tKlausSysProc_Find.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_Find.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 2) or (cnt > 4) then errWrongParamCount(cnt, 2, 4, at);
  checkCanAssign(kdtString, expr[0].resultTypeDef, expr[0].point);
  checkCanAssign(kdtString, expr[1].resultTypeDef, expr[1].point);
  if cnt > 2 then checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
  if cnt > 3 then checkCanAssign(kdtBoolean, expr[3].resultTypeDef, expr[3].point);
end;

procedure tKlausSysProc_Find.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  case length(types) of
    2: modes := [kpmInput, kpmInput];
    3: modes := [kpmInput, kpmInput, kpmInput];
    4: modes := [kpmInput, kpmInput, kpmInput, kpmInput];
  else
    errWrongParamCount(length(types), 2, 4, at);
  end;
end;

procedure tKlausSysProc_Find.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  index, rslt: tKlausInteger;
  matchCase: tKlausBoolean;
  what, where: string;
begin
  cnt := length(values);
  if (cnt < 2) or (cnt > 4) then errWrongParamCount(cnt, 2, 4, at);
  if cnt <= 2 then index := 0 else index := getSimpleInt(values[2]);
  if index < 0 then raise eKlausError.createFmt(ercInvalidStringIndex, at, [index]);
  if cnt <= 3 then matchCase := true else matchCase := getSimpleBool(values[3]);
  what := getSimpleStr(values[0]);
  where := getSimpleStr(values[1]);
  if not matchCase then begin
    what := u8Lower(what);
    where := u8Lower(where);
  end;
  rslt := system.pos(what, where, index+1);
  returnSimple(frame, klausSimpleI(rslt-1));
end;

{ tKlausSysProc_Replace }

constructor tKlausSysProc_Replace.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Replace, aPoint);
  fStr := tKlausProcParam.create(self, 'стр', aPoint, kpmInOut, source.simpleTypes[kdtString]);
  addParam(fStr);
  fIdx := tKlausProcParam.create(self, 'индекс', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fIdx);
  fCount := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fCount);
  fWith := tKlausProcParam.create(self, 'чем', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fWith);
end;

procedure tKlausSysProc_Replace.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  v: tKlausVarValueSimple;
begin
  v := frame.varByDecl(fStr, at).value as tKlausVarValueSimple;
  v.stringReplace(
    getSimpleInt(frame, fIdx, at),
    getSimpleInt(frame, fCount, at),
    getSimpleStr(frame, fWith, at), at);
end;

{ tKlausSysProc_Format }

constructor tKlausSysProc_Format.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Format, aPoint);
  declareRetValue(kdtString);
end;

function tKlausSysProc_Format.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_Format.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  i: integer;
begin
  if length(expr) < 1 then raise eKlausError.createFmt(ercWrongNumberOfParams, at, [0, strOneOrMore]);
  checkCanAssign(kdtString, expr[0].resultTypeDef, expr[0].point);
  for i := 1 to length(expr)-1 do
    if expr[i].resultTypeDef is tKlausTypeDefArray then begin
      if (expr[i].resultTypeDef as tKlausTypeDefArray).elmtType.dataType = kdtComplex then
        raise eKlausError.create(ercInvalidFormatParamType, expr[i].point)
    end else if expr[i].resultType = kdtComplex then
      raise eKlausError.create(ercInvalidFormatParamType, expr[i].point);
end;

procedure tKlausSysProc_Format.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_Format.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  i, j, idx, len: integer;
  rslt: tKlausString;
  a: tKlausVarValueArray;
  v: array of tKlausSimpleValue = nil;
begin
  if length(values) < 1 then raise eKlausError.createFmt(ercWrongNumberOfParams, at, [0, strOneOrMore]);
  rslt := getSimpleStr(values[0]);
  len := length(values)-1;
  for i := 1 to length(values)-1 do
    if values[i].v is tKlausVarValueArray then
      inc(len, (values[i].v as tKlausVarValueArray).count-1);
  setLength(v, len);
  idx := 0;
  for i := 1 to length(values)-1 do begin
    if values[i].v is tKlausVarValueArray then begin
      a := values[i].v as tKlausVarValueArray;
      for j := 0 to a.count-1 do begin
        v[idx] := (a.getElmt(j, values[i].at) as tKlausVarValueSimple).simple;
        inc(idx);
      end;
    end else begin
      v[idx] := getSimple(values[i]);
      inc(idx);
    end;
  end;
  rslt := klstrFormat(rslt, v, at);
  returnSimple(frame, klausSimpleS(rslt));
end;

{ tKlausSysProc_Upper }

constructor tKlausSysProc_Upper.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Upper, aPoint);
  fStr := tKlausProcParam.create(self, 'стр', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fStr);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_Upper.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleS(u8Upper(getSimpleStr(frame, fStr, at))));
end;

{ tKlausSysProc_Lower }

constructor tKlausSysProc_Lower.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Lower, aPoint);
  fStr := tKlausProcParam.create(self, 'стр', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fStr);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_Lower.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleS(u8Lower(getSimpleStr(frame, fStr, at))));
end;

{ tKlausSysProc_IsNaN }

constructor tKlausSysProc_IsNaN.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_IsNaN, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_IsNaN.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleB(isNaN(getSimpleFloat(frame, fNum, at))));
end;

{ tKlausSysProc_IsFinite }

constructor tKlausSysProc_IsFinite.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_IsFinite, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_IsFinite.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimpleB(not (isNaN(f) or IsInfinite(f))));
end;

{ tKlausSysProc_Round }

constructor tKlausSysProc_Round.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Round, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtInteger);
end;

procedure tKlausSysProc_Round.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  if isNaN(f) or IsInfinite(f) then raise eKlausError.create(ercArgumentIsNotFinite, at);
  returnSimple(frame, klausSimpleI(round(f)));
end;

{ tKlausSysProc_RoundTo }

constructor tKlausSysProc_RoundTo.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_RoundTo, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  fDigits := tKlausProcParam.create(self, 'знаков', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fDigits);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_RoundTo.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  rslt: tKlausFloat;
  n: tKlausFloat;
  d: tKlausInteger;
begin
  n := getSimpleFloat(frame, fNum, at);
  d := getSimpleInt(frame, fDigits, at);
  rslt := roundTo(n, -d);
  returnSimple(frame, klausSimpleF(rslt));
end;

{ tKlausSysProc_Int }

constructor tKlausSysProc_Int.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Int, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Int.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimpleF(int(f)));
end;

{ tKlausSysProc_Frac }

constructor tKlausSysProc_Frac.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Frac, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Frac.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimpleF(frac(f)));
end;

{ tKlausSysProc_Sin }

constructor tKlausSysProc_Sin.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Sin, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Sin.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimpleF(sin(f)));
end;

{ tKlausSysProc_Cos }

constructor tKlausSysProc_Cos.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Cos, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Cos.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimpleF(cos(f)));
end;

{ tKlausSysProc_Tan }

constructor tKlausSysProc_Tan.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Tan, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Tan.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimpleF(tan(f)));
end;

{ tKlausSysProc_ArcSin }

constructor tKlausSysProc_ArcSin.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_ArcSin, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_ArcSin.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimpleF(arcsin(f)));
end;

{ tKlausSysProc_ArcCos }

constructor tKlausSysProc_ArcCos.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_ArcCos, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_ArcCos.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimpleF(arccos(f)));
end;

{ tKlausSysProc_ArcTan }

constructor tKlausSysProc_ArcTan.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_ArcTan, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_ArcTan.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimpleF(arctan(f)));
end;

{ tKlausSysProc_Ln }

constructor tKlausSysProc_Ln.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Ln, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Ln.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimpleF(ln(f)));
end;

{ tKlausSysProc_Exp }

constructor tKlausSysProc_Exp.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Exp, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Exp.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimpleF(exp(f)));
end;

{ tKlausSysProc_Delay }

constructor tKlausSysProc_Delay.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Delay, aPoint);
  fDelay := tKlausProcParam.create(self, 'мсек', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fDelay);
end;

procedure tKlausSysProc_Delay.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  msec: tKlausInteger;
begin
  msec := getSimpleInt(frame, fDelay, at);
  while msec > 0 do begin
    sleep(min(msec, 100));
    msec -= 100;
    if klausDebugThread <> nil then
      klausDebugThread.checkTerminated;
  end;
end;

{ tKlausSysProc_Random }

constructor tKlausSysProc_Random.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Random, aPoint);
  fRange := tKlausProcParam.create(self, 'макс', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fRange);
  declareRetValue(kdtInteger);
end;

procedure tKlausSysProc_Random.run(frame: tKlausStackFrame; const at: tSrcPoint);
const
  init: boolean = false;
begin
  if not init then begin
    randomize;
    init := true;
  end;
  returnSimple(frame, klausSimpleI(random(getSimpleInt(frame, fRange, at))));
end;

{ tKlausSysProc_ProgramName }

constructor tKlausSysProc_ProgramName.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_ProgramName, aPoint);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_ProgramName.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleS(frame.owner.source.module.name));
end;

{ tKlausSysProc_CourseName }

constructor tKlausSysProc_CourseName.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_CourseName, aPoint);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_CourseName.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  m: tKlausModule;
begin
  m := frame.owner.source.module;
  if not (m is tKlausProgram) then returnSimple(frame, klausSimpleS(''))
  else returnSimple(frame, klausSimpleS((m as tKlausProgram).courseName));
end;

end.

