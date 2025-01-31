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

unit KlausDef;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, KlausLex, KlausErr;

type
  tKlausUnaryOperator = class;
  tKlausUnOpMinus = class;
  tKlausUnOpNot = class;
  tKlausBinaryOperator = class;
  tKlausBinOpPlus = class;
  tKlausBinOpMinus = class;
  tKlausBinOpConcat = class;
  tKlausBinOpMulti = class;
  tKlausBinOpFDiv = class;
  tKlausBinOpIDiv = class;
  tKlausBinOpMod = class;
  tKlausBinOpPwr = class;
  tKlausBinOpCompare = class;
  tKlausBinOpEq = class;
  tKlausBinOpNEq = class;
  tKlausBinOpLT = class;
  tKlausBinOpGT = class;
  tKlausBinOpLE = class;
  tKlausBinOpGE = class;
  tKlausBinOpAnd = class;
  tKlausBinOpOr = class;
  tKlausBinOpXor = class;

type
  // Тип данных
  tKlausDataType = (
    kdtComplex, kdtChar, kdtString, kdtInteger, kdtFloat, kdtMoment, kdtBoolean, kdtObject);

  // Простой тип данных
  tKlausSimpleType = succ(kdtComplex)..high(tKlausDataType);
  tKlausSimpleTypes = set of tKlausSimpleType;

const
  // Все простые типы данных
  klausSimpleTypes = [low(tKlausSimpleType)..high(tKlausSimpleType)];

  // Наименования простых типов данных
  klausDataTypeCaption: array[tKlausDataType] of string = (
    'составной', klausChar, klausString, klausInteger,
    klausFloat, klausMoment, klausBoolean, klausObject);

  // Множество ключевых слов, обозначающих простые типы данных
  klausSimpleTypeKwd = [
    kkwdChar, kkwdString, kkwdInteger, kkwdFloat, kkwdMoment, kkwdBoolean, kkwdObject];

  // Соответствие простых типов данных ключевым словам
  klausKwdToSimpleType: array[kkwdChar..kkwdObject] of tKlausSimpleType = (
    kdtChar, kdtString, kdtInteger, kdtFloat, kdtMoment, kdtBoolean, kdtObject);

  // Множество лексем для литералов простых типов данных
  klausSimpleTypeLexemes = [klxChar, klxString, klxInteger, klxFloat, klxMoment];

  // Соответствие типов данных типам лексем литералов
  klausSimpleTypeLiterals: array[klxChar..klxMoment] of tKlausSimpleType = (
    kdtChar, kdtString, kdtInteger, kdtFloat, kdtMoment);

type
  // Простое значение
  pKlausSimpleValue = ^tKlausSimpleValue;
  tKlausSimpleValue = record
    sValue: tKlausString; // было бы внутри case, но компилятор так не может
    case dataType: tKlausSimpleType of
      kdtChar: (cValue: tKlausChar);
      kdtInteger: (iValue: tKlausInteger);
      kdtFloat: (fValue: tKlausFloat);
      kdtMoment: (mValue: tKlausMoment);
      kdtBoolean: (bValue: tKlausBoolean);
      kdtObject: (oValue: tKlausObject);
  end;

type
  // Унарная операция
  tKlausUnaryOperation = (kuoInvalid, kuoMinus, kuoNot, kuoBitNot);
  tKlausValidUnaryOperation = succ(kuoInvalid)..high(tKlausUnaryOperation);
  tKlausUnOpSymbols = klsMinus..klsNot;
  tKlausUnOpKeywords = kkwdNot..kkwdNot;

const
  // Ключевые слова унарных операций
  klausKwdToUnOp: array[tKlausUnOpKeywords] of tKlausValidUnaryOperation = (kuoNot);
  // Символы унарных операций
  klausSymToUnOp: array[tKlausUnOpSymbols] of tKlausValidUnaryOperation = (kuoMinus, kuoBitNot);

const
  // Наименования унарных операций
  klausUnaryOperationName: array[tKlausUnaryOperation] of string = (
    'не определено', //kuoInvalid
    'минус',         //kuoMinus
    'отрицание',     //kuoNot
    'побитовое НЕ'   //kuoNot
  );

type
  // Бинарная операция
  // Тут нюанс. Во множестве знаков языка знаки унарных операций идут сразу после бинарных,
  // и поэтому знак "минус" можно включить в оба множества без потери порядка. Стало быть,
  // если добавляются знаки языка, которые могут служить и унарными операциями, и бинарными,
  // то их нужно добавлять именно в то место, где множество унарных операций пересекается
  // с множеством бинарных.
  tKlausBinaryOperation = (
    kboInvalid, kboPlus, kboConcat, kboMulti, kboFDiv, kboIDiv, kboMod, kboPwr, kboEq, kboNEq,
    kboLT, kboGT, kboLE, kboGE, kboAnd, kboOr, kboXor, kboBitAnd, kboBitOr, kboBitXor, kboMinus);
  tKlausValidBinaryOperation = succ(kboInvalid)..high(tKlausBinaryOperation);
  tKlausBinOpSymbols = klsPlus..klsMinus;
  tKlausBinOpKeywords = kkwdAnd..kkwdXor;

const
  // Ключевые слова бинарных операций
  klausKwdToBinOp: array[tKlausBinOpKeywords] of tKlausValidBinaryOperation = (
    kboAnd, kboOr, kboXor);
  // Символы бинарных операций
  klausSymToBinOp: array[tKlausBinOpSymbols] of tKlausValidBinaryOperation = (
    kboPlus, kboConcat, kboMulti, kboFDiv, kboIDiv, kboMod, kboPwr, kboEq, kboNEq,
    kboLT, kboGT, kboLE, kboGE, kboBitAnd, kboBitOr, kboBitXor, kboMinus);

const
  // Приоритет бинарных операций
  klausBinOpPriority: array[tKlausBinaryOperation] of integer = (
    -1,  //kboInvalid
    70,  //kboPlus
    40,  //kboConcat
    80,  //kboMulti
    80,  //kboFDiv
    80,  //kboIDiv
    80,  //kboMod
    90,  //kboPwr
    30,  //kboEq
    30,  //kboNEq
    30,  //kboLT
    30,  //kboGT
    30,  //kboLE
    30,  //kboGE
    20,  //kboAnd
    10,  //kboOr
    10,  //kboXor
    60,  //kboBitAnd
    50,  //kboBitOr
    50,  //kboBitXor
    70   //kboMinus
  );

const
  // Наименования бинарных операций
  klausBinaryOperationName: array[tKlausBinaryOperation] of string = (
    'не определено',         //kboInvalid
    'сложение',              //kboPlus
    'соединение',            //kboConcat
    'умножение',             //kboMulti
    'деление',               //kboFDiv
    'целочисленное деление', //kboIDiv
    'остаток от деления',    //kboMod
    'возведение в степень',  //kboPwr
    'равно',                 //kboEq
    'не равно',              //kboNEq
    'меньше',                //kboLT
    'больше',                //kboGT
    'меньше или равно',      //kboLE
    'больше или равно',      //kboGE
    'логическое И',          //kboAnd
    'логическое ИЛИ',        //kboOr
    'логическое ЛИБО',       //kboXor
    'побитовое И',           //kboBitAnd
    'побитовое ИЛИ',         //kboBitOr
    'побитовое ЛИБО',        //kboBitXor
    'вычитание'              //kboMinus
  );

const
  // Символы инструкций присваивания
  klausAssignSymbols = [klsAsgn..klsXorAsgn];

  // Операции, выполняемые инструкциями присваивания
  klausAsgnOp: array[klsAsgn..klsXorAsgn] of tKlausBinaryOperation = (
    kboInvalid, kboPlus, kboMinus, kboMulti, kboFDiv, kboIDiv, kboMod, kboPwr,
    kboBitAnd, kboBitOr, kboBitXor);

type
  // Базовый класс унарной операции
  tKlausUnaryOperator = class(tObject)
    protected
      function  getOp: tKlausUnaryOperation; virtual; abstract;
      function  getName: string; virtual;
    public
      property op: tKlausUnaryOperation read getOp;
      property name: string read getName;

      function  defined(dt: tKlausDataType): boolean; virtual;
      function  defined(const v: tKlausSimpleValue): boolean; virtual;
      procedure checkDefined(dt: tKlausDataType; const at: tSrcPoint);
      function  resultType(dt: tKlausDataType; const at: tSrcPoint): tKlausDataType; virtual; abstract;
      function  evaluate(const v: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; virtual; abstract;
  end;

type
  // Унарная операция "обратный знак"
  tKlausUnOpMinus = class(tKlausUnaryOperator)
    protected
      function getOp: tKlausUnaryOperation; override;
    public
      function defined(dt: tKlausDataType): boolean; override;
      function resultType(dt: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const v: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Унарная операция "логическое НЕ"
  tKlausUnOpNot = class(tKlausUnaryOperator)
    protected
      function getOp: tKlausUnaryOperation; override;
    public
      function defined(dt: tKlausDataType): boolean; override;
      function resultType(dt: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const v: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Унарная операция "побитовое НЕ"
  tKlausUnOpBitNot = class(tKlausUnaryOperator)
    protected
      function getOp: tKlausUnaryOperation; override;
    public
      function defined(dt: tKlausDataType): boolean; override;
      function resultType(dt: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const v: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Базовый класс бинарной операции
  tKlausBinaryOperator = class(tObject)
    protected
      function  getOp: tKlausBinaryOperation; virtual; abstract;
      function  getName: string; virtual;
    public
      property op: tKlausBinaryOperation read getOp;
      property name: string read getName;

      function  defined(dtl, dtr: tKlausDataType): boolean; virtual;
      function  defined(const vl, vr: tKlausSimpleValue): boolean; virtual;
      procedure checkDefined(dtl, dtr: tKlausDataType; const at: tSrcPoint);
      function  resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; virtual; abstract;
      function  evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; virtual; abstract;
  end;

type
  // Операция "сложение"
  tKlausBinOpPlus = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция "вычитание"
  tKlausBinOpMinus = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция "соединение символов/строк"
  tKlausBinOpConcat = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция "умножение"
  tKlausBinOpMulti = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция "вещественное деление"
  tKlausBinOpFDiv = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция "целочисленное деление"
  tKlausBinOpIDiv = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция "остаток от деления"
  tKlausBinOpMod = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция "возведение в степень"
  tKlausBinOpPwr = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Базовый класс операции сравнения
  tKlausBinOpCompare = class(tKlausBinaryOperator)
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
  end;

type
  // Операция "равно"
  tKlausBinOpEq = class(tKlausBinOpCompare)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция "не равно"
  tKlausBinOpNEq = class(tKlausBinOpCompare)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция "меньше"
  tKlausBinOpLT = class(tKlausBinOpCompare)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция "больше"
  tKlausBinOpGT = class(tKlausBinOpCompare)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция "меньше или равно"
  tKlausBinOpLE = class(tKlausBinOpCompare)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция "больше или равно"
  tKlausBinOpGE = class(tKlausBinOpCompare)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция логическое "И"
  tKlausBinOpAnd = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция логическое "ИЛИ"
  tKlausBinOpOr = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция логическое "исключающее ИЛИ"
  tKlausBinOpXor = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция побитовое "И"
  tKlausBinOpBitAnd = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция побитовое "ИЛИ"
  tKlausBinOpBitOr = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

type
  // Операция побитовое "исключающее ИЛИ"
  tKlausBinOpBitXor = class(tKlausBinaryOperator)
    protected
      function getOp: tKlausBinaryOperation; override;
    public
      function defined(dtl, dtr: tKlausDataType): boolean; override;
      function resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType; override;
      function evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue; override;
  end;

// Сравнивает приоритет бинарных операций
function klausBinOpPriorityCompare(op1, op2: tKlausBinaryOperation): integer;

// Возвращает "нулевое" (т.е., начальное) значение указанного типа
function klausZeroValue(dt: tKlausSimpleType): tKlausSimpleValue;

// Возвращает true, если переданное значение является "нулевым" (т.е., начальным)
function klausIsZeroValue(v: tKlausSimpleValue): boolean;

// Возвращает значение переданного литерала
function klausLiteralValue(const li: tKlausLexInfo): tKlausSimpleValue;

// Возвращает tKlausSimpleValue, заполненный переданными данными
function klausSimpleC(const c: tKlausChar): tKlausSimpleValue;
function klausSimpleS(const s: tKlausString): tKlausSimpleValue;
function klausSimpleI(const i: tKlausInteger): tKlausSimpleValue;
function klausSimpleF(const f: tKlausFloat): tKlausSimpleValue;
function klausSimpleM(const m: tKlausMoment): tKlausSimpleValue;
function klausSimpleB(const b: tKlausBoolean): tKlausSimpleValue;
function klausSimpleO(const o: tKlausObject): tKlausSimpleValue;

// Возвращает true, если тип src можно неявно привести к типу dt
function klausCanAssign(src, dt: tKlausDataType): boolean;

// Возвращает true, если тип src можно привести к типу dt
function klausCanTypecast(src, dt: tKlausDataType): boolean;

// Возвращает true, если значение можно привести к типу dt
function klausCanTypecast(const v: tKlausSimpleValue; dt: tKlausDataType): boolean;

// Приводит значение к указанному типу
function klausTypecast(const v: tKlausSimpleValue; dt: tKlausSimpleType; const at: tSrcPoint): tKlausSimpleValue;

// Возвращает true, если переданные типы данных сравнимы
function klausCanCompare(dt1, dt2: tKlausDataType): boolean;

// Возвращает true, если переданные простые значения сравнимы
function klausCanCompare(v1, v2: tKlausSimpleValue): boolean;

// Сравнивает простые значение
function klausCompare(v1, v2: tKlausSimpleValue; const at: tSrcPoint): integer;
function klausCompare(v1, v2: tKlausSimpleValue; accuracy: tKlausFloat; const at: tSrcPoint): integer;

// Возвращает значение, преобразованное к строке
// для отображения в отладочных окнах среды.
function klausDisplayValue(val: tKlausSimpleValue; long: boolean = false): string;

var
  // Экземпляры операторов для унарных операций
  klausUnOp: array[tKlausValidUnaryOperation] of tKlausUnaryOperator;

var
  // Экземпляры операторов для бинарных операций
  klausBinOp: array[tKlausValidBinaryOperation] of tKlausBinaryOperator;

implementation

uses Math, KlausUtils;

{ Globals }

// Сравнивает приоритет бинарных операций
function klausBinOpPriorityCompare(op1, op2: tKlausBinaryOperation): integer;
begin
  if klausBinOpPriority[op1] < klausBinOpPriority[op2] then result := -1
  else if klausBinOpPriority[op1] > klausBinOpPriority[op2] then result := 1
  else result := 0;
end;

// Возвращает "нулевое" (начальное) значение указанного типа
function klausZeroValue(dt: tKlausSimpleType): tKlausSimpleValue;
begin
  result.dataType := dt;
  result.sValue := '';
  case dt of
    kdtString:;
    kdtChar: result.cValue := 0;
    kdtInteger: result.iValue := 0;
    kdtFloat: result.fValue := 0;
    kdtMoment: result.mValue := 0;
    kdtBoolean: result.bValue := false;
    kdtObject: result.oValue := 0;
  else
    assert(false, 'Invalid data type');
  end;
end;

// Возвращает true, если переданное значение является "нулевым" (т.е., начальным)
function klausIsZeroValue(v: tKlausSimpleValue): boolean;
begin
  case v.dataType of
    kdtString: result := v.sValue = '';
    kdtChar: result := v.cValue = 0;
    kdtInteger: result := v.iValue = 0;
    kdtFloat: result := v.fValue = 0;
    kdtMoment: result := v.mValue = 0;
    kdtBoolean: result := v.bValue = false;
    kdtObject: result := v.oValue = 0;
  else
    result := false;
    assert(false, 'Invalid data type');
  end;
end;

// Возвращает значение переданного литерала
function klausLiteralValue(const li: tKlausLexInfo): tKlausSimpleValue;
begin
  if li.lexem = klxKeyword then begin
    case li.keyword of
      kkwdTrue: begin
        result.dataType := kdtBoolean;
        result.bValue := true;
      end;
      kkwdFalse: begin
        result.dataType := kdtBoolean;
        result.bValue := false;
      end;
      kkwdEmpty: begin
        result.dataType := kdtObject;
        result.oValue := 0;
      end;
      else raise eKlausError.create(ercInvalidLiteralValue, srcPoint(li));
    end;
  end else if li.lexem in klausSimpleTypeLexemes then begin
    result.dataType := klausSimpleTypeLiterals[li.lexem];
    case result.dataType of
      kdtChar: result.cValue := li.cValue;
      kdtString: result.sValue := li.sValue;
      kdtInteger: result.iValue := li.iValue;
      kdtFloat: result.fValue := li.fValue;
      kdtMoment: result.mValue := li.mValue;
    else
      assert(false, 'Invalid data type');
    end;
  end else
    raise eKlausError.create(ercInvalidLiteralValue, srcPoint(li));
end;

// Возвращает tKlausSimpleValue, заполненный переданными данными
function klausSimpleC(const c: tKlausChar): tKlausSimpleValue;
begin
  result.dataType := kdtChar;
  result.cValue := c;
end;

// Возвращает tKlausSimpleValue, заполненный переданными данными
function klausSimpleS(const s: tKlausString): tKlausSimpleValue;
begin
  result.dataType := kdtString;
  result.sValue := s;
end;

// Возвращает tKlausSimpleValue, заполненный переданными данными
function klausSimpleI(const i: tKlausInteger): tKlausSimpleValue;
begin
  result.dataType := kdtInteger;
  result.iValue := i;
end;

// Возвращает tKlausSimpleValue, заполненный переданными данными
function klausSimpleF(const f: tKlausFloat): tKlausSimpleValue;
begin
  result.dataType := kdtFloat;
  result.fValue := f;
end;

// Возвращает tKlausSimpleValue, заполненный переданными данными
function klausSimpleM(const m: tKlausMoment): tKlausSimpleValue;
begin
  result.dataType := kdtMoment;
  result.mValue := m;
end;

// Возвращает tKlausSimpleValue, заполненный переданными данными
function klausSimpleB(const b: tKlausBoolean): tKlausSimpleValue;
begin
  result.dataType := kdtBoolean;
  result.bValue := b;
end;

// Возвращает tKlausSimpleValue, заполненный переданными данными
function klausSimpleO(const o: tKlausObject): tKlausSimpleValue;
begin
  result.dataType := kdtObject;
  result.oValue := o;
end;

// Возвращает true, если тип src можно неявно привести к типу dt
function klausCanAssign(src, dt: tKlausDataType): boolean;
begin
  if (src = kdtComplex) or (dt = kdtComplex) then exit(false);
  if src = dt then exit(true);
  case dt of
    kdtChar: result := src = kdtChar;
    kdtString: result := src in [kdtChar, kdtString];
    kdtInteger: result := src = kdtInteger;
    kdtFloat: result := src in [kdtInteger, kdtFloat];
    kdtMoment: result := src = kdtMoment;
    kdtBoolean: result := src = kdtBoolean;
    kdtObject: result := src = kdtObject;
  else
    result := false;
    assert(false, 'Invalid data type');
  end;
end;

// Возвращает true, если тип src можно привести к типу dt
function klausCanTypecast(src, dt: tKlausDataType): boolean;
begin
  if (src = kdtComplex) or (dt = kdtComplex) then exit(false);
  if src = dt then exit(true);
  case dt of
    kdtChar: result := src = kdtInteger;
    kdtString: result := src in [kdtChar, kdtInteger, kdtFloat, kdtMoment, kdtBoolean, kdtObject];
    kdtInteger: result := src in [kdtChar, kdtString, kdtFloat, kdtMoment, kdtBoolean, kdtObject];
    kdtFloat: result := src in [kdtString, kdtInteger, kdtMoment];
    kdtMoment: result := src in [kdtString, kdtInteger, kdtFloat];
    kdtBoolean: result := src in [kdtString, kdtInteger];
    kdtObject: result := false;
  else
    result := false;
    assert(false, 'Invalid data type');
  end;
end;

// Возвращает true, если значение можно привести к типу dt
function klausCanTypecast(const v: tKlausSimpleValue; dt: tKlausDataType): boolean;
begin
  result := klausCanTypecast(v.dataType, dt);
end;

// Приводит значение к указанному типу
function klausTypecast(const v: tKlausSimpleValue; dt: tKlausSimpleType; const at: tSrcPoint): tKlausSimpleValue;
const
  bv: array[boolean] of string = (klausFalse, klausTrue);
begin
  if v.dataType = dt then exit(v);
  if not klausCanTypecast(v, dt) then raise eKlausError.create(ercInvalidTypecast, at);
  result.dataType := dt;
  case dt of
    kdtChar: result.cValue := tKlausChar(v.iValue);
    kdtString: case v.dataType of
      kdtChar: result.sValue := klausCharToStr(v.cValue);
      kdtInteger: result.sValue := klausIntToStr(v.iValue);
      kdtFloat: result.sValue := klausFloatToStr(v.fValue);
      kdtMoment: result.sValue := klausMomentToStr(v.mValue);
      kdtBoolean: result.sValue := bv[v.bValue];
      kdtObject: result.sValue := intToHex(v.oValue, sizeOf(tKlausObject)*2);
    end;
    kdtInteger: case v.dataType of
      kdtChar: result.iValue := tKlausInteger(v.cValue);
      kdtString: result.iValue := klausStrToInt(v.sValue);
      kdtFloat: begin
        if isNaN(v.fValue) or isInfinite(v.fValue) then raise eKlausError.create(ercArgumentIsNotFinite, at);
        result.iValue := trunc(v.fValue);
      end;
      kdtMoment: begin
        if isNaN(v.mValue) or isInfinite(v.mValue) then raise eKlausError.create(ercArgumentIsNotFinite, at);
        result.iValue := trunc(v.mValue);
      end;
      kdtBoolean: if v.bValue then result.iValue := 1 else result.iValue := 0;
      kdtObject: result.iValue := tKlausInteger(v.oValue);
    end;
    kdtFloat: case v.dataType of
      kdtString: result.fValue := klausStrToFloat(v.sValue);
      kdtInteger: result.fValue := v.iValue;
      kdtMoment: result.fValue := v.mValue;
    end;
    kdtMoment: case v.dataType of
      kdtString: result.mValue := klausStrToMoment(v.sValue);
      kdtInteger: result.mValue := v.iValue;
      kdtFloat: result.mValue := v.fValue;
    end;
    kdtBoolean: case v.dataType of
      kdtString: result.bValue := klausStrToBool(v.sValue);
      kdtInteger: result.bValue := v.iValue <> 0;
    end;
    kdtObject: raise eKlausError.create(ercInvalidTypecast, at);
  end;
end;

// Возвращает true, если переданные простые значения сравнимы
function klausCanCompare(v1, v2: tKlausSimpleValue): boolean;
begin
  result := klausCanCompare(v1.dataType, v2.dataType);
end;

// Возвращает true, если переданные простые типы сравнимы
function klausCanCompare(dt1, dt2: tKlausDataType): boolean;
begin
  if (dt1 = kdtComplex) or (dt2 = kdtComplex) then exit(false);
  case dt1 of
    kdtChar: result := dt2 = kdtChar;
    kdtString: result := dt2 = kdtString;
    kdtInteger: result := dt2 in [kdtInteger, kdtFloat];
    kdtFloat: result := dt2 in [kdtInteger, kdtFloat];
    kdtMoment: result := dt2 = kdtMoment;
    kdtBoolean: result := dt2 = kdtBoolean;
    kdtObject: result := dt2 = kdtObject;
  else
    result := false;
    assert(false, 'Invalid data type.');
  end;
end;

function klausCompare(v1, v2: tKlausSimpleValue; const at: tSrcPoint): integer;
begin
  result := klausCompare(v1, v2, 0, at);
end;

// Сравнивает простые значение
function klausCompare(v1, v2: tKlausSimpleValue; accuracy: tKlausFloat; const at: tSrcPoint): integer;
begin
  result := 0;
  if not klausCanCompare(v1.dataType, v2.dataType) then
    raise eKlausError.createFmt(ercBinOperNotDefined, at, ['сравнение', klausDataTypeCaption[v1.dataType], klausDataTypeCaption[v2.dataType]]);
  case v1.dataType of
    kdtChar: result := klausCmp(v1.cValue, v2.cValue);
    kdtString: result := klausCmp(v1.sValue, v2.sValue);
    kdtInteger: begin
      if v2.dataType = kdtInteger then
        result := klausCmp(v1.iValue, v2.iValue)
      else begin
        if isNaN(v2.fValue) then raise eKlausError.create(ercArgumentIsNaN, at);
        result := klausCmp(v1.iValue, v2.fValue, accuracy);
      end;
    end;
    kdtFloat: begin
      if isNaN(v1.fValue) then raise eKlausError.create(ercArgumentIsNaN, at);
      if v2.dataType = kdtInteger then
        result := klausCmp(v1.fValue, v2.iValue, accuracy)
      else begin
        if isNaN(v2.fValue) then raise eKlausError.create(ercArgumentIsNaN, at);
        result := klausCmp(v1.fValue, v2.fValue, accuracy);
      end;
    end;
    kdtMoment: begin
      if isNaN(v1.mValue) or isNaN(v2.mValue) then raise eKlausError.create(ercArgumentIsNaN, at);
      result := klausCmp(v1.mValue, v2.mValue, accuracy);
    end;
    kdtBoolean: result := klausCmp(v1.bValue, v2.bValue);
    kdtObject: result := klausCmp(v1.oValue, v2.oValue);
  else
    assert(false, 'Invalid data type');
  end;
end;

// Возвращает значение, преобразованное к строке
// для отображения в отладочных окнах среды.
function klausDisplayValue(val: tKlausSimpleValue; long: boolean = false): string;
begin
  try
    result := klausTypecast(val, kdtString, zeroSrcPt).sValue;
    if val.dataType = kdtString then result := klausStringLiteral(result)
    else if val.dataType = kdtMoment then result := '`'+result+'`';
  except
    on e: exception do result := e.className + ': ' + e.message;
  end;
end;

{ tKlausUnOpMinus }

function tKlausUnOpMinus.getOp: tKlausUnaryOperation;
begin
  result := kuoMinus;
end;

function tKlausUnOpMinus.defined(dt: tKlausDataType): boolean;
begin
  result := dt in [kdtInteger, kdtFloat, kdtMoment];
end;

function tKlausUnOpMinus.resultType(dt: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dt, at);
  result := dt;
end;

function tKlausUnOpMinus.evaluate(const v: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(v.dataType, at);
  case result.dataType of
    kdtInteger: result.iValue := -v.iValue;
    kdtFloat: result.fValue := -v.fValue;
    kdtMoment: result.mValue := -v.mValue;
  end;
end;

{ tKlausUnOpNot }

function tKlausUnOpNot.getOp: tKlausUnaryOperation;
begin
  result := kuoNot;
end;

function tKlausUnOpNot.defined(dt: tKlausDataType): boolean;
begin
  result := dt = kdtBoolean;
end;

function tKlausUnOpNot.resultType(dt: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dt, at);
  result := dt;
end;

function tKlausUnOpNot.evaluate(const v: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(v.dataType, at);
  result.bValue := not v.bValue;
end;

{ tKlausUnOpBitNot }

function tKlausUnOpBitNot.getOp: tKlausUnaryOperation;
begin
  result := kuoBitNot;
end;

function tKlausUnOpBitNot.defined(dt: tKlausDataType): boolean;
begin
  result := dt = kdtInteger;
end;

function tKlausUnOpBitNot.resultType(dt: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dt, at);
  result := dt;
end;

function tKlausUnOpBitNot.evaluate(const v: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(v.dataType, at);
  result.iValue := not v.iValue;
end;

{ tKlausUnaryOperator }

function tKlausUnaryOperator.getName: string;
begin
  result := klausUnaryOperationName[op];
end;

procedure tKlausUnaryOperator.checkDefined(dt: tKlausDataType; const at: tSrcPoint);
begin
  if not defined(dt) then
    raise eKlausError.createFmt(ercUnOperNotDefined, at, [name, klausDataTypeCaption[dt]]);
end;

function tKlausUnaryOperator.defined(dt: tKlausDataType): boolean;
begin
  result := false;
end;

function tKlausUnaryOperator.defined(const v: tKlausSimpleValue): boolean;
begin
  result := defined(v.dataType);
end;

{ tKlausBinaryOperator }

function tKlausBinaryOperator.getName: string;
begin
  result := klausBinaryOperationName[op];
end;

procedure tKlausBinaryOperator.checkDefined(dtl, dtr: tKlausDataType; const at: tSrcPoint);
begin
  if not defined(dtl, dtr) then
    raise eKlausError.createFmt(ercBinOperNotDefined, at, [name, klausDataTypeCaption[dtl], klausDataTypeCaption[dtr]]);
end;

function tKlausBinaryOperator.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := false;
end;

function tKlausBinaryOperator.defined(const vl, vr: tKlausSimpleValue): boolean;
begin
  result := defined(vl.dataType, vr.dataType);
end;

{ tKlausBinOpPlus }

function tKlausBinOpPlus.getOp: tKlausBinaryOperation;
begin
  result := kboPlus;
end;

function tKlausBinOpPlus.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl in [kdtInteger, kdtFloat, kdtMoment]) and (dtr in [kdtInteger, kdtFloat, kdtMoment]);
end;

function tKlausBinOpPlus.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  if (dtl = kdtMoment) or (dtr = kdtMoment) then result := kdtMoment
  else if (dtl = kdtInteger) and (dtr = kdtInteger) then result := kdtInteger
  else result := kdtFloat;
end;

function tKlausBinOpPlus.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  case result.dataType of
    kdtInteger: result.iValue := vl.iValue + vr.iValue;
    kdtFloat: result.fValue := klausTypecast(vl, kdtFloat, at).fValue + klausTypecast(vr, kdtFloat, at).fValue;
    kdtMoment: result.mValue := klausTypecast(vl, kdtMoment, at).mValue + klausTypecast(vr, kdtMoment, at).mValue;
  end;
end;

{ tKlausBinOpMinus }

function tKlausBinOpMinus.getOp: tKlausBinaryOperation;
begin
  result := kboMinus;
end;

function tKlausBinOpMinus.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result :=
    ((dtl = kdtMoment) and (dtr = kdtMoment))
    or ((dtl in [kdtInteger, kdtFloat, kdtMoment]) and (dtr in [kdtInteger, kdtFloat]));
end;

function tKlausBinOpMinus.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  if (dtl = kdtMoment) or (dtr = kdtMoment) then result := kdtMoment
  else if (dtl = kdtInteger) and (dtr = kdtInteger) then result := kdtInteger
  else result := kdtFloat;
end;

function tKlausBinOpMinus.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  case result.dataType of
    kdtInteger: result.iValue := vl.iValue - vr.iValue;
    kdtFloat: result.fValue := klausTypecast(vl, kdtFloat, at).fValue - klausTypecast(vr, kdtFloat, at).fValue;
    kdtMoment: result.mValue := klausTypecast(vl, kdtMoment, at).mValue - klausTypecast(vr, kdtMoment, at).mValue;
  end;
end;

{ tKlausBinOpConcat }

function tKlausBinOpConcat.getOp: tKlausBinaryOperation;
begin
  result := kboConcat;
end;

function tKlausBinOpConcat.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl in [kdtChar, kdtString]) and (dtr in [kdtChar, kdtString]);
end;

function tKlausBinOpConcat.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  result := kdtString;
end;

function tKlausBinOpConcat.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.sValue := klausTypecast(vl, kdtString, at).sValue + klausTypecast(vr, kdtString, at).sValue;
end;

{ tKlausBinOpMulti }

function tKlausBinOpMulti.getOp: tKlausBinaryOperation;
begin
  result := kboMulti;
end;

function tKlausBinOpMulti.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl in [kdtInteger, kdtFloat]) and (dtr in [kdtInteger, kdtFloat]);
end;

function tKlausBinOpMulti.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  if (dtl = kdtInteger) and (dtr = kdtInteger) then result := kdtInteger
  else result := kdtFloat;
end;

function tKlausBinOpMulti.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  if result.dataType = kdtInteger then result.iValue := vl.iValue * vr.iValue
  else result.fValue := klausTypecast(vl, kdtFloat, at).fValue * klausTypecast(vr, kdtFloat, at).fValue;
end;

{ tKlausBinOpFDiv }

function tKlausBinOpFDiv.getOp: tKlausBinaryOperation;
begin
  result := kboFDiv;
end;

function tKlausBinOpFDiv.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl in [kdtInteger, kdtFloat]) and (dtr in [kdtInteger, kdtFloat]);
end;

function tKlausBinOpFDiv.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  result := kdtFloat;
end;

function tKlausBinOpFDiv.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.fValue := klausTypecast(vl, kdtFloat, at).fValue / klausTypecast(vr, kdtFloat, at).fValue;
end;

{ tKlausBinOpIDiv }

function tKlausBinOpIDiv.getOp: tKlausBinaryOperation;
begin
  result := kboIDiv;
end;

function tKlausBinOpIDiv.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl = kdtInteger) and (dtr = kdtInteger);
end;

function tKlausBinOpIDiv.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  result := kdtInteger;
end;

function tKlausBinOpIDiv.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.iValue := vl.iValue div vr.iValue;
end;

{ tKlausBinOpMod }

function tKlausBinOpMod.getOp: tKlausBinaryOperation;
begin
  result := kboMod;
end;

function tKlausBinOpMod.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl = kdtInteger) and (dtr = kdtInteger);
end;

function tKlausBinOpMod.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  result := kdtInteger;
end;

function tKlausBinOpMod.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.iValue := vl.iValue mod vr.iValue;
end;

{ tKlausBinOpPwr }

function tKlausBinOpPwr.getOp: tKlausBinaryOperation;
begin
  result := kboPwr;
end;

function tKlausBinOpPwr.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl in [kdtInteger, kdtFloat]) and (dtr in [kdtInteger, kdtFloat]);
end;

function tKlausBinOpPwr.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  if (dtl = kdtInteger) and (dtr = kdtInteger) then result := kdtInteger
  else result := kdtFloat;
end;

function tKlausBinOpPwr.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  if result.dataType = kdtInteger then result.iValue := vl.iValue ** vr.iValue
  else result.fValue := klausTypecast(vl, kdtFloat, at).fValue ** klausTypecast(vr, kdtFloat, at).fValue;
end;

{ tKlausBinOpCompare }

function tKlausBinOpCompare.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := klausCanCompare(dtl, dtr);
end;

function tKlausBinOpCompare.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtr, dtl, at);
  result := kdtBoolean;
end;

{ tKlausBinOpEq }

function tKlausBinOpEq.getOp: tKlausBinaryOperation;
begin
  result := kboEq;
end;

function tKlausBinOpEq.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.bValue := klausCompare(vl, vr, at) = 0;
end;

{ tKlausBinOpNEq }

function tKlausBinOpNEq.getOp: tKlausBinaryOperation;
begin
  result := kboNEq;
end;

function tKlausBinOpNEq.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.bValue := klausCompare(vl, vr, at) <> 0;
end;

{ tKlausBinOpLT }

function tKlausBinOpLT.getOp: tKlausBinaryOperation;
begin
  result := kboLT;
end;

function tKlausBinOpLT.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.bValue := klausCompare(vl, vr, at) < 0;
end;

{ tKlausBinOpGT }

function tKlausBinOpGT.getOp: tKlausBinaryOperation;
begin
  result := kboGT;
end;

function tKlausBinOpGT.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.bValue := klausCompare(vl, vr, at) > 0;
end;

{ tKlausBinOpLE }

function tKlausBinOpLE.getOp: tKlausBinaryOperation;
begin
  result := kboLE;
end;

function tKlausBinOpLE.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.bValue := klausCompare(vl, vr, at) <= 0;
end;

{ tKlausBinOpGE }

function tKlausBinOpGE.getOp: tKlausBinaryOperation;
begin
  result := kboGE;
end;

function tKlausBinOpGE.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.bValue := klausCompare(vl, vr, at) >= 0;
end;

{ tKlausBinOpAnd }

function tKlausBinOpAnd.getOp: tKlausBinaryOperation;
begin
  result := kboAnd;
end;

function tKlausBinOpAnd.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl = kdtBoolean) and (dtr = kdtBoolean);
end;

function tKlausBinOpAnd.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  result := kdtBoolean;
end;

function tKlausBinOpAnd.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.bValue := vl.bValue and vr.bValue;
end;

{ tKlausBinOpOr }

function tKlausBinOpOr.getOp: tKlausBinaryOperation;
begin
  result := kboOr;
end;

function tKlausBinOpOr.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl = kdtBoolean) and (dtr = kdtBoolean);
end;

function tKlausBinOpOr.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  result := kdtBoolean;
end;

function tKlausBinOpOr.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.bValue := vl.bValue or vr.bValue;
end;

{ tKlausBinOpXor }

function tKlausBinOpXor.getOp: tKlausBinaryOperation;
begin
  result := kboXor;
end;

function tKlausBinOpXor.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl = kdtBoolean) and (dtr = kdtBoolean);
end;

function tKlausBinOpXor.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  result := kdtBoolean;
end;

function tKlausBinOpXor.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.bValue := vl.bValue xor vr.bValue;
end;

{ tKlausBinOpBitAnd }

function tKlausBinOpBitAnd.getOp: tKlausBinaryOperation;
begin
  result := kboBitAnd;
end;

function tKlausBinOpBitAnd.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl = kdtInteger) and (dtr = kdtInteger);
end;

function tKlausBinOpBitAnd.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  result := kdtInteger;
end;

function tKlausBinOpBitAnd.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.iValue := vl.iValue and vr.iValue;
end;

{ tKlausBinOpBitOr }

function tKlausBinOpBitOr.getOp: tKlausBinaryOperation;
begin
  result := kboBitOr;
end;

function tKlausBinOpBitOr.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl = kdtInteger) and (dtr = kdtInteger);
end;

function tKlausBinOpBitOr.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  result := kdtInteger;
end;

function tKlausBinOpBitOr.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.iValue := vl.iValue or vr.iValue;
end;

{ tKlausBinOpBitXor }

function tKlausBinOpBitXor.getOp: tKlausBinaryOperation;
begin
  result := kboBitXor;
end;

function tKlausBinOpBitXor.defined(dtl, dtr: tKlausDataType): boolean;
begin
  result := (dtl = kdtInteger) and (dtr = kdtInteger);
end;

function tKlausBinOpBitXor.resultType(dtl, dtr: tKlausDataType; const at: tSrcPoint): tKlausDataType;
begin
  checkDefined(dtl, dtr, at);
  result := kdtInteger;
end;

function tKlausBinOpBitXor.evaluate(const vl, vr: tKlausSimpleValue; const at: tSrcPoint): tKlausSimpleValue;
begin
  result.dataType := resultType(vl.dataType, vr.dataType, at);
  result.iValue := vl.iValue xor vr.iValue;
end;

{ initialization }

var
  uop: tKlausValidUnaryOperation;
  bop: tKlausValidBinaryOperation;
initialization
  setExceptionMask([
    exInvalidOp, exDenormalized, exZeroDivide,
    exOverflow, exUnderflow, exPrecision]);
  // Унарные операторы
  klausUnOp[kuoMinus] := tKlausUnOpMinus.create;
  klausUnOp[kuoNot] := tKlausUnOpNot.create;
  klausUnOp[kuoBitNot] := tKlausUnOpBitNot.create;
  // Бинарные операторы
  klausBinOp[kboPlus] := tKlausBinOpPlus.create;
  klausBinOp[kboConcat] := tKlausBinOpConcat.create;
  klausBinOp[kboMulti] := tKlausBinOpMulti.create;
  klausBinOp[kboFDiv] := tKlausBinOpFDiv.create;
  klausBinOp[kboIDiv] := tKlausBinOpIDiv.create;
  klausBinOp[kboMod] := tKlausBinOpMod.create;
  klausBinOp[kboPwr] := tKlausBinOpPwr.create;
  klausBinOp[kboEq] := tKlausBinOpEq.create;
  klausBinOp[kboNEq] := tKlausBinOpNEq.create;
  klausBinOp[kboLT] := tKlausBinOpLT.create;
  klausBinOp[kboGT] := tKlausBinOpGT.create;
  klausBinOp[kboLE] := tKlausBinOpLE.create;
  klausBinOp[kboGE] := tKlausBinOpGE.create;
  klausBinOp[kboAnd] := tKlausBinOpAnd.create;
  klausBinOp[kboOr] := tKlausBinOpOr.create;
  klausBinOp[kboXor] := tKlausBinOpXor.create;
  klausBinOp[kboBitAnd] := tKlausBinOpBitAnd.create;
  klausBinOp[kboBitOr] := tKlausBinOpBitOr.create;
  klausBinOp[kboBitXor] := tKlausBinOpBitXor.create;
  klausBinOp[kboMinus] := tKlausBinOpMinus.create;
finalization
  for uop := low(uop) to high(uop) do freeAndNil(klausUnOp[uop]);
  for bop := low(bop) to high(bop) do freeAndNil(klausBinOp[bop]);
end.

