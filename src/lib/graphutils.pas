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

unit GraphUtils;

{$mode ObjFPC}{$H+}
{$i klaus.inc}

interface

uses
  Classes, SysUtils, Graphics;

const
  cl16Black   = 00;
  cl16Maroon  = 01;
  cl16Green   = 02;
  cl16Olive   = 03;
  cl16Navy    = 04;
  cl16Purple  = 05;
  cl16Teal    = 06;
  cl16Silver  = 07;
  cl16Gray    = 08;
  cl16Red     = 09;
  cl16Lime    = 10;
  cl16Yellow  = 11;
  cl16Blue    = 12;
  cl16Fuchsia = 13;
  cl16Aqua    = 14;
  cl16White   = 15;

  colors256: array[0..255] of tColor = (
    $000000, $000080, $008000, $008080, $800000, $800080, $808000, $c0c0c0,
    $808080, $0000ff, $00ff00, $00ffff, $ff0000, $ff00ff, $ffff00, $ffffff,
    $000000, $5f0000, $870000, $af0000, $d70000, $ff0000, $005f00, $5f5f00,
    $875f00, $af5f00, $d75f00, $ff5f00, $008700, $5f8700, $878700, $0087af,
    $0087d7, $ff8700, $00af00, $5faf00, $87af00, $afaf00, $d7af00, $ffaf00,
    $00d700, $5fd700, $87d700, $afd700, $d7d700, $ffd700, $00ff00, $5fff00,
    $87ff00, $afff00, $d7ff00, $ffff00, $00005f, $5f005f, $87005f, $af005f,
    $d7005f, $ff005f, $005f5f, $5f5f5f, $875f5f, $af5f5f, $d75f5f, $ff5f5f,
    $00875f, $5f875f, $87875f, $af875f, $d7875f, $ff875f, $00af5f, $5faf5f,
    $87af5f, $afaf5f, $d7af5f, $ffaf5f, $00d75f, $5fd75f, $87d75f, $afd75f,
    $d7d75f, $ffd75f, $00ff5f, $5fff5f, $87ff5f, $afff5f, $d7ff5f, $ffff5f,
    $000087, $5f0087, $870087, $af0087, $d70087, $ff0087, $005f87, $5f5f87,
    $875f87, $af5f87, $d75f87, $ff5f87, $008787, $5f8787, $878787, $af8787,
    $d78787, $ff8787, $00af87, $5faf87, $87af87, $afaf87, $d7af87, $ffaf87,
    $00d787, $5fd787, $87d787, $afd787, $d7d787, $ffd787, $00ff87, $5fff87,
    $87ff87, $afff87, $d7ff87, $ffff87, $0000af, $5f00af, $8700af, $af00af,
    $d700af, $ff00af, $005faf, $5f5faf, $875faf, $af5faf, $d75faf, $ff5faf,
    $0087af, $5f87af, $8787af, $af87af, $d787af, $ff87af, $00afaf, $5fafaf,
    $87afaf, $afafaf, $d7afaf, $ffafaf, $00d7af, $5fd7af, $87d7af, $afd7af,
    $d7d7af, $ffd7af, $00ffaf, $5fffaf, $87ffaf, $afffaf, $d7ffaf, $ffffaf,
    $0000d7, $5f00d7, $8700d7, $af00d7, $d700d7, $ff00d7, $005fd7, $5f5fd7,
    $875fd7, $af5fd7, $d75fd7, $ff5fd7, $0087d7, $5f87d7, $8787d7, $af87d7,
    $d787d7, $ff87d7, $00afd7, $5fafd7, $87afd7, $afafd7, $d7afd7, $ffafd7,
    $00d7d7, $5fd7d7, $87d7d7, $afd7d7, $d7d7d7, $ffd7d7, $00ffd7, $5fffd7,
    $87ffd7, $afffd7, $d7ffd7, $ffffd7, $0000ff, $5f00ff, $8700ff, $af00ff,
    $d700ff, $ff00ff, $005fff, $5f5fff, $875fff, $af5fff, $d75fff, $ff5fff,
    $0087ff, $5f87ff, $8787ff, $af87ff, $d787ff, $ff87ff, $00afff, $5fafff,
    $87afff, $afafff, $d7afff, $ffafff, $00d7ff, $5fd7ff, $87d7ff, $afd7ff,
    $d7d7ff, $ffd7ff, $00ffff, $5fffff, $87ffff, $afffff, $d7ffff, $ffffff,
    $080808, $121212, $1c1c1c, $262626, $303030, $3a3a3a, $444444, $4e4e4e,
    $585858, $626262, $6c6c6c, $767676, $808080, $8a8a8a, $949494, $9e9e9e,
    $a8a8a8, $b2b2b2, $bcbcbc, $c6c6c6, $d0d0d0, $dadada, $e4e4e4, $eeeeee);

type
  tUITheme = (thLight, thDark);

const
  uiThemeName: array[tUITheme] of string = ('light', 'dark');

type
  tHSL = record
    hue: double;
    sat: double;
    lum: double;
  end;

function colorToHSL(const color: tColor): tHSL;
function hslToColor(const hsl: tHSL): tColor;
function lighter(c: tColor; delta: double): tColor;
function darker(c: tColor; delta: double): tColor;
function lighterOrDarker(c: tColor; delta: double): tColor;
function rgbTo256(r, g, b: byte): byte;

function fontStyleToString(fs: tFontStyles): string;
function fontStyleToText(fs: tFontStyles): string;
function stringToFontStyle(const s: string): tFontStyles;

function getCurrentTheme: tUITheme;

function colorCaption(c: tColor): string;

implementation

uses
  Math, TypInfo, U8;

resourcestring
  strBold = 'жирный';
  strItalic = 'курсив';
  strUnderline = 'подчёркнутый';
  strStrikeOut = 'зачёркнутый';

  rsBlackColorCaption = 'Чёрный';
  rsMaroonColorCaption = 'Бордовый';
  rsGreenColorCaption = 'Зелёный';
  rsOliveColorCaption = 'Оливковый';
  rsNavyColorCaption = 'Тёмно-синий';
  rsPurpleColorCaption = 'Лиловый';
  rsTealColorCaption = 'Бирюзовый';
  rsGrayColorCaption = 'Тёмно-серый';
  rsSilverColorCaption = 'Светло-серый';
  rsRedColorCaption = 'Красный';
  rsLimeColorCaption = 'Светло-зелёный';
  rsYellowColorCaption = 'Жёлтый';
  rsBlueColorCaption = 'Синий';
  rsFuchsiaColorCaption = 'Фиолетовый';
  rsAquaColorCaption = 'Морской волны';
  rsWhiteColorCaption = 'Белый';
  rsMoneyGreenColorCaption = 'Бледно-зелёный';
  rsSkyBlueColorCaption = 'Бледно-голубой';
  rsCreamColorCaption = 'Кремовый';
  rsMedGrayColorCaption = 'Серый';
  rsNoneColorCaption = '(Нет)';
  rsDefaultColorCaption = '(По умолчанию)';
  rsScrollBarColorCaption = 'Полоса прокрутки';
  rsBackgroundColorCaption = 'Рабочий стол';
  rsActiveCaptionColorCaption = 'Заголовок активного окна';
  rsInactiveCaptionColorCaption = 'Заголовок неактивного окна';
  rsMenuColorCaption = 'Меню';
  rsWindowColorCaption = 'Окно';
  rsWindowFrameColorCaption = 'Рамка окна';
  rsMenuTextColorCaption = 'Текст меню';
  rsWindowTextColorCaption = 'Текст окна';
  rsCaptionTextColorCaption = 'Текст заголовка активного окна';
  rsActiveBorderColorCaption = 'Граница активного окна';
  rsInactiveBorderColorCaption = 'Граница неактивного окна';
  rsAppWorkspaceColorCaption = 'Рабочая область приложения';
  rsHighlightColorCaption = 'Выделение';
  rsHighlightTextColorCaption = 'Выделенный текст';
  rsBtnFaceColorCaption = 'Поверхность кнопки';
  rsBtnShadowColorCaption = 'Тёмная сторона кнопки';
  rsGrayTextColorCaption = 'Серый текст';
  rsBtnTextColorCaption = 'Текст кнопки';
  rsInactiveCaptionText = 'Текст заголовка неактивного окна';
  rsBtnHighlightColorCaption = 'Светлая сторона кнопки';
  rs3DDkShadowColorCaption = 'Тёмная сторона 3D';
  rs3DLightColorCaption = 'Светлая сторона 3D';
  rsInfoTextColorCaption = 'Текст подсказки';
  rsInfoBkColorCaption = 'Фон подсказки';
  rsHotLightColorCaption = 'Подсветка';
  rsGradientActiveCaptionColorCaption = 'Градиент активного заголовка';
  rsGradientInactiveCaptionColorCaption = 'Градиент неактивного заголовка';
  rsMenuHighlightColorCaption = 'Выбранный пункт меню';
  rsMenuBarColorCaption = 'Строка меню';
  rsFormColorCaption = 'Форма';

function colorToHSL(const color: tColor): tHSL;
var
  r, g, b: double;
  br, bg, bb: byte;
  delta, cMax, cMin: double;
begin
  redGreenBlue(colorToRGB(color), br, bg, bb);
  r := br / 255;
  g := bg / 255;
  b := bb / 255;
  cMax := max(r, max(g, b));
  cMin := min(r, min(g, b));
  with result do begin
    lum := (cMax+cMin) / 2;
    if sameValue(cMax, cMin) then begin
      hue := 0;
      sat := 0;
    end else begin
       if lum < 0.5 then sat := (cMax-cMin) / (cMax+cMin)
       else sat := (cMax-cMin) / (2-cMax-cMin);
       delta := cMax-cMin;
       if sameValue(r, cMax) then hue := (g-b) / delta
       else if sameValue(g, CMax) then hue := 2 + (b-r) / delta
       else hue := 4 + (r-g) / delta;
       hue := hue / 6;
       if hue < 0 then hue += 1;
    end;
  end;
end;

function hslToColor(const hsl: tHSL): tColor;

  function hueToRGB(m1, m2, h: double): double;
  begin
    if h < 0 then h += 1;
    if h > 1 then h += 1;
    if h*6 < 1 then result := m1 + (m2-m1)*h*6
    else if h*2 < 1 then result := m2
    else if h*3 < 2 then result := m1+(m2-m1)*((2/3)-h)*6
    else result := m1;
  end;

var
  r, g, b: double;
  m1, m2: double;
begin
  with hsl do begin
    if sat = 0 then begin
      r := lum;
      g := lum;
      b := lum;
    end else begin
      if lum <= 0.5 then m2 := lum * (sat+1)
      else m2 := lum + sat - lum*sat;
      m1 := lum*2 - m2;
      r := hueToRGB(m1, m2, hue + 1/3);
      g := hueToRGB(m1, m2, hue);
      b := hueToRGB(m1, m2, hue - 1/3);
    end;
    result := rgbToColor(round(r*255), round(g*255), round(b*255));
  end;
end;

function lighter(c: tColor; delta: double): tColor;
var
  hsl: tHSL;
begin
  hsl := colorToHSL(c);
  hsl.lum := max(0, min(1, hsl.lum+delta));
  result := hslToColor(hsl);
end;

function darker(c: tColor; delta: double): tColor;
begin
  result := lighter(c, -delta);
end;

function lighterOrDarker(c: tColor; delta: double): tColor;
var
  hsl: tHSL;
begin
  hsl := colorToHSL(c);
  if hsl.lum >= 0.5 then hsl.lum := max(0, min(1, hsl.lum-delta))
  else hsl.lum := max(0, min(1, hsl.lum+delta));
  result := hslToColor(hsl);
end;

function rgbTo256(r, g, b: byte): byte;
var
  i: integer;
  rgb: longWord;
begin
  rgb := (b shl 16) + (g shl 8) + r;
  for i := 0 to 15 do if rgb = colors256[i] then exit(i);
  if (r = g) and (g = b) then exit(round(r / 255 * 23) + 232);
  r := round(r / 255 * 5);
  g := round(g / 255 * 5);
  b := round(b / 255 * 5);
  result := 16 + 36*r + 6*g + b;
end;

function fontStyleToString(fs: tFontStyles): string;
var
  i: tFontStyle;
  sep: string = '';
begin
  result := '';
  for i := low(i) to high(i) do
    if i in fs then begin
      result += sep + getEnumName(typeInfo(tFontStyle), ord(i));
      sep := ', ';
    end;
end;

function fontStyleToText(fs: tFontStyles): string;
var
  fontStyleName: array[TFontStyle] of string = (strBold, strItalic, strUnderline, strStrikeOut);
  i: tFontStyle;
  sep: string = '';
begin
  result := '';
  for i := low(i) to high(i) do
    if i in fs then begin
      result += sep + fontStyleName[i];
      sep := ', ';
    end;
end;

function stringToFontStyle(const s: string): tFontStyles;
var
  n: string;
  i: tFontStyle;
  sl: tStringList;
begin
  sl := tStringList.create;
  try
    sl.sorted := true;
    sl.duplicates := dupIgnore;
    sl.commaText := u8Upper(s);
    result := [];
    for i := low(i) to high(i) do begin
      n := u8Upper(getEnumName(typeInfo(tFontStyle), ord(i)));
      if sl.indexOf(n) >= 0 then include(result, i);
    end;
  finally
    freeAndNil(sl);
  end;
end;

function getCurrentTheme: tUITheme;
var
  hslw, hslt: tHSL;
begin
  hslw := colorToHSL(clWindow);
  hslt := colorToHSL(clWindowText);
  if hslt.lum < hslw.lum then result := thLight else result := thDark;
end;

function colorCaption(c: tColor): string;
begin
  result := '';
  case c of
    clBlack                   : result := rsBlackColorCaption;
    clMaroon                  : result := rsMaroonColorCaption;
    clGreen                   : result := rsGreenColorCaption;
    clOlive                   : result := rsOliveColorCaption;
    clNavy                    : result := rsNavyColorCaption;
    clPurple                  : result := rsPurpleColorCaption;
    clTeal                    : result := rsTealColorCaption;
    clGray                    : result := rsGrayColorCaption;
    clSilver                  : result := rsSilverColorCaption;
    clRed                     : result := rsRedColorCaption;
    clLime                    : result := rsLimeColorCaption;
    clYellow                  : result := rsYellowColorCaption;
    clBlue                    : result := rsBlueColorCaption;
    clFuchsia                 : result := rsFuchsiaColorCaption;
    clAqua                    : result := rsAquaColorCaption;
    clWhite                   : result := rsWhiteColorCaption;
    clMoneyGreen              : result := rsMoneyGreenColorCaption;
    clSkyBlue                 : result := rsSkyBlueColorCaption;
    clCream                   : result := rsCreamColorCaption;
    clMedGray                 : result := rsMedGrayColorCaption;
    clNone                    : result := rsNoneColorCaption;
    clDefault                 : result := rsDefaultColorCaption;
    clScrollBar               : result := rsScrollBarColorCaption;
    clBackground              : result := rsBackgroundColorCaption;
    clActiveCaption           : result := rsActiveCaptionColorCaption;
    clInactiveCaption         : result := rsInactiveCaptionColorCaption;
    clMenu                    : result := rsMenuColorCaption;
    clWindow                  : result := rsWindowColorCaption;
    clWindowFrame             : result := rsWindowFrameColorCaption;
    clMenuText                : result := rsMenuTextColorCaption;
    clWindowText              : result := rsWindowTextColorCaption;
    clCaptionText             : result := rsCaptionTextColorCaption;
    clActiveBorder            : result := rsActiveBorderColorCaption;
    clInactiveBorder          : result := rsInactiveBorderColorCaption;
    clAppWorkspace            : result := rsAppWorkspaceColorCaption;
    clHighlight               : result := rsHighlightColorCaption;
    clHighlightText           : result := rsHighlightTextColorCaption;
    clBtnFace                 : result := rsBtnFaceColorCaption;
    clBtnShadow               : result := rsBtnShadowColorCaption;
    clGrayText                : result := rsGrayTextColorCaption;
    clBtnText                 : result := rsBtnTextColorCaption;
    clInactiveCaptionText     : result := rsInactiveCaptionText;
    clBtnHighlight            : result := rsBtnHighlightColorCaption;
    cl3DDkShadow              : result := rs3DDkShadowColorCaption;
    cl3DLight                 : result := rs3DLightColorCaption;
    clInfoText                : result := rsInfoTextColorCaption;
    clInfoBk                  : result := rsInfoBkColorCaption;
    clHotLight                : result := rsHotLightColorCaption;
    clGradientActiveCaption   : result := rsGradientActiveCaptionColorCaption;
    clGradientInactiveCaption : result := rsGradientInactiveCaptionColorCaption;
    clMenuHighlight           : result := rsMenuHighlightColorCaption;
    clMenuBar                 : result := rsMenuBarColorCaption;
    clForm                    : result := rsFormColorCaption;
  end;
end;

end.
