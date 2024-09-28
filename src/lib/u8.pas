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

unit U8;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LazUTF8;

const
  CR    = #13;
  LF    = #10;
  Tab   = #9;
  Space = #32;

type
  u8Char = string[5]; // до 4 байт + нуль-терминатор

  function u8Valid(p: pChar): boolean;
  function u8Valid(c: u8Char): boolean;

  function u8Size(c: char): byte;
  function u8Size(p: pChar): byte;
  function u8Size(c: u8Char): byte;

  function u8Start(p: pChar): boolean; inline;

  function u8CharCount(const s: string): ptrInt;
  function u8CharCount(p: pChar; len: ptrInt): ptrInt;

  function u8Chr(p: pChar): u8Char;
  function u8Chr(const s: string): u8Char;

  function u8GetChar(var p: pChar): u8Char;
  function u8GetCharBytes(var p: pChar): longWord;
  function u8ReadChar(stream: tStream): u8Char;
  function u8ReadChar(var inp: text): u8Char; // iocheck

  function u8CharBytes(p: pChar): longWord;
  function u8CharFromBytes(c: longWord): u8Char;

  function u8SkipChars(p: pChar; count: integer): pChar;
  function u8SkipChars(s: string; count: integer): pChar;

  function u8Copy(const s: string; idx, count: integer): string;

  function u8SkipCharsLeft(p, bound: pChar; count: integer): pChar;
  function u8SkipCharsLeft(s: string; idx, count: integer): pChar;

  function u8Upper(const s: string): string;
  function u8Lower(const s: string): string;

  function uniToU8(cp: longWord): u8Char;
  function u8ToUni(p: pChar): longWord;
  function u8ToUni(c: u8Char): longWord;

  function boolStr(v: boolean; const strTrue, strFalse: string): string; inline;

implementation

{$ifdef windows}uses Windows;{$endif}

const
  u8mask = %11000000;
  u8next = %10000000;

// Возвращает true, если передан корректный символ UTF8
// размером не более 4 байт
function u8Valid(p: pChar): boolean;
var
  i, len: integer;
begin
  len := u8Size(p);
  if len = 0 then exit(false);
  p += 1;
  for i := 2 to len do begin
    if p^ = #0 then exit(false);
    if (byte(p^) and u8mask) <> u8next then exit(false);
    p += 1;
  end;
  result := true;
end;

// Возвращает true, если передан корректный символ UTF8
function u8Valid(c: u8Char): boolean;
begin
  if length(c) < 1 then
    result := false
  else begin
    c[length(c)+1] := #0;
    result := u8Valid(@c[1]);
  end;
end;

function u8Size(c: char): byte;
begin
  case c of
    #1..#127:   result := 1;
    #192..#223: result := 2;
    #224..#239: result := 3;
    #240..#247: result := 4;
  else
    result := 0;
  end;
end;

// Возвращает размер в байтах символа UTF8. Для #0 возвращает 0.
// Для некорректного начала символа возвращает 0.
function u8Size(p: pChar): byte;
begin
  if p = nil then exit(0);
  result := u8Size(p^);
end;

// Возвращает размер в байтах символа UTF8. Для #0 возвращает 0.
// Для некорректного начала символа возвращает 0.
function u8Size(c: u8Char): byte;
begin
  if c = '' then exit(0);
  result := u8Size(c[1]);
end;

// Возвращает true, если p указывает на начало символа
function u8Start(p: pChar): boolean;
begin
  if p = nil then result := false
  else result := byte(p^) and u8mask <> u8next;
end;

// Возвращает количество кодпойнтов в строке
function u8CharCount(const s: string): PtrInt;
begin
  result := UTF8LengthFast(s);
end;

// Возвращает количество кодпойнтов в строке
function u8CharCount(p: pChar; len: ptrInt): PtrInt;
begin
  result := UTF8LengthFast(p, len);
end;

// Преобразует longWord в u8Char.
// Предполагает, что передан корректный символ.
function u8CharFromBytes(c: longWord): u8Char;
begin
  result := '';
  move(c, result[1], sizeOf(c));
  result[0] := char(u8Size(pChar(@c)));
  result[byte(result[0])+1] := #0;
end;

// Возвращает указатель, сдвинутый вправо на указанное кол-во символов.
// Если по дороге встретился #0 или некорректный символ, возвращает указатель на него.
function u8SkipChars(p: pChar; count: integer): pChar;
var
  i, size: integer;
begin
  result := p;
  if p = nil then exit;
  for i := 0 to count-1 do begin
    size := u8Size(result);
    if size = 0 then break;
    inc(result, size);
  end;
end;

// Возвращает указатель, сдвинутый вправо на указанное кол-во символов.
// Если по дороге встретился #0 или некорректный символ, возвращает указатель на него.
function u8SkipChars(s: string; count: integer): pChar;
begin
  result := u8SkipChars(pChar(s), count);
end;

function u8Copy(const s: string; idx, count: integer): string;
// Возвращает подстроку переданной строки длиной count символов, начаиная с указанного idx символа
var
  p1, p2: pChar;
begin
  p1 := u8SkipChars(s, idx);
  if p1 = nil then exit('');
  p2 := u8SkipChars(p1, count);
  if p2 = nil then exit('');
  setLength(result, p2-p1);
  move(p1^, pChar(result)^, p2-p1);
end;

// Возвращает указатель, сдвинутый влево на указанное кол-во символов,
// но не левее переданного указателя на начало строки.
function u8SkipCharsLeft(p, bound: pChar; count: integer): pChar;
var
  i: integer = 0;
begin
  result := p;
  if p = nil then exit;
  while result > bound do begin
    if i >= count then break;
    result -= 1;
    if byte(result^) and u8mask <> u8next then inc(i);
  end;
end;

// Возвращает указатель, сдвинутый влево относительно переданного индекса
// на указанное кол-во символов, но не левее начала строки.
function u8SkipCharsLeft(s: string; idx, count: integer): pChar;
begin
  result := u8SkipCharsLeft(pChar(s)+idx-1, pChar(s), count);
end;

// Возвращает символ UTF8. Байт в возвращаемой строке, следующий
// за окончанием символа, приравнивает нулю. Предполагает, что
// передан указатель на начало корректного символа.
function u8Chr(p: pChar): u8Char;
begin
  result[0] := char(u8Size(p));
  move(p^, result[1], byte(result[0]));
  result[byte(result[0])+1] := #0;
end;

// Возвращает символ UTF8.
// Предполагает, что передан указатель на начало корректного символа.
function u8Chr(const s: string): u8Char;
begin
  result := u8Chr(pChar(s));
end;

// Возвращает символ UTF8.
// Предполагает, что передан указатель на начало корректного символа.
function u8CharBytes(p: pChar): longWord;
begin
  result := 0;
  move(p^, result, u8Size(p));
end;

// Возвращает символ UTF8 и сдвигает указатель вправо на его размер.
// Байт в возвращаемой строке, следующий за окончанием символа, приравнивает нулю.
// Предполагает, что передан указатель на начало корректного символа.
// В случае некорректного символа сдвигает p на 1 байт, чтобы не виснуть в циклах.
function u8GetChar(var p: pChar): u8Char;
begin
  result := u8Chr(p);
  if result = '' then p += 1
  else p += byte(result[0]);
end;

// Возвращает символ UTF8 и сдвигает указатель вправо на его размер.
// Предполагает, что передан указатель на начало корректного символа.
// В случае некорректного символа сдвигает p на 1 байт, чтобы не виснуть в циклах.
function u8GetCharBytes(var p: pChar): longWord;
var
  size: byte;
begin
  result := 0;
  size := u8Size(p);
  move(p^, result, size);
  if size <= 0 then p += 1 else p += size;
end;

// Читает символ UTF8 из потока и проверяет его корректность.
// В случае конца потока возвращает пустую строку.
// В случае некорректного символа создаёт исключение EStreamError.
function u8ReadChar(stream: tStream): u8Char;
const
  err = 'Invalid UTF-8 character in the input stream.';
var
  cnt: byte;
begin
  result := '';
  fillChar(result[0], sizeOf(result), 0);
  cnt := stream.read(result[1], 1);
  if cnt = 0 then exit;
  result[0] := char(u8Size(@result[1]));
  if result[0] = #0 then
    raise eStreamError.create(err)
  else if result[0] > #1 then begin
    cnt := stream.read(result[2], byte(result[0])-1);
    if cnt <> byte(result[0])-1 then raise eStreamError.create(err);
  end;
  for cnt := 2 to length(result) do
    if (byte(result[cnt]) and u8mask) <> u8next then raise eStreamError.create(err);
end;

// Читает символ из консоли или перенаправленного потока ввода.
// При необходимости запрашивает пользовательский ввод;
// в случае конца потока возвращает символ #26.
function u8ReadChar(var inp: text): u8Char; iocheck;
{$push}{$i-}
  function readChar(var inp: text): char;
  {$ifdef windows}
  var
    cnt: longWord;
  {$endif}
  begin
    {$ifdef windows}
    cnt := 0;
    result := #0;
    if not readFile(tTextRec(inp).handle, result, 1, cnt, nil) then begin
      InOutRes := 100;
      exit;
    end;
    if cnt <= 0 then result := #26;
    {$else}
    result := #0;
    read(inp, result);
    {$endif}
  end;

{$ifdef windows}
const
  isConsole: record
    yes: boolean;
    valid: boolean;
  end = (yes: true; valid: false);
var
  c: char;
  mode: longWord = 0;
{$endif}
var
  i: integer;
begin
  if InOutRes <> 0 then exit('');
  {$ifdef windows}
  if not isConsole.valid then begin
    isConsole.yes := getConsoleMode(tTextRec(inp).handle, mode);
    isConsole.valid := true;
  end;
  if isConsole.yes then begin
    c := readChar(inp);
    if InOutRes <> 0 then exit('');
    result := ConsoleToUTF8(c);
    exit;
  end;
  {$endif}
  result[1] := readChar(inp);
  if InOutRes <> 0 then exit('');
  result[0] := char(u8Size(result[1]));
  result[byte(result[0])+1] := #0;
  for i := 2 to byte(result[0]) do begin
    result[i] := readChar(inp);
    if InOutRes <> 0 then exit('');
    if (byte(result[i]) and u8mask) <> u8next then begin
      InOutRes := 106;
      break;
    end;
  end;
{$pop}
end;

// Возвращает переданную строку в верхнем регистре
function u8Upper(const s: string): string;
begin
  result := UTF8UpperCase(s);
end;

// Возвращает переданную строку в нижнем регистре
function u8Lower(const s: string): string;
begin
  result := UTF8LowerCase(s);
end;

// Возвращает символ, соответствующий переданному кодпойнту Unicode.
function uniToU8(cp: longWord): u8Char;
begin
  if cp = 0 then result := ''
  else result := UnicodeToUTF8(cp);
end;

// Возвращает кодпойнт Unicode, соответствующий переданному символу UTF8
function u8ToUni(p: pChar): longWord;
var
  len: integer;
begin
  if p^ = #0 then result := 0
  else result := UTF8CodepointToUnicode(p, len);
end;

// Возвращает кодпойнт Unicode, соответствующий переданному символу UTF8
function u8ToUni(c: u8Char): longWord;
var
  len: integer;
begin
  if c = '' then
    result := 0
  else begin
    c[length(c)+1] := #0;
    result := UTF8CodepointToUnicode(@c[1], len);
  end;
end;

// Возвращает строковое значение для переданного логического
function boolStr(v: boolean; const strTrue, strFalse: string): string; inline;
begin
  if v then result := strTrue else result := strFalse;
end;

end.

