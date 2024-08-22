unit FormMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ActnList, Menus,
  ComCtrls, ExtCtrls, KlausPract, FrameCourseProps, FrameCategoryProps,
  FrameTaskProps;

type

  { tMainForm }

  tMainForm = class(tForm)
    actFileOpen: tAction;
    actFileNew: tAction;
    actFileSave: tAction;
    actFileSaveAs: tAction;
    actFileExit: tAction;
    actTaskDelete: tAction;
    actTaskAdd: tAction;
    actionImages: tImageList;
    actionList: tActionList;
    bvTreeSizer: tBevel;
    mainMenu: tMainMenu;
    MenuItem1: tMenuItem;
    MenuItem2: tMenuItem;
    miTaskDelete: tMenuItem;
    miTaskAdd: tMenuItem;
    miFileExit: tMenuItem;
    miFileSaveAs: tMenuItem;
    miFileSave: tMenuItem;
    miFileOpen: tMenuItem;
    miFileNew: tMenuItem;
    openDialog: tOpenDialog;
    pnProps: tPanel;
    pnTree: tPanel;
    saveDialog: TSaveDialog;
    Separator1: tMenuItem;
    statusBar: tStatusBar;
    toolBar: tToolBar;
    tbFileNew: tToolButton;
    tbFileOpen: tToolButton;
    tbFileSave: tToolButton;
    ToolButton4: tToolButton;
    tbTaskAdd: tToolButton;
    tbTaskDelete: tToolButton;
    tree: tTreeView;
    procedure actFileExitExecute(sender: tObject);
    procedure actFileNewExecute(sender: tObject);
    procedure actFileOpenExecute(sender: tObject);
    procedure actFileSaveAsExecute(Sender: TObject);
    procedure actFileSaveExecute(Sender: TObject);
    procedure actTaskAddExecute(sender: tObject);
    procedure actTaskDeleteExecute(sender: tObject);
    procedure bvTreeSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvTreeSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
    procedure bvTreeSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure formCloseQuery(sender: tObject; var canClose: boolean);
    procedure formShow(sender: tObject);
    procedure treeChange(sender: tObject; node: tTreeNode);
    procedure treeChanging(sender: tObject; node: tTreeNode; var allowChange: boolean);
  private
    fCourse: tKlausCourse;
    fTreeSizing: boolean;
    fSizingPoint: tPoint;
    fModified: boolean;
    fRefreshCount: integer;
    fCourseProps: tCoursePropsFrame;
    fCategoryProps: tCategoryPropsFrame;
    fTaskProps: tTaskPropsFrame;

    function  getRefreshing: boolean;
    procedure setModified(val: boolean);
  protected
    procedure beginRefresh;
    procedure endRefresh;
  public
    property course: tKlausCourse read fCourse;
    property modified: boolean read fModified write setModified;
    property refreshing: boolean read getRefreshing;

    constructor create(aOwner: tComponent); override;
    procedure refreshWindow;
    procedure updateCaption;
    procedure refreshTree(select: tObject = nil);
    procedure refreshProps;
    procedure updateProps;
    function  propsUpdated: boolean;
    function  findCategoryNode(s: string): tCategoryTreeNode;
    procedure renameCategory(node: tCategoryTreeNode; newName: string);
    procedure renameTask(task: tKlausTask; newName: string);
    procedure enableDisable;
    function  promptToSave: boolean;
    procedure createCourse;
    procedure openCourse(fileName: string);
    function  saveCourse(saveAs: boolean = false): boolean;
  end;

var
  mainForm: tMainForm;

implementation

uses Math, U8;

resourcestring
  strFormCaption = '%s';
  strPromptToSave = 'Учебный курс "%s" был изменён. Сохранить изменения?';
  strOtherTasks = '(другие задачи)';
  strConfirmDelete = 'Удалить задачу "%s"?';

{$R *.lfm}

constructor tMainForm.create(aOwner: tComponent);
begin
  inherited create(aOwner);
  fCourseProps := tCoursePropsFrame.create(self);
  fCourseProps.parent := pnProps;
  fCourseProps.align := alClient;
  fCourseProps.visible := false;
  fCategoryProps := tCategoryPropsFrame.create(self);
  fCategoryProps.parent := pnProps;
  fCategoryProps.align := alClient;
  fCategoryProps.visible := false;
  fTaskProps := tTaskPropsFrame.create(self);
  fTaskProps.parent := pnProps;
  fTaskProps.align := alClient;
  fTaskProps.visible := false;
  createCourse;
end;

procedure tMainForm.refreshWindow;
begin
  beginRefresh;
  try
    updateCaption;
    refreshTree;
  finally
    endRefresh;
    enableDisable;
  end;
end;

procedure tMainForm.updateCaption;
var
  s: string;
begin
  if course.fileName = '' then s := course.name else s := course.fileName;
  caption := format(strFormCaption, [s]);
  application.title := caption;
end;

procedure tMainForm.refreshTree(select: tObject = nil);
var
  i, j: integer;
  cat: string;
  n, pn: tTreeNode;
  cn: tCategoryTreeNode;
  sel: pointer;
begin
  if select = nil then begin
    n := tree.selected;
    if n <> nil then sel := n.data else sel := nil;
  end else
    sel := select;
  beginRefresh;
  try
    with tree.items do begin
      beginUpdate;
      try
        clear;
        pn := addObject(nil, course.name, course);
        for j := 0 to course.catCount-1 do begin
          cat := u8Lower(course.categories[j]);
          cn := tCategoryTreeNode.create(tree.items);
          cn.course := course;
          cn.category := course.categories[j];
          tree.items.addNode(cn, pn, course.categories[j], nil, naAddChild);
          for i := 0 to course.taskCount-1 do begin
            if u8Lower(course[i].category) <> cat then continue;
            addChildObject(cn, course[i].name, course[i]);
          end;
        end;
        cn := nil;
        for i := 0 to course.taskCount-1 do begin
          if course[i].category <> '' then continue;
          if cn = nil then begin
            cn := tCategoryTreeNode.create(tree.items);
            cn.course := course;
            cn.category := '';
            tree.items.addNode(cn, pn, strOtherTasks, nil, naAddChild);
          end;
          addChildObject(cn, course[i].name, course[i]);
        end;
        pn.expanded := true;
      finally
        endUpdate;
      end;
    end;
    if sel <> nil then begin
      n := tree.items.findNodeWithData(sel);
      if n <> nil then tree.selected := n;
    end;
    refreshProps;
  finally
    endRefresh;
  end;
end;

procedure tMainForm.bvTreeSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then begin
    fTreeSizing := true;
    fSizingPoint := bvTreeSizer.clientToScreen(point(x, y));
  end;
end;

procedure tMainForm.actFileExitExecute(sender: tObject);
begin
  close;
end;

procedure tMainForm.bvTreeSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
var
  p: tPoint;
  dw: integer;
begin
  if fTreeSizing then begin
    p := bvTreeSizer.clientToScreen(point(x, y));
    dw := p.x - fSizingPoint.x;
    with pnProps do if width - dw < 100 then dw := width - 100;
    pnTree.width := max(100, pnTree.width + dw);
    fSizingPoint := p;
  end;
end;

procedure tMainForm.bvTreeSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then fTreeSizing := false;
end;

procedure tMainForm.formCloseQuery(sender: tObject; var canClose: boolean);
begin
  canClose := promptToSave;
end;

procedure tMainForm.formShow(sender: tObject);
var
  fn: string;
begin
  if paramCount > 0 then begin
    fn := expandFileName(paramStr(1));
    openCourse(fn);
  end;
end;

procedure tMainForm.treeChange(sender: tObject; node: tTreeNode);
begin
  refreshProps;
end;

procedure tMainForm.treeChanging(sender: tObject; node: tTreeNode; var allowChange: boolean);
begin
  allowChange := propsUpdated;
end;

procedure tMainForm.refreshProps;
var
  n: tTreeNode;
  obj: tObject = nil;
begin
  beginRefresh;
  try
    n := tree.selected;
    if n <> nil then obj := tObject(n.data);
    if obj is tKlausCourse then begin
      fCourseProps.data := obj;
      fCategoryProps.data := nil;
      fTaskProps.data := nil;
    end else if n is tCategoryTreeNode then begin
      fCourseProps.data := nil;
      fCategoryProps.data := n;
      fTaskProps.data := nil;
    end else if obj is tKlausTask then begin
      fCourseProps.data := nil;
      fCategoryProps.data := nil;
      fTaskProps.data := obj;
    end else begin
      fCourseProps.data := nil;
      fCategoryProps.data := nil;
      fTaskProps.data := nil;
    end;
  finally
    endRefresh;
    enableDisable;
  end;
end;

procedure tMainForm.updateProps;
begin
  fCourseProps.updateData;
  fCategoryProps.updateData;
  fTaskProps.updateData;
end;

function tMainForm.propsUpdated: boolean;
begin
  result := not fCourseProps.updateError
    and not fCategoryProps.updateError
    and not fTaskProps.updateError;
end;

function tMainForm.findCategoryNode(s: string): tCategoryTreeNode;
var
  n: tTreeNode;
begin
  result := nil;
  s := u8Lower(s);
  n := tree.items.getFirstNode;
  while n <> nil do begin
    if n is tCategoryTreeNode then
      if u8Lower((n as tCategoryTreeNode).category) = s then begin
        result := n as tCategoryTreeNode;
        break;
      end;
    n := n.getNext;
  end;
end;

procedure tMainForm.renameCategory(node: tCategoryTreeNode; newName: string);
var
  cn: tTreeNode;
  n: tCategoryTreeNode;
begin
  with node do begin
    course.renameCategory(category, newName);
    n := mainForm.findCategoryNode(newName);
    if (n <> nil) and (n <> node) then begin
      cn := n.getFirstChild;
      while cn <> nil do begin
        node.owner.addNode(cn, node, cn.text, cn.data, naAddChild);
        cn := n.getFirstChild;
      end;
      freeAndNil(n);
    end;
    category := newName;
    if newName <> '' then text := newName else text := strOtherTasks;
  end;
end;

procedure tMainForm.renameTask(task: tKlausTask; newName: string);
var
  n: tTreeNode;
begin
  task.name := newName;
  n := tree.items.findNodeWithData(task);
  if n <> nil then n.text := newName;
end;

procedure tMainForm.setModified(val: boolean);
begin
  if fModified <> val then begin
    fModified := val;
    enableDisable;
  end;
end;

function tMainForm.getRefreshing: boolean;
begin
  result := fRefreshCount > 0;
end;

procedure tMainForm.beginRefresh;
begin
  inc(fRefreshCount);
end;

procedure tMainForm.endRefresh;
begin
  if fRefreshCount > 0 then begin
    dec(fRefreshCount);
    if fRefreshCount = 0 then enableDisable;
  end;
end;

procedure tMainForm.enableDisable;
var
  n: tTreeNode;
  obj: tObject = nil;
begin
  if refreshing then exit;
  actFileSave.enabled := modified;
  n := tree.selected;
  if n <> nil then obj := tObject(n.data);
  fCourseProps.enabled := obj is tKlausCourse;
  fCourseProps.visible := obj is tKlausCourse;
  fCategoryProps.enabled := n is tCategoryTreeNode;
  fCategoryProps.visible := n is tCategoryTreeNode;
  fTaskProps.enabled := obj is tKlausTask;
  fTaskProps.visible := obj is tKlausTask;
  actTaskDelete.enabled := obj is tKlausTask;
end;

function tMainForm.promptToSave: boolean;
begin
  updateProps;
  if not propsUpdated then exit(false);
  if (course = nil) or not modified then exit(true);
  case messageDlg(format(strPromptToSave, [course.name]), mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
    mrYes: result := saveCourse;
    mrNo: result := true;
    else result := false;
  end;
end;

procedure tMainForm.actFileNewExecute(sender: tObject);
begin
  if not promptToSave then exit;
  createCourse;
end;

procedure tMainForm.createCourse;
begin
  if fCourse <> nil then freeAndNil(fCourse);
  fCourse := tKlausCourse.create(klausPracticum);
  refreshWindow;
end;

procedure tMainForm.actFileOpenExecute(sender: tObject);
begin
  if not promptToSave then exit;
  with openDialog do if execute then openCourse(fileName);
end;

procedure tMainForm.actFileSaveAsExecute(Sender: TObject);
begin
  saveCourse(true);
end;

procedure tMainForm.actFileSaveExecute(Sender: TObject);
begin
  saveCourse;
end;

procedure tMainForm.actTaskAddExecute(sender: tObject);
var
  n: tTreeNode;
  cat: string = '';
  task: tKlausTask;
begin
  n := tree.selected;
  if n <> nil then begin
    if n is tCategoryTreeNode then cat := (n as tCategoryTreeNode).category
    else if tObject(n.data) is tKlausTask then cat := tKlausTask(n.data).category;
  end;
  task := tKlausTask.create(course);
  task.category := cat;
  refreshTree(task);
  modified := true;
end;

procedure tMainForm.actTaskDeleteExecute(sender: tObject);
var
  n: tTreeNode;
  s, cat: string;
begin
  n := tree.selected;
  if n <> nil then
    if tObject(n.data) is tKlausTask then begin
      s := format(strConfirmDelete, [tKlausTask(n.data).name]);
      if messageDlg(s, mtConfirmation, [mbYes, mbCancel], 0) <> mrYes then exit;
      cat := tKlausTask(n.data).category;
      tKlausTask(n.data).free;
      refreshTree;
      n := findCategoryNode(cat);
      if n <> nil then n.expanded := true;
      modified := true;
    end;
end;

procedure tMainForm.openCourse(fileName: string);
begin
  if fCourse <> nil then freeAndNil(fCourse);
  fCourse := tKlausCourse.create(klausPracticum, fileName);
  refreshWindow;
end;

function tMainForm.saveCourse(saveAs: boolean = false): boolean;
var
  n: tTreeNode;
begin
  result := false;
  if course = nil then exit;
  if saveAs or (course.fileName = '') then begin
    if course.fileName = '' then saveDialog.fileName := course.name + '.klaus-course'
    else saveDialog.fileName := course.fileName;
    if not saveDialog.execute then exit;
    course.saveToFile(saveDialog.fileName);
  end else
    course.saveToFile;
  n := tree.items.findNodeWithData(course);
  if n <> nil then n.text := course.name;
  updateCaption;
  modified := false;
  result := true;
end;

end.

