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

unit KlausUnitFiles;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, KlausLex, KlausDef, KlausSyn, KlausErr, KlausSrc, KlausUtils, KlausUnitSystem;

const
  klausUnitName_Files = 'Файлы';

const
  klausProcName_FileCreate = 'файлСоздать';
  klausProcName_FileOpen = 'файлОткрыть';
  klausProcName_FileClose = 'файлЗакрыть';
  klausProcName_FileSize = 'файлРазмер';
  klausProcName_FilePos = 'файлПоз';
  klausProcName_FileRead = 'файлПрочесть';
  klausProcName_FileWrite = 'файлЗаписать';
  klausProcName_FileExists = 'файлЕсть';
  klausProcName_FileDirExists = 'файлЕстьКат';
  klausProcName_FileTempDir = 'файлВрмКат';
  klausProcName_FileTempName = 'файлВрмИмя';
  klausProcName_FileExpandName = 'файлПолныйПуть';
  klausProcName_FileProgName = 'файлВыполняемый';
  klausProcName_FileExtractPath = 'файлПуть';
  klausProcName_FileExtractName = 'файлИмя';
  klausProcName_FileExtractExt = 'файлРасширение';
  klausProcName_FileHomeDir = 'файлДомКат';
  klausProcName_FileGetAttrs = 'файлАтрибуты';
  klausProcName_FileGetAge = 'файлВозраст';
  klausProcName_FileRename = 'файлПереместить';
  klausProcName_FileDelete = 'файлУдалить';
  klausProcName_FileFindFirst = 'файлПервый';
  klausProcName_FileFindNext = 'файлСледующий';
  klausProcName_FileMkDir = 'файлСоздКат';
  klausProcName_FileRmDir = 'файлУдалКат';
  klausProcName_FileCurDir = 'файлТекКат';

const
  klausConstName_FileTypeText = 'фтТекст';
  klausConstName_FileTypeBinary = 'фтДвоичный';
  klausConstName_FileOpenRead = 'фрдЧтение';
  klausConstName_FileOpenWrite = 'фрдЗапись';
  klausConstName_FileShareExclusive = 'фcдИсключить';
  klausConstName_FileShareDenyWrite = 'фcдЧтение';
  klausConstName_FileShareDenyNone = 'фcдЛюбой';
  klausConstName_FilePosFromBeginning = 'фпОтНачала';
  klausConstName_FilePosFromEnd = 'фпОтКонца';
  klausConstName_FilePosFromCurrent = 'фпОтносительно';
  klausConstName_FileAttrReadOnly = 'фаТолькоЧтение';
  klausConstName_FileAttrHidden = 'фаСкрытый';
  klausConstName_FileAttrSystem = 'фаСистемный';
  klausConstName_FileAttrVolumeID = 'фаМеткаТома';
  klausConstName_FileAttrDirectory = 'фаКаталог';
  klausConstName_FileAttrArchive = 'фаАрхивный';
  klausConstName_FileAttrNormal = 'фаНормальный';
  klausConstName_FileAttrTemporary = 'фаВременный';
  klausConstName_FileAttrSymLink = 'фаСимвСсылка';
  klausConstName_FileAttrCompressed = 'фаСжатый';
  klausConstName_FileAttrEncrypted = 'фаШифрованный';
  klausConstName_FileAttrVirtual = 'фаВиртуальный';

const
  klausTypeName_FileInfo = 'ФайлИнфо';

type
  // Встроенный модуль, содержащий библиотеку файлового ввода-вывода.
  tKlausUnitFiles = class(tKlausStdUnit)
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
  KlausUnitFiles_Proc;

resourcestring
  strKlausFileSearch = 'Поиск файлов';
  strKlausFileStream = 'Файл';

{ tKlausUnitFiles }

constructor tKlausUnitFiles.create(aSource: tKlausSource);
begin
  inherited create(aSource);
  createTypes;
  createVariables;
  createRoutines;
end;

procedure tKlausUnitFiles.createTypes;
var
  str: tKlausTypeDefStruct;
begin
  // ФайлИнфо
  str := tKlausTypeDefStruct.create(source, zeroSrcPt);
  tKlausStructMember.create(str, 'имя', zeroSrcPt, source.simpleTypes[kdtString]);
  tKlausStructMember.create(str, 'размер', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'атрибуты', zeroSrcPt, source.simpleTypes[kdtInteger]);
  tKlausStructMember.create(str, 'возраст', zeroSrcPt, source.simpleTypes[kdtMoment]);
  tKlausTypeDecl.create(self, [klausTypeName_FileInfo], zeroSrcPt, str);
end;

procedure tKlausUnitFiles.createVariables;
begin
  tKlausConstDecl.create(self, [klausConstName_FileTypeText], zeroSrcPt, klausSimpleI(klausFileTypeText));
  tKlausConstDecl.create(self, [klausConstName_FileTypeBinary], zeroSrcPt, klausSimpleI(klausFileTypeBinary));
  tKlausConstDecl.create(self, [klausConstName_FileOpenRead], zeroSrcPt, klausSimpleI(klausFileOpenRead));
  tKlausConstDecl.create(self, [klausConstName_FileOpenWrite], zeroSrcPt, klausSimpleI(klausFileOpenWrite));
  tKlausConstDecl.create(self, [klausConstName_FileShareExclusive], zeroSrcPt, klausSimpleI(klausFileShareExclusive));
  tKlausConstDecl.create(self, [klausConstName_FileShareDenyWrite], zeroSrcPt, klausSimpleI(klausFileShareDenyWrite));
  tKlausConstDecl.create(self, [klausConstName_FileShareDenyNone], zeroSrcPt, klausSimpleI(klausFileShareDenyNone));
  tKlausConstDecl.create(self, [klausConstName_FilePosFromBeginning], zeroSrcPt, klausSimpleI(klausFilePosFromBeginning));
  tKlausConstDecl.create(self, [klausConstName_FilePosFromEnd], zeroSrcPt, klausSimpleI(klausFilePosFromEnd));
  tKlausConstDecl.create(self, [klausConstName_FilePosFromCurrent], zeroSrcPt, klausSimpleI(klausFilePosFromCurrent));
  tKlausConstDecl.create(self, [klausConstName_FileAttrReadOnly], zeroSrcPt, klausSimpleI(faReadOnly));
  {$push}{$warnings off}
  tKlausConstDecl.create(self, [klausConstName_FileAttrHidden], zeroSrcPt, klausSimpleI(faHidden));
  tKlausConstDecl.create(self, [klausConstName_FileAttrSystem], zeroSrcPt, klausSimpleI(faSysFile));
  tKlausConstDecl.create(self, [klausConstName_FileAttrVolumeID], zeroSrcPt, klausSimpleI(faVolumeID));
  tKlausConstDecl.create(self, [klausConstName_FileAttrDirectory], zeroSrcPt, klausSimpleI(faDirectory));
  tKlausConstDecl.create(self, [klausConstName_FileAttrArchive], zeroSrcPt, klausSimpleI(faArchive));
  tKlausConstDecl.create(self, [klausConstName_FileAttrNormal], zeroSrcPt, klausSimpleI(faNormal));
  tKlausConstDecl.create(self, [klausConstName_FileAttrTemporary], zeroSrcPt, klausSimpleI(faTemporary));
  tKlausConstDecl.create(self, [klausConstName_FileAttrSymLink], zeroSrcPt, klausSimpleI(faSymLink));
  tKlausConstDecl.create(self, [klausConstName_FileAttrCompressed], zeroSrcPt, klausSimpleI(faCompressed));
  tKlausConstDecl.create(self, [klausConstName_FileAttrEncrypted], zeroSrcPt, klausSimpleI(faEncrypted));
  tKlausConstDecl.create(self, [klausConstName_FileAttrVirtual], zeroSrcPt, klausSimpleI(faVirtual));
  {$pop}
end;

procedure tKlausUnitFiles.createRoutines;
begin
  tKlausSysProc_FileCreate.create(self, zeroSrcPt);
  tKlausSysProc_FileOpen.create(self, zeroSrcPt);
  tKlausSysProc_FileClose.create(self, zeroSrcPt);
  tKlausSysProc_FileWrite.create(self, zeroSrcPt);
  tKlausSysProc_FileRead.create(self, zeroSrcPt);
  tKlausSysProc_FilePos.create(self, zeroSrcPt);
  tKlausSysProc_FileExists.create(self, zeroSrcPt);
  tKlausSysProc_FileDirExists.create(self, zeroSrcPt);
  tKlausSysProc_FileTempDir.create(self, zeroSrcPt);
  tKlausSysProc_FileTempName.create(self, zeroSrcPt);
  tKlausSysProc_FileExpandName.create(self, zeroSrcPt);
  tKlausSysProc_FileProgName.create(self, zeroSrcPt);
  tKlausSysProc_FileExtractPath.create(self, zeroSrcPt);
  tKlausSysProc_FileExtractName.create(self, zeroSrcPt);
  tKlausSysProc_FileExtractExt.create(self, zeroSrcPt);
  tKlausSysProc_FileHomeDir.create(self, zeroSrcPt);
  tKlausSysProc_FileGetAttrs.create(self, zeroSrcPt);
  tKlausSysProc_FileGetAge.create(self, zeroSrcPt);
  tKlausSysProc_FileRename.create(self, zeroSrcPt);
  tKlausSysProc_FileDelete.create(self, zeroSrcPt);
  tKlausSysProc_FileFindFirst.create(self, zeroSrcPt);
  tKlausSysProc_FileFindNext.create(self, zeroSrcPt);
  tKlausSysProc_FileMkDir.create(self, zeroSrcPt);
  tKlausSysProc_FileRmDir.create(self, zeroSrcPt);
  tKlausSysProc_FileCurDir.create(self, zeroSrcPt);
end;

class function tKlausUnitFiles.stdUnitName: string;
begin
  result := klausUnitName_Files;
end;

initialization
  klausRegisterStdUnit(tKlausUnitFiles);
  tKlausObjects.registerKlausObject(tKlausFileSearch, strKlausFileSearch);
  tKlausObjects.registerKlausObject(tKlausFileStream, strKlausFileStream);
end.

