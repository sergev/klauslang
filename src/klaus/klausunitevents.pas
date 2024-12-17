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

unit KlausUnitEvents;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, KlausLex, KlausDef, KlausSyn, KlausErr, KlausSrc, KlausUtils, KlausUnitSystem;

const
  klausUnitName_Events = 'События';

const
  klausProcName_EvtSubscribe = 'сбтЗаказать';
  klausProcName_EvtExists = 'сбтЕсть';
  klausProcName_EvtGet = 'сбтЗабрать';
  klausProcName_EvtCount = 'сбтСколько';
  klausProcName_EvtPeek = 'сбтСмотреть';

const
  klausConstName_EvtKeyDown = 'сбтКлНаж';
  klausConstName_EvtKeyUp = 'сбтКлОтп';
  klausConstName_EvtKeyChar = 'сбтКлСмв';
  klausConstName_EvtMouseDown = 'сбтМшНаж';
  klausConstName_EvtMouseUp = 'сбтМшОтп';
  klausConstName_EvtMouseWheel = 'сбтМшКлс';
  klausConstName_EvtEnter = 'сбтМшВх';
  klausConstName_EvtLeave = 'сбтМшВых';
  klausConstName_EvtMove = 'сбтМшДвг';
  klausConstName_KeyStateShift = 'сскШифт';
  klausConstName_KeyStateCtrl = 'сскКтрл';
  klausConstName_KeyStateAlt = 'сскАльт';
  klausConstName_KeyStateLeft = 'сскЛКМ';
  klausConstName_KeyStateRight = 'сскПКМ';
  klausConstName_KeyStateMiddle = 'сскСКМ';
  klausConstName_KeyStateDouble = 'сскДвКлик';

const
  klausTypeName_Event = 'Событие';
  klausTypeName_Event3 = 'Событий';

type
  // Встроенный модуль, содержащий библиотеку обработки событий в окнах GUI.
  tKlausUnitEvents = class(tKlausStdUnit)
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
  KlausUnitEvents_Proc;

{ tKlausUnitEvents }

constructor tKlausUnitEvents.create(aSource: tKlausSource);
begin
  inherited create(aSource);
  createTypes;
  createVariables;
  createRoutines;
end;

procedure tKlausUnitEvents.createTypes;
var
  str: tKlausTypeDefStruct;
begin
  // Событие/Событий
  str := tKlausTypeDefStruct.create(source, zeroSrcPt);
  tKlausStructMember.create(str, 'что', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'код', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'инфо', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'г', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'в', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausTypeDecl.create(self, [klausTypeName_Event, klausTypeName_Event3], zeroSrcPt, str);
end;

procedure tKlausUnitEvents.createVariables;
begin
  tKlausConstDecl.create(self, [klausConstName_EvtKeyDown], zeroSrcPt, klausSimpleI(klausConst_EvtKeyDown));
  tKlausConstDecl.create(self, [klausConstName_EvtKeyUp], zeroSrcPt, klausSimpleI(klausConst_EvtKeyUp));
  tKlausConstDecl.create(self, [klausConstName_EvtKeyChar], zeroSrcPt, klausSimpleI(klausConst_EvtKeyChar));
  tKlausConstDecl.create(self, [klausConstName_EvtMouseDown], zeroSrcPt, klausSimpleI(klausConst_EvtMouseDown));
  tKlausConstDecl.create(self, [klausConstName_EvtMouseUp], zeroSrcPt, klausSimpleI(klausConst_EvtMouseUp));
  tKlausConstDecl.create(self, [klausConstName_EvtMouseWheel], zeroSrcPt, klausSimpleI(klausConst_EvtMouseWheel));
  tKlausConstDecl.create(self, [klausConstName_EvtEnter], zeroSrcPt, klausSimpleI(klausConst_EvtMouseEnter));
  tKlausConstDecl.create(self, [klausConstName_EvtLeave], zeroSrcPt, klausSimpleI(klausConst_EvtMouseLeave));
  tKlausConstDecl.create(self, [klausConstName_EvtMove], zeroSrcPt, klausSimpleI(klausConst_EvtMouseMove));
  tKlausConstDecl.create(self, [klausConstName_KeyStateShift], zeroSrcPt, klausSimpleI(klausConst_KeyStateShift));
  tKlausConstDecl.create(self, [klausConstName_KeyStateCtrl], zeroSrcPt, klausSimpleI(klausConst_KeyStateCtrl));
  tKlausConstDecl.create(self, [klausConstName_KeyStateAlt], zeroSrcPt, klausSimpleI(klausConst_KeyStateAlt));
  tKlausConstDecl.create(self, [klausConstName_KeyStateLeft], zeroSrcPt, klausSimpleI(klausConst_KeyStateLeft));
  tKlausConstDecl.create(self, [klausConstName_KeyStateRight], zeroSrcPt, klausSimpleI(klausConst_KeyStateRight));
  tKlausConstDecl.create(self, [klausConstName_KeyStateMiddle], zeroSrcPt, klausSimpleI(klausConst_KeyStateMiddle));
  tKlausConstDecl.create(self, [klausConstName_KeyStateDouble], zeroSrcPt, klausSimpleI(klausConst_KeyStateDouble));
end;

procedure tKlausUnitEvents.createRoutines;
begin
  tKlausSysProc_EvtSubscribe.create(self, zeroSrcPt);
  tKlausSysProc_EvtExists.create(self, zeroSrcPt);
  tKlausSysProc_EvtGet.create(self, zeroSrcPt);
  tKlausSysProc_EvtCount.create(self, zeroSrcPt);
  tKlausSysProc_EvtPeek.create(self, zeroSrcPt);
end;

class function tKlausUnitEvents.stdUnitName: string;
begin
  result := klausUnitName_Events;
end;

initialization
  klausRegisterStdUnit(tKlausUnitEvents);
end.

