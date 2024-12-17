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

unit KlausDoer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, KlausLex, KlausDef, KlausSyn, KlausErr, KlausSrc, Controls, Forms,
  FpJson;

type
  tKlausDoer = class;
  tKlausDoerSetting = class;
  tKlausDoerView = class;

  tKlausDoerClass = class of tKlausDoer;

type
  tKlausDoerCreateTabMethod = function(const cap: string): tWinControl of object;
  tKlausDoerDestroyTabMethod = procedure(ctl: tWinControl) of object;

type
  tKlausDoerViewMode = (dvmView, dvmEdit, dvmExecute);

type
  tKlausDoer = class(tKlausStdUnit)
    private
      fWindow: tWinControl;
      fView: tKlausDoerView;
      fSetting: tKlausDoerSetting;

      procedure syncCreateWindow;
      procedure syncDestroyWindow;
    protected
      procedure beforeInit(frame: tKlausStackFrame); override;
      procedure afterDone(frame: tKlausStackFrame); override;
    public
      class var createWindowMethod: tKlausDoerCreateTabMethod;
      class var destroyWindowMethod: tKlausDoerDestroyTabMethod;
      class function createSetting: tKlausDoerSetting; virtual; abstract;
      class function createView(aOwner: tComponent; mode: tKlausDoerViewMode): tKlausDoerView; virtual; abstract;
    public
      property window: tWinControl read fWindow;
      property view: tKlausDoerView read fView;
      property setting: tKlausDoerSetting read fSetting;
  end;

type
  tKlausDoerSetting = class(tPersistent)
    private
      fCaption: string;
      fUpdateCount: integer;
      fOnChange: tNotifyEvent;

      procedure setCaption(val: string);
    protected
      procedure modified; virtual;
    public
      property caption: string read fCaption write setCaption;
      property onChange: tNotifyEvent read fOnChange write fOnChange;

      procedure updating;
      procedure updated;
      function  toJson: tJsonData; virtual;
      procedure fromJson(data: tJsonData); virtual;
  end;

type
  tKlausDoerSettings = class(tPersistent)
    private
      fDoerClass: tKlausDoerClass;
      fItems: tFPList;

      function getCount: integer;
      function getItems(idx: integer): tKlausDoerSetting;
    public
      property doerClass: tKlausDoerClass read fDoerClass;
      property count: integer read getCount;
      property items[idx: integer]: tKlausDoerSetting read getItems; default;

      constructor create(aDoerClass: tKlausDoerClass);
      destructor  destroy; override;
      procedure clear;
      function  add: tKlausDoerSetting;
      function  insert(idx: integer): tKlausDoerSetting;
      procedure remove(item: tKlausDoerSetting);
      function  indexOf(item: tKlausDoerSetting): integer;
      procedure delete(idx: integer);
      procedure move(curIdx, newIdx: integer);
      function  toJson: tJsonData;
      procedure fromJson(data: tJsonData);
  end;

type
  tKlausDoerView = class(tCustomControl)
    private
      fReadOnly: boolean;
      fOnChange: tNotifyEvent;
      fSetting: tKlausDoerSetting;
    protected
      procedure setSetting(aSetting: tKlausDoerSetting); virtual;
      procedure setReadOnly(val: boolean); virtual;
      procedure change; virtual;
    public
      class function doerClass: tKlausDoerClass; virtual; abstract;

      property readOnly: boolean read fReadOnly write setReadOnly;
      property setting: tKlausDoerSetting read fSetting write setSetting;
      property onChange: tNotifyEvent read fOnChange write fOnChange;
  end;

function  klausFindDoer(const name: string): tKlausDoerClass;
procedure klausEnumDoers(sl: tStrings);

implementation

uses
  Math, KlausPract, KlausUnitSystem;

{ Globals }

var
  theDoer: tKlausDoer = nil;

function klausFindDoer(const name: string): tKlausDoerClass;
var
  u: tKlausStdUnitClass;
begin
  u := klausFindStdUnit(name);
  if u.inheritsFrom(tKlausDoer) then result := tKlausDoerClass(u)
  else result := nil;
end;

procedure klausEnumDoers(sl: tStrings);
begin
  klausEnumStdUnits(sl, tKlausDoer);
end;

{ tKlausDoerSetting }

procedure tKlausDoerSetting.updating;
begin
  inc(fUpdateCount);
end;

procedure tKlausDoerSetting.updated;
begin
  if fUpdateCount > 0 then begin
    dec(fUpdateCount);
    if fUpdateCount = 0 then modified;
  end;
end;

function tKlausDoerSetting.toJson: tJsonData;
begin
  result := tJsonObject.create;
  (result as tJsonObject).add('caption', caption);
end;

procedure tKlausDoerSetting.fromJson(data: tJsonData);
begin
  if not (data is tJsonObject) then raise eKlausError.create(ercInvalidFileFormat, zeroSrcPt);
  updating;
  try caption := (data as tJsonObject).get('caption', '');
  finally updated; end;
end;

procedure tKlausDoerSetting.setCaption(val: string);
begin
  if fCaption <> val then begin
    updating;
    try fCaption := val;
    finally updated; end;
  end;
end;

procedure tKlausDoerSetting.modified;
begin
  if assigned(fOnChange) then fOnChange(self);
end;

{ tKlausDoerSettings }

constructor tKlausDoerSettings.create(aDoerClass: tKlausDoerClass);
begin
  inherited create;
  fDoerClass := aDoerClass;
  fItems := tFPList.create;
end;

destructor tKlausDoerSettings.destroy;
begin
  clear;
  freeAndNil(fItems);
  inherited destroy;
end;

procedure tKlausDoerSettings.clear;
var
  i: integer;
begin
  for i := count-1 downto 0 do items[i].free;
  fItems.clear;
end;

function tKlausDoerSettings.getCount: integer;
begin
  result := fItems.count;
end;

function tKlausDoerSettings.getItems(idx: integer): tKlausDoerSetting;
begin
  result := tKlausDoerSetting(fItems[idx]);
end;

function tKlausDoerSettings.add: tKlausDoerSetting;
begin
  result := doerClass.createSetting;
  fItems.add(result);
end;

function tKlausDoerSettings.insert(idx: integer): tKlausDoerSetting;
begin
  result := doerClass.createSetting;
  fItems.insert(idx, result);
end;

procedure tKlausDoerSettings.remove(item: tKlausDoerSetting);
begin
  delete(indexOf(item));
end;

function tKlausDoerSettings.indexOf(item: tKlausDoerSetting): integer;
begin
  result := fItems.indexOf(item);
end;

procedure tKlausDoerSettings.delete(idx: integer);
begin
  items[idx].free;
  fItems.delete(idx);
end;

procedure tKlausDoerSettings.move(curIdx, newIdx: integer);
begin
  fItems.move(curIdx, newIdx);
end;

function tKlausDoerSettings.toJson: tJsonData;
var
  i: integer;
begin
  result := tJsonArray.create;
  for i := 0 to count-1 do
    (result as tJsonArray).add(items[i].toJson);
end;

procedure tKlausDoerSettings.fromJson(data: tJsonData);
var
  i: integer;
  ds: tJsonObject;
  setting: tKlausDoerSetting;
begin
  if not (data is tJsonArray) then raise eKlausError.create(ercInvalidFileFormat, zeroSrcPt);
  with data as tJsonArray do
    for i := 0 to count-1 do begin
      ds := objects[i];
      setting := self.add;
      setting.fromJson(ds);
    end;
end;

{ tKlausDoerView }

procedure tKlausDoerView.setSetting(aSetting: tKlausDoerSetting);
begin
  if fSetting <> aSetting then begin
    fSetting := aSetting;
    if handleAllocated then invalidate;
  end;
end;

procedure tKlausDoerView.setReadOnly(val: boolean);
begin
  fReadOnly := val;
end;

procedure tKlausDoerView.change;
begin
  if assigned(fOnChange) then fOnChange(self);
end;

procedure tKlausDoer.syncCreateWindow;
begin
  fWindow := createWindowMethod(stdUnitName);
  fView := createView(fWindow, dvmExecute);
  fView.parent := fWindow;
  fView.align := alClient;
  fView.borderSpacing.around := 2;
  fView.setting := fSetting;
end;

procedure tKlausDoer.syncDestroyWindow;
begin
  destroyWindowMethod(fWindow);
end;

procedure tKlausDoer.beforeInit(frame: tKlausStackFrame);
var
  tn, cn: string;
  t: tKlausTask;
  ds: tKlausDoerSetting;
begin
  if theDoer <> nil then raise eKlausError.createFmt(ercDuplicateDoer, zeroSrcPt, [self.stdUnitName, theDoer.stdUnitName]);
  if not assigned(createWindowMethod) then raise eKlausError.create(ercDoerWindowNotAvailable, zeroSrcPt);
  inherited beforeInit(frame);
  theDoer := self;
  fSetting := createSetting;
  if (klausPracticum = nil)
  or not (source.module is tKlausProgram) then
    t := nil
  else begin
    tn := source.module.name;
    cn := (source.module as tKlausProgram).courseName;
    t := klausPracticum.findTask(cn, tn);
  end;
  if t <> nil then
    if t.doer = self.classType then begin
      ds := t.activeSetting;
      if ds <> nil then fSetting.assign(ds);
    end;
  frame.owner.synchronize(@syncCreateWindow);
end;

procedure tKlausDoer.afterDone(frame: tKlausStackFrame);
begin
  frame.owner.synchronize(@syncDestroyWindow);
  freeAndNil(fSetting);
  theDoer := nil;
  inherited afterDone(frame);
end;

end.
