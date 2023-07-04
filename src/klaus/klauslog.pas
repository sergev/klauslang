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

unit KlausLog;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils;

procedure logReset(name: string);
procedure logln(name: string; s: string; args: array of const); overload;
procedure logln(name: string; s: string); overload;

implementation

{$ifndef enableLogging}

procedure logReset(name: string); inline; begin end;
procedure logln(name: string; s: string; args: array of const); inline; overload; begin end;
procedure logln(name: string; s: string); overload; inline; begin end;

{$else}
uses
  U8;

const
  logPath = './';

var
  logs: tStringList;

function getLogStream(name: string): tStream;
var
  idx: integer;
begin
  name := u8Lower(name);
  idx := logs.indexOf(name);
  if idx >= 0 then
    result := tStream(logs.objects[idx])
  else begin
    result := tFileStream.create(logPath + name + '.log', fmCreate);
    logs.addObject(name, result);
  end;
end;

procedure logReset(name: string);
var
  idx: integer;
begin
  name := u8Lower(name);
  idx := logs.indexOf(name);
  if idx >= 0 then begin
    tStream(logs.objects[idx]).free;
    logs.delete(idx);
  end;
end;

procedure logln(name: string; s: string; args: array of const); overload;
const
  bv: array[boolean] of string[5] = ('false', 'true');
var
  i: integer;
  newArgs: array of tVarRec = ();
begin
  setLength(newArgs, length(args));
  for i := low(args) to high(args) do
    if args[i].vType = vtBoolean then begin
      newArgs[i].vType := vtString;
      newArgs[i].vString := @bv[args[i].vBoolean];
    end else
      newArgs[i] := args[i];
  s := format(s, newArgs);
  if s <> '' then getLogStream(name).write(pChar(s)^, length(s));
end;

procedure logln(name: string; s: string); overload;
begin
  logln(name, s, []);
end;

var
  i: integer;
initialization
  logs := tStringList.create;
  logs.sorted := true;
  logs.duplicates := dupError;
finalization
  for i := logs.count-1 downto 0 do logReset(logs[i]);
  freeAndNil(logs);
{$endif}

end.

