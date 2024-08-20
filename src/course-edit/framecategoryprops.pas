unit FrameCategoryProps;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, KlausPract, FrameProps;

type
  tCategoryPropsFrame = class(tPropsFrame)
    Bevel3: TBevel;
    edCaption: TEdit;
    Label3: TLabel;
    Label9: TLabel;
    Panel13: TPanel;
    Panel3: TPanel;
    pnProps: TPanel;
    procedure somethingChange(sender: TObject);
    procedure somethingEditingDone(sender: tObject);
  private
    function  getNode: tCategoryTreeNode;
    procedure setNode(val: tCategoryTreeNode);
  protected
    procedure doRefreshWindow; override;
    procedure doUpdateData(what: tObject); override;
  public
    property node: tCategoryTreeNode read getNode write setNode;
  end;

implementation

uses
  formMain;

{$R *.lfm}

procedure tCategoryPropsFrame.setNode(val: tCategoryTreeNode);
begin
  setData(val);
end;

procedure tCategoryPropsFrame.somethingChange(Sender: tObject);
begin
  changed(sender);
end;

procedure tCategoryPropsFrame.somethingEditingDone(Sender: tObject);
begin
  updateData;
end;

function tCategoryPropsFrame.getNode: tCategoryTreeNode;
begin
  result := data as tCategoryTreeNode;
end;

procedure tCategoryPropsFrame.doRefreshWindow;
begin
  if node = nil then edCaption.text := ''
  else edCaption.text := node.category;
end;

procedure tCategoryPropsFrame.doUpdateData(what: tObject);
begin
  if what = edCaption then mainForm.renameCategory(node, edCaption.text);
end;

end.

