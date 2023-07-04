program KlausCon;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, FileInfo, KlausUtils, KlausLex, KlausDef, KlausErr, KlausSrc,
  KlausUnitSystem, KlausUnitSystem_Proc;

type
  tKlausApplication = class(tCustomApplication)
    protected
      procedure doRun; override;
      procedure displayException(e: tObject);
      procedure writeHelp;
      procedure runProgram(const fileName: string; args: tStrings);
    public
      constructor create(theOwner: tComponent); override;
      destructor destroy; override;
  end;

resourcestring
  strVersion = 'Версия %s';
  strRuntimeError = 'Исключение %s';
  strKlausException = '%s: %s';
  strAtLinePos = 'Строка %d, символ %d.';
  strDeveloper = 'Разработчик %s';
  strUsage = 'Использование: %s <имя-файла> [параметры]'#10+
    '    имя-файла -- имя исходного файла Клаус, содержащего выполняемую программу'#10+
    '    параметры -- аргументы командной строки, которые будут переданы выполняемой программе';

var
  application: tKlausApplication;

{ tKlausApplication }

constructor tKlausApplication.create(theOwner: tComponent);
begin
  inherited;
  stopOnException := true;
end;

destructor tKlausApplication.destroy;
begin
  inherited;
end;

procedure tKlausApplication.runProgram(const fileName: string; args: tStrings);
var
  s: tFileStream;
  r: tKlausRuntime;
  src: tKlausSource;
  p: tKlausLexParser;
begin
  s := tFileStream.create(fileName, fmOpenRead or fmShareDenyWrite);
  p := tKlausLexParser.create(s);
  try src := tKlausSource.create(p);
  finally freeAndNil(p); end;
  try
    r := tKlausRuntime.create(src);
    try
      try
        try r.run(fileName, args);
        finally exitCode := r.exitCode; end;
      except
        on e: eKlausLangException do begin
          e.message := format(strKlausException, [e.name, e.message]);
          e.finalizeData;
          raise;
        end;
        else raise;
      end;
    finally
      freeAndNil(r);
    end;
  finally
    freeAndNil(src);
  end;
end;

procedure tKlausApplication.displayException(e: tObject);
var
  s: string;
  l: integer = 0;
  p: integer = 0;
begin
  s := e.className;
  if e is eKlausLangException then s := (e as eKlausLangException).message
  else if e is exception then s += ': ' + (e as exception).message;
  writeln(stderr, format(strRuntimeError, [s]));
  if (e is eKlausError) then begin
    l := (e as eKlausError).line;
    p := (e as eKlausError).pos;
  end else if (e is eKlausLangException) then begin
    l := (e as eKlausLangException).line;
    p := (e as eKlausLangException).pos;
  end;
  if (p > 0) then writeln(stderr, format(strAtLinePos, [l, p]));
end;

procedure tKlausApplication.writeHelp;
var
  ver: tFileVersionInfo;
begin
  ver := tFileVersionInfo.create(application);
  try
    ver.enabled := true;
    with ver.versionStrings do begin
      writeln(stderr, values['FileDescription']);
      writeln(stderr, format(strVersion, [values['FileVersion']]));
      writeln(stderr, format(strDeveloper, [values['CompanyName']]));
      writeln(stderr, values['Comments']);
      writeln(stderr, values['LegalCopyright']);
      writeln(stderr, values['LegalTrademarks']);
      writeln(stderr, '');
      writeln(stderr, format(strUsage, [values['OriginalFilename']]));
      writeln(stderr, '');
    end;
  finally
    freeAndNil(ver);
  end;
end;

procedure tKlausApplication.doRun;
var
  i: integer;
  fileName: string;
  sl: tStringList = nil;
begin
  try
    if paramCount < 1 then begin
      writeHelp;
      raise eKlausError.create(ercMissingProgramFilename, 0, 0);
    end;
    try
      if paramCount >= 2 then begin
        sl := tStringList.create;
        for i := 2 to paramCount do sl.add(paramStr(i));
      end;
      fileName := expandFileName(paramStr(1));
      runProgram(fileName, sl);
    finally
      freeAndNil(sl);
    end;
  except
    on e: tObject do begin
      displayException(e);
      exitCode := -1;
    end;
  end;
  terminate;
end;

{$R *.res}

begin
  application := tKlausApplication.create(nil);
  application.title := 'Клаус';
  application.run;
  application.free;
end.

