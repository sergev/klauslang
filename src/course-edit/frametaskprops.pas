unit FrameTaskProps;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, KlausPract, FrameProps, FrameMarkdown;

type
  tTaskPropsFrame = class(tPropsFrame)
    Bevel3: tBevel;
    Bevel4: tBevel;
    edName: tEdit;
    edCaption: tEdit;
    edCategory: tEdit;
    FlowPanel1: tFlowPanel;
    Label10: tLabel;
    Label3: tLabel;
    Label5: tLabel;
    Label6: tLabel;
    Label9: tLabel;
    Panel13: tPanel;
    Panel14: tPanel;
    Panel3: tPanel;
    Panel5: tPanel;
    Panel6: tPanel;
    pnDescription: tPanel;
    pnProps: tPanel;
    procedure somethingEditingDone(sender: tObject);
    procedure somethingChange(sender: tObject);
    procedure descChange(sender: tObject);
  private
    fDesc: tMarkdownFrame;

    function  getTask: tKlausTask;
    procedure setTask(val: tKlausTask);
  protected
    procedure doRefreshWindow; override;
    procedure doUpdateData(what: tObject); override;
  public
    property task: tKlausTask read getTask write setTask;

    constructor create(aOwner: tComponent); override;
  end;

implementation

uses
  FormMain;

{$R *.lfm}

constructor tTaskPropsFrame.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  fDesc := tMarkdownFrame.create(self);
  fDesc.parent := pnDescription;
  fDesc.align := alClient;
  fDesc.onChange := @descChange;
end;

procedure tTaskPropsFrame.setTask(val: tKlausTask);
begin
  setData(val);
end;

procedure tTaskPropsFrame.somethingChange(Sender: tObject);
begin
  changed(sender);
end;

procedure tTaskPropsFrame.descChange(sender: tObject);
begin
  changed(sender);
  updateData;
end;

procedure tTaskPropsFrame.somethingEditingDone(Sender: tObject);
begin
  updateData;
end;

function tTaskPropsFrame.getTask: tKlausTask;
begin
  result := data as tKlausTask;
end;

procedure tTaskPropsFrame.doRefreshWindow;
begin
  if task = nil then begin
    edName.text := '';
    edCategory.text := '';
    edCaption.text := '';
    fDesc.markdown := '';
  end else begin
    edName.text := task.name;
    edCategory.text := task.category;
    edCaption.text := task.caption;
    fDesc.markdown := task.description;
  end;
  fDesc.pageControl.activePage := fDesc.tsEdit;
end;

procedure tTaskPropsFrame.doUpdateData(what: tObject);
begin
  if what = edName then mainForm.renameTask(task, edName.text)
  else if what = edCategory then begin
    task.category := edCategory.text;
    mainForm.refreshTree;
  end else if what = edCaption then task.caption := edCaption.text
  else if what = fDesc then task.description := fDesc.markdown;
end;

end.

