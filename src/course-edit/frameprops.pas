unit FrameProps;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, LCLIntf, Messages, KlausGlobals;

type
  tPropsFrame = class(tFrame)
  private
    fRefreshCount: integer;
    fData: tObject;
    fChanged: tObject;
    fUpdateError: boolean;

    procedure beginRefresh;
    procedure endRefresh;
    function  getModified: boolean;
    function  getRefreshing: boolean;
  protected
    procedure setData(val: tObject); virtual;
    procedure doRefreshWindow; virtual; abstract;
    procedure doUpdateData(what: tObject); virtual;
    procedure changed(what: tObject); virtual;
    procedure APPMFocusControl(var msg: tMessage); message APPM_FocusControl;
  public
    property refreshing: boolean read getRefreshing;
    property data: tObject read fData write setData;
    property modified: boolean read getModified;
    property updateError: boolean read fUpdateError;

    procedure refreshWindow;
    procedure updateData;
  end;

implementation

uses FormMain;

{$R *.lfm}

procedure tPropsFrame.beginRefresh;
begin
  inc(fRefreshCount);
end;

procedure tPropsFrame.endRefresh;
begin
  if fRefreshCount > 0 then dec(fRefreshCount);
end;

function tPropsFrame.getModified: boolean;
begin
  result := fChanged <> nil;
end;

function tPropsFrame.getRefreshing: boolean;
begin
  result := fRefreshCount > 0;
end;

procedure tPropsFrame.refreshWindow;
begin
  updateData;
  beginRefresh;
  try doRefreshWindow;
  finally endRefresh; end;
end;

procedure tPropsFrame.updateData;
begin
  if modified then begin
    try
      doUpdateData(fChanged);
      fUpdateError := false;
      fChanged := nil;
    except
      fUpdateError := true;
      postMessage(handle, APPM_FocusControl, 0, ptrInt(fChanged));
      application.handleException(application);
    end;
  end;
end;

procedure tPropsFrame.setData(val: tObject);
begin
  if fData <> val then begin
    updateData;
    fData := val;
    fChanged := nil;
    fUpdateError := false;
    refreshWindow;
  end;
end;

procedure tPropsFrame.doUpdateData(what: tObject);
begin
end;

procedure tPropsFrame.changed(what: tObject);
begin
  if refreshing or (data = nil) then exit;
  if modified and (fChanged <> what) then updateData;
  fChanged := what;
  fUpdateError := false;
  mainForm.modified := true;
end;

procedure tPropsFrame.APPMFocusControl(var msg: tMessage);
var
  tmp: tObject;
begin
  tmp := fChanged;
  fChanged := nil;
  try tWinControl(msg.lParam).setFocus;
  finally fChanged := tmp; end;
end;

end.

