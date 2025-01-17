program KlausCourseEdit;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, SysUtils, Forms, FormMain, FrameProps,
  FrameMarkdown, FrameCourseProps, FrameCategoryProps, FrameTaskProps,
  FrameDoer, KlausDoer_Mouse, FrameDoerSetting_Mouse, DlgDoerMouseCellProps;

{$R *.res}
{$R *.ver.res}

function getAppName: string;
begin
  result := 'klaus-course-edit';
end;

begin
  onGetApplicationName := @getAppName;
  requireDerivedFormResource := true;
  Application.Title:='KlausCourseEdit';
  Application.Scaled:=True;
  application.exceptionDialog := aedOkMessageBox;
  application.initialize;
  {$push}{$warn SYMBOL_PLATFORM off}
  application.updateFormatSettings := false;
  {$pop}
  application.createForm(tMainForm, mainForm);
  application.run;
end.

