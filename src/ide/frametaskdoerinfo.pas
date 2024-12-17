unit FrameTaskDoerInfo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, Buttons, KlausDoer, KlausPract;

type
  tDoerSettingTabSheet = class(tTabSheet)
    private
      fSetting: tKlausDoerSetting;
    public
      property setting: tKlausDoerSetting read fSetting write fSetting;
  end;

type
  tTaskDoerInfoFrame = class(tFrame)
    pageControl: tPageControl;
    procedure pageControlChange(sender: tObject);
  private
    fTask: tKlausTask;
    fRefreshCount: integer;

    function  getRefreshing: boolean;
    function  getSelectedSetting: tKlausDoerSetting;
    procedure setTask(val: tKlausTask);
  protected
    procedure beginRefresh;
    procedure endRefresh;
  public
    property task: tKlausTask read fTask write setTask;
    property refreshing: boolean read getRefreshing;
    property selectedSetting: tKlausDoerSetting read getSelectedSetting;

    procedure refreshWindow;
  end;

implementation

{$R *.lfm}

{ tTaskDoerInfoFrame }

procedure tTaskDoerInfoFrame.setTask(val: tKlausTask);
begin
  if fTask <> val then begin
    fTask := val;
    refreshWindow;
  end;
end;

procedure tTaskDoerInfoFrame.beginRefresh;
begin
  inc(fRefreshCount);
end;

procedure tTaskDoerInfoFrame.endRefresh;
begin
  if fRefreshCount > 0 then dec(fRefreshCount);
end;

procedure tTaskDoerInfoFrame.pageControlChange(sender: tObject);
begin
  if not refreshing then begin
    if task = nil then exit;
    if task.doer = nil then exit;
    task.activeSetting := selectedSetting;
  end;
end;

function tTaskDoerInfoFrame.getSelectedSetting: tKlausDoerSetting;
begin
  if pageControl.activePage = nil then exit(nil);
  result := (pageControl.activePage as tDoerSettingTabSheet).setting;
end;

function tTaskDoerInfoFrame.getRefreshing: boolean;
begin
  result := fRefreshCount > 0;
end;

procedure tTaskDoerInfoFrame.refreshWindow;
var
  s: string;
  i: integer;
  page, p: tDoerSettingTabSheet;
  ds: tKlausDoerSetting;
  view: tKlausDoerView;
begin
  beginRefresh;
  try
    with pageControl do
      while pageCount > 0 do pages[pageCount-1].free;
    if task = nil then exit;
    if (task.doer = nil) or (task.doerSettings = nil) then exit;
    p := nil;
    for i := 0 to task.doerSettings.count-1 do begin
      ds := task.doerSettings[i];
      s := ds.caption;
      if s = '' then s := format('%.2d', [i]);
      page := tDoerSettingTabSheet.create(pageControl);
      page.pageControl := pageControl;
      page.caption := s;
      page.setting := ds;
      view := task.doer.createView(self, dvmView);
      view.parent := page;
      view.align := alClient;
      view.setting := ds;
      if task.activeSetting = ds then p := page;
    end;
    if p <> nil then pageControl.activePage := p;
  finally
    endRefresh;
  end;
end;

end.

