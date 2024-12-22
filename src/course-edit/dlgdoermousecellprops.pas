unit DlgDoerMouseCellProps;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls, KlausDoer_Mouse;

type
  tDoerMouseCellPropsDlg = class(tForm)
    Bevel1: tBevel;
    chHasNumber: TCheckBox;
    pbCancel: tButton;
    pbOk: tButton;
    chMark: tCheckBox;
    edText1: tEdit;
    edText2: tEdit;
    rbArrowNone: tRadioButton;
    seTemperature: tFloatSpinEdit;
    seRadiation: tFloatSpinEdit;
    Label1: tLabel;
    Label2: tLabel;
    Label3: tLabel;
    Label5: tLabel;
    Label6: tLabel;
    rbArrowLeft: tRadioButton;
    rbArrowRight: tRadioButton;
    rbArrowUp: tRadioButton;
    rbArrowDown: tRadioButton;
    seNumber: tSpinEdit;
    procedure chHasNumberChange(sender: tObject);
  private
    function  getArrow: tklausMouseDirection;
    function  getHasNumber: boolean;
    function  getMark: boolean;
    function  getNumber: integer;
    function  getRadiation: double;
    function  getTemperature: double;
    function  getText1: string;
    function  getText2: string;
    procedure setArrow(val: tklausMouseDirection);
    procedure setHasNumber(val: boolean);
    procedure setMark(val: boolean);
    procedure setNumber(val: integer);
    procedure setRadiation(val: double);
    procedure setTemperature(val: double);
    procedure setText1(val: string);
    procedure setText2(val: string);

  public
    property text1: string read getText1 write setText1;
    property text2: string read getText2 write setText2;
    property hasNumber: boolean read getHasNumber write setHasNumber;
    property number: integer read getNumber write setNumber;
    property mark: boolean read getMark write setMark;
    property arrow: tklausMouseDirection read getArrow write setArrow;
    property temperature: double read getTemperature write setTemperature;
    property radiation: double read getRadiation write setRadiation;
  end;

var
  DoerMouseCellPropsDlg: tDoerMouseCellPropsDlg;

implementation

{$R *.lfm}

{ tDoerMouseCellPropsDlg }

procedure tDoerMouseCellPropsDlg.chHasNumberChange(sender: tObject);
begin
  if not chHasNumber.checked then seNumber.value := 0;
  seNumber.enabled := chHasNumber.checked;
end;

function tDoerMouseCellPropsDlg.getArrow: tklausMouseDirection;
begin
  if rbArrowLeft.checked then result := kmdLeft
  else if rbArrowUp.checked then result := kmdUp
  else if rbArrowRight.checked then result := kmdRight
  else if rbArrowDown.checked then result := kmdDown
  else result := kmdNone;
end;

function tDoerMouseCellPropsDlg.getHasNumber: boolean;
begin
  result := chHasNumber.checked;
end;

function tDoerMouseCellPropsDlg.getMark: boolean;
begin
  result := chMark.checked;
end;

function tDoerMouseCellPropsDlg.getNumber: integer;
begin
  result := seNumber.value;
end;

function tDoerMouseCellPropsDlg.getRadiation: double;
begin
  result := seRadiation.value;
end;

function tDoerMouseCellPropsDlg.getTemperature: double;
begin
  result := seTemperature.value;
end;

function tDoerMouseCellPropsDlg.getText1: string;
begin
  result := edText1.text;
end;

function tDoerMouseCellPropsDlg.getText2: string;
begin
  result := edText2.text;
end;

procedure tDoerMouseCellPropsDlg.setArrow(val: tklausMouseDirection);
begin
  case val of
    kmdLeft: rbArrowLeft.checked := true;
    kmdUp: rbArrowUp.checked := true;
    kmdRight: rbArrowRight.checked := true;
    kmdDown: rbArrowDown.checked := true;
  else
    rbArrowNone.checked := true;
  end;
end;

procedure tDoerMouseCellPropsDlg.setHasNumber(val: boolean);
begin
  chHasNumber.checked := val;
  seNumber.enabled := val;
  if not val then seNumber.value := 0;
end;

procedure tDoerMouseCellPropsDlg.setMark(val: boolean);
begin
  chMark.checked := val;
end;

procedure tDoerMouseCellPropsDlg.setNumber(val: integer);
begin
  seNumber.value := val;
  chHasNumber.checked := true;
end;

procedure tDoerMouseCellPropsDlg.setRadiation(val: double);
begin
  seRadiation.value := val;
end;

procedure tDoerMouseCellPropsDlg.setTemperature(val: double);
begin
  seTemperature.value := val;
end;

procedure tDoerMouseCellPropsDlg.setText1(val: string);
begin
  edText1.text := val;
end;

procedure tDoerMouseCellPropsDlg.setText2(val: string);
begin
  edText2.text := val;
end;

end.

