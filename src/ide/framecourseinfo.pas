unit FrameCourseInfo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Messages, Forms, Controls, ExtCtrls, Buttons, StdCtrls,
  ActnList, ComCtrls, IpHtml, IpFileBroker, KlausGlobals, KlausPract, KlausDoer,
  FrameTaskDoerInfo;

type
  tCourseInfoFrame = class(tFrame)
    actSolve: TAction;
    actSettings: TAction;
    actionImages: TImageList;
    actionList: TActionList;
    actRefresh: TAction;
    buttonImages: TImageList;
    bvTreeSizer: TBevel;
    bvDoerSizer: TBevel;
    htmlInfo: TIpHtmlPanel;
    lblCaption: TLabel;
    pnDescription: TPanel;
    pnTree: TPanel;
    pnContent: TPanel;
    pnHeader: TPanel;
    pnDoer: TPanel;
    sbClose: TSpeedButton;
    Shape1: TShape;
    tbAdd: TToolButton;
    tbEdit: TToolButton;
    toolBar: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    tree: TTreeView;
    procedure actRefreshExecute(Sender: TObject);
    procedure actSettingsExecute(Sender: TObject);
    procedure actSolveExecute(Sender: TObject);
    procedure htmlInfoHotClick(Sender: TObject);
    procedure htmlInfoHotURL(Sender: TObject; const URL: String);
    procedure sbCloseClick(Sender: TObject);
    procedure treeChange(Sender: TObject; Node: TTreeNode);
    procedure bvTreeSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvTreeSizerMouseMove(sender: TObject; shift: TShiftState; x, y: integer);
    procedure bvTreeSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvDoerSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvDoerSizerMouseMove(sender: TObject; shift: TShiftState; x, y: integer);
    procedure bvDoerSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure treeDblClick(Sender: TObject);
  private
    fActiveCourse: string;
    fActiveTask: string;
    fTaskNotFound: boolean;
    fHotURL: string;
    fTreePanelSizing: boolean;
    fDoerPanelSizing: boolean;
    fSizingPoint: tPoint;
    fDoerFrame: tTaskDoerInfoFrame;

    function  getSelectedTask: tKlausTask;
    procedure updateTree(course: tKlausCourse);
    procedure updateSelection;
    procedure updateActiveTaskInfo;
    procedure updateTaskDoerSettings;
  public
    property activeCourse: string read fActiveCourse;
    property activeTask: string read fActiveTask;
    property selectedTask: tKlausTask read getSelectedTask;

    procedure updateContent(courseName, taskName: string; force: boolean = false);
  end;

implementation

{$R *.lfm}

uses formMain, klausUtils, LCLIntf, U8, Math;

resourcestring
  strCourseNotFound = '(курс не найден)';
  strOtherTasks = '(другие задачи)';
  strItemCaption = '%s - %s';
  strUnnamed = '(без названия)';
  strTaskNotFound = 'Задача не найдена: **%s**';

{ tCourseInfoFrame }

procedure tCourseInfoFrame.sbCloseClick(Sender: TObject);
begin
  mainForm.showCourseInfo('', '');
end;

procedure tCourseInfoFrame.treeChange(Sender: TObject; Node: TTreeNode);
begin
  fTaskNotFound := false;
  updateActiveTaskInfo;
end;

procedure tCourseInfoFrame.htmlInfoHotURL(Sender: TObject; const URL: String);
begin
  fHotURL := URL;
end;

procedure tCourseInfoFrame.htmlInfoHotClick(Sender: TObject);
begin
  if fHotURL <> '' then openURL(fHotURL);
end;

procedure tCourseInfoFrame.actSettingsExecute(Sender: TObject);
begin
  mainForm.showOptionsDlg('tsPracticum');
end;

procedure tCourseInfoFrame.actSolveExecute(Sender: TObject);
var
  task: tKlausTask;
begin
  task := selectedTask;
  if task <> nil then mainForm.openTaskSolution(task);
end;

procedure tCourseInfoFrame.actRefreshExecute(Sender: TObject);
begin
  mainForm.loadPracticum;
end;

procedure tCourseInfoFrame.updateContent(courseName, taskName: string; force: boolean);
var
  course: tKlausCourse;
  courseChanged: boolean;
begin
  courseName := u8Lower(courseName);
  taskName := u8Lower(taskName);
  if not force and (fActiveCourse = courseName) and (fActiveTask = taskName) then exit;
  courseChanged := force or (fActiveCourse <> courseName);
  fActiveCourse := courseName;
  fActiveTask := taskName;
  course := klausPracticum.course[fActiveCourse];
  if course = nil then fTaskNotFound := false
  else fTaskNotFound := (fActiveTask <> '') and (course.task[fActiveTask] = nil);
  if courseChanged then updateTree(course) else updateSelection;
end;

procedure tCourseInfoFrame.updateTree(course: tKlausCourse);
var
  i, j: integer;
  cat, s: string;
  pn, tn, cn, sel: tTreeNode;
begin
  sel := nil;
  with tree.items do begin
    beginUpdate;
    try
      clear;
      if course <> nil then begin
        s := course.caption;
        if s = '' then s := strUnnamed;
        s := format(strItemCaption, [course.name, s]);
        pn := addObject(nil, s, course);
        if course.catCount <= 0 then begin
          for i := 0 to course.taskCount-1 do begin
            s := course[i].caption;
            if s = '' then s := strUnnamed;
            s := format(strItemCaption, [course[i].name, s]);
            tn := addChildObject(pn, s, course[i]);
            if u8Lower(course[i].name) = fActiveTask then sel := tn;
          end;
        end else begin
          for j := 0 to course.catCount-1 do begin
            cat := u8Lower(course.categories[j]);
            cn := addChildObject(pn, course.categories[j], nil);
            for i := 0 to course.taskCount-1 do begin
              if u8Lower(course[i].category) <> cat then continue;
              s := course[i].caption;
              if s = '' then s := strUnnamed;
              s := format(strItemCaption, [course[i].name, s]);
              tn := addChildObject(cn, s, course[i]);
              if u8Lower(course[i].name) = fActiveTask then sel := tn;
            end;
          end;
          cn := nil;
          for i := 0 to course.taskCount-1 do begin
            if course[i].category <> '' then continue;
            if cn = nil then cn := addChildObject(pn, strOtherTasks, nil);
            s := format(strItemCaption, [course[i].name, course[i].caption]);
            tn := addChildObject(cn, s, course[i]);
            if u8Lower(course[i].name) = fActiveTask then sel := tn;
          end;
        end;
        pn.expanded := true;
        if sel = nil then tree.selected := pn else tree.selected := sel;
      end else
        addObject(nil, format(strItemCaption, [fActiveCourse, strCourseNotFound]), nil);
    finally
      endUpdate;
    end;
  end;
  updateActiveTaskInfo;
end;

function tCourseInfoFrame.getSelectedTask: tKlausTask;
var
  course: tKlausCourse;
begin
  result := nil;
  if (activeCourse = '') or (activeTask = '') then exit;
  course := klausPracticum.course[activeCourse];
  if course <> nil then result := course.task[activeTask];
end;

procedure tCourseInfoFrame.updateSelection;
var
  n: tTreeNode;
  t: tKlausTask;
  c: tKlausCourse;
begin
  try
    c := klausPracticum.course[fActiveCourse];
    if c = nil then exit;
    if fActiveTask <> '' then begin
      t := c.task[fActiveTask];
      if t <> nil then begin
        n := tree.items.findNodeWithData(t);
        if n <> nil then begin
          tree.selected := n;
          exit;
        end else
          fTaskNotFound := true;
      end;
    end else
      fTaskNotFound := false;
    n := tree.items.findNodeWithData(c);
    if n <> nil then tree.selected := n;
  finally
    updateActiveTaskInfo;
  end;
end;

procedure tCourseInfoFrame.updateActiveTaskInfo;
var
  n: tTreeNode;
  desc: string;
  obj: tObject = nil;
begin
  if fTaskNotFound then
    htmlInfo.setHtml(markdownToHtml(format(strTaskNotFound, [fActiveTask])))
  else begin
    n := tree.selected;
    if n <> nil then obj := tObject(n.data);
    if obj is tKlausCourse then begin
      fActiveTask := '';
      desc := (obj as tKlausCourse).description;
      if desc = '' then desc := (obj as tKlausCourse).caption;
      if desc = '' then desc := (obj as tKlausCourse).name;
      htmlInfo.setHtml(markdownToHtml(desc));
    end else if obj is tKlausTask then begin
      fActiveTask := u8Lower((obj as tKlausTask).name);
      desc := (obj as tKlausTask).description;
      if desc = '' then desc := (obj as tKlausTask).caption;
      if desc = '' then desc := (obj as tKlausTask).name;
      htmlInfo.setHtml(markdownToHtml(desc));
    end else begin
      fActiveTask := '';
      htmlInfo.setHtml(nil);
    end;
  end;
  updateTaskDoerSettings;
  actSolve.enabled := selectedTask <> nil;
end;

procedure tCourseInfoFrame.updateTaskDoerSettings;
var
  task: tKlausTask;
  doer: tKlausDoerClass;
begin
  task := selectedTask;
  if task = nil then doer := nil else doer := task.doer;
  if doer = nil then begin
    pnDoer.visible := false;
    freeAndNil(fDoerFrame);
  end else begin
    pnDoer.visible := true;
    if fDoerFrame = nil then begin
      fDoerFrame := tTaskDoerInfoFrame.create(self);
      fDoerFrame.parent := pnDoer;
      fDoerFrame.align := alClient;
    end;
    fDoerFrame.settings := task.doerSettings;
  end;
end;

procedure tCourseInfoFrame.bvTreeSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then begin
    fTreePanelSizing := true;
    fSizingPoint := bvTreeSizer.clientToScreen(point(x, y));
  end;
end;

procedure tCourseInfoFrame.bvTreeSizerMouseMove(sender: TObject; shift: TShiftState; x, y: integer);
var
  p: tPoint;
  dh: integer;
begin
  if fTreePanelSizing then begin
    p := bvTreeSizer.clientToScreen(point(x, y));
    dh := p.y - fSizingPoint.y;
    with pnDescription do if height - dh < 100 then dh := height - 100;
    pnTree.height := max(100, pnTree.height + dh);
    fSizingPoint := p;
  end;
end;

procedure tCourseInfoFrame.bvTreeSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then fTreePanelSizing := false;
end;

procedure tCourseInfoFrame.bvDoerSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then begin
    fDoerPanelSizing := true;
    fSizingPoint := bvDoerSizer.clientToScreen(point(x, y));
  end;
end;

procedure tCourseInfoFrame.bvDoerSizerMouseMove(sender: TObject; shift: TShiftState; x, y: integer);
var
  p: tPoint;
  dh: integer;
begin
  if fDoerPanelSizing then begin
    p := bvDoerSizer.clientToScreen(point(x, y));
    dh := fSizingPoint.y - p.y;
    with pnDescription do if height - dh < 100 then dh := height - 100;
    pnDoer.height := max(100, pnDoer.height + dh);
    fSizingPoint := p;
  end;
end;

procedure tCourseInfoFrame.bvDoerSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then fDoerPanelSizing := false;
end;

procedure tCourseInfoFrame.treeDblClick(Sender: TObject);
begin
  with actSolve do if enabled then execute;
end;

end.

