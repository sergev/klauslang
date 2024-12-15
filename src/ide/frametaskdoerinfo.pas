unit FrameTaskDoerInfo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, Buttons, KlausDoer;

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
  private
    fSettings: tKlausDoerSettings;

    function  getSelectedSetting: tKlausDoerSetting;
    procedure setSettings(val: tKlausDoerSettings);
  public
    property settings: tKlausDoerSettings read fSettings write setSettings;
    property selectedSetting: tKlausDoerSetting read getSelectedSetting;

    procedure refreshWindow;
  end;

implementation

{$R *.lfm}

{ tTaskDoerInfoFrame }

procedure tTaskDoerInfoFrame.setSettings(val: tKlausDoerSettings);
begin
  if fSettings <> val then begin
    fSettings := val;
    refreshWindow;
  end;
end;

function tTaskDoerInfoFrame.getSelectedSetting: tKlausDoerSetting;
begin
  if pageControl.activePage = nil then exit(nil);
  result := (pageControl.activePage as tDoerSettingTabSheet).setting;
end;

procedure tTaskDoerInfoFrame.refreshWindow;
var
  s: string;
  i: integer;
  page: tDoerSettingTabSheet;
  ds: tKlausDoerSetting;
  view: tKlausDoerView;
begin
  with pageControl do
    while pageCount > 0 do pages[pageCount-1].free;
  if settings = nil then exit;
  for i := 0 to settings.count-1 do begin
    ds := settings[i];
    s := ds.caption;
    if s = '' then s := format('%.2d', [i]);
    page := tDoerSettingTabSheet.create(pageControl);
    page.pageControl := pageControl;
    page.caption := s;
    page.setting := ds;
    view := settings.doerClass.createView(self);
    view.readOnly := true;
    view.parent := page;
    view.align := alClient;
    view.enabled := false;
    view.setting := ds;
  end;
end;

end.

