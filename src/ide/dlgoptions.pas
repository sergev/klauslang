unit DlgOptions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, EditBtn, ColorBox, Spin, KlausEdit, KlausGlobals;

type
  TOptionsDlg = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    chStyleDefault: TCheckBox;
    chStyleBold: TCheckBox;
    chStyleItalic: TCheckBox;
    chStyleUnderline: TCheckBox;
    chStyleStrikeOut: TCheckBox;
    chAutoIndent: TCheckBox;
    cbSelection: TColorBox;
    cbBackColor: TColorBox;
    cbTextColor: TColorBox;
    cbSelectionText: TColorBox;
    cbStyleBackColor: TColorBox;
    cbStyleTextColor: TColorBox;
    colorDialog: TColorDialog;
    edFont: TEditButton;
    FlowPanel1: TFlowPanel;
    FlowPanel3: TFlowPanel;
    fontDialog: TFontDialog;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbStyles: TListBox;
    pageControl: TPageControl;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel8: TPanel;
    pnCommon: TPanel;
    pnSample: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    pnSyntaxHighlight: TPanel;
    Panel9: TPanel;
    pnFontAndColors: TPanel;
    pbCancel: TButton;
    pbSave: TButton;
    pnButtons: TPanel;
    edTabSize: TSpinEdit;
    tsEditor: TTabSheet;
    procedure cbBackColorChange(Sender: TObject);
    procedure cbSelectionChange(Sender: TObject);
    procedure cbSelectionTextChange(Sender: TObject);
    procedure cbStyleBackColorChange(Sender: TObject);
    procedure cbStyleTextColorChange(Sender: TObject);
    procedure cbTextColorChange(Sender: TObject);
    procedure chAutoIndentClick(Sender: TObject);
    procedure chStyleBoldClick(Sender: TObject);
    procedure chStyleDefaultClick(Sender: TObject);
    procedure chStyleItalicClick(Sender: TObject);
    procedure chStyleStrikeOutClick(Sender: TObject);
    procedure chStyleUnderlineClick(Sender: TObject);
    procedure edFontButtonClick(Sender: TObject);
    procedure edTabSizeChange(Sender: TObject);
    procedure lbStylesClick(Sender: TObject);
  private
    fRefreshCount: integer;
    fSampleEdit: tKlausEdit;
    fEditorOptions: tKlausEditorOptions;

    procedure editorOptionsChange(sender: tObject);
    function  getRefreshing: boolean;
    function  getSelectedStyle: tKlausEditStyle;
    procedure setEditorOptions(val: tKlausEditorOptions);
    procedure updateSampleEdit;
    procedure sampleEditGetLineStyle(sender: tObject; line: integer; var style: tKlausEditStyleIndex);
    procedure refreshStyleProps;
  protected
    property selectedStyle: tKlausEditStyle read getSelectedStyle;

    procedure beginRefresh;
    procedure endRefresh;
  public
    property refreshing: boolean read getRefreshing;
    property editorOptions: tKlausEditorOptions read fEditorOptions write setEditorOptions;

    constructor create(aOwner: tComponent); override;
    destructor  destroy; override;
    procedure refreshWindow;
    procedure enableDisable;
  end;

implementation

uses
  GraphUtils;

resourcestring
  strFont = '%s %dpt %s';
  strSampleEditText =
    'программа Пример;'#10+
    'переменные'#10+
    #9'смв: символ = №4350;'#10+
    #9'стр: строка = "Строковый литерал";'#10+
    #9'цел: целое = 12345;'#10+
    #9'дрб: дробное = 123.45э67;'#10+
    #9'ммт: момент = `2023-05-17 14:03`;'#10+
    'начало'#10+
    #9'// строка с ошибкой'#10+
    #9'// однострочный комментарий'#10+
    #9'дрб := дрб / (цел + целое(смв));'#10+
    #9'если дрб > 0 то начало // выполняемая строка'#10+
    #9#9'вывести("дрб = " ++ строка(дрб), НС);'#10+
    #9#9'вывести(стр, НС); // точка останова'#10+
    #9'конец;'#10+
    #9'{многострочный комментарий'#10+
    #9'а на следующей строке недопустимые символы}'#10+
    #9'???'#10+
    'окончание.'#10;

{$R *.lfm}

{ TOptionsDlg }

constructor TOptionsDlg.create(aOwner: tComponent);
var
  i: tKlausEditStyleIndex;
begin
  inherited;
  fEditorOptions := tKlausEditorOptions.create;
  fEditorOptions.onChange := @editorOptionsChange;
  fSampleEdit := tKlausEdit.create(self);
  fSampleEdit.parent := pnSample;
  fSampleEdit.readOnly := true;
  fSampleEdit.align := alClient;
  fSampleEdit.borderStyle := bsSingle;
  fSampleEdit.styles := fEditorOptions;
  fSampleEdit.onGetLineStyle := @sampleEditGetLineStyle;
  for i := low(i) to high(i) do
    lbStyles.items.addObject(klausEditStyleCaption[i], fEditorOptions[i]);
  updateSampleEdit;
end;

destructor TOptionsDlg.destroy;
begin
  inherited;
  freeAndNil(fEditorOptions);
end;

procedure TOptionsDlg.refreshWindow;
begin
  beginRefresh;
  try
    with fEditorOptions do begin
      edTabSize.value := tabSize;
      chAutoIndent.checked := autoIndent;
      edFont.text := format(strFont, [font.name, font.size, fontStyleToText(fontStyle)]);
      cbTextColor.selected := fontColor;
      cbBackColor.selected := backColor;
      cbSelection.selected := selBackColor;
      cbSelectionText.selected := selFontColor;
    end;
    refreshStyleProps;
  finally
    endRefresh;
  end;
end;

procedure TOptionsDlg.lbStylesClick(Sender: TObject);
begin
  refreshStyleProps;
end;

procedure TOptionsDlg.edFontButtonClick(Sender: TObject);
begin
  with fontDialog do begin
    font := fEditorOptions.font;
    font.style := fEditorOptions.fontStyle;
    font.color := fEditorOptions.fontColor;
    if execute then begin
      fEditorOptions.beginUpdate;
      try
        fEditorOptions.font := font;
        fEditorOptions.fontStyle := font.style;
      finally
        fEditorOptions.endUpdate;
      end;
      refreshWindow;
    end;
  end;
end;

procedure TOptionsDlg.chAutoIndentClick(Sender: TObject);
begin
  if refreshing then exit;
  fEditorOptions.autoIndent := chAutoIndent.checked;
  updateSampleEdit;
end;

procedure TOptionsDlg.chStyleBoldClick(Sender: TObject);
var
  fs: tFontStyles;
  stl: tKlausEditStyle;
begin
  if refreshing then exit;
  stl := selectedStyle;
  if stl = nil then exit;
  stl.defaultFontStyle := false;
  fs := stl.fontStyle;
  if chStyleBold.checked then include(fs, fsBold) else exclude(fs, fsBold);
  stl.fontStyle := fs;
  refreshStyleProps;
end;

procedure TOptionsDlg.chStyleDefaultClick(Sender: TObject);
var
  stl: tKlausEditStyle;
begin
  if refreshing then exit;
  stl := selectedStyle;
  if stl = nil then exit;
  stl.defaultFontStyle := chStyleDefault.checked;
  refreshStyleProps;
end;

procedure TOptionsDlg.chStyleItalicClick(Sender: TObject);
var
  fs: tFontStyles;
  stl: tKlausEditStyle;
begin
  if refreshing then exit;
  stl := selectedStyle;
  if stl = nil then exit;
  stl.defaultFontStyle := false;
  fs := stl.fontStyle;
  if chStyleItalic.checked then include(fs, fsItalic) else exclude(fs, fsItalic);
  stl.fontStyle := fs;
  refreshStyleProps;
end;

procedure TOptionsDlg.chStyleStrikeOutClick(Sender: TObject);
var
  fs: tFontStyles;
  stl: tKlausEditStyle;
begin
  if refreshing then exit;
  stl := selectedStyle;
  if stl = nil then exit;
  stl.defaultFontStyle := false;
  fs := stl.fontStyle;
  if chStyleStrikeOut.checked then include(fs, fsStrikeOut) else exclude(fs, fsStrikeOut);
  stl.fontStyle := fs;
  refreshStyleProps;
end;

procedure TOptionsDlg.chStyleUnderlineClick(Sender: TObject);
var
  fs: tFontStyles;
  stl: tKlausEditStyle;
begin
  if refreshing then exit;
  stl := selectedStyle;
  if stl = nil then exit;
  stl.defaultFontStyle := false;
  fs := stl.fontStyle;
  if chStyleUnderline.checked then include(fs, fsUnderline) else exclude(fs, fsUnderline);
  stl.fontStyle := fs;
  refreshStyleProps;
end;

procedure TOptionsDlg.cbBackColorChange(Sender: TObject);
begin
  if refreshing then exit;
  fEditorOptions.backColor := cbBackColor.selected;
  refreshWindow;
end;

procedure TOptionsDlg.cbSelectionChange(Sender: TObject);
begin
  if refreshing then exit;
  fEditorOptions.selBackColor := cbSelection.selected;
  refreshWindow;
end;

procedure TOptionsDlg.cbSelectionTextChange(Sender: TObject);
begin
  if refreshing then exit;
  fEditorOptions.selFontColor := cbSelectionText.selected;
  refreshWindow;
end;

procedure TOptionsDlg.cbStyleBackColorChange(Sender: TObject);
var
  stl: tKlausEditStyle;
begin
  if refreshing then exit;
  stl := selectedStyle;
  if stl = nil then exit;
  if cbStyleBackColor.selected = clDefault then
    stl.defaultBackColor := true
  else begin
    stl.defaultBackColor := false;
    stl.backColor := cbStyleBackColor.selected;
  end;
end;

procedure TOptionsDlg.cbStyleTextColorChange(Sender: TObject);
var
  stl: tKlausEditStyle;
begin
  if refreshing then exit;
  stl := selectedStyle;
  if stl = nil then exit;
  if cbStyleTextColor.selected = clDefault then
    stl.defaultFontColor := true
  else begin
    stl.defaultFontColor := false;
    stl.fontColor := cbStyleTextColor.selected;
  end;
end;

procedure TOptionsDlg.cbTextColorChange(Sender: TObject);
begin
  if refreshing then exit;
  fEditorOptions.fontColor := cbTextColor.selected;
  refreshWindow;
end;

procedure TOptionsDlg.edTabSizeChange(Sender: TObject);
begin
  if refreshing then exit;
  fEditorOptions.tabSize := edTabSize.value;
  updateSampleEdit;
end;

procedure TOptionsDlg.editorOptionsChange(sender: tObject);
begin
  updateSampleEdit;
end;

function TOptionsDlg.getRefreshing: boolean;
begin
  result := fRefreshCount > 0;
end;

function TOptionsDlg.getSelectedStyle: tKlausEditStyle;
begin
  with lbStyles do
    if itemIndex < 0 then result := nil
    else result := tKlausEditStyle(items.objects[itemIndex]);
end;

procedure TOptionsDlg.setEditorOptions(val: tKlausEditorOptions);
begin
  fEditorOptions.assign(val);
  refreshWindow;
end;

procedure TOptionsDlg.updateSampleEdit;
var
  opt: tKlausEditOptions;
begin
  with fSampleEdit do begin
    font := fEditorOptions.font;
    tabSize := fEditorOptions.tabSize;
    opt := options;
    if fEditorOptions.autoIndent then include(opt, keoAutoIndent) else exclude(opt, keoAutoIndent);
    options := opt;
    lines.text := strSampleEditText;
  end;
end;

procedure TOptionsDlg.sampleEditGetLineStyle(sender: tObject; line: integer; var style: tKlausEditStyleIndex);
begin
  case line of
    8: style := esiErrorLine;
    13: style := esiBreakpoint;
    11: style := esiExecPoint;
    else style := esiNone;
  end;
end;

procedure TOptionsDlg.refreshStyleProps;
var
  stl: tKlausEditStyle;
begin
  beginRefresh;
  try
    cbStyleTextColor.defaultColorColor := fEditorOptions.fontColor;
    cbStyleBackColor.defaultColorColor := fEditorOptions.backColor;
    stl := selectedStyle;
    if stl = nil then begin
      cbStyleTextColor.selected := clDefault;
      cbStyleBackColor.selected := clDefault;
      chStyleDefault.checked := true;
      chStyleBold.checked := fsBold in fEditorOptions.fontStyle;
      chStyleItalic.checked := fsItalic in fEditorOptions.fontStyle;
      chStyleUnderline.checked := fsUnderline in fEditorOptions.fontStyle;
      chStyleStrikeOut.checked := fsStrikeOut in fEditorOptions.fontStyle;
    end else begin
      if stl.defaultFontColor then cbStyleTextColor.selected := clDefault
      else cbStyleTextColor.selected := stl.fontColor;
      if stl.defaultBackColor then cbStyleBackColor.selected := clDefault
      else cbStyleBackColor.selected := stl.backColor;
      if stl.defaultFontStyle then begin
        chStyleDefault.checked := true;
        chStyleBold.checked := fsBold in fEditorOptions.fontStyle;
        chStyleItalic.checked := fsItalic in fEditorOptions.fontStyle;
        chStyleUnderline.checked := fsUnderline in fEditorOptions.fontStyle;
        chStyleStrikeOut.checked := fsStrikeOut in fEditorOptions.fontStyle;
      end else begin
        chStyleDefault.checked := false;
        chStyleBold.checked := fsBold in stl.fontStyle;
        chStyleItalic.checked := fsItalic in stl.fontStyle;
        chStyleUnderline.checked := fsUnderline in stl.fontStyle;
        chStyleStrikeOut.checked := fsStrikeOut in stl.fontStyle;
      end;
    end;
    enableDisable;
  finally
    endRefresh;
  end;
end;

procedure TOptionsDlg.beginRefresh;
begin
  inc(fRefreshCount);
end;

procedure TOptionsDlg.endRefresh;
begin
  if fRefreshCount > 0 then dec(fRefreshCount);
end;

procedure TOptionsDlg.enableDisable;
var
  i: tKlausEditStyleIndex;
begin
  i := tKlausEditStyleIndex(lbStyles.itemIndex);
  if (i < low(i)) or (i > high(i)) then begin
    cbStyleTextColor.enabled := false;
    cbStyleBackColor.enabled := false;
    chStyleDefault.enabled := false;
    chStyleBold.enabled := false;
    chStyleItalic.enabled := false;
    chStyleUnderline.enabled := false;
    chStyleStrikeOut.enabled := false;
  end else begin
    cbStyleTextColor.enabled := true;
    cbStyleBackColor.enabled := true;
    chStyleDefault.enabled := true;
    chStyleBold.enabled := true;
    chStyleItalic.enabled := true;
    chStyleUnderline.enabled := true;
    chStyleStrikeOut.enabled := true;
  end;
end;

end.

