unit FrameDoerError;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls;

type
  tDoerErrorFrame = class(TFrame)
    img: TImage;
    lblMessage: TLabel;
  private
    function  getMessage: string;
    procedure setMessage(val: string);

  public
    property message: string read getMessage write setMessage;
  end;

implementation

{$R *.lfm}

{ tDoerErrorFrame }

function tDoerErrorFrame.getMessage: string;
begin
  result := lblMessage.caption;
end;

procedure tDoerErrorFrame.setMessage(val: string);
begin
  lblMessage.caption := val;
  visible := val <> '';
end;

end.

