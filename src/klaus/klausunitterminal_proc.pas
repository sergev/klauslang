{
Этот файл — часть KlausLang.

KlausLang — свободное программное обеспечение: вы можете перераспространять
его и/или изменять его на условиях Стандартной общественной лицензии GNU
в том виде, в каком она была опубликована Фондом свободного программного
обеспечения; либо версии 3 лицензии, либо (по вашему выбору) любой более
поздней версии.

Программное обеспечение KlausLang распространяется в надежде, что оно будет
полезным, но БЕЗ ВСЯКИХ ГАРАНТИЙ; даже без неявной гарантии ТОВАРНОГО ВИДА
или ПРИГОДНОСТИ ДЛЯ ОПРЕДЕЛЕННЫХ ЦЕЛЕЙ.

Подробнее см. в Стандартной общественной лицензии GNU.
Вы должны были получить копию Стандартной общественной лицензии GNU вместе
с этим программным обеспечением. Кроме того, с текстом лицензии  можно
ознакомиться здесь: <https://www.gnu.org/licenses/>.
}

unit KlausUnitTerminal_Proc;

{$mode ObjFPC}{$H+}

interface

uses
  Types, Classes, SysUtils, U8, KlausErr, KlausLex, KlausDef, KlausSyn, KlausSrc,
  KlausUnitSystem, KlausUnitTerminal;

type
  // процедура терминал(вх поток: целое; вх сквозной: логическое);
  tKlausSysProc_TerminalMode = class(tKlausSysProcDecl)
    private
      fHandle: tKlausProcParam;
      fRaw: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // Базовый класс для функций работы с терминалом
  tKlausSysTermProc = class(tKlausSysProcDecl)
    protected
      procedure writeStdStream(frame: tKlausStackFrame; const s: string); virtual;
  end;

type
  // процедура размерЭкрана(вх горз, верт: целое);
  tKlausSysProc_SetScreenSize = class(tKlausSysTermProc)
    private
      fHorz: tKlausProcParam;
      fVert: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура очиститьЭкран;
  tKlausSysProc_ClearScreen = class(tKlausSysTermProc)
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура очиститьСтроку(вх где: целое);
  tKlausSysProc_ClearLine = class(tKlausSysTermProc)
    private
      fWhere: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура курсор(вх горз, верт: целое);
  tKlausSysProc_SetCursorPos = class(tKlausSysTermProc)
    private
      fHorz: tKlausProcParam;
      fVert: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура курсорВерт(вх верт: целое);
  tKlausSysProc_SetCursorPosVert = class(tKlausSysTermProc)
    private
      fVert: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура курсорГорз(вх горз: целое);
  tKlausSysProc_SetCursorPosHorz = class(tKlausSysTermProc)
    private
      fHorz: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура подвинутьКурсор(вх горз, верт: целое);
  tKlausSysProc_CursorMove = class(tKlausSysTermProc)
    private
      fHorz: tKlausProcParam;
      fVert: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура запомнитьКурсор();
  tKlausSysProc_CursorSave = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура вернутьКурсор();
  tKlausSysProc_CursorRestore = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура скрытьКурсор;
  tKlausSysProc_HideCursor = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура показатьКурсор;
  tKlausSysProc_ShowCursor = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура цветФона(вх цвет: целое);
  tKlausSysProc_BackColor = class(tKlausSysTermProc)
    private
      fColor: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура цветШрифта(вх цвет: целое);
  tKlausSysProc_FontColor = class(tKlausSysTermProc)
    private
      fColor: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура стильШрифта(вх стиль: целое);
  tKlausSysProc_FontStyle = class(tKlausSysTermProc)
    private
      fStyle: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // процедура сброситьАтрибуты;
  tKlausSysProc_ResetTextAttr = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция цвет256(вх кр, зел, син: целое): целое;
  tKlausSysProc_Color256 = class(tKlausSysProcDecl)
    private
      fRed: tKlausProcParam;
      fGreen: tKlausProcParam;
      fBlue: tKlausProcParam;
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция естьВвод: логическое;
  tKlausSysProc_InputAvailable = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // функция прочестьСимвол: символ;
  tKlausSysProc_ReadChar = class(tKlausSysTermProc)
    private
    public
      constructor create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

implementation

uses
  Math, LCLIntf, Graphics, GraphType, GraphUtils, KlausUtils;

const
  klausTermProcStream: tHandle = 1;

{ tKlausSysProc_TerminalMode }

constructor tKlausSysProc_TerminalMode.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_TerminalMode, aPoint);
  fHandle := tKlausProcParam.create(self, 'поток', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fHandle);
  fRaw := tKlausProcParam.create(self, 'сквозной', aPoint, kpmInput, source.simpleTypes[kdtBoolean]);
  addParam(fRaw);
end;

procedure tKlausSysProc_TerminalMode.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  klausTermProcStream := getSimpleInt(frame, fHandle, at);
  frame.owner.setRawInputMode(getSimpleBool(frame, fRaw, at));
end;

{ tKlausSysTermProc }

procedure tKlausSysTermProc.writeStdStream(frame: tKlausStackFrame; const s: string);
begin
  if klausTermProcStream = klausConst_StdErr then frame.owner.writeStdErr(s)
  else frame.owner.writeStdOut(s);
end;

{ tKlausSysProc_SetScreenSize }

constructor tKlausSysProc_SetScreenSize.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_SetScreenSize, aPoint);
  fHorz := tKlausProcParam.create(self, 'горз', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fHorz);
  fVert := tKlausProcParam.create(self, 'верт', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fVert);
end;

procedure tKlausSysProc_SetScreenSize.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  cx, cy: tKlausInteger;
begin
  cy := getSimpleInt(frame, fVert, at);
  cx := getSimpleInt(frame, fHorz, at);
  writeStdStream(frame, format(#27'[8;%d;%dt', [word(cy), word(cx)]));
end;

{ tKlausSysProc_ClearScreen }

constructor tKlausSysProc_ClearScreen.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_ClearScreen, aPoint);
end;

procedure tKlausSysProc_ClearScreen.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  writeStdStream(frame, #27'[2J');
end;

{ tKlausSysProc_ClearLine }

constructor tKlausSysProc_ClearLine.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_ClearLine, aPoint);
  fWhere := tKlausProcParam.create(self, 'где', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fWhere);
end;

procedure tKlausSysProc_ClearLine.run(frame: tKlausStackFrame; const at: tSrcPoint);
const
  pv: array[-1..+1] of byte = (1, 2, 0);
var
  idx: integer;
begin
  idx := klausCmp(getSimpleInt(frame, fWhere, at), 0);
  writeStdStream(frame, format(#27'[%dK', [pv[idx]]));
end;

{ tKlausSysProc_SetCursorPos }

constructor tKlausSysProc_SetCursorPos.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_SetCursorPos, aPoint);
  fHorz := tKlausProcParam.create(self, 'горз', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fHorz);
  fVert := tKlausProcParam.create(self, 'верт', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fVert);
end;

procedure tKlausSysProc_SetCursorPos.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  x, y: tKlausInteger;
begin
  x := getSimpleInt(frame, fHorz, at)+1;
  y := getSimpleInt(frame, fVert, at)+1;
  writeStdStream(frame, format(#27'[%d;%df', [word(y), word(x)]));
end;

{ tKlausSysProc_SetCursorPosVert }

constructor tKlausSysProc_SetCursorPosVert.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_SetCursorPosVert, aPoint);
  fVert := tKlausProcParam.create(self, 'верт', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fVert);
end;

procedure tKlausSysProc_SetCursorPosVert.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  y: tKlausInteger;
begin
  y := getSimpleInt(frame, fVert, at)+1;
  writeStdStream(frame, format(#27'[%dd', [word(y)]));
end;

{ tKlausSysProc_SetCursorPosHorz }

constructor tKlausSysProc_SetCursorPosHorz.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_SetCursorPosHorz, aPoint);
  fHorz := tKlausProcParam.create(self, 'горз', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fHorz);
end;

procedure tKlausSysProc_SetCursorPosHorz.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  x: tKlausInteger;
begin
  x := getSimpleInt(frame, fHorz, at)+1;
  writeStdStream(frame, format(#27'[%d`', [word(x)]));
end;

{ tKlausSysProc_CursorMove }

constructor tKlausSysProc_CursorMove.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_CursorMove, aPoint);
  fHorz := tKlausProcParam.create(self, 'горз', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fHorz);
  fVert := tKlausProcParam.create(self, 'верт', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fVert);
end;

procedure tKlausSysProc_CursorMove.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  vs, hs: string;
  x, y: tKlausInteger;
begin
  x := getSimpleInt(frame, fHorz, at);
  y := getSimpleInt(frame, fVert, at);
  if y < 0 then vs := format(#27'[%dA', [-y])
  else if y > 0 then vs := format(#27'[%dB', [y])
  else vs := '';
  if x < 0 then hs := format(#27'[%dD', [-x])
  else if x > 0 then hs := format(#27'[%dC', [x])
  else hs := '';
  if hs <> '' then writeStdStream(frame, hs);
  if vs <> '' then writeStdStream(frame, vs);
end;

{ tKlausSysProc_CursorSave }

constructor tKlausSysProc_CursorSave.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_CursorSave, aPoint);
end;

procedure tKlausSysProc_CursorSave.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  writeStdStream(frame, #27'[s');
end;

{ tKlausSysProc_CursorRestore }

constructor tKlausSysProc_CursorRestore.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_CursorRestore, aPoint);
end;

procedure tKlausSysProc_CursorRestore.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  writeStdStream(frame, #27'[u');
end;

{ tKlausSysProc_HideCursor }

constructor tKlausSysProc_HideCursor.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_HideCursor, aPoint);
end;

procedure tKlausSysProc_HideCursor.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  writeStdStream(frame, #27'[?25l');
end;

{ tKlausSysProc_ShowCursor }

constructor tKlausSysProc_ShowCursor.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_ShowCursor, aPoint);
end;

procedure tKlausSysProc_ShowCursor.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  writeStdStream(frame, #27'[?25h');
end;

{ tKlausSysProc_BackColor }

constructor tKlausSysProc_BackColor.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_BackColor, aPoint);
  fColor := tKlausProcParam.create(self, 'цвет', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fColor);
end;

procedure tKlausSysProc_BackColor.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  c: tKlausInteger;
begin
  c := getSimpleInt(frame, fColor, at);
  writeStdStream(frame, format(#27'[48;5;%dm', [byte(c)]));
end;

{ tKlausSysProc_FontColor }

constructor tKlausSysProc_FontColor.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FontColor, aPoint);
  fColor := tKlausProcParam.create(self, 'цвет', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fColor);
end;

procedure tKlausSysProc_FontColor.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  c: tKlausInteger;
begin
  c := getSimpleInt(frame, fColor, at);
  writeStdStream(frame, format(#27'[38;5;%dm', [byte(c)]));
end;

{ tKlausSysProc_FontStyle }

constructor tKlausSysProc_FontStyle.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_FontStyle, aPoint);
  fStyle := tKlausProcParam.create(self, 'стиль', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fStyle);
end;

procedure tKlausSysProc_FontStyle.run(frame: tKlausStackFrame; const at: tSrcPoint);
const
  bit: array[tFontStyle] of byte = (
    klausConst_FontBold,
    klausConst_FontItalic,
    klausConst_FontUnderline,
    klausConst_FontStrikeOut);
  attr: array[tFontStyle] of array[boolean] of integer = (
    (22, 1), //fsBold
    (23, 3), //fsItalic
    (24, 4), //fsUnderline
    (29, 9)  //fsStrikeOut
  );
var
  n: word;
  s: string;
  fs: tFontStyle;
  style: tKlausInteger;
begin
  s := '';
  style := getSimpleInt(frame, fStyle, at);
  for fs := low(fs) to high(fs) do begin
    n := attr[fs][style and bit[fs] > 0];
    s += format(#27'[%dm', [n]);
  end;
  writeStdStream(frame, s);
end;

{ tKlausSysProc_ResetTextAttr }

constructor tKlausSysProc_ResetTextAttr.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_ResetTextAttr, aPoint);
end;

procedure tKlausSysProc_ResetTextAttr.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  writeStdStream(frame, #27'[0m');
end;

{ tKlausSysProc_Color256 }

constructor tKlausSysProc_Color256.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_Color256, aPoint);
  fRed := tKlausProcParam.create(self, 'кр', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fRed);
  fGreen := tKlausProcParam.create(self, 'зел', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fGreen);
  fBlue := tKlausProcParam.create(self, 'син', aPoint, kpmInput, source.simpleTypes[kdtInteger]);
  addParam(fBlue);
  declareRetValue(kdtInteger);
end;

procedure tKlausSysProc_Color256.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  r, g, b: byte;
begin
  r := getSimpleInt(frame, fRed, at);
  g := getSimpleInt(frame, fGreen, at);
  b := getSimpleInt(frame, fBlue, at);
  returnSimple(frame, klausSimple(tKlausInteger(rgbTo256(r, g, b))));
end;

{ tKlausSysProc_InputAvailable }

constructor tKlausSysProc_InputAvailable.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_InputAvailable, aPoint);
  declareRetValue(kdtBoolean);
end;

procedure tKlausSysProc_InputAvailable.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  returnSimple(frame, klausSimple(frame.owner.inputAvailable));
end;

{ tKlausSysProc_ReadChar }

constructor tKlausSysProc_ReadChar.create(aOwner: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(aOwner, klausProcName_ReadChar, aPoint);
  declareRetValue(kdtChar);
end;

procedure tKlausSysProc_ReadChar.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  c: u8Char;
  rslt: tKlausChar;
begin
  frame.owner.readStdIn(c);
  if (c = '') or (c[1] = #0) then rslt := 0
  else rslt := u8ToUni(c);
  returnSimple(frame, klausSimple(rslt));
end;

end.

