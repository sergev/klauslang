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

unit KlausUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Graphics, FpJson, {$ifdef klauside}IpHTML, Markdown,{$endif}
  {$ifdef windows}Windows,{$else}BaseUnix, TermIO,{$endif}
  SysUtils, U8, KlausLex, KlausDef, KlausErr;

const
  klausInvalidPointer = pointer(ptrInt(-1));

// Устанавливает длину переданной строки. Если новая длина больше старой, заполняет хвост
// строки пробелами. Если меньше, до переданная длина должна быть такой, чтобы последний символ
// в строке не оказался разбит на части, иначе будет ошибка НеверныйСимвол.
// Возвращает новую длину строки.
function klstrSetLength(var s: tKlausString; len: tKlausInteger; const at: tSrcPoint): tKlausInteger;

// Вставляет подстроку substr перед указанным байтом строки s.
// Позиция, переданная в idx, определяет номер байта от начала строки, начиная с нуля.
// В указанной позиции должно находиться начало символа UTF-8, иначе будет ошибка НеверныйСимвол.
procedure klstrInsert(var s: tKlausString; idx: tKlausInteger; const substr: tKlausString; const at: tSrcPoint);

// Удаляет из s указанное кол-во байт, начиная с указанного байта.
// Позиция, переданная в idx, определяет номер байта от начала строки, начиная с нуля.
// В указанной позиции, а также в позиции, следующей за окончанием удаляемого фрагмента,
// должны находиться начала символов UTF-8, иначе будет ошибка НеверныйСимвол.
procedure klstrDelete(var s: tKlausString; idx, count: tKlausInteger; const at: tSrcPoint);

// Копирует в s по указанному индексу len байт из src, начиная с from.
// Позиция, переданная в idx, должна соответствовать началу символа в строке s; позиция,
// переданная во from, должна соответствовать началу символа в строке src; значение len
// должно быть таким, чтобы последний скопированный из src символ не оказался разбит на части
// -- в противном случае будет ошибка НеверныйСимвол.
// Байты в строке s перезаписываются новыми байтами из src. Если копируемые данные не влезают
// в строку s, то её длина будет увеличена до необходимой.
procedure klstrOverwrite(
  var s: tKlausString; idx: tKlausInteger; const src: tKlausString; from, len: tKlausInteger; const at: tSrcPoint);

// Заменяет count байт в строке s, начиная от idx, байтами из строки repl. Длина строки
// изменяется соответственно. Значения idx и count должны быть такими, чтобы никакие символы
// не оказались при замене разбиты на части, иначе будет исключение НеверныйСимвол.
procedure klstrReplace(
  var s: tKlausString; idx, count: tKlausInteger; const repl: tKlausString; const at: tSrcPoint);

// Возвращает символ (кодпойнт Unicode), расположенный в указанной позиции переданной строки.
// В указанной позиции должно быть начало символа UTF-8, иначе будет ошибка НеверныйСимвол.
function klstrChar(const s: tKlausString; idx: tKlausInteger; const at: tSrcPoint): tKlausChar;

// Возвращает подстроку из строки s длиной count байт, начиная с байта, переданного в idx.
// Если в строке не хватило байтов, возвращает подстроку от idx до конца строки.
// В указанной позиции, а также в позиции, следующей за окончанием копируемого фрагмента,
// должны находиться начала символов UTF-8, иначе будет ошибка НеверныйСимвол.
function klstrPart(
  const s: tKlausString; idx, count: tKlausInteger; const at: tSrcPoint): tKlausString;

// Возвращает позицию в строке s, смещённую вправо на count кодпойнтов, начиная с переданной
// позиции idx. Если кодпойнтов в строке не хватило, возвращает длину строки.
// Записывает в chars количество фактически посчитанных кодпойнтов.
// В указанной позиции должно быть начало символа UTF-8, иначе будет ошибка НеверныйСимвол.
function klstrNext(
  const s: tKlausString; idx, count: tKlausInteger;
  out chars: tKlausInteger; const at: tSrcPoint): tKlausInteger;

// Возвращает позицию в строке s, смещённую влево на count кодпойнтов,
// начиная с переданной позиции idx. Если кодпойнтов в строке не хватило, возвращает 0.
// Записывает в chars количество фактически посчитанных кодпойнтов.
// В указанной позиции должно быть начало символа UTF-8, иначе будет ошибка НеверныйСимвол.
function klstrPrev(
  const s: tKlausString; idx, count: tKlausInteger;
  out chars: tKlausInteger; const at: tSrcPoint): tKlausInteger;

// Возвращает строку, отформатированную переданными аргументами.
function klstrFormat(
  const s: tKlausString; args: array of tKlausSimpleValue; const at: tSrcPoint): tKlausString;

// Преобразует строку в вещественное число путём вызова strToFloat с форматом
// klausLiteralFormat. Перед преобразованием ищет в s символы из exponentChars
// и заменяет первый найденный на латинскую 'E'.
function klausStrToFloat(const s: string; klausExpSigns: boolean = true): tKlausFloat;

// Преобразует вещественное число в строку
function klausFloatToStr(f: tKlausFloat): string;
function klausFloatToStr(f: tKlausFloat; fmt: tFormatSettings): string;

// Преобразует строку в целое число
function klausStrToInt(const s: string): tKlausInteger;

// Преобразует целое число в строку
function klausIntToStr(i: tKlausInteger): string;

// Преобразует строку в логическое значение.
function klausStrToBool(s: string): tKlausBoolean;

// Преобразует строку в дату/время с форматом klausLiteralFormat.
function klausStrToMoment(const s: string): tKlausMoment;

// Преобразует дату/время в строку с форматом klausLiteralFormat.
function klausMomentToStr(v: tKlausMoment): string;

// Преобразует символ в строку
function klausCharToStr(v: tKlausChar): u8Char;

// Преобразует строку в символ
function klausStrToChar(v: u8Char): tKlausChar;
function klausStrToChar(p: pChar): tKlausChar;

// Возвращает заключённый в двойные кавычки строковый литерал,
// преобразует управляющие символы #01..#1F в коды.
function klausStringLiteral(const s: string): string;

// Возвращает результат сравнения двух значений
function klausCmp(v1, v2: tKlausChar): integer;
function klausCmp(v1, v2: tKlausString): integer;
function klausCmp(v1, v2: tKlausInteger): integer;
function klausCmp(v1, v2: tKlausFloat; accuracy: tKlausFloat = 0): integer;
function klausCmp(v1, v2: tKlausMoment; accuracy: tKlausFloat = 0): integer;
function klausCmp(v1, v2: tKlausBoolean): integer;
function klausCmp(v1, v2: tKlausObject): integer;

type
  tKlausTerminalState = {$ifdef windows}cardinal{$else}TermIOs{$endif};

// Возвращает текущее состояние терминала
function klausGetTerminalState(h: tHandle): tKlausTerminalState;

// Устанавливает состояние терминала
procedure klausSetTerminalState(h: tHandle; state: tKlausTerminalState);

// Устанавливает сквозной режим работы терминала
procedure klausTerminalSetRaw(var inp: text; raw: boolean);

// Возвращает TRUE, если стандартный поток ввода не пуст
function klausTerminalHasChar(var inp: text): boolean;

// Читает значение из текстового потока в кодировке UTF-8.
// Возвращает FALSE, если поток пустой; создаёт исключения при ошибках чтения и конвертации.
function klausReadFromText(
  stream: tStream; dt: tKlausSimpleType; out sv: tKlausSimpleValue; const at: tSrcPoint): boolean;

const
  klausFileCreate         = $01;
  klausFileOpenRead       = $02;
  klausFileOpenWrite      = $04;
  klausFileOpenReadWrite  = klausFileOpenRead or klausFileOpenWrite;
  klausFileShareExclusive = $10;
  klausFileShareDenyWrite = $20;
  klausFileShareDenyNone  = $40;
const
  klausFilePosFromBeginning = 0;
  klausFilePosFromEnd       = 1;
  klausFilePosFromCurrent   = 2;

type
  tKlausInputReader = class
    private
      fStashed: u8Char;
    protected
      function eof(const c: u8Char): boolean; virtual;
      function doReadChar: u8Char; virtual; abstract;
    public
      property stashed: u8Char read fStashed write fStashed;

      function readChar: u8Char;
      function readNextValue(dt: tKlausSimpleType; out s: string): boolean;
      function readNextValue(dt: tKlausDataType; out sv: tKlausSimpleValue; const at: tSrcPoint): boolean;
  end;

type
  tKlausStreamReader = class(tKlausInputReader)
    private
      fStream: tStream;
    protected
      function doReadChar: u8Char; override;
    public
      constructor create(aStream: tStream);
  end;

type
  tKlausFileStream = class(tFileStream)
    private
      fMode: tKlausInteger;
    protected
      procedure setSize(const newSize: int64); override;
    public
      property mode: tKlausInteger read fMode;

      constructor create(const aFileName: string; aMode: tKlausInteger); virtual;
      function  read(var buffer; count: longint): longint; override;
      function  write(const buffer; count: longint): longint; override;
      function  readSimpleValue(dt: tKlausSimpleType; const at: tSrcPoint): tKlausSimpleValue; virtual; abstract;
      procedure writeSimpleValue(const sv: tKlausSimpleValue; const at: tSrcPoint); virtual; abstract;
  end;

type
  tKlausTextFile = class(tKlausFileStream)
    private
      fReader: tKlausStreamReader;
    public
      constructor create(const aFileName: string; aMode: tKlausInteger); override;

      function  readSimpleValue(dt: tKlausSimpleType; const at: tSrcPoint): tKlausSimpleValue; override;
      procedure writeSimpleValue(const sv: tKlausSimpleValue; const at: tSrcPoint); override;
  end;

type
  tKlausBinaryFile = class(tKlausFileStream)
    public
      function  readSimpleValue(dt: tKlausSimpleType; const at: tSrcPoint): tKlausSimpleValue; override;
      procedure writeSimpleValue(const sv: tKlausSimpleValue; const at: tSrcPoint); override;
  end;

type
  tKlausFileClass = class of tKlausFileStream;

const
  klausFileTypeText = 0;
  klausFileTypeBinary = 1;

const
  klausFileClass: array[klausFileTypeText..klausFileTypeBinary] of tKlausFileClass = (
    tKlausTextFile, tKlausBinaryFile);

function  klausGetFileType(ft: tKlausInteger; const at: tSrcPoint): tKlausFileClass;

function  loadJsonData(const fileName: string): tJsonData;
procedure saveJsonData(const fileName: string; data: tJsonData);

procedure listFileNames(const searchPath, mask: string; exclAttr: longInt; list: tStrings);

{$ifdef klauside}
function markdownToHtml(const md: string): tIpHTML;
{$endif}

function klausGetCourseTaskNames(src: tStream; out course, task: string): boolean;

implementation

uses Math, JsonParser, JsonScanner;

{$ifdef klauside}
var markdownProcessor: tMarkdownDaringFireball = nil;
{$endif}

resourcestring
  errInvalidInteger = 'Неверное целое число: "%s".';
  errInvalidFloat = 'Неверное дробное число: "%s".';
  errInvalidBoolean = 'Неверное логическое значение: "%s".';
  errInvalidMoment = 'Неверное значение даты/времени: "%s".';
  errFileNotReadable = 'Файл не был открыт для чтения.';
  errFileNotWritable = 'Файл не был открыт для записи.';
  errFileReadError = 'Ошибка чтения файла.';

function klausStrToFloat(const s: string; klausExpSigns: boolean = true): tKlausFloat;
var
  p: pChar;
  c: u8Char;
  tmp: string;
  i, sz: integer;
begin
  tmp := s;
  if klausExpSigns then begin
    p := pChar(klausExponentChars);
    repeat
      c := u8GetChar(p);
      if (c = 'E') or (c = 'e') then continue;
      if c = '' then break;
      i := pos(c, tmp);
      if i > 0 then begin
        sz := u8Size(c);
        tmp := copy(tmp, 1, i-1) + 'E' + copy(tmp, i+sz);
        break;
      end;
    until false;
  end;
  try result := strToFloat(s, klausLiteralFormat);
  except raise eConvertError.createFmt(errInvalidFloat, [s]); end;
end;

function klausFloatToStr(f: tKlausFloat): string;
begin
  result := klausFloatToStr(f, klausLiteralFormat);
end;

function klausFloatToStr(f: tKlausFloat; fmt: tFormatSettings): string;
begin
  result := floatToStr(f, fmt);
end;

function klausStrToInt(const s: string): tKlausInteger;
begin
  try result := strToInt64(s);
  except raise eConvertError.createFmt(errInvalidInteger, [s]); end;
end;

function klausIntToStr(i: tKlausInteger): string;
begin
  result := intToStr(i);
end;

function klausStrToBool(s: string): tKlausBoolean;
begin
  s := u8Lower(s);
  if (s = 'y') or (s = 'yes') or (s = 'д') or (s = 'да') or (s = '1')
  or (s = 't') or (s = 'true') or (s = 'и') or (s = 'истина') then result := true
  else if (s = 'n') or (s = 'no') or (s = 'н') or (s = 'нет') or (s = '0')
  or (s = 'f') or (s = 'false') or (s = 'л') or (s = 'ложь') then result := false
  else raise eConvertError.createFmt(errInvalidBoolean, [s]);
end;

function klausStrToMoment(const s: string): tKlausMoment;
var
  tmp: string;
  b: boolean = false;
begin
  tmp := u8Lower(s);
  if tmp = 'nan' then exit(0/0)
  else if tmp = '-inf' then exit(-1/0)
  else if (tmp = 'inf') or (tmp = '+inf') then exit(1/0);
  b := tryStrToDateTime(s, result, klausLiteralFormat);
  if not b then b := tryStrToTime(s, result, klausLiteralFormat);
  if not b then b := tryStrToDate(s, result, klausLiteralFormat);
  if not b then raise eConvertError.createFmt(errInvalidMoment, [s]);
end;

function klausMomentToStr(v: tKlausMoment): string;
begin
  if isNaN(v) or isInfinite(v) then result := klausFloatToStr(v)
  else if isZero(int(v)) then result := timeToStr(v, klausLiteralFormat)
  else result := dateTimeToStr(v, klausLiteralFormat)
end;

function klausCharToStr(v: tKlausChar): u8Char;
begin
  result := uniToU8(v);
end;

function klausStrToChar(v: u8Char): tKlausChar;
begin
  result := u8ToUni(v);
end;

function klausStrToChar(p: pChar): tKlausChar;
begin
  result := u8ToUni(p);
end;

function klausStringLiteral(const s: string): string;
var
  p: pChar;
  c: u8Char;
  wasCode: boolean;
begin
  if s = '' then exit('""');
  result := '';
  p := pChar(s);
  wasCode := true;
  while p^ <> #0 do begin
    c := u8GetChar(p);
    if c = '' then // так не должно быть, но вдруг? :)
    else if c[1] <= #$1F then begin
      if not wasCode then result += '"';
      result += '#'+intToHex(byte(c[1]));
      wasCode := true;
    end else begin
      if wasCode then result += '"';
      if c = '"' then result += '""'
      else result += c;
      wasCode := false;
    end;
  end;
  if not wasCode then result += '"';
  result := result;
end;

function klausCmp(v1, v2: tKlausChar): integer;
begin
  if v1 > v2 then result := 1
  else if v1 < v2 then result := -1
  else result := 0;
end;

function klausCmp(v1, v2: tKlausString): integer;
begin
  if v1 > v2 then result := 1
  else if v1 < v2 then result := -1
  else result := 0;
end;

function klausCmp(v1, v2: tKlausInteger): integer;
begin
  if v1 > v2 then result := 1
  else if v1 < v2 then result := -1
  else result := 0;
end;

function klausCmp(v1, v2: tKlausFloat; accuracy: tKlausFloat = 0): integer;
begin
  result := 1;
  if abs(v1-v2) <= accuracy then result := 0
  else if v1 < v2 then result := -1;
end;

function klausCmp(v1, v2: tKlausMoment; accuracy: tKlausFloat = 0): integer;
begin
  result := 1;
  if abs(v1-v2) <= accuracy then result := 0
  else if v1 < v2 then result := -1;
end;

function klausCmp(v1, v2: tKlausBoolean): integer;
const
  bv: array[boolean] of integer = (0, 1);
begin
  if bv[v1] > bv[v2] then result := 1
  else if bv[v1] < bv[v2] then result := -1
  else result := 0;
end;

function klausCmp(v1, v2: tKlausObject): integer;
begin
  if v1 > v2 then result := 1
  else if v1 < v2 then result := -1
  else result := 0;
end;

type
  tTerminalState = {$ifdef windows}cardinal{$else}TermIOs{$endif};

function stdInHandle(var inp: text): tHandle;
begin
  result := tTextRec(inp).handle;
end;

function stdInBufNotEmpty(var inp: text): boolean;
begin
  with tTextRec(inp) do
    result := bufPos < bufEnd;
end;

{$push}{$WARN 5057 off}{$WARN 5059 off}{$WARN 5060 off}
function klausGetTerminalState(h: tHandle): tKlausTerminalState;
begin
  {$ifdef windows}
  getConsoleMode(h, result);
  {$else}
  TCGetAttr(h, result);
  {$endif}
end;
{$pop}

procedure klausSetTerminalState(h: tHandle; state: tKlausTerminalState);
begin
  {$ifdef windows}
  setConsoleMode(h, state);
  {$else}
  TCSetAttr(h, TCSANOW, state);
  {$endif}
end;

procedure klausTerminalSetRaw(var inp: text; raw: boolean);
const
  {$push}{$warnings off}
  prevState: record
    valid: boolean;
    state: tKlausTerminalState;
  end = (valid: false);
  {$pop}
var
  state: tTerminalState;
begin
  if not prevState.valid then begin
    if not raw then exit;
    prevState.state := klausGetTerminalState(stdInHandle(inp));
    prevState.valid := true;
  end;
  state := prevState.state;
  {$ifdef windows}
  if raw then state := state and not (ENABLE_ECHO_INPUT or ENABLE_LINE_INPUT or ENABLE_PROCESSED_INPUT);
  {$else}
  if raw then CFMakeRaw(state);
  {$endif}
  klausSetTerminalState(stdInHandle(inp), state);
end;

function klausTerminalHasChar(var inp: text): boolean;
{$ifdef windows}
var
  i: integer;
  read: longWord;
  num: longWord = 0;
  inps: array of tInputRecord = nil;
begin
  if stdInBufNotEmpty(inp) then exit(true);
  result := false;
  if not getNumberOfConsoleInputEvents(stdInHandle(inp), num) then exit(true);
  if num = 0 then exit;
  setLength(inps, num);
  peekConsoleInput(stdInHandle(inp), @inps[0], num, @read);
  for i := 0 to read-1 do
    if (inps[i].eventType = KEY_EVENT) and (inps[i].event.keyEvent.bKeyDown) then exit(true)
end;
{$else}
var
  fdSet: tFDSet;
  timeout: tTimeVal;
begin
  if stdInBufNotEmpty(inp) then exit(true);
  fpFD_ZERO(fdSet);
  fpFD_SET(stdInHandle(inp), fdSet);
  timeout.tv_sec := 0;
  timeout.tv_usec := 0;
  result := fpSelect(stdInHandle(inp)+1, @fdSet, nil, nil, @timeout) > 0;
end;
{$endIf}

function klstrSetLength(var s: tKlausString; len: tKlausInteger; const at: tSrcPoint): tKlausInteger;
var
  old: tKlausInteger;
begin
  old := length(s);
  if len < 0 then len := 0
  else if len < old then if not u8Start(pChar(s)+len) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [len]);
  setLength(s, len);
  if len > old then fillChar((pChar(s)+old)^, len-old, ' ');
  result := len;
end;

procedure klstrInsert(
  var s: tKlausString; idx: tKlausInteger; const substr: tKlausString; const at: tSrcPoint);
var
  l: tKlausInteger;
begin
  if idx < 0 then raise eKlausError.createFmt(ercInvalidStringIndex, at, [idx]);
  l := length(s);
  if idx >= l then idx := l
  else if not u8Start(pChar(s)+idx) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx]);
  system.insert(substr, s, idx+1);
end;

procedure klstrDelete(var s: tKlausString; idx, count: tKlausInteger; const at: tSrcPoint);
var
  l: tKlausInteger;
begin
  if idx < 0 then raise eKlausError.createFmt(ercInvalidStringIndex, at, [idx]);
  if count <= 0 then exit;
  l := length(s);
  if idx >= l then exit;
  if count > l-idx then count := l-idx;
  if not u8Start(pChar(s)+idx) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx]);
  if idx+count < l then if not u8Start(pChar(s)+idx+count) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx+count]);
  system.delete(s, idx+1, count);
end;

procedure klstrOverwrite(
  var s: tKlausString; idx: tKlausInteger; const src: tKlausString; from, len: tKlausInteger; const at: tSrcPoint);
var
  l1, l2: tKlausInteger;
begin
  if idx < 0 then raise eKlausError.createFmt(ercInvalidStringIndex, at, [idx]);
  if from < 0 then raise eKlausError.createFmt(ercInvalidStringIndex, at, [from]);
  l1 := length(s);
  if idx >= l1 then idx := l1
  else if not u8Start(pChar(s)+idx) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx]);
  l2 := length(src);
  if from >= l2 then exit
  else if not u8Start(pChar(src)+from) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [from]);
  if len >= l2-from then len := l2-from
  else if not u8Start(pChar(src)+from+len) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [from+len]);
  if idx+len >= l1 then
    setLength(s, idx+len)
  else begin
    if not u8Start(pChar(s)+idx+len) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx+len]);
    uniqueString(s);
  end;
  move((pChar(src)+from)^, (pChar(s)+idx)^, len);
end;

procedure klstrReplace(
  var s: tKlausString; idx, count: tKlausInteger; const repl: tKlausString; const at: tSrcPoint);
var
  l, rl: tKlausInteger;
begin
  l := length(s);
  if idx < 0 then raise eKlausError.createFmt(ercInvalidStringIndex, at, [idx]);
  if (count <= 0) and (repl = '') then exit;
  if idx >= l then idx := l
  else if not u8Start(pChar(s)+idx) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx]);
  if count >= l-idx then count := l-idx
  else if not u8Start(pChar(s)+idx+count) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx+count]);
  rl := length(repl);
  if count-rl > 0 then system.delete(s, idx+1, count-rl)
  else system.insert(stringOfChar(' ', rl-count), s, idx+1);
  if repl <> '' then begin
    uniqueString(s);
    move(pChar(repl)^, (pChar(s)+idx)^, rl);
  end;
end;

function klstrChar(const s: tKlausString; idx: tKlausInteger; const at: tSrcPoint): tKlausChar;
var
  l: tKlausInteger;
begin
  l := length(s);
  if (idx < 0) or (idx >= l) then raise eKlausError.createFmt(ercInvalidStringIndex, at, [idx]);
  if not u8Start(pChar(s)+idx) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx]);
  result := klausStrToChar(pChar(s)+idx);
end;

function klstrPart(const s: tKlausString; idx, count: tKlausInteger; const at: tSrcPoint): tKlausString;
var
  l: tKlausInteger;
begin
  if idx < 0 then raise eKlausError.createFmt(ercInvalidStringIndex, at, [idx]);
  l := length(s);
  if (idx >= l) or (count <= 0) then exit('');
  if not u8Start(pChar(s)+idx) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx]);
  if count > l-idx then count := l-idx;
  if (idx+count < l) then if not u8Start(pChar(s)+idx+count) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx+count]);
  result := copy(s, idx+1, count);
end;

function klstrNext(
  const s: tKlausString; idx, count: tKlausInteger; out chars: tKlausInteger; const at: tSrcPoint): tKlausInteger;
var
  p, pend: pChar;
  l: tKlausInteger;
begin
  chars := 0;
  if idx < 0 then raise eKlausError.createFmt(ercInvalidStringIndex, at, [idx]);
  l := length(s);
  if idx >= l then exit(l);
  p := pChar(s)+idx;
  if not u8Start(p) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx]);
  if count <= 0 then exit(idx);
  pend := pChar(s)+l;
  repeat
    p += u8Size(p);
    inc(chars);
    if p >= pend then exit(l);
  until chars >= count;
  result := p-pChar(s);
end;

function klstrPrev(
  const s: tKlausString; idx, count: tKlausInteger; out chars: tKlausInteger; const at: tSrcPoint): tKlausInteger;
var
  p, pend: pChar;
  l: tKlausInteger;
begin
  chars := 0;
  if idx < 0 then raise eKlausError.createFmt(ercInvalidStringIndex, at, [idx]);
  if s = '' then exit(0);
  l := length(s);
  if idx > l then idx := l;
  p := pChar(s)+idx;
  if idx < l then if not u8Start(p) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx]);
  if count <= 0 then exit(idx);
  pend := pChar(s);
  while p > pend do begin
    if chars >= count then break;
    p -= 1;
    if u8Start(p) then inc(chars);
  end;
  if not u8Start(p) then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx]);
  result := p-pend;
end;

function klstrFormat(const s: tKlausString; args: array of tKlausSimpleValue; const at: tSrcPoint): tKlausString;
type
  tFmtType = (ftI, ftE, ftF, ftG, ftN, ftD, ftT, ftM, ftS, ftX);
  tFmt = record
    ft: tFmtType;
    arg: integer;
    width: integer;
    prec: integer;
    left: boolean;
  end;

  function readFmtType(const s: tKlausString; var idx: sizeInt): tFmtType;
  var
    c: u8Char;
  begin
    c := u8Chr(pChar(s)+idx-1);
    case c[1] of
      'I', 'i': result := ftI;
      'E', 'e': result := ftE;
      'F', 'f': result := ftF;
      'G', 'g': result := ftG;
      'N', 'n': result := ftN;
      'D', 'd': result := ftD;
      'T', 't': result := ftT;
      'M', 'm': result := ftM;
      'S', 's': result := ftS;
      'X', 'x': result := ftX;
      else if (c = 'Ц') or (c = 'ц') then result := ftI
      else if (c = 'Э') or (c = 'э') then result := ftE
      else if (c = 'Ф') or (c = 'ф') then result := ftF
      else if (c = 'О') or (c = 'о') then result := ftG
      else if (c = 'Ч') or (c = 'ч') then result := ftN
      else if (c = 'Д') or (c = 'д') then result := ftD
      else if (c = 'В') or (c = 'в') then result := ftT
      else if (c = 'М') or (c = 'м') then result := ftM
      else if (c = 'С') or (c = 'с') then result := ftS
      else if (c = 'Ш') or (c = 'ш') then result := ftX
      else raise eKlausError.create(ercInvalidFormatSpecifier, at);
    end;
    inc(idx, length(c));
  end;

  function readInt(const s: tKlausString; var idx: sizeInt): integer;
  var
    l, sIdx: sizeInt;
  begin
    sIdx := idx;
    l := length(s);
    while s[idx] in ['0'..'9'] do begin
      inc(idx);
      if idx > l then break;
    end;
    if idx <= sIdx then result := -1
    else result := strToInt(copy(s, sIdx, idx-sIdx));
  end;

  procedure readFormat(const s: tKlausString; var idx: sizeInt; out fmt: tFmt);
  type
    tReadState = (rsArg, rsLeft, rsWidth, rsPrec, rsType);
  var
    v: integer;
    l: sizeInt;
    rs: tReadState = rsArg;
  begin
    l := length(s);
    repeat
      if idx > l then raise eKlausError.create(ercInvalidFormatSpecifier, at);
      case rs of
        rsArg: begin
          v := readInt(s, idx);
          if v < 0 then begin
            fmt.arg := -1;
            rs := rsLeft;
          end else if s[idx] = ':' then begin
            fmt.arg := v;
            rs := rsLeft;
            inc(idx);
          end else begin
            fmt.arg :=-1;
            fmt.left := false;
            fmt.width := v;
            rs := rsPrec;
          end;
        end;
        rsLeft: begin
          if s[idx] = '-' then begin
            fmt.left := true;
            inc(idx);
          end else
            fmt.left := false;
          rs := rsWidth;
        end;
        rsWidth: begin
          v := readInt(s, idx);
          if v >= 0 then fmt.width := v
          else fmt.width := -1;
          rs := rsPrec;
        end;
        rsPrec: begin
          if s[idx] = '.' then begin
            inc(idx);
            v := readInt(s, idx);
            if v < 0 then raise eKlausError.create(ercInvalidFormatSpecifier, at);
            fmt.prec := v;
          end else
            fmt.prec := -1;
          rs := rsType;
        end;
        rsType: begin
          fmt.ft := readFmtType(s, idx);
          break;
        end;
      end;
    until false;
  end;

  function formatArg(const fmt: tFmt; var arg: integer): string;
  var
    q: qWord;
    pad, prec: integer;
  begin
    result := '';
    if fmt.arg < 0 then inc(arg) else arg := fmt.arg;
    if (arg < 0) or (arg >= length(args)) then
      raise eKlausError.createFmt(ercInvalidFormatArgIdx, at, [arg]);
    case fmt.ft of
      ftI: begin
        if args[arg].dataType <> kdtInteger then raise eKlausError.createFmt(ercInvalidFormatArgType, at, [arg]);
        result := intToStr(args[arg].iValue);
        pad := fmt.prec - length(result);
        if result[1] <> '-' then insert(stringOfChar('0', pad), result, 1)
        else insert(stringOfChar('0', pad+1), result, 2)
      end;
      ftX: begin
        if not (args[arg].dataType in [kdtInteger, kdtChar, kdtObject]) then raise eKlausError.createFmt(ercInvalidFormatArgType, at, [arg]);
        q := qWord(klausTypecast(args[arg], kdtInteger, at).iValue);
        prec := 1;
        while (qWord(1) shl (prec*4) <= q) and (prec < 16) do inc(prec);
        if fmt.prec > prec then prec := fmt.prec;
        result := HexStr(q, prec);
      end;
      ftE: begin
        if fmt.prec < 0 then prec := 16 else prec := fmt.prec;
        if not (args[arg].dataType in [kdtInteger, kdtFloat]) then raise eKlausError.createFmt(ercInvalidFormatArgType, at, [arg]);
        result := floatToStrF(klausTypecast(args[arg], kdtFloat, at).fValue, ffExponent, prec, 3, klausLiteralFormat);
      end;
      ftF: begin
        if fmt.prec < 0 then prec := 16 else prec := fmt.prec;
        if not (args[arg].dataType in [kdtInteger, kdtFloat]) then raise eKlausError.createFmt(ercInvalidFormatArgType, at, [arg]);
        result := floatToStrF(klausTypecast(args[arg], kdtFloat, at).fValue, ffFixed, 9999, prec, klausLiteralFormat);
      end;
      ftG: begin
        if fmt.prec < 0 then prec := 16 else prec := fmt.prec;
        if not (args[arg].dataType in [kdtInteger, kdtFloat]) then raise eKlausError.createFmt(ercInvalidFormatArgType, at, [arg]);
        result := floatToStrF(klausTypecast(args[arg], kdtFloat, at).fValue, ffGeneral, prec, 3, klausLiteralFormat);
      end;
      ftN: begin
        if fmt.prec < 0 then prec := 16 else prec := fmt.prec;
        if not (args[arg].dataType in [kdtInteger, kdtFloat]) then raise eKlausError.createFmt(ercInvalidFormatArgType, at, [arg]);
        result := floatToStrF(klausTypecast(args[arg], kdtFloat, at).fValue, ffNumber, 9999, prec, klausLiteralFormat);
      end;
      ftD: begin
        if args[arg].dataType <> kdtMoment then raise eKlausError.createFmt(ercInvalidFormatArgType, at, [arg]);
        result := dateToStr(args[arg].mValue, klausLiteralFormat);
      end;
      ftT: begin
        if args[arg].dataType <> kdtMoment then raise eKlausError.createFmt(ercInvalidFormatArgType, at, [arg]);
        result := timeToStr(args[arg].mValue, klausLiteralFormat);
      end;
      ftM: begin
        if args[arg].dataType <> kdtMoment then raise eKlausError.createFmt(ercInvalidFormatArgType, at, [arg]);
        result := dateToStr(args[arg].mValue, klausLiteralFormat) + ' ' + timeToStr(args[arg].mValue, klausLiteralFormat);
      end;
      ftS: result := klausTypecast(args[arg], kdtString, at).sValue;
    end;
    if fmt.width >= 0 then begin
      pad := fmt.width - u8CharCount(result);
      if fmt.left then result += stringOfChar(' ', pad)
      else result := stringOfChar(' ', pad) + result;
    end;
  end;

  procedure processFormat(var s: tKlausString; var idx: sizeInt; var arg: integer);
  var
    fmt: tFmt;
    i, dl: sizeInt;
    v: tKlausString;
  begin
    i := idx-1;
    readFormat(s, idx, fmt);
    v := formatArg(fmt, arg);
    dl := length(v)-idx+i;
    if dl <= 0 then delete(s, i, -dl)
    else insert(stringOfChar(' ', dl), s, i);
    move(pChar(v)^, s[i], length(v));
    idx += dl;
  end;

var
  arg: integer;
  idx: sizeInt;
begin
  result := s;
  if result = '' then exit('');
  arg := -1;
  idx := pos('%', result);
  while idx > 0 do begin
    inc(idx);
    if idx > length(result) then break;
    if result[idx] = '%' then delete(result, idx, 1)
    else processFormat(result, idx, arg);
    idx := pos('%', result, idx);
  end;
end;

procedure testKlstrFormat;
var
  at: tSrcPoint;
  fmt, s: string;
  v: tKlausSimpleValue;
begin
  at := zeroSrcPt;
  fmt := '[%i]';
  v := klausSimpleI(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%%]';
  v := klausSimpleI(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%10i]';
  v := klausSimpleI(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%.4i]';
  v := klausSimpleI(-10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%10.4ц]';
  v := klausSimpleI(-10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:ц]';
  v := klausSimpleI(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:10Ц]';
  v := klausSimpleI(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:10.4Ц]';
  v := klausSimpleI(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-10i]';
  v := klausSimpleI(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-10.4I]';
  v := klausSimpleI(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%x]';
  v := klausSimpleI(1234567);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%10x]';
  v := klausSimpleI(1234567);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%.4x]';
  v := klausSimpleI(-1234567);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%10.4ш]';
  v := klausSimpleI(-1234567);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:ш]';
  v := klausSimpleC(tKlausChar($0401));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:10Ш]';
  v := klausSimpleC(tKlausChar($0401));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:10.4Ш]';
  v := klausSimpleC(tKlausChar($0401));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-10x]';
  v := klausSimpleC(tKlausChar($0401));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-10.4X]';
  v := klausSimpleC(tKlausChar($0401));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%e]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%12e]';
  v := klausSimpleF(tKlausFloat(-1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%12.4e]';
  v := klausSimpleF(tKlausFloat(-1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:э]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:12э]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:12.4Э]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-12Э]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-12.4E]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%f]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%12f]';
  v := klausSimpleF(tKlausFloat(-1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%12.4f]';
  v := klausSimpleF(tKlausFloat(-1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:ф]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:12ф]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:12.4Ф]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-12Ф]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-12.4F]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%g]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%12g]';
  v := klausSimpleF(tKlausFloat(-1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%12.4g]';
  v := klausSimpleF(tKlausFloat(-1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:о]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:12о]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:12.4О]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-12О]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-12.4G]';
  v := klausSimpleF(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%n]';
  v := klausSimpleF(tKlausFloat(1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%14n]';
  v := klausSimpleF(tKlausFloat(-1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%14.4n]';
  v := klausSimpleF(tKlausFloat(-1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:ч]';
  v := klausSimpleF(tKlausFloat(1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:14ч]';
  v := klausSimpleF(tKlausFloat(1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:14.4Ч]';
  v := klausSimpleF(tKlausFloat(1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-14Ч]';
  v := klausSimpleF(tKlausFloat(1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-14.4N]';
  v := klausSimpleF(tKlausFloat(1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%14d]';
  v := klausSimpleM(tKlausMoment(44567.123));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%-14д]';
  v := klausSimpleM(tKlausMoment(44567.123));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%14t]';
  v := klausSimpleM(tKlausMoment(44567.123));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%-14в]';
  v := klausSimpleM(tKlausMoment(44567.123));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%14m]';
  v := klausSimpleM(tKlausMoment(44567.123));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%-14м]';
  v := klausSimpleM(tKlausMoment(44567.123));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%s]';
  v := klausSimpleS('Привет!');
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%14с]';
  v := klausSimpleS('Привет!');
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%-14с]';
  v := klausSimpleS('Привет!');
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
end;

function klausGetFileType(ft: tKlausInteger; const at: tSrcPoint): tKlausFileClass;
begin
  if (ft < low(klausFileClass)) or (ft > high(klausFileClass)) then raise eKlausError.createFmt(ercInvalidFileType, at, [ft]);
  result := klausFileClass[ft];
end;

function klausReadFromText(
  stream: tStream; dt: tKlausSimpleType; out sv: tKlausSimpleValue; const at: tSrcPoint): boolean;
var
  c: u8Char;
  s: tKlausString;
  l, idx: sizeInt;
begin
  case dt of
    kdtObject:
      raise eKlausError.createFmt(ercValueCannotBeRead, at, [klausDataTypeCaption[dt]]);
    kdtChar: begin
      c := u8ReadChar(stream);
      if c = '' then exit(false);
      sv.cValue := klausStrToChar(c);
      sv.dataType := kdtChar;
    end;
    kdtString: begin
      s := '';
      idx := 1;
      c := u8ReadChar(stream);
      if c = '' then exit(false);
      while c <> '' do begin
        if c = #10 then break
        else if c = #13 then begin
          c := u8ReadChar(stream);
          if (c <> '') and (c <> #10) then stream.seek(-u8Size(c), soCurrent);
          break;
        end;
        l := byte(c[0]);
        if idx-1 > length(s)-l then setLength(s, idx+32);
        move(c[1], s[idx], l);
        idx += l;
        c := u8ReadChar(stream);
      end;
      setLength(s, idx-1);
      sv.sValue := s;
      sv.dataType := kdtString;
    end;
  else
    c := u8ReadChar(stream);
    if c = '' then exit(false);
    while c[1] in [#9, #10, #13, ' '] do begin
      c := u8ReadChar(stream);
      if c = '' then exit(false);
    end;
    s := '';
    idx := 1;
    while c <> '' do begin
      if c[1] in [#9, #10, #13, ' '] then begin
        stream.seek(-1, soCurrent);
        break;
      end;
      l := byte(c[0]);
      if idx-1 > length(s)-l then setLength(s, idx+32);
      move(c[1], s[idx], l);
      idx += l;
      c := u8ReadChar(stream);
    end;
    setLength(s, idx-1);
    case dt of
      kdtInteger: sv.iValue := klausStrToInt(s);
      kdtFloat:   sv.fValue := klausStrToFloat(s);
      kdtMoment:  sv.mValue := klausStrToMoment(s);
      kdtBoolean: sv.bValue := klausStrToBool(s);
    else
      assert(false, 'Unexpected value type');
    end;
    sv.dataType := dt;
  end;
  result := true;
end;

function loadJsonData(const fileName: string): tJsonData;
var
  stream: tFileStream;
  parser: tJsonParser;
begin
  stream := tFileStream.create(fileName, fmOpenRead or fmShareDenyWrite);
  try
    parser := tJsonParser.create(stream, [joUTF8]);
    try
      result := parser.parse;
    finally
      freeAndNil(parser);
    end;
  finally
    freeAndNil(stream);
  end;
end;

procedure saveJsonData(const fileName: string; data: tJsonData);
var
  s: string;
  stream: tFileStream;
begin
  stream := tFileStream.create(fileName, fmCreate or fmShareDenyWrite);
  try
    s := data.formatJson;
    if s <> '' then stream.writeBuffer(pChar(s)^, length(s));
  finally
    freeAndNil(stream);
  end;
end;

procedure listFileNames(const searchPath, mask: string; exclAttr: longInt; list: tStrings);
var
  i: integer;
  path: string;
  sr: tSearchRec;
  dirs: tStringList;
begin
  dirs := tStringList.create;
  try
    dirs.strictDelimiter := true;
    dirs.quoteChar := '"';
    dirs.delimiter := ';';
    dirs.delimitedText := searchPath;
    for i := 0 to dirs.count-1 do begin
      path := includeTrailingPathDelimiter(dirs[i]);
      if findFirst(path+mask, longInt($FFFFFFFF), sr) = 0 then try
        repeat
          if (sr.attr and exclAttr) = 0 then list.add(path+sr.name);
        until findNext(sr) <> 0;
      finally
        findClose(sr);
      end;
    end;
  finally
    freeAndNil(dirs);
  end;
end;

{$ifdef klauside}
function markdownToHtml(const md: string): tIpHTML;
var
  html: string;
  stream: tStringReadStream;
begin
  if markdownProcessor = nil then begin
    markdownProcessor := tMarkdownDaringFireball.create;
    markdownProcessor.config.forceExtendedProfile := true;
  end;
  html := markdownProcessor.process(md);
  stream := tStringReadStream.create(html);
  try
    result := tIpHtml.create;
    try result.loadFromStream(stream);
    except freeAndNil(result); raise; end;
  finally
    freeAndNil(stream);
  end;
end;
{$endif}

function klausGetCourseTaskNames(src: tStream; out course, task: string): boolean;
var
  li: tKlausLexInfo;
  p: tKlausLexParser;

  function next: tKlausLexInfo;
  begin
    p.getNextLexem(result);
    while result.lexem in [klxSLComment, klxMLComment] do p.getNextLexem(result);
  end;

begin
  result := false;
  course := '';
  task := '';
  try
    p := tKlausLexParser.create(src);
    p.ownsStream := false;
    try
      li := next;
      if (li.lexem <> klxKeyword) or (li.keyword <> kkwdTask) then exit;
      result := true;
      li := next;
      if li.lexem <> klxID then exit;
      task := li.text;
      li := next;
      if (li.lexem <> klxKeyword) or (li.keyword <> kkwdPracticum) then exit;
      li := next;
      if li.lexem <> klxID then exit;
      course := li.text;
    finally
      freeAndNil(p);
    end;
  except
    result := false;
  end;
end;

{ tKlausInputReader }

function tKlausInputReader.readChar: u8Char;
begin
  if stashed <> '' then begin
    result := stashed;
    stashed := '';
  end else
    result := doReadChar;
end;

function tKlausInputReader.eof(const c: u8Char): boolean;
begin
  if c = '' then exit(true);
  result := c[1] in [#04, #26];
end;

function tKlausInputReader.readNextValue(dt: tKlausSimpleType; out s: string): boolean;
var
  c: u8Char;
  l, idx: integer;
begin
  case dt of
    kdtChar: begin
      s := readChar;
      result := not eof(s);
    end;
    kdtString: begin
      s := '';
      idx := 1;
      c := readChar;
      if eof(c) then exit(false)
      else repeat
        if c = #10 then break
        else if c = #13 then begin
          c := readChar;
          if (c <> '') and (c <> #10) then stashed := c;
          break;
        end;
        l := byte(c[0]);
        if idx-1 > length(s)-l then setLength(s, idx+32);
        move(c[1], s[idx], l);
        idx += l;
        c := readChar;
      until eof(c);
      setLength(s, idx-1);
      result := true;
    end;
    kdtInteger, kdtFloat, kdtMoment, kdtBoolean: begin
      c := readChar;
      if eof(c) then exit(false);
      while c[1] in [#9, #10, #13, ' '] do begin
        c := readChar;
        if eof(c) then exit(false);
      end;
      s := '';
      idx := 1;
      repeat
        if c = #10 then break
        else if c = #13 then begin
          c := readChar;
          if (c <> '') and (c <> #10) then stashed := c;
          break;
        end else if c[1] in [#9, ' '] then begin
          stashed := c;
          break;
        end;
        l := byte(c[0]);
        if idx-1 > length(s)-l then setLength(s, idx+32);
        move(c[1], s[idx], l);
        idx += l;
        c := readChar;
      until eof(c);
      setLength(s, idx-1);
      while (stashed = #9) or (stashed = ' ') do begin
        stashed := '';
        c := readChar;
        if c = #10 then break
        else if c = #13 then begin
          c := readChar;
          if (c <> '') and (c <> #10) then stashed := c;
          break;
        end else
          stashed := c;
      end;
      result := true;
    end;
    else begin
      assert(dt in [kdtChar..kdtBoolean], 'Value of this data type cannot be read.');
      result := false;
    end;
  end;
end;

function tKlausInputReader.readNextValue(dt: tKlausDataType; out sv: tKlausSimpleValue; const at: tSrcPoint): boolean;
var
  s: string;
begin
  case dt of
    kdtComplex: raise eKlausError.create(ercCannotReadComplexType, at);
    kdtObject: raise eKlausError.createFmt(ercValueCannotBeRead, at, [klausDataTypeCaption[dt]]);
  end;
  if not readNextValue(dt, s) then exit(false);
  case dt of
    kdtChar:    sv := klausSimpleC(klausStrToChar(s));
    kdtString:  sv := klausSimpleS(s);
    kdtInteger: sv := klausSimpleI(klausStrToInt(s));
    kdtFloat:   sv := klausSimpleF(klausStrToFloat(s));
    kdtMoment:  sv := klausSimpleM(klausStrToMoment(s));
    kdtBoolean: sv := klausSimpleB(klausStrToBool(s));
    else assert(false, 'Invalid datatype.');
  end;
  result := true;
end;

{ tKlausStreamReader }

constructor tKlausStreamReader.create(aStream: tStream);
begin
  inherited create;
  fStream := aStream;
end;

function tKlausStreamReader.doReadChar: u8Char;
begin
  result := u8ReadChar(fStream);
  if result = '' then result := #04;
end;

{ tKlausFileStream }

procedure tKlausFileStream.setSize(const newSize: int64);
begin
  if mode and klausFileOpenWrite = 0 then raise eStreamError.create(errFileNotWritable);
  inherited setSize(newSize);
end;

constructor tKlausFileStream.create(const aFileName: string; aMode: tKlausInteger);
var
  fm, fs: word;
begin
  fMode := aMode;
  if mode and klausFileCreate = klausFileCreate then begin
    fm := fmCreate;
    fMode := fMode or klausFileOpenReadWrite;
  end else if mode and klausFileOpenReadWrite = klausFileOpenReadWrite then
    fm := fmOpenReadWrite
  else if mode and klausFileOpenWrite = klausFileOpenWrite then
    fm := fmOpenWrite
  else
    fm := fmOpenRead;
  if mode and klausFileShareDenyNone = klausFileShareDenyNone then fs := fmShareDenyNone
  else if mode and klausFileShareDenyWrite = klausFileShareDenyWrite then fs := fmShareDenyWrite
  else fs := klausFileShareExclusive;
  inherited create(aFileName, fm or fs);
end;

function tKlausFileStream.read(var buffer; count: longint): longint;
begin
  if mode and klausFileOpenRead = 0 then raise eStreamError.create(errFileNotReadable);
  result := inherited read(buffer, count);
end;

function tKlausFileStream.write(const buffer; count: longint): longint;
begin
  if mode and klausFileOpenWrite = 0 then raise eStreamError.create(errFileNotWritable);
  result := inherited write(buffer, count);
end;

{ tKlausTextFile }

constructor tKlausTextFile.create(const aFileName: string; aMode: tKlausInteger);
begin
  inherited;
  fReader := tKlausStreamReader.create(self);
end;

function tKlausTextFile.readSimpleValue(dt: tKlausSimpleType; const at: tSrcPoint): tKlausSimpleValue;
begin
  if not fReader.readNextValue(dt, result, at) then raise eStreamError.create(errFileReadError);
end;

procedure tKlausTextFile.writeSimpleValue(const sv: tKlausSimpleValue; const at: tSrcPoint);
var
  s: tKlausString;
begin
  s := klausTypecast(sv, kdtString, at).sValue;
  if s <> '' then writeBuffer(pChar(s)^, length(s));
end;

{ tKlausBinaryFile }

procedure tKlausBinaryFile.writeSimpleValue(const sv: tKlausSimpleValue; const at: tSrcPoint);
var
  l: tKlausInteger;
begin
  case sv.dataType of
    kdtChar: writeBuffer(sv.cValue, sizeOf(sv.cValue));
    kdtString: begin
      l := length(sv.sValue);
      writeBuffer(l, sizeOf(l));
      if sv.sValue <> '' then writeBuffer(pChar(sv.sValue)^, l);
    end;
    kdtInteger: writeBuffer(sv.iValue, sizeOf(sv.iValue));
    kdtFloat: writeBuffer(sv.fValue, sizeOf(sv.fValue));
    kdtMoment: writeBuffer(sv.mValue, sizeOf(sv.mValue));
    kdtBoolean: writeBuffer(sv.bValue, sizeOf(sv.bValue));
    kdtObject: writeBuffer(sv.oValue, sizeOf(sv.oValue));
  else
    assert(false, 'Invalid simple type');
  end;
end;

function tKlausBinaryFile.readSimpleValue(dt: tKlausSimpleType; const at: tSrcPoint): tKlausSimpleValue;
var
  l: tKlausInteger = 0;
begin
  result.dataType := dt;
  case dt of
    kdtChar: readBuffer(result.cValue, sizeOf(result.cValue));
    kdtString: begin
      readBuffer(l, sizeOf(l));
      setLength(result.sValue, l);
      if l > 0  then readBuffer(pChar(result.sValue)^, l);
    end;
    kdtInteger: readBuffer(result.iValue, sizeOf(result.iValue));
    kdtFloat: readBuffer(result.fValue, sizeOf(result.fValue));
    kdtMoment: readBuffer(result.mValue, sizeOf(result.mValue));
    kdtBoolean: readBuffer(result.bValue, sizeOf(result.bValue));
    kdtObject: raise eKlausError.createFmt(ercValueCannotBeRead, at, [klausDataTypeCaption[dt]]);
  else
    assert(false, 'Invalid data type');
  end;
end;

initialization
  defaultFormatSettings := klausLiteralFormat;
  //testKlstrFormat;
finalization
  {$ifdef klauside}
  freeAndNil(markdownProcessor);
  {$endif}
end.

