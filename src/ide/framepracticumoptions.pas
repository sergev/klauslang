unit FramePracticumOptions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, EditBtn, Grids,
  KlausGlobals;

type

  { tPracticumOptionsFrame }

  tPracticumOptionsFrame = class(TFrame)
    Bevel4: TBevel;
    Bevel5: TBevel;
    edSearchPath: TEditButton;
    edWorkingDir: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    lblCourseFileName: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    pnDirectories: TPanel;
    sgCourses: TStringGrid;
    procedure edSearchPathButtonClick(Sender: TObject);
    procedure edSearchPathChange(Sender: TObject);
    procedure edSearchPathKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edWorkingDirChange(Sender: TObject);
    procedure sgCoursesAfterSelection(Sender: TObject; aCol, aRow: Integer);
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

uses LCLType, KlausPract, FormMain;

{$R *.lfm}

resourcestring
  strCourseFileName = 'Файл курса: %s';
  strNone = '(нет)';

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

procedure tPracticumOptionsFrame.edSearchPathChange(Sender: TObject);
begin
  if refreshing then exit;
  fPracticumOptions.searchPath := edsearchPath.text;
end;

procedure tPracticumOptionsFrame.edSearchPathKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  shift := shift * [ssShift, ssCtrl, ssAlt];
  if (key = VK_F5) and (shift = []) then edSearchPath.button.click;
end;

procedure tPracticumOptionsFrame.edSearchPathButtonClick(Sender: TObject);
begin
  mainForm.practicumOptions.searchPath := practicumOptions.searchPath;
  mainForm.loadPracticum;
  refreshCourseInfo;
end;

procedure tPracticumOptionsFrame.edWorkingDirChange(Sender: TObject);
begin
  if refreshing then exit;
  fPracticumOptions.workingDir := edWorkingDir.text;
end;

procedure tPracticumOptionsFrame.sgCoursesAfterSelection(Sender: TObject; aCol, aRow: Integer);
begin
  refreshCourseFileName;
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
begin
  with klausPracticum do begin
    sgCourses.rowCount := count+1;
    for i := 0 to count-1 do begin
      sgCourses.cells[0, i+1] := courses[i].name;
      sgCourses.cells[1, i+1] := courses[i].author;
      sgCourses.cells[2, i+1] := intToStr(courses[i].taskCount);
      sgCourses.cells[3, i+1] := courses[i].caption;
      sgCourses.cells[4, i+1] := courses[i].fileName;
    end;
  end;
  refreshCourseFileName;
end;

procedure tPracticumOptionsFrame.refreshCourseFileName;
var
  fn: string;
begin
  with sgCourses do if row < 1 then fn := strNone else fn := cells[4, row];
  lblCourseFileName.caption := format(strCourseFileName, [fn]);
end;

procedure tPracticumOptionsFrame.enableDisable;
begin
end;

end.

