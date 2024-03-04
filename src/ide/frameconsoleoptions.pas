unit FrameConsoleOptions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Spin, KlausGlobals,
  ColorBox, EditBtn, Dialogs, Graphics, GraphUtils;

type

  { tConsoleOptionsFrame }

  tConsoleOptionsFrame = class(TFrame)
    Bevel1: TBevel;
    Bevel3: TBevel;
    cbBackColor: TColorBox;
    cbTextColor: TColorBox;
    chStayOnTop: TCheckBox;
    chAutoClose: TCheckBox;
    colorDialog: TColorDialog;
    edFont: TEditButton;
    edWinWidth: TSpinEdit;
    edWinHeight: TSpinEdit;
    FlowPanel1: TFlowPanel;
    fontDialog: TFontDialog;
    Label1: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label9: TLabel;
    Panel1: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel16: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    pnCommon: TPanel;
    pnFontAndColors: TPanel;
    procedure cbBackColorChange(Sender: TObject);
    procedure cbTextColorChange(Sender: TObject);
    procedure chAutoCloseClick(Sender: TObject);
    procedure chStayOnTopClick(Sender: TObject);
    procedure colorBoxGetColors(Sender: TCustomColorBox; Items: TStrings);
    procedure edFontButtonClick(Sender: TObject);
    procedure edFontKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edWinHeightChange(Sender: TObject);
    procedure edWinWidthChange(Sender: TObject);
  private
    fRefreshCount: integer;
    fConsoleOptions: tKlausConsoleOptions;

    function  getRefreshing: boolean;
    procedure setConsoleOptions(val: tKlausConsoleOptions);
    procedure beginRefresh;
    procedure endRefresh;
  public
    property consoleOptions: tKlausConsoleOptions read fConsoleOptions write setConsoleOptions;
    property refreshing: boolean read getRefreshing;

    constructor create(aOwner: tComponent); override;
    destructor  destroy; override;
    procedure refreshWindow;
    procedure enableDisable;
  end;

implementation

uses
  KlausConsole, LCLType;

resourcestring
  strCustomColor = 'Настроить...';
  strFont = '%s %dpt';

{$R *.lfm}

{ tConsoleOptionsFrame }

constructor tConsoleOptionsFrame.create(aOwner: tComponent);
begin
  inherited;
  fConsoleOptions := tKlausConsoleOptions.create;
  edWinWidth.minValue := klsConMinScreenWidth;
  edWinWidth.maxValue := klsConMaxScreenWidth;
  edWinHeight.minValue := klsConMinScreenHeight;
  edWinHeight.maxValue := klsConMaxScreenHeight;
end;

destructor tConsoleOptionsFrame.destroy;
begin
  freeAndNil(fConsoleOptions);
  inherited;
end;

procedure tConsoleOptionsFrame.setConsoleOptions(val: tKlausConsoleOptions);
begin
  fConsoleOptions.assign(val);
  refreshWindow;
end;

function tConsoleOptionsFrame.getRefreshing: boolean;
begin
  result := fRefreshCount > 0;
end;

procedure tConsoleOptionsFrame.beginRefresh;
begin
  inc(fRefreshCount);
end;

procedure tConsoleOptionsFrame.endRefresh;
begin
  if fRefreshCount > 0 then dec(fRefreshCount);
end;

procedure tConsoleOptionsFrame.colorBoxGetColors(Sender: TCustomColorBox; Items: TStrings);
var
  i: integer;
  c: tColor;
begin
  items.strings[0] := strCustomColor;
  for i := 1 to items.count-1 do begin
    c := tColor(ptrInt(items.objects[i]));
    items.strings[i] := colorCaption(c);
  end;
end;

procedure tConsoleOptionsFrame.chStayOnTopClick(Sender: TObject);
begin
  if refreshing then exit;
  with fConsoleOptions do stayOnTop := not stayOnTop;
end;

procedure tConsoleOptionsFrame.chAutoCloseClick(Sender: TObject);
begin
  if refreshing then exit;
  with fConsoleOptions do autoClose := not autoClose;
end;

procedure tConsoleOptionsFrame.cbBackColorChange(Sender: TObject);
begin
  if refreshing then exit;
  fConsoleOptions.backColor := colorTo256(cbBackColor.selected);
end;

procedure tConsoleOptionsFrame.cbTextColorChange(Sender: TObject);
begin
  if refreshing then exit;
  fConsoleOptions.fontColor := colorTo256(cbTextColor.selected);
end;

procedure tConsoleOptionsFrame.edFontButtonClick(Sender: TObject);
begin
  with fontDialog do begin
    font := fConsoleOptions.font;
    font.style := [];
    if execute then begin
      fConsoleOptions.font := font;
      fConsoleOptions.font.style := [];
      refreshWindow;
    end;
  end;
end;

procedure tConsoleOptionsFrame.edFontKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  shift := shift * [ssShift, ssCtrl, ssAlt];
  if (key = VK_F2) and (shift = []) then edFont.button.click;
end;

procedure tConsoleOptionsFrame.edWinHeightChange(Sender: TObject);
begin
  if refreshing then exit;
  fConsoleOptions.height := edWinHeight.value;
end;

procedure tConsoleOptionsFrame.edWinWidthChange(Sender: TObject);
begin
  if refreshing then exit;
  fConsoleOptions.width := edWinWidth.value;
end;

procedure tConsoleOptionsFrame.refreshWindow;
begin
  beginRefresh;
  try
    with fConsoleOptions do begin
      edWinWidth.value := width;
      edWinHeight.value := height;
      chAutoClose.checked := autoClose;
      chStayOnTop.checked := stayOnTop;
      edFont.text := format(strFont, [font.name, font.size]);
      cbTextColor.selected := colors256[fontColor];
      cbBackColor.selected := colors256[backColor];
    end;
  finally
    endRefresh;
  end;
end;

procedure tConsoleOptionsFrame.enableDisable;
begin
end;

end.

