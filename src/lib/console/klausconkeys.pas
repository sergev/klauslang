unit KlausConKeys;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LCLType, Keyboard;

const
  klausConSpecialKeys = [
    VK_PRIOR, VK_NEXT, VK_END, VK_HOME, VK_UP, VK_DOWN, VK_RIGHT, VK_LEFT, VK_NUMPAD5,
    VK_INSERT, VK_DELETE, VK_F1, VK_F2, VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8,
    VK_F9, VK_F10, VK_F11, VK_F12, VK_BACK, VK_RETURN, VK_ESCAPE, VK_SPACE, VK_TAB];

// Выдаёт последовательность, соответствующую переданной комбинации
// клавиш, *примерно* так же, как это делает Gnome Terminal
function klausConKeyToSequence(key: word; shift: tShiftState): string;

// Возвращает true, если переданная комбинация клавиш создаёт печатный символ
function klausConIsCharKey(key: word; shift: tShiftState): boolean;

implementation

function klausConKeyToSequence(key: word; shift: tShiftState): string;

  function shst(c: string = ''; c0: string = ''): string;
  begin
    if shift = [ssShift] then result := c+';2'
    else if shift = [ssAlt] then result := c+';3'
    else if shift = [ssShift, ssAlt] then result := c+';4'
    else if shift = [ssCtrl] then result := c+';5'
    else if shift = [ssShift, ssCtrl] then result := c+';6'
    else if shift = [ssAlt, ssCtrl] then result := c+';7'
    else if shift = [ssShift, ssAlt, ssCtrl] then result := c+';8'
    else result := c0+'';
  end;

  function chrseq(c, shc: string; ctl: string = ''): string;
  begin
    if (ssCtrl in shift) and (ctl <> '') then result := ctl
    else if ssShift in shift then result := shc
    else result := c;
    if ssAlt in shift then result := #27+result;
  end;

const
  dgtShiftChar: array[VK_0..VK_9] of char = (')', '!', '@', '#', '$', '%', '^', '&',  '*', '(');
  dgtCtrlChar:  array[VK_0..VK_9] of char = ('0', '1', #00, #27, #28, #29, #30, #31, #127, '9');
begin
  result := '';
  shift := shift * [ssShift, ssAlt, ssCtrl];
  if (key >= VK_0) and (key <= VK_9) then begin
    if ssShift in shift then result := dgtShiftChar[key]
    else if ssCtrl in shift then result := dgtCtrlChar[key]
    else result := char(key-48);
    if ssAlt in shift then result := #27+result;
  end else if (key >= VK_A) and (key <= VK_Z) then begin
    if ssCtrl in shift then result := char(key-64)
    else if ssShift in shift then result := char(key)
    else result := char(key+32);
    if ssAlt in shift then result := #27+result;
  end else case key of
    VK_PRIOR:             result := #27'[5'+shst+'~';
    VK_NEXT:              result := #27'[6'+shst+'~';
    VK_END:               result := #27'['+shst('1')+'F';
    VK_HOME:              result := #27'['+shst('1')+'H';
    VK_UP:                result := #27'['+shst('1')+'A';
    VK_DOWN:              result := #27'['+shst('1')+'B';
    VK_RIGHT:             result := #27'['+shst('1')+'C';
    VK_LEFT:              result := #27'['+shst('1')+'D';
    VK_NUMPAD5:           result := #27'['+shst('1')+'E';
    VK_INSERT:            result := #27'[2'+shst+'~';
    VK_DELETE:            result := #27'[3'+shst+'~';
    VK_F1:                result := #27'['+shst('1', 'O')+'P';
    VK_F2:                result := #27'['+shst('1', 'O')+'Q';
    VK_F3:                result := #27'['+shst('1', 'O')+'R';
    VK_F4:                result := #27'['+shst('1', 'O')+'S';
    VK_F5:                result := #27'[15'+shst+'~';
    VK_F6:                result := #27'[17'+shst+'~';
    VK_F7:                result := #27'[18'+shst+'~';
    VK_F8:                result := #27'[19'+shst+'~';
    VK_F9:                result := #27'[20'+shst+'~';
    VK_F10:               result := #27'[21'+shst+'~';
    VK_F11:               result := #27'[23'+shst+'~';
    VK_F12:               result := #27'[24'+shst+'~';
    VK_BACK:              result := chrseq(#8, #8);
    VK_RETURN:            result := chrseq(#13, #13);
    VK_ESCAPE:            result := chrseq(#27, #27);
    VK_SPACE:             result := chrseq(#32, #32);
    VK_TAB:               result := chrseq(#9, #27'[Z');
    VK_LCL_EQUAL:         result := chrseq('=', '+');
    VK_LCL_COMMA:         result := chrseq(',', '<');
    VK_LCL_POINT:         result := chrseq('.', '>');
    VK_LCL_SLASH:         result := chrseq('/', '?', #31);
    VK_LCL_SEMI_COMMA:    result := chrseq(';', ':');
    VK_LCL_MINUS:         result := chrseq('-', '_');
    VK_LCL_OPEN_BRACKET:  result := chrseq('[', '{', #27);
    VK_LCL_CLOSE_BRACKET: result := chrseq(']', '}', #29);
    VK_LCL_BACKSLASH:     result := chrseq('\', '|', #28);
    VK_LCL_TILDE:         result := chrseq('`', '~', #0);
    VK_LCL_QUOTE:         result := chrseq('''', '"');
  end;
end;

function klausConIsCharKey(key: word; shift: tShiftState): boolean;
begin
  if (ssAlt in shift) or (ssCtrl in shift) then exit(false);
  result := not (key in klausConSpecialKeys);
end;

initialization
end.

