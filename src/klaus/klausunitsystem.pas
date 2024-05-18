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
  klausSysProcName_Clear = 'очистить';
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
  klausSysProcName_CursorMove = 'подвинутьКурсор';
  klausSysProcName_CursorSave = 'запомнитьКурсор';
  klausSysProcName_CursorRestore = 'вернутьКурсор';
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
  klausSysProcName_FileExtractPath = 'файлПуть';
  klausSysProcName_FileExtractName = 'файлИмя';
  klausSysProcName_FileExtractExt = 'файлРасширение';
  klausSysProcName_FileHomeDir = 'файлДомКат';
  klausSysProcName_FileGetAttrs = 'файлАтрибуты';
  klausSysProcName_FileGetAge = 'файлВозраст';
  klausSysProcName_FileRename = 'файлПереместить';
  klausSysProcName_FileDelete = 'файлУдалить';
  klausSysProcName_FileFindFirst = 'файлПервый';
  klausSysProcName_FileFindNext = 'файлСледующий';
  klausSysProcName_GrWindowOpen = 'грОкно';
  klausSysProcName_GrDestroy = 'грУничтожить';
  klausSysProcName_GrSize = 'грРазмер';
  klausSysProcName_GrBeginPaint = 'грНачать';
  klausSysProcName_GrEndPaint = 'грЗакончить';
  klausSysProcName_GrPen = 'грПеро';
  klausSysProcName_GrBrush = 'грКисть';
  klausSysProcName_GrFont = 'грШрифт';
  klausSysProcName_GrClipRect = 'грОбрезка';
  klausSysProcName_GrPoint = 'грТочка';
  klausSysProcName_GrCircle = 'грКруг';
  klausSysProcName_GrEllipse = 'грЭллипс';
  klausSysProcName_GrArc = 'грДуга';
  klausSysProcName_GrSector = 'грСектор';
  klausSysProcName_GrChord = 'грСегмент';
  klausSysProcName_GrLine = 'грОтрезок';
  klausSysProcName_GrPolyLine = 'грЛоманая';
  klausSysProcName_GrRectangle = 'грПрямоугольник';
  klausSysProcName_GrPolygon = 'грМногоугольник';
  klausSysProcName_GrTextSize = 'грРазмерТекста';
  klausSysProcName_GrText = 'грТекст';
  klausSysProcName_GrImgLoad = 'грИзоЗагрузить';
  klausSysProcName_GrImgCreate = 'грИзоСоздать';
  klausSysProcName_GrImgSave = 'грИзоСохранить';
  klausSysProcName_GrImgDraw = 'грИзоВывести';
  klausSysProcName_EvtSubscribe = 'сбтЗаказать';
  klausSysProcName_EvtExists = 'сбтЕсть';
  klausSysProcName_EvtGet = 'сбтЗабрать';
  klausSysProcName_EvtCount = 'сбтСколько';
  klausSysProcName_EvtPeek = 'сбтСмотреть';

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
  klausConstName_StdOut = 'идСтдВывод';
  klausConstName_StdErr = 'идСтдСообщ';
  klausConstName_TermCanon = 'трКанон';
  klausConstName_TermDirect = 'трСквозной';
  klausConstName_FontBold = 'стшЖирный';
  klausConstName_FontItalic = 'стшКурсив';
  klausConstName_FontUnderline = 'стшПодчерк';
  klausConstName_FontStrikeOut = 'стшЗачерк';
  klausConstName_FileTypeText = 'фтТекст';
  klausConstName_FileTypeBinary = 'фтДвоичный';
  klausConstName_FileOpenRead = 'фрдЧтение';
  klausConstName_FileOpenWrite = 'фрдЗапись';
  klausConstName_FileShareExclusive = 'фcдИсключить';
  klausConstName_FileShareDenyWrite = 'фcдЧтение';
  klausConstName_FileShareDenyNone = 'фcдЛюбой';
  klausConstName_FilePosFromBeginning = 'фпОтНачала';
  klausConstName_FilePosFromEnd = 'фпОтКонца';
  klausConstName_FilePosFromCurrent = 'фпОтносительно';
  klausConstName_FileAttrReadOnly = 'фаТолькоЧтение';
  klausConstName_FileAttrHidden = 'фаСкрытый';
  klausConstName_FileAttrSystem = 'фаСистемный';
  klausConstName_FileAttrVolumeID = 'фаМеткаТома';
  klausConstName_FileAttrDirectory = 'фаКаталог';
  klausConstName_FileAttrArchive = 'фаАрхивный';
  klausConstName_FileAttrNormal = 'фаНормальный';
  klausConstName_FileAttrTemporary = 'фаВременный';
  klausConstName_FileAttrSymLink = 'фаСимвСсылка';
  klausConstName_FileAttrCompressed = 'фаСжатый';
  klausConstName_FileAttrEncrypted = 'фаШифрованный';
  klausConstName_FileAttrVirtual = 'фаВиртуальный';
  klausConstName_GrPenStyleClear = 'грспПусто';
  klausConstName_GrPenStyleSolid = 'грспЛиния';
  klausConstName_GrPenStyleDot = 'грспТочка';
  klausConstName_GrPenStyleDash = 'грспТире';
  klausConstName_GrPenStyleDashDot = 'грспТочкаТире';
  klausConstName_GrPenStyleDashDotDot = 'грсп2ТочкиТире';
  klausConstName_GrBrushStyleClear = 'грскПусто';
  klausConstName_GrBrushStyleSolid = 'грскЦвет';
  klausConstName_GrFontBold = 'грсшЖирный';
  klausConstName_GrFontItalic = 'грсшКурсив';
  klausConstName_GrFontUnderline = 'грсшПодчерк';
  klausConstName_GrFontStrikeOut = 'грсшЗачерк';
  klausConstName_EvtKeyDown = 'сбтКлНаж';
  klausConstName_EvtKeyUp = 'сбтКлОтп';
  klausConstName_EvtKeyChar = 'сбтКлСмв';
  klausConstName_EvtMouseDown = 'сбтМшНаж';
  klausConstName_EvtMouseUp = 'сбтМшОтп';
  klausConstName_EvtMouseWheel = 'сбтМшКлс';
  klausConstName_EvtEnter = 'сбтМшВх';
  klausConstName_EvtLeave = 'сбтМшВых';
  klausConstName_EvtMove = 'сбтМшДвг';
  klausConstName_KeyStateShift = 'сскШифт';
  klausConstName_KeyStateCtrl = 'сскКтрл';
  klausConstName_KeyStateAlt = 'сскАльт';
  klausConstName_KeyStateLeft = 'сскЛКМ';
  klausConstName_KeyStateRight = 'сскПКМ';
  klausConstName_KeyStateMiddle = 'сскСКМ';
  klausConstName_KeyStateDouble = 'сскДвКлик';

const
  klausTypeName_FileInfo = 'ФайлИнфо';
  klausTypeName_Point = 'Точка';
  klausTypeName_Point2 = 'Точки';
  klausTypeName_Point3 = 'Точек';
  klausTypeName_Size = 'Размер';
  klausTypeName_Size2 = 'Размеры';
  klausTypeName_Size3 = 'Размеров';
  klausTypeName_PointArray = 'МассивТочек';
  klausTypeName_PointArray2 = 'МассивыТочек';
  klausTypeName_PointArray3 = 'МассивовТочек';
  klausTypeName_Event = 'Событие';
  klausTypeName_Event2 = 'События';
  klausTypeName_Event3 = 'Событий';

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

function  klausStdError(frame: tKlausStackFrame; ksx: tKlausStdException; line, pos: integer): eKlausLangException;
function  klausStdError(frame: tKlausStackFrame; ksx: tKlausStdException; msg: string; line, pos: integer): eKlausLangException;
function  klausStdError(frame: tKlausStackFrame; ksx: tKlausStdexception; msg: string; const args: array of const; line, pos: integer): eKlausLangException;
procedure klausTranslateException(frame: tKlausStackFrame; const at: tSrcPoint);

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

resourcestring
  strKlausFileStream = 'Файл';
  strKlausFileSearch = 'Поиск файлов';
  strKlausCanvasLink = 'Холст';

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
    if (l = 0) and (p = 0) then begin
      l := at.line;
      p := at.pos;
    end;
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
  str: tKlausTypeDefStruct;
  arr: tKlausTypeDefArray;
begin
  // ФайлИнфо
  str := tKlausTypeDefStruct.create(source, zeroSrcPt);
  tKlausStructMember.create(str, 'имя', zeroSrcPt, source.simpleTypes[kdtString]);
  tKlausStructMember.create(str, 'размер', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'атрибуты', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'возраст', zeroSrcPt, source.simpleTypes[kdtMoment]);
  tKlausTypeDecl.create(self, [klausTypeName_FileInfo], zeroSrcPt, str);
  // Точка/Точки/Точек
  str := tKlausTypeDefStruct.create(source, zeroSrcPt);
  tKlausStructMember.create(str, 'г', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'в', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausTypeDecl.create(self, [klausTypeName_Point, klausTypeName_Point2, klausTypeName_Point3], zeroSrcPt, str);
  // Размер/Размеры/Размеров
  tKlausTypeDecl.create(self, [klausTypeName_Size, klausTypeName_Size2, klausTypeName_Size3], zeroSrcPt, str);
  // МассивТочек/МассивыТочек/МассивовТочек
  arr := tKlausTypeDefArray.create(source, zeroSrcPt, 1, str);
  tKlausTypeDecl.create(self, [klausTypeName_PointArray, klausTypeName_PointArray2, klausTypeName_PointArray3], zeroSrcPt, arr);
  // Событие/События/Событий
  str := tKlausTypeDefStruct.create(source, zeroSrcPt);
  tKlausStructMember.create(str, 'что', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'код', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'инфо', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'г', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'в', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausTypeDecl.create(self, [klausTypeName_Event, klausTypeName_Event2, klausTypeName_Event3], zeroSrcPt, str);
end;

procedure tKlausUnitSystem.createSystemVariables;
var
  dtString: tKlausTypeDef;
  dtStrArray: tKlausTypeDef;
begin
  dtString := source.simpleTypes[kdtString];
  dtStrArray := source.arrayTypes[kdtString];
  // константы
  tKlausConstDecl.create(self, klausConstName_Newline, zeroSrcPt, klausSimple(#13#10));
  tKlausConstDecl.create(self, klausConstName_Tab, zeroSrcPt, klausSimple(tKlausChar(#9)));
  tKlausConstDecl.create(self, klausConstName_CR, zeroSrcPt, klausSimple(tKlausChar(#13)));
  tKlausConstDecl.create(self, klausConstName_LF, zeroSrcPt, klausSimple(tKlausChar(#10)));
  tKlausConstDecl.create(self, klausConstName_EOF, zeroSrcPt, klausSimple(tKlausChar(#26)));
  tKlausConstDecl.create(self, klausConstName_MaxInt, zeroSrcPt, klausSimple(high(tKlausInteger)));
  tKlausConstDecl.create(self, klausConstName_MinInt, zeroSrcPt, klausSimple(low(tKlausInteger)));
  tKlausConstDecl.create(self, klausConstName_MaxFloat, zeroSrcPt, klausSimple(tKlausFloat(klausMaxFloat)));
  tKlausConstDecl.create(self, klausConstName_MinFloat, zeroSrcPt, klausSimple(tKlausFloat(klausMinFloat)));
  tKlausConstDecl.create(self, klausConstName_Pi, zeroSrcPt, klausSimple(tKlausFloat(Pi)));
  tKlausConstDecl.create(self, klausConstName_PiRus, zeroSrcPt, klausSimple(tKlausFloat(Pi)));
  tKlausConstDecl.create(self, klausConstName_StdOut, zeroSrcPt, klausSimple(tKlausInteger(klausConst_StdOut)));
  tKlausConstDecl.create(self, klausConstName_StdErr, zeroSrcPt, klausSimple(tKlausInteger(klausConst_StdErr)));
  tKlausConstDecl.create(self, klausConstName_TermCanon, zeroSrcPt, klausSimple(false));
  tKlausConstDecl.create(self, klausConstName_TermDirect, zeroSrcPt, klausSimple(true));
  tKlausConstDecl.create(self, klausConstName_FontBold, zeroSrcPt, klausSimple(tKlausInteger(klausConst_FontBold)));
  tKlausConstDecl.create(self, klausConstName_FontItalic, zeroSrcPt, klausSimple(tKlausInteger(klausConst_FontItalic)));
  tKlausConstDecl.create(self, klausConstName_FontUnderline, zeroSrcPt, klausSimple(tKlausInteger(klausConst_FontUnderline)));
  tKlausConstDecl.create(self, klausConstName_FontStrikeOut, zeroSrcPt, klausSimple(tKlausInteger(klausConst_FontStrikeOut)));
  tKlausConstDecl.create(self, klausConstName_FileTypeText, zeroSrcPt, klausSimple(tKlausInteger(klausFileTypeText)));
  tKlausConstDecl.create(self, klausConstName_FileTypeBinary, zeroSrcPt, klausSimple(tKlausInteger(klausFileTypeBinary)));
  tKlausConstDecl.create(self, klausConstName_FileOpenRead, zeroSrcPt, klausSimple(tKlausInteger(klausFileOpenRead)));
  tKlausConstDecl.create(self, klausConstName_FileOpenWrite, zeroSrcPt, klausSimple(tKlausInteger(klausFileOpenWrite)));
  tKlausConstDecl.create(self, klausConstName_FileShareExclusive, zeroSrcPt, klausSimple(tKlausInteger(klausFileShareExclusive)));
  tKlausConstDecl.create(self, klausConstName_FileShareDenyWrite, zeroSrcPt, klausSimple(tKlausInteger(klausFileShareDenyWrite)));
  tKlausConstDecl.create(self, klausConstName_FileShareDenyNone, zeroSrcPt, klausSimple(tKlausInteger(klausFileShareDenyNone)));
  tKlausConstDecl.create(self, klausConstName_FilePosFromBeginning, zeroSrcPt, klausSimple(tKlausInteger(klausFilePosFromBeginning)));
  tKlausConstDecl.create(self, klausConstName_FilePosFromEnd, zeroSrcPt, klausSimple(tKlausInteger(klausFilePosFromEnd)));
  tKlausConstDecl.create(self, klausConstName_FilePosFromCurrent, zeroSrcPt, klausSimple(tKlausInteger(klausFilePosFromCurrent)));
  tKlausConstDecl.create(self, klausConstName_FileAttrReadOnly, zeroSrcPt, klausSimple(tKlausInteger(faReadOnly)));
  tKlausConstDecl.create(self, klausConstName_GrPenStyleClear, zeroSrcPt, klausSimple(tKlausInteger(klausConst_psClear)));
  tKlausConstDecl.create(self, klausConstName_GrPenStyleSolid, zeroSrcPt, klausSimple(tKlausInteger(klausConst_psSolid)));
  tKlausConstDecl.create(self, klausConstName_GrPenStyleDot, zeroSrcPt, klausSimple(tKlausInteger(klausConst_psDot)));
  tKlausConstDecl.create(self, klausConstName_GrPenStyleDash, zeroSrcPt, klausSimple(tKlausInteger(klausConst_psDash)));
  tKlausConstDecl.create(self, klausConstName_GrPenStyleDashDot, zeroSrcPt, klausSimple(tKlausInteger(klausConst_psDashDot)));
  tKlausConstDecl.create(self, klausConstName_GrPenStyleDashDotDot, zeroSrcPt, klausSimple(tKlausInteger(klausConst_psDashDotDot)));
  tKlausConstDecl.create(self, klausConstName_GrBrushStyleClear, zeroSrcPt, klausSimple(tKlausInteger(klausConst_bsClear)));
  tKlausConstDecl.create(self, klausConstName_GrBrushStyleSolid, zeroSrcPt, klausSimple(tKlausInteger(klausConst_bsSolid)));
  tKlausConstDecl.create(self, klausConstName_GrFontBold, zeroSrcPt, klausSimple(tKlausInteger(klausConst_FontBold)));
  tKlausConstDecl.create(self, klausConstName_GrFontItalic, zeroSrcPt, klausSimple(tKlausInteger(klausConst_FontItalic)));
  tKlausConstDecl.create(self, klausConstName_GrFontUnderline, zeroSrcPt, klausSimple(tKlausInteger(klausConst_FontUnderline)));
  tKlausConstDecl.create(self, klausConstName_GrFontStrikeOut, zeroSrcPt, klausSimple(tKlausInteger(klausConst_FontStrikeOut)));
  tKlausConstDecl.create(self, klausConstName_EvtKeyDown, zeroSrcPt, klausSimple(tKlausInteger(klausConst_EvtKeyDown)));
  tKlausConstDecl.create(self, klausConstName_EvtKeyUp, zeroSrcPt, klausSimple(tKlausInteger(klausConst_EvtKeyUp)));
  tKlausConstDecl.create(self, klausConstName_EvtKeyChar, zeroSrcPt, klausSimple(tKlausInteger(klausConst_EvtKeyChar)));
  tKlausConstDecl.create(self, klausConstName_EvtMouseDown, zeroSrcPt, klausSimple(tKlausInteger(klausConst_EvtMouseDown)));
  tKlausConstDecl.create(self, klausConstName_EvtMouseUp, zeroSrcPt, klausSimple(tKlausInteger(klausConst_EvtMouseUp)));
  tKlausConstDecl.create(self, klausConstName_EvtMouseWheel, zeroSrcPt, klausSimple(tKlausInteger(klausConst_EvtMouseWheel)));
  tKlausConstDecl.create(self, klausConstName_EvtEnter, zeroSrcPt, klausSimple(tKlausInteger(klausConst_EvtMouseEnter)));
  tKlausConstDecl.create(self, klausConstName_EvtLeave, zeroSrcPt, klausSimple(tKlausInteger(klausConst_EvtMouseLeave)));
  tKlausConstDecl.create(self, klausConstName_EvtMove, zeroSrcPt, klausSimple(tKlausInteger(klausConst_EvtMouseMove)));
  tKlausConstDecl.create(self, klausConstName_KeyStateShift, zeroSrcPt, klausSimple(tKlausInteger(klausConst_KeyStateShift)));
  tKlausConstDecl.create(self, klausConstName_KeyStateCtrl, zeroSrcPt, klausSimple(tKlausInteger(klausConst_KeyStateCtrl)));
  tKlausConstDecl.create(self, klausConstName_KeyStateAlt, zeroSrcPt, klausSimple(tKlausInteger(klausConst_KeyStateAlt)));
  tKlausConstDecl.create(self, klausConstName_KeyStateLeft, zeroSrcPt, klausSimple(tKlausInteger(klausConst_KeyStateLeft)));
  tKlausConstDecl.create(self, klausConstName_KeyStateRight, zeroSrcPt, klausSimple(tKlausInteger(klausConst_KeyStateRight)));
  tKlausConstDecl.create(self, klausConstName_KeyStateMiddle, zeroSrcPt, klausSimple(tKlausInteger(klausConst_KeyStateMiddle)));
  tKlausConstDecl.create(self, klausConstName_KeyStateDouble, zeroSrcPt, klausSimple(tKlausInteger(klausConst_KeyStateDouble)));
  {$push}{$warnings off}
  tKlausConstDecl.create(self, klausConstName_FileAttrHidden, zeroSrcPt, klausSimple(tKlausInteger(faHidden)));
  tKlausConstDecl.create(self, klausConstName_FileAttrSystem, zeroSrcPt, klausSimple(tKlausInteger(faSysFile)));
  tKlausConstDecl.create(self, klausConstName_FileAttrVolumeID, zeroSrcPt, klausSimple(tKlausInteger(faVolumeID)));
  tKlausConstDecl.create(self, klausConstName_FileAttrDirectory, zeroSrcPt, klausSimple(tKlausInteger(faDirectory)));
  tKlausConstDecl.create(self, klausConstName_FileAttrArchive, zeroSrcPt, klausSimple(tKlausInteger(faArchive)));
  tKlausConstDecl.create(self, klausConstName_FileAttrNormal, zeroSrcPt, klausSimple(tKlausInteger(faNormal)));
  tKlausConstDecl.create(self, klausConstName_FileAttrTemporary, zeroSrcPt, klausSimple(tKlausInteger(faTemporary)));
  tKlausConstDecl.create(self, klausConstName_FileAttrSymLink, zeroSrcPt, klausSimple(tKlausInteger(faSymLink)));
  tKlausConstDecl.create(self, klausConstName_FileAttrCompressed, zeroSrcPt, klausSimple(tKlausInteger(faCompressed)));
  tKlausConstDecl.create(self, klausConstName_FileAttrEncrypted, zeroSrcPt, klausSimple(tKlausInteger(faEncrypted)));
  tKlausConstDecl.create(self, klausConstName_FileAttrVirtual, zeroSrcPt, klausSimple(tKlausInteger(faVirtual)));
  {$pop}
  // имя исполняемого файла
  tKlausVarDecl.create(self, klausVarName_ExecFilename, zeroSrcPt, dtString, nil);
  // аргументы командной строки
  tKlausVarDecl.create(self, klausVarName_CmdLineParams, zeroSrcPt, dtStrArray, nil);
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
  tKlausSysProc_CursorMove.create(self, zeroSrcPt);
  tKlausSysProc_CursorSave.create(self, zeroSrcPt);
  tKlausSysProc_CursorRestore.create(self, zeroSrcPt);
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
  tKlausSysProc_FileExtractPath.create(self, zeroSrcPt);
  tKlausSysProc_FileExtractName.create(self, zeroSrcPt);
  tKlausSysProc_FileExtractExt.create(self, zeroSrcPt);
  tKlausSysProc_FileHomeDir.create(self, zeroSrcPt);
  tKlausSysProc_FileGetAttrs.create(self, zeroSrcPt);
  tKlausSysProc_FileGetAge.create(self, zeroSrcPt);
  tKlausSysProc_FileRename.create(self, zeroSrcPt);
  tKlausSysProc_FileDelete.create(self, zeroSrcPt);
  tKlausSysProc_FileFindFirst.create(self, zeroSrcPt);
  tKlausSysProc_FileFindNext.create(self, zeroSrcPt);
  tKlausSysProc_GrWindowOpen.create(self, zeroSrcPt);
  tKlausSysProc_GrDestroy.create(self, zeroSrcPt);
  tKlausSysProc_GrSize.create(self, zeroSrcPt);
  tKlausSysProc_GrBeginPaint.create(self, zeroSrcPt);
  tKlausSysProc_GrEndPaint.create(self, zeroSrcPt);
  tKlausSysProc_GrPen.create(self, zeroSrcPt);
  tKlausSysProc_GrBrush.create(self, zeroSrcPt);
  tKlausSysProc_GrFont.create(self, zeroSrcPt);
  tKlausSysProc_GrCircle.create(self, zeroSrcPt);
  tKlausSysProc_GrEllipse.create(self, zeroSrcPt);
  tKlausSysProc_GrArc.create(self, zeroSrcPt);
  tKlausSysProc_GrSector.create(self, zeroSrcPt);
  tKlausSysProc_GrChord.create(self, zeroSrcPt);
  tKlausSysProc_GrLine.create(self, zeroSrcPt);
  tKlausSysProc_GrPolyLine.create(self, zeroSrcPt);
  tKlausSysProc_GrRectangle.create(self, zeroSrcPt);
  tKlausSysProc_GrPolygon.create(self, zeroSrcPt);
  tKlausSysProc_GrPoint.create(self, zeroSrcPt);
  tKlausSysProc_GrTextSize.create(self, zeroSrcPt);
  tKlausSysProc_GrText.create(self, zeroSrcPt);
  tKlausSysProc_GrClipRect.create(self, zeroSrcPt);
  tKlausSysProc_GrImgLoad.create(self, zeroSrcPt);
  tKlausSysProc_GrImgCreate.create(self, zeroSrcPt);
  tKlausSysProc_GrImgSave.create(self, zeroSrcPt);
  tKlausSysProc_GrImgDraw.create(self, zeroSrcPt);
  tKlausSysProc_EvtSubscribe.create(self, zeroSrcPt);
  tKlausSysProc_EvtExists.create(self, zeroSrcPt);
  tKlausSysProc_EvtGet.create(self, zeroSrcPt);
  tKlausSysProc_EvtCount.create(self, zeroSrcPt);
  tKlausSysProc_EvtPeek.create(self, zeroSrcPt);
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
  v := frame.varByName(klausVarName_ExecFilename, point);
  (v.value as tKlausVarValueSimple).setSimple(klausSimple(fileName), zeroSrcPt);
  // аргументы командной строки
  v := frame.varByName(klausVarName_CmdLineParams, point);
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
  tKlausObjects.registerKlausObject(tKlausFileStream, strKlausFileStream);
  tKlausObjects.registerKlausObject(tKlausFileSearch, strKlausFileSearch);
  tKlausObjects.registerKlausObject(tKlausCanvasLink, strKlausCanvasLink);
end.


