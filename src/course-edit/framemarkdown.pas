unit FrameMarkdown;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, StdCtrls, ExtCtrls, IpHtml, LCLIntf;

type
  tMarkdownFrame = class(tFrame)
    htmlPanel: tIpHtmlPanel;
    mlEdit: tMemo;
    pageControl: tPageControl;
    changeTimer: tTimer;
    tsEdit: tTabSheet;
    tsPreview: tTabSheet;
    procedure mlEditChange(Sender: tObject);
    procedure tsPreviewShow(Sender: TObject);
    procedure htmlPanelHotClick(Sender: TObject);
    procedure htmlPanelHotURL(Sender: TObject; const URL: String);
  private
    fHotURL: string;
    fOnChange: tNotifyEvent;
    fHtmlInvalid: boolean;

    function  getMarkdown: string;
    procedure setMarkdown(val: string);
  protected
    procedure doChange; virtual;
  public
    property markdown: string read getMarkdown write setMarkdown;
    property onChange: tNotifyEvent read fOnChange write fOnChange;

    constructor create(aOwner: tComponent); override;
  end;

implementation

uses KlausUtils;

{$R *.lfm}

{ tMarkdownFrame }

constructor tMarkdownFrame.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  {$if defined(windows)} htmlPanel.fixedTypeface := 'Courier New';
  {$elseif defined(darwin)} htmlPanel.fixedTypeface := 'Menlo';
  {$else} htmlPanel.fixedTypeface := 'Monospace'; {$endif}
  fHtmlInvalid := true;
end;

procedure tMarkdownFrame.mlEditChange(Sender: tObject);
begin
  fHtmlInvalid := true;
  doChange;
end;

procedure tMarkdownFrame.tsPreviewShow(Sender: TObject);
begin
  if fHtmlInvalid then begin
    if trim(mlEdit.text) = '' then htmlPanel.setHtml(nil)
    else htmlPanel.setHtml(markdownToHtml(mlEdit.text));
    fHtmlInvalid := false;
  end;
end;

function tMarkdownFrame.getMarkdown: string;
begin
  result := mlEdit.text;
end;

procedure tMarkdownFrame.setMarkdown(val: string);
begin
  mlEdit.text := val;
  fHtmlInvalid := true;
end;

procedure tMarkdownFrame.doChange;
begin
  if assigned(onChange) then onChange(self);
end;

procedure tMarkdownFrame.htmlPanelHotURL(Sender: TObject; const URL: String);
begin
  fHotURL := URL;
end;

procedure tMarkdownFrame.htmlPanelHotClick(Sender: TObject);
begin
  if fHotURL <> '' then openURL(fHotURL);
end;

end.

