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
  klausSysProcName_Destroy = 'уничтожить';
  klausSysProcName_ReadLn = 'ввести';
  klausSysProcName_Write = 'вывести';
  klausSysProcName_Report = 'сообщить';
  klausSysProcName_Date = 'дата';
  klausSysProcName_Time = 'время';
  klausSysProcName_Now = 'сейчас';
  klausSysProcName_exceptionName = 'имя_исключения';
  klausSysProcName_exceptionText = 'текст_исключения';
  klausSysProcName_Length = 'длина';
  klausSysProcName_Char = 'симв';
  klausSysProcName_Next = 'след';
  klausSysProcName_Prev = 'пред';
  klausSysProcName_Part = 'часть';
  klausSysProcName_Add = 'добавить';
  klausSysProcName_Insert = 'вставить';
  klausSysProcName_Delete = 'удалить';
  klausSysProcName_Overwrite = 'вписать';
  klausSysProcName_Find = 'найти';
  klausSysProcName_Replace = 'заменить';
  klausSysProcName_Format = 'формат';
  klausSysProcName_Upper = 'загл';
  klausSysProcName_Lower = 'строч';
  klausSysProcName_IsNaN = 'нечисло';
  klausSysProcName_IsFinite = 'конечно';
  klausSysProcName_Round = 'округл';
  klausSysProcName_Int = 'цел';
  klausSysProcName_Frac = 'дроб';
  klausSysProcName_Sin = 'sin';
  klausSysProcName_Cos = 'cos';
  klausSysProcName_Tan = 'tg';
  klausSysProcName_ArcSin = 'arcsin';
  klausSysProcName_ArcCos = 'arccos';
  klausSysProcName_ArcTan = 'arctg';
  klausSysProcName_Ln = 'ln';
  klausSysProcName_Exp = 'exp';
  klausSysProcName_Delay = 'пауза';
  klausSysProcName_Random = 'случайное';
  klausSysProcName_Terminal = 'терминал';
  klausSysProcName_SetScreenSize = 'размерЭкрана';
  klausSysProcName_ClearScreen = 'очиститьЭкран';
  klausSysProcName_ClearLine = 'очиститьСтроку';
  klausSysProcName_SetCursorPos = 'курсор';
  klausSysProcName_SetCursorPosVert = 'курсорВерт';
  klausSysProcName_SetCursorPosHorz = 'курсорГорз';
  klausSysProcName_HideCursor = 'скрытьКурсор';
  klausSysProcName_ShowCursor = 'показатьКурсор';
  klausSysProcName_BackColor = 'цветФона';
  klausSysProcName_FontColor = 'цветШрифта';
  klausSysProcName_FontStyle = 'стильШрифта';
  klausSysProcName_Color256 = 'цвет256';
  klausSysProcName_ResetTextAttr = 'сброситьАтрибуты';
  klausSysProcName_InputAvailable = 'естьСимвол';
  klausSysProcName_ReadChar = 'прочестьСимвол';
  klausSysProcName_FileCreate = 'файлСоздать';
  klausSysProcName_FileOpen = 'файлОткрыть';
  klausSysProcName_FileClose = 'файлЗакрыть';
  klausSysProcName_FileSize = 'файлРазмер';
  klausSysProcName_FilePos = 'файлПоз';
  klausSysProcName_FileRead = 'файлПрочесть';
  klausSysProcName_FileWrite = 'файлЗаписать';
  klausSysProcName_FileExists = 'файлЕсть';
  klausSysProcName_FileDirExists = 'файлЕстьКат';
  klausSysProcName_FileTempDir = 'файлВрмКат';
  klausSysProcName_FileTempName = 'файлВрмИмя';
  klausSysProcName_FileExpandName = 'файлПолныйПуть';
  klausSysProcName_FileProgName = 'файлВыполняемый';
  klausSysProcName_FileHomeDir = 'файлДомКат';
  klausSysProcName_FileGetAttrs = 'файлАтрибуты';
  klausSysProcName_FileGetAge = 'файлВозраст';
  klausSysProcName_FileRename = 'файлПереместить';
  klausSysProcName_FileDelete = 'файлУдалить';
  klausSysProcName_FileFindFirst = 'файлПервый';
  klausSysProcName_FileFindNext = 'файлСледующий';

const
  klausConstNameNewline = 'НС';
  klausConstNameTab = 'Таб';
  klausConstNameEOF = 'КФ';
  klausConstNameCR = 'ВК';
  klausConstNameLF = 'ПС';
  klausConstNameMinInt = 'минЦелое';
  klausConstNameMaxInt = 'максЦелое';
  klausConstNameMinFloat = 'минДробное';
  klausConstNameMaxFloat = 'максДробное';
  klausConstNamePi = 'Pi';
  klausConstNamePiRus = 'Пи';
  klausConstFileTypeText = 'фтТекст';
  klausConstFileTypeBinary = 'фтДвоичный';
  klausConstFileOpenRead = 'фрдЧтение';
  klausConstFileOpenWrite = 'фрдЗапись';
  klausConstFileShareExclusive = 'фcдИсключить';
  klausConstFileShareDenyWrite = 'фcдЧтение';
  klausConstFileShareDenyNone = 'фcдЛюбой';
  klausConstFilePosFromBeginning = 'фпОтНачала';
  klausConstFilePosFromEnd = 'фпОтКонца';
  klausConstFilePosFromCurrent = 'фпОтносительно';
  klausConstFileAttrReadOnly = 'фаТолькоЧтение';
  klausConstFileAttrHidden = 'фаСкрытый';
  klausConstFileAttrSystem = 'фаСистемный';
  klausConstFileAttrVolumeID = 'фаМеткаТома';
  klausConstFileAttrDirectory = 'фаКаталог';
  klausConstFileAttrArchive = 'фаАрхивный';
  klausConstFileAttrNormal = 'фаНормальный';
  klausConstFileAttrTemporary = 'фаВременный';
  klausConstFileAttrSymLink = 'фаСимвСсылка';
  klausConstFileAttrCompressed = 'фаСжатый';
  klausConstFileAttrEncrypted = 'фаШифрованный';
  klausConstFileAttrVirtual = 'фаВиртуальный';

const
  klausTypeNameFileInfo = 'ФайлИнфо';

const
  klausVarNameCmdLineParams = '$cmdLineParams';
  klausVarNameExecFilename = '$execFileName';

var
  globalErrorInfo: record
    name: string;
    text: string;
  end = (name: ''; text: '');

type
  // Встроенный модуль, содержащий системные определения и подпрограммы.
  // Запускается в корневом фрейме стека при запуске программы.
  tKlausUnitSystem = class(tKlausUnit)
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
      function  getHidden: boolean; override;
      procedure beforeInit(frame: tKlausStackFrame); override;
    public
      property fileName: string read fFileName write fFileName;
      property args: tStrings read fArgs write setArgs;

      constructor create(aSource: tKlausSource);
      destructor  destroy; override;
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

function  klausStdError(frame: tKlausStackFrame; ksx: tKlausStdException; line, pos: integer): eKlausLangException;
function  klausStdError(frame: tKlausStackFrame; ksx: tKlausStdException; msg: string; line, pos: integer): eKlausLangException;
function  klausStdError(frame: tKlausStackFrame; ksx: tKlausStdexception; msg: string; const args: array of const; line, pos: integer): eKlausLangException;
procedure klausTranslateException(frame: tKlausStackFrame; const at: tSrcPoint);

implementation

uses KlausUtils, KlausUnitSystem_Proc;

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

function klausStdError(frame: tKlausStackFrame; ksx: tKlausStdException; line, pos: integer): eKlausLangException;
begin
  result := klausStdError(frame, ksx, '', [], line, pos);
end;

function klausStdError(frame: tKlausStackFrame; ksx: tKlausStdException; msg: string; line, pos: integer): eKlausLangException;
begin
  result := klausStdError(frame, ksx, msg, [], line, pos);
end;

function klausStdError(frame: tKlausStackFrame; ksx: tKlausStdException; msg: string; const args: array of const; line, pos: integer): eKlausLangException;
var
  d: tKlausExceptDecl;
begin
  d := (frame.owner.source.systemUnit as tKlausUnitSystem).fStdErrors[ksx];
  if msg = '' then msg := d.message;
  if msg = '' then msg := d.name;
  msg := format(msg, args);
  result := eKlausLangException.create(msg, d, nil, line, pos);
end;

procedure klausTranslateException(frame: tKlausStackFrame; const at: tSrcPoint);
var
  obj: tObject;
  l, p: integer;
  ksx: tKlausStdException;
begin
  if exceptObject = nil then exit;
  obj := tObject(acquireExceptionObject);
  if obj is eKlausLangException then
    raise obj at get_caller_addr(get_frame)
  else if obj is eKlausError then begin
    releaseExceptionObject;
    l := (obj as eKlausError).line;
    p := (obj as eKlausError).pos;
    for ksx := low(ksx) to high(ksx) do
      if (obj as eKlausError).code in klausCodeToStdErr[ksx] then
        raise klausStdError(frame, ksx, (obj as exception).message, l, p) at get_caller_addr(get_frame);
    raise klausStdError(frame, ksxInternalError, (obj as exception).message, l, p) at get_caller_addr(get_frame);
  end else if obj is eControlC then begin
    releaseExceptionObject;
    raise eKlausHalt.create(-1) at get_caller_addr(get_frame)
  end else if (obj is eExternal)
  or (obj is EHeapMemoryError)
  or (obj is eOSError) then begin
    releaseExceptionObject;
    raise klausStdError(frame, ksxRuntimeError, (obj as exception).message, at.line, at.pos) at get_caller_addr(get_frame)
  end else if obj is eAssertionFailed then begin
    releaseExceptionObject;
    raise klausStdError(frame, ksxInternalError, (obj as exception).message, at.line, at.pos) at get_caller_addr(get_frame)
  end else if obj is eConvertError then begin
    releaseExceptionObject;
    raise klausStdError(frame, ksxConvertError, (obj as exception).message, at.line, at.pos) at get_caller_addr(get_frame)
  end else if (obj is eDirectoryNotFoundException)
  or (obj is eFileNotFoundException)
  or (obj is ePathNotFoundException)
  or (obj is ePathTooLongException)
  or (obj is eInOutError)
  or (obj is eStreamError) then begin
    releaseExceptionObject;
    raise klausStdError(frame, ksxInOutError, (obj as exception).message, at.line, at.pos) at get_caller_addr(get_frame)
  end else if obj is eFormatError then begin
    releaseExceptionObject;
    raise klausStdError(frame, ksxConvertError, (obj as exception).message, at.line, at.pos) at get_caller_addr(get_frame)
  end else
    raise obj at get_caller_addr(get_frame);
end;

{ tKlausUnitSystem }

constructor tKlausUnitSystem.create(aSource: tKlausSource);
begin
  inherited create(aSource, klausUnitName_System, zeroSrcPt);
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
var
  def: tKlausTypeDefStruct;
begin
  // ФайлИнфо
  def := tKlausTypeDefStruct.create(source, zeroSrcPt);
  tKlausStructMember.create(def, 'имя', zeroSrcPt, source.simpleTypes[kdtString]);
  tKlausStructMember.create(def, 'размер', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(def, 'атрибуты', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(def, 'возраст', zeroSrcPt, source.simpleTypes[kdtMoment]);
  tKlausTypeDecl.create(self, [klausTypeNameFileInfo], zeroSrcPt, def);
end;

procedure tKlausUnitSystem.createSystemVariables;
var
  dtString: tKlausTypeDef;
  dtStrArray: tKlausTypeDef;
begin
  dtString := source.simpleTypes[kdtString];
  dtStrArray := source.arrayTypes[kdtString];
  // константы
  tKlausConstDecl.create(self, klausConstNameNewline, zeroSrcPt, klausSimple(#13#10));
  tKlausConstDecl.create(self, klausConstNameTab, zeroSrcPt, klausSimple(tKlausChar(#9)));
  tKlausConstDecl.create(self, klausConstNameCR, zeroSrcPt, klausSimple(tKlausChar(#13)));
  tKlausConstDecl.create(self, klausConstNameLF, zeroSrcPt, klausSimple(tKlausChar(#10)));
  tKlausConstDecl.create(self, klausConstNameEOF, zeroSrcPt, klausSimple(tKlausChar(#26)));
  tKlausConstDecl.create(self, klausConstNameMaxInt, zeroSrcPt, klausSimple(high(tKlausInteger)));
  tKlausConstDecl.create(self, klausConstNameMinInt, zeroSrcPt, klausSimple(low(tKlausInteger)));
  tKlausConstDecl.create(self, klausConstNameMaxFloat, zeroSrcPt, klausSimple(klausMaxFloat));
  tKlausConstDecl.create(self, klausConstNameMinFloat, zeroSrcPt, klausSimple(klausMinFloat));
  tKlausConstDecl.create(self, klausConstNamePi, zeroSrcPt, klausSimple(tKlausFloat(Pi)));
  tKlausConstDecl.create(self, klausConstNamePiRus, zeroSrcPt, klausSimple(tKlausFloat(Pi)));
  tKlausConstDecl.create(self, klausConstFileTypeText, zeroSrcPt, klausSimple(klausFileTypeText));
  tKlausConstDecl.create(self, klausConstFileTypeBinary, zeroSrcPt, klausSimple(klausFileTypeBinary));
  tKlausConstDecl.create(self, klausConstFileOpenRead, zeroSrcPt, klausSimple(klausFileOpenRead));
  tKlausConstDecl.create(self, klausConstFileOpenWrite, zeroSrcPt, klausSimple(klausFileOpenWrite));
  tKlausConstDecl.create(self, klausConstFileShareExclusive, zeroSrcPt, klausSimple(klausFileShareExclusive));
  tKlausConstDecl.create(self, klausConstFileShareDenyWrite, zeroSrcPt, klausSimple(klausFileShareDenyWrite));
  tKlausConstDecl.create(self, klausConstFileShareDenyNone, zeroSrcPt, klausSimple(klausFileShareDenyNone));
  tKlausConstDecl.create(self, klausConstFilePosFromBeginning, zeroSrcPt, klausSimple(klausFilePosFromBeginning));
  tKlausConstDecl.create(self, klausConstFilePosFromEnd, zeroSrcPt, klausSimple(klausFilePosFromEnd));
  tKlausConstDecl.create(self, klausConstFilePosFromCurrent, zeroSrcPt, klausSimple(klausFilePosFromCurrent));
  tKlausConstDecl.create(self, klausConstFileAttrReadOnly, zeroSrcPt, klausSimple(tKlausInteger(faReadOnly)));
  {$push}{$warnings off}
  tKlausConstDecl.create(self, klausConstFileAttrHidden, zeroSrcPt, klausSimple(tKlausInteger(faHidden)));
  tKlausConstDecl.create(self, klausConstFileAttrSystem, zeroSrcPt, klausSimple(tKlausInteger(faSysFile)));
  tKlausConstDecl.create(self, klausConstFileAttrVolumeID, zeroSrcPt, klausSimple(tKlausInteger(faVolumeID)));
  tKlausConstDecl.create(self, klausConstFileAttrDirectory, zeroSrcPt, klausSimple(tKlausInteger(faDirectory)));
  tKlausConstDecl.create(self, klausConstFileAttrArchive, zeroSrcPt, klausSimple(tKlausInteger(faArchive)));
  tKlausConstDecl.create(self, klausConstFileAttrNormal, zeroSrcPt, klausSimple(tKlausInteger(faNormal)));
  tKlausConstDecl.create(self, klausConstFileAttrTemporary, zeroSrcPt, klausSimple(tKlausInteger(faTemporary)));
  tKlausConstDecl.create(self, klausConstFileAttrSymLink, zeroSrcPt, klausSimple(tKlausInteger(faSymLink)));
  tKlausConstDecl.create(self, klausConstFileAttrCompressed, zeroSrcPt, klausSimple(tKlausInteger(faCompressed)));
  tKlausConstDecl.create(self, klausConstFileAttrEncrypted, zeroSrcPt, klausSimple(tKlausInteger(faEncrypted)));
  tKlausConstDecl.create(self, klausConstFileAttrVirtual, zeroSrcPt, klausSimple(tKlausInteger(faVirtual)));
  {$pop}
  // имя исполняемого файла
  tKlausVarDecl.create(self, klausVarNameExecFilename, zeroSrcPt, dtString, klausZeroValue(kdtString));
  // аргументы командной строки
  tKlausVarDecl.create(self, klausVarNameCmdLineParams, zeroSrcPt, dtStrArray, klausZeroValue(kdtString));
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
  tKlausSysProc_Terminal.create(self, zeroSrcPt);
  tKlausSysProc_SetScreenSize.create(self, zeroSrcPt);
  tKlausSysProc_ClearScreen.create(self, zeroSrcPt);
  tKlausSysProc_ClearLine.create(self, zeroSrcPt);
  tKlausSysProc_SetCursorPos.create(self, zeroSrcPt);
  tKlausSysProc_SetCursorPosVert.create(self, zeroSrcPt);
  tKlausSysProc_SetCursorPosHorz.create(self, zeroSrcPt);
  tKlausSysProc_ShowCursor.create(self, zeroSrcPt);
  tKlausSysProc_HideCursor.create(self, zeroSrcPt);
  tKlausSysProc_BackColor.create(self, zeroSrcPt);
  tKlausSysProc_FontColor.create(self, zeroSrcPt);
  tKlausSysProc_FontStyle.create(self, zeroSrcPt);
  tKlausSysProc_Color256.create(self, zeroSrcPt);
  tKlausSysProc_ResetTextAttr.create(self, zeroSrcPt);
  tKlausSysProc_InputAvailable.create(self, zeroSrcPt);
  tKlausSysProc_ReadChar.create(self, zeroSrcPt);
  tKlausSysProc_Random.create(self, zeroSrcPt);
  tKlausSysProc_FileCreate.create(self, zeroSrcPt);
  tKlausSysProc_FileOpen.create(self, zeroSrcPt);
  tKlausSysProc_FileClose.create(self, zeroSrcPt);
  tKlausSysProc_FileWrite.create(self, zeroSrcPt);
  tKlausSysProc_FileRead.create(self, zeroSrcPt);
  tKlausSysProc_FilePos.create(self, zeroSrcPt);
  tKlausSysProc_FileExists.create(self, zeroSrcPt);
  tKlausSysProc_FileDirExists.create(self, zeroSrcPt);
  tKlausSysProc_FileTempDir.create(self, zeroSrcPt);
  tKlausSysProc_FileTempName.create(self, zeroSrcPt);
  tKlausSysProc_FileExpandName.create(self, zeroSrcPt);
  tKlausSysProc_FileProgName.create(self, zeroSrcPt);
  tKlausSysProc_FileHomeDir.create(self, zeroSrcPt);
  tKlausSysProc_FileGetAttrs.create(self, zeroSrcPt);
  tKlausSysProc_FileGetAge.create(self, zeroSrcPt);
  tKlausSysProc_FileRename.create(self, zeroSrcPt);
  tKlausSysProc_FileDelete.create(self, zeroSrcPt);
  tKlausSysProc_FileFindFirst.create(self, zeroSrcPt);
  tKlausSysProc_FileFindNext.create(self, zeroSrcPt);
end;

procedure tKlausUnitSystem.setArgs(val: tStrings);
begin
  if val = nil then fArgs.clear
  else fArgs.assign(val);
end;

function tKlausUnitSystem.getHidden: boolean;
begin
  result := true;
end;

procedure tKlausUnitSystem.beforeInit(frame: tKlausStackFrame);
var
  i: integer;
  v: tKlausVariable;
  vv: tKlausVarValueSimple;
begin
  inherited;
  // имя исполняемого файла
  v := frame.varByName(klausVarNameExecFilename, point);
  (v.value as tKlausVarValueSimple).setSimple(klausSimple(fileName), zeroSrcPt);
  // аргументы командной строки
  v := frame.varByName(klausVarNameCmdLineParams, point);
  for i := 0 to fArgs.count-1 do begin
    vv := tKlausVarValueSimple.create(source.simpleTypes[kdtString]);
    vv.setSimple(klausSimple(fArgs[i]), zeroSrcPt);
    (v.value as tKlausVarValueArray).insert(i, vv, zeroSrcPt);
  end;
end;

{ tKlausSysProcDecl }

procedure tKlausSysProcDecl.declareRetValue(dt: tKlausSimpleType);
begin
  assert(retValue = nil, 'Internal function return value already declared');
  setRetValue(tKlausProcParam.create(self, '', point, kpmOutput, source.simpleTypes[dt]));
end;

procedure tKlausSysProcDecl.returnSimple(frame: tKlausStackFrame; rslt: tKlausSimpleValue);
begin
  assert(retValue <> nil, 'Internal procedure cannot return a value');
  (frame.varByDecl(retValue, point).value as tKlausVarValueSimple).setSimple(rslt, point);
end;

function tKlausSysProcDecl.findTypeDef(const typeName: string): tKlausTypeDef;
begin
  result := (find(typeName, knsGlobal) as tKlausTypeDecl).dataType;
end;

procedure tKlausSysProcDecl.errWrongParamCount(given, min, max: integer; const at: tSrcPoint);
var
  s: string;
begin
  if min = max then s := intToStr(min)
  else if max < 0 then s := format(strAtLeast, [min])
  else s := format(strFromTo, [min, max]);
  raise eKlausError.createFmt(ercWrongNumberOfParams, at.line, at.pos, [given, s])
  at get_caller_addr(get_frame);
end;

procedure tKlausSysProcDecl.errTypeMismatch(const at: tSrcPoint);
begin
  raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
  at get_caller_addr(get_frame);
end;

procedure tKlausSysProcDecl.checkCanAssign(dst: tKlausSimpleType; src: tKlausTypeDef; const at: tSrcPoint; strict: boolean = false);
begin
  if not source.simpleTypes[dst].canAssign(src, strict) then
    raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
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
    raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
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
      raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
      at get_caller_addr(get_frame);
  end else if dst is tKlausTypeDefDict then begin
    kt := (dst as tKlausTypeDefDict).keyType;
    if not source.simpleTypes[kt].canAssign(key, strict) then
      raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
      at get_caller_addr(get_frame);
  end else
    raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
    at get_caller_addr(get_frame);
end;

procedure tKlausSysProcDecl.checkKeyType(dst, key: tKlausVarValue; const at: tSrcPoint; strict: boolean = false);
var
  kt: tKlausSimpleType;
begin
  if dst is tKlausVarValueArray then begin
    if not source.simpleTypes[kdtInteger].canAssign(key.dataType, strict) then
      raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
      at get_caller_addr(get_frame);
  end else if dst is tKlausVarValueDict then begin
    kt := (dst.dataType as tKlausTypeDefDict).keyType;
    if not source.simpleTypes[kt].canAssign(key.dataType, strict) then
      raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
      at get_caller_addr(get_frame);
  end else
    raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
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
    raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
    at get_caller_addr(get_frame);
  if not et.canAssign(elmt, strict) then
    raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
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
    raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
    at get_caller_addr(get_frame);
  if not et.canAssign(elmt.dataType, strict) then
    raise eKlausError.create(ercTypeMismatch, at.line, at.pos)
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
  (v as tKlausVarValueSimple).setSimple(klausSimple(val), at);
end;

procedure tKlausSysProcDecl.setSimpleStr(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausString; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimple(val), at);
end;

procedure tKlausSysProcDecl.setSimpleInt(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausInteger; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimple(val), at);
end;

procedure tKlausSysProcDecl.setSimpleFloat(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausFloat; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimple(val), at);
end;

procedure tKlausSysProcDecl.setSimpleMoment(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausMoment; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimple(val), at);
end;

procedure tKlausSysProcDecl.setSimpleBool(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausBoolean; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimple(val), at);
end;

procedure tKlausSysProcDecl.setSimpleObj(frame: tKlausStackFrame; vd: tKlausVarDecl; const val: tKlausObject; const at: tSrcPoint);
var
  v: tKlausVarValue;
begin
  v := frame.varByDecl(vd, at).value;
  if not (v is tKlausVarValueSimple) then
    raise eKlausError.create(ercTypeMismatch, at)
    at get_caller_addr(get_frame);
  (v as tKlausVarValueSimple).setSimple(klausSimple(val), at);
end;

function tKlausSysProcDecl.getKlausObject(frame: tKlausStackFrame; h: tKlausObject; cls: tClass; const at: tSrcPoint): tObject;
begin
  result := frame.owner.objects.get(h, at);
  if not (result is cls) then raise eKlausError.createFmt(ercUnexpectedObjectClass, at, [cls.className, result.className]);
end;

end.


