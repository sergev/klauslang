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

program KlausCon;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Classes, SysUtils, CustApp, FileInfo, KlausUtils, KlausLex, KlausDef, KlausErr, KlausSrc,
  KlausUnitSystem, KlausUnitSystem_Proc, KlausUnitTerminal, KlausUnitTerminal_Proc,
  KlausUnitFiles, KlausUnitFiles_Proc;

{$R *.ver.res}

type
  tKlausApplication = class(tCustomApplication)
    private
      fTSI, fTSO, fTSE: tKlausTerminalState;
    protected
      procedure doRun; override;
      procedure displayException(e: tObject);
      procedure writeHelp;
      procedure runProgram(const fileName: string; args: tStrings);
    public
      constructor create(theOwner: tComponent); override;
      destructor destroy; override;
      procedure initTerminalState;
      procedure restoreTerminalState;
  end;

resourcestring
  strVersion = 'Версия %s';
  strRuntimeError = 'Исключение %s';
  strKlausException = '%s: %s';
  strAtLinePos = 'В файле "%s" (строка %d, символ %d).';
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

procedure tKlausApplication.initTerminalState;
begin
  fTSI := klausGetTerminalState(tTextRec(input).handle);
  fTSO := klausGetTerminalState(tTextRec(stdOut).handle);
  fTSE := klausGetTerminalState(tTextRec(stdErr).handle);
  {$ifdef windows}
  setConsoleOutputCP(CP_UTF8);
  setTextCodepage(stdOut, CP_UTF8);
  setTextCodepage(stdErr, CP_UTF8);
  klausSetTerminalState(tTextRec(input).handle, fTSI or ENABLE_VIRTUAL_TERMINAL_INPUT);
  klausSetTerminalState(tTextRec(stdOut).handle, fTSO or ENABLE_VIRTUAL_TERMINAL_PROCESSING);
  klausSetTerminalState(tTextRec(stdErr).handle, fTSE or ENABLE_VIRTUAL_TERMINAL_PROCESSING);
  {$endif}
end;

procedure tKlausApplication.restoreTerminalState;
begin
  klausSetTerminalState(tTextRec(input).handle, fTSI);
  klausSetTerminalState(tTextRec(stdOut).handle, fTSO);
  klausSetTerminalState(tTextRec(stdErr).handle, fTSE);
end;

procedure tKlausApplication.runProgram(const fileName: string; args: tStrings);
var
  s: tFileStream;
  r: tKlausRuntime;
  src: tKlausSource;
  p: tKlausLexParser;
begin
  initTerminalState;
  try
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
  finally
    restoreTerminalState;
  end;
end;

procedure tKlausApplication.displayException(e: tObject);
var
  s: string;
  pt: tSrcPoint;
begin
  s := e.className;
  if e is eKlausLangException then s := (e as eKlausLangException).message
  else if e is exception then s += ': ' + (e as exception).message;
  writeln(stderr, format(strRuntimeError, [s]));
  if (e is eKlausError) then pt := (e as eKlausError).point
  else if (e is eKlausLangException) then pt := (e as eKlausLangException).point
  else pt := zeroSrcPt;
  if not srcPointEmpty(pt) then writeln(stderr, format(strAtLinePos, [pt.fileName, pt.line, pt.pos]));
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
      raise eKlausError.create(ercMissingProgramFilename, zeroSrcPt);
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
  try
    application.title := 'Клаус';
    application.run;
  finally
    application.free;
  end;
end.

