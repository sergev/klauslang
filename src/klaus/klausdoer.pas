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
  Dialogs, FpJson, FrameDoerError;

type
  tKlausDoer = class;
  tKlausDoerSettings = class;
  tKlausDoerSetting = class;
  tKlausDoerView = class;

  tKlausDoerClass = class of tKlausDoer;

type
  tKlausDoerCreateTabMethod = function(const cap: string): tWinControl of object;
  tKlausDoerDestroyTabMethod = procedure(ctl: tWinControl) of object;

type
  tKlausDoerViewMode = (kdvmView, kdvmEdit, kdvmExecute);

type
  tKlausDoerCapability = (kdcImportSettings, kdcExportSettings);
  tKlausDoerCapabilities = set of tKlausDoerCapability;

type
  tKlausDoerSpeed = (kdsSlowest, kdsSlow, kdsMedium, kdsFast, kdsFastest, kdsImmediate);

var
  klausDoerSpeed: tKlausDoerSpeed = kdsSlow;

resourcestring
  strKlausDoerSettingFileExt = '.klaus-setting';

type
  tKlausDoer = class(tKlausStdUnit)
    private
      fWindow: tWinControl;
      fView: tKlausDoerView;
      fError: tDoerErrorFrame;
      fSetting: tKlausDoerSetting;
      fSettingCaption: string;
      fStrParam: string;

      procedure syncCreateWindow;
      procedure syncDestroyWindow;
      procedure syncErrorMessage;
    protected
      procedure beforeInit(frame: tKlausStackFrame); override;
      procedure afterDone(frame: tKlausStackFrame); override;
    public
      class var createWindowMethod: tKlausDoerCreateTabMethod;
      class var destroyWindowMethod: tKlausDoerDestroyTabMethod;
      class function  createSetting: tKlausDoerSetting; virtual; abstract;
      class function  createView(aOwner: tComponent; mode: tKlausDoerViewMode): tKlausDoerView; virtual; abstract;
      class function  capabilities: tKlausDoerCapabilities; virtual;
      class procedure importSettingsDlgSetup(dlg: tOpenDialog); virtual;
      class procedure importSettings(settings: tKlausDoerSettings; fileName: string); virtual;
      class procedure exportSettingsDlgSetup(dlg: tSaveDialog); virtual;
      class procedure exportSettings(settings: tKlausDoerSettings; fileName: string); virtual;
    public
      property window: tWinControl read fWindow;
      property view: tKlausDoerView read fView;
      property setting: tKlausDoerSetting read fSetting;
      property error: tDoerErrorFrame read fError;

      procedure errorMessage(frame: tKlausStackFrame; msg: string);
      procedure errorMessage(frame: tKlausStackFrame; msg: string; args: array of const);
  end;

type
  tKlausDoerSetting = class(tPersistent)
    private
      fCaption: string;
      fUpdateCount: integer;
      fOnChange: tNotifyEvent;

      procedure setCaption(val: string);
    protected
      procedure assignTo(dest: tPersistent); override;
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
    protected
      procedure assignTo(dest: tPersistent); override;
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
      fOwnSetting: boolean;
      fReadOnly: boolean;
      fOnChange: tNotifyEvent;
      fSetting: tKlausDoerSetting;
      fRunning: boolean;
    protected
      procedure setSetting(aSetting: tKlausDoerSetting); virtual;
      procedure setReadOnly(val: boolean); virtual;
      procedure setRunning(val: boolean); virtual;
      procedure change; virtual;
    public
      class function doerClass: tKlausDoerClass; virtual; abstract;

      property readOnly: boolean read fReadOnly write setReadOnly;
      property setting: tKlausDoerSetting read fSetting write setSetting;
      property ownSetting: boolean read fOwnSetting write fOwnSetting;
      property running: boolean read fRunning write setRunning;
      property onChange: tNotifyEvent read fOnChange write fOnChange;

      destructor destroy; override;
  end;

function  klausFindDoer(const name: string): tKlausDoerClass;
procedure klausEnumDoers(sl: tStrings);

implementation

uses
  KlausPract, KlausUnitSystem;

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

procedure tKlausDoerSetting.assignTo(dest: tPersistent);
begin
  if dest is tKlausDoerSetting then
    (dest as tKlausDoerSetting).caption := self.caption
  else
    inherited assignTo(dest);
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

procedure tKlausDoerSettings.assignTo(dest: tPersistent);
var
  i: integer;
  s: tklausDoerSetting;
begin
  if dest is tKlausDoerSettings then
    with dest as tKlausDoerSettings do begin
      if doerClass <> self.doerClass then inherited;
      clear;
      for i := 0 to self.count-1 do begin
        s := add;
        s.assign(self[i]);
      end;
    end
  else
    inherited;
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

procedure tKlausDoerView.setRunning(val: boolean);
begin
  if fRunning <> val then begin
    fRunning := val;
    invalidate;
  end;
end;

procedure tKlausDoerView.setSetting(aSetting: tKlausDoerSetting);
begin
  if fSetting <> aSetting then begin
    if ownSetting then freeAndNil(fSetting);
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

destructor tKlausDoerView.destroy;
begin
  if ownSetting then freeAndNil(fSetting);
  inherited destroy;
end;

procedure tKlausDoer.syncCreateWindow;
var
  s: string;
begin
  if fSettingCaption = '' then s := stdUnitName
  else s := format('%s - %s', [stdUnitName, fSettingCaption]);
  fWindow := createWindowMethod(s);
  fView := createView(fWindow, kdvmExecute);
  fView.running := true;
  fView.align := alClient;
  fView.borderSpacing.around := 2;
  fView.setting := fSetting;
  fView.ownSetting := true;
  fView.parent := fWindow;
  fError := tDoerErrorFrame.create(fWindow);
  fError.parent := fWindow;
  fError.align := alBottom;
  fError.visible := false;
end;

procedure tKlausDoer.syncDestroyWindow;
begin
  fView.running := false;
  fView.invalidate;
  // не нужно уничтожать окно, чтобы можно было
  // увидеть и проверить результаты выполнения программы
  // destroyWindowMethod(fWindow);
end;

procedure tKlausDoer.beforeInit(frame: tKlausStackFrame);
var
  idx: integer;
  t: tKlausTask;
  ds: tKlausDoerSetting;
begin
  if theDoer <> nil then raise eKlausError.createFmt(ercDuplicateDoer, zeroSrcPt, [self.stdUnitName, theDoer.stdUnitName]);
  if not assigned(createWindowMethod) then raise eKlausError.create(ercDoerWindowNotAvailable, zeroSrcPt);
  inherited beforeInit(frame);
  theDoer := self;
  fSetting := createSetting;
  if klausPracticum = nil then t := nil
  else t := klausPracticum.findTask(source.module);
  if t <> nil then
    if t.doer = self.classType then begin
      idx := t.runningSetting;
      if idx >= 0 then
        ds := t.doerSettings[idx]
      else begin
        ds := t.activeSetting;
        idx := t.doerSettings.indexOf(ds);
      end;
      if ds <> nil then begin
        fSetting.assign(ds);
        if fSetting.caption <> '' then fSettingCaption := fSetting.caption
        else fSettingCaption := format('%.2d', [idx + 1])
      end;
    end;
  frame.owner.synchronize(@syncCreateWindow);
end;

procedure tKlausDoer.afterDone(frame: tKlausStackFrame);
var
  s: string;
begin
  if exceptObject <> nil then
    if not klausSilentException(exceptObject) then begin
      if not (exceptObject is exception) then s := exceptObject.className
      else s := (exceptObject as exception).message;
      errorMessage(frame, s);
    end;
  frame.owner.synchronize(@syncDestroyWindow);
  fSetting := nil;
  theDoer := nil;
  inherited afterDone(frame);
end;

class function tKlausDoer.capabilities: tKlausDoerCapabilities;
begin
  result := [];
end;

class procedure tKlausDoer.importSettingsDlgSetup(dlg: tOpenDialog);
begin
end;

class procedure tKlausDoer.importSettings(settings: tKlausDoerSettings; fileName: string);
begin
end;

class procedure tKlausDoer.exportSettingsDlgSetup(dlg: tSaveDialog);
begin
end;

class procedure tKlausDoer.exportSettings(settings: tKlausDoerSettings; fileName: string);
begin
end;

procedure tKlausDoer.syncErrorMessage;
begin
  fError.message := fStrParam;
end;

procedure tKlausDoer.errorMessage(frame: tKlausStackFrame; msg: string);
begin
  fStrParam := msg;
  frame.owner.synchronize(@syncErrorMessage);
end;

procedure tKlausDoer.errorMessage(frame: tKlausStackFrame; msg: string; args: array of const);
begin
  fStrParam := format(msg, args);
  frame.owner.synchronize(@syncErrorMessage);
end;

end.

