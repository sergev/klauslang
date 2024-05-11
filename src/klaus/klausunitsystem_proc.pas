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
  Types, Classes, SysUtils, U8, KlausErr, KlausLex, KlausDef, KlausSyn, KlausSrc, KlausUnitSystem;

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
  // функция прочесть(вых арг0, арг1, арг2, ...): целое;
  tKlausSysProc_ReadLn = class(tKlausSysProcDecl)
    private
      fStream: tStringReadStream;
      function processInputData(frame: tKlausStackFrame; const data: string; values: array of tKlausVarValueAt; const at: tSrcPoint): tKlausInteger;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      destructor  destroy; override;
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
  // процедура терминал(вх поток: целое; вх сквозной: логическое);
  tKlausSysProc_Terminal = class(tKlausSysProcDecl)
    private
      fHandle: tKlausProcParam;
      fRaw: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // Базовый класс для функций работы с терминалом
  tKlausSysTermProc = class(tKlausSysProcDecl)
    protected
      procedure writeStdStream(frame: tKlausStackFrame; const s: string); virtual;
  end;

type
  // процедура размерЭкрана(вх горз, верт: целое);
  tKlausSysProc_SetScreenSize = class(tKlausSysTermProc)
    private
      fHorz: tKlausProcParam;
      fVert: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура очиститьЭкран;
  tKlausSysProc_ClearScreen = class(tKlausSysTermProc)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура очиститьСтроку(вх где: целое);
  tKlausSysProc_ClearLine = class(tKlausSysTermProc)
    private
      fWhere: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура курсор(вх горз, верт: целое);
  tKlausSysProc_SetCursorPos = class(tKlausSysTermProc)
    private
      fHorz: tKlausProcParam;
      fVert: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура курсорВерт(вх верт: целое);
  tKlausSysProc_SetCursorPosVert = class(tKlausSysTermProc)
    private
      fVert: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура курсорГорз(вх горз: целое);
  tKlausSysProc_SetCursorPosHorz = class(tKlausSysTermProc)
    private
      fHorz: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура подвинутьКурсор(вх горз, верт: целое);
  tKlausSysProc_CursorMove = class(tKlausSysTermProc)
    private
      fHorz: tKlausProcParam;
      fVert: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура запомнитьКурсор();
  tKlausSysProc_CursorSave = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура вернутьКурсор();
  tKlausSysProc_CursorRestore = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура скрытьКурсор;
  tKlausSysProc_HideCursor = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура показатьКурсор;
  tKlausSysProc_ShowCursor = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура цветФона(вх цвет: целое);
  tKlausSysProc_BackColor = class(tKlausSysTermProc)
    private
      fColor: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура цветШрифта(вх цвет: целое);
  tKlausSysProc_FontColor = class(tKlausSysTermProc)
    private
      fColor: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура стильШрифта(вх стиль: целое);
  tKlausSysProc_FontStyle = class(tKlausSysTermProc)
    private
      fStyle: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура сброситьАтрибуты;
  tKlausSysProc_ResetTextAttr = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция цвет256(вх кр, зел, син: целое): целое;
  tKlausSysProc_Color256 = class(tKlausSysProcDecl)
    private
      fRed: tKlausProcParam;
      fGreen: tKlausProcParam;
      fBlue: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция естьВвод: логическое;
  tKlausSysProc_InputAvailable = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция прочестьСимвол: символ;
  tKlausSysProc_ReadChar = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлСоздать(вх типФайла: целое; вх имя: строка; вх режим: целое): объект;
  tKlausSysProc_FileCreate = class(tKlausSysProcDecl)
    private
      fFileType: tKlausProcParam;
      fFileName: tKlausProcParam;
      fMode: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлОткрыть(вх типФайла: целое; вх имя: строка; вх режим: целое): объект;
  tKlausSysProc_FileOpen = class(tKlausSysProcDecl)
    private
      fFileType: tKlausProcParam;
      fFileName: tKlausProcParam;
      fMode: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура файлЗакрыть(вв файл: объект);
  tKlausSysProc_FileClose = class(tKlausSysProcDecl)
    private
      fFile: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура файлЗаписать(вх файл: объект; вх арг1, арг2, арг3...);
  tKlausSysProc_FileWrite = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура файлПрочесть(вх файл: объект; вых арг1, арг2, арг3...);
  tKlausSysProc_FileRead = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция файлПоз(вх файл: объект): целое;
  // функция файлПоз(вх файл: объект; вх поз: целое): целое;
  // функция файлПоз(вх файл: объект; вх поз: целое; вх откуда: целое): целое;
  tKlausSysProc_FilePos = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция файлРазмер(вх файл: объект): целое;
  // функция файлРазмер(вх файл: объект; вх размер: целое): целое;
  tKlausSysProc_FileSize = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция файлЕсть(вх имя: строка): логическое;
  tKlausSysProc_FileExists = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлЕстьКат(вх имя: строка): логическое;
  tKlausSysProc_FileDirExists = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлВрмКат(вх общий: логическое): строка;
  tKlausSysProc_FileTempDir = class(tKlausSysProcDecl)
    private
      fGlobal: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлВрмИмя(вх общий: логическое; вх префикс: строка): строка;
  tKlausSysProc_FileTempName = class(tKlausSysProcDecl)
    private
      fGlobal: tKlausProcParam;
      fPrefix: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлПолныйПуть(вх путь: строка): строка;
  tKlausSysProc_FileExpandName = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлПуть(вх путь: строка): строка;
  tKlausSysProc_FileExtractPath = class(tKlausSysProcDecl)
    private
      fPath: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлИмя(вх путь: строка): строка;
  tKlausSysProc_FileExtractName = class(tKlausSysProcDecl)
    private
      fPath: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлРасширение(вх путь: строка): строка;
  tKlausSysProc_FileExtractExt = class(tKlausSysProcDecl)
    private
      fPath: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлВыполняемый(): строка;
  tKlausSysProc_FileProgName = class(tKlausSysProcDecl)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлДомКат(): строка;
  tKlausSysProc_FileHomeDir = class(tKlausSysProcDecl)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлАтрибуты(вх имя: строка): целое;
  tKlausSysProc_FileGetAttrs = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлВозраст(вх имя: строка): момент;
  tKlausSysProc_FileGetAge = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура файлПереместить(вх откуда, куда: строка);
  tKlausSysProc_FileRename = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
      fNewName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура файлУдалить(вх имя: строка);
  tKlausSysProc_FileDelete = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  tKlausFileSearch = class
    public
      searchRec: tSearchRec;
      destructor  destroy; override;
  end;

type
  // Базовый класс для функций листинга каталога
  tKlausSysProcFileFind = class(tKlausSysProcDecl)
    protected
      procedure fillInFileInfo(search: tKlausFileSearch; v: tKlausVarValueStruct; const at: tSrcPoint);
  end;

type
  // функция файлПервый(вх шаблон: строка; вых инфо: тФайлИнфо): объект;
  tKlausSysProc_FileFindFirst = class(tKlausSysProcFileFind)
    private
      fMask: tKlausProcParam;
      fInfo: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлСледующий(вых инфо: тФайлИнфо): логический;
  tKlausSysProc_FileFindNext = class(tKlausSysProcFileFind)
    private
      fObj: tKlausProcParam;
      fInfo: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

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
  Math, LCLIntf, Graphics, GraphType, GraphUtils, KlausUtils;

const
  klausTermProcStream: tHandle = 1;

resourcestring
  strOneOrMore = '1 или более';
  strNumOrNum = '%d или %d';
  strEventQueue = 'источник событий';

{ tKlausSysProc_Destroy }

constructor tKlausSysProc_Destroy.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Destroy, aPoint);
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
  inherited create(aOwner, klausSysProcName_Date, aPoint);
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
  returnSimple(frame, klausSimple(tKlausMoment(int(dt))));
end;

{ tKlausSysProc_Time }

constructor tKlausSysProc_Time.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Time, aPoint);
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
  returnSimple(frame, klausSimple(tKlausMoment(frac(dt))));
end;

{ tKlausSysProc_Now }

constructor tKlausSysProc_Now.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Now, aPoint);
  declareRetValue(kdtMoment);
end;

procedure tKlausSysProc_Now.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimple(tKlausMoment(now)));
end;

{ tKlausSysProc_exceptionName }

constructor tKlausSysProc_ExceptionName.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_exceptionName, aPoint);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_ExceptionName.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimple(globalErrorInfo.name));
end;

{ tKlausSysProc_exceptionText }

constructor tKlausSysProc_ExceptionText.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_exceptionText, aPoint);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_ExceptionText.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimple(globalErrorInfo.text));
end;

{ tKlausSysProc_ReadLn }

constructor tKlausSysProc_ReadLn.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_ReadLn, aPoint);
  declareRetValue(kdtInteger);
  fStream := tStringReadStream.create('');
end;

destructor tKlausSysProc_ReadLn.destroy;
begin
  freeAndNil(fStream);
  inherited destroy;
end;

(*
function tKlausSysProc_ReadLn.processInputData(
  const data: string; values: array of tKlausVarValueAt; const at: tSrcPoint): tKlausInteger;

  procedure put(idx: integer; v: tKlausSimpleValue);
  begin
    (values[idx].v as tKlausVarValueSimple).setSimple(v, values[idx].at);
  end;

  procedure castAndPut(idx: integer; s: string);
  var
    dt: tKlausSimpleType;
    sv: tKlausSimpleValue;
  begin
    dt := values[idx].v.dataType.dataType;
    case dt of
      kdtInteger: sv := klausSimple(klausStrToInt(s));
      kdtFloat:   sv := klausSimple(klausStrToFloat(s));
      kdtMoment:  sv := klausSimple(klausStrToMoment(s));
      kdtBoolean: sv := klausSimple(klausStrToBool(s));
    else
      sv := klausZeroValue(kdtString);
      assert(false, 'Unexpected value type');
    end;
    (values[idx].v as tKlausVarValueSimple).setSimple(sv, values[idx].at);
  end;

var
  sub: string;
  p, spc: pChar;
  idx: integer;
  dt: tKlausDataType;
  v: tKlausSimpleValue;
begin
  if data = '' then exit(0);
  idx := 0;
  p := pChar(data);
  while idx < length(values) do begin
    dt := values[idx].v.dataType.dataType;
    case dt of
      kdtObject:
        raise eKlausError.createFmt(ercValueCannotBeRead, values[idx].at, [klausDataTypeCaption[dt]]);
      kdtChar: begin
        v := klausSimple(klausStrToChar(u8GetChar(p)));
        put(idx, v);
      end;
      kdtString: begin
        v := klausSimple(tKlausString(copy(data, pChar(data)-p+1)));
        put(idx, v);
        break;
      end;
    else
      while p^ in [#9, ' '] do inc(p);
      if p^ = #0 then break;
      spc := p;
      while not (spc^ in [#0, #9, ' ']) do inc(spc);
      sub := copy(data, p-pChar(data)+1, spc-p);
      castAndPut(idx, sub);
      p := spc;
    end;
    inc(idx);
    if p^ = #0 then break;
  end;
  result := idx;
end;
*)

function tKlausSysProc_ReadLn.processInputData(
  frame: tKlausStackFrame; const data: string; values: array of tKlausVarValueAt; const at: tSrcPoint): tKlausInteger;
var
  i: integer;
  sv: tKlausSimpleValue;
begin
  fStream.data := data;
  for i := 0 to length(values)-1 do try
    if not klausReadFromText(fStream, values[i].v.dataType.dataType, sv, values[i].at) then exit(i);
    (values[i].v as tKlausVarValueSimple).setSimple(sv, values[i].at);
  except
    klausTranslateException(frame, values[i].at);
  end;
  result := length(values);
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
const
  prev: u8Char = #0;
var
  s: string;
  c: u8Char;
  l, idx: sizeInt;
begin
  try
    s := '';
    idx := 1;
    frame.owner.readStdIn(c);
    if (c = #10) and (prev = #13) then frame.owner.readStdIn(c);
    prev := c;
    while (c <> '') and not (c[1] in [#0, #10, #13, #26]) do begin
      l := byte(c[0]);
      if idx-1 > length(s)-l then setLength(s, idx+32);
      move(c[1], s[idx], l);
      idx += l;
      frame.owner.readStdIn(c);
      prev := c;
    end;
    setLength(s, idx-1);
    //frame.owner.writeStdOut('"'+s+'"'#10);
    returnSimple(frame, klausSimple(processInputData(frame, s, values, at)));
  except
    klausTranslateException(frame, at);
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
  inherited create(aOwner, klausSysProcName_Write, aPoint);
end;

procedure tKlausSysProc_Write.doWrite(frame: tKlausStackFrame; const s: string);
begin
  frame.owner.writeStdOut(s);
end;

{ tKlausSysProc_Report }

constructor tKlausSysProc_Report.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Report, aPoint);
end;

procedure tKlausSysProc_Report.doWrite(frame: tKlausStackFrame; const s: string);
begin
  frame.owner.writeStdErr(s);
end;

{ tKlausSysProc_Length }

constructor tKlausSysProc_Length.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Length, aPoint);
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
    returnSimple(frame, klausSimple((values[0].v as tKlausVarValueArray).count));
  end else if values[0].v is tKlausVarValueDict then begin
    // словарь
    returnSimple(frame, klausSimple((values[0].v as tKlausVarValueDict).count));
  end else if values[0].v is tKlausVarValueSimple then begin
    // строка
    if cnt > 1 then begin
      rslt := getSimpleInt(values[1]);
      rslt := (values[0].v as tKlausVarValueSimple).stringSetLength(rslt, at);
      returnSimple(frame, klausSimple(rslt));
    end else
      returnSimple(frame, klausSimple(length(getSimpleStr(values[0]))));
  end else
    errTypeMismatch(values[0].at);
end;

{ tKlausSysProc_Add }

constructor tKlausSysProc_Add.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Add, aPoint);
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
  inherited create(aOwner, klausSysProcName_Insert, aPoint);
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
  inherited create(aOwner, klausSysProcName_Delete, aPoint);
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
  inherited create(aOwner, klausSysProcName_Clear, aPoint);
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
  inherited create(aOwner, klausSysProcName_Part, aPoint);
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
  returnSimple(frame, klausSimple(rslt));
end;

{ tKlausSysProc_Char }

constructor tKlausSysProc_Char.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Char, aPoint);
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
  returnSimple(frame, klausSimple(rslt));
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
  if cnt = 4 then (values[3].v as tKlausVarValueSimple).setSimple(klausSimple(chars), at);
  returnSimple(frame, klausSimple(rslt));
end;

{ tKlausSysProc_Next }

constructor tKlausSysProc_Next.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Next, aPoint);
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
  inherited create(aOwner, klausSysProcName_Prev, aPoint);
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
  inherited create(aOwner, klausSysProcName_Overwrite, aPoint);
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
  inherited create(aOwner, klausSysProcName_Find, aPoint);
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
  returnSimple(frame, klausSimple(rslt-1));
end;

{ tKlausSysProc_Replace }

constructor tKlausSysProc_Replace.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Replace, aPoint);
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
  inherited create(aOwner, klausSysProcName_Format, aPoint);
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
  returnSimple(frame, klausSimple(rslt));
end;

{ tKlausSysProc_Upper }

constructor tKlausSysProc_Upper.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Upper, aPoint);
  fStr := tKlausProcParam.create(self, 'стр', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fStr);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_Upper.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimple(u8Upper(getSimpleStr(frame, fStr, at))));
end;

{ tKlausSysProc_Lower }

constructor tKlausSysProc_Lower.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Lower, aPoint);
  fStr := tKlausProcParam.create(self, 'стр', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fStr);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_Lower.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimple(u8Lower(getSimpleStr(frame, fStr, at))));
end;

{ tKlausSysProc_IsNaN }

constructor tKlausSysProc_IsNaN.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_IsNaN, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_IsNaN.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimple(isNaN(getSimpleFloat(frame, fNum, at))));
end;

{ tKlausSysProc_IsFinite }

constructor tKlausSysProc_IsFinite.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_IsFinite, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_IsFinite.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimple(not (isNaN(f) or IsInfinite(f))));
end;

{ tKlausSysProc_Round }

constructor tKlausSysProc_Round.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Round, aPoint);
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
  returnSimple(frame, klausSimple(round(f)));
end;

{ tKlausSysProc_Int }

constructor tKlausSysProc_Int.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Int, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Int.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimple(tKlausFloat(int(f))));
end;

{ tKlausSysProc_Frac }

constructor tKlausSysProc_Frac.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Frac, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Frac.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimple(tKlausFloat(frac(f))));
end;

{ tKlausSysProc_Sin }

constructor tKlausSysProc_Sin.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Sin, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Sin.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimple(tKlausFloat(sin(f))));
end;

{ tKlausSysProc_Cos }

constructor tKlausSysProc_Cos.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Cos, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Cos.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimple(tKlausFloat(cos(f))));
end;

{ tKlausSysProc_Tan }

constructor tKlausSysProc_Tan.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Tan, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Tan.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimple(tKlausFloat(tan(f))));
end;

{ tKlausSysProc_ArcSin }

constructor tKlausSysProc_ArcSin.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_ArcSin, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_ArcSin.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimple(tKlausFloat(arcsin(f))));
end;

{ tKlausSysProc_ArcCos }

constructor tKlausSysProc_ArcCos.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_ArcCos, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_ArcCos.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimple(tKlausFloat(arccos(f))));
end;

{ tKlausSysProc_ArcTan }

constructor tKlausSysProc_ArcTan.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_ArcTan, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_ArcTan.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimple(tKlausFloat(arctan(f))));
end;

{ tKlausSysProc_Ln }

constructor tKlausSysProc_Ln.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Ln, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Ln.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimple(tKlausFloat(ln(f))));
end;

{ tKlausSysProc_Exp }

constructor tKlausSysProc_Exp.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Exp, aPoint);
  fNum := tKlausProcParam.create(self, 'число', aPoint, kpmInput, source.simpleTypes[kdtFloat]);
  addParam(fNum);
  declareRetValue(kdtFloat);
end;

procedure tKlausSysProc_Exp.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausFloat;
begin
  f := getSimpleFloat(frame, fNum, at);
  returnSimple(frame, klausSimple(tKlausFloat(exp(f))));
end;

{ tKlausSysProc_Delay }

constructor tKlausSysProc_Delay.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Delay, aPoint);
  fDelay := tKlausProcParam.create(self, 'мсек', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fDelay);
end;

procedure tKlausSysProc_Delay.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  sleep(getSimpleInt(frame, fDelay, at));
end;

{ tKlausSysProc_Random }

constructor tKlausSysProc_Random.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Random, aPoint);
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
  returnSimple(frame, klausSimple(random(getSimpleInt(frame, fRange, at))));
end;

{ tKlausSysProc_Terminal }

constructor tKlausSysProc_Terminal.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Terminal, aPoint);
  fHandle := tKlausProcParam.create(self, 'поток', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fHandle);
  fRaw := tKlausProcParam.create(self, 'сквозной', aPoint, kpmInput, source.simpleTypes[kdtBoolean]);
  addParam(fRaw);
end;

procedure tKlausSysProc_Terminal.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  klausTermProcStream := getSimpleInt(frame, fHandle, at);
  frame.owner.setRawInputMode(getSimpleBool(frame, fRaw, at));
end;

{ tKlausSysTermProc }

procedure tKlausSysTermProc.writeStdStream(frame: tKlausStackFrame; const s: string);
begin
  if klausTermProcStream = klausConst_StdErr then frame.owner.writeStdErr(s)
  else frame.owner.writeStdOut(s);
end;

{ tKlausSysProc_SetScreenSize }

constructor tKlausSysProc_SetScreenSize.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_SetScreenSize, aPoint);
  fHorz := tKlausProcParam.create(self, 'горз', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fHorz);
  fVert := tKlausProcParam.create(self, 'верт', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fVert);
end;

procedure tKlausSysProc_SetScreenSize.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  cx, cy: tKlausInteger;
begin
  cy := getSimpleInt(frame, fVert, at);
  cx := getSimpleInt(frame, fHorz, at);
  writeStdStream(frame, format(#27'[8;%d;%dt', [word(cy), word(cx)]));
end;

{ tKlausSysProc_ClearScreen }

constructor tKlausSysProc_ClearScreen.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_ClearScreen, aPoint);
end;

procedure tKlausSysProc_ClearScreen.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  writeStdStream(frame, #27'[2J');
end;

{ tKlausSysProc_ClearLine }

constructor tKlausSysProc_ClearLine.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_ClearLine, aPoint);
  fWhere := tKlausProcParam.create(self, 'где', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fWhere);
end;

procedure tKlausSysProc_ClearLine.run(frame: tKlausStackFrame; const at: tSrcPoint);
const
  pv: array[-1..+1] of byte = (1, 2, 0);
var
  idx: integer;
begin
  idx := klausCmp(getSimpleInt(frame, fWhere, at), 0);
  writeStdStream(frame, format(#27'[%dK', [pv[idx]]));
end;

{ tKlausSysProc_SetCursorPos }

constructor tKlausSysProc_SetCursorPos.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_SetCursorPos, aPoint);
  fHorz := tKlausProcParam.create(self, 'горз', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fHorz);
  fVert := tKlausProcParam.create(self, 'верт', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fVert);
end;

procedure tKlausSysProc_SetCursorPos.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  x, y: tKlausInteger;
begin
  x := getSimpleInt(frame, fHorz, at)+1;
  y := getSimpleInt(frame, fVert, at)+1;
  writeStdStream(frame, format(#27'[%d;%df', [word(y), word(x)]));
end;

{ tKlausSysProc_SetCursorPosVert }

constructor tKlausSysProc_SetCursorPosVert.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_SetCursorPosVert, aPoint);
  fVert := tKlausProcParam.create(self, 'верт', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fVert);
end;

procedure tKlausSysProc_SetCursorPosVert.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  y: tKlausInteger;
begin
  y := getSimpleInt(frame, fVert, at)+1;
  writeStdStream(frame, format(#27'[%dd', [word(y)]));
end;

{ tKlausSysProc_SetCursorPosHorz }

constructor tKlausSysProc_SetCursorPosHorz.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_SetCursorPosHorz, aPoint);
  fHorz := tKlausProcParam.create(self, 'горз', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fHorz);
end;

procedure tKlausSysProc_SetCursorPosHorz.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  x: tKlausInteger;
begin
  x := getSimpleInt(frame, fHorz, at)+1;
  writeStdStream(frame, format(#27'[%d`', [word(x)]));
end;

{ tKlausSysProc_CursorMove }

constructor tKlausSysProc_CursorMove.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_CursorMove, aPoint);
  fHorz := tKlausProcParam.create(self, 'горз', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fHorz);
  fVert := tKlausProcParam.create(self, 'верт', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fVert);
end;

procedure tKlausSysProc_CursorMove.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  vs, hs: string;
  x, y: tKlausInteger;
begin
  x := getSimpleInt(frame, fHorz, at);
  y := getSimpleInt(frame, fVert, at);
  if y < 0 then vs := format(#27'[%dA', [-y])
  else if y > 0 then vs := format(#27'[%dB', [y])
  else vs := '';
  if x < 0 then hs := format(#27'[%dD', [-x])
  else if x > 0 then hs := format(#27'[%dC', [x])
  else hs := '';
  if hs <> '' then writeStdStream(frame, hs);
  if vs <> '' then writeStdStream(frame, vs);
end;

{ tKlausSysProc_CursorSave }

constructor tKlausSysProc_CursorSave.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_CursorSave, aPoint);
end;

procedure tKlausSysProc_CursorSave.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  writeStdStream(frame, #27'[s');
end;

{ tKlausSysProc_CursorRestore }

constructor tKlausSysProc_CursorRestore.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_CursorRestore, aPoint);
end;

procedure tKlausSysProc_CursorRestore.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  writeStdStream(frame, #27'[u');
end;

{ tKlausSysProc_HideCursor }

constructor tKlausSysProc_HideCursor.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_HideCursor, aPoint);
end;

procedure tKlausSysProc_HideCursor.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  writeStdStream(frame, #27'[?25l');
end;

{ tKlausSysProc_ShowCursor }

constructor tKlausSysProc_ShowCursor.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_ShowCursor, aPoint);
end;

procedure tKlausSysProc_ShowCursor.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  writeStdStream(frame, #27'[?25h');
end;

{ tKlausSysProc_BackColor }

constructor tKlausSysProc_BackColor.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_BackColor, aPoint);
  fColor := tKlausProcParam.create(self, 'цвет', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fColor);
end;

procedure tKlausSysProc_BackColor.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  c: tKlausInteger;
begin
  c := getSimpleInt(frame, fColor, at);
  writeStdStream(frame, format(#27'[48;5;%dm', [byte(c)]));
end;

{ tKlausSysProc_FontColor }

constructor tKlausSysProc_FontColor.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FontColor, aPoint);
  fColor := tKlausProcParam.create(self, 'цвет', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fColor);
end;

procedure tKlausSysProc_FontColor.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  c: tKlausInteger;
begin
  c := getSimpleInt(frame, fColor, at);
  writeStdStream(frame, format(#27'[38;5;%dm', [byte(c)]));
end;

{ tKlausSysProc_FontStyle }

constructor tKlausSysProc_FontStyle.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FontStyle, aPoint);
  fStyle := tKlausProcParam.create(self, 'стиль', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fStyle);
end;

procedure tKlausSysProc_FontStyle.run(frame: tKlausStackFrame; const at: tSrcPoint);
const
  bit: array[tFontStyle] of byte = (
    klausConst_FontBold,
    klausConst_FontItalic,
    klausConst_FontUnderline,
    klausConst_FontStrikeOut);
  attr: array[tFontStyle] of array[boolean] of integer = (
    (22, 1), //fsBold
    (23, 3), //fsItalic
    (24, 4), //fsUnderline
    (29, 9)  //fsStrikeOut
  );
var
  n: word;
  s: string;
  fs: tFontStyle;
  style: tKlausInteger;
begin
  s := '';
  style := getSimpleInt(frame, fStyle, at);
  for fs := low(fs) to high(fs) do begin
    n := attr[fs][style and bit[fs] > 0];
    s += format(#27'[%dm', [n]);
  end;
  writeStdStream(frame, s);
end;

{ tKlausSysProc_ResetTextAttr }

constructor tKlausSysProc_ResetTextAttr.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_ResetTextAttr, aPoint);
end;

procedure tKlausSysProc_ResetTextAttr.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  writeStdStream(frame, #27'[0m');
end;

{ tKlausSysProc_Color256 }

constructor tKlausSysProc_Color256.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_Color256, aPoint);
  fRed := tKlausProcParam.create(self, 'кр', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fRed);
  fGreen := tKlausProcParam.create(self, 'зел', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fGreen);
  fBlue := tKlausProcParam.create(self, 'син', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fBlue);
  declareRetValue(kdtInteger);
end;

procedure tKlausSysProc_Color256.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  r, g, b: byte;
begin
  r := getSimpleInt(frame, fRed, at);
  g := getSimpleInt(frame, fGreen, at);
  b := getSimpleInt(frame, fBlue, at);
  returnSimple(frame, klausSimple(tKlausInteger(rgbTo256(r, g, b))));
end;

{ tKlausSysProc_InputAvailable }

constructor tKlausSysProc_InputAvailable.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_InputAvailable, aPoint);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_InputAvailable.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimple(frame.owner.inputAvailable));
end;

{ tKlausSysProc_ReadChar }

constructor tKlausSysProc_ReadChar.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_ReadChar, aPoint);
  declareRetValue(kdtChar);
end;

procedure tKlausSysProc_ReadChar.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  c: u8Char;
  rslt: tKlausChar;
begin
  frame.owner.readStdIn(c);
  if (c = '') or (c[1] = #0) then rslt := 0
  else rslt := u8ToUni(c);
  returnSimple(frame, klausSimple(rslt));
end;

{ tKlausSysProc_FileCreate }

constructor tKlausSysProc_FileCreate.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileCreate, aPoint);
  fFileType := tKlausProcParam.create(self, 'типФайла', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fFileType);
  fFileName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fFileName);
  fMode := tKlausProcParam.create(self, 'режим', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fMode);
  declareRetValue(kdtObject);
end;

procedure tKlausSysProc_FileCreate.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  fn: tKlausString;
  rslt: tKlausObject;
  ft, mode: tKlausInteger;
begin
  ft := getSimpleInt(frame, fFileType, at);
  fn := getSimpleStr(frame, fFileName, at);
  mode := getSimpleInt(frame, fMode, at) or klausFileCreate;
  rslt := frame.owner.objects.allocate(tObject(klausInvalidPointer), at);
  try
    frame.owner.objects.put(rslt, klausGetFileType(ft, at).create(fn, mode), at);
    returnSimple(frame, klausSimpleObj(rslt));
  except
    frame.owner.objects.release(rslt, at);
    raise;
  end;
end;

{ tKlausSysProc_FileOpen }

constructor tKlausSysProc_FileOpen.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileOpen, aPoint);
  fFileType := tKlausProcParam.create(self, 'типФайла', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fFileType);
  fFileName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fFileName);
  fMode := tKlausProcParam.create(self, 'режим', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fMode);
  declareRetValue(kdtObject);
end;

procedure tKlausSysProc_FileOpen.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  fn: tKlausString;
  rslt: tKlausObject;
  ft, mode: tKlausInteger;
begin
  ft := getSimpleInt(frame, fFileType, at);
  fn := getSimpleStr(frame, fFileName, at);
  mode := getSimpleInt(frame, fMode, at);
  rslt := frame.owner.objects.allocate(tObject(klausInvalidPointer), at);
  try
    frame.owner.objects.put(rslt, klausGetFileType(ft, at).create(fn, mode), at);
    returnSimple(frame, klausSimpleObj(rslt));
  except
    frame.owner.objects.release(rslt, at);
    raise;
  end;
end;

{ tKlausSysProc_FileClose }

constructor tKlausSysProc_FileClose.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileClose, aPoint);
  fFile := tKlausProcParam.create(self, 'файл', aPoint, kpmInOut, source.simpleTypes[kdtObject]);
  addParam(fFile);
end;

procedure tKlausSysProc_FileClose.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausObject;
begin
  f := getSimpleObj(frame, fFile, at);
  getKlausObject(frame, f, tKlausFileStream, at);
  frame.owner.objects.releaseAndFree(f, at);
  setSimple(frame, fFile, klausZeroValue(kdtObject), at);
end;

{ tKlausSysProc_FileWrite }

constructor tKlausSysProc_FileWrite.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileWrite, aPoint);
end;

function tKlausSysProc_FileWrite.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_FileWrite.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  i, cnt: integer;
begin
  cnt := length(expr);
  if cnt < 2 then errWrongParamCount(cnt, 2, -1, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  for i := 1 to cnt-1 do
    if expr[i].resultType = kdtComplex then
      raise eKlausError.create(ercCannotWriteComplexType, expr[i].point);
end;

procedure tKlausSysProc_FileWrite.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_FileWrite.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  i: integer;
  stream: tKlausFileStream;
begin
  try
    stream := getKlausObject(frame, getSimpleObj(values[0]), tKlausFileStream, values[0].at) as tKlausFileStream;
    for i := 1 to length(values)-1 do begin
      if not (values[i].v is tKlausVarValueSimple) then
        raise eKlausError.create(ercCannotWriteComplexType, values[i].at);
      stream.writeSimpleValue(getSimple(values[i]), values[i].at);
    end;
  except
    klausTranslateException(frame, at);
  end;
end;

{ tKlausSysProc_FileRead }

constructor tKlausSysProc_FileRead.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileRead, aPoint);
end;

function tKlausSysProc_FileRead.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_FileRead.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  i, cnt: integer;
begin
  cnt := length(expr);
  if cnt < 2 then errWrongParamCount(cnt, 2, -1, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  for i := 1 to cnt-1 do
    if expr[i].resultType = kdtComplex then
      raise eKlausError.create(ercCannotReadComplexType, expr[i].point);
end;

procedure tKlausSysProc_FileRead.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i, cnt: integer;
begin
  modes := nil;
  cnt := length(types);
  setLength(modes, cnt);
  modes[0] := kpmInput;
  for i := 1 to cnt-1 do modes[i] := kpmOutput;
end;

procedure tKlausSysProc_FileRead.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  i: integer;
  vv: tKlausVarValueSimple;
  stream: tKlausFileStream;
begin
  try
    stream := getKlausObject(frame, getSimpleObj(values[0]), tKlausFileStream, values[0].at) as tKlausFileStream;
    for i := 1 to length(values)-1 do begin
      if not (values[i].v is tKlausVarValueSimple) then
        raise eKlausError.create(ercCannotReadComplexType, values[i].at);
      vv := values[i].v as tKlausVarValueSimple;
      try vv.setSimple(stream.readSimpleValue(vv.dataType.dataType, values[i].at), values[i].at);
      except klausTranslateException(frame, values[i].at); end;
    end;
  except
    klausTranslateException(frame, at);
  end;
end;

{ tKlausSysProc_FilePos }

constructor tKlausSysProc_FilePos.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FilePos, aPoint);
  declareRetValue(kdtInteger);
end;

function tKlausSysProc_FilePos.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_FilePos.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 1) or (cnt > 3) then errWrongParamCount(cnt, 1, 3, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  if cnt > 1 then checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
  if cnt > 2 then checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
end;

procedure tKlausSysProc_FilePos.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_FilePos.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  origin: tSeekOrigin;
  stream: tKlausFileStream;
begin
  cnt := length(values);
  origin := soBeginning;
  if cnt >= 3 then case getSimpleInt(values[2]) of
    klausFilePosFromEnd: origin := soEnd;
    klausFilePosFromCurrent: origin := soCurrent;
  end;
  try
    stream := getKlausObject(frame, getSimpleObj(values[0]), tKlausFileStream, values[0].at) as tKlausFileStream;
    if cnt >= 2 then stream.seek(getSimpleInt(values[1]), origin);
    returnSimple(frame, klausSimple(stream.position));
  except
    klausTranslateException(frame, at);
  end;
end;

{ tKlausSysProc_FileSize }

constructor tKlausSysProc_FileSize.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileSize, aPoint);
  declareRetValue(kdtInteger);
end;

function tKlausSysProc_FileSize.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_FileSize.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 1) or (cnt > 2) then errWrongParamCount(cnt, 1, 2, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  if cnt > 1 then checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
end;

procedure tKlausSysProc_FileSize.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_FileSize.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  stream: tKlausFileStream;
begin
  cnt := length(values);
  try
    stream := getKlausObject(frame, getSimpleObj(values[0]), tKlausFileStream, values[0].at) as tKlausFileStream;
    if cnt >= 2 then stream.size := getSimpleInt(values[1]);
    returnSimple(frame, klausSimple(stream.size));
  except
    klausTranslateException(frame, at);
  end;
end;

{ tKlausSysProc_FileExists }

constructor tKlausSysProc_FileExists.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileExists, aPoint);
  fName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_FileExists.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  fn: tKlausString;
begin
  fn := getSimpleStr(frame, fName, at);
  returnSimple(frame, klausSimple(fileExists(fn)));
end;

{ tKlausSysProc_FileDirExists }

constructor tKlausSysProc_FileDirExists.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileDirExists, aPoint);
  fName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_FileDirExists.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  fn: tKlausString;
begin
  fn := getSimpleStr(frame, fName, at);
  returnSimple(frame, klausSimple(directoryExists(fn)));
end;

{ tKlausSysProc_FileTempDir }

constructor tKlausSysProc_FileTempDir.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileTempDir, aPoint);
  fGlobal := tKlausProcParam.create(self, 'общий', aPoint, kpmInput, source.simpleTypes[kdtBoolean]);
  addParam(fGlobal);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileTempDir.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimple(getTempDir(getSimpleBool(frame, fGlobal, at))));
end;

{ tKlausSysProc_FileTempName }

constructor tKlausSysProc_FileTempName.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileTempName, aPoint);
  fGlobal := tKlausProcParam.create(self, 'общий', aPoint, kpmInput, source.simpleTypes[kdtBoolean]);
  addParam(fGlobal);
  fPrefix := tKlausProcParam.create(self, 'префикс', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fPrefix);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileTempName.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  td: string;
begin
  td := getTempDir(getSimpleBool(frame, fGlobal, at));
  returnSimple(frame, klausSimple(getTempFileName(td, getSimpleStr(frame, fPrefix, at))));
end;

{ tKlausSysProc_FileExpandName }

constructor tKlausSysProc_FileExpandName.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileExpandName, aPoint);
  fName := tKlausProcParam.create(self, 'путь', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileExpandName.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimple(expandFileName(getSimpleStr(frame, fName, at))));
end;

{ tKlausSysProc_FileExtractPath }

constructor tKlausSysProc_FileExtractPath.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileExtractPath, aPoint);
  fPath := tKlausProcParam.create(self, 'путь', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fPath);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileExtractPath.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  s: tKlausString;
begin
  s := extractFilePath(getSimpleStr(frame, fPath, at));
  returnSimple(frame, klausSimple(s));
end;

{ tKlausSysProc_FileExtractName }

constructor tKlausSysProc_FileExtractName.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileExtractName, aPoint);
  fPath := tKlausProcParam.create(self, 'путь', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fPath);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileExtractName.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  s: tKlausString;
begin
  s := getSimpleStr(frame, fPath, at);
  returnSimple(frame, klausSimple(extractFileName(s)));
end;

{ tKlausSysProc_FileExtractExt }

constructor tKlausSysProc_FileExtractExt.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileExtractExt, aPoint);
  fPath := tKlausProcParam.create(self, 'путь', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fPath);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileExtractExt.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  s: tKlausString;
begin
  s := getSimpleStr(frame, fPath, at);
  returnSimple(frame, klausSimple(extractFileExt(s)));
end;

{ tKlausSysProc_FileProgName }

constructor tKlausSysProc_FileProgName.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileProgName, aPoint);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileProgName.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  v: tKlausVariable;
begin
  v := frame.varByName(klausVarName_ExecFilename, at);
  returnSimple(frame, (v.value as tKlausVarValueSimple).simple);
end;

{ tKlausSysProc_FileHomeDir }

constructor tKlausSysProc_FileHomeDir.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileHomeDir, aPoint);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileHomeDir.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimple(getUserDir));
end;

{ tKlausSysProc_FileGetAttrs }

constructor tKlausSysProc_FileGetAttrs.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileGetAttrs, aPoint);
  fName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  declareRetValue(kdtInteger);
end;

procedure tKlausSysProc_FileGetAttrs.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  rslt: tKlausInteger;
begin
  rslt := fileGetAttr(getSimpleStr(frame, fName, at));
  if rslt = -1 then raise eInOutError.create(sysErrorMessage(getLastOsError));
  returnSimple(frame, klausSimple(rslt));
end;

{ tKlausSysProc_FileGetAge }

constructor tKlausSysProc_FileGetAge.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileGetAge, aPoint);
  fName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  declareRetValue(kdtMoment);
end;

procedure tKlausSysProc_FileGetAge.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  rslt: longInt;
begin
  rslt := fileAge(getSimpleStr(frame, fName, at));
  if rslt = -1 then raise eInOutError.create(sysErrorMessage(getLastOsError));
  returnSimple(frame, klausSimple(tKlausMoment(fileDateToDateTime(rslt))));
end;

{ tKlausSysProc_FileRename }

constructor tKlausSysProc_FileRename.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileRename, aPoint);
  fName := tKlausProcParam.create(self, 'откуда', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  fNewName := tKlausProcParam.create(self, 'куда', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fNewName);
end;

procedure tKlausSysProc_FileRename.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  rslt: boolean;
begin
  rslt := renameFile(getSimpleStr(frame, fName, at), getSimpleStr(frame, fNewName, at));
  if not rslt then raise eInOutError.create(sysErrorMessage(getLastOsError));
end;

{ tKlausSysProc_FileDelete }

constructor tKlausSysProc_FileDelete.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileDelete, aPoint);
  fName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
end;

procedure tKlausSysProc_FileDelete.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  rslt: boolean;
begin
  rslt := deleteFile(getSimpleStr(frame, fName, at));
  if not rslt then raise eInOutError.create(sysErrorMessage(getLastOsError));
end;

{ tKlausFileSearch }

destructor tKlausFileSearch.destroy;
begin
  findClose(searchRec);
  inherited destroy;
end;

{ tKlausSysProcFileFind }

procedure tKlausSysProcFileFind.fillInFileInfo(search: tKlausFileSearch; v: tKlausVarValueStruct; const at: tSrcPoint);
var
  mv: tKlausVarValueSimple;
begin
  mv := v.getMember('имя', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimple(search.searchRec.name), at);
  mv := v.getMember('размер', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimple(search.searchRec.size), at);
  mv := v.getMember('атрибуты', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimple(search.searchRec.attr), at);
  mv := v.getMember('возраст', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimple(tKlausMoment(fileDateToDateTime(search.searchRec.time))), at);
end;

{ tKlausSysProc_FileFindFirst }

constructor tKlausSysProc_FileFindFirst.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileFindFirst, aPoint);
  fMask := tKlausProcParam.create(self, 'шаблон', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fMask);
  fInfo := tKlausProcParam.create(self, 'инфо', aPoint, kpmOutput, findTypeDef(klausTypeName_FileInfo));
  addParam(fInfo);
  declareRetValue(kdtObject);
end;

procedure tKlausSysProc_FileFindFirst.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  path: string;
  rslt: tKlausObject = 0;
  search: tKlausFileSearch;
begin
  search := tKlausFileSearch.create;
  try
    path := getSimpleStr(frame, fMask, at);
    if findFirst(path, longInt($FFFFFFFF), search.searchRec) = 0 then begin
      rslt := frame.owner.objects.allocate(search, at);
      fillInFileInfo(search, frame.varByDecl(fInfo, at).value as tKlausVarValueStruct, at);
    end else
      freeAndNil(search);
    returnSimple(frame, klausSimpleObj(rslt));
  except
    freeAndNil(search);
    raise;
  end;
end;

{ tKlausSysProc_FileFindNext }

constructor tKlausSysProc_FileFindNext.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_FileFindNext, aPoint);
  fObj := tKlausProcParam.create(self, 'о', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fObj);
  fInfo := tKlausProcParam.create(self, 'инфо', aPoint, kpmOutput, findTypeDef(klausTypeName_FileInfo));
  addParam(fInfo);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_FileFindNext.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  rslt: tKlausBoolean;
  search: tKlausFileSearch;
begin
  search := getKlausObject(frame, getSimpleObj(frame, fObj, at), tKlausFileSearch, at) as tKlausFileSearch;
  rslt := findNext(search.searchRec) = 0;
  if rslt then fillInFileInfo(search, frame.varByDecl(fInfo, at).value as tKlausVarValueStruct, at);
  returnSimple(frame, klausSimple(rslt));
end;

{ tKlausSysProc_GrWindowOpen }

constructor tKlausSysProc_GrWindowOpen.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_GrWindowOpen, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrDestroy, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrSize, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrBeginPaint, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrEndPaint, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrPen, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrBrush, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrFont, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrCircle, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrEllipse, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrArc, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrSector, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrChord, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrLine, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrPolyLine, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrPolygon, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrRectangle, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrPoint, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrTextSize, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrText, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrClipRect, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrImgLoad, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrImgCreate, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrImgSave, aPoint);
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
  inherited create(aOwner, klausSysProcName_GrImgDraw, aPoint);
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

{ tKlausSysProc_EvtSubscribe }

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

constructor tKlausSysProc_EvtSubscribe.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_EvtSubscribe, aPoint);
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
  inherited create(aOwner, klausSysProcName_EvtExists, aPoint);
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
  returnSimple(frame, klausSimple(intf.eventExists));
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
  mv.setSimple(klausSimple(klausEventWhatCode[evt.what]), at);
  mv := v.getMember('код', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimple(tKlausInteger(evt.code)), at);
  for k := low(k) to high(k) do
    if k in evt.shift then ks := ks or klausKeyStateCode[k];
  mv := v.getMember('инфо', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimple(tKlausInteger(ks)), at);
  mv := v.getMember('г', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimple(tKlausInteger(evt.point.x)), at);
  mv := v.getMember('в', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimple(tKlausInteger(evt.point.y)), at);
end;

{ tKlausSysProc_EvtGet }

constructor tKlausSysProc_EvtGet.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_EvtGet, aPoint);
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
  inherited create(aOwner, klausSysProcName_EvtCount, aPoint);
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
  returnSimple(frame, klausSimple(tKlausInteger(intf.eventCount)));
end;

{ tKlausSysProc_EvtPeek }

constructor tKlausSysProc_EvtPeek.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausSysProcName_EvtPeek, aPoint);
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

