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
  Classes, SysUtils, Graphics, U8, KlausLex, KlausDef, KlausErr;

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
function klausCmp(v1, v2: tKlausFloat): integer;
function klausCmp(v1, v2: tKlausMoment): integer;
function klausCmp(v1, v2: tKlausBoolean): integer;

// Устанавливает raw-режим работы терминала
procedure klausTerminalSetRaw(var inp: text; raw: boolean);

// Возвращает TRUE, если стандартный поток ввода не пуст
function klausTerminalHasChar(var inp: text): boolean;

implementation

uses {$ifdef windows}Windows,{$else}BaseUnix, TermIO,{$endif}Math;

resourcestring
  errInvalidInteger = 'Неверное целое число: "%s".';
  errInvalidFloat = 'Неверное дробное число: "%s".';
  strInvalidBoolean = 'Неверное логическое значение: "%s".';
  strInvalidMoment = 'Неверное значение даты/времени: "%s".';

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
  else raise eConvertError.createFmt(strInvalidBoolean, [s]);
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
  if not b then raise eConvertError.createFmt(strInvalidMoment, [s]);
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

function klausCmp(v1, v2: tKlausFloat): integer;
begin
  if v1 > v2 then result := 1
  else if v1 < v2 then result := -1
  else result := 0;
end;

function klausCmp(v1, v2: tKlausMoment): integer;
begin
  if v1 > v2 then result := 1
  else if v1 < v2 then result := -1
  else result := 0;
end;

function klausCmp(v1, v2: tKlausBoolean): integer;
const
  bv: array[boolean] of integer = (0, 1);
begin
  if bv[v1] > bv[v2] then result := 1
  else if bv[v1] < bv[v2] then result := -1
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
function getTerminalState(h: tHandle): tTerminalState;
begin
  {$ifdef windows}
  getConsoleMode(h, result);
  {$else}
  TCGetAttr(h, result);
  {$endif}
end;
{$pop}

procedure klausTerminalSetRaw(var inp: text; raw: boolean);
const
  {$push}{$warnings off}
  prevState: record
    valid: boolean;
    state: tTerminalState;
  end = (valid: false);
  {$pop}
var
  state: tTerminalState;
begin
  if not prevState.valid then begin
    if not raw then exit;
    prevState.state := getTerminalState(stdInHandle(inp));
    prevState.valid := true;
  end;
  state := prevState.state;
  {$ifdef windows}
  if raw then state := state and not (ENABLE_ECHO_INPUT or ENABLE_LINE_INPUT or ENABLE_PROCESSED_INPUT);
  setConsoleMode(stdInHandle(inp), state);
  {$else}
  if raw then CFMakeRaw(state);
  TCSetAttr(stdInHandle, TCSANOW, state);
  {$endif}
end;

function klausTerminalHasChar(var inp: text): boolean;
{$ifdef windows}
var
  read: longWord;
  num: longWord = 0;
  inps: array of tInputRecord;
  i: integer;
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
{$Else}
var
  fdSet: tFDSet;
  timeout: tTimeVal;
begin
  if stdInBufNotEmpty then exit(true);
  fpFD_ZERO(fdSet);
  fpFD_SET(stdInHandle, fdSet);
  timeout.tv_sec := 0;
  timeout.tv_usec := 0;
  result := fpSelect(stdInHandle+1, @fdSet, nil, nil, @timeout) > 0;
end;
{$EndIf}

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
  if result = 0 then raise eKlausError.createFmt(ercInvalidCharAtIndex, at, [idx]);
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
    if (arg < 0) or (arg >= length(args)) then raise eKlausError.createFmt(ercInvalidFormatArgIdx, at, [arg]);
    case fmt.ft of
      ftI: begin
        if args[arg].dataType <> kdtInteger then raise eKlausError.createFmt(ercInvalidFormatArgType, at, [arg]);
        result := intToStr(args[arg].iValue);
        pad := fmt.prec - length(result);
        if result[1] <> '-' then insert(stringOfChar('0', pad), result, 1)
        else insert(stringOfChar('0', pad+1), result, 2)
      end;
      ftX: begin
        if not (args[arg].dataType in [kdtInteger, kdtChar]) then raise eKlausError.createFmt(ercInvalidFormatArgType, at, [arg]);
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
  v := klausSimple(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%%]';
  v := klausSimple(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%10i]';
  v := klausSimple(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%.4i]';
  v := klausSimple(-10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%10.4ц]';
  v := klausSimple(-10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:ц]';
  v := klausSimple(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:10Ц]';
  v := klausSimple(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:10.4Ц]';
  v := klausSimple(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-10i]';
  v := klausSimple(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-10.4I]';
  v := klausSimple(10);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%x]';
  v := klausSimple(1234567);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%10x]';
  v := klausSimple(1234567);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%.4x]';
  v := klausSimple(-1234567);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%10.4ш]';
  v := klausSimple(-1234567);
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:ш]';
  v := klausSimple(tKlausChar($0401));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:10Ш]';
  v := klausSimple(tKlausChar($0401));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:10.4Ш]';
  v := klausSimple(tKlausChar($0401));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-10x]';
  v := klausSimple(tKlausChar($0401));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-10.4X]';
  v := klausSimple(tKlausChar($0401));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%e]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%12e]';
  v := klausSimple(tKlausFloat(-1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%12.4e]';
  v := klausSimple(tKlausFloat(-1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:э]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:12э]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:12.4Э]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-12Э]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-12.4E]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%f]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%12f]';
  v := klausSimple(tKlausFloat(-1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%12.4f]';
  v := klausSimple(tKlausFloat(-1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:ф]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:12ф]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:12.4Ф]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-12Ф]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-12.4F]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%g]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%12g]';
  v := klausSimple(tKlausFloat(-1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%12.4g]';
  v := klausSimple(tKlausFloat(-1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:о]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:12о]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:12.4О]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-12О]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-12.4G]';
  v := klausSimple(tKlausFloat(1.234));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%n]';
  v := klausSimple(tKlausFloat(1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%14n]';
  v := klausSimple(tKlausFloat(-1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%14.4n]';
  v := klausSimple(tKlausFloat(-1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:ч]';
  v := klausSimple(tKlausFloat(1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:14ч]';
  v := klausSimple(tKlausFloat(1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:14.4Ч]';
  v := klausSimple(tKlausFloat(1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-14Ч]';
  v := klausSimple(tKlausFloat(1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%0:-14.4N]';
  v := klausSimple(tKlausFloat(1234567));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%14d]';
  v := klausSimple(tKlausMoment(44567.123));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%-14д]';
  v := klausSimple(tKlausMoment(44567.123));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%14t]';
  v := klausSimple(tKlausMoment(44567.123));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%-14в]';
  v := klausSimple(tKlausMoment(44567.123));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%14m]';
  v := klausSimple(tKlausMoment(44567.123));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%-14м]';
  v := klausSimple(tKlausMoment(44567.123));
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%s]';
  v := klausSimple('Привет!');
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%14с]';
  v := klausSimple('Привет!');
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
  fmt := '[%-14с]';
  v := klausSimple('Привет!');
  s := klstrFormat(fmt, [v], at);
  writeln(format('стр := формат("%s", %s); // стр = "%s"', [fmt, klausDisplayValue(v), s]));
end;

initialization
  //testKlstrFormat;
finalization
end.

