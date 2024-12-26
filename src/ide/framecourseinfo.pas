unit FrameCourseInfo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Messages, Forms, Controls, ExtCtrls, Buttons, StdCtrls,
  ActnList, ComCtrls, IpHtml, IpFileBroker, KlausGlobals, KlausPract, KlausDoer,
  FrameTaskDoerInfo;

type
  tCourseInfoFrame = class(tFrame)
    actSolve: tAction;
    actSettings: tAction;
    actionImages: tImageList;
    actionList: tActionList;
    actRefresh: tAction;
    buttonImages: tImageList;
    bvTreeSizer: tBevel;
    bvDoerSizer: tBevel;
    htmlInfo: tIpHtmlPanel;
    lblCaption: tLabel;
    pnDescription: tPanel;
    pnTree: tPanel;
    pnContent: tPanel;
    pnHeader: tPanel;
    pnDoer: tPanel;
    sbClose: tSpeedButton;
    Shape1: tShape;
    tbAdd: tToolButton;
    tbEdit: tToolButton;
    toolBar: tToolBar;
    ToolButton1: tToolButton;
    ToolButton2: tToolButton;
    tree: tTreeView;
    procedure actRefreshExecute(sender: tObject);
    procedure actSettingsExecute(sender: tObject);
    procedure actSolveExecute(sender: tObject);
    procedure htmlInfoHotClick(sender: tObject);
    procedure htmlInfoHotURL(sender: tObject; const URL: String);
    procedure sbCloseClick(sender: tObject);
    procedure treeChange(sender: tObject; Node: tTreeNode);
    procedure bvTreeSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvTreeSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
    procedure bvTreeSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvDoerSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure bvDoerSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
    procedure bvDoerSizerMouseUp(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
    procedure treeDblClick(sender: tObject);
  private
    fActiveCourse: string;
    fActiveTask: string;
    fTaskNotFound: boolean;
    fHotURL: string;
    fTreePanelSizing: boolean;
    fDoerPanelSizing: boolean;
    fSizingPoint: tPoint;
    fDoerFrame: tTaskDoerInfoFrame;

    function  getSelectedSetting: tKlausDoerSetting;
    function  getSelectedTask: tKlausTask;
    procedure updateTree(course: tKlausCourse);
    procedure updateSelection;
    procedure updateActiveTaskInfo;
    procedure updateTaskDoerSettings;
    procedure updateHeights;
  public
    property activeCourse: string read fActiveCourse;
    property activeTask: string read fActiveTask;
    property selectedTask: tKlausTask read getSelectedTask;
    property selectedSetting: tKlausDoerSetting read getSelectedSetting;

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

procedure tCourseInfoFrame.sbCloseClick(sender: tObject);
begin
  mainForm.showCourseInfo('', '');
end;

procedure tCourseInfoFrame.treeChange(sender: tObject; Node: tTreeNode);
begin
  fTaskNotFound := false;
  updateActiveTaskInfo;
end;

procedure tCourseInfoFrame.htmlInfoHotURL(sender: tObject; const URL: String);
begin
  fHotURL := URL;
end;

procedure tCourseInfoFrame.htmlInfoHotClick(sender: tObject);
begin
  if fHotURL <> '' then openURL(fHotURL);
end;

procedure tCourseInfoFrame.actSettingsExecute(sender: tObject);
begin
  mainForm.showOptionsDlg('tsPracticum');
end;

procedure tCourseInfoFrame.actSolveExecute(sender: tObject);
var
  task: tKlausTask;
begin
  task := selectedTask;
  if task <> nil then mainForm.openTaskSolution(task);
end;

procedure tCourseInfoFrame.actRefreshExecute(sender: tObject);
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

function tCourseInfoFrame.getSelectedSetting: tKlausDoerSetting;
begin
  if fDoerFrame = nil then exit(nil);
  result := fDoerFrame.selectedSetting;
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
  updateHeights;
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
    fDoerFrame.task := task;
  end;
end;

procedure tCourseInfoFrame.updateHeights;
var
  h, h1, h3: integer;
begin
  h := pnContent.height;
  h1 := pnTree.height;
  with pnDoer do if visible then h3 := height else h3 := 0;
  if h-h1-h3 < 100 then begin
    h1 := max(100, h-h3-100);
    if pnDoer.visible and (h-h1-h3 < 100) then begin
      h3 := max(100, h-h1-100);
      pnDoer.height := h3;
    end;
    pnTree.height := h1;
    tree.makeSelectionVisible;
  end;
end;

procedure tCourseInfoFrame.bvTreeSizerMouseDown(sender: tObject; button: tMouseButton; shift: tShiftState; x, y: integer);
begin
  if (button = mbLeft) then begin
    fTreePanelSizing := true;
    fSizingPoint := bvTreeSizer.clientToScreen(point(x, y));
  end;
end;

procedure tCourseInfoFrame.bvTreeSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
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

procedure tCourseInfoFrame.bvDoerSizerMouseMove(sender: tObject; shift: tShiftState; x, y: integer);
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

procedure tCourseInfoFrame.treeDblClick(sender: tObject);
begin
  with actSolve do if enabled then execute;
end;

end.

