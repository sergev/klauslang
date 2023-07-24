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

unit KlausLex;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, Math, U8;

type
  // Простые типы данных
  tKlausChar    = type longWord;    // кодпойнт Юникод
  tKlausString  = type string;      // строка UTF-8
  tKlausInteger = type int64;       // 64-разрядное целое
  tKlausFloat   = type double;      // 64-разрядное вещественное
  tKlausMoment  = type tKlausFloat; // дата/время
  tKlausBoolean = type boolean;     // логическое
  tKlausObject  = type longInt;     // объект

const
  klausMinFloat = tKlausFloat(minDouble);
  klausMaxFloat = tKlausFloat(maxDouble);

type
  // Лексема языка Клаус
  // Префикс 'klx' менять нельзя -- всё развалится :)
  {$push}{$packenum 1}
  tKlausLexem = (
    klxEOF       =  0, // конец потока
    klxInvalid   =  1, // недопустимый символ
    klxKeyword   =  2, // ключевое слово
    klxID        =  3, // идентификатор
    klxChar      =  4, // символьный литерал (апострофы или №)
    klxString    =  5, // строковый литерал (кавычки)
    klxInteger   =  6, // целочисленный литерал
    klxFloat     =  7, // вещественный литерал
    klxMoment    =  8, // литерал даты/времени (обратные апострофы)
    klxSymbol    =  9, // знак
    klxSLComment = 10, // однострочный комментарий
    klxMLComment = 11  // многострочный комментарий
  );
  {$pop}

type
  // Допустимый тип лексемы
  tKlausValidLexem = succ(klxInvalid)..high(tKlausLexem);
  tKlausValidLexemes = set of tKlausValidLexem;

const
  // Типы лексем, игнорируемые в исходном коде
  klausLexemIgnore = [klxSLComment, klxMLComment];

const
  // Наименования типов  лексем
  klausLexemCaption: array[tKlausLexem] of string = (
    'конец потока',
    'неверный символ',
    'ключевое слово',
    'идентификатор',
    'символьный литерал',
    'строковый литерал',
    'целочисленный литерал',
    'вещественный литерал',
    'литерал момента',
    'знак языка',
    'однострочный комментарий',
    'многострочный комментарий'
  );

const
  // Эти константы используются в качестве ключевых слов, а также для
  // преобразования булевских значений к строке. Нижний регистр обязателен.
  klausTrue = 'да';
  klausFalse = 'нет';

const
  // Эти константы используются в качестве ключевых слов, а также для
  // преобразования простых типов данных к строке. Нижний регистр обязателен.
  klausChar = 'символ';
  klausString = 'строка';
  klausInteger = 'целое';
  klausFloat = 'дробное';
  klausMoment = 'момент';
  klausBoolean = 'логическое';
  klausObject = 'объект';

type
  // Ключевые слова языка
  tKlausKeyword = (
    kkwdInvalid,
    kkwdProgram,
    kkwdUses,
    kkwdBegin,
    kkwdEnd,
    kkwdVar,
    kkwdConst,
    kkwdType,
    kkwdChar,
    kkwdString,
    kkwdInteger,
    kkwdFloat,
    kkwdMoment,
    kkwdBoolean,
    kkwdObject,
    kkwdTrue,
    kkwdFalse,
    kkwdArray,
    kkwdDict,
    kkwdStruct,
    kkwdKey,
    kkwdProcedure,
    kkwdFunction,
    kkwdNothing,
    kkwdBreak,
    kkwdContinue,
    kkwdReturn,
    kkwdIf,
    kkwdThen,
    kkwdElse,
    kkwdFor,
    kkwdFrom,
    kkwdReverse,
    kkwdTo,
    kkwdLoop,
    kkwdWhile,
    kkwdCase,
    kkwdOf,
    kkwdException,
    kkwdRaise,
    kkwdThrow,
    kkwdAny,
    kkwdMessage,
    kkwdHalt,
    kkwdExceptWhen,
    kkwdExceptThen,
    kkwdFinally,
    kkwdInput,
    kkwdOutput,
    kkwdInOut,
    kkwdEach,
    kkwdExists,
    kkwdNotExists,
    kkwdEmpty
  );

type
 // Допустимые ключевые слова языка
  tKlausValidKeyword = succ(kkwdInvalid)..high(tKlausKeyword);
  tKlausValidKeywords = set of tKlausValidKeyword;

type
  // Знаки языка
  tKlausSymbol = (
    klsInvalid,   // не знак
    klsPlus,      // сложение
    klsConcat,    // соединение строк
    klsMulti,     // умножение
    klsFDiv,      // вещественное деление
    klsIDiv,      // целочисленное деление
    klsMod,       // остаток от целочисленного деления
    klsPwr,       // возведение в степень
    klsEq,        // равняется
    klsNEq,       // не равняется
    klsLT,        // меньше
    klsGT,        // больше
    klsLE,        // меньше или равно
    klsGE,        // больше или равно
    klsAnd,       // логическое "и"
    klsOr,        // логическое "или"
    klsXor,       // логическое "исключающее или"
    klsMinus,     // унарный минус, вычитание
    klsNot,       // логическое отрицание
    klsAsgn,      // присвоить
    klsAddAsgn,   // прибавить и присвоить
    klsSubAsgn,   // вычесть и присвоить
    klsMulAsgn,   // умножить и присвоить
    klsFDivAsgn,  // разделить (вещественное деление) и присвоить
    klsIDivAsgn,  // разделить (целочисленное деление) и присвоить
    klsModAsgn,   // присвоить остаток от целочисленного деления
    klsPwrAsgn,   // возвести в степень и присвоить
    klsComma,     // разделитель списка имён
    klsDot,       // обращение к полю структуры, конец программы
    klsColon,     // квалификатор определения
    klsSemicolon, // разделитель инструкций, полей структуры, параметров
    klsParOpen,   // группировка в выражениях, параметры процедур/функций
    klsParClose,  // группировка в выражениях, параметры процедур/функций
    klsBktOpen,   // обращение к элементу массива или словаря
    klsBktClose   // обращение к элементу массива или словаря
  );

type
  // Допустимые знаки языка
  tKlausValidSymbol = succ(klsInvalid)..high(tKlausSymbol);
  tKlausValidSymbols = set of tKlausValidSymbol;

type
  // Лексема
  pKlausLexInfo = ^tKlausLexInfo;
  tKlausLexInfo = record
    lexem: tKlausLexem;     // тип лексической единицы
    keyword: tKlausKeyword; // тип ключевого слова для klutKeyword
    symbol: tKlausSymbol;   // тип знака для klutSymbol
    text: string;           // оригинальный текст
    cValue: tKlausChar;     // значение (определено для klxChar)
    sValue: tKlausString;   // значение (определено для klxString)
    iValue: tKlausInteger;  // значение (определено для klxInteger)
    fValue: tKlausFloat;    // значение (определено для klxFloat)
    mValue: tKlausMoment;   // значение (определено для klxMoment)
    line: integer;          // номер строки в исходном тексте (нач. с 1)
    pos: integer;           // позиция в символах относительно начала строки (нач. с 1)
    absPos: integer;        // позиция в байтах относительно начала потока (нач. с 0)
  end;

const
  // Лексема "конец файла"
  klliEOF: tKlausLexInfo = (
    lexem: klxEOF;
    keyword: kkwdInvalid;
    symbol: klsInvalid;
    text: '';
    cValue: 0;
    sValue: '';
    iValue: 0;
    fValue: 0;
    mValue: 0;
    line: 0;
    pos: 0;
    absPos: 0);

const
  // Лексема "недопустимый символ"
  klliError: tKlausLexInfo = (
    lexem: klxInvalid;
    keyword: kkwdInvalid;
    symbol: klsInvalid;
    text: '';
    cValue: 0;
    sValue: '';
    iValue: 0;
    fValue: 0;
    mValue: 0;
    line: 0;
    pos: 0;
    absPos: 0);

type
  tStringReadStream = class(tCustomMemoryStream)
    private
      fData: string;
      fOnReset: tNotifyEvent;
    protected
      procedure setData(value: string); virtual;
    public
      property data: string read fData write setData;
      property onReset: tNotifyEvent read fOnReset write fOnReset;

      constructor create(const s: string);
  end;

type
  // Базовый класс лексического парсера с полной поддержкой UTF8
  tCustomLexParser = class(tObject)
    private
      fStream: tStream;
      fBOF: boolean;
      fEOF: boolean;
      fEOLN: boolean;
      fLine: integer;
      fPos: integer;
      fAbsPos: integer;
      fPrevAbsPos: integer;
      fPrevLineLength: integer;
      fFeedBackTwice: boolean;
      fOwnsStream: boolean;
      fRaiseErrors: boolean;
    protected
      property BOF: boolean read fBOF;
      property EOF: boolean read fEOF;
      property EOLN: boolean read fEOLN;
      property line: integer read fLine;
      property pos: integer read fPos;
      property absPos: integer read fAbsPos;

      procedure setStream(aStream: tStream); virtual;
      procedure streamReset(sender: tObject); virtual;
      function  nextChar: u8Char;
      procedure feedBack;
      function  tryNextChar: u8Char;
    public
      property stream: tStream read fStream write setStream;
      property ownsStream: boolean read fOwnsStream write fOwnsStream;
      property raiseErrors: boolean read fRaiseErrors write fRaiseErrors;

      constructor create(const aStream: tStream);
      constructor create(const s: string);
      destructor  destroy; override;
      procedure reset;
      function  copyText(absPosStart, absPosEnd: integer): string;
      procedure error(code, l, p: integer);
      procedure error(code, l, p: integer; const args: array of const);
  end;

type
  // Парсер лексики языка Клаус
  tKlausLexParser = class(tCustomLexParser)
    private
      procedure setLexInfo(s: string; aLexem: tKlausLexem; out li: tKlausLexInfo);
      procedure setLexInfo(s: string; aSymbol: tKlausValidSymbol; out li: tKlausLexInfo);
      procedure processSingleLineComment(c: u8Char; out li: tKlausLexInfo);
      procedure processMultiLineComment(c: u8Char; out li: tKlausLexInfo);
      procedure processSymbol(c: u8Char; out li: tKlausLexInfo);
      procedure processChar(c: u8Char; out li: tKlausLexInfo);
      procedure processCharCode(c: u8Char; out li: tKlausLexInfo);
      procedure processString(c: u8Char; out li: tKlausLexInfo);
      procedure processMoment(c: u8Char; out li: tKlausLexInfo);
      procedure processWord(c: u8Char; out li: tKlausLexInfo);
      procedure processNumber(c: u8Char; out li: tKlausLexInfo);
      procedure processHexNumber(c: u8Char; out li: tKlausLexInfo);
    public
      class function  isSpace(c: u8Char): boolean;
      class function  isEOLN(c: u8Char): boolean;
      class function  isLetter(c: u8Char): boolean;
      class function  isIdentChar(c: u8Char): boolean;
      class function  isDigit(c: u8Char): boolean;
      class function  isHexDigit(c: u8Char): boolean;
      class function  translateHexDigit(c: u8Char): u8Char;
      class function  isCharCode(c: u8Char): boolean;
      class function  isHexNum(c: u8Char): boolean;
      class function  isDecimal(c: u8Char): boolean;
      class function  isExponent(c: u8Char): boolean;
      class function  findSymbol(s: string): tKlausSymbol;
      class function  symbolValue(k: tKlausValidSymbol): string;
      class function  findKeyword(s: string): tKlausKeyword;
      class function  keywordValue(k: tKlausValidKeyword): string;

      procedure getNextLexem(out li: tKlausLexInfo);
      function  wideLexBegins(const s: string; idx: integer; out lex: tKlausLexem; out index: integer): boolean;
      function  wideLexEnds(const s: string; idx: integer; lex: tKlausLexem; out index: integer): boolean;
  end;

// Возвращает имя переданной лексемы
function klausLexemName(lex: tKlausLexem): string;

const
  // Ключевые слова языка Клаус
  // Обязательно в нижнем регистре
  klausKeywords: array of record
    s: string;        // значение должно быть уникально в пределах массива
    k: tKlausKeyword; // значения могут повторяться для синонимичных ключевых слов
  end = (
    (s: 'программа'; k: kkwdProgram),
    (s: 'используется'; k: kkwdUses),
    (s: 'используются'; k: kkwdUses),
    (s: 'начало'; k: kkwdBegin),
    (s: 'окончание'; k: kkwdEnd),
    (s: 'конец'; k: kkwdEnd),
    (s: 'переменная'; k: kkwdVar),
    (s: 'переменные'; k: kkwdVar),
    (s: 'константа'; k: kkwdConst),
    (s: 'константы'; k: kkwdConst),
    (s: 'тип'; k: kkwdType),
    (s: 'типы'; k: kkwdType),
    (s: klausChar; k: kkwdChar),
    (s: 'символов'; k: kkwdChar),
    (s: klausString; k: kkwdString),
    (s: 'строк'; k: kkwdString),
    (s: klausInteger; k: kkwdInteger),
    (s: 'целых'; k: kkwdInteger),
    (s: klausFloat; k: kkwdFloat),
    (s: 'дробных'; k: kkwdFloat),
    (s: klausMoment; k: kkwdMoment),
    (s: 'моментов'; k: kkwdMoment),
    (s: klausBoolean; k: kkwdBoolean),
    (s: 'логических'; k: kkwdBoolean),
    (s: klausObject; k: kkwdObject),
    (s: 'объектов'; k: kkwdObject),
    (s: klausTrue; k: kkwdTrue),
    (s: klausFalse; k: kkwdFalse),
    (s: 'массив'; k: kkwdArray),
    (s: 'массивов'; k: kkwdArray),
    (s: 'словарь'; k: kkwdDict),
    (s: 'словарей'; k: kkwdDict),
    (s: 'структура'; k: kkwdStruct),
    (s: 'структур'; k: kkwdStruct),
    (s: 'ключ'; k: kkwdKey),
    (s: 'процедура'; k: kkwdProcedure),
    (s: 'функция'; k: kkwdFunction),
    (s: 'ничего'; k: kkwdNothing),
    (s: 'прервать'; k: kkwdBreak),
    (s: 'продолжить'; k: kkwdContinue),
    (s: 'вернуть'; k: kkwdReturn),
    (s: 'вернуться'; k: kkwdReturn),
    (s: 'если'; k: kkwdIf),
    (s: 'то'; k: kkwdThen),
    (s: 'иначе'; k: kkwdElse),
    (s: 'для'; k: kkwdFor),
    (s: 'от'; k: kkwdFrom),
    (s: 'до'; k: kkwdTo),
    (s: 'цикл'; k: kkwdLoop),
    (s: 'обратный'; k: kkwdReverse),
    (s: 'пока'; k: kkwdWhile),
    (s: 'выбор'; k: kkwdCase),
    (s: 'из'; k: kkwdOf),
    (s: 'исключение'; k: kkwdException),
    (s: 'исключения'; k: kkwdException),
    (s: 'ошибка'; k: kkwdRaise),
    (s: 'бросить'; k: kkwdThrow),
    (s: 'кинуть'; k: kkwdThrow),
    (s: 'швырнуть'; k: kkwdThrow),
    (s: 'пульнуть'; k: kkwdThrow),
    (s: 'сообщение'; k: kkwdMessage),
    (s: 'завершить'; k: kkwdHalt),
    (s: 'когда'; k: kkwdExceptWhen),
    (s: 'тогда'; k: kkwdExceptThen),
    (s: 'напоследок'; k: kkwdFinally),
    (s: 'любой'; k: kkwdAny),
    (s: 'любая'; k: kkwdAny),
    (s: 'любое'; k: kkwdAny),
    (s: 'вх'; k: kkwdInput),
    (s: 'вых'; k: kkwdOutput),
    (s: 'вв'; k: kkwdInOut),
    (s: 'каждый'; k: kkwdEach),
    (s: 'каждого'; k: kkwdEach),
    (s: 'каждой'; k: kkwdEach),
    (s: 'есть'; k: kkwdExists),
    (s: 'нету'; k: kkwdNotExists),
    (s: 'пусто'; k: kkwdEmpty)
  );

const
  // Знаки языка -- знаки операций, скобки, запятые и пр.
  // В нынешней реализации лексического анализатора поддерживаются
  // только однобуквенные и двухбуквенные знаки языка.
  // Впрочем, это несложно поправить. В более высоких слоях кода
  // таких ограничений быть не должно -- нужно рассчитывать на то,
  // что знаки языка могут быть любой длины.
  // Также предполагается, что текст символов не содержит букв,
  // для которых имеет значение регистр. В нынешней реализации
  // поиск по массиву знаков -- регистрочувствительный.
  klausSymbols: array of record
    s: string;            // значение должно быть уникально в пределах массива
    k: tKlausValidSymbol; // значения могут повторяться для синонимичных знаков
  end = (
    (s: '+';  k: klsPlus),
    (s: '++'; k: klsConcat),
    (s: '*';  k: klsMulti),
    (s: '/';  k: klsFDiv),
    (s: '\';  k: klsIDiv),
    (s: '%';  k: klsMod),
    (s: '^';  k: klsPwr),
    (s: '=';  k: klsEq),
    (s: '<>'; k: klsNEq),
    (s: '!='; k: klsNEq),
    (s: '<';  k: klsLT),
    (s: '>';  k: klsGT),
    (s: '<='; k: klsLE),
    (s: '>='; k: klsGE),
    (s: '-';  k: klsMinus),
    (s: '!'; k: klsNot),
    (s: '&&'; k: klsAnd),
    (s: '||'; k: klsOr),
    (s: '~|'; k: klsXor),
    (s: ':='; k: klsAsgn),
    (s: '+='; k: klsAddAsgn),
    (s: '-='; k: klsSubAsgn),
    (s: '*='; k: klsMulAsgn),
    (s: '/='; k: klsFDivAsgn),
    (s: '\='; k: klsIDivAsgn),
    (s: '%='; k: klsModAsgn),
    (s: '^='; k: klsPwrAsgn),
    (s: ',';  k: klsComma),
    (s: '.';  k: klsDot),
    (s: ':';  k: klsColon),
    (s: ';';  k: klsSemicolon),
    (s: '(';  k: klsParOpen),
    (s: ')';  k: klsParClose),
    (s: '[';  k: klsBktOpen),
    (s: ']';  k: klsBktClose)
  );

const
  // Символы, с которых могут начинаться идентификаторы и ключевые слова.
  // Во всех регистрах.
  klausLetters = '_'+
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'+
    'abcdefghijklmnopqrstuvwxyz'+
    'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'+
    'абвгдеёжзийклмнопрстуфхцчшщъыьэюя';

  // Символы, с которых могут начинаться численные литералы.
  // Во всех регистрах.
  klausDigits = '0123456789';

  // Символы, которыми могут продолжаться идентификаторы и ключевые слова.
  // Во всех регистрах.
  klausIdentChars = klausLetters + klausDigits;

  // Символы, допустимые в 16-ричных численных литералах.
  // Во всех регистрах.
  klausHexDigits = klausDigits + 'ABCDEFabcdefАБЦДЕФабцдеф'; // ИНЖАЛИД ДЕЖИЦЕ! ;)

  // Десятичный разделитель
  klausDecimalPoint = '.';

  // Разделитель даты
  klausSepYMD = '-';

  // Разделитель времени
  klausSepHMS = ':';

  // Константа для обработки литералов и приведения значений к строке
  klausLiteralFormat: tFormatSettings = (
    currencyFormat: 5;
    negCurrFormat: 5;
    thousandSeparator: ' ';
    decimalSeparator: klausDecimalPoint;
    currencyDecimals: 2;
    dateSeparator: klausSepYMD;
    timeSeparator: klausSepHMS;
    listSeparator: ',';
    currencyString: '₽';
    shortDateFormat: 'yyyy/mm/dd';
    longDateFormat: 'yyyy/mm/dd';
    timeAMString: 'ДП';
    timePMString: 'ПП';
    shortTimeFormat: 'hh:nn:ss';
    longTimeFormat: 'hh:nn:ss';
    shortMonthNames: ('Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек');
    longMonthNames: ('Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь');
    shortDayNames: ('Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб');
    longDayNames:  ('Воскресенье', 'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота');
    twoDigitYearCenturyWindow: 50;
  );

  // Символы, с которых может начинаться экспоненцияльная часть вещетвенного литерала.
  // Во всех регистрах.
  klausExponentChars = 'EeЕеЭэ';

implementation

uses TypInfo, KlausUtils, KlausDef, KlausErr;

// Возвращает имя переданной лексемы
function klausLexemName(lex: tKlausLexem): string;
begin
  result := copy(getEnumName(typeInfo(tKlausLexem), ord(lex)), 4);
end;

{ tStringReadStream }

constructor tStringReadStream.create(const s: string);
begin
  inherited create;
  setData(s);
end;

procedure tStringReadStream.setData(value: string);
begin
  fData := value;
  setPointer(pChar(fData), length(fData));
  seek(0, soFromBeginning);
  if assigned(fOnReset) then fOnReset(self);
end;

{ tCustomLexParser }

// Создание, инициализация
constructor tCustomLexParser.create(const aStream: tStream);
begin
  inherited create;
  fRaiseErrors := true;
  ownsStream := true;
  setStream(aStream);
end;

// Создание, инициализация
constructor tCustomLexParser.create(const s: string);
var
  str: tStringReadStream;
begin
  str := tStringReadStream.create(s);
  str.onReset := @streamReset;
  create(str);
  ownsStream := true;
end;

// Уничтожение
// Если ownedStream, то уничтожает stream
destructor tCustomLexParser.destroy;
begin
  setStream(nil);
  inherited destroy;
end;

procedure tCustomLexParser.reset;
begin
  fBOF := true;
  fEOF := false;
  fEOLN := false;
  fAbsPos := 0;
  fLine := 1;
  fPos := 1;
  fPrevLineLength := 0;
  fPrevAbsPos := 0;
end;

// Устанавливает stream и инициализирует парсер
// Если ownedStream, то предыдущий stream уничтожается
procedure tCustomLexParser.setStream(aStream: tStream);
begin
  if (fStream <> aStream) then begin
    if fOwnsStream and assigned(fStream) then freeAndNil(fStream);
    fStream := aStream;
    reset;
  end;
end;

procedure tCustomLexParser.streamReset(sender: tObject);
begin
  reset;
end;

// Возвращает следующий символ UTF8 из потока
function tCustomLexParser.nextChar: u8Char;
var
  sp: integer;
begin
  if fEOF then exit(LF);
  sp := fStream.position;
  try
    result := u8ReadChar(fStream);
  except
    on eStreamError do raise eKlausError.create(ercStreamError, fLine, fPos);
    else raise;
  end;
  if result = '' then begin
    result := LF;
    fEOF := true;
  end;
  if fBOF then begin
    fAbsPos := 0;
    fPrevAbsPos := 0;
    fLine := 1;
    fPos := 1;
    fPrevLineLength := 0;
    fBOF := false;
  end else begin
    fPrevAbsPos := fAbsPos;
    fAbsPos := sp;
    if fEOLN then begin
      fPrevLineLength := fPos;
      Inc(fLine);
      fPos := 1;
    end else
      Inc(fPos);
  end;
  if result = CR then result := ' ';
  fEOLN := result = LF;
  fFeedBackTwice := false;
end;

// Сдаёт назад на один символ UTF8 в потоке
procedure tCustomLexParser.feedBack;
begin
  assert(not fBOF, 'Cannot feed back at the beginning of the stream');
  assert(not fFeedBackTwice, 'Cannot feed back twice');
  fFeedBackTwice := true;
  if fAbsPos = 0 then begin
    fBOF := true;
    fEOF := false;
    fEOLN := false;
  end else begin
    fStream.position := fAbsPos;
    fAbsPos := fPrevAbsPos;
    fEOF := false;
    if fPos <= 1 then begin
      dec(fLine);
      fPos := fPrevLineLength;
      fEOLN := true;
    end else begin
      dec(fPos);
      fEOLN := false;
    end;
  end;
end;

// Возвращает следующий символ UTF8 из потока и сдаёт назад
function tCustomLexParser.tryNextChar: u8Char;
begin
  result := nextChar;
  feedBack;
end;

// Копирует байты из потока в указанном диапазоне
function tCustomLexParser.copyText(absPosStart, absPosEnd: integer): string;
var
  savePos, len: integer;
begin
  if fStream = nil then exit;
  len := absPosEnd - absPosStart;
  if len <= 0 then exit('');
  savePos := fStream.position;
  try
    setLength(result, len);
    fStream.position := absPosStart;
    len := fStream.read(pChar(result)^, len);
    SetLength(result, len);
  finally
    fStream.position := savePos;
  end;
end;

procedure tCustomLexParser.error(code, l, p: integer);
begin
  if not raiseErrors then exit;
  raise eKlausError.create(code, l, p) at get_caller_addr(get_frame);
end;

procedure tCustomLexParser.error(code, l, p: integer; const args: array of const);
begin
  if not raiseErrors then exit;
  raise eKlausError.createFmt(code, l, p, args) at get_caller_addr(get_frame);
end;

{ tKlausLexParser }

// Пишет в lu следующую лексему из потока
// В случае конца потока пишет klutEOF
procedure tKlausLexParser.getNextLexem(out li: tKlausLexInfo);
var
  c: u8Char;
begin
  if stream = nil then begin
    setLexInfo(LF, klxEOF, li);
    exit;
  end;
  c := nextChar;
  while not EOF do begin
    if not isSpace(c) then break;
    c := nextChar;
  end;
  if not EOF then begin
    if c = '/' then begin
      if tryNextChar = '/' then processSingleLineComment(c, li)
      else processSymbol(c, li);
    end else if c = '{' then begin
      processMultiLineComment(c, li);
    end else if c = '''' then begin
      processChar(c, li);
    end else if isCharCode(c) then begin
      processCharCode(c, li);
    end else if c = '"' then begin
      processString(c, li);
    end else if c = '`' then begin
      processMoment(c, li);
    end else if isLetter(c) then begin
      processWord(c, li);
    end else if isHexNum(c) then begin
      processHexNumber(c, li);
    end else if isDigit(c) then begin
      processNumber(c, li);
    end else begin
      processSymbol(c, li);
    end;
  end else
    setLexInfo(LF, klxEOF, li);
end;

function tKlausLexParser.wideLexBegins(const s: string; idx: integer; out lex: tKlausLexem; out index: integer): boolean;
var
  i, l, savePos: Integer;
  inStr, open: Boolean;
begin
  inStr := false;
  open := false;
  l := length(s);
  savePos := 0;
  for i := idx to l do
    case s[i] of
      '{': if not inStr then begin
        open := true;
        savePos := i;
      end;
      '}': open := false;
      '''': if not open then inStr := not inStr;
    end;
  if open then begin
    result := true;
    lex := klxMLComment;
    index := savePos;
  end else
    result := false;
end;

function tKlausLexParser.wideLexEnds(const s: string; idx: integer; lex: tKlausLexem; out index: integer): boolean;
var
  i, l: integer;
begin
  result := false;
  if lex <> klxMLComment then exit;
  l := length(s);
  for i := idx to l do
    if s[i] = '}' then begin
      result := true;
      index := i;
      exit;
    end;
end;

// Возвращает true для пробельных символов (включая символы перевода строки)
class function tKlausLexParser.isSpace(c: u8Char): boolean;
begin
  result := (c = CR) or (c = LF) or (c = Tab) or (c = Space);
end;

// Возвращает true для символа перевода строки.
// Если последовательность перевода строки многосимвольная,
// то здесь нужно проверять последний символ последовательности.
class function tKlausLexParser.isEOLN(c: u8Char): boolean;
begin
  result := c = LF;
end;

// Возвращает true для символов, с которых может начинаться
// идентификатор или ключевое слово
class function tKlausLexParser.isLetter(c: u8Char): boolean;
begin
  result := system.pos(c, klausLetters) > 0;
end;

// Возвращает true для символов, которыми может продолжаться
// идентификатор или ключевое слово
class function tKlausLexParser.isIdentChar(c: u8Char): boolean;
begin
  result := system.pos(c, klausIdentChars) > 0;
end;

// Возвращает true для символов, с которых может начинаться численный литерал
class function tKlausLexParser.isDigit(c: u8Char): boolean;
begin
  result := system.pos(c, klausDigits) > 0;
end;

// Возвращает true для символов, которые могут быть 16-ричными цифрами
class function tKlausLexParser.isHexDigit(c: u8Char): boolean;
begin
  result := system.pos(c, klausHexDigits) > 0;
end;

// Приводит кириллические 16-ричные цифры к латинским.
// Если это невозможно, возвращает c.
class function tKlausLexParser.translateHexDigit(c: u8Char): u8Char;
begin
  if (c = 'А') or (c = 'а') then result := 'a'
  else if (c = 'Б') or (c = 'б') then result := 'b'
  else if (c = 'Ц') or (c = 'ц') then result := 'c'
  else if (c = 'Д') or (c = 'д') then result := 'd'
  else if (c = 'Е') or (c = 'е') then result := 'e'
  else if (c = 'Ф') or (c = 'ф') then result := 'f'
  else result := c;
end;

// Возвращает true для символов, с которых может начинаться литерал кода символа
class function tKlausLexParser.isCharCode(c: u8Char): boolean;
begin
  result := (c = '#') or (c = '№');
end;

// Возвращает true для символов, с которых может начинаться 16-ричный численный литерал
class function tKlausLexParser.isHexNum(c: u8Char): boolean;
begin
  result := c = '$';
end;

// Возвращает true для символа десятичной точки
class function tKlausLexParser.isDecimal(c: u8Char): boolean;
begin
  result := c = klausDecimalPoint;
end;

// Возвращает true для символов, с которых может начинаться
// экспоненциальная часть вещественного литерала
class function tKlausLexParser.isExponent(c: u8Char): boolean;
begin
  result := system.pos(c, klausExponentChars) > 0;
end;

// Возвращает ключевое слово или kkwdInvalid, если s не найдена в списке ключевых слов
class function tKlausLexParser.findKeyword(s: string): tKlausKeyword;
var
  l: string;
  i: integer;
begin
  l := u8Lower(s);
  for i := low(klausKeywords) to high(klausKeywords) do
    if (klausKeywords[i].s) = l then exit(klausKeywords[i].k);
  result := kkwdInvalid;
end;

// Возвращает текст ключевого слова.
// Если определено несколько ключевых слов, возвращает первый по порядку.
class function tKlausLexParser.keywordValue(k: tKlausValidKeyword): string;
var
  i: integer;
begin
  for i := low(klausKeywords) to high(klausKeywords) do
    if (klausKeywords[i].k) = k then exit(klausKeywords[i].s);
  result := '';
end;

// Возвращает знак языка или klssInvalid, если s не найдена в списке знаков
class function tKlausLexParser.findSymbol(s: string): tKlausSymbol;
var
  i: integer;
begin
  for i := low(klausSymbols) to high(klausSymbols) do
    if klausSymbols[i].s = s then exit(klausSymbols[i].k);
  result := klsInvalid;
end;

// Возвращает текст знака языка.
// Если определено несколько синонимичных знаков, возвращает первый по порядку.
class function tKlausLexParser.symbolValue(k: tKlausValidSymbol): string;
var
  i: integer;
begin
  for i := low(klausSymbols) to high(klausSymbols) do
    if klausSymbols[i].k = k then exit(klausSymbols[i].s);
  result := '';
end;

// Заполняет структуру lu
procedure tKlausLexParser.setLexInfo(s: string; aLexem: tKlausLexem; out li: tKlausLexInfo);
begin
  assert(aLexem <> klxSymbol);
  with li do begin
    lexem := aLexem;
    keyword := kkwdInvalid;
    symbol := klsInvalid;
    text := s;
    line := self.line;
    pos := self.pos;
    absPos := self.absPos;
  end;
end;

// Заполняет структуру lu
procedure tKlausLexParser.setLexInfo(s: string; aSymbol: tKlausValidSymbol; out li: tKlausLexInfo);
begin
  with li do begin
    lexem := klxSymbol;
    keyword := kkwdInvalid;
    symbol := aSymbol;
    text := s;
    line := self.line;
    pos := self.pos;
    absPos := self.absPos;
  end;
end;

// Дочитывает из потока однострочный комментарий
procedure tKlausLexParser.processSingleLineComment(c: u8Char; out li: tKlausLexInfo);
begin
  setLexInfo(c, klxSLComment, li);
  c := nextChar;
  while not isEOLN(c) do begin
    li.text += c;
    c := nextChar;
  end;
  feedBack;
end;

// Дочитывает из потока многострочный комментарий
procedure tKlausLexParser.processMultiLineComment(c: u8Char; out li: tKlausLexInfo);
begin
  setLexInfo(c, klxMLComment, li);
  repeat
    c := nextChar;
    if EOF then begin
      error(ercCommentNotClosed, line, pos);
      exit;
    end;
    li.text += c;
  until c = '}';
end;

// Дочитывает из потока знак языка
procedure tKlausLexParser.processSymbol(c: u8Char; out li: tKlausLexInfo);
var
  c2: string;
  sym: tKlausSymbol;
begin
  c2 := c + tryNextChar;
  sym := findSymbol(c2);
  if sym <> klsInvalid then begin
    setLexInfo(c2, sym, li);
    nextChar;
  end else begin
    sym := findSymbol(c);
    if sym <> klsInvalid then setLexInfo(c, sym, li)
    else setLexInfo(c, klxInvalid, li);
  end;
end;

// Дочитывает из потока слово, определяет ключевое слово или идентификатор
procedure tKlausLexParser.processWord(c: u8Char; out li: tKlausLexInfo);
begin
  setLexInfo(c, klxID, li);
  c := nextChar;
  while isIdentChar(c) do begin
    li.text += c;
    c := nextChar;
  end;
  feedBack;
  li.keyword := findKeyword(li.text);
  if li.keyword <> kkwdInvalid then li.lexem := klxKeyword;
end;

// Дочитывает из потока символьный литерал в апострофах
procedure tKlausLexParser.processChar(c: u8Char; out li: tKlausLexInfo);
begin
  setLexInfo(c, klxChar, li);
  c := nextChar;
  if EOLN then begin
    error(ercApostropheNotClosed, li.line, li.pos);
    exit;
  end;
  if c = '''' then begin
    if tryNextChar = '''' then
      nextChar
    else begin
      error(ercEmptyChar, line, pos);
      exit;
    end;
  end;
  li.text += c;
  li.cValue := klausStrToChar(c);
  c := nextChar;
  if EOF then begin
    error(ercApostropheNotClosed, li.line, li.pos);
    exit;
  end;
  if c <> '''' then begin
    error(ercCharTooLong, line, pos);
    feedBack;
    exit;
  end;
  li.text += c;
end;

// Дочитывает из потока численный литерал, определяет целое или вещественное
procedure tKlausLexParser.processNumber(c: u8Char; out li: tKlausLexInfo);
var
  decimal: boolean = false;
  exponent: boolean = false;
  expSign: boolean = false;
  val: string;
begin
  val := c;
  setLexInfo(c, klxInteger, li);
  repeat
    c := nextChar;
    if EOF then break;
    if isDigit(c) then begin
      if exponent then expSign := true;
      val += c;
    end else if isDecimal(c) then begin
      if decimal or exponent then break
      else decimal := true;
      val += defaultFormatSettings.decimalSeparator;
    end else if isExponent(c) then begin
      if exponent then break
      else exponent := true;
      val += 'e';
    end else if (c = '+') or (c = '-') then begin
      if not exponent or expSign then break
      else expSign := true;
      val += c;
    end else
      break;
    li.text += c;
  until FALSE;
  feedBack;
  if decimal or exponent then begin
    li.lexem := klxFloat;
    try li.fValue := klausStrToFloat(val, false);
    except error(ercInvalidFloat, li.line, li.pos); exit; end;
  end else begin
    try li.iValue := klausStrToInt(val);
    except error(ercInvalidInteger, li.line, li.pos); exit; end;
  end;
end;

// Дочитывает из потока 16-ричный целочисленный литерал
procedure tKlausLexParser.processHexNumber(c: u8Char; out li: tKlausLexInfo);
var
  val: string;
begin
  val := '';
  setLexInfo(c, klxInteger, li);
  repeat
    c := nextChar;
    if EOF then break;
    if not isHexDigit(c) then break;
    li.text += c;
    val += translateHexDigit(c);
  until FALSE;
  feedBack;
  try li.iValue := klausStrToInt('$' + val);
  except error(ercInvalidHexadecimal, li.line, li.pos); exit; end;
end;

// Дочитывает из потока литерал кода символа Unicode
procedure tKlausLexParser.processCharCode(c: u8Char; out li: tKlausLexInfo);
var
  n: u8Char;
  nli: tKlausLexInfo;
begin
  setLexInfo(c, klxChar, li);
  n := tryNextChar;
  if isHexDigit(n) then begin
    processHexNumber('', nli);
    if (nli.iValue < low(tKlausChar))
    or (nli.iValue > high(tKlausChar)) then begin
      error(ercInvalidCharCode, li.line, li.pos);
      exit;
    end;
    li.cValue := nli.iValue;
    li.text += nli.text;
  end else begin
    error(ercInvalidCharCode, li.line, li.pos);
    exit;
  end;
end;

// Дочитывает из потока строковый литерал
procedure tKlausLexParser.processString(c: u8Char; out li: tKlausLexInfo);
var
  cli: tKlausLexInfo;
  needQuote: boolean;
begin
  setLexInfo(c, klxString, li);
  li.sValue := '';
  repeat
    c := nextChar;
    if EOLN then begin
      error(ercQuoteNotClosed, li.line, li.pos);
      exit;
    end;
    li.text += c;
    if c = '"' then begin
      needQuote := true;
      c := nextChar;
      while isCharCode(c) do begin
        needQuote := false;
        processCharCode(c, cli);
        li.text += cli.text;
        li.sValue += klausCharToStr(cli.cValue);
        c := nextChar;
      end;
      if c = '"' then begin
        li.text += c;
        if needQuote then li.sValue += c;
      end else begin
        feedBack;
        break;
      end;
    end else
      li.sValue += c;
  until false;
end;

// Дочитывает из потока литерал даты/времени
procedure tKlausLexParser.processMoment(c: u8Char; out li: tKlausLexInfo);
var
  s: string = '';
begin
  setLexInfo(c, klxMoment, li);
  repeat
    c := nextChar;
    if EOLN then begin
      error(ercMomentNotClosed, li.line, li.pos);
      exit;
    end;
    li.text += c;
    if c <> '`' then s += c;
  until c = '`';
  try li.mValue := klausStrToMoment(s);
  except error(ercInvalidMoment, li.line, li.pos); exit; end;
end;

end.

