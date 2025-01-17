unit FramePracticumOptions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, EditBtn, Grids,
  KlausGlobals, KlausErr;

type
  tPracticumOptionsFrame = class(tFrame)
    Bevel4: tBevel;
    Bevel5: tBevel;
    edSearchPath: tEditButton;
    edWorkingDir: tEdit;
    Label1: tLabel;
    Label10: tLabel;
    Label11: tLabel;
    lblCourseFileName: tLabel;
    Label3: tLabel;
    Label4: tLabel;
    Panel14: tPanel;
    Panel15: tPanel;
    Panel3: tPanel;
    Panel4: tPanel;
    pnDirectories: tPanel;
    sgCourses: tStringGrid;
    procedure edSearchPathButtonClick(sender: tObject);
    procedure edSearchPathChange(sender: tObject);
    procedure edSearchPathKeyDown(sender: tObject; var key: word; shift: tShiftState);
    procedure edWorkingDirChange(sender: tObject);
    procedure sgCoursesAfterSelection(sender: tObject; aCol, aRow: integer);
    procedure sgCoursesButtonClick(sender: tObject; aCol, aRow: integer);
  private
    fRefreshCount: integer;
    fPracticumOptions: tKlausPracticumOptions;

    function  getRefreshing: boolean;
    procedure beginRefresh;
    procedure endRefresh;
    procedure setPracticumOptions(val: tKlausPracticumOptions);
  public
    property refreshing: boolean read getRefreshing;
    property practicumOptions: tKlausPracticumOptions read fPracticumOptions write setPracticumOptions;

    constructor create(aOwner: tComponent); override;
    destructor  destroy; override;
    procedure refreshWindow;
    procedure refreshCourseInfo;
    procedure refreshCourseFileName;
    procedure enableDisable;
  end;

implementation

uses LCLType, KlausPract, FormMain, Zipper, Dialogs;

{$R *.lfm}

resourcestring
  strCourseFileName = 'Файл курса: %s';
  strNone = '(нет)';
  strSolutionsSetup = 'распаковать...';
  strPromptCreateDir = 'Каталог "%s" не существует. Создать его?';
  strPromptExistingDir = 'Файлы решений задач будут распакованы в "%s". Существующие файлы в этом каталоге могут быть перезаписаны. Продолжить?';
  strSolutionsInstalled = 'Решения задач были успешно распакованы в "%s".';

{ tPracticumOptionsFrame }

constructor tPracticumOptionsFrame.create(aOwner: tComponent);
begin
  inherited;
  fPracticumOptions := tKlausPracticumOptions.create;
end;

destructor tPracticumOptionsFrame.destroy;
begin
  freeAndNil(fPracticumOptions);
  inherited;
end;

procedure tPracticumOptionsFrame.edSearchPathChange(sender: tObject);
begin
  if refreshing then exit;
  fPracticumOptions.searchPath := edsearchPath.text;
end;

procedure tPracticumOptionsFrame.edSearchPathKeyDown(sender: tObject; var key: word; shift: tShiftState);
begin
  shift := shift * [ssShift, ssCtrl, ssAlt];
  if (key = VK_F5) and (shift = []) then edSearchPath.button.click;
end;

procedure tPracticumOptionsFrame.edSearchPathButtonClick(sender: tObject);
begin
  mainForm.practicumOptions.searchPath := practicumOptions.searchPath;
  mainForm.loadPracticum;
  refreshCourseInfo;
end;

procedure tPracticumOptionsFrame.edWorkingDirChange(sender: tObject);
begin
  if refreshing then exit;
  fPracticumOptions.workingDir := edWorkingDir.text;
end;

procedure tPracticumOptionsFrame.sgCoursesAfterSelection(sender: tObject; aCol, aRow: integer);
begin
  refreshCourseFileName;
end;

procedure tPracticumOptionsFrame.sgCoursesButtonClick(sender: tObject; aCol, aRow: integer);
var
  s, dir, msg: string;
  zip: tUnzipper;
begin
  if aCol = 4 then
    with klausPracticum do begin
      s := courses[aRow-1].solutions;
      if s <> '' then begin
        zip := tUnzipper.create;
        try
          with practicumOptions do dir := expandFileName(expandPath(workingDir));
          dir := includeTrailingPathDelimiter(dir) + courses[aRow-1].name;
          if not directoryExists(dir) then begin
            msg := format(strPromptCreateDir, [dir]);
            if messageDlg(msg, mtConfirmation, [mbYes, mbCancel], 0) <> mrYes then exit;
            if not forceDirectories(dir) then
              raise eKlausError.createFmt(ercCannotCreateDirectory, zeroSrcPt, [dir]);
          end else begin
            msg := format(strPromptExistingDir, [dir]);
            if messageDlg(msg, mtConfirmation, [mbYes, mbCancel], 0) <> mrYes then exit;
          end;
          zip.fileName := s;
          zip.outputPath := dir;
          zip.unzipAllFiles;
          messageDlg(format(strSolutionsInstalled, [dir]), mtInformation, [mbOK], 0);
        finally
          freeAndNil(zip);
        end;
      end;
    end;
end;

function tPracticumOptionsFrame.getRefreshing: boolean;
begin
  result := fRefreshCount > 0;
end;

procedure tPracticumOptionsFrame.beginRefresh;
begin
  inc(fRefreshCount);
end;

procedure tPracticumOptionsFrame.endRefresh;
begin
  if fRefreshCount > 0 then dec(fRefreshCount);
end;

procedure tPracticumOptionsFrame.setPracticumOptions(val: tKlausPracticumOptions);
begin
  fPracticumOptions.assign(val);
  refreshWindow;
end;

procedure tPracticumOptionsFrame.refreshWindow;
begin
  beginRefresh;
  try
    with fPracticumOptions do begin
      edSearchPath.text := searchPath;
      edWorkingDir.text := workingDir;
    end;
    refreshCourseInfo;
  finally
    endRefresh;
  end;
end;

procedure tPracticumOptionsFrame.refreshCourseInfo;
var
  i: integer;
  sol: boolean = false;
begin
  with klausPracticum do begin
    sgCourses.rowCount := count+1;
    for i := 0 to count-1 do begin
      sgCourses.cells[0, i+1] := courses[i].name;
      sgCourses.cells[1, i+1] := courses[i].author;
      sgCourses.cells[2, i+1] := intToStr(courses[i].taskCount);
      sgCourses.cells[3, i+1] := courses[i].caption;
      if courses[i].solutions = '' then
        sgCourses.cells[4, i+1] := strNone
      else begin
        sgCourses.cells[4, i+1] := strSolutionsSetup;
        sol := true;
      end;
      sgCourses.cells[5, i+1] := courses[i].fileName;
    end;
  end;
  sgCourses.columns[4].visible := sol;
  refreshCourseFileName;
end;

procedure tPracticumOptionsFrame.refreshCourseFileName;
var
  fn: string;
begin
  with sgCourses do if row < 1 then fn := strNone else fn := cells[5, row];
  lblCourseFileName.caption := format(strCourseFileName, [fn]);
end;

procedure tPracticumOptionsFrame.enableDisable;
begin
end;

end.

