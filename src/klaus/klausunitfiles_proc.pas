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

unit KlausUnitFiles_Proc;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, KlausErr, KlausLex, KlausDef, KlausSyn, KlausSrc,
  KlausUnitSystem, KlausUnitFiles;

type
  // функция файлСоздать(вх типФайла: целое; вх имя: строка; вх режим: целое): объект;
  tKlausSysProc_FileCreate = class(tKlausSysProcDecl)
    private
      fFileType: tKlausProcParam;
      fFileName: tKlausProcParam;
      fMode: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлОткрыть(вх типФайла: целое; вх имя: строка; вх режим: целое): объект;
  tKlausSysProc_FileOpen = class(tKlausSysProcDecl)
    private
      fFileType: tKlausProcParam;
      fFileName: tKlausProcParam;
      fMode: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура файлЗакрыть(вв файл: объект);
  tKlausSysProc_FileClose = class(tKlausSysProcDecl)
    private
      fFile: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура файлЗаписать(вх файл: объект; вх арг1, арг2, арг3...);
  tKlausSysProc_FileWrite = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // процедура файлПрочесть(вх файл: объект; вых арг1, арг2, арг3...);
  tKlausSysProc_FileRead = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция файлПоз(вх файл: объект): целое;
  // функция файлПоз(вх файл: объект; вх поз: целое): целое;
  // функция файлПоз(вх файл: объект; вх поз: целое; вх откуда: целое): целое;
  tKlausSysProc_FilePos = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция файлРазмер(вх файл: объект): целое;
  // функция файлРазмер(вх файл: объект; вх размер: целое): целое;
  tKlausSysProc_FileSize = class(tKlausSysProcDecl)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

type
  // функция файлЕсть(вх имя: строка): логическое;
  tKlausSysProc_FileExists = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлЕстьКат(вх имя: строка): логическое;
  tKlausSysProc_FileDirExists = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлВрмКат(вх общий: логическое): строка;
  tKlausSysProc_FileTempDir = class(tKlausSysProcDecl)
    private
      fGlobal: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлВрмИмя(вх общий: логическое; вх префикс: строка): строка;
  tKlausSysProc_FileTempName = class(tKlausSysProcDecl)
    private
      fGlobal: tKlausProcParam;
      fPrefix: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлПолныйПуть(вх путь: строка): строка;
  tKlausSysProc_FileExpandName = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлПуть(вх путь: строка): строка;
  tKlausSysProc_FileExtractPath = class(tKlausSysProcDecl)
    private
      fPath: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлИмя(вх путь: строка): строка;
  tKlausSysProc_FileExtractName = class(tKlausSysProcDecl)
    private
      fPath: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлРасширение(вх путь: строка): строка;
  tKlausSysProc_FileExtractExt = class(tKlausSysProcDecl)
    private
      fPath: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлВыполняемый(): строка;
  tKlausSysProc_FileProgName = class(tKlausSysProcDecl)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлДомКат(): строка;
  tKlausSysProc_FileHomeDir = class(tKlausSysProcDecl)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлАтрибуты(вх имя: строка): целое;
  tKlausSysProc_FileGetAttrs = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлВозраст(вх имя: строка): момент;
  tKlausSysProc_FileGetAge = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура файлПереместить(вх откуда, куда: строка);
  tKlausSysProc_FileRename = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
      fNewName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура файлУдалить(вх имя: строка);
  tKlausSysProc_FileDelete = class(tKlausSysProcDecl)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  tKlausFileSearch = class
    public
      searchRec: tSearchRec;
      destructor  destroy; override;
  end;

type
  // Базовый класс для функций листинга каталога
  tKlausSysProcFileFind = class(tKlausSysProcDecl)
    protected
      procedure fillInFileInfo(search: tKlausFileSearch; v: tKlausVarValueStruct; const at: tSrcPoint);
  end;

type
  // функция файлПервый(вх шаблон: строка; вых инфо: тФайлИнфо): объект;
  tKlausSysProc_FileFindFirst = class(tKlausSysProcFileFind)
    private
      fMask: tKlausProcParam;
      fInfo: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлСледующий(вых инфо: тФайлИнфо): логический;
  tKlausSysProc_FileFindNext = class(tKlausSysProcFileFind)
    private
      fObj: tKlausProcParam;
      fInfo: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура файлСоздКат(вх имя: строка);
  tKlausSysProc_FileMkDir = class(tKlausSysProcFileFind)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура файлУдалКат(вх имя: строка);
  tKlausSysProc_FileRmDir = class(tKlausSysProcFileFind)
    private
      fName: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция файлТекКат(): строка;
  // функция файлТекКат(вх имя: строка): строка;
  tKlausSysProc_FileCurDir = class(tKlausSysProcFileFind)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      function  isCustomParamHandler: boolean; override;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); override;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); override;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); override;
  end;

implementation

uses
  LCLIntf, Graphics, GraphType, GraphUtils, KlausUtils;

{ tKlausSysProc_FileCreate }

constructor tKlausSysProc_FileCreate.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileCreate, aPoint);
  fFileType := tKlausProcParam.create(self, 'типФайла', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fFileType);
  fFileName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fFileName);
  fMode := tKlausProcParam.create(self, 'режим', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fMode);
  declareRetValue(kdtObject);
end;

procedure tKlausSysProc_FileCreate.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  fn: tKlausString;
  rslt: tKlausObject;
  ft, mode: tKlausInteger;
begin
  ft := getSimpleInt(frame, fFileType, at);
  fn := getSimpleStr(frame, fFileName, at);
  mode := getSimpleInt(frame, fMode, at) or klausFileCreate;
  rslt := frame.owner.objects.allocate(tObject(klausInvalidPointer), at);
  try
    frame.owner.objects.put(rslt, klausGetFileType(ft, at).create(fn, mode), at);
    returnSimple(frame, klausSimpleO(rslt));
  except
    frame.owner.objects.release(rslt, at);
    raise;
  end;
end;

{ tKlausSysProc_FileOpen }

constructor tKlausSysProc_FileOpen.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileOpen, aPoint);
  fFileType := tKlausProcParam.create(self, 'типФайла', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fFileType);
  fFileName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fFileName);
  fMode := tKlausProcParam.create(self, 'режим', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fMode);
  declareRetValue(kdtObject);
end;

procedure tKlausSysProc_FileOpen.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  fn: tKlausString;
  rslt: tKlausObject;
  ft, mode: tKlausInteger;
begin
  ft := getSimpleInt(frame, fFileType, at);
  fn := getSimpleStr(frame, fFileName, at);
  mode := getSimpleInt(frame, fMode, at);
  rslt := frame.owner.objects.allocate(tObject(klausInvalidPointer), at);
  try
    frame.owner.objects.put(rslt, klausGetFileType(ft, at).create(fn, mode), at);
    returnSimple(frame, klausSimpleO(rslt));
  except
    frame.owner.objects.release(rslt, at);
    raise;
  end;
end;

{ tKlausSysProc_FileClose }

constructor tKlausSysProc_FileClose.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileClose, aPoint);
  fFile := tKlausProcParam.create(self, 'файл', aPoint, kpmInOut, source.simpleTypes[kdtObject]);
  addParam(fFile);
end;

procedure tKlausSysProc_FileClose.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  f: tKlausObject;
begin
  f := getSimpleObj(frame, fFile, at);
  getKlausObject(frame, f, tKlausFileStream, at);
  frame.owner.objects.releaseAndFree(f, at);
  setSimple(frame, fFile, klausZeroValue(kdtObject), at);
end;

{ tKlausSysProc_FileWrite }

constructor tKlausSysProc_FileWrite.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileWrite, aPoint);
end;

function tKlausSysProc_FileWrite.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_FileWrite.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  i, cnt: integer;
begin
  cnt := length(expr);
  if cnt < 2 then errWrongParamCount(cnt, 2, -1, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  for i := 1 to cnt-1 do
    if expr[i].resultType = kdtComplex then
      raise eKlausError.create(ercCannotWriteComplexType, expr[i].point);
end;

procedure tKlausSysProc_FileWrite.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_FileWrite.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  i: integer;
  stream: tKlausFileStream;
begin
  try
    stream := getKlausObject(frame, getSimpleObj(values[0]), tKlausFileStream, values[0].at) as tKlausFileStream;
    for i := 1 to length(values)-1 do begin
      if not (values[i].v is tKlausVarValueSimple) then
        raise eKlausError.create(ercCannotWriteComplexType, values[i].at);
      stream.writeSimpleValue(getSimple(values[i]), values[i].at);
    end;
  except
    klausTranslateException(frame, at);
  end;
end;

{ tKlausSysProc_FileRead }

constructor tKlausSysProc_FileRead.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileRead, aPoint);
end;

function tKlausSysProc_FileRead.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_FileRead.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  i, cnt: integer;
begin
  cnt := length(expr);
  if cnt < 2 then errWrongParamCount(cnt, 2, -1, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  for i := 1 to cnt-1 do
    if expr[i].resultType = kdtComplex then
      raise eKlausError.create(ercCannotReadComplexType, expr[i].point);
end;

procedure tKlausSysProc_FileRead.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i, cnt: integer;
begin
  modes := nil;
  cnt := length(types);
  setLength(modes, cnt);
  modes[0] := kpmInput;
  for i := 1 to cnt-1 do modes[i] := kpmOutput;
end;

procedure tKlausSysProc_FileRead.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  i: integer;
  vv: tKlausVarValueSimple;
  stream: tKlausFileStream;
begin
  try
    stream := getKlausObject(frame, getSimpleObj(values[0]), tKlausFileStream, values[0].at) as tKlausFileStream;
    for i := 1 to length(values)-1 do begin
      if not (values[i].v is tKlausVarValueSimple) then
        raise eKlausError.create(ercCannotReadComplexType, values[i].at);
      vv := values[i].v as tKlausVarValueSimple;
      try vv.setSimple(stream.readSimpleValue(vv.dataType.dataType, values[i].at), values[i].at);
      except klausTranslateException(frame, values[i].at); end;
    end;
  except
    klausTranslateException(frame, at);
  end;
end;

{ tKlausSysProc_FilePos }

constructor tKlausSysProc_FilePos.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FilePos, aPoint);
  declareRetValue(kdtInteger);
end;

function tKlausSysProc_FilePos.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_FilePos.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 1) or (cnt > 3) then errWrongParamCount(cnt, 1, 3, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  if cnt > 1 then checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
  if cnt > 2 then checkCanAssign(kdtInteger, expr[2].resultTypeDef, expr[2].point);
end;

procedure tKlausSysProc_FilePos.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_FilePos.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  origin: tSeekOrigin;
  stream: tKlausFileStream;
begin
  cnt := length(values);
  origin := soBeginning;
  if cnt >= 3 then case getSimpleInt(values[2]) of
    klausFilePosFromEnd: origin := soEnd;
    klausFilePosFromCurrent: origin := soCurrent;
  end;
  try
    stream := getKlausObject(frame, getSimpleObj(values[0]), tKlausFileStream, values[0].at) as tKlausFileStream;
    if cnt >= 2 then stream.seek(getSimpleInt(values[1]), origin);
    returnSimple(frame, klausSimpleI(stream.position));
  except
    klausTranslateException(frame, at);
  end;
end;

{ tKlausSysProc_FileSize }

constructor tKlausSysProc_FileSize.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileSize, aPoint);
  declareRetValue(kdtInteger);
end;

function tKlausSysProc_FileSize.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_FileSize.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if (cnt < 1) or (cnt > 2) then errWrongParamCount(cnt, 1, 2, at);
  checkCanAssign(kdtObject, expr[0].resultTypeDef, expr[0].point);
  if cnt > 1 then checkCanAssign(kdtInteger, expr[1].resultTypeDef, expr[1].point);
end;

procedure tKlausSysProc_FileSize.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_FileSize.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  stream: tKlausFileStream;
begin
  cnt := length(values);
  try
    stream := getKlausObject(frame, getSimpleObj(values[0]), tKlausFileStream, values[0].at) as tKlausFileStream;
    if cnt >= 2 then stream.size := getSimpleInt(values[1]);
    returnSimple(frame, klausSimpleI(stream.size));
  except
    klausTranslateException(frame, at);
  end;
end;

{ tKlausSysProc_FileExists }

constructor tKlausSysProc_FileExists.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileExists, aPoint);
  fName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_FileExists.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  fn: tKlausString;
begin
  fn := getSimpleStr(frame, fName, at);
  returnSimple(frame, klausSimpleB(fileExists(fn)));
end;

{ tKlausSysProc_FileDirExists }

constructor tKlausSysProc_FileDirExists.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileDirExists, aPoint);
  fName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_FileDirExists.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  fn: tKlausString;
begin
  fn := getSimpleStr(frame, fName, at);
  returnSimple(frame, klausSimpleB(directoryExists(fn)));
end;

{ tKlausSysProc_FileTempDir }

constructor tKlausSysProc_FileTempDir.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileTempDir, aPoint);
  fGlobal := tKlausProcParam.create(self, 'общий', aPoint, kpmInput, source.simpleTypes[kdtBoolean]);
  addParam(fGlobal);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileTempDir.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleS(getTempDir(getSimpleBool(frame, fGlobal, at))));
end;

{ tKlausSysProc_FileTempName }

constructor tKlausSysProc_FileTempName.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileTempName, aPoint);
  fGlobal := tKlausProcParam.create(self, 'общий', aPoint, kpmInput, source.simpleTypes[kdtBoolean]);
  addParam(fGlobal);
  fPrefix := tKlausProcParam.create(self, 'префикс', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fPrefix);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileTempName.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  td: string;
begin
  td := getTempDir(getSimpleBool(frame, fGlobal, at));
  returnSimple(frame, klausSimpleS(getTempFileName(td, getSimpleStr(frame, fPrefix, at))));
end;

{ tKlausSysProc_FileExpandName }

constructor tKlausSysProc_FileExpandName.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileExpandName, aPoint);
  fName := tKlausProcParam.create(self, 'путь', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileExpandName.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleS(expandFileName(getSimpleStr(frame, fName, at))));
end;

{ tKlausSysProc_FileExtractPath }

constructor tKlausSysProc_FileExtractPath.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileExtractPath, aPoint);
  fPath := tKlausProcParam.create(self, 'путь', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fPath);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileExtractPath.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  s: tKlausString;
begin
  s := extractFilePath(getSimpleStr(frame, fPath, at));
  returnSimple(frame, klausSimpleS(s));
end;

{ tKlausSysProc_FileExtractName }

constructor tKlausSysProc_FileExtractName.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileExtractName, aPoint);
  fPath := tKlausProcParam.create(self, 'путь', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fPath);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileExtractName.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  s: tKlausString;
begin
  s := getSimpleStr(frame, fPath, at);
  returnSimple(frame, klausSimpleS(extractFileName(s)));
end;

{ tKlausSysProc_FileExtractExt }

constructor tKlausSysProc_FileExtractExt.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileExtractExt, aPoint);
  fPath := tKlausProcParam.create(self, 'путь', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fPath);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileExtractExt.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  s: tKlausString;
begin
  s := getSimpleStr(frame, fPath, at);
  returnSimple(frame, klausSimpleS(extractFileExt(s)));
end;

{ tKlausSysProc_FileProgName }

constructor tKlausSysProc_FileProgName.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileProgName, aPoint);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileProgName.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  v: tKlausVariable;
begin
  v := frame.varByName(klausVarName_ExecFilename, at);
  returnSimple(frame, (v.value as tKlausVarValueSimple).simple);
end;

{ tKlausSysProc_FileHomeDir }

constructor tKlausSysProc_FileHomeDir.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileHomeDir, aPoint);
  declareRetValue(kdtString);
end;

procedure tKlausSysProc_FileHomeDir.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimpleS(getUserDir));
end;

{ tKlausSysProc_FileGetAttrs }

constructor tKlausSysProc_FileGetAttrs.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileGetAttrs, aPoint);
  fName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  declareRetValue(kdtInteger);
end;

procedure tKlausSysProc_FileGetAttrs.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  rslt: tKlausInteger;
begin
  rslt := fileGetAttr(getSimpleStr(frame, fName, at));
  if rslt = -1 then raise eInOutError.create(sysErrorMessage(getLastOsError));
  returnSimple(frame, klausSimpleI(rslt));
end;

{ tKlausSysProc_FileGetAge }

constructor tKlausSysProc_FileGetAge.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileGetAge, aPoint);
  fName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  declareRetValue(kdtMoment);
end;

procedure tKlausSysProc_FileGetAge.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  age: longInt;
begin
  age := fileAge(getSimpleStr(frame, fName, at));
  if age = -1 then raise eInOutError.create(sysErrorMessage(getLastOsError));
  returnSimple(frame, klausSimpleM(fileDateToDateTime(age)));
end;

{ tKlausSysProc_FileRename }

constructor tKlausSysProc_FileRename.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileRename, aPoint);
  fName := tKlausProcParam.create(self, 'откуда', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
  fNewName := tKlausProcParam.create(self, 'куда', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fNewName);
end;

procedure tKlausSysProc_FileRename.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  rslt: boolean;
begin
  rslt := renameFile(getSimpleStr(frame, fName, at), getSimpleStr(frame, fNewName, at));
  if not rslt then raise eInOutError.create(sysErrorMessage(getLastOsError));
end;

{ tKlausSysProc_FileDelete }

constructor tKlausSysProc_FileDelete.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileDelete, aPoint);
  fName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
end;

procedure tKlausSysProc_FileDelete.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  rslt: boolean;
begin
  rslt := deleteFile(getSimpleStr(frame, fName, at));
  if not rslt then raise eInOutError.create(sysErrorMessage(getLastOsError));
end;

{ tKlausFileSearch }

destructor tKlausFileSearch.destroy;
begin
  findClose(searchRec);
  inherited destroy;
end;

{ tKlausSysProcFileFind }

procedure tKlausSysProcFileFind.fillInFileInfo(search: tKlausFileSearch; v: tKlausVarValueStruct; const at: tSrcPoint);
var
  mv: tKlausVarValueSimple;
begin
  mv := v.getMember('имя', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimpleS(search.searchRec.name), at);
  mv := v.getMember('размер', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimpleI(search.searchRec.size), at);
  mv := v.getMember('атрибуты', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimpleI(search.searchRec.attr), at);
  mv := v.getMember('возраст', at) as tKlausVarValueSimple;
  mv.setSimple(klausSimpleM(fileDateToDateTime(search.searchRec.time)), at);
end;

{ tKlausSysProc_FileFindFirst }

constructor tKlausSysProc_FileFindFirst.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileFindFirst, aPoint);
  fMask := tKlausProcParam.create(self, 'шаблон', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fMask);
  fInfo := tKlausProcParam.create(self, 'инфо', aPoint, kpmOutput, findTypeDef(klausTypeName_FileInfo));
  addParam(fInfo);
  declareRetValue(kdtObject);
end;

procedure tKlausSysProc_FileFindFirst.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  path: string;
  rslt: tKlausObject = 0;
  search: tKlausFileSearch;
begin
  search := tKlausFileSearch.create;
  try
    path := getSimpleStr(frame, fMask, at);
    if findFirst(path, longInt($FFFFFFFF), search.searchRec) = 0 then begin
      rslt := frame.owner.objects.allocate(search, at);
      fillInFileInfo(search, frame.varByDecl(fInfo, at).value as tKlausVarValueStruct, at);
    end else
      freeAndNil(search);
    returnSimple(frame, klausSimpleO(rslt));
  except
    freeAndNil(search);
    raise;
  end;
end;

{ tKlausSysProc_FileFindNext }

constructor tKlausSysProc_FileFindNext.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileFindNext, aPoint);
  fObj := tKlausProcParam.create(self, 'о', aPoint, kpmInput, source.simpleTypes[kdtObject]);
  addParam(fObj);
  fInfo := tKlausProcParam.create(self, 'инфо', aPoint, kpmOutput, findTypeDef(klausTypeName_FileInfo));
  addParam(fInfo);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_FileFindNext.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  rslt: tKlausBoolean;
  search: tKlausFileSearch;
begin
  search := getKlausObject(frame, getSimpleObj(frame, fObj, at), tKlausFileSearch, at) as tKlausFileSearch;
  rslt := findNext(search.searchRec) = 0;
  if rslt then fillInFileInfo(search, frame.varByDecl(fInfo, at).value as tKlausVarValueStruct, at);
  returnSimple(frame, klausSimpleB(rslt));
end;

{ tKlausSysProc_FileMkDir }

constructor tKlausSysProc_FileMkDir.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileMkDir, aPoint);
  fName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
end;

procedure tKlausSysProc_FileMkDir.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  {$push}{$i+}
  mkDir(getSimpleStr(frame, fName, at));
  {$pop}
end;

{ tKlausSysProc_FileRmDir }

constructor tKlausSysProc_FileRmDir.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileRmDir, aPoint);
  fName := tKlausProcParam.create(self, 'имя', aPoint, kpmInput, source.simpleTypes[kdtString]);
  addParam(fName);
end;

procedure tKlausSysProc_FileRmDir.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  {$push}{$i+}
  rmDir(getSimpleStr(frame, fName, at));
  {$pop}
end;

{ tKlausSysProc_FileCurDir }

constructor tKlausSysProc_FileCurDir.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FileCurDir, aPoint);
  declareRetValue(kdtString);
end;

function tKlausSysProc_FileCurDir.isCustomParamHandler: boolean;
begin
  result := true;
end;

procedure tKlausSysProc_FileCurDir.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  cnt: integer;
begin
  cnt := length(expr);
  if cnt > 1 then errWrongParamCount(cnt, 0, 1, at);
  if cnt > 0 then checkCanAssign(kdtString, expr[0].resultTypeDef, expr[0].point);
end;

procedure tKlausSysProc_FileCurDir.getCustomParamModes(
  types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
var
  i: integer;
begin
  modes := nil;
  setLength(modes, length(types));
  for i := 0 to length(modes)-1 do modes[i] := kpmInput;
end;

procedure tKlausSysProc_FileCurDir.customRun(
  frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
var
  cnt: integer;
  rslt: string = '';
begin
  cnt := length(values);
  try
    {$push}{$i+}
    if cnt > 0 then chDir(getSimpleStr(values[0]));
    getDir(0, rslt);
    {$pop}
    returnSimple(frame, klausSimpleS(rslt));
  except
    klausTranslateException(frame, at);
  end;
end;

end.

