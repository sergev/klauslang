unit FrameTaskDoerInfo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, KlausDoer;

type
  tTaskDoerInfoFrame = class(tFrame)
    pageControl: tPageControl;
  private
    fSettings: tKlausDoerSettings;

    procedure setSettings(val: tKlausDoerSettings);
  public
    property settings: tKlausDoerSettings read fSettings write setSettings;

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

procedure tTaskDoerInfoFrame.refreshWindow;
var
  s: string;
  i: integer;
  page: tTabSheet;
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
    page := pageControl.addTabSheet;
    page.caption := s;
    view := settings.doerClass.createView(self);
    view.readOnly := true;
    view.parent := page;
    view.align := alClient;
    view.enabled := false;
    view.setting := ds;
  end;
end;

end.

