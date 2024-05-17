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

unit KlausErr;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, KlausLex;

type
  // Стандартные исключения языка -- определения даны в модуле KlausUnitSystem
  tKlausStdException = (
    ksxInOutError, ksxConvertError, ksxIndexError, ksxKeyError, ksxTypeMismatch, ksxInvalidName,
    ksxSyntaxError, ksxInvalidChar, ksxRuntimeError, ksxBadNumber, ksxInternalError);

type
  // Позиция в исходном тексте
  tSrcPoint = record
    line: integer;   // строка, начиная с 1
    pos: integer;    // символ в строке, начиная с 1
    absPos: integer; // байт в потоке, начиная с 0
  end;

const
  // Константа для тех случаев, когда точка в исходном тексте
  // не определена, а вызов требует. Применять с осторожностью!
  zeroSrcPt: tSrcPoint = (line: 0; pos: 0; absPos: 0);

const
  // Коды ошибок eKlausError
  ercQuoteNotClosed         = 01;
  ercCommentNotClosed       = 02;
  ercStreamError            = 03;
  ercEmptyChar              = 04;
  ercCharTooLong            = 05;
  ercApostropheNotClosed    = 06;
  ercInvalidInteger         = 07;
  ercInvalidFloat           = 08;
  ercInvalidHexadecimal     = 09;
  ercInvalidCharCode        = 10;
  ercSyntaxError            = 11;
  ercTextAfterEnd           = 12;
  ercUnexpectedSyntax       = 13;
  ercDuplicateName          = 14;
  ercVarNameNotFound        = 15;
  ercTypeNameRequired       = 16;
  ercTypeMismatch           = 17;
  ercMomentNotClosed        = 18;
  ercInvalidMoment          = 19;
  ercLoopCtlOutsideLoop     = 20;
  ercInvalidLiteralValue    = 21;
  ercInvalidTypecast        = 22;
  ercBinOperNotDefined      = 23;
  ercUnOperNotDefined       = 24;
  ercNotConstantValue       = 25;
  ercValueDeclRequired      = 26;
  ercIllegalIndexQualifier  = 27;
  ercIndexMustBeInteger     = 28;
  ercIllegalFieldQualifier  = 29;
  ercStructMemberNotFound   = 30;
  ercCannotReturnValue      = 31;
  ercInvalidArrayIndex      = 32;
  ercConstAsgnTarget        = 33;
  ercIllegalAsgnOperator    = 34;
  ercInvalidDictIndex       = 35;
  ercInvalidDictKey         = 36;
  ercSubroutineRequired     = 37;
  ercMustReturnValue        = 38;
  ercWrongNumberOfParams    = 39;
  ercInvalidOutputParam     = 40;
  ercCannotWriteComplexType = 41;
  ercCannotReadComplexType  = 42;
  ercStackTooBig            = 43;
  ercConditionMustBeBool    = 44;
  ercInvalidLoopCounter     = 45;
  ercExceptionRequired      = 46;
  ercExceptBlockOnly        = 47;
  ercMixedExceptBlock       = 48;
  ercExceptAnyMustBeLast    = 49;
  ercExceptAlreadyHandled   = 50;
  ercInvalidForEachKey      = 51;
  ercInvalidForEachType     = 52;
  ercForEachKeyTypeMismatch = 53;
  ercCaseExprMustBeSimple   = 54;
  ercDuplicateCaseLabel     = 55;
  ercInvalidCharAtIndex     = 56;
  ercInvalidStringIndex     = 57;
  ercInvalidFormatSpecifier = 58;
  ercInvalidFormatArgIdx    = 59;
  ercInvalidFormatArgType   = 60;
  ercArgumentIsNaN          = 61;
  ercArgumentIsNotFinite    = 62;
  ercMissingProgramFilename = 63;
  ercInaccurateCleanup      = 64;
  ercInvalidKlausHandle     = 65;
  ercTooManyHandles         = 66;
  ercValueCannotBeRead      = 67;
  ercInvalidFileType        = 68;
  ercUnexpectedObjectClass  = 69;
  ercIllegalExpression      = 70;
  ercStreamNotOpen          = 71;
  ercAccuracyNotApplicable  = 72;
  ercNegativeAccuracy       = 73;
  ercCallsNotAllowed        = 74;
  ercConstOutputParam       = 75;
  ercUndefinedForward       = 76;
  ercDuplicateForward       = 77;
  ercWrongForwardSignature  = 78;
  ercCanvasUnavailable      = 79;
  ercInvalidFormatParamType = 80;
  ercGraphicOperationNA     = 81;
  ercInvalidListIndex       = 82;
  ercEventQueueEmpty        = 83;
  ercUntypedCompoundLiteral = 84;
  ercDuplicateMemberLiteral = 85;

const
  // Классификация кодов eKlausError для трансляции в исключения языка
  klausCodeToStdErr: array[tKlausStdException] of set of byte = (
    //ksxInOutError
    [ercStreamError, ercInvalidFileType, ercStreamNotOpen],

    //ksxConvertError
    [ercInvalidLiteralValue, ercInvalidFormatSpecifier, ercInvalidFormatArgIdx,
    ercInvalidFormatArgType],

    //ksxIndexError
    [ercInvalidArrayIndex, ercInvalidDictIndex, ercInvalidListIndex],

    //ksxKeyError
    [ercInvalidDictKey],

    //ksxTypeMismatch
    [ercInvalidTypecast, ercTypeMismatch, ercIndexMustBeInteger, ercCannotWriteComplexType,
    ercCannotReadComplexType, ercConditionMustBeBool, ercBinOperNotDefined, ercUnOperNotDefined,
    ercIllegalAsgnOperator, ercInvalidLoopCounter, ercInvalidForEachKey, ercInvalidForEachType,
    ercForEachKeyTypeMismatch, ercCaseExprMustBeSimple, ercValueCannotBeRead,
    ercInvalidFormatParamType],

    //ksxInvalidName
    [ercVarNameNotFound, ercStructMemberNotFound],

    //ksxSyntaxError
    [ercQuoteNotClosed, ercCommentNotClosed, ercEmptyChar, ercCharTooLong, ercApostropheNotClosed,
    ercInvalidInteger, ercInvalidFloat, ercInvalidHexadecimal, ercInvalidCharCode, ercSyntaxError,
    ercTextAfterEnd, ercDuplicateName, ercTypeNameRequired, ercMomentNotClosed, ercInvalidMoment,
    ercLoopCtlOutsideLoop, ercNotConstantValue, ercValueDeclRequired, ercIllegalIndexQualifier,
    ercIllegalFieldQualifier, ercCannotReturnValue, ercConstAsgnTarget, ercSubroutineRequired,
    ercMustReturnValue, ercWrongNumberOfParams, ercInvalidOutputParam, ercExceptionRequired,
    ercExceptBlockOnly, ercMixedExceptBlock, ercExceptAnyMustBeLast, ercExceptAlreadyHandled,
    ercDuplicateCaseLabel, ercIllegalExpression, ercAccuracyNotApplicable, ercNegativeAccuracy,
    ercConstOutputParam, ercUndefinedForward, ercDuplicateForward, ercWrongForwardSignature,
    ercUntypedCompoundLiteral, ercDuplicateMemberLiteral],

    //ksxInvalidChar
    [ercInvalidCharAtIndex, ercInvalidStringIndex],

    //ksxRuntimeError
    [ercStackTooBig, ercInaccurateCleanup, ercInvalidKlausHandle, ercTooManyHandles,
    ercUnexpectedObjectClass, ercCallsNotAllowed, ercCanvasUnavailable, ercGraphicOperationNA,
    ercEventQueueEmpty],

    //ksxBadNumber
    [ercArgumentIsNaN, ercArgumentIsNotFinite],

    //ksxInternalError
    [ercUnexpectedSyntax]
  );

type
  // Исключение, вызываемое в коде Клаус
  eKlausError = class(Exception)
    private
      fCode: integer;
      fLine, fPos: integer;
    protected
      function getErrorMessage: string; virtual;
    public
      property code: integer read fCode write fCode;
      property line: integer read fLine write fLine;
      property pos: integer read fPos write fPos;

      constructor create(aCode: integer; aLine, aPos: integer);
      constructor createFmt(aCode: integer; aLine, aPos: integer; const args: array of const);
      constructor create(aCode: integer; p: tSrcPoint);
      constructor createFmt(aCode: integer; p: tSrcPoint; const args: array of const);
      function toString: string; override;
  end;

// Создаёт структуру с информацией о позиции элемента в исходном тексте
function srcPoint(l, p, abs: integer): tSrcPoint;
function srcPoint(li: tKlausLexInfo): tSrcPoint;

// Преобразует src в точку для tKlausEdit
function srcToEdit(src: tSrcPoint): tPoint;

implementation

resourcestring
  errAtLinePos = 'Ошибка %s в строке %d, символ %d: %s';
  errQuoteNotClosed = 'Ожидаются закрывающие кавычки, а обнаружен конец строки.';
  errCommentNotClosed = 'Ожидается окончание комментария, а обнаружен конец файла.';
  errStreamError = 'Ошибка чтения исходного файла.';
  errEmptyChar = 'Неверный символьный литерал. Ожидается ровно один символ.';
  errCharTooLong = 'Слишком длинный символьный литерал. Ожидается ровно один символ.';
  errApostropheNotClosed = 'Ожидается закрывающий апостроф, а обнаружен конец строки.';
  errInvalidInteger = 'Неверный целочисленный литерал.';
  errInvalidFloat = 'Неверный дробный литерал.';
  errInvalidHexadecimal = 'Неверный шестнадцатиричный целочисленный литерал.';
  errInvalidCharCode = 'Неверный литерал Unicode. Ожидается шестнадцатиричное целое число.';
  errSyntaxError = 'Синтаксическая ошибка.';
  errTextAfterEnd = 'Недопустимый текст после окончания исходного кода.';
  errUnexpectedSyntax = 'Внутренняя ошибка. Неожиданный синтаксис.';
  errDuplicateName = 'Повторное определение имени: "%s"';
  errVarNameNotFound = 'Переменная не существует в текущем фрейме: "%s"';
  errTypeNameRequired = 'Требуется имя типа данных.';
  errTypeMismatch = 'Несоответствие типов данных';
  errMomentNotClosed = 'Ожидается закрывающий обратный апостроф, а обнаружен конец строки.';
  errInvalidMoment = 'Неверный литерал момента времени.';
  errLoopCtlOutsideLoop = 'Инструкция может использоваться только внутри тела цикла.';
  errInvalidLiteralValue = 'Неверное буквальное значение.';
  errInvalidTypecast = 'Недопустимое преобразование типов.';
  errBinOperNotDefined = 'Операция "%s" не определена для операндов "%s" и "%s".';
  errUnOperNotDefined = 'Операция "%s" не определена для операнда "%s".';
  errNotConstantValue = 'Невозможно вычислить значение на этапе компиляции.';
  errValueDeclRequired = 'Требуется имя переменной или константы.';
  errIllegalIndexQualifier = 'Обращение по индексу допустимо только для массивов и словарей.';
  errIndexMustBeInteger = 'Индекс массива должен быть целым числом.';
  errIllegalFieldQualifier = 'Обращение к полям допустимо только для структурных типов.';
  errStructMemberNotFound = 'Структура не содержит поля "%s".';
  errCannotReturnValue = 'Процедура не может возвращать значение.';
  errInvalidArrayIndex = 'Индекс массива вне допустимых пределов: %d.';
  errConstAsgnTarget = 'Невозможно присвоить значение константе.';
  errIllegalAsgnOperator = 'Недопустимый оператор присваивания.';
  errInvalidDictIndex = 'Индекс элемента словаря вне допустимых пределов: %d.';
  errInvalidDictKey = 'Ключ словаря не существует: %s.';
  errSubroutineRequired = '"%s" не является именем процедуры или функции.';
  errMustReturnValue = 'Не указано возвращаемое значение.';
  errWrongNumberOfParams = 'Указано неверное количество параметров: %d (требуется %s).';
  errInvalidOutputParam = 'В качестве выходных параметров могут быть указаны только переменные.';
  errCannotWriteComplexType = 'Невозможно вывести значение составного типа.';
  errCannotReadComplexType = 'Невозможно прочесть значение составного типа.';
  errStackTooBig = 'Слишком большой уровень вложенности вызовов.';
  errConditionMustBeBool = 'Условное выражение должно возвращать логическое значение.';
  errInvalidLoopCounter = 'Счётчик цикла должен быть локальной целочисленной переменной.';
  errExceptionRequired = '"%s" не является именем исключения.';
  errExceptBlockOnly = 'Инструкция допустима только в блоке обработки исключений.';
  errMixedExceptBlock = 'Блок может содержать либо инструкции, либо секции обработки исключений.';
  errExceptAnyMustBeLast = 'Секция должна быть последней в блоке обработки исключений.';
  errExceptAlreadyHandled = 'Исключение %s уже обработано в этой или одной из предыдущих секций.';
  errInvalidForEachKey = 'Итератор цикла должен быть локальной переменной простого типа.';
  errInvalidForEachType = 'Неверный тип данных. Ожидается массив, словарь или строка.';
  errForEachKeyTypeMismatch = 'Неверный тип переменной итератора. Ожидается %s.';
  errCaseExprMustBeSimple = 'Выражение должно возвращать значение простого типа.';
  errDuplicateCaseLabel = 'Повторное значение варианта выбора.';
  errInvalidCharAtIndex = 'Указанная позиция в строке не является началом символа: %d.';
  errInvalidStringIndex = 'Указанная позиция в строке выходит за допустимые пределы: %d.';
  errInvalidFormatSpecifier = 'Неверный спецификатор в строке форматирования.';
  errInvalidFormatArgIdx = 'Неверный индекс аргумента форматирования или недостаточно аргументов: %d.';
  errInvalidFormatArgType = 'Тип аргумента %d не соответствует типу спецификатора.';
  errArgumentIsNaN = 'Операция недопустима для аргументов, имеющих значение НеЧисло.';
  errArgumentIsNotFinite = 'Операция недопустима для аргументов, имеющих значение НеЧисло или Бесконечность.';
  errMissingProgramFilename = 'Не указано имя файла выполняемой программы.';
  errInaccurateCleanup = 'Некоторые объекты, созданные при выполнении программы, не были уничтожены.';
  errInvalidKlausHandle = 'Неверный дескриптор объекта: %.8x. Объект не был создан.';
  errTooManyHandles = 'Слишком много дескрипторов объектов.';
  errValueCannotBeRead = 'Значение этого типа не может быть прочитано: %s.';
  errInvalidFileType = 'Неверный тип файла: %d.';
  errUnexpectedObjectClass = 'Неожиданный класс объекта. Требуется %s, передано %s.';
  errIllegalExpression = 'Недопустимая конструкция.';
  errStreamNotOpen = 'Поток ввода-вывода не был открыт.';
  errAccuracyNotApplicable = 'Указание точности сравнения допустимо только для дробных чисел и моментов.';
  errNegativeAccuracy = 'Точность сравнения не может быть отрицательным числом.';
  errCallsNotAllowed = 'Вызовы функций не разрешены.';
  errConstOutputParam = 'Нельзя использовать константу в качестве выходного параметра.';
  errUndefinedForward = 'Отсутствует реализация для предварительного определения.';
  errDuplicateForward = 'Повторное предварительное определение.';
  errWrongForwardSignature = 'Определение подпрограммы не соответствует предварительному определению.';
  errCanvasUnavailable = 'Невозможно использовать функции графической библиотеки в этом режиме.';
  errInvalidFormatParamType = 'В качестве аргументов допустимы только значения или одномерные массивы простых типов.';
  errGraphicOperationNA = 'Операция невозможна для данного типа графического объекта: %s.';
  errInvalidListIndex = 'Неверный индекс элемента в списке: %d.';
  errEventQueueEmpty = 'Очередь событий пуста.';
  errUntypedCompoundLiteral = 'Не определён тип данных для составного значения.';
  errDuplicateMemberLiteral = 'Повторное присваивание значения полю структуры: "%s".';

{ Globals }

// Создаёт структуру с информацией о позиции элемента в исходном тексте
function srcPoint(l, p, abs: integer): tSrcPoint;
begin
  result.line := l;
  result.pos := p;
  result.absPos := abs;
end;

// Создаёт структуру с информацией о позиции элемента в исходном тексте
function srcPoint(li: tKlausLexInfo): tSrcPoint;
begin
  result.line := li.line;
  result.pos := li.pos;
  result.absPos := li.absPos;
end;

// Преобразует src в точку для tKlausEdit
function srcToEdit(src: tSrcPoint): tPoint;
begin
  result.x := src.pos;
  result.y := src.line-1;
end;

{ eKlausError }

function eKlausError.getErrorMessage: string;
begin
  result := '';
  case code of
    ercQuoteNotClosed: result := errQuoteNotClosed;
    ercCommentNotClosed: result := errCommentNotClosed;
    ercStreamError: result := errStreamError;
    ercEmptyChar: result := errEmptyChar;
    ercCharTooLong: result := errCharTooLong;
    ercApostropheNotClosed: result := errApostropheNotClosed;
    ercInvalidInteger: result := errInvalidInteger;
    ercInvalidFloat: result := errInvalidFloat;
    ercInvalidHexadecimal: result := errInvalidHexadecimal;
    ercInvalidCharCode: result := errInvalidCharCode;
    ercSyntaxError: result := errSyntaxError;
    ercTextAfterEnd: result := errTextAfterEnd;
    ercUnexpectedSyntax: result := errUnexpectedSyntax;
    ercDuplicateName: result := errDuplicateName;
    ercVarNameNotFound: result := errVarNameNotFound;
    ercTypeNameRequired: result := errTypeNameRequired;
    ercTypeMismatch: result := errTypeMismatch;
    ercMomentNotClosed: result := errMomentNotClosed;
    ercInvalidMoment: result := errInvalidMoment;
    ercLoopCtlOutsideLoop: result := errLoopCtlOutsideLoop;
    ercInvalidLiteralValue: result := errInvalidLiteralValue;
    ercInvalidTypecast: result := errInvalidTypecast;
    ercBinOperNotDefined: result := errBinOperNotDefined;
    ercUnOperNotDefined: result := errUnOperNotDefined;
    ercNotConstantValue: result := errNotConstantValue;
    ercValueDeclRequired: result := errValueDeclRequired;
    ercIllegalIndexQualifier: result := errIllegalIndexQualifier;
    ercIndexMustBeInteger: result := errIndexMustBeInteger;
    ercIllegalFieldQualifier: result := errIllegalFieldQualifier;
    ercStructMemberNotFound: result := errStructMemberNotFound;
    ercCannotReturnValue: result := errCannotReturnValue;
    ercInvalidArrayIndex: result := errInvalidArrayIndex;
    ercConstAsgnTarget: result := errConstAsgnTarget;
    ercIllegalAsgnOperator: result := errIllegalAsgnOperator;
    ercInvalidDictIndex: result := errInvalidDictIndex;
    ercInvalidDictKey: result := errInvalidDictKey;
    ercSubroutineRequired: result := errSubroutineRequired;
    ercMustReturnValue: result := errMustReturnValue;
    ercWrongNumberOfParams: result := errWrongNumberOfParams;
    ercInvalidOutputParam: result := errInvalidOutputParam;
    ercCannotWriteComplexType: result := errCannotWriteComplexType;
    ercCannotReadComplexType: result := errCannotReadComplexType;
    ercStackTooBig: result := errStackTooBig;
    ercConditionMustBeBool: result := errConditionMustBeBool;
    ercInvalidLoopCounter: result := errInvalidLoopCounter;
    ercExceptionRequired: result := errExceptionRequired;
    ercExceptBlockOnly: result := errExceptBlockOnly;
    ercMixedExceptBlock: result := errMixedExceptBlock;
    ercExceptAnyMustBeLast: result := errExceptAnyMustBeLast;
    ercExceptAlreadyHandled: result := errExceptAlreadyHandled;
    ercInvalidForEachKey: result := errInvalidForEachKey;
    ercInvalidForEachType: result := errInvalidForEachType;
    ercForEachKeyTypeMismatch: result := errForEachKeyTypeMismatch;
    ercCaseExprMustBeSimple: result := errCaseExprMustBeSimple;
    ercDuplicateCaseLabel: result := errDuplicateCaseLabel;
    ercInvalidCharAtIndex: result := errInvalidCharAtIndex;
    ercInvalidStringIndex: result := errInvalidStringIndex;
    ercInvalidFormatSpecifier: result := errInvalidFormatSpecifier;
    ercInvalidFormatArgIdx: result := errInvalidFormatArgIdx;
    ercInvalidFormatArgType: result := errInvalidFormatArgType;
    ercArgumentIsNaN: result := errArgumentIsNaN;
    ercArgumentIsNotFinite: result := errArgumentIsNotFinite;
    ercMissingProgramFilename: result := errMissingProgramFilename;
    ercInaccurateCleanup: result := errInaccurateCleanup;
    ercInvalidKlausHandle: result := errInvalidKlausHandle;
    ercTooManyHandles: result := errTooManyHandles;
    ercValueCannotBeRead: result := errValueCannotBeRead;
    ercInvalidFileType: result := errInvalidFileType;
    ercUnexpectedObjectClass: result := errUnexpectedObjectClass;
    ercIllegalExpression: result := errIllegalExpression;
    ercStreamNotOpen: result := errStreamNotOpen;
    ercAccuracyNotApplicable: result := errAccuracyNotApplicable;
    ercNegativeAccuracy: result := errNegativeAccuracy;
    ercCallsNotAllowed: result := errCallsNotAllowed;
    ercConstOutputParam: result := errConstOutputParam;
    ercUndefinedForward: result := errUndefinedForward;
    ercDuplicateForward: result := errDuplicateForward;
    ercWrongForwardSignature: result := errWrongForwardSignature;
    ercCanvasUnavailable: result := errCanvasUnavailable;
    ercInvalidFormatParamType: result := errInvalidFormatParamType;
    ercGraphicOperationNA: result := errGraphicOperationNA;
    ercInvalidListIndex: result := errInvalidListIndex;
    ercEventQueueEmpty: result := errEventQueueEmpty;
    ercUntypedCompoundLiteral: result := errUntypedCompoundLiteral;
    ercDuplicateMemberLiteral: result := errDuplicateMemberLiteral;
  end;
end;

constructor eKlausError.create(aCode: integer; aLine, aPos: integer);
begin
  fCode := aCode;
  fLine := aLine;
  fPos := aPos;
  inherited create(getErrorMessage);
end;

constructor eKlausError.createFmt(aCode: integer; aLine, aPos: integer; const args: array of const);
begin
  fCode := aCode;
  fLine := aLine;
  fPos := aPos;
  inherited createFmt(getErrorMessage, args);
end;

constructor eKlausError.create(aCode: integer; p: tSrcPoint);
begin
  create(aCode, p.line, p.pos);
end;

constructor eKlausError.createFmt(aCode: integer; p: tSrcPoint; const args: array of const);
begin
  createFmt(aCode, p.line, p.pos, args);
end;

function eKlausError.toString: string;
begin
  Result := format(errAtLinePos, [className, line, pos, message]);
end;

end.

