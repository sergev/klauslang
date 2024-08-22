unit KlausPract;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, FpJson, ComCtrls;

type
  tKlausPracticum = class;
  tKlausCourse = class;
  tKlausTask = class;

type
  tKlausPracticum = class
    private
      fDestroying: boolean;
      fCourses: tStringList;

      function getCount: integer;
      function getCourse(cn: string): tKlausCourse;
      function getCourses(idx: integer): tKlausCourse;
    protected
      procedure addCourse(item: tKlausCourse);
      procedure removeCourse(item: tKlausCourse);
    public
      property count: integer read getCount;
      property courses[idx: integer]: tKlausCourse read getCourses; default;
      property course[cn: string]: tKlausCourse read getCourse;

      constructor create;
      destructor  destroy; override;
      procedure clear;
      procedure beforeDestruction; override;
      procedure loadCourses(searchPath: string; out errMsg: string);
  end;

type
  tKlausCourse = class
    private
      fLoading: boolean;
      fDestroying: boolean;
      fOwner: tKlausPracticum;
      fName: string;
      fFileName: string;
      fCaption: string;
      fAuthor: string;
      fLicense: string;
      fURL: string;
      fDescription: string;
      fCategories: tStringList;
      fTasks: tStringList;

      function  getCatCount: integer;
      function  getCategories(idx: integer): string;
      function  getTask(tn: string): tKlausTask;
      function  getTaskCount: integer;
      function  getTasks(idx: integer): tKlausTask;
    protected
      procedure addTask(item: tKlausTask);
      procedure removeTask(item: tKlausTask);
      procedure updateCategories(renamed: string = '');
      procedure loadFromFile; virtual;
      procedure loadData(data: tJsonData);
      function  getJsonData: tJsonData;
      procedure saveData(fn: string);
    public
      class function extractCourseName(fileName: string): string;
    public
      property owner: tKlausPracticum read fOwner;
      property name: string read fName;
      property fileName: string read fFileName;
      property caption: string read fCaption write fCaption;
      property author: string read fAuthor write fAuthor;
      property license: string read fLicense write fLicense;
      property url: string read fURL write fURL;
      property description: string read fDescription write fDescription;
      property catCount: integer read getCatCount;
      property categories[idx: integer]: string read getCategories;
      property taskCount: integer read getTaskCount;
      property tasks[idx: integer]: tKlausTask read getTasks; default;
      property task[tn: string]: tKlausTask read getTask;

      constructor create(aOwner: tKlausPracticum; aFileName: string = '');
      destructor  destroy; override;
      procedure beforeDestruction; override;
      procedure renameCategory(old, new: string);
      procedure saveToFile(newFileName: string = '');
  end;

type
  tKlausTask = class
    private
      fOwner: tKlausCourse;
      fName: string;
      fCaption: string;
      fCategory: string;
      fDescription: string;

      procedure setCategory(val: string);
      procedure setName(val: string);
    protected
      procedure loadData(data: tJsonData);
      function  getJsonData: tJsonData;
    public
      property owner: tKlausCourse read fOwner;
      property name: string read fName write setName;
      property caption: string read fCaption write fCaption;
      property category: string read fCategory write setCategory;
      property description: string read fDescription write fDescription;

      constructor create(aOwner: tKlausCourse; data: tJsonData = nil);
      destructor  destroy; override;
      function  createSolution(dir: string): string;
  end;

  tCategoryTreeNode = class(tTreeNode)
    private
      fCourse: tKlausCourse;
      fCategory: string;
    public
      property course: tKlausCourse read fCourse write fCourse;
      property category: string read fCategory write fCategory;
  end;

var
  klausPracticum: tKlausPracticum = nil;

implementation

uses
  U8, KlausLex, KlausErr, KlausUtils;

resourcestring
  strNewCourseName = 'НовыйКурс%d';
  strNewCourseCaption = 'Новый курс %d';
  strNewTaskName = 'НоваяЗадача%d';
  strNewTaskCaption = 'Новая задача %d';
  strTaskFileName = '%s.klaus';
  strDefaultSolutionTepmlate = 'задача %s из %s;'#10'начало'#10#10'окончание.';

{ tKlausPracticum }

constructor tKlausPracticum.create;
begin
  inherited create;
  fCourses := tStringList.create;
  fCourses.sorted := true;
  fCourses.caseSensitive := false;
  fCourses.duplicates := dupError;
end;

destructor tKlausPracticum.destroy;
begin
  clear();
  freeAndNil(fCourses);
  inherited destroy;
end;

procedure tKlausPracticum.clear;
var
  i: integer;
begin
  for i := count-1 downto 0 do courses[i].free;
end;

procedure tKlausPracticum.beforeDestruction;
begin
  fDestroying := true;
  inherited beforeDestruction;
end;

procedure tKlausPracticum.loadCourses(searchPath: string; out errMsg: string);
var
  i: integer;
  name, sep: string;
  fn: tStringList;
begin
  clear;
  sep := '';
  errMsg := '';
  fn := tStringList.create;
  try
    {$PUSH}{$WARN SYMBOL_PLATFORM OFF}
    listFileNames(searchPath, '*.klaus-course', faHidden or faDirectory, fn);
    {$POP}
    for i := 0 to fn.count-1 do begin
      name := tKlausCourse.extractCourseName(fn[i]);
      if course[name] <> nil then continue;
      try
        tKlausCourse.create(self, fn[i]);
      except
        on e: exception do begin
          errMsg += sep + e.message;
          sep := #13#10;
        end
        else raise;
      end;
    end;
  finally
    freeAndNil(fn);
  end;
end;


function tKlausPracticum.getCount: integer;
begin
  result := fCourses.count;
end;

function tKlausPracticum.getCourse(cn: string): tKlausCourse;
var
  idx: integer;
begin
  idx := fCourses.indexOf(cn);
  if idx < 0 then result := nil else result := courses[idx];
end;

function tKlausPracticum.getCourses(idx: integer): tKlausCourse;
begin
  result := fCourses.objects[idx] as tKlausCourse;
end;

procedure tKlausPracticum.addCourse(item: tKlausCourse);
begin
  if not tKlausLexParser.isValidIdent(item.name) then raise eKlausError.createFmt(ercInvalidCourseName, zeroSrcPt, [item.name]);
  if course[item.name] <> nil then raise eKlausError.createFmt(ercDuplicateCourseName, zeroSrcPt, [item.name]);
  fCourses.addObject(item.name, item);
end;

procedure tKlausPracticum.removeCourse(item: tKlausCourse);
var
  idx: integer;
begin
  if fDestroying then exit;
  idx := fCourses.indexOfObject(item);
  if idx >= 0 then fCourses.delete(idx);
end;

{ tKlausCourse }

constructor tKlausCourse.create(aOwner: tKlausPracticum; aFileName: string = '');
var
  idx: integer;
begin
  inherited create;
  fCategories := tStringList.create;
  fCategories.sorted := true;
  fCategories.caseSensitive := false;
  fCategories.duplicates := dupIgnore;
  fTasks := tStringList.create;
  fTasks.sorted := true;
  fTasks.caseSensitive := false;
  fTasks.duplicates := dupError;
  fOwner := aOwner;
  fFileName := aFileName;
  if fFileName <> '' then begin
    fFileName := expandFileName(fFileName);
    fName := extractCourseName(fileName);
    fCaption := fName;
  end else begin
    idx := 1;
    fName := format(strNewCourseName, [idx]);
    while fOwner.course[fName] <> nil do begin
      idx += 1;
      fName := format(strNewCourseName, [idx]);
    end;
    fCaption := format(strNewCourseCaption, [idx]);
  end;
  fOwner.addCourse(self);
  if fileName <> '' then loadFromFile;
end;

destructor tKlausCourse.destroy;
var
  i: integer;
begin
  for i := taskCount-1 downto 0 do tasks[i].free;
  fOwner.removeCourse(self);
  freeAndNil(fTasks);
  freeAndNil(fCategories);
  inherited destroy;
end;

procedure tKlausCourse.beforeDestruction;
begin
  fDestroying := true;
  inherited beforeDestruction;
end;

procedure tKlausCourse.renameCategory(old, new: string);
var
  i: integer;
  s: string;
begin
  s := u8Lower(old);
  for i := 0 to taskCount-1 do
    if u8Lower(tasks[i].category) = s then
      tasks[i].fCategory := new;
  updateCategories;
end;

procedure tKlausCourse.saveToFile(newFileName: string = '');
var
  newName: string;
begin
  if newFileName = '' then newFileName := fileName;
  if newFileName = '' then newFileName := name + '.klaus-course';
  newFileName := expandFileName(newFileName);
  newName := extractCourseName(newFileName);
  if not tKlausLexParser.isValidIdent(newName) then raise eKlausError.createFmt(ercInvalidCourseName, zeroSrcPt, [newName]);
  if (u8Lower(name) <> u8Lower(newName)) and (owner.course[newName] <> nil) then raise eKlausError.createFmt(ercDuplicateCourseName, zeroSrcPt, [newName]);
  saveData(newFileName);
  owner.removeCourse(self);
  fName := newName;
  fFileName := newFileName;
  owner.addCourse(self);
end;

function tKlausCourse.getCatCount: integer;
begin
  result := fCategories.count;
end;

function tKlausCourse.getCategories(idx: integer): string;
begin
  result := fCategories[idx];
end;

function tKlausCourse.getTask(tn: string): tKlausTask;
var
  idx: integer;
begin
  idx := fTasks.indexOf(tn);
  if idx < 0 then result := nil else result := tasks[idx];
end;

function tKlausCourse.getTaskCount: integer;
begin
  result := fTasks.count;
end;

function tKlausCourse.getTasks(idx: integer): tKlausTask;
begin
  result := fTasks.objects[idx] as tKlausTask;
end;

procedure tKlausCourse.addTask(item: tKlausTask);
begin
  if not tKlausLexParser.isValidIdent(item.name) then raise eKlausError.createFmt(ercInvalidTaskName, zeroSrcPt, [item.name]);
  if task[item.name] <> nil then raise eKlausError.createFmt(ercDuplicateTaskName, zeroSrcPt, [item.name]);
  fTasks.addObject(item.name, item);
  updateCategories;
end;

procedure tKlausCourse.removeTask(item: tKlausTask);
var
  idx: integer;
begin
  if fDestroying then exit;
  idx := fTasks.indexOfObject(item);
  if idx >= 0 then begin
    fTasks.delete(idx);
    updateCategories;
  end;
end;

procedure tKlausCourse.updateCategories(renamed: string = '');
var
  s: string;
  i: integer;
begin
  if fLoading or fDestroying then exit;
  fCategories.clear;
  s := u8Lower(renamed);
  for i := 0 to taskCount-1 do
    if u8Lower(tasks[i].category) = s then
      tasks[i].fCategory := renamed;
  for i := 0 to taskCount-1 do
    if tasks[i].category <> '' then
      fCategories.add(tasks[i].category);
end;

procedure tKlausCourse.loadFromFile;
var
  data: tJsonData;
begin
  try
    fLoading := true;
    try
      data := loadJsonData(fileName);
      try
        loadData(data);
      finally
        freeAndNil(data);
      end;
    finally
      fLoading := false;
      updateCategories;
    end;
  except
    on e: exception do raise eKlausError.createFmt(ercFileReadError, zeroSrcPt, [fileName, e.message]);
    else raise;
  end;
end;

procedure tKlausCourse.loadData(data: tJsonData);
var
  arr: tJsonArray;
  i: integer;
begin
  if not (data is tJsonObject) then raise eKlausError.create(ercInvalidFileFormat, zeroSrcPt);
  with data as tJsonObject do begin
    fCaption := get('title', '');
    fAuthor := get('author', '');
    fLicense := get('license', '');
    fURL := get('url', '');
    fDescription := get('description', '');
    arr := find('tasks', jtArray) as tJsonArray;
    if arr <> nil then
      for i := 0 to arr.count-1 do
        tKlausTask.create(self, arr[i]);
  end;
end;

procedure tKlausCourse.saveData(fn: string);
var
  data: tJsonData;
begin
  data := getJsonData;
  try
    saveJsonData(fn, data);
  finally
    freeAndNil(data);
  end;
end;

function tKlausCourse.getJsonData: tJsonData;
var
  arr: tJsonArray;
  i: integer;
begin
  result := tJsonObject.create;
  with result as tJsonObject do begin
    add('title', fCaption);
    add('author', fAuthor);
    add('license', fLicense);
    add('url', fURL);
    add('description', fDescription);
    if taskCount > 0 then begin
      arr := tJsonArray.create;
      for i := 0 to taskCount-1 do
        arr.add(tasks[i].getJsonData);
      add('tasks', arr);
    end;
  end;
end;

class function tKlausCourse.extractCourseName(fileName: string): string;
begin
  result := changeFileExt(extractFileName(fileName), '');
end;

{ tKlausTask }

constructor tKlausTask.create(aOwner: tKlausCourse; data: tJsonData = nil);
var
  idx: integer;
begin
  inherited create;
  fOwner := aOwner;
  idx := 1;
  fName := format(strNewTaskName, [idx]);
  while fOwner.task[fName] <> nil do begin
    idx += 1;
    fName := format(strNewTaskName, [idx]);
  end;
  fCaption := format(strNewTaskCaption, [idx]);
  if data <> nil then loadData(data);
  fOwner.addTask(self);
end;

destructor tKlausTask.destroy;
begin
  fOwner.removeTask(self);
  inherited destroy;
end;

function tKlausTask.createSolution(dir: string): string;
var
  src: string;
  stream: tStream;
begin
  dir := excludeTrailingPathDelimiter(dir);
  if not directoryExists(dir) then
    if not forceDirectories(dir) then
      raise eKlausError.createFmt(ercCannotCreateDirectory, zeroSrcPt, [dir]);
  result := includeTrailingPathDelimiter(dir) + format(strTaskFileName, [name]);
  if not fileExists(result) then begin
    src := format(strDefaultSolutionTepmlate, [name, owner.name]);
    stream := tFileStream.create(result, fmCreate or fmShareDenyWrite);
    try stream.writeBuffer(pChar(src)^, length(src));
    finally freeAndNil(stream); end;
  end;
end;

procedure tKlausTask.setCategory(val: string);
begin
  if fCategory <> val then begin
    fCategory := val;
    owner.updateCategories(val);
  end;
end;

procedure tKlausTask.setName(val: string);
var
  idx: integer;
begin
  if fName <> val then begin
    if not tKlausLexParser.isValidIdent(val) then
      raise eKlausError.createFmt(ercInvalidTaskName, zeroSrcPt, [val]);
    if u8Lower(name) <> u8Lower(val) then begin
      idx := owner.fTasks.indexOf(val);
      if idx >= 0 then raise eKlausError.createFmt(ercDuplicateTaskName, zeroSrcPt, [val]);
      idx := owner.fTasks.indexOf(name);
      if idx >= 0 then owner.fTasks.delete(idx);
      owner.fTasks.addObject(val, self);
    end;
    fName := val;
  end;
end;

procedure tKlausTask.loadData(data: tJsonData);
begin
  if not (data is tJsonObject) then raise eKlausError.create(ercInvalidFileFormat, zeroSrcPt);
  with data as tJsonObject do begin
    fName := get('name', '');
    fCaption := get('title', '');
    fCategory := get('category', '');
    fDescription := get('description', '');
  end;
end;

function tKlausTask.getJsonData: tJsonData;
begin
  result := tJsonObject.create;
  with result as tJsonObject do begin
    add('name', fName);
    add('title', fCaption);
    add('category', fCategory);
    add('description', fDescription);
  end;
end;

initialization
  klausPracticum := tKlausPracticum.create;
finalization
  freeAndNil(klausPracticum);
end.
