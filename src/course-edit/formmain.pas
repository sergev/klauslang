unit FormMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ActnList, Menus,
  ComCtrls, KlausPract;

type
  tMainForm = class(tForm)
    actFileOpen: TAction;
    actFileNew: TAction;
    actFileSave: TAction;
    actFileSaveAs: TAction;
    actFileExit: TAction;
    actTaskRename: TAction;
    actTaskDelete: TAction;
    actTaskAdd: TAction;
    actionImages: TImageList;
    actionList: TActionList;
    mainMenu: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    miTaskDelete: TMenuItem;
    miTaskRename: TMenuItem;
    miTaskAdd: TMenuItem;
    miFileExit: TMenuItem;
    miFileSaveAs: TMenuItem;
    miFileSave: TMenuItem;
    miFileOpen: TMenuItem;
    miFileNew: TMenuItem;
    Separator1: TMenuItem;
    statusBar: TStatusBar;
    ToolBar1: TToolBar;
    tbFileNew: TToolButton;
    tbFileOpen: TToolButton;
    tbFileSave: TToolButton;
    ToolButton4: TToolButton;
    tbTaskAdd: TToolButton;
    tbTaskRename: TToolButton;
    tbTaskDelete: TToolButton;
  private

  public

  end;

var
  mainForm: tMainForm;

implementation

{$R *.lfm}

end.

