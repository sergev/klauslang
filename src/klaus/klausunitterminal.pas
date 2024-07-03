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

unit KlausUnitTerminal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, KlausLex, KlausDef, KlausSyn, KlausErr, KlausSrc, KlausUnitSystem;

const
  klausUnitName_Terminal = 'Терминал';

const
  klausProcName_TerminalMode = 'режимТерминала';
  klausProcName_SetScreenSize = 'размерЭкрана';
  klausProcName_ClearScreen = 'очиститьЭкран';
  klausProcName_ClearLine = 'очиститьСтроку';
  klausProcName_SetCursorPos = 'курсор';
  klausProcName_SetCursorPosVert = 'курсорВерт';
  klausProcName_SetCursorPosHorz = 'курсорГорз';
  klausProcName_CursorMove = 'подвинутьКурсор';
  klausProcName_CursorSave = 'запомнитьКурсор';
  klausProcName_CursorRestore = 'вернутьКурсор';
  klausProcName_HideCursor = 'скрытьКурсор';
  klausProcName_ShowCursor = 'показатьКурсор';
  klausProcName_BackColor = 'цветФона';
  klausProcName_FontColor = 'цветШрифта';
  klausProcName_FontStyle = 'стильШрифта';
  klausProcName_Color256 = 'цвет256';
  klausProcName_ResetTextAttr = 'сброситьАтрибуты';
  klausProcName_InputAvailable = 'естьСимвол';
  klausProcName_ReadChar = 'прочестьСимвол';

const
  klausConstName_StdOut = 'идСтдВывод';
  klausConstName_StdErr = 'идСтдСообщ';
  klausConstName_TermCanon = 'трКанон';
  klausConstName_TermDirect = 'трСквозной';
  klausConstName_FontBold = 'стшЖирный';
  klausConstName_FontItalic = 'стшКурсив';
  klausConstName_FontUnderline = 'стшПодчерк';
  klausConstName_FontStrikeOut = 'стшЗачерк';

type
  // Встроенный модуль, содержащий библиотеку управления терминалом.
  tKlausUnitTerminal = class(tKlausUnit)
    private
      procedure createVariables;
      procedure createRoutines;
    protected
      function  getHidden: boolean; override;
    public
      constructor create(aSource: tKlausSource; aName: string; aPoint: tSrcPoint); override;
  end;

implementation

uses
  KlausUnitTerminal_Proc;

{ tKlausUnitTerminal }

constructor tKlausUnitTerminal.create(aSource: tKlausSource; aName: string; aPoint: tSrcPoint);
begin
  inherited create(aSource, klausUnitName_Terminal, aPoint);
  createVariables;
  createRoutines;
end;

procedure tKlausUnitTerminal.createVariables;
begin
  tKlausConstDecl.create(self, [klausConstName_StdOut], zeroSrcPt, klausSimple(tKlausInteger(klausConst_StdOut)));
  tKlausConstDecl.create(self, [klausConstName_StdErr], zeroSrcPt, klausSimple(tKlausInteger(klausConst_StdErr)));
  tKlausConstDecl.create(self, [klausConstName_TermCanon], zeroSrcPt, klausSimple(false));
  tKlausConstDecl.create(self, [klausConstName_TermDirect], zeroSrcPt, klausSimple(true));
  tKlausConstDecl.create(self, [klausConstName_FontBold], zeroSrcPt, klausSimple(tKlausInteger(klausConst_FontBold)));
  tKlausConstDecl.create(self, [klausConstName_FontItalic], zeroSrcPt, klausSimple(tKlausInteger(klausConst_FontItalic)));
  tKlausConstDecl.create(self, [klausConstName_FontUnderline], zeroSrcPt, klausSimple(tKlausInteger(klausConst_FontUnderline)));
  tKlausConstDecl.create(self, [klausConstName_FontStrikeOut], zeroSrcPt, klausSimple(tKlausInteger(klausConst_FontStrikeOut)));
end;

procedure tKlausUnitTerminal.createRoutines;
begin
  tKlausSysProc_TerminalMode.create(self, zeroSrcPt);
  tKlausSysProc_SetScreenSize.create(self, zeroSrcPt);
  tKlausSysProc_ClearScreen.create(self, zeroSrcPt);
  tKlausSysProc_ClearLine.create(self, zeroSrcPt);
  tKlausSysProc_SetCursorPos.create(self, zeroSrcPt);
  tKlausSysProc_SetCursorPosVert.create(self, zeroSrcPt);
  tKlausSysProc_SetCursorPosHorz.create(self, zeroSrcPt);
  tKlausSysProc_CursorMove.create(self, zeroSrcPt);
  tKlausSysProc_CursorSave.create(self, zeroSrcPt);
  tKlausSysProc_CursorRestore.create(self, zeroSrcPt);
  tKlausSysProc_ShowCursor.create(self, zeroSrcPt);
  tKlausSysProc_HideCursor.create(self, zeroSrcPt);
  tKlausSysProc_BackColor.create(self, zeroSrcPt);
  tKlausSysProc_FontColor.create(self, zeroSrcPt);
  tKlausSysProc_FontStyle.create(self, zeroSrcPt);
  tKlausSysProc_Color256.create(self, zeroSrcPt);
  tKlausSysProc_ResetTextAttr.create(self, zeroSrcPt);
  tKlausSysProc_InputAvailable.create(self, zeroSrcPt);
  tKlausSysProc_ReadChar.create(self, zeroSrcPt);
end;

function tKlausUnitTerminal.getHidden: boolean;
begin
  result := true;
end;

initialization
  klausRegisterStdUnit(klausUnitName_Terminal, tKlausUnitTerminal);
end.

