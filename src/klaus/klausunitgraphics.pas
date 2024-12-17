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

unit KlausUnitGraphics;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, KlausLex, KlausDef, KlausSyn, KlausErr, KlausSrc, KlausUtils, KlausUnitSystem;

const
  klausUnitName_Graphics = 'Графика';

const
  klausProcName_GrWindowOpen = 'грОкно';
  klausProcName_GrDestroy = 'грУничтожить';
  klausProcName_GrSize = 'грРазмер';
  klausProcName_GrBeginPaint = 'грНачать';
  klausProcName_GrEndPaint = 'грЗакончить';
  klausProcName_GrPen = 'грПеро';
  klausProcName_GrBrush = 'грКисть';
  klausProcName_GrFont = 'грШрифт';
  klausProcName_GrClipRect = 'грОбрезка';
  klausProcName_GrPoint = 'грТочка';
  klausProcName_GrCircle = 'грКруг';
  klausProcName_GrEllipse = 'грЭллипс';
  klausProcName_GrArc = 'грДуга';
  klausProcName_GrSector = 'грСектор';
  klausProcName_GrChord = 'грСегмент';
  klausProcName_GrLine = 'грОтрезок';
  klausProcName_GrPolyLine = 'грЛоманая';
  klausProcName_GrRectangle = 'грПрямоугольник';
  klausProcName_GrPolygon = 'грМногоугольник';
  klausProcName_GrTextSize = 'грРазмерТекста';
  klausProcName_GrText = 'грТекст';
  klausProcName_GrImgLoad = 'грИзоЗагрузить';
  klausProcName_GrImgCreate = 'грИзоСоздать';
  klausProcName_GrImgSave = 'грИзоСохранить';
  klausProcName_GrImgDraw = 'грИзоВывести';

const
  klausConstName_GrPenStyleClear = 'грспПусто';
  klausConstName_GrPenStyleSolid = 'грспЛиния';
  klausConstName_GrPenStyleDot = 'грспТочка';
  klausConstName_GrPenStyleDash = 'грспТире';
  klausConstName_GrPenStyleDashDot = 'грспТочкаТире';
  klausConstName_GrPenStyleDashDotDot = 'грсп2ТочкиТире';
  klausConstName_GrBrushStyleClear = 'грскПусто';
  klausConstName_GrBrushStyleSolid = 'грскЦвет';
  klausConstName_GrFontBold = 'грсшЖирный';
  klausConstName_GrFontItalic = 'грсшКурсив';
  klausConstName_GrFontUnderline = 'грсшПодчерк';
  klausConstName_GrFontStrikeOut = 'грсшЗачерк';

const
  klausTypeName_Point = 'Точка';
  klausTypeName_Point2 = 'Точки';
  klausTypeName_Point3 = 'Точек';
  klausTypeName_Size = 'Размер';
  klausTypeName_Size2 = 'Размеры';
  klausTypeName_Size3 = 'Размеров';
  klausTypeName_PointArray = 'МассивТочек';
  klausTypeName_PointArray2 = 'МассивыТочек';
  klausTypeName_PointArray3 = 'МассивовТочек';

type
  // Встроенный модуль, содержащий библиотеку графического вывода.
  tKlausUnitGraphics = class(tKlausStdUnit)
    private
      procedure createTypes;
      procedure createVariables;
      procedure createRoutines;
    public
      constructor create(aSource: tKlausSource); override;
      class function stdUnitName: string; override;
  end;

implementation

uses
  KlausUnitGraphics_Proc;

resourcestring
  strKlausCanvasLink = 'Холст';

{ tKlausUnitGraphics }

constructor tKlausUnitGraphics.create(aSource: tKlausSource);
begin
  inherited create(aSource);
  createTypes;
  createVariables;
  createRoutines;
end;

procedure tKlausUnitGraphics.createTypes;
var
  str: tKlausTypeDefStruct;
  arr: tKlausTypeDefArray;
begin
  // Точка/Точки/Точек
  str := tKlausTypeDefStruct.create(source, zeroSrcPt);
  tKlausStructMember.create(str, 'г', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'в', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausTypeDecl.create(self, [klausTypeName_Point, klausTypeName_Point2, klausTypeName_Point3], zeroSrcPt, str);
  // Размер/Размеры/Размеров
  tKlausTypeDecl.create(self, [klausTypeName_Size, klausTypeName_Size2, klausTypeName_Size3], zeroSrcPt, str);
  // МассивТочек/МассивыТочек/МассивовТочек
  arr := tKlausTypeDefArray.create(source, zeroSrcPt, 1, str);
  tKlausTypeDecl.create(self, [klausTypeName_PointArray, klausTypeName_PointArray2, klausTypeName_PointArray3], zeroSrcPt, arr);
end;

procedure tKlausUnitGraphics.createVariables;
begin
  tKlausConstDecl.create(self, [klausConstName_GrPenStyleClear], zeroSrcPt, klausSimpleI(klausConst_psClear));
  tKlausConstDecl.create(self, [klausConstName_GrPenStyleSolid], zeroSrcPt, klausSimpleI(klausConst_psSolid));
  tKlausConstDecl.create(self, [klausConstName_GrPenStyleDot], zeroSrcPt, klausSimpleI(klausConst_psDot));
  tKlausConstDecl.create(self, [klausConstName_GrPenStyleDash], zeroSrcPt, klausSimpleI(klausConst_psDash));
  tKlausConstDecl.create(self, [klausConstName_GrPenStyleDashDot], zeroSrcPt, klausSimpleI(klausConst_psDashDot));
  tKlausConstDecl.create(self, [klausConstName_GrPenStyleDashDotDot], zeroSrcPt, klausSimpleI(klausConst_psDashDotDot));
  tKlausConstDecl.create(self, [klausConstName_GrBrushStyleClear], zeroSrcPt, klausSimpleI(klausConst_bsClear));
  tKlausConstDecl.create(self, [klausConstName_GrBrushStyleSolid], zeroSrcPt, klausSimpleI(klausConst_bsSolid));
  tKlausConstDecl.create(self, [klausConstName_GrFontBold], zeroSrcPt, klausSimpleI(klausConst_FontBold));
  tKlausConstDecl.create(self, [klausConstName_GrFontItalic], zeroSrcPt, klausSimpleI(klausConst_FontItalic));
  tKlausConstDecl.create(self, [klausConstName_GrFontUnderline], zeroSrcPt, klausSimpleI(klausConst_FontUnderline));
  tKlausConstDecl.create(self, [klausConstName_GrFontStrikeOut], zeroSrcPt, klausSimpleI(klausConst_FontStrikeOut));
end;

procedure tKlausUnitGraphics.createRoutines;
begin
  tKlausSysProc_GrWindowOpen.create(self, zeroSrcPt);
  tKlausSysProc_GrDestroy.create(self, zeroSrcPt);
  tKlausSysProc_GrSize.create(self, zeroSrcPt);
  tKlausSysProc_GrBeginPaint.create(self, zeroSrcPt);
  tKlausSysProc_GrEndPaint.create(self, zeroSrcPt);
  tKlausSysProc_GrPen.create(self, zeroSrcPt);
  tKlausSysProc_GrBrush.create(self, zeroSrcPt);
  tKlausSysProc_GrFont.create(self, zeroSrcPt);
  tKlausSysProc_GrCircle.create(self, zeroSrcPt);
  tKlausSysProc_GrEllipse.create(self, zeroSrcPt);
  tKlausSysProc_GrArc.create(self, zeroSrcPt);
  tKlausSysProc_GrSector.create(self, zeroSrcPt);
  tKlausSysProc_GrChord.create(self, zeroSrcPt);
  tKlausSysProc_GrLine.create(self, zeroSrcPt);
  tKlausSysProc_GrPolyLine.create(self, zeroSrcPt);
  tKlausSysProc_GrRectangle.create(self, zeroSrcPt);
  tKlausSysProc_GrPolygon.create(self, zeroSrcPt);
  tKlausSysProc_GrPoint.create(self, zeroSrcPt);
  tKlausSysProc_GrTextSize.create(self, zeroSrcPt);
  tKlausSysProc_GrText.create(self, zeroSrcPt);
  tKlausSysProc_GrClipRect.create(self, zeroSrcPt);
  tKlausSysProc_GrImgLoad.create(self, zeroSrcPt);
  tKlausSysProc_GrImgCreate.create(self, zeroSrcPt);
  tKlausSysProc_GrImgSave.create(self, zeroSrcPt);
  tKlausSysProc_GrImgDraw.create(self, zeroSrcPt);
end;

class function tKlausUnitGraphics.stdUnitName: string;
begin
  result := klausUnitName_Graphics;
end;

initialization
  klausRegisterStdUnit(tKlausUnitGraphics);
  tKlausObjects.registerKlausObject(tKlausCanvasLink, strKlausCanvasLink);
end.

