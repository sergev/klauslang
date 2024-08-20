unit FrameCourseProps;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, FrameProps, FrameMarkdown, KlausPract;

type
  tCoursePropsFrame = class(tPropsFrame)
    Bevel3: tBevel;
    Bevel4: tBevel;
    edCaption: tEdit;
    edAuthor: tEdit;
    edLicense: tEdit;
    edURL: tEdit;
    FlowPanel1: tFlowPanel;
    Label10: tLabel;
    Label3: tLabel;
    Label5: tLabel;
    Label6: tLabel;
    Label7: tLabel;
    Label9: tLabel;
    pnDescription: tPanel;
    Panel13: tPanel;
    Panel14: tPanel;
    Panel3: tPanel;
    Panel5: tPanel;
    Panel6: tPanel;
    Panel7: tPanel;
    pnProps: tPanel;
    procedure somethingChange(sender: tObject);
    procedure somethingEditingDone(sender: tObject);
    procedure descChange(sender: tObject);
  private
    fDesc: tMarkdownFrame;

    function  getCourse: tKlausCourse;
    procedure setCourse(val: tKlausCourse);
  protected
    procedure doRefreshWindow; override;
    procedure doUpdateData(what: tObject); override;
  public
    property course: tKlausCourse read getCourse write setCourse;

    constructor create(aOwner: tComponent); override;
  end;

implementation

{$R *.lfm}

{ tCoursePropsFrame }

constructor tCoursePropsFrame.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  fDesc := tMarkdownFrame.create(self);
  fDesc.parent := pnDescription;
  fDesc.align := alClient;
  fDesc.onChange := @descChange;
end;

procedure tCoursePropsFrame.setCourse(val: tKlausCourse);
begin
  setData(val);
end;

procedure tCoursePropsFrame.somethingEditingDone(sender: tObject);
begin
  updateData;
end;

procedure tCoursePropsFrame.descChange(sender: tObject);
begin
  changed(sender);
  updateData;
end;

procedure tCoursePropsFrame.somethingChange(sender: tObject);
begin
  changed(sender);
end;

function tCoursePropsFrame.getCourse: tKlausCourse;
begin
  result := data as tKlausCourse;
end;

procedure tCoursePropsFrame.doRefreshWindow;
begin
  if course = nil then begin
    edCaption.text := '';
    edAuthor.text := '';
    edLicense.text := '';
    edURL.text := '';
    fDesc.markdown := '';
  end else begin
    edCaption.text := course.caption;
    edAuthor.text := course.author;
    edLicense.text := course.license;
    edURL.text := course.url;
    fDesc.markdown := course.description;
  end;
  fDesc.pageControl.activePage := fDesc.tsEdit;
end;

procedure tCoursePropsFrame.doUpdateData(what: tObject);
begin
  if what = edCaption then course.caption := edCaption.text
  else if what = edAuthor then course.author := edAuthor.text
  else if what = edLicense then course.license := edLicense.text
  else if what = edURL then course.url := edURL.text
  else if what = fDesc then course.description := fDesc.markdown;
end;

end.

