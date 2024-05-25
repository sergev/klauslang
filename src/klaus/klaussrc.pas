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

unit KlausSrc;

//todo: Кроме точки в тексте, исключения должны знать модуль, из которого они прилетели
//todo: Добавить в VarPath возможность ссылки на модуль (точнее, путь к области видимости)

//todo: процедурные переменные
//todo: диапазоны в инструкции выбора

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Types, Classes, SysUtils, FGL, Graphics, U8, KlausErr, KlausLex, KlausDef, KlausSyn;

type
  tKlausMap = class;

type
  tKlausSyntaxBrowser = class;
  tKlausSource = class;
  tKlausDecl = class;
  tKlausRoutine = class;
  tKlausModule = class;
  tKlausUnit = class;
  tKlausProgram = class;
  tKlausTypeDef = class;
  tKlausTypeDefSimple = class;
  tKlausTypeDefArray = class;
  tKlausTypeDefDict = class;
  tKlausStructMember = class;
  tKlausTypeDefStruct = class;
  tKlausTypeDecl = class;
  tKlausValueDecl = class;
  tKlausConstDecl = class;
  tKlausVarDecl = class;
  tKlausExceptObjDecl = class;
  tKlausExceptDecl = class;
  tKlausProcParam = class;
  tKlausProcDecl = class;
  tKlausInternalProcDecl = class;
  tKlausVarPath = class;
  tKlausCall = class;
  tKlausOperand = class;
  tKlausExpression = class;
  tKlausOpndLiteral = class;
  tKlausOpndTypecast = class;
  tKlausOpndVarPath = class;
  tKlausOpndCompound = class;
  tKlausOpndArray = class;
  tKlausOpndDict = class;
  tKlausOpndStruct = class;
  tKlausOpndExists = class;
  tKlausOpndCall = class;
  tKlausStatement = class;
  tKlausStmtNothing = class;
  tKlausStmtLoopControl = class;
  tKlausStmtBreak = class;
  tKlausStmtContinue = class;
  tKlausStmtHalt = class;
  tKlausStmtReturn = class;
  tKlausStmtAssign = class;
  tKlausStmtCall = class;
  tKlausStmtRaise = class;
  tKlausStmtCtlStruct = class;
  tKlausStmtBlock = class;
  tKlausExceptBlock = class;
  tKlausFinallyBlock = class;
  tKlausStmtWhen = class;
  tKlausStmtThrow = class;
  tKlausStmtCompound = class;
  tKlausStmtRoutineBody = class;
  tKlausStmtIf = class;
  tKlausStmtCase = class;
  tKlausStmtLoop = class;
  tKlausStmtFor = class;
  tKlausStmtForEach = class;
  tKlausStmtWhile = class;
  tKlausStmtRepeat = class;

type
  tKlausObjects = class;
  tKlausVarValue = class;
  tKlausVarValueSimple = class;
  tKlausVarValueArray = class;
  tKlausVarValueDict = class;
  tKlausVarValueStruct = class;
  tKlausVariable = class;
  tKlausStackFrame = class;
  tKlausRuntime = class;
  tKlausCanvasLink = class;
  eKlausLangException = class;

type
  tKlausVarValueClass = class of tKlausVarValue;
  tKlausOpndCompoundClass = class of tKlausOpndCompound;
  tKlausStmtCtlStructClass = class of tKlausStmtCtlStruct;

type
  // Область поиска имён
  // knsLocal -- только в текущей области видимости
  // knsGlobal -- в текущей и объемлющих областях видимости
  tKlausNameScope = (knsLocal, knsGlobal);

type
  // Режим передачи параметра в подпрограмму
  tKlausProcParamMode = (kpmInput, kpmOutput, kpmInOut);
  tKlausProcParamModes = array of tKlausProcParamMode;

type
  // Элемент пути к переменной
  tKLausVarPathStep = record
    name: string;
    point: tSrcPoint;
    indices: array of tKlausExpression;
  end;
  tKlausVarPathSteps = array of tKlausVarPathStep;

type
  // Опции при получении значения переменной
  tKlausVarPathMode = (
    vpmEvaluate,   // получить значение для использования в выражении
    vpmCheckExist, // проверить существование элемента в массиве или словаре
    vpmAsgnTarget  // получить (или создать) буфер для присваивания значения
  );

type
  // Состояние нити отладки программы
  tKlausDebugState = (
    kdsInitial,   // создана, но ещё не запущена
    kdsRunning,   // выполняется
    kdsWaitStep,  // остановлена отладчиком и ждёт следующего шага
    kdsWaitInput, // ждёт ввода данных из консоли от основной нити
    kdsFinished   // завершена
  );

type
  // Структура для передачи значений параметров во встроенные функции
  tKlausVarValueAt = record
    v: tKlausVarValue;
    at: tSrcPoint;
  end;

const
  // Максимальная глубина стека вызовов
  klausDefaultMaxStackSize = 255;

type
  // Словарь с ключом tKlausSimpleValue (требует ключей одного указанного типа).
  // Генерик здесь использовать не получается, т.к. не определены операторы
  // сравнения для tKlausSimpleValue, а код генерика их использует.
  tKlausMap = class(tFPSMap)
    private
      fKeyType: tKlausSimpleType;
      fAccuracy: tKlausFloat;
    protected
      procedure copyItem(src, dest: pointer); override;
      procedure copyKey(src, dest: pointer); override;
      procedure copyData(src, dest: pointer); override;
      procedure deref(item: pointer); override;
      procedure initOnPtrCompare; override;
      function  getKey(index: integer): tKlausSimpleValue;
      function  getKeyData(const aKey: tKlausSimpleValue): tObject;
      function  getData(index: integer): tObject;
      function  keyCompare(key1, key2: pointer): integer;
      procedure putKey(index: integer; const newKey: tKlausSimpleValue);
      procedure putKeyData(const aKey: tKlausSimpleValue; const newData: tObject);
      procedure putData(index: integer; const newData: tObject);
    public
      property keyType: tKlausSimpleType read fKeyType;
      property accuracy: tKlausFloat read fAccuracy;
      property keys[index: integer]: tKlausSimpleValue read getKey write putKey;
      property data[index: integer]: tObject read getData write putData;
      property keyData[const aKey: tKlausSimpleValue]: tObject read getKeyData write putKeyData; default;

      constructor create(aKeyType: tKlausSimpleType; aAccuracy: tKlausFloat);
      function  add(const aKey: tKlausSimpleValue; const aData: tObject): integer;
      function  add(const aKey: tKlausSimpleValue): integer;
      function  find(const aKey: tKlausSimpleValue; out index: integer): boolean;
      function  tryGetData(const aKey: tKlausSimpleValue; out aData: tObject): boolean;
      procedure addOrSetData(const aKey: tKlausSimpleValue; const aData: tObject);
      function  indexOf(const aKey: tKlausSimpleValue): integer;
      function  indexOfData(const aData: tObject): integer;
      procedure insertKey(index: integer; const aKey: tKlausSimpleValue);
      procedure insertKeyData(index: integer; const aKey: tKlausSimpleValue; const aData: tObject);
      function  remove(const aKey: tKlausSimpleValue): integer;
  end;

type
  // Вспомогательный класс для обхода синтаксического дерева
  tKlausSyntaxBrowser = class
    private
      fRoot: tKlausSrcNodeRule;
      fCur: tKlausSrcNode;
      fLex: tKlausLexInfo;
      fPause: boolean;

      procedure updateCurLexInfo;
    public
      property root: tKlausSrcNodeRule read fRoot;
      property cur: tKlausSrcNode read fCur;
      property lex: tKlausLexInfo read fLex;

      constructor create(aRoot: tKlausSrcNodeRule);
      procedure next;
      procedure pause;
      function  check(aKwd: tKlausValidKeyword; require: boolean = true): boolean;
      function  check(aKwd: tKlausValidKeywords; require: boolean = true): tKlausKeyword;
      function  check(aSym: tKlausValidSymbol; require: boolean = true): boolean;
      function  check(aSym: tKlausValidSymbols; require: boolean = true): tKlausSymbol;
      function  check(aRule: string; require: boolean = true): boolean;
      function  check(aRule: array of string; require: boolean = true): integer;
      function  check(aLex: tKlausValidLexem; require: boolean = true): boolean;
      function  check(aLex: tKlausValidLexemes; require: boolean = true): tKlausLexem;
      function  get(aLex: tKlausValidLexem; require: boolean = true): tKlausLexInfo;
      function  get(aLex: tKlausValidLexemes; require: boolean = true): tKlausLexInfo;
  end;

type
  // Корневой класс для построения синтаксического дерева исходного текста
  tKlausSource = class(tObject)
    private
      fDestroying: boolean;
      fModule: tKlausModule;
      fUnits: tStringList;
      fSystemUnit: tKlausUnit;
      fTypes: tFPList;
      fSimpleTypes: array[tKlausSimpleType] of tKlausTypeDefSimple;
      fArrayTypes: array[tKlausSimpleType] of tKlausTypeDefArray;
      fSimpleExceptType: tKlausTypeDefStruct;

      function  getSimpleTypes(t: tKlausSimpleType): tKlausTypeDefSimple;
      function  getArrayTypes(t: tKlausSimpleType): tKlausTypeDefArray;
      function  getTypeCount: integer;
      function  getTypes(idx: integer): tKlausTypeDef;
      function  addType(aType: tKlausTypeDef): integer;
      procedure removeType(aType: tKlausTypeDef);
      function  getUnitCount: integer;
      function  getUnits(idx: integer): tKlausUnit;
      procedure addUnit(aUnit: tKlausUnit);
      procedure removeUnit(aUnit: tKlausUnit);
    protected
      function createProgram(prog: tKlausSrcNodeRule): tKlausProgram;
    public
      property unitCount: integer read getUnitCount;
      property units[idx: integer]: tKlausUnit read getUnits;
      property systemUnit: tKlausUnit read fSystemUnit;
      property simpleTypes[t: tKlausSimpleType]: tKlausTypeDefSimple read getSimpleTypes;
      property arrayTypes[t: tKlausSimpleType]: tKlausTypeDefArray read getArrayTypes;
      property simpleExceptType: tKlausTypeDefStruct read fSimpleExceptType;
      property typeCount: integer read getTypeCount;
      property types[idx: integer]: tKlausTypeDef read getTypes;
      property module: tKlausModule read fModule;

      constructor create(p: tKlausLexParser);
      destructor  destroy; override;
      procedure beforeDestruction; override;
      function  createExceptionTypeDef: tKlausTypeDefStruct;
  end;

type
  // Именованное определение
  tKlausDecl = class(tObject)
    private
      fPoint: tSrcPoint;
      fOwner: tKlausRoutine;
      fName: string;
      fAltNames: array of string;
      fPosition: integer;
      function getNameCount: integer;
      function getNames(idx: integer): string;
    protected
      function getSource: tKlausSource; virtual;
      function getUpperScope: tKlausRoutine; virtual;
    public
      property owner: tKlausRoutine read fOwner;
      property source: tKlausSource read getSource;
      property name: string read fName;
      property nameCount: integer read getNameCount;
      property names[idx: integer]: string read getNames;
      property position: integer read fPosition;
      property point: tSrcPoint read fPoint;
      property upperScope: tKlausRoutine read getUpperScope;

      constructor create(aOwner: tKlausRoutine; aNames: array of string; aPoint: tSrcPoint);
      destructor  destroy; override;
      function hasName(s: string): boolean;
  end;

type
  // Именованная подпрограмма -- процедура, функция, программа, модуль
  tKlausRoutine = class(tKlausDecl)
    private
      fDestroying: boolean;
      fSource: tKlausSource;
      fDecls: tStringList;
      fDeclOrder: array of tKlausDecl;
      fParams: tFPList;
      fRetValue: tKlausProcParam;
      fBody: tKlausStmtCompound;

      function  getDecl(const d: string): tKlausDecl;
      function  getDeclCount: integer;
      function  getDecls(idx: integer): tKlausDecl;
      function  getParamCount: integer;
      function  getParams(idx: integer): tKlausProcParam;
      procedure createIDs(b: tKlausSyntaxBrowser; out ids: tStringArray; out p: tSrcPoint);
      procedure createRoutine(b: tKlausSyntaxBrowser);
      procedure createDeclarations(b: tKlausSyntaxBrowser);
      function  createStatement(aOwner: tKlausStmtCtlStruct; b: tKlausSyntaxBrowser): tKlausStatement;
      procedure createStatements(aOwner: tKlausStmtCtlStruct; b: tKlausSyntaxBrowser);
      procedure createVarDeclarations(b: tKlausSyntaxBrowser);
      procedure createConstDeclarations(b: tKlausSyntaxBrowser);
      procedure createTypeDeclarations(b: tKlausSyntaxBrowser);
      procedure createExceptDeclarations(b: tKlausSyntaxBrowser);
      procedure createProcDeclaration(b: tKlausSyntaxBrowser);
      procedure createFuncDeclaration(b: tKlausSyntaxBrowser);
      function  createDataType(b: tKlausSyntaxBrowser): tKlausTypeDef;
      function  createDataTypeID(b: tKlausSyntaxBrowser; require: boolean = true): tKlausTypeDef;
      function  createSimpleType(b: tKlausSyntaxBrowser; require: boolean = true): tKlausTypeDefSimple;
      function  createConstExpression(b: tKlausSyntaxBrowser): tKlausSimpleValue;
      function  createExpression(aStmt: tKlausStatement; b: tKlausSyntaxBrowser; expectedType: tKlausTypeDef = nil): tKlausExpression;
      function  createStmtControlStructure(aOwner: tKlausStmtCtlStruct; b: tKlausSyntaxBrowser): tKlausStmtCtlStruct;
    protected
      function  getHidden: boolean; virtual;
      function  getDisplayName: string; virtual;
      function  getSource: tKlausSource; override;
      procedure addDecl(item: tKlausDecl);
      procedure removeDecl(item: tKlausDecl);
      function  getRetValueType: tKlausTypeDef; virtual;
      function  findDecl(aName: string; scope: tKlausNameScope; before: integer): tKlausDecl; virtual;
      procedure addParam(p: tKlausProcParam);
      procedure setRetValue(v: tKlausProcParam);
    public
      property hidden: boolean read getHidden;
      property displayName: string read getDisplayName;
      property declCount: integer read getDeclCount;
      property decls[idx: integer]: tKlausDecl read getDecls;
      property decl[const d: string]: tKlausDecl read getDecl;
      property paramCount: integer read getParamCount;
      property params[idx: integer]: tKlausProcParam read getParams;
      property retValue: tKlausProcParam read fRetValue;
      property retValueType: tKlausTypeDef read getRetValueType;
      property body: tKlausStmtCompound read fBody;

      constructor create(aOwner: tKlausRoutine; aName: string; aPoint: tSrcPoint);
      destructor  destroy; override;
      procedure beforeDestruction; override;
      function  find(aName: string; scope: tKlausNameScope): tKlausDecl;
      procedure checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint); virtual;
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); virtual;
    end;

type
  // Базовый класс программы или модуля
  tKlausModule = class(tKlausRoutine)
    private
      fUpperScope: tKlausRoutine;
    protected
      function  getUpperScope: tKlausRoutine; override;
    public
      constructor create(aSource: tKlausSource; aName: string; aPoint: tSrcPoint);
  end;

type
  // Модуль
  tKlausUnit = class(tKlausModule)
    private
      fNext: tKlausModule;
      fDoneBody: tKlausStmtCompound;
    protected
      function  getDisplayName: string; override;
      procedure beforeInit(stack: tKlausStackFrame); virtual;
      procedure afterDone(stack: tKlausStackFrame); virtual;
    public
      property next: tKlausModule read fNext;
      property initBody: tKlausStmtCompound read fBody;
      property doneBody: tKlausStmtCompound read fDoneBody;

      constructor create(aSource: tKlausSource; aName: string; aPoint: tSrcPoint);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // Программа
  tKlausProgram = class(tKlausModule)
    private
      fArgs: tKlausProcParam;
    protected
      function getDisplayName: string; override;
    public
      property args: tKlausProcParam read fArgs;

      constructor create(aSource: tKlausSource; aName: string; aPoint: tSrcPoint);
      constructor create(aSource: tKlausSource; aName: string; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      procedure run(frame: tKlausStackFrame; const at: tSrcPoint); override;
  end;

type
  // Описание типа данных
  tKlausTypeDef = class(tObject)
    private
      fOwner: tKlausSource;
      fPoint: tSrcPoint;
    protected
      function getDataType: tKlausDataType; virtual;
    public
      property owner: tKlausSource read fOwner;
      property dataType: tKlausDataType read getDataType;
      property point: tSrcPoint read fPoint;

      constructor create(aOwner: tKlausSource; aPoint: tSrcPoint);
      destructor  destroy; override;
      function  canAssign(src: tKlausTypeDef; strict: boolean = false): boolean; virtual;
      function  canAssign(src: tKlausDataType; strict: boolean = false): boolean;
      function  canAssign(src: tKlausSimpleValue; strict: boolean = false): boolean;
      function  zeroValue: tKlausSimpleValue; virtual;
      function  valueClass: tKlausVarValueClass; virtual; abstract;
      function  literalClass: tKlausOpndCompoundClass; virtual;
  end;

type
  // Описание простого типа данных -- символ, строка, число, момент, логическое.
  tKlausTypeDefSimple = class(tKlausTypeDef)
    private
      fSimpleType: tKlausSimpleType;
    protected
      function getDataType: tKlausDataType; override;
    public
      property simpleType: tKlausSimpleType read fSimpleType;

      constructor create(aOwner: tKlausSource; aSimpleType: tKlausSimpleType);
      function  canAssign(src: tKlausTypeDef; strict: boolean = false): boolean; override;
      function  zeroValue: tKlausSimpleValue; override;
      function  valueClass: tKlausVarValueClass; override;
  end;

type
  // Описание составного типа данных -- массива
  tKlausTypeDefArray = class(tKlausTypeDef)
    private
      fElmtType: tKlausTypeDef;
    public
      property elmtType: tKlausTypeDef read fElmtType;

      constructor create(aOwner: tKlausSource; aElmtType: tKlausDataType);
      constructor create(context: tKlausRoutine; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      constructor create(source: tKlausSource; aPoint: tSrcPoint; aDims: integer; aElmtType: tKlausTypeDef);
      function  canAssign(src: tKlausTypeDef; strict: boolean = false): boolean; override;
      function  valueClass: tKlausVarValueClass; override;
      function  literalClass: tKlausOpndCompoundClass; override;
  end;

type
  // Описание составного типа данных -- словаря
  tKlausTypeDefDict = class(tKlausTypeDef)
    private
      fKeyType: tKlausSimpleType;
      fValueType: tKlausTypeDef;
      fAccuracy: tKlausFloat;
    public
      property keyType: tKlausSimpleType read fKeyType;
      property valueType: tKlausTypeDef read fValueType;
      property accuracy: tKlausFloat read fAccuracy;

      constructor create(context: tKlausRoutine; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      function  canAssign(src: tKlausTypeDef; strict: boolean = false): boolean; override;
      function  valueClass: tKlausVarValueClass; override;
      function  literalClass: tKlausOpndCompoundClass; override;
  end;

type
  // Описание поля структуры
  tKlausStructMember = class(tObject)
    private
      fOwner: tKlausTypeDefStruct;
      fPoint: tSrcPoint;
      fName: string;
      fDataType: tKlausTypeDef;
    public
      property owner: tKlausTypeDefStruct read fOwner;
      property name: string read fName;
      property dataType: tKlausTypeDef read fDataType;
      property point: tSrcPoint read fPoint;

      constructor create(aOwner: tKlausTypeDefStruct; aName: string; aPoint: tSrcPoint; aDataType: tKlausTypeDef);
      destructor  destroy; override;
  end;

type
  // Описание составного типа данных -- структуры
  tKlausTypeDefStruct = class(tKlausTypeDef)
    private
      fDestroying: boolean;
      fMembers: tStringList;
      fMemberOrder: array of tKlausStructMember;

      function  getCount: integer;
      function  getMember(const m: string): tKlausStructMember;
      function  getMembers(idx: integer): tKlausStructMember;
      procedure addMember(m: tKlausStructMember);
      procedure removeMember(m: tKlausStructMember);
    public
      property count: integer read getCount;
      property members[idx: integer]: tKlausStructMember read getMembers;
      property member[const m: string]: tKlausStructMember read getMember;

      constructor create(aOwner: tKlausSource; aPoint: tSrcPoint);
      constructor create(context: tKlausRoutine; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      procedure beforeDestruction; override;
      function  canAssign(src: tKlausTypeDef; strict: boolean = false): boolean; override;
      function  valueClass: tKlausVarValueClass; override;
      function  literalClass: tKlausOpndCompoundClass; override;
  end;

type
  // Определение типа данных
  tKlausTypeDecl = class(tKlausDecl)
    private
      fDataType: tKlausTypeDef;
    public
      property dataType: tKlausTypeDef read fDataType;

      constructor create(aOwner: tKlausRoutine; aNames: array of string; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      constructor create(aOwner: tKlausRoutine; aNames: array of string; aPoint: tSrcPoint; def: tKlausTypeDef);
  end;

type
  // Объект, имеющий значение, -- базовый класс для переменных и констант
  tKlausValueDecl = class(tKlausDecl)
    protected
      function getDataType: tKlausTypeDef; virtual; abstract;
    public
      property dataType: tKlausTypeDef read getDataType;
  end;

type
  // Определение константы
  tKlausConstDecl = class(tKlausValueDecl)
    private
      fValue: tKlausVarValue;
    protected
      function getDataType: tKlausTypeDef; override;
    public
      property value: tKlausVarValue read fValue;

      constructor create(aOwner: tKlausRoutine; aNames: array of string; aPoint: tSrcPoint; const val: tKlausSimpleValue);
      constructor create(aOwner: tKlausRoutine; aNames: array of string; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
  end;

type
  // Определение переменной
  tKlausVarDecl = class(tKlausValueDecl)
    private
      fDataType: tKlausTypeDef;
      fInitial: tKlausVarValue;

      function getHidden: boolean;
    protected
      function getDataType: tKlausTypeDef; override;
    public
      property initial: tKlausVarValue read fInitial;
      property hidden: boolean read getHidden;

      constructor create(aOwner: tKlausRoutine; aNames: array of string; aPoint: tSrcPoint; aDataType: tKlausTypeDef; aInitial: tKlausVarValue);
      destructor  destroy; override;
      procedure initialize(v: tKlausVariable);
  end;

type
  // Определение исключения
  tKlausExceptDecl = class(tKlausDecl)
    private
      fMessage: string;
      fData: tKlausTypeDefStruct;
    public
      property message: string read fMessage;
      property data: tKlausTypeDefStruct read fData;

      constructor create(aOwner: tKlausRoutine; aName: string; aPoint: tSrcPoint; aMsg: string);
      constructor create(aOwner: tKlausRoutine; aName: string; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
  end;

type
  // Определение переменной - объекта исключения в секции обработки исключений
  tKlausExceptObjDecl = class(tKlausVarDecl)
    public
      constructor create(aOwner: tKlausRoutine; aName: string; const aPoint: tSrcPoint; aExceptDecl: tKlausExceptDecl);
  end;

type
  // Определение параметра подпрограммы
  tKlausProcParam = class(tKlausVarDecl)
    private
      fMode: tKlausProcParamMode;
    public
      property mode: tKlausProcParamMode read fMode;

      constructor create(aOwner: tKlausRoutine; aName: string; aPoint: tSrcPoint; aMode: tKlausProcParamMode; aDataType: tKlausTypeDef);
  end;

type
  // Определение процедуры/функции
  tKlausProcDecl = class(tKlausRoutine)
    private
      fFwd: boolean;
      fImplPos: integer;

      function getIsFunction: boolean;
    protected
      function getDisplayName: string; override;
    public
      property isFunction: boolean read getIsFunction;
      property fwd: boolean read fFwd;
      property implPos: integer read fImplPos;

      constructor create(aOwner: tKlausRoutine; aName: string; aPoint: tSrcPoint);
      constructor create(aOwner: tKlausRoutine; aName: string; isFunc: boolean; b: tKlausSyntaxBrowser);
      constructor createHeader(aOwner: tKlausRoutine; aName: string; isFunc: boolean; b: tKlausSyntaxBrowser);
      procedure resolveForwardDeclaration(isFunc: boolean; b: tKlausSyntaxBrowser);
      function  matchHeader(pd: tKlausProcDecl): boolean;
  end;

type
  // Базовый класс встроенной подпрограммы. Используется для объявления
  // встроенных функций языка -- их, вестимо, создают встроенные модули.
  // Позволяет колдовать со списком параметров. А вот с возвращаемым
  // результатом колдовать не будем: такое колдовство стоит слишком много маны.
  // Поэтому определяемся сразу: либо крестик, либо... кхгм... нету крестика.
  tKlausInternalProcDecl = class(tKlausProcDecl)
    public
      function  isCustomParamHandler: boolean; virtual;
      procedure getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint); virtual;
      procedure customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint); virtual;
  end;

type
  // Путь к переменной или константе -- список имён через точку
  // с возможными обращениями к элементам массивов/словарей по индексу/ключу
  tKlausVarPath = class(tObject)
    private
      fDecl: tKlausValueDecl;
      fSteps: tKlausVarPathSteps;

      function getIsConstant: boolean;
      function getStepCount: integer;
      function getIsVariable: boolean;
      function getPoint: tSrcPoint;
      function getSteps(idx: integer): tKlausVarPathStep;
    public
      property decl: tKlausValueDecl read fDecl;
      property stepCount: integer read getStepCount;
      property steps[idx: integer]: tKlausVarPathStep read getSteps;
      property point: tSrcPoint read getPoint;
      property isVariable: boolean read getIsVariable;
      property isConstant: boolean read getIsConstant;

      constructor create(context: tKlausStatement; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      function resultTypeDef: tKlausTypeDef;
      function evaluate: tKlausVarValue;
      function evaluate(frame: tKlausStackFrame; mode: tKlausVarPathMode; allowCalls: boolean): tKlausVarValue;
  end;

type
  // Вызов подпрограммы со списком выражений для передачи в параметры
  tKlausCall = class(tObject)
    private
      fPoint: tSrcPoint;
      fCallee: tKlausRoutine;
      fParams: array of tKlausExpression;

      function  getParamCount: integer;
      function  getParams(idx: integer): tKlausExpression;
      procedure checkParamTypes;
    public
      property callee: tKlausRoutine read fCallee;
      property paramCount: integer read getParamCount;
      property params[idx: integer]: tKlausExpression read getParams;
      property point: tSrcPoint read fPoint;

      constructor create(context: tKlausStatement; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      function  resultTypeDef: tKlausTypeDef;
      procedure perform(frame: tKlausStackFrame; out rslt: tKlausVarValue);
  end;

type
  // Базовый класс операнда выражения
  tKlausOperand = class(tObject)
    private
      fPoint: tSrcPoint;
      fStmt: tKlausStatement;
      fParent: tKlausOperand;
      fUop: tKlausUnaryOperation;

      function getRoutine: tKlausRoutine;
    protected
      function doEvaluate: tKlausSimpleValue; virtual;
      function doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue; virtual; abstract;
      function getResultType: tKlausDataType; virtual; abstract;
    public
      property point: tSrcPoint read fPoint write fPoint;
      property stmt: tKlausStatement read fStmt;
      property parent: tKlausOperand read fParent;
      property routine: tKlausRoutine read getRoutine;
      property uop: tKlausUnaryOperation read fUop write fUop;

      constructor create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint);
      function resultType: tKlausDataType;
      function resultTypeDef: tKlausTypeDef; virtual;
      function evaluate: tKlausSimpleValue;
      function evaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue;
      function acquireVarValue: tKlausVarValue; virtual;
      function acquireVarValue(frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue; virtual;
  end;

type
  // Выражение.
  // Левый операнд определён всегда. Правый может быть nil -- тогда операция должна быть kboInvalid,
  // и выражение возвращает значение левого операнда. Выражения с двумя операндами могут возвращать
  // только значения простых типов. Передаваться в параметры ВЫХ и ВВ могут только выражения,
  // имеющие один левый операнд класса tKlausOpndVarPath, в котором uop = kuoInvalid.
  tKlausExpression = class(tKlausOperand)
    private
      fLeft: tKlausOperand;
      fRight: tKlausOperand;
      fOp: tKlausBinaryOperation;
      fOpPoint: tSrcPoint;

      procedure setLeft(aLeft: tKlausOperand);
      procedure setRight(aRight: tKlausOperand);
    protected
      function doEvaluate: tKlausSimpleValue; override;
      function doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue; override;
      function getResultType: tKlausDataType; override;
    public
      property left: tKlausOperand read fLeft write setLeft;
      property right: tKlausOperand read fRight write setRight;
      property op: tKlausBinaryOperation read fOp write fOp;
      property opPoint: tSrcPoint read fOpPoint write fOpPoint;

      constructor create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint);
      destructor  destroy; override;
      function  resultTypeDef: tKlausTypeDef; override;
      function  isVarPath: boolean;
      function  isConstPath: boolean;
      function  isCall: boolean;
      function  isCompound: boolean;
      function  acquireVarValue: tKlausVarValue; override;
      function  acquireVarValue(frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue; override;
  end;

type
  // Операнд выражения -- литерал
  tKlausOpndLiteral = class(tKlausOperand)
    private
      fValue: tKlausSimpleValue;
    protected
      function getResultType: tKlausDataType; override;
      function doEvaluate: tKlausSimpleValue; override;
      function doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue; override;
    public
      property value: tKlausSimpleValue read fValue;

      constructor create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
  end;

type
  // Операнд выражения -- приведение типа
  tKlausOpndTypecast = class(tKlausOperand)
    private
      fDestType: tKlausSimpleType;
      fExpr: tKlausExpression;
    protected
      function getResultType: tKlausDataType; override;
      function doEvaluate: tKlausSimpleValue; override;
      function doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue; override;
    public
      property destType: tKlausSimpleType read fDestType;
      property expr: tKlausExpression read fExpr;

      constructor create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
  end;

type
  // Операнд выражения -- переменная или константа
  tKlausOpndVarPath = class(tKlausOperand)
    private
      fPath: tKlausVarPath;
    protected
      function getResultType: tKlausDataType; override;
      function doEvaluate: tKlausSimpleValue; override;
      function doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue; override;
    public
      property path: tKlausVarPath read fPath;

      constructor create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      function  resultTypeDef: tKlausTypeDef; override;
      function  acquireVarValue: tKlausVarValue; override;
      function  acquireVarValue(frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue; override;
  end;

type
  // Операнд выражения -- литерал составного типа.
  // Собственно, операндом в выражении он быть не может -- только самим выражением.
  tKlausOpndCompound = class(tKlausOperand)
    private
      fTypeDef: tKlausTypeDef;
    protected
      function getResultType: tKlausDataType; override;
      function doEvaluate: tKlausSimpleValue; override;
      function doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue; override;
      function doAcquireVarValue(runTime: boolean; frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue; virtual; abstract;
    public
      property typeDef: tKlausTypeDef read fTypeDef;

      constructor create(aStmt: tKlausStatement; aTypeDef: tKlausTypeDef; aPoint: tSrcPoint; b: tKlausSyntaxBrowser); virtual;
      function  resultTypeDef: tKlausTypeDef; override;
      procedure parseLiteral(b: tKlausSyntaxBrowser); virtual; abstract;
      function  acquireVarValue: tKlausVarValue; override;
      function  acquireVarValue(frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue; override;
  end;

type
  // Операнд выражения -- литерал массива.
  tKlausOpndArray = class(tKlausOpndCompound)
    private
      fElmt: array of tKlausExpression;

      function getCount: integer;
      function getElmt(idx: integer): tKlausExpression;
    protected
      function doAcquireVarValue(runTime: boolean; frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue; override;
    public
      property count: integer read getCount;
      property elmt[idx: integer]: tKlausExpression read getElmt;

      constructor create(aStmt: tKlausStatement; aTypeDef: tKlausTypeDef; aPoint: tSrcPoint; b: tKlausSyntaxBrowser); override;
      destructor  destroy; override;
      procedure parseLiteral(b: tKlausSyntaxBrowser); override;
  end;

type
  // Элемент литерала словаря -- пара ключ-значение.
  tKlausOpndDictElmt = class(tObject)
    private
      fKey: tKlausExpression;
      fValue: tKlausExpression;
    public
      property key: tKlausExpression read fKey;
      property value: tKlausExpression read fValue;

      constructor create(aKey, aValue: tKlausExpression);
      destructor  destroy; override;
  end;

type
  // Операнд выражения -- литерал массива.
  tKlausOpndDict = class(tKlausOpndCompound)
    private
      fElmt: array of tKlausOpndDictElmt;

      function getCount: integer;
      function getElmt(idx: integer): tKlausOpndDictElmt;
    protected
      function doAcquireVarValue(runTime: boolean; frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue; override;
    public
      property count: integer read getCount;
      property elmt[idx: integer]: tKlausOpndDictElmt read getElmt;

      constructor create(aStmt: tKlausStatement; aTypeDef: tKlausTypeDef; aPoint: tSrcPoint; b: tKlausSyntaxBrowser); override;
      destructor  destroy; override;
      procedure parseLiteral(b: tKlausSyntaxBrowser); override;
  end;

type
  // Элемент литерала структуры -- значение поля.
  tKlausOpndStructMember = class(tObject)
    private
      fName: string;
      fExpr: tKlausExpression;
      fPoint: tSrcPoint;
    public
      property name: string read fName;
      property expr: tKlausExpression read fExpr;
      property point: tSrcPoint read fPoint;

      constructor create(aName: string; aExpr: tKlausExpression; aPoint: tSrcPoint);
      destructor  destroy; override;
  end;

type
  // Операнд выражения -- литерал структуры.
  tKlausOpndStruct = class(tKlausOpndCompound)
    private
      fMembers: tStringList;

      function getCount: integer;
      function getMembers(idx: integer): tKlausOpndStructMember;
    protected
      function doAcquireVarValue(runTime: boolean; frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue; override;
    public
      property count: integer read getCount;
      property members[idx: integer]: tKlausOpndStructMember read getMembers;

      constructor create(aStmt: tKlausStatement; aTypeDef: tKlausTypeDef; aPoint: tSrcPoint; b: tKlausSyntaxBrowser); override;
      destructor  destroy; override;
      procedure parseLiteral(b: tKlausSyntaxBrowser); override;
  end;

type
  // Операнд выражения -- проверка существования
  tKlausOpndExists = class(tKlausOperand)
    private
      fNegate: boolean;
      fPath: tKlausVarPath;
    protected
      function getResultType: tKlausDataType; override;
      function doEvaluate: tKlausSimpleValue; override;
      function doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue; override;
    public
      property negate: boolean read fNegate;
      property path: tKlausVarPath read fPath;

      constructor create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
  end;

type
  // Операнд выражения -- вызов функции
  tKlausOpndCall = class(tKlausOperand)
    private
      fCall: tKlausCall;
    protected
      function getResultType: tKlausDataType; override;
      function doEvaluate: tKlausSimpleValue; override;
      function doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue; override;
    public
      property call: tKlausCall read fCall;

      constructor create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      function resultTypeDef: tKlausTypeDef; override;
      function acquireVarValue: tKlausVarValue; override;
      function acquireVarValue(frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue; override;
  end;

type
  // Базовый класс инструкции
  tKlausStatement = class(tObject)
    private
      fPoint: tSrcPoint;
      fOwner: tKlausStmtCtlStruct;
    protected
      function getRoutine: tKlausRoutine; virtual;
      function findUpperStructure(cls: tKlausStmtCtlStructClass): tKlausStmtCtlStruct;
    public
      property owner: tKlausStmtCtlStruct read fOwner;
      property routine: tKlausRoutine read getRoutine;
      property point: tSrcPoint read fPoint;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame); virtual; abstract;
  end;

type
  // Пустая инструкция
  tKlausStmtNothing = class(tKlausStatement)
    public
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Базовый класс инструкции управления циклом
  tKlausStmtLoopControl = class(tKlausStatement)
    public
      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint);
  end;

type
  // Инструкция прерывания цикла
  tKlausStmtBreak = class(tKlausStmtLoopControl)
    public
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Инструкция продолжения цикла
  tKlausStmtContinue = class(tKlausStmtLoopControl)
    public
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Инструкция завершения программы
  tKlausStmtHalt = class(tKlausStatement)
    private
      fRetCode: tKlausExpression;
    public
      property retCode: tKlausExpression read fRetCode;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Инструкция возврата из подпрограммы
  tKlausStmtReturn = class(tKlausStatement)
    private
      fRetValue: tKlausExpression;
    public
      property retValue: tKlausExpression read fRetValue;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Инструкция присваивания
  tKlausStmtAssign = class(tKlausStatement)
    private
      fDest: tKlausVarPath;
      fSource: tKlausExpression;
      fOp: tKlausBinaryOperation;
    public
      property dest: tKlausVarPath read fDest;
      property source: tKlausExpression read fSource;
      property op: tKlausBinaryOperation  read fOp;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Инструкция вызова подпрограммы
  tKlausStmtCall = class(tKlausStatement)
    private
      fCall: tKlausCall;
    public
      property call: tKlausCall read fCall;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Инструкция создания исключения
  tKlausStmtRaise = class(tKlausStatement)
    private
      fDecl: tKlausExceptDecl;
      fMessage: tKlausExpression;
      fParams: array of tKlausExpression;

      function  getParamCount: integer;
      function  getParams(idx: integer): tKlausExpression;
      procedure checkParamTypes;
      function  formatErrorMessage(const msg: string; data: tKlausVarValueStruct): string;
    public
      property decl: tKlausExceptDecl read fDecl;
      property message: tKlausExpression read fMessage;
      property paramCount: integer read getParamCount;
      property params[idx: integer]: tKlausExpression read getParams;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Базовый класс инструкции -- управляющей структуры.
  // Управляющая структура может содержать вложенные инструкции и должна их освобождать,
  // но функции добавления и удаления вложенных инструкций должны быть реализованы наследниками.
  tKlausStmtCtlStruct = class(tKlausStatement)
    private
      fDestroying: boolean;
    protected
      procedure addItem(item: tKlausStatement); virtual;
      procedure removeItem(item: tKlausStatement); virtual;
    public
      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint);
      procedure beforeDestruction; override;
  end;

type
  // Базовый класс составной инструкции -- блок вложенных инструкций
  tKlausStmtBlock = class(tKlausStmtCtlStruct)
    private
      fItems: tFPList;

      function  getCount: integer;
      function  getItems(idx: integer): tKlausStatement;
    protected
      procedure addItem(item: tKlausStatement); override;
      procedure removeItem(item: tKlausStatement); override;
    public
      property count: integer read getCount;
      property items[idx: integer]: tKlausStatement read getItems;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Блок завершения в инструкции "начало-окончание"
  tKlausFinallyBlock = class(tKlausStmtBlock);

type
  // Блок обработки исключений в инструкции "начало-окончание"
  tKlausExceptBlock = class(tKlausStmtBlock)
    private
      fHasHandlers: boolean;
    protected
      procedure addItem(item: tKlausStatement); override;
    public
      property hasHandlers: boolean read fHasHandlers;

      procedure createExceptHandlers(b: tKlausSyntaxBrowser);
      function  getExceptionHandler(obj: eKlausLangException): tKlausStmtWhen;
  end;

type
  // Секция в блоке обработки исключений
  tKlausStmtWhen = class(tKlausStmtCtlStruct)
    private
      fObjDecl: tKlausExceptObjDecl;
      fExcepts: array of tKlausExceptDecl;
      fStmt: tKlausStatement;

      function getExceptCount: integer;
      function getExcepts(idx: integer): tKlausExceptDecl;
    public
      property objDecl: tKlausExceptObjDecl read fObjDecl;
      property exceptCount: integer read getExceptCount;
      property excepts[idx: integer]: tKlausExceptDecl read getExcepts;
      property stmt: tKlausStatement read fStmt;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      function  willHandle(obj: eKlausLangException): boolean;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Инструкция повторного создания исключения в блоке обработки
  tKlausStmtThrow = class(tKlausStatement)
    public
      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint);
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Составная инструкция "начало-обработать-напоследок-окончание"
  tKlausStmtCompound = class(tKlausStmtBlock)
    private
      fExceptBlock: tKlausExceptBlock;
      fFinallyBlock: tKlausFinallyBlock;

      procedure updateGlobalErrorInfo(obj: eKlausLangException);
      procedure updateExceptionMessage(frame: tKlausStackFrame; obj: eKlausLangException);
    protected
      procedure addItem(item: tKlausStatement); override;
      procedure handleException(frame: tKlausStackFrame; obj: eKlausLangException; addr: codePointer);
    public
      property exceptBlock: tKlausExceptBlock read fExceptBlock;
      property finallyBlock: tKlausFinallyBlock read fFinallyBlock;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint);
      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      procedure createCompound(b: tKlausSyntaxBrowser);
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Составная инструкция -- тело процедуры/функции/программы
  tKlausStmtRoutineBody = class(tKlausStmtCompound)
    private
      fRoutine: tKlausRoutine;
    protected
      function getRoutine: tKlausRoutine; override;
    public
      constructor create(aRoutine: tKlausRoutine; aPoint: tSrcPoint);
  end;

type
  // Инструкция условного ветвления
  tKlausStmtIf = class(tKlausStmtCtlStruct)
    private
      fExpr: tKlausExpression;
      fStmtTrue: tKlausStatement;
      fStmtFalse: tKlausStatement;
    public
      property expr: tKlausExpression read fExpr;
      property stmtTrue: tKlausStatement read fStmtTrue;
      property stmtFalse: tKlausStatement read fStmtFalse;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Базовый класс инструкции цикла
  tKlausStmtLoop = class(tKlausStmtCtlStruct);

type
  // Инструкция цикла со счётчиком
  tKlausStmtFor = class(tKlausStmtLoop)
    private
      fCounter: tKlausVarDecl;
      fStart: tKlausExpression;
      fFinish: tKlausExpression;
      fReverse: boolean;
      fBody: tKlausStatement;
    public
      property counter: tKlausVarDecl read fCounter;
      property start: tKlausExpression read fStart;
      property finish: tKlausExpression read fFinish;
      property reverse: boolean read fReverse;
      property body: tKlausStatement read fBody;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Инструкция цикла "для каждого"
  tKlausStmtForEach = class(tKlausStmtLoop)
    private
      fKey: tKlausVarDecl;
      fDict: tKlausVarPath;
      fStart: tKlausExpression;
      fReverse: boolean;
      fBody: tKlausStatement;
    public
      property key: tKlausVarDecl read fKey;
      property dict: tKlausVarPath read fDict;
      property start: tKlausExpression read fStart;
      property reverse: boolean read fReverse;
      property body: tKlausStatement read fBody;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Инструкция цикла с предусловием
  tKlausStmtWhile = class(tKlausStmtLoop)
    private
      fExpr: tKlausExpression;
      fBody: tKlausStatement;
    public
      property expr: tKlausExpression read fExpr;
      property body: tKlausStatement read fBody;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Инструкция цикла с постусловием
  tKlausStmtRepeat = class(tKlausStmtLoop)
    private
      fExpr: tKlausExpression;
      fBody: tKlausStatement;
    public
      property expr: tKlausExpression read fExpr;
      property body: tKlausStatement read fBody;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  // Инструкция многовариантного ветвления
  tKlausStmtCase = class(tKlausStmtCtlStruct)
    private
      fExpr: tKlausExpression;
      fAccuracy: tKlausFloat;
      fItems: array of tKlausStatement;
      fItemMap: tKlausMap;
      fElseStmt: tKlausStatement;

      function getCount: integer;
      function getItems(idx: integer): tKlausStatement;
    protected
      procedure addItem(item: tKlausStatement); override;
      procedure removeItem(item: tKlausStatement); override;
    public
      property expr: tKlausExpression read fExpr;
      property accuracy: tKlausFloat read fAccuracy;
      property count: integer read getCount;
      property items[idx: integer]: tKlausStatement read getItems;
      property elseStmt: tKlausStatement read fElseStmt;

      constructor create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
      destructor  destroy; override;
      function  findItem(const key: tKlausSimpleValue): tKlausStatement;
      procedure run(frame: tKlausStackFrame); override;
  end;

type
  tPtrStrMap = specialize tFPGMap <pointer, string>;

type
  // Хранилище экземпляров встроенных объектов Клаус
  tKlausObjects = class
    private
      class var fObjNames: tPtrStrMap;
    public
      class procedure registerKlausObject(cls: tClass; objectName: string);
      class function  klausObjectName(cls: tClass): string;
    private
      fItems: tFPList;
      fCount: sizeInt;
      fFreeItems: array of tKlausObject;
      fFreeCount: sizeInt;

      procedure storeFreeHandle(h: tKlausObject);
      function  restoreFreeHandle: tKlausObject;
    public
      property count: sizeInt read fCount;

      constructor create;
      destructor  destroy; override;
      function  get(h: tKlausObject; const at: tSrcPoint): tObject;
      procedure put(h: tKlausObject; obj: tObject; const at: tSrcPoint);
      function  allocate(obj: tObject; const at: tSrcPoint): tKlausObject;
      function  release(h: tKlausObject; const at: tSrcPoint): tObject;
      procedure releaseAndFree(h: tKlausObject; const at: tSrcPoint);
      function  exists(h: tKlausObject): boolean;
  end;

type
  // Базовый класс хранилища значения переменной во фрейме стека вызовов
  // с поддержкой счётчика ссылок для копирования-при-записи
  tKlausVarValue = class(tObject)
    private
      fRefCount: integer;
      fDataType: tKlausTypeDef;
    public
      property dataType: tKlausTypeDef read fDataType;

      constructor create(dt: tKlausTypeDef); virtual;
      destructor  destroy; override;
      function  acquire: tKlausVarValue;
      procedure release;
      function  shared: boolean;
      function  canAssign(src: tKlausVarValue; strict: boolean = false): boolean; virtual;
      procedure assign(src: tKlausVarValue; const at: tSrcPoint); virtual; abstract;
      procedure clear; virtual; abstract;
      function  clone: tKlausVarValue; virtual;
      function  displayValue: string; virtual; abstract;
  end;

type
  // Хранилище значения скалярной переменной
  tKlausVarValueSimple = class(tKlausVarValue)
    private
      fSimple: tKlausSimpleValue;

      function  getSimple: tKlausSimpleValue;
    public
      property simple: tKlausSimpleValue read getSimple;

      constructor create(dt: tKlausTypeDef); override;
      procedure setSimple(const val: tKlausSimpleValue; const at: tSrcPoint);
      function  stringSetLength(len: tKlausInteger; const at: tSrcPoint): tKlausInteger;
      procedure stringAdd(const s: tKlausString; const at: tSrcPoint);
      procedure stringInsert(idx: tKlausInteger; const substr: tKlausString; const at: tSrcPoint);
      procedure stringDelete(idx, count: tKlausInteger; const at: tSrcPoint);
      procedure stringOverwrite(idx: tKlausInteger; const s: string; from, len: tKlausInteger; const at: tSrcPoint);
      procedure stringReplace(idx, count: tKlausInteger; const repl: string; const at: tSrcPoint);
      procedure assign(src: tKlausVarValue; const at: tSrcPoint); override;
      procedure clear; override;
      function  displayValue: string; override;
  end;

type
  // Хранилище значения переменной -- массива
  tKlausVarValueArray = class(tKlausVarValue)
    private
      fElmt: tFPList;

      function  getCount: integer;
      procedure setCount(val: integer);
    public
      property count: integer read getCount write setCount;

      constructor create(dt: tKlausTypeDef); override;
      destructor  destroy; override;
      function  getElmt(idx: integer; const at: tSrcPoint; mode: tKlausVarPathMode = vpmEvaluate): tKlausVarValue;
      procedure insert(idx: integer; val: tKlausVarValue; const at: tSrcPoint);
      procedure delete(idx, cnt: integer; const at: tSrcPoint);
      procedure clear; override;
      procedure assign(src: tKlausVarValue; const at: tSrcPoint); override;
      function  displayValue: string; override;
  end;

type
  // Хранилище значения переменной -- словаря
  tKlausVarValueDict = class(tKlausVarValue)
    private
      fMap: tKlausMap;

      function  getCount: integer;
      procedure checkKeyType(var key: tKlausSimpleValue; const at: tSrcPoint);
      procedure checkValueType(val: tKlausVarValue; const at: tSrcPoint);
    public
      property count: integer read getCount;

      constructor create(dt: tKlausTypeDef); override;
      destructor  destroy; override;
      procedure clear; override;
      function  has(key: tKlausSimpleValue; const at: tSrcPoint): boolean;
      function  findKey(key: tKlausSimpleValue; out idx: integer): boolean;
      function  getKeyAt(idx: integer; const at: tSrcPoint): tKlausSimpleValue;
      function  getElmt(key: tKlausSimpleValue; const at: tSrcPoint; mode: tKlausVarPathMode = vpmEvaluate): tKlausVarValue;
      function  getElmtAt(idx: integer; const at: tSrcPoint): tKlausVarValue;
      procedure setElmt(key: tKlausSimpleValue; val: tKlausVarValue; const at: tSrcPoint);
      procedure delete(idx: integer; const at: tSrcPoint);
      procedure delete(key: tKlausSimpleValue; const at: tSrcPoint);
      procedure assign(src: tKlausVarValue; const at: tSrcPoint); override;
      function  displayValue: string; override;
  end;

type
  // Хранилище значения переменной -- структуры
  tKlausVarValueStruct = class(tKlausVarValue)
    private
      fMembers: tStringList;
    public
      constructor create(dt: tKlausTypeDef); override;
      destructor  destroy; override;
      function  findMember(const name: string): tKlausVarValue;
      function  getMember(const name: string; const at: tSrcPoint): tKlausVarValue;
      procedure clear; override;
      procedure assign(src: tKlausVarValue; const at: tSrcPoint); override;
      function  displayValue: string; override;
  end;

type
  // Экземпляр переменной во фрейме стека вызовов
  tKlausVariable = class(tObject)
    private
      fOwner: tKlausStackFrame;
      fDecl: tKlausVarDecl;
      fValue: tKlausVarValue;
      fOutputBuffer: boolean;

      function getDisplayValue: string;
    public
      property owner: tKlausStackFrame read fOwner;
      property decl: tKlausVarDecl read fDecl;
      property value: tKlausVarValue read fValue;
      property displayValue: string read getDisplayValue;

      constructor create(aOwner: tKlausStackFrame; aDecl: tKlausVarDecl);
      destructor  destroy; override;
      procedure assignValue(val: tKlausVarValue; const at: tSrcPoint; release: boolean = false);
      procedure acquireValue(val: tKlausVarValue; const at: tSrcPoint; release: boolean = false);
      procedure acquireOutputBuffer(val: tKlausVarValue; const at: tSrcPoint);
      procedure ownValueNeeded;
  end;

type
  // Фрейм стека вызовов. Создаётся и помещается в вершину стека
  // при каждом вызове подпрограммы, в т.ч. при запуске основной программы,
  // а также при инициализации каждого модуля перед запуском программы.
  tKlausStackFrame = class(tObject)
    private
      fDestroying: boolean;
      fIndex: integer;
      fOwner: tKlausRuntime;
      fCallerPoint: tSrcPoint;
      fRoutine: tKlausRoutine;
      fVars: tStringList;
      fReleased: tFPList;

      procedure addVariable(v: tKlausVariable);
      function  getVarCount: integer;
      function  getVars(idx: integer): tKlausVariable;
      procedure removeVariable(v: tKlausVariable);
    public
      property owner: tKlausRuntime read fOwner;
      property index: integer read fIndex;
      property callerPoint: tSrcPoint read fCallerPoint;
      property routine: tKlausRoutine read fRoutine;
      property varCount: integer read getVarCount;
      property vars[idx: integer]: tKlausVariable read getVars;

      constructor create(aOwner: tKlausRuntime; aRoutine: tKlausRoutine; at: tSrcPoint);
      destructor  destroy; override;
      procedure beforeDestruction; override;
      function  upperFrame: tKlausStackFrame;
      procedure deferRelease(val: tKlausVarValue);
      function  varByName(const n: string; const at: tSrcPoint): tKlausVariable;
      function  varByDecl(d: tKlausVarDecl; const at: tSrcPoint): tKlausVariable;
      procedure assignVarValue(dest: tKlausVarPath; source: tKlausExpression; op: tKlausBinaryOperation = kboInvalid);
      procedure assignVarValue(dest: tKlausVariable; source: tKlausExpression);
      procedure call(callee: tKlausRoutine; const params: array of tKlausExpression; out rslt: tKlausVarValue; const at: tSrcPoint);
  end;

type
  // Обработчик перевода терминала в raw-режим
  tKlausSetRawMethod = procedure(raw: boolean) of object;

  // Обработчик проверки готовности символа в стандартном потоке
  tKlausHasCharMethod = function: boolean of object;

  // Обработчик чтения символа из стандартного потока
  tKlausReadCharMethod = procedure(out c: u8Char) of object;

  // Обработчик записи данных в стандартный поток
  tKlausWriteMethod = procedure(const s: string) of object;

  // Комплект процедур ввода-вывода
  tKlausInOutMethods = record
    setRaw: tKlausSetRawMethod;
    hasChar: tKlausHasCharMethod;
    readChar: tKlausReadCharMethod;
    writeOut: tKlausWriteMethod;
    writeErr: tKlausWriteMethod;
  end;

type
  tKlausEventType = (
    ketKeyDown, ketKeyUp, ketChar,
    ketMouseDown, ketMouseUp, ketMouseWheel,
    ketMouseEnter, ketMouseLeave, ketMouseMove);
  tKlausEventTypes = set of tKlausEventType;

type
  tKlausKeyState = ssShift..ssDouble;
  tKlausKeyStates = set of tKlausKeyState;

const
  klausValidKeyStates = [ssShift..ssDouble];

const
  klausEventBufferSize = 512;

type
  tKlausEvent = record
    what: tKlausEventType;
    code: longInt;
    shift: tKlausKeyStates;
    point: packed record
      x: smallInt;
      y: smallInt;
    end;
  end;

const
  iidKlausEventQueue = '{DC37E306-E479-4D92-9F84-8FBAF341C0AB}';

type
  iKlausEventQueue = interface[iidKlausEventQueue]
    procedure eventSubscribe(const what: tKlausEventTypes);
    function  eventExists: boolean;
    function  eventGet(out evt: tKlausEvent): boolean;
    function  eventCount: integer;
    function  eventPeek(index: integer = 0): tKlausEvent;
  end;

const
  klausDefaultCanvasWidth  = 800;
  klausDefaultCanvasHeight = 600;

type
  tKlausPenProp = (kppColor, kppWidth, kppStyle);
  tKlausPenProps = set of tKlausPenProp;

type
  tKlausBrushProp = (kbpColor, kbpStyle);
  tKlausBrushProps = set of tKlausBrushProp;

type
  tKlausFontProp = (kfpName, kfpSize, kfpStyle, kfpColor);
  tKlausFontProps = set of tKlausFontProp;

type
  tKlausPointArray = array of tPoint;

type
  // Объект-связка с окном графического вывода
  tKlausCanvasLinkClass = class of tKlausCanvasLink;
  tKlausCanvasLink = class(tObject)
    private
      fRuntime: tKlausRuntime;
      fNestCount: integer;
    protected
      function  getCanvas: tCanvas; virtual; abstract;
      procedure doInvalidate; virtual; abstract;
    public
      property runtime: tKlausRuntime read fRuntime;
      property canvas: tCanvas read getCanvas;

      constructor create(aRuntime: tKlausRuntime; const cap: string = ''); virtual;
      procedure invalidate;
      procedure beginPaint;
      procedure endPaint;
      function  getSize: tSize; virtual; abstract;
      function  setSize(val: tSize): tSize; virtual; abstract;
      procedure setPenProps(what: tKlausPenProps; color: tColor; width: integer; style: tPenStyle); virtual; abstract;
      procedure setBrushProps(what: tKlausBrushProps; color: tColor; style: tBrushStyle); virtual; abstract;
      procedure setFontProps(what: tKlausFontProps; const name: string; size: integer; style: tFontStyles; color: tColor); virtual; abstract;
      function  getPoint(x, y: integer): tColor; virtual; abstract;
      function  setPoint(x, y: integer; color: tColor): tColor; virtual; abstract;
      procedure ellipse(x1, y1, x2, y2: integer); virtual; abstract;
      procedure arc(x1, y1, x2, y2, start, finish: integer); virtual; abstract;
      procedure sector(x1, y1, x2, y2, start, finish: integer); virtual; abstract;
      procedure chord(x1, y1, x2, y2, start, finish: integer); virtual; abstract;
      procedure line(x1, y1, x2, y2: integer); virtual; abstract;
      procedure polyLine(points: tKlausPointArray); virtual; abstract;
      procedure rectangle(x1, y1, x2, y2: integer); virtual; abstract;
      procedure roundRect(x1, y1, x2, y2, rx, ry: integer); virtual; abstract;
      procedure polygone(points: tKlausPointArray); virtual; abstract;
      function  textSize(const s: string): tPoint; virtual; abstract;
      function  textOut(x, y: integer; const s: string): tPoint; virtual; abstract;
      procedure clipRect(x1, y1, x2, y2: integer); virtual; abstract;
      procedure setClipping(val: boolean); virtual; abstract;
      procedure draw(x, y: integer; picture: tKlausCanvasLink); virtual; abstract;
      procedure copyFrom(source: tKlausCanvasLink; x1, y1, x2, y2: integer); virtual; abstract;
      procedure loadFromFile(const fileName: string); virtual; abstract;
      procedure saveToFile(const fileName: string); virtual; abstract;
  end;

var
  klausCanvasLinkClass: tKlausCanvasLinkClass = nil;
  klausPictureLinkClass: tKlausCanvasLinkClass = nil;

type
  tSynchronizeMethod = procedure(method: tThreadMethod) of object;

type
  // Экземпляр исполняемой программы
  tKlausRuntime = class(tObject)
    private
      fSource: tKlausSource;
      fObjects: tKlausObjects;
      fStack: tFPList;
      fMaxStackSize: integer;
      fExitCode: integer;
      fStdIO: tKlausInOutMethods;
      fOnSync: tSynchronizeMethod;

      function  getStackCount: integer;
      function  getStackFrames(idx: integer): tKlausStackFrame;
      function  getStackTop: tKlausStackFrame;
      procedure push(fr: tKlausStackFrame);
      procedure pop(fr: tKlausStackFrame);
    public
      property source: tKlausSource read fSource;
      property objects: tKlausObjects read fObjects;
      property maxStackSize: integer read fMaxStackSize write fMaxStackSize;
      property stackCount: integer read getStackCount;
      property stackFrames[idx: integer]: tKlausStackFrame read getStackFrames;
      property stackTop: tKlausStackFrame read getStackTop;
      property exitCode: integer read fExitCode write fExitCode;
      property onSync: tSynchronizeMethod read fOnSync write fOnSync;

      constructor create(aSource: tKlausSource);
      destructor  destroy; override;
      procedure setInOutMethods(const io: tKlausInOutMethods);
      procedure readStdIn(out c: u8Char);
      procedure writeStdOut(const s: string);
      procedure writeStdErr(const s: string);
      procedure setRawInputMode(raw: boolean);
      function  inputAvailable: boolean;
      procedure run(const fileName: string; args: tStrings = nil);
      function  evaluate(fr: tKlausStackFrame; expr: string; allowCalls: boolean): string;
      procedure synchronize(method: tThreadMethod);
  end;

type
  // Исключение, вызываемое при прерывании выполнения программы в режиме отладки
  eKlausDebugTerminated = class(tObject);

  // Исключение языка Клаус.
  // Такие исключения необходимо перехватывать и вызывать finalizeData в пределах
  // жизненного цикла экземпляра tKlausRuntime, чтобы не было повисших ссылок и генералов.
  eKlausLangException = class(exception)
    private
      fLine: integer;
      fPos: integer;
      fName: string;
      fDecl: tKlausExceptDecl;
      fData: tKlausVarValueStruct;
    public
      property line: integer read fLine;
      property pos: integer read fPos;
      property name: string read fName;
      property decl: tKlausExceptDecl read fDecl;
      property data: tKlausVarValueStruct read fData;

      constructor create(const aMsg: string; aDecl: tKlausExceptDecl; aData: tKlausVarValueStruct; aLine, aPos: integer);
      destructor  destroy; override;
      procedure finalizeData;
  end;

  // Исключение, используемое инструкцией "вернуть"
  eKlausReturn = class(tObject);

  // Исключение, используемое инструкцией "завершить"
  eKlausHalt = class(tObject)
    public
      code: integer;
      constructor create(exitCode: integer);
  end;

  // Исключение, используемое инструкцией "прервать"
  eKlausBreak = class(tObject);

  // Исключение, используемое инструкцией "продолжить"
  eKlausContinue = class(tObject);

  // Исключение, используемое инструкцией "бросить"
  eKlausThrow = class(tObject);

  // Ошибка ввода-вывода
  eKlausIOError = class(exception);

type
  // структура с информацией о точке останова
  tKlausBreakpoint = record
    enabled: boolean;
    fileName: string;
    line: integer;
  end;
  tKlausBreakpoints = array of tKlausBreakpoint;

type
  // Событие, которое поток отладчика вызывает для привязки к стандартным потокам ввода-вывода
  tKlausAssignIOEvent = procedure(sender: tObject; var io: tKlausInOutMethods) of object;

type
  // Нить для запуска программы в режиме отладки
  tKlausDebugThread = class(tThread)
    private
      fLatch: tRTLCriticalSection;
      fStepEvt: pRtlEvent;
      fInputEvt: pRtlEvent;
      fStepMode: boolean;
      fStep: boolean;
      fState: tKlausDebugState;
      fTerminated: boolean;
      fSource: tKlausSource;
      fFileName: string;
      fArgs: tStrings;
      fRuntime: tKlausRuntime;
      fWaitForInput: boolean;
      fInputDone: boolean;
      fExecPoint: tSrcPoint;
      fLastStep: integer;
      fStepOver: boolean;
      fBreakpoints: tKlausBreakpoints;
      fStdIO: tKlausInOutMethods;
      fOnAssignStdIO: tKlausAssignIOEvent;
      fOnStateChange: tNotifyEvent;

      procedure lock;
      procedure unlock;
      function  getState: tKlausDebugState;
      procedure setState(val: tKlausDebugState);
      function  getStepMode: boolean;
      procedure setStepMode(val: boolean);
      function  getWaitForInput: boolean;
      procedure setWaitForInput(val: boolean);
      function  getTerminated: boolean;
      procedure setTerminated(val: boolean);
      function  getExecPoint: tSrcPoint;
      procedure setExecPoint(frame: tKlausStackFrame; val: tSrcPoint);
      function  getRuntime: tKlausRuntime;
      procedure setRuntime(val: tKlausRuntime);
      procedure callOnStateChange;
    protected
      property terminated: boolean read getTerminated write setTerminated;

      procedure execute; override;
      procedure doTerminate; override;
      procedure doStateChange; virtual;
      procedure doSetRaw(raw: boolean);
      function  doHasChar: boolean;
      procedure doReadChar(out c: u8Char);
      procedure doWriteOut(const s: string);
      procedure doWriteErr(const s: string);
    public
      property returnValue;
      property source: tKlausSource read fSource;
      property fileName: string read fFileName;
      property args: tStrings read fArgs;
      property state: tKlausDebugState read getState;
      property runtime: tKlausRuntime read getRuntime;
      property execPoint: tSrcPoint read getExecPoint;
      property stepMode: boolean read getStepMode write setStepMode;
      property waitForInput: boolean read getWaitForInput write setWaitForInput;
      property onAssignStdIO: tKlausAssignIOEvent read fOnAssignStdIO write fOnAssignStdIO;
      property onStateChange: tNotifyEvent read fOnStateChange write fOnStateChange;

      constructor create(aSource: tKlausSource; aFileName: string; aArgs: tStrings);
      destructor  destroy; override;
      procedure checkTerminated;
      procedure setBreakpoints(bp: tKlausBreakpoints);
      procedure checkBreakpoint;
      procedure waitForStep(frame: tKlausStackFrame);
      procedure step(over: boolean);
      procedure inputNeeded;
      procedure inputDone;
      procedure terminate;
  end;

// Вызывает v.release (с проверкой на nil) и обнуляет ссылку
procedure releaseAndNil(var v: tKlausVarValue);

// Инструкции Клаус должны вызывать эту процедуру перед их выполнением, чтобы были
// возможны работа в пошаговом режиме и прерывание программы, запущенной отладчиком
procedure klausDebuggerStep(frame: tKlausStackFrame; execPoint: tSrcPoint);

threadvar
  // Нить выполнения программы в отладочном режиме
  klausDebugThread: tKlausDebugThread;

implementation

uses
  Math, KlausUtils, KlausUnitSystem
  {$ifdef enableLogging}, KlausLog{$endif};

const
  // Имя скрытой переменной -- выходного параметра функции, в который
  // инструкция "вернуть" помещает возвращаемое значение.
  klausResultParamName = '$result';

  // Имя поля, содержащего текст сообщения об ошибке,
  // в структуре, содержащей значения параметров исключения языка.
  klausExceptionMessageFieldName = 'текст';

resourcestring
  strEmptyValue = '(пусто)';
  strProgram = 'программа';
  strUnit = 'модуль';
  strProcedure = 'процедура';
  strFunction = 'функция';
  strReadError = 'Ошибка чтения данных.';
  strWriteError = 'Ошибка записи данных.';
  strOutputNotOpen = 'Поток вывода не был открыт.';
  strInputNotOpen = 'Поток ввода не был открыт.';
  strKlausException = '%s: %s';

{$ifdef enableLogging}
// Пишет в source.log исходный текст программы, заново собранный
// по синтаксическому дереву. Если всё работает правильно, то этот
// текст должен полностью совпадать с исходным, с той оговоркой,
// что комментарии в него не попадут.
procedure writeSourceLog(rule: tKlausSrcNodeRule);
var
  s: string = '';
  l: integer = 1;
  li: tKlausLexInfo;
  b: tKlausSyntaxBrowser;
begin
  logReset('source');
  b := tKlausSyntaxBrowser.create(rule);
  try
    while b.cur <> nil do begin
      while b.cur is tKlausSrcNodeRule do b.next;
      if b.cur = nil then break;
      li := b.lex;
      while l < li.line do begin
        logln('source', '%s', [s + #10]);
        s := '';
        l += 1;
      end;
      while u8CharCount(s) < li.pos-1 do s += ' ';
      s += li.text;
      b.next;
    end;
    if s <> '' then logln('source', '%s', [s + #10]);
  finally
    freeAndNil(b);
  end;
end;
{$endif}

// Вызывает v.release (с проверкой на nil) и обнуляет ссылку
procedure releaseAndNil(var v: tKlausVarValue);
begin
  if assigned(v) then begin
    v.release;
    v := nil;
  end;
end;

// Вызывается инструкциями Клаус при их выполнении
// для работы в пошаговом режиме и прерывания отладки
procedure klausDebuggerStep(frame: tKlausStackFrame; execPoint: tSrcPoint);
begin
  if klausDebugThread = nil then exit;
  klausDebugThread.setExecPoint(frame, execPoint);
  klausDebugThread.checkTerminated;
  klausDebugThread.checkBreakpoint;
  klausDebugThread.waitForStep(frame);
end;

{ tKlausMap }

constructor tKlausMap.create(aKeyType: tKlausSimpleType; aAccuracy: tKlausFloat);
begin
  fKeyType := aKeyType;
  fAccuracy := aAccuracy;
  inherited create(sizeOf(tKlausSimpleValue), sizeOf(tKlausVarValue));
end;

procedure tKlausMap.copyItem(src, dest: pointer);
begin
  copyKey(src, dest);
  copyData(pByte(src)+keySize, pByte(dest)+keySize);
end;

procedure tKlausMap.copyKey(src, dest: pointer);
begin
  tKlausSimpleValue(dest^) := tKlausSimpleValue(src^);
end;

procedure tKlausMap.copyData(src, dest: pointer);
begin
  tKlausVarValue(dest^) := tKlausVarValue(src^);
end;

procedure tKlausMap.deref(item: pointer);
begin
  finalize(tKlausSimpleValue(item^));
end;

function tKlausMap.getKey(index: integer): tKlausSimpleValue;
begin
  result := tKlausSimpleValue(inherited getKey(index)^);
end;

function tKlausMap.getData(index: integer): tObject;
begin
  result := tObject(inherited getData(index)^);
end;

function tKlausMap.getKeyData(const aKey: tKlausSimpleValue): tObject;
begin
  result := tObject(inherited getKeyData(@aKey)^);
end;

function tKlausMap.keyCompare(key1, key2: pointer): integer;
begin
  assert(pKlausSimpleValue(key1)^.dataType = pKlausSimpleValue(key2)^.dataType, 'Dissimilar key data in a tKlausMap');
  result := klausCompare(pKlausSimpleValue(key1)^, pKlausSimpleValue(key2)^, accuracy, zeroSrcPt);
end;

procedure tKlausMap.InitOnPtrCompare;
begin
  onKeyPtrCompare := @keyCompare;
  onDataPtrCompare := nil;
end;

procedure tKlausMap.putKey(index: integer; const newKey: tKlausSimpleValue);
begin
  assert(fKeyType = newKey.dataType, 'Key type mismatch in a tKlausMap');
  inherited putKey(index, @newKey);
end;

procedure tKlausMap.putData(index: integer; const newData: tObject);
begin
  inherited putData(index, @newData);
end;

procedure tKlausMap.putKeyData(const aKey: tKlausSimpleValue; const newData: tObject);
begin
  assert(fKeyType = aKey.dataType, 'Key type mismatch in a tKlausMap');
  inherited putKeyData(@aKey, @newData);
end;

function tKlausMap.add(const aKey: tKlausSimpleValue): integer;
begin
  assert(fKeyType = aKey.dataType, 'Key type mismatch in a tKlausMap');
  result := inherited add(@aKey);
end;

function tKlausMap.add(const aKey: tKlausSimpleValue; const aData: tObject): integer;
begin
  assert(fKeyType = aKey.dataType, 'Key type mismatch in a tKlausMap');
  result := inherited add(@aKey, @aData);
end;

function tKlausMap.find(const aKey: tKlausSimpleValue; out index: integer): boolean;
begin
  assert(fKeyType = aKey.dataType, 'Key type mismatch in a tKlausMap');
  result := inherited find(@aKey, index);
end;

function tKlausMap.tryGetData(const aKey: tKlausSimpleValue; out aData: tObject): boolean;
var
  i: integer;
begin
  i := indexOf(aKey);
  result := i >= 0;
  if not result then aData := nil
  else aData := tObject(inherited getData(i)^);
end;

procedure tKlausMap.addOrSetData(const aKey: tKlausSimpleValue; const aData: tObject);
begin
  assert(fKeyType = aKey.dataType, 'Key type mismatch in a tKlausMap');
  inherited putKeyData(@aKey, @aData);
end;

function tKlausMap.indexOf(const aKey: tKlausSimpleValue): integer;
begin
  assert(fKeyType = aKey.dataType, 'Key type mismatch in a tKlausMap');
  result := inherited indexOf(@aKey);
end;

function tKlausMap.indexOfData(const aData: tObject): integer;
var
  item: pointer;
begin
  result := 0;
  item := first + keySize;
  while (result < count) and (tKlausVarValue(item^) <> aData) do begin
    inc(result);
    item := pByte(item) + itemSize;
  end;
  if result = count then result := -1;
end;

procedure tKlausMap.insertKey(index: integer; const aKey: tKlausSimpleValue);
begin
  assert(fKeyType = aKey.dataType, 'Key type mismatch in a tKlausMap');
  inherited insertKey(index, @aKey);
end;

procedure tKlausMap.insertKeyData(index: integer; const aKey: tKlausSimpleValue; const aData: tObject);
begin
  assert(fKeyType = aKey.dataType, 'Key type mismatch in a tKlausMap');
  inherited insertKeyData(index, @aKey, @aData);
end;

function tKlausMap.remove(const aKey: tKlausSimpleValue): integer;
begin
  result := inherited remove(@aKey);
end;

{ eKlausLangException }

constructor eKlausLangException.create(const aMsg: string; aDecl: tKlausExceptDecl; aData: tKlausVarValueStruct; aLine, aPos: integer);
var
  fv: tKlausVarValueSimple;
begin
  inherited create(aMsg);
  fLine := aLine;
  fPos := aPos;
  fDecl := aDecl;
  fName := decl.name;
  fData := aData;
  if fData = nil then begin
    fData := tKlausVarValueStruct.create(decl.data);
    fv := fData.getMember(klausExceptionMessageFieldName, zeroSrcPt) as tKlausVarValueSimple;
    fv.setSimple(klausSimple(aMsg), zeroSrcPt);
  end;
end;

destructor eKlausLangException.destroy;
begin
  finalizeData;
  inherited destroy;
end;

procedure eKlausLangException.finalizeData;
begin
  if fData <> nil then fData.release;
  fData := nil;
  fDecl := nil;
end;

{ eKlausHalt }

constructor eKlausHalt.create(exitCode: integer);
begin
  inherited create;
  code := exitCode;
end;

{ tKlausVarPath }

constructor tKlausVarPath.create(context: tKlausStatement; b: tKlausSyntaxBrowser);
var
  idx: integer = 0;
  li: tKlausLexInfo;
  d: tKlausDecl;
  expr: tKlausExpression;
begin
  inherited create;
  repeat
    b.next;
    b.check('var_ref');
    b.next;
    li := b.get(klxID);
    setLength(fSteps, idx+1);
    fSteps[idx].point := srcPoint(b.lex);
    fSteps[idx].name := li.text;
    if idx = 0 then begin
      d := context.routine.find(fSteps[idx].name, knsGlobal);
      if not (d is tKlausValueDecl) then
        raise eKlausError.createFmt(ercValueDeclRequired, li.line, li.pos, [li.text]);
      fDecl := d as tKlausValueDecl;
    end;
    b.next;
    while b.check(klsBktOpen, false) do begin
      b.next;
      b.check('expression');
      expr := context.routine.createExpression(context, b);
      with fSteps[idx] do begin
        setLength(indices, length(indices)+1);
        indices[length(indices)-1] := expr;
      end;
      b.next;
      b.check(klsBktClose);
      b.next;
    end;
    idx += 1;
  until not b.check(klsDot, false);
  b.pause;
end;

destructor tKlausVarPath.destroy;
var
  i, j: integer;
begin
  for i := stepCount-1 downto 0 do
    for j := length(steps[i].indices)-1 downto 0 do
      freeAndNil(steps[i].indices[j]);
  inherited destroy;
end;

function tKlausVarPath.getStepCount: integer;
begin
  result := length(fSteps);
end;

function tKlausVarPath.getIsConstant: boolean;
begin
  result := decl is tKlausConstDecl;
end;

function tKlausVarPath.getIsVariable: boolean;
begin
  result := (decl is tKlausVarDecl) and (stepCount = 1) and (length(steps[0].indices) = 0);
end;

function tKlausVarPath.getSteps(idx: integer): tKlausVarPathStep;
begin
  assert((idx >= 0) and (idx < stepCount), 'Invalid item index');
  result := fSteps[idx];
end;

function tKlausVarPath.getPoint: tSrcPoint;
begin
  result := steps[0].point;
end;

function tKlausVarPath.resultTypeDef: tKlausTypeDef;
var
  i: integer;
  idx: integer = 0;
  kt: tKlausSimpleType;
  m: tKlausStructMember;
begin
  result := decl.dataType;
  repeat
    if idx > 0 then begin
      if not (result is tKlausTypeDefStruct) then
        raise eKlausError.create(ercIllegalFieldQualifier, steps[idx].point);
      m := (result as tKlausTypeDefStruct).member[steps[idx].name];
      if m = nil then raise eKlausError.createFmt(ercStructMemberNotFound, steps[idx].point, [steps[idx].name]);
      result := m.dataType;
    end;
    for i := 0 to length(steps[idx].indices)-1 do begin
      if result is tKlausTypeDefArray then begin
        if steps[idx].indices[i].resultType <> kdtInteger then
          raise eKlausError.create(ercIndexMustBeInteger, steps[idx].point);
        result := (result as tKlausTypeDefArray).elmtType;
      end else if result is tKlausTypeDefDict then begin
        kt := (result as tKlausTypeDefDict).keyType;
        if not klausCanAssign(steps[idx].indices[i].resultType, kt) then
          raise eKlausError.create(ercTypeMismatch, steps[idx].point);
        result := (result as tKlausTypeDefDict).valueType;
      end else
        raise eKlausError.create(ercIllegalIndexQualifier, steps[idx].point);
    end;
    idx += 1;
  until idx >= stepCount;
end;

function tKlausVarPath.evaluate(frame: tKlausStackFrame; mode: tKlausVarPathMode; allowCalls: boolean): tKlausVarValue;
var
  i: integer;
  idx: integer = 0;
  kt: tKlausSimpleType;
  sv: tKlausSimpleValue;
begin
  if decl is tKlausConstDecl then begin
    if mode = vpmAsgnTarget then raise eKlausError.create(ercConstAsgnTarget, point.line, point.pos);
    result := (decl as tKlausConstDecl).value;
  end else
    result := frame.varByDecl(decl as tKlausVarDecl, point).value;
  repeat
    if idx > 0 then begin
      if not (result is tKlausVarValueStruct) then
        raise eKlausError.create(ercIllegalFieldQualifier, steps[idx].point.line, steps[idx].point.pos);
      result := (result as tKlausVarValueStruct).getMember(steps[idx].name, steps[idx].point);
    end;
    for i := 0 to length(steps[idx].indices)-1 do begin
      if result is tKlausVarValueArray then begin
        sv := steps[idx].indices[i].evaluate(frame, allowCalls);
        if sv.dataType <> kdtInteger then
          raise eKlausError.create(ercIndexMustBeInteger, steps[idx].point.line, steps[idx].point.pos);
        result := (result as tKlausVarValueArray).getElmt(sv.iValue, steps[idx].point, mode);
        if result = nil then exit;
      end else if result is tKlausVarValueDict then begin
        kt := ((result as tKlausVarValueDict).dataType as tKlausTypeDefDict).keyType;
        sv := steps[idx].indices[i].evaluate(frame, allowCalls);
        if klausCanAssign(sv.dataType, kt) then sv := klausTypecast(sv, kt, steps[idx].point)
        else raise eKlausError.create(ercTypeMismatch, steps[idx].point);
        result := (result as tKlausVarValueDict).getElmt(sv, steps[idx].point, mode);
        if result = nil then exit;
      end else
        raise eKlausError.create(ercIllegalIndexQualifier, steps[idx].point.line, steps[idx].point.pos);
    end;
    idx += 1;
  until idx >= stepCount;
end;

function tKlausVarPath.evaluate: tKlausVarValue;
begin
  if not (decl is tKlausConstDecl)
  or (stepCount > 1) or (length(steps[0].indices) > 0) then
    raise eKlausError.create(ercNotConstantValue, point.line, point.pos);
  result := (decl as tKlausConstDecl).value;
end;

{ tKlausCall }

constructor tKlausCall.create(context: tKlausStatement; b: tKlausSyntaxBrowser);
var
  idx: integer = -1;
  li: tKlausLexInfo;
  d: tKlausDecl;
  dt: tKlausTypeDef;
  expr: tKlausExpression;
begin
  inherited create;
  b.next;
  li := b.get(klxID);
  fPoint := srcPoint(li);
  d := context.routine.find(li.text, knsGlobal);
  if not (d is tKlausProcDecl) then
    raise eKlausError.createFmt(ercSubroutineRequired, li.line, li.pos, [li.text]);
  fCallee := d as tKlausProcDecl;
  b.next;
  b.check(klsParOpen);
  repeat
    b.next;
    if b.check('expression', false) then begin
      idx := length(fParams);
      if idx >= callee.paramCount then dt := nil
      else dt := callee.params[idx].dataType;
      expr := context.routine.createExpression(context, b, dt);
      setLength(fParams, idx+1);
      fParams[idx] := expr;
      b.next;
    end;
    if b.check(klsParClose, idx < 0) then break
    else b.check(klsComma);
  until false;
  checkParamTypes;
end;

destructor tKlausCall.destroy;
var
  i: integer;
begin
  for i := paramCount-1 downto 0 do params[i].free;
  inherited destroy;
end;

procedure tKlausCall.checkParamTypes;
begin
  callee.checkCallParamTypes(fParams, point);
end;

function tKlausCall.getParamCount: integer;
begin
  result := length(fParams);
end;

function tKlausCall.getParams(idx: integer): tKlausExpression;
begin
  assert((idx >= 0) and (idx < paramCount), 'Invalid item index');
  result := fParams[idx];
end;

function tKlausCall.resultTypeDef: tKlausTypeDef;
begin
  if callee.retValue = nil then result := nil
  else result := callee.retValue.dataType;
end;

procedure tKlausCall.perform(frame: tKlausStackFrame; out rslt: tKlausVarValue);
begin
  frame.call(fCallee, fParams, rslt, point);
end;

{ tKlausOperand }

constructor tKlausOperand.create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint);
begin
  inherited create;
  fParent := nil;
  fStmt := aStmt;
  fUop := aUop;
  fPoint := aPoint;
end;

function tKlausOperand.resultType: tKlausDataType;
begin
  result := getResultType;
  if (uop <> kuoInvalid) then
    result := klausUnOp[uop].resultType(result, point);
end;

function tKlausOperand.resultTypeDef: tKlausTypeDef;
begin
  result := routine.source.simpleTypes[resultType];
end;

function tKlausOperand.getRoutine: tKlausRoutine;
begin
  result := fStmt.routine;
end;

function tKlausOperand.evaluate: tKlausSimpleValue;
begin
  result := doEvaluate;
  if (uop <> kuoInvalid) then result := klausUnOp[uop].evaluate(result, point);
end;

function tKlausOperand.evaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue;
begin
  result := doEvaluate(frame, allowCalls);
  if (uop <> kuoInvalid) then result := klausUnOp[uop].evaluate(result, point);
end;

function tKlausOperand.acquireVarValue: tKlausVarValue;
begin
  result := nil;
end;

function tKlausOperand.acquireVarValue(frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue;
begin
  result := nil;
end;

function tKlausOperand.doEvaluate: tKlausSimpleValue;
begin
  result := klausZeroValue(kdtString);
  raise eKlausError.create(ercNotConstantValue, point.line, point.pos);
end;

{ tKlausOpndLiteral }

constructor tKlausOpndLiteral.create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  inherited create(aStmt, aUop, aPoint);
  b.next;
  fValue := klausLiteralValue(b.lex);
end;

function tKlausOpndLiteral.getResultType: tKlausDataType;
begin
  result := value.dataType;
end;

function tKlausOpndLiteral.doEvaluate: tKlausSimpleValue;
begin
  result := value;
end;

function tKlausOpndLiteral.doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue;
begin
  result := value;
end;

{ tKlausOpndTypecast }

constructor tKlausOpndTypecast.create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  kwd: tKlausKeyword;
begin
  inherited create(aStmt, aUop, aPoint);
  b.next;
  b.check('simple_type');
  b.next;
  kwd := b.check(klausSimpleTypeKwd);
  fDestType := klausKwdToSimpleType[kwd];
  b.next;
  b.check(klsParOpen);
  b.next;
  b.check('expression');
  fExpr := routine.createExpression(stmt, b);
  fExpr.fParent := self;
  b.next;
  b.check(klsParClose);
 end;

destructor tKlausOpndTypecast.destroy;
begin
  freeAndNil(fExpr);
  inherited destroy;
end;

function tKlausOpndTypecast.getResultType: tKlausDataType;
begin
  if not klausCanTypecast(expr.resultType, destType) then
    raise eKlausError.create(ercInvalidTypecast, point.line, point.pos);
  result := destType;
end;

function tKlausOpndTypecast.doEvaluate: tKlausSimpleValue;
begin
  result := klausTypecast(expr.evaluate, destType, point);
end;

function tKlausOpndTypecast.doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue;
begin
  result := klausTypecast(expr.evaluate(frame, allowCalls), destType, point);
end;

{ tKlausOpndVarPath }

constructor tKlausOpndVarPath.create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  inherited create(aStmt, aUop, aPoint);
  fPath := tKlausVarPath.create(aStmt, b);
end;

destructor tKlausOpndVarPath.destroy;
begin
  freeAndNil(fPath);
  inherited destroy;
end;

function tKlausOpndVarPath.resultTypeDef: tKlausTypeDef;
begin
  result := fPath.resultTypeDef;
end;

function tKlausOpndVarPath.acquireVarValue: tKlausVarValue;
begin
  if uop <> kuoInvalid then exit(nil);
  result := path.evaluate.acquire;
end;

function tKlausOpndVarPath.acquireVarValue(frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue;
begin
  if uop <> kuoInvalid then exit(nil);
  result := path.evaluate(frame, vpmEvaluate, allowCalls).acquire;
end;

function tKlausOpndVarPath.getResultType: tKlausDataType;
begin
  result := fPath.resultTypeDef.dataType;
end;

function tKlausOpndVarPath.doEvaluate: tKlausSimpleValue;
var
  v: tKlausVarValue;
begin
  v := fPath.evaluate;
  if not (v is tKlausVarValueSimple) then raise eKlausError.create(ercTypeMismatch, point.line, point.pos);
  result := (v as tKlausVarValueSimple).simple;
end;

function tKlausOpndVarPath.doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue;
var
  v: tKlausVarValue;
begin
  v := fPath.evaluate(frame, vpmEvaluate, allowCalls);
  if not (v is tKlausVarValueSimple) then raise eKlausError.create(ercTypeMismatch, point);
  result := (v as tKlausVarValueSimple).simple;
end;

{ tKlausOpndCompound }

constructor tKlausOpndCompound.create(aStmt: tKlausStatement; aTypeDef: tKlausTypeDef; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  inherited create(aStmt, kuoInvalid, aPoint);
  if aTypeDef.dataType <> kdtComplex then raise eKlausError.create(ercTypeMismatch, aPoint);
  fTypeDef := aTypeDef;
  parseLiteral(b);
end;

function tKlausOpndCompound.getResultType: tKlausDataType;
begin
  result := kdtComplex;
end;

function tKlausOpndCompound.doEvaluate: tKlausSimpleValue;
begin
  result := klausZeroValue(kdtString);
  raise eKlausError.create(ercTypeMismatch, point);
end;

function tKlausOpndCompound.doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue;
begin
  result := klausZeroValue(kdtString);
  raise eKlausError.create(ercTypeMismatch, point);
end;

function tKlausOpndCompound.resultTypeDef: tKlausTypeDef;
begin
  result := typeDef;
end;

function tKlausOpndCompound.acquireVarValue: tKlausVarValue;
begin
  result := doAcquireVarValue(false, nil, false);
end;

function tKlausOpndCompound.acquireVarValue(frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue;
begin
  result := doAcquireVarValue(true, frame, allowCalls);
end;

{ tKlausOpndArray }

constructor tKlausOpndArray.create(aStmt: tKlausStatement; aTypeDef: tKlausTypeDef; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  assert(aTypeDef is tKlausTypeDefArray, 'Invalid compound literal class.');
  inherited create(aStmt, aTypeDef, aPoint, b);
end;

destructor tKlausOpndArray.destroy;
var
  i: integer;
begin
  for i := 0 to count-1 do elmt[i].free;
  inherited destroy;
end;

function tKlausOpndArray.getCount: integer;
begin
  result := length(fElmt);
end;

function tKlausOpndArray.getElmt(idx: integer): tKlausExpression;
begin
  assert((idx >= 0) and (idx < count), 'Invalid item index.');
  result := fElmt[idx];
end;

function tKlausOpndArray.doAcquireVarValue(runTime: boolean; frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue;
var
  i: integer;
  rslt: tKlausVarValueArray;
  e: tKlausVarValue;
  sv: tKlausVarValue;
  ssv: tKlausSimpleValue;
  p: tSrcPoint;
begin
  rslt := tKlausVarValueArray.create(typeDef);
  try
    rslt.count := count;
    for i := 0 to count-1 do begin
      p := elmt[i].point;
      e := rslt.getElmt(i, p, vpmAsgnTarget);
      if not runTime then sv := elmt[i].acquireVarValue
      else sv := elmt[i].acquireVarValue(frame, allowCalls);
      if sv <> nil then begin
        try e.assign(sv, p);
        finally releaseAndNil(sv); end;
      end else begin
        if not (e is tKlausVarValueSimple) then raise eKlausError.create(ercTypeMismatch, p);
        if not runTime then ssv := elmt[i].evaluate
        else ssv := elmt[i].evaluate(frame, allowCalls);
        (e as tKlausVarValueSimple).setSimple(ssv, p);
      end;
    end;
  except
    rslt.release;
    raise;
  end;
  result := rslt;
end;

procedure tKlausOpndArray.parseLiteral(b: tKlausSyntaxBrowser);
var
  idx: integer = 0;
  expr: tKlausExpression;
begin
  b.next;
  if not b.check('array_literal', false) then raise eKlausError.create(ercTypeMismatch, srcPoint(b.lex));
  b.next;
  b.check(klsBktOpen);
  repeat
    b.next;
    b.check('expression');
    expr := routine.createExpression(stmt, b, (typeDef as tKlausTypeDefArray).elmtType);
    setLength(fElmt, idx+1);
    fElmt[idx] := expr;
    idx += 1;
    b.next;
    if b.check(klsBktClose, false) then break;
  until not b.check(klsComma);
end;

{ tKlausOpndDictElmt }

constructor tKlausOpndDictElmt.create(aKey, aValue: tKlausExpression);
begin
  inherited create;
  fKey := aKey;
  fValue := aValue;
end;

destructor tKlausOpndDictElmt.destroy;
begin
  freeAndNil(fKey);
  freeAndNil(fValue);
  inherited destroy;
end;

{ tKlausOpndDict }

constructor tKlausOpndDict.create(aStmt: tKlausStatement; aTypeDef: tKlausTypeDef; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  assert(aTypeDef is tKlausTypeDefDict, 'Invalid compound literal class.');
  inherited create(aStmt, aTypeDef, aPoint, b);
end;

destructor tKlausOpndDict.destroy;
var
  i: integer;
begin
  for i := 0 to count-1 do elmt[i].free;
  inherited destroy;
end;

function tKlausOpndDict.getCount: integer;
begin
  result := length(fElmt);
end;

function tKlausOpndDict.getElmt(idx: integer): tKlausOpndDictElmt;
begin
  assert((idx >= 0) and (idx < count), 'Invalid item index.');
  result := fElmt[idx];
end;

function tKlausOpndDict.doAcquireVarValue(runTime: boolean; frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue;
var
  i: integer;
  rslt: tKlausVarValueDict;
  k: tKlausSimpleValue;
  dv: tKlausVarValue;
  sv: tKlausVarValue;
  ssv: tKlausSimpleValue;
  p: tSrcPoint;
begin
  rslt := tKlausVarValueDict.create(typeDef);
  try
    for i := 0 to count-1 do begin
      p := elmt[i].key.point;
      if not runTime then k := elmt[i].key.evaluate
      else k := elmt[i].key.evaluate(frame, allowCalls);
      dv := rslt.getElmt(k, p, vpmAsgnTarget);
      if not runTime then sv := elmt[i].value.acquireVarValue
      else sv := elmt[i].value.acquireVarValue(frame, allowCalls);
      if sv <> nil then begin
        try dv.assign(sv, p);
        finally releaseAndNil(sv); end;
      end else begin
        if not (dv is tKlausVarValueSimple) then raise eKlausError.create(ercTypeMismatch, p);
        if not runTime then ssv := elmt[i].value.evaluate
        else ssv := elmt[i].value.evaluate(frame, allowCalls);
        (dv as tKlausVarValueSimple).setSimple(ssv, p);
      end;
    end;
  except
    rslt.release;
    raise;
  end;
  result := rslt;
end;

procedure tKlausOpndDict.parseLiteral(b: tKlausSyntaxBrowser);
var
  idx: integer = 0;
  kx, vx: tKlausExpression;
begin
  b.next;
  if not b.check('dict_literal', false) then raise eKlausError.create(ercTypeMismatch, srcPoint(b.lex));
  b.next;
  b.check(klsBrcOpen);
  repeat
    b.next;
    b.check('expression');
    kx := routine.createExpression(stmt, b);
    b.next;
    b.check(klsColon);
    b.next;
    b.check('expression');
    vx := routine.createExpression(stmt, b, (typeDef as tKlausTypeDefDict).valueType);
    setLength(fElmt, idx+1);
    fElmt[idx] := tKlausOpndDictElmt.create(kx, vx);
    idx += 1;
    b.next;
    if b.check(klsBrcClose, false) then break;
  until not b.check(klsComma);
end;

{ tKlausOpndStructMember }

constructor tKlausOpndStructMember.create(aName: string; aExpr: tKlausExpression; aPoint: tSrcPoint);
begin
  inherited create;
  fName := aName;
  fExpr := aExpr;
  fPoint := aPoint;
end;

destructor tKlausOpndStructMember.destroy;
begin
  freeAndNil(fExpr);
  inherited destroy;
end;

{ tKlausOpndStruct }

constructor tKlausOpndStruct.create(aStmt: tKlausStatement; aTypeDef: tKlausTypeDef; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  assert(aTypeDef is tKlausTypeDefStruct, 'Invalid compound literal class.');
  fMembers := tStringList.create;
  fMembers.sorted := true;
  fMembers.duplicates := dupIgnore;
  inherited create(aStmt, aTypeDef, aPoint, b);
end;

destructor tKlausOpndStruct.destroy;
var
  i: integer;
begin
  for i := 0 to fMembers.count-1 do fMembers.objects[i].free;
  freeAndNil(fMembers);
  inherited destroy;
end;

function tKlausOpndStruct.getCount: integer;
begin
  result := fMembers.count;
end;

function tKlausOpndStruct.getMembers(idx: integer): tKlausOpndStructMember;
begin
  result := fMembers.objects[idx] as tKlausOpndStructMember;
end;

function tKlausOpndStruct.doAcquireVarValue(runTime: boolean; frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue;
var
  i: integer;
  rslt: tKlausVarValueStruct;
  m: tKlausOpndStructMember;
  vm: tKlausVarValue;
  sv: tKlausVarValue;
  ssv: tKlausSimpleValue;
begin
  rslt := tKlausVarValueStruct.create(typeDef);
  try
    for i := 0 to count-1 do begin
      m := members[i];
      vm := rslt.getMember(m.name, m.point);
      if not runTime then sv := m.expr.acquireVarValue
      else sv := m.expr.acquireVarValue(frame, allowCalls);
      if sv <> nil then begin
        try vm.assign(sv, m.expr.point);
        finally releaseAndNil(sv); end;
      end else begin
        if not (vm is tKlausVarValueSimple) then raise eKlausError.create(ercTypeMismatch, m.expr.point);
        if not runTime then ssv := m.expr.evaluate
        else ssv := m.expr.evaluate(frame, allowCalls);
        (vm as tKlausVarValueSimple).setSimple(ssv, m.expr.point);
      end;
    end;
  except
    rslt.release;
    raise;
  end;
  result := rslt;
end;

procedure tKlausOpndStruct.parseLiteral(b: tKlausSyntaxBrowser);
var
  mn: string;
  sm: tKlausStructMember;
  expr: tKlausExpression;
  p: tSrcPoint;
begin
  b.next;
  if not b.check('struct_literal', false) then raise eKlausError.create(ercTypeMismatch, srcPoint(b.lex));
  b.next;
  b.check(klsBrcOpen);
  repeat
    b.next;
    p := srcPoint(b.lex);
    mn := b.get(klxID).text;
    if fMembers.indexOf(u8Lower(mn)) >= 0 then raise eKlausError.createFmt(ercDuplicateMemberLiteral, srcPoint(b.lex), [mn]);
    sm := (typeDef as tKlausTypeDefStruct).member[mn];
    if sm = nil then raise eKlausError.createFmt(ercStructMemberNotFound, srcPoint(b.lex), [mn]);
    b.next;
    b.check(klsEq);
    b.next;
    b.check('expression');
    expr := routine.createExpression(stmt, b, sm.dataType);
    fMembers.addObject(u8Lower(mn), tKlausOpndStructMember.create(mn, expr, p));
    b.next;
    if b.check(klsBrcClose, false) then break;
  until not b.check(klsComma);
end;

{ tKlausOpndExists }

constructor tKlausOpndExists.create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  inherited create(aStmt, aUop, aPoint);
  b.next;
  case b.check([kkwdExists, kkwdNotExists]) of
    kkwdExists: fNegate := false;
    kkwdNotExists: fNegate := true;
  end;
  b.next;
  b.check(klsParOpen);
  b.next;
  b.check('var_path');
  fPath := tKlausVarPath.create(aStmt, b);
  b.next;
  b.check(klsParClose);
end;

destructor tKlausOpndExists.destroy;
begin
  freeAndNil(fPath);
  inherited destroy;
end;

function tKlausOpndExists.getResultType: tKlausDataType;
begin
  result := kdtBoolean;
end;

function tKlausOpndExists.doEvaluate: tKlausSimpleValue;
begin
  result := klausZeroValue(kdtString);
  raise eKlausError.create(ercNotConstantValue, point.line, point.pos);
end;

function tKlausOpndExists.doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue;
begin
  result := klausSimple(fPath.evaluate(frame, vpmCheckExist, allowCalls) <> nil);
  if negate then result.bValue := not result.bValue;
end;

{ tKlausOpndCall }

constructor tKlausOpndCall.create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  inherited create(aStmt, aUop, aPoint);
  fCall := tKlausCall.create(aStmt, b);
end;

destructor tKlausOpndCall.destroy;
begin
  freeAndNil(fCall);
  inherited destroy;
end;

function tKlausOpndCall.resultTypeDef: tKlausTypeDef;
begin
  result := fCall.resultTypeDef;
end;

function tKlausOpndCall.acquireVarValue: tKlausVarValue;
begin
  result := nil;
end;

function tKlausOpndCall.acquireVarValue(frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue;
begin
  if uop <> kuoInvalid then exit(nil);
  if not allowCalls then raise eKlausError.create(ercCallsNotAllowed, point);
  fCall.perform(frame, result);
end;

function tKlausOpndCall.getResultType: tKlausDataType;
var
  def: tKlausTypeDef;
begin
  def := fCall.resultTypeDef;
  if def <> nil then result := def.dataType
  else raise eKlausError.create(ercCannotReturnValue, point);
end;

function tKlausOpndCall.doEvaluate: tKlausSimpleValue;
begin
  result := klausZeroValue(kdtString);
  raise eKlausError.create(ercNotConstantValue, point);
end;

function tKlausOpndCall.doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue;
var
  val: tKlausVarValue;
begin
  if not allowCalls then raise eKlausError.create(ercCallsNotAllowed, point);
  call.perform(frame, val);
  try
    if val = nil then raise eKlausError.create(ercCannotReturnValue, point);
    if not (val is tKlausVarValueSimple) then raise eKlausError.create(ercTypeMismatch, point);
    result := (val as tKlausVarValueSimple).simple;
  finally
    releaseAndNil(val);
  end;
end;

{ tKlausExpression }

constructor tKlausExpression.create(aStmt: tKlausStatement; aUop: tKlausUnaryOperation; aPoint: tSrcPoint);
begin
  inherited create(aStmt, aUop, aPoint);
  fLeft := nil;
  fRight := nil;
  fOp := kboInvalid;
  fOpPoint := fPoint;
end;

destructor tKlausExpression.destroy;
begin
  if assigned(fLeft) then freeAndNil(fLeft);
  if assigned(fRight) then freeAndNil(fRight);
  inherited destroy;
end;

procedure tKlausExpression.setLeft(aLeft: tKlausOperand);
begin
  fLeft := aLeft;
  if assigned(fLeft) then begin
    fLeft.fStmt := stmt;
    fLeft.fParent := self;
  end;
end;

procedure tKlausExpression.setRight(aRight: tKlausOperand);
begin
  fRight := aRight;
  if assigned(fRight) then begin
    fRight.fStmt := stmt;
    fRight.fParent := self;
  end;
end;

function tKlausExpression.doEvaluate: tKlausSimpleValue;
var
  vr: tKlausSimpleValue;
begin
  result := left.evaluate;
  if right <> nil then begin
    assert(op <> kboInvalid, 'Illegal binary operation');
    vr := right.evaluate;
    result := klausBinOp[op].evaluate(result, vr, opPoint);
  end;
end;

function tKlausExpression.doEvaluate(frame: tKlausStackFrame; allowCalls: boolean): tKlausSimpleValue;
var
  vr: tKlausSimpleValue;
begin
  result := left.evaluate(frame, allowCalls);
  if right <> nil then begin
    assert(op <> kboInvalid, 'Illegal binary operation');
    vr := right.evaluate(frame, allowCalls);
    result := klausBinOp[op].evaluate(result, vr, opPoint);
  end;
end;

function tKlausExpression.isVarPath: boolean;
begin
  result := (left is tKlausOpndVarPath) and (left.uop = kuoInvalid) and (right = nil);
end;

function tKlausExpression.isConstPath: boolean;
begin
  result := (left is tKlausOpndVarPath) and (left.uop = kuoInvalid) and (right = nil);
  if result then result := (left as tKlausOpndVarPath).path.isConstant;
end;

function  tKlausExpression.isCall: boolean;
begin
  result := (left is tKlausOpndCall) and (left.uop = kuoInvalid) and (right = nil);
end;

function tKlausExpression.isCompound: boolean;
begin
  result := (left is tKlausOpndCompound) and (left.uop = kuoInvalid) and (right = nil);
end;

function tKlausExpression.acquireVarValue: tKlausVarValue;
begin
  if right <> nil then result := nil
  else result := left.acquireVarValue
end;

function tKlausExpression.acquireVarValue(frame: tKlausStackFrame; allowCalls: boolean): tKlausVarValue;
begin
  if right <> nil then result := nil
  else result := left.acquireVarValue(frame, allowCalls)
end;

function tKlausExpression.resultTypeDef: tKlausTypeDef;
begin
  if right = nil then result := left.resultTypeDef
  else result := inherited resultTypeDef;
end;

function tKlausExpression.getResultType: tKlausDataType;
var
  dtr: tKlausDataType;
begin
  result := left.resultType;
  if right <> nil then begin
    assert(op <> kboInvalid, 'Illegal binary operation');
    dtr := right.resultType;
    result := klausBinOp[op].resultType(result, dtr, opPoint);
  end;
end;

{ tKlausStmtHalt }

constructor tKlausStmtHalt.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  inherited create(aOwner, aPoint);
  b.next;
  if b.check('expression', false) then begin
    fRetCode := routine.createExpression(self, b);
    if fRetCode.resultType <> kdtInteger then
      raise eKlausError.create(ercTypeMismatch, fRetCode.point.line, fRetCode.point.pos);
  end else begin
    fRetCode := nil;
    b.pause;
  end;
end;

destructor tKlausStmtHalt.destroy;
begin
  freeAndNil(fRetCode);
  inherited destroy;
end;

procedure tKlausStmtHalt.run(frame: tKlausStackFrame);
var
  code: tKlausSimpleValue;
begin
  klausDebuggerStep(frame, point);
  try
    if assigned(fRetCode) then begin
      code := retCode.evaluate(frame, true);
      if code.dataType <> kdtInteger then raise eKlausError.create(ercTypeMismatch, retCode.point.line, retCode.point.pos);
    end else
      code := klausSimple(tKlausInteger(0));
    raise eKlausHalt.create(code.iValue);
  except
    klausTranslateException(frame, point);
  end;
end;

{ tKlausStmtReturn }

constructor tKlausStmtReturn.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  rvt: tKlausTypeDef;
begin
  inherited create(aOwner, aPoint);
  rvt := owner.routine.retValueType;
  b.next;
  if b.check('expression', false) then begin
    fRetValue := routine.createExpression(self, b);
    if rvt = nil then raise eKlausError.create(ercCannotReturnValue, fRetValue.point.line, fRetValue.point.pos);
    if not rvt.canAssign(fRetValue.resultTypeDef) then raise eKlausError.create(ercTypeMismatch, fRetValue.point.line, fRetValue.point.pos);
  end else begin
    if rvt <> nil then raise eKlausError.create(ercMustReturnValue, b.lex.line, b.lex.pos);
    b.pause;
  end;
end;

destructor tKlausStmtReturn.destroy;
begin
  freeAndNil(fRetValue);
  inherited destroy;
end;

procedure tKlausStmtReturn.run(frame: tKlausStackFrame);
var
  rv: tKlausVarDecl;
begin
  klausDebuggerStep(frame, point);
  try
    rv := owner.routine.retValue;
    if (rv = nil) and (retValue <> nil) then raise eKlausError.create(ercCannotReturnValue, point.line, point.pos);
    if (rv <> nil) and (retValue = nil) then raise eKlausError.create(ercMustReturnValue, point.line, point.pos);
    if rv <> nil then frame.assignVarValue(frame.varByDecl(rv, point), retValue);
    raise eKlausReturn.create;
  except
    klausTranslateException(frame, point);
  end;
end;

{ tKlausStmtAssign }

constructor tKlausStmtAssign.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  sym: tKlausSymbol;
  dt, st: tKlausTypeDef;
begin
  inherited create(aOwner, aPoint);
  b.next;
  b.check('var_path');
  fDest := tKlausVarPath.create(self, b);
  if fDest.isConstant then raise eKlausError.create(ercConstAsgnTarget, fDest.point);
  dt := fDest.resultTypeDef;
  b.next;
  b.check('assign_symbol');
  b.next;
  sym := b.check(klausAssignSymbols);
  fOp := klausAsgnOp[sym];
  b.next;
  b.check('expression');
  fSource := routine.createExpression(self, b, dt);
  st := fSource.resultTypeDef;
  if st = nil then raise eKlausError.create(ercCannotReturnValue, fSource.point.line, fSource.point.pos);
  if not dt.canAssign(st) then raise eKlausError.create(ercTypeMismatch, fSource.point.line, fSource.point.pos);
  if op <> kboInvalid then klausBinOp[op].checkDefined(dt.dataType, st.dataType, fSource.point);
end;

destructor tKlausStmtAssign.destroy;
begin
  freeAndNil(fDest);
  freeAndNil(fSource);
  inherited destroy;
end;

procedure tKlausStmtAssign.run(frame: tKlausStackFrame);
begin
  klausDebuggerStep(frame, point);
  try
    frame.assignVarValue(dest, source, op);
  except
    klausTranslateException(frame, point);
  end;
end;

{ tKlausStmtCall }

constructor tKlausStmtCall.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  inherited create(aOwner, aPoint);
  fCall := tKlausCall.create(self, b);
end;

destructor tKlausStmtCall.destroy;
begin
  freeAndNil(fCall);
  inherited destroy;
end;

procedure tKlausStmtCall.run(frame: tKlausStackFrame);
var
  rslt: tKlausVarValue;
begin
  klausDebuggerStep(frame, point);
  try
    call.perform(frame, rslt);
    if rslt <> nil then releaseAndNil(rslt);
  except
    klausTranslateException(frame, point);
  end;
end;

{ tKlausStmtRaise }

constructor tKlausStmtRaise.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  idx: integer = -1;
  li: tKlausLexInfo;
  d: tKlausDecl;
  expr: tKlausExpression;
begin
  inherited create(aOwner, aPoint);
  b.next;
  b.check('exception');
  b.next;
  li := b.get(klxID);
  fPoint := srcPoint(li);
  d := routine.find(li.text, knsGlobal);
  if not (d is tKlausExceptDecl) then
    raise eKlausError.createFmt(ercExceptionRequired, li.line, li.pos, [li.text]);
  fDecl := d as tKlausExceptDecl;
  b.next;
  if b.check(klsParOpen, false) then begin
    repeat
      b.next;
      b.check('expression');
      expr := routine.createExpression(self, b);
      idx := length(fParams);
      setLength(fParams, idx+1);
      fParams[idx] := expr;
      b.next;
      if b.check(klsParClose, false) then break
      else b.check(klsComma);
    until false;
    b.next;
  end;
  if b.check(kkwdMessage, false) then begin
    b.next;
    b.check('expression');
    fMessage := routine.createExpression(self, b);
  end else begin
    fMessage := nil;
    b.pause;
  end;
  checkParamTypes;
end;

destructor tKlausStmtRaise.destroy;
var
  i: integer;
begin
  for i := paramCount-1 downto 0 do params[i].free;
  freeAndNil(fMessage);
  inherited destroy;
end;

procedure tKlausStmtRaise.run(frame: tKlausStackFrame);
var
  i: integer;
  pt: tSrcPoint;
  sv: tKlausSimpleValue;
  fv: tKlausVarValueSimple;
  obj: tKlausVarValueStruct;
begin
  try
    if decl.data.count-1 <> paramCount then raise eKlausError.createFmt(ercWrongNumberOfParams, point.line, point.pos, [paramCount, IntToStr(decl.data.count-1)]);
    obj := tKlausVarValueStruct.create(decl.data);
    for i := 0 to paramCount-1 do begin
      fv := obj.getMember(decl.data.members[i+1].name, params[i].point) as tKlausVarValueSimple;
      fv.setSimple(params[i].evaluate(frame, true), params[i].point);
    end;
    if message <> nil then begin
      pt := message.point;
      sv := message.evaluate(frame, true);
      if sv.dataType <> kdtString then raise eKlausError.create(ercTypeMismatch, pt.line, pt.pos);
    end else begin
      pt := point;
      sv.dataType := kdtString;
      sv.sValue := decl.message;
      if sv.sValue = '' then sv.sValue := decl.name;
    end;
    fv := obj.getMember(klausExceptionMessageFieldName, pt) as tKlausVarValueSimple;
    sv.sValue := formatErrorMessage(sv.sValue, obj);
    fv.setSimple(sv, pt);
    raise eKlausLangException.create(sv.sValue, decl, obj, point.line, point.pos);
  except
    klausTranslateException(frame, point);
  end;
end;

function tKlausStmtRaise.getParamCount: integer;
begin
  result := length(fParams);
end;

function tKlausStmtRaise.getParams(idx: integer): tKlausExpression;
begin
  assert((idx >= 0) and (idx < paramCount), 'Invalid item index');
  result := fParams[idx];
end;

procedure tKlausStmtRaise.checkParamTypes;
var
  i: integer;
  dt: tKlausDataType;
begin
  if decl.data.count-1 <> paramCount then raise eKlausError.createFmt(ercWrongNumberOfParams, point.line, point.pos, [paramCount, intToStr(decl.data.count-1)]);
  for i := 0 to paramCount-1 do begin
    dt := params[i].resultType;
    if not decl.data.members[i+1].dataType.canAssign(dt) then raise eKlausError.create(ercTypeMismatch, params[i].point.line, params[i].point.pos);
  end;
  if message <> nil then
    if not decl.data.members[0].dataType.canAssign(message.resultType) then
      raise eKlausError.create(ercTypeMismatch, message.point.line, message.point.pos);
end;

function tKlausStmtRaise.formatErrorMessage(const msg: string; data: tKlausVarValueStruct): string;
var
  n: string;
  idx: integer;
  p1, p2: pChar;
  pt: tSrcPoint;
  v: tKlausVarValue;
begin
  if message = nil then pt := point
  else pt := message.point;
  result := '';
  p2 := pChar(msg);
  idx := pos('%(', msg);
  while idx > 0 do begin
    p1 := pChar(msg)+idx-1;
    result += copy(msg, p2-pChar(msg)+1, p1-p2);
    while not (p2^ in [#0, ')']) do inc(p2);
    if p2^ = ')' then begin
      n := copy(msg, p1-pChar(msg)+3, p2-p1-2);
      v := data.findMember(n);
      if v is tKlausVarValueSimple then begin
        inc(p2);
        result += klausTypecast((v as tKlausVarValueSimple).simple, kdtString, pt).sValue;
      end else
        p2 := p1;
    end else
      p2 := p1;
    idx := pos('%(', msg, p2-pChar(msg)+2);
  end;
  result += copy(msg, p2-pChar(msg)+1, maxInt);
end;

{ tKlausStmtLoopControl }

constructor tKlausStmtLoopControl.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint);
var
  loop: tKlausStmtLoop;
begin
  inherited create(aOwner, aPoint);
  loop := findUpperStructure(tKlausStmtLoop) as tKlausStmtLoop;
  if loop = nil then raise eKlausError.create(ercLoopCtlOutsideLoop, aPoint.line, aPoint.pos);
end;

{ tKlausStmtBreak }

procedure tKlausStmtBreak.run(frame: tKlausStackFrame);
begin
  klausDebuggerStep(frame, point);
  raise eKlausBreak.create;
end;

{ tKlausStmtContinue }

procedure tKlausStmtContinue.run(frame: tKlausStackFrame);
begin
  klausDebuggerStep(frame, point);
  raise eKlausContinue.create;
end;

{ tKlausStmtCtlStruct }

constructor tKlausStmtCtlStruct.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint);
begin
  fDestroying := false;
  inherited create(aOwner, aPoint);
end;

procedure tKlausStmtCtlStruct.beforeDestruction;
begin
  fDestroying := true;
  inherited beforeDestruction;
end;

procedure tKlausStmtCtlStruct.addItem(item: tKlausStatement);
begin
end;

procedure tKlausStmtCtlStruct.removeItem(item: tKlausStatement);
begin
end;

{ tKlausStatement }

constructor tKlausStatement.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint);
begin
  inherited create;
  fOwner := aOwner;
  fPoint := aPoint;
  if assigned(fOwner) then fOwner.addItem(self);
end;

destructor tKlausStatement.destroy;
begin
  if assigned(fOwner) then fOwner.removeItem(self);
  inherited destroy;
end;

function tKlausStatement.getRoutine: tKlausRoutine;
var
  r: tKlausStmtRoutineBody;
begin
  r := findUpperStructure(tKlausStmtRoutineBody) as tKlausStmtRoutineBody;
  if assigned(r) then result := r.routine else result := nil;
end;

function tKlausStatement.findUpperStructure(cls: tKlausStmtCtlStructClass): tKlausStmtCtlStruct;
begin
  result := owner;
  while not (result is cls) do begin
    if result = nil then exit;
    result := result.owner;
  end;
end;

{ tKlausStmtNothing }

procedure tKlausStmtNothing.run(frame: tKlausStackFrame);
begin
  klausDebuggerStep(frame, point);
end;

{ tKlausStmtBlock }

constructor tKlausStmtBlock.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint);
begin
  inherited create(aOwner, aPoint);
  fItems := tFPList.create;
  fDestroying := false;
end;

destructor tKlausStmtBlock.destroy;
var
  i: integer;
begin
  for i := count-1 downto 0 do items[i].free;
  inherited destroy;
end;

procedure tKlausStmtBlock.run(frame: tKlausStackFrame);
var
  i: integer;
begin
  try
    for i := 0 to count-1 do items[i].run(frame);
  except
    klausTranslateException(frame, point);
  end;
end;

function tKlausStmtBlock.getCount: integer;
begin
  result := fItems.count;
end;

function tKlausStmtBlock.getItems(idx: integer): tKlausStatement;
begin
  assert((idx >= 0) and (idx < count), 'Invalid item index');
  result := tKlausStatement(fItems[idx]);
end;

procedure tKlausStmtBlock.addItem(item: tKlausStatement);
begin
  fItems.add(item);
end;

procedure tKlausStmtBlock.removeItem(item: tKlausStatement);
begin
  if fDestroying then exit;
  fItems.remove(item);
end;

{ tKlausStmtCompound }

constructor tKlausStmtCompound.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint);
begin
  inherited create(aOwner, aPoint);
  fExceptBlock := nil;
  fFinallyBlock := nil;
end;

constructor tKlausStmtCompound.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  inherited create(aOwner, aPoint);
  createCompound(b);
end;

destructor tKlausStmtCompound.destroy;
begin
  freeAndNil(fExceptBlock);
  freeAndNil(fFinallyBlock);
  inherited destroy;
end;

procedure tKlausStmtCompound.createCompound(b: tKlausSyntaxBrowser);
const
  exceptRules: array of string = ('except_handler', 'except_else', 'statements');
var
  idx: integer;
begin
  b.next;
  b.check(kkwdBegin);
  fPoint := srcPoint(b.lex);
  b.next;
  b.check('statements');
  routine.createStatements(self, b);
  b.next;
  if b.check(kkwdException, false) then begin
    tKlausExceptBlock.create(self, srcPoint(b.lex));
    b.next;
    b.check('except_block');
    b.next;
    idx := b.check(exceptRules);
    case idx of
      0, 1: fExceptBlock.createExceptHandlers(b);
      2: routine.createStatements(fExceptBlock, b);
    end;
    b.next;
  end;
  if b.check(kkwdFinally, false) then begin
    tKlausFinallyBlock.create(self, srcPoint(b.lex));
    b.next;
    b.check('statements');
    routine.createStatements(fFinallyBlock, b);
    b.next;
  end;
  b.check(kkwdEnd);
end;

procedure tKlausStmtCompound.run(frame: tKlausStackFrame);
var
  i: integer;
  obj: eKlausLangException;
begin
  try
    try
      try
        for i := 0 to count-1 do items[i].run(frame);
      except
        on eKlausLangException do try
          obj := eKlausLangException(acquireExceptionObject);
          updateGlobalErrorInfo(obj);
          handleException(frame, obj, exceptAddr);
        finally
          updateGlobalErrorInfo(nil);
        end;
        else raise;
      end;
    finally
      if fFinallyBlock <> nil then fFinallyBlock.run(frame);
    end;
  except
    klausTranslateException(frame, point);
  end;
end;

procedure tKlausStmtCompound.updateGlobalErrorInfo(obj: eKlausLangException);
begin
  if obj <> nil then begin
    globalErrorInfo.name := obj.decl.name;
    globalErrorInfo.text := obj.message;
  end else begin
    globalErrorInfo.name := '';
    globalErrorInfo.text := '';
  end;
end;

procedure tKlausStmtCompound.updateExceptionMessage(frame: tKlausStackFrame; obj: eKlausLangException);
var
  v: tKlausVarValue;
begin
  v := obj.data.getMember(klausExceptionMessageFieldName, zeroSrcPt);
  obj.message := (v as tKlausVarValueSimple).simple.sValue;
  if obj.message = '' then obj.message := obj.decl.name;
end;

procedure tKlausStmtCompound.handleException(frame: tKlausStackFrame; obj: eKlausLangException; addr: codePointer);
var
  wh: tKlausStmtWhen;
  v: tKlausVariable = nil;
begin
  if fExceptBlock = nil then raise obj at addr;
  try
    if not fExceptBlock.hasHandlers then
      fExceptBlock.run(frame)
    else begin
      wh := fExceptBlock.getExceptionHandler(obj);
      if wh = nil then raise obj at addr;
      if wh.objDecl <> nil then
        v := tKlausVariable.create(frame, wh.objDecl);
      try
        if v <> nil then
          v.acquireOutputBuffer(obj.data, wh.objDecl.point);
        wh.run(frame);
      finally
        freeAndNil(v);
      end;
    end;
  except
    on eKlausThrow do begin
      updateExceptionMessage(frame, obj);
      raise obj at addr;
    end;
    else raise;
  end;
end;

procedure tKlausStmtCompound.addItem(item: tKlausStatement);
begin
  if item is tKlausExceptBlock then begin
    assert(fExceptBlock = nil, 'There may be only one EXCEPT block');
    fExceptBlock := item as tKlausExceptBlock;
    exit;
  end;
  if item is tKlausFinallyBlock then begin
    assert(fFinallyBlock = nil, 'There may be only one FINALLY block');
    fFinallyBlock := item as tKlausFinallyBlock;
    exit;
  end;
  inherited addItem(item);
end;

{ tKlausExceptBlock }

procedure tKlausExceptBlock.addItem(item: tKlausStatement);
begin
  if count > 0 then
    if ((item is tKlausStmtWhen) and not (items[0] is tKlausStmtWhen))
    or (not (item is tKlausStmtWhen) and (items[0] is tKlausStmtWhen)) then
      raise eKlausError.create(ercMixedExceptBlock, item.point.line, item.point.pos);
  inherited addItem(item);
  fHasHandlers := item is tKlausStmtWhen;
end;

procedure tKlausExceptBlock.createExceptHandlers(b: tKlausSyntaxBrowser);
type
  tPtrMap = specialize tFPGMap<pointer, integer>;
const
  handlerRules: array of string = ('except_handler', 'except_else');
var
  i, j: integer;
  map: tPtrMap;
  when: tKlausStmtWhen;
  anyFound: boolean = false;
begin
  repeat
    b.next;
    b.check(kkwdExceptWhen);
    tKlausStmtWhen.create(self, srcPoint(b.lex), b);
    b.next;
  until b.check(handlerRules, false) < 0;
  b.pause;
  map := tPtrMap.create;
  try
    for i := 0 to count-1 do begin
      if anyFound then eKlausError.create(ercExceptAnyMustBeLast, items[i].point.line, items[i].point.pos);
      when := items[i] as tKlausStmtWhen;
      if when.exceptCount = 0 then anyFound := true;
      for j := 0 to when.exceptCount-1 do begin
        if map.indexOf(when.excepts[j]) >= 0 then raise eKlausError.createFmt(ercExceptAlreadyHandled, when.point.line, when.point.pos, [when.excepts[j].name]);
        map.add(when.excepts[j]);
      end;
    end;
  finally
    freeAndNil(map);
  end;
end;

function tKlausExceptBlock.getExceptionHandler(obj: eKlausLangException): tKlausStmtWhen;
var
  i: integer;
  wh: tKlausStmtWhen;
begin
  if not hasHandlers then exit(nil);
  for i := 0 to count-1 do begin
    wh := items[i] as tKlausStmtWhen;
    if wh.willHandle(obj) then exit(wh);
  end;
  result := nil;
end;

{ tKlausExceptObjDecl }

constructor tKlausExceptObjDecl.create(aOwner: tKlausRoutine; aName: string; const aPoint: tSrcPoint; aExceptDecl: tKlausExceptDecl);
begin
  inherited create(aOwner, aName, aPoint, aExceptDecl.data, nil);
end;

{ tKlausStmtWhen }

constructor tKlausStmtWhen.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  idx: integer;
  xd: tKlausDecl;
  id1, id2: tKlausLexInfo;
begin
  inherited create(aOwner, aPoint);
  if not (aOwner is tKlausExceptBlock) then raise eKlausError.create(ercExceptBlockOnly, point.line, point.pos);
  b.next;
  if b.check(kkwdAny, false) then begin
    fExcepts := nil;
    fObjDecl := nil;
    b.next;
  end else begin
    id1 := b.get(klxID);
    b.next;
    if b.check(klsColon, false) then begin
      b.next;
      id2 := b.get(klxID);
      xd := routine.find(id2.text, knsGlobal);
      if not (xd is tKlausExceptDecl) then raise eKlausError.createFmt(ercExceptionRequired, id2.line, id2.pos, [id2.text]);
      if routine.find(id1.text, knsLocal) <> nil then raise eKlausError.createFmt(ercDuplicateName, id1.line, id1.pos, [id1.text]);
      setLength(fExcepts, 1);
      fExcepts[0] := xd as tKlausExceptDecl;
      fObjDecl := tKlausExceptObjDecl.create(routine, id1.text, srcPoint(id1), xd as tKlausExceptDecl);
      b.next;
    end else begin
      b.pause;
      fObjDecl := nil;
      repeat
        xd := routine.find(id1.text, knsGlobal);
        if not (xd is tKlausExceptDecl) then raise eKlausError.createFmt(ercExceptionRequired, id1.line, id1.pos, [id1.text]);
        idx := length(fExcepts);
        setLength(fExcepts, idx+1);
        fExcepts[idx] := xd as tKlausExceptDecl;
        b.next;
        if not b.check(klsComma, false) then break;
        b.next;
        id1 := b.get(klxID);
      until false;
    end;
  end;
  b.check(kkwdExceptThen);
  b.next;
  b.check('statement');
  fStmt := routine.createStatement(self, b);
  b.next;
  b.check(klsSemicolon);
end;

destructor tKlausStmtWhen.destroy;
begin
  freeAndNil(fStmt);
  inherited destroy;
end;

function tKlausStmtWhen.willHandle(obj: eKlausLangException): boolean;
var
  i: integer;
begin
  if exceptCount = 0 then exit(true);
  for i := 0 to exceptCount-1 do
    if excepts[i] = obj.decl then exit(true);
  result := false;
end;

procedure tKlausStmtWhen.run(frame: tKlausStackFrame);
begin
  try
    fStmt.run(frame);
  except
    klausTranslateException(frame, point);
  end;
end;

function tKlausStmtWhen.getExceptCount: integer;
begin
  result := length(fExcepts);
end;

function tKlausStmtWhen.getExcepts(idx: integer): tKlausExceptDecl;
begin
  assert((idx >= 0) and (idx < exceptCount), 'Invalid item index');
  result := fExcepts[idx];
end;

{ tKlausStmtThrow }

constructor tKlausStmtThrow.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint);
var
  block: tKlausExceptBlock;
begin
  inherited create(aOwner, aPoint);
  block := findUpperStructure(tKlausExceptBlock) as tKlausExceptBlock;
  if block = nil then raise eKlausError.create(ercExceptBlockOnly, aPoint.line, aPoint.pos);
end;

procedure tKlausStmtThrow.run(frame: tKlausStackFrame);
begin
  klausDebuggerStep(frame, point);
  raise eKlausThrow.create;
end;

{ tKlausStmtRoutineBody }

function tKlausStmtRoutineBody.getRoutine: tKlausRoutine;
begin
  result := fRoutine;
end;

constructor tKlausStmtRoutineBody.create(aRoutine: tKlausRoutine; aPoint: tSrcPoint);
begin
  inherited create(nil, aPoint);
  fRoutine := aRoutine;
end;

{ tKlausStmtIf }

constructor tKlausStmtIf.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  inherited create(aOwner, aPoint);
  b.next;
  b.check(kkwdIf);
  b.next;
  b.check('expression');
  fExpr := routine.createExpression(self, b);
  if fExpr.resultType <> kdtBoolean then raise eKlausError.create(ercConditionMustBeBool, fExpr.point.line, fExpr.point.pos);
  b.next;
  b.check(kkwdThen);
  b.next;
  b.check('statement');
  fStmtTrue := routine.createStatement(self, b);
  b.next;
  if b.check(kkwdElse, false) then begin
    b.next;
    b.check('statement');
    fStmtFalse := routine.createStatement(self, b);
  end else begin
    fStmtFalse := nil;
    b.pause;
  end;
end;

destructor tKlausStmtIf.destroy;
begin
  freeAndNil(fExpr);
  freeAndNil(fStmtTrue);
  freeAndNil(fStmtFalse);
  inherited destroy;
end;

procedure tKlausStmtIf.run(frame: tKlausStackFrame);
var
  sv: tKlausSimpleValue;
begin
  klausDebuggerStep(frame, point);
  try
    sv := expr.evaluate(frame, true);
    if sv.dataType <> kdtBoolean then raise eKlausError.create(ercConditionMustBeBool, expr.point.line, expr.point.pos);
    if sv.bValue then stmtTrue.run(frame)
    else if stmtFalse <> nil then stmtFalse.run(frame);
  except
    klausTranslateException(frame, point);
  end;
end;

{ tKlausStmtFor }

constructor tKlausStmtFor.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  decl: tKlausDecl;
begin
  inherited create(aOwner, aPoint);
  b.next;
  b.check(kkwdFor);
  b.next;
  b.check(klxID);
  decl := routine.find(b.lex.text, knsGlobal);
  if not (decl is tKlausVarDecl) then raise eKlausError.create(ercInvalidLoopCounter, b.lex.line, b.lex.pos);
  if ((decl as tKlausVarDecl).dataType.dataType <> kdtInteger)
  or (decl.owner <> self.routine) then raise eKlausError.create(ercInvalidLoopCounter, b.lex.line, b.lex.pos);
  fCounter := decl as tKlausVarDecl;
  b.next;
  b.check(kkwdFrom);
  b.next;
  b.check('expression');
  fStart := routine.createExpression(self, b);
  if fStart.resultType <> kdtInteger then raise eKlausError.create(ercTypeMismatch, fStart.point.line, fStart.point.pos);
  b.next;
  b.check(kkwdTo);
  b.next;
  b.check('expression');
  fFinish := routine.createExpression(self, b);
  if fFinish.resultType <> kdtInteger then raise eKlausError.create(ercTypeMismatch, fFinish.point.line, fFinish.point.pos);
  b.next;
  if b.check(kkwdReverse, false) then begin
    fReverse := true;
    b.next;
  end else
    fReverse := false;
  b.check(kkwdLoop);
  b.next;
  b.check('statement');
  fBody := routine.createStatement(self, b);
end;

destructor tKlausStmtFor.destroy;
begin
  freeAndNil(fStart);
  freeAndNil(fFinish);
  freeAndNil(fBody);
  inherited destroy;
end;

procedure tKlausStmtFor.run(frame: tKlausStackFrame);
var
  v: tKlausVariable;
  cntr: tKlausVarValueSimple;
  sv: tKlausSimpleValue;
  i, strt, fnsh: integer;
begin
  klausDebuggerStep(frame, point);
  try
    v := frame.varByDecl(counter, counter.point);
    if v.value.dataType.dataType <> kdtInteger then raise eKlausError.create(ercInvalidLoopCounter, counter.point.line, counter.point.pos);
    cntr := v.value as tKlausVarValueSimple;
    sv := start.evaluate(frame, true);
    if sv.dataType <> kdtInteger then raise eKlausError.create(ercTypeMismatch, start.point);
    strt := sv.iValue;
    sv := finish.evaluate(frame, true);
    if sv.dataType <> kdtInteger then raise eKlausError.create(ercTypeMismatch, finish.point);
    fnsh := sv.iValue;
    try
      if reverse then begin
        for i := strt downto fnsh do try
          cntr.setSimple(klausSimple(i), counter.point);
          body.run(frame);
        except
          on eKlausContinue do;
          else raise;
        end
      end else begin
        for i := strt to fnsh do try
          cntr.setSimple(klausSimple(i), counter.point);
          body.run(frame);
        except
          on eKlausContinue do;
          else raise;
        end;
      end;
    except
      on eKlausBreak do;
      else raise;
    end;
  except
    klausTranslateException(frame, point);
  end;
end;

{ tKlausStmtForEach }

constructor tKlausStmtForEach.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  decl: tKlausDecl;
  path: tKlausVarPath;
  kdt: tKlausSimpleType;
  pdt: tKlausTypeDef;
  p1, p2: tSrcPoint;
begin
  inherited create(aOwner, aPoint);
  b.next;
  b.check(kkwdFor);
  b.next;
  b.check(kkwdEach);
  b.next;
  b.check(klxID);
  p1 := srcPoint(b.lex);
  decl := routine.find(b.lex.text, knsGlobal);
  b.next;
  b.check(kkwdOf);
  b.next;
  b.check('var_path');
  p2 := srcPoint(b.lex);
  path := tKlausVarPath.create(self, b);
  if not (decl is tKlausVarDecl) or (decl.owner <> self.routine) then raise eKlausError.create(ercInvalidForEachKey, p1.line, p1.pos);
  pdt := path.resultTypeDef;
  if pdt is tKlausTypeDefArray then kdt := kdtInteger
  else if pdt is tKlausTypeDefDict then kdt := (pdt as tKlausTypeDefDict).keyType
  else if pdt is tKlausTypeDefSimple then begin
    if (pdt as tKlausTypeDefSimple).simpleType <> kdtString then raise eKlausError.create(ercInvalidForEachType, p2);
    kdt := kdtInteger;
  end else
    raise eKlausError.create(ercInvalidForEachType, p2.line, p2.pos);
  if (decl as tKlausVarDecl).dataType.dataType <> kdt then raise eKlausError.createFmt(ercForEachKeyTypeMismatch, p1, [klausDataTypeCaption[kdt]]);
  fKey := decl as tKlausVarDecl;
  fDict := path;
  b.next;
  if b.check(kkwdFrom, false) then begin
    if pdt is tKlausTypeDefSimple then raise eKlauserror.create(ercIllegalExpression, b.lex.line, b.lex.pos);
    b.next;
    b.check('expression');
    fStart := routine.createExpression(self, b);
    if fStart.resultType <> kdt then raise eKlausError.create(ercTypeMismatch, fStart.point);
    b.next;
  end else
    fStart := nil;
  if b.check(kkwdReverse, false) then begin
    fReverse := true;
    b.next;
  end else
    fReverse := false;
  b.check(kkwdLoop);
  b.next;
  b.check('statement');
  fBody := routine.createStatement(self, b);
end;

destructor tKlausStmtForEach.destroy;
begin
  freeAndNil(fDict);
  freeAndNil(fBody);
  freeAndNil(fStart);
  inherited destroy;
end;

procedure tKlausStmtForEach.run(frame: tKlausStackFrame);
var
  v: tKlausVariable;
  kv: tKlausVarValueSimple;
  dv: tKlausVarValue;
  dvkt: tKlausSimpleType;
  sv: tKlausSimpleValue;
  i, len, strt: integer;
  found: boolean;
  s: string;
  p: pChar;
begin
  klausDebuggerStep(frame, point);
  try
    v := frame.varByDecl(key, key.point);
    if not (v.value is tKlausVarValueSimple) then raise eKlausError.create(ercInvalidForEachKey, key.point.line, key.point.pos);
    kv := v.value as tKlausVarValueSimple;
    dv := dict.evaluate(frame, vpmEvaluate, true);
    if dv is tKlausVarValueArray then begin
      if kv.dataType.dataType <> kdtInteger then raise eKlausError.createFmt(ercForEachKeyTypeMismatch, key.point.line, key.point.pos, [klausDataTypeCaption[kdtInteger]]);
      len := (dv as tKlausVarValueArray).count;
      if start = nil then begin
        if reverse then strt := len-1
        else strt := 0;
      end else begin
        sv := start.evaluate(frame, true);
        if sv.dataType <> kdtInteger then raise eKlausError.create(ercTypeMismatch, start.point);
        strt := sv.iValue;
      end;
      try
        if reverse then begin
          for i := strt downto 0 do try
            kv.setSimple(klausSimple(i), key.point);
            body.run(frame);
          except
            on eKlausContinue do;
            else raise;
          end
        end else begin
          for i := strt to len-1 do try
            kv.setSimple(klausSimple(i), key.point);
            body.run(frame);
          except
            on eKlausContinue do;
            else raise;
          end;
        end;
      except
        on eKlausBreak do;
        else raise;
      end;
    end else if dv is tKlausVarValueDict then begin
      dvkt := (dv.dataType as tKlausTypeDefDict).keyType;
      if kv.dataType.dataType <> dvkt then raise eKlausError.createFmt(ercForEachKeyTypeMismatch, key.point.line, key.point.pos, [klausDataTypeCaption[dvkt]]);
      len := (dv as tKlausVarValueDict).count;
      if start = nil then begin
        if reverse then strt := len-1
        else strt := 0;
      end else begin
        sv := start.evaluate(frame, true);
        if sv.dataType <> dvkt then raise eKlausError.create(ercTypeMismatch, start.point);
        found := (dv as tKlausVarValueDict).findKey(sv, strt);
        if not found and reverse then dec(strt);
      end;
      try
        if reverse then begin
          for i := strt downto 0 do try
            sv := (dv as tKlausVarValueDict).getKeyAt(i, dict.point);
            kv.setSimple(sv, key.point);
            body.run(frame);
          except
            on eKlausContinue do;
            else raise;
          end
        end else begin
          for i := strt to len-1 do try
            sv := (dv as tKlausVarValueDict).getKeyAt(i, dict.point);
            kv.setSimple(sv, key.point);
            body.run(frame);
          except
            on eKlausContinue do;
            else raise;
          end;
        end;
      except
        on eKlausBreak do;
        else raise;
      end;
    end else if dv is tKlausVarValueSimple then begin
      if dv.dataType.dataType <> kdtString then raise eKlausError.create(ercInvalidForEachType, dict.point.line, dict.point.pos);
      if kv.dataType.dataType <> kdtInteger then raise eKlausError.createFmt(ercForEachKeyTypeMismatch, key.point.line, key.point.pos, [klausDataTypeCaption[kdtInteger]]);
      s := (dv as tKlausVarValueSimple).simple.sValue;
      if s <> '' then try
        p := pChar(s);
        if reverse then begin
          p += length(s);
          while p > pChar(s) do try
            p := u8SkipCharsLeft(p, pChar(s), 1);
            kv.setSimple(klausSimple(p-pChar(s)), key.point);
            body.run(frame);
          except
            on eKlausContinue do;
            else raise;
          end
        end else begin
          while p^ <> #0 do try
            kv.setSimple(klausSimple(p-pChar(s)), key.point);
            body.run(frame);
            p := u8SkipChars(p, 1);
          except
            on eKlausContinue do;
            else raise;
          end;
        end;
      except
        on eKlausBreak do;
        else raise;
      end;
    end else
      raise eKlausError.create(ercInvalidForEachType, dict.point.line, dict.point.pos);
  except
    klausTranslateException(frame, point);
  end;
end;

{ tKlausStmtWhile }

constructor tKlausStmtWhile.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  inherited create(aOwner, aPoint);
  b.next;
  b.check(kkwdWhile);
  b.next;
  b.check('expression');
  fExpr := routine.createExpression(self, b);
  if fExpr.resultType <> kdtBoolean then raise eKlausError.create(ercConditionMustBeBool, fExpr.point.line, fExpr.point.pos);
  b.next;
  b.check(kkwdLoop);
  b.next;
  b.check('statement');
  fBody := routine.createStatement(self, b);
end;

destructor tKlausStmtWhile.destroy;
begin
  freeAndNil(fExpr);
  freeAndNil(fBody);
  inherited destroy;
end;

procedure tKlausStmtWhile.run(frame: tKlausStackFrame);
var
  sv: tKlausSimpleValue;
begin
  try
    try
      while true do try
        klausDebuggerStep(frame, expr.point);
        sv := expr.evaluate(frame, true);
        if sv.dataType <> kdtBoolean then raise eKlausError.create(ercConditionMustBeBool, expr.point.line, expr.point.pos);
        if not sv.bValue then break;
        body.run(frame);
      except
        on eKlausContinue do;
        else raise;
      end;
    except
      on eKlausBreak do;
      else raise;
    end;
  except
    klausTranslateException(frame, point);
  end;
end;

{ tKlausStmtRepeat }

constructor tKlausStmtRepeat.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  inherited create(aOwner, aPoint);
  b.next;
  b.check(kkwdLoop);
  b.next;
  b.check('statement');
  fBody := routine.createStatement(self, b);
  b.next;
  b.check(kkwdWhile);
  b.next;
  b.check('expression');
  fExpr := routine.createExpression(self, b);
  if fExpr.resultType <> kdtBoolean then raise eKlausError.create(ercConditionMustBeBool, fExpr.point.line, fExpr.point.pos);
end;

destructor tKlausStmtRepeat.destroy;
begin
  freeAndNil(fExpr);
  freeAndNil(fBody);
  inherited destroy;
end;

procedure tKlausStmtRepeat.run(frame: tKlausStackFrame);
var
  sv: tKlausSimpleValue;
begin
  try
    try
      while true do try
        body.run(frame);
        klausDebuggerStep(frame, expr.point);
        sv := expr.evaluate(frame, true);
        if sv.dataType <> kdtBoolean then raise eKlausError.create(ercConditionMustBeBool, expr.point.line, expr.point.pos);
        if not sv.bValue then break;
      except
        on eKlausContinue do;
        else raise;
      end;
    except
      on eKlausBreak do;
      else raise;
    end;
  except
    klausTranslateException(frame, point);
  end;
end;

{ tKlausStmtCase }

constructor tKlausStmtCase.create(aOwner: tKlausStmtCtlStruct; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  i, idx: integer;
  kdt: tKlausDataType;
  va: array of record
    v: tKlausSimpleValue;
    pt: tSrcPoint;
  end = nil;
  x: tKlausExpression;
  stmt: tKlausStatement;
  li: tKlausLexInfo;
  sv: tKlausSimpleValue;
begin
  inherited create(aOwner, aPoint);
  b.next;
  b.check(kkwdCase);
  b.next;
  b.check('expression');
  fExpr := routine.createExpression(self, b);
  kdt := expr.resultType;
  if not (kdt in klausSimpleTypes) then raise eKlausError.create(ercCaseExprMustBeSimple, expr.point.line, expr.point.pos);
  b.next;
  if b.check(kkwdAccuracy, false) then begin
    if not (kdt in [kdtFloat, kdtMoment]) then raise eKlausError.create(ercAccuracyNotApplicable, b.lex.line, b.lex.pos);
    b.next;
    li := b.lex;
    b.pause;
    sv := routine.createConstExpression(b);
    if not klausCanAssign(sv.dataType, kdtFloat) then raise eKlausError.create(ercTypeMismatch, li.line, li.pos);
    fAccuracy := klausTypecast(sv, kdtFloat, srcPoint(li)).fValue;
    if fAccuracy < 0 then raise eKlausError.create(ercNegativeAccuracy, li.line, li.pos);
    b.next;
  end else
    fAccuracy := 0;
  fItemMap := tKlausMap.create(kdt, fAccuracy);
  fItemMap.sorted := true;
  fItemMap.duplicates := dupError;
  b.check(kkwdOf);
  b.next;
  b.check('case_body');
  b.next;
  while b.check('case_item', false) do begin
    idx := 0;
    repeat
      setLength(va, idx+1);
      b.next;
      b.check('expression');
      x := routine.createExpression(self, b);
      try
        va[idx].v := x.evaluate;
        va[idx].pt := x.point;
      finally
        freeAndNIL(x);
      end;
      idx += 1;
      b.next;
      if not b.check(klsComma, false) then break;
    until false;
    b.check(klsColon);
    b.next;
    b.check('statement');
    stmt := routine.createStatement(self, b);
    b.next;
    b.check(klsSemicolon);
    for i := 0 to length(va)-1 do begin
      if klausCanAssign(va[i].v.dataType, kdt) then va[i].v := klausTypecast(va[i].v, kdt, va[i].pt)
      else raise eKlausError.create(ercTypeMismatch, va[i].pt.line, va[i].pt.pos);
      idx := fItemMap.indexOf(va[i].v);
      if idx >= 0 then raise eKlausError.create(ercDuplicateCaseLabel, va[i].pt.line, va[i].pt.pos);
      fItemMap.add(va[i].v, stmt);
    end;
    b.next;
  end;
  if b.check('case_else', false) then begin
    b.next;
    b.check(kkwdElse);
    b.next;
    b.check('statement');
    fElseStmt := routine.createStatement(self, b);
    b.next;
    b.check(klsSemicolon);
    b.next;
  end else
    fElseStmt := nil;
  b.check(kkwdEnd);
end;

destructor tKlausStmtCase.destroy;
var
  i: integer;
begin
  for i := count-1 downto 0 do items[i].free;
  freeAndNil(fExpr);
  freeAndNil(fItemMap);
  inherited destroy;
end;

procedure tKlausStmtCase.run(frame: tKlausStackFrame);
var
  stmt: tKlausStatement;
  sv: tKlausSimpleValue;
begin
  try
    klausDebuggerStep(frame, expr.point);
    sv := expr.evaluate(frame, true);
    if sv.dataType <> fItemMap.keyType then raise eKlausError.create(ercTypeMismatch, expr.point.line, expr.point.pos);
    stmt := findItem(sv);
    if stmt <> nil then stmt.run(frame);
  except
    klausTranslateException(frame, point);
  end;
end;

function tKlausStmtCase.getCount: integer;
begin
  result := length(fItems);
end;

function tKlausStmtCase.getItems(idx: integer): tKlausStatement;
begin
  assert((idx >= 0) and (idx < count), 'Invalid item index');
  result := fItems[idx];
end;

procedure tKlausStmtCase.addItem(item: tKlausStatement);
var
  idx: integer;
begin
  idx := length(fItems);
  setLength(fItems, idx+1);
  fItems[idx] := item;
end;

procedure tKlausStmtCase.removeItem(item: tKlausStatement);
var
  idx: integer;
begin
  if fDestroying then exit;
  idx := length(fItems)-1;
  assert(fItems[idx] = item, 'Only the last item in the list may be removed');
  setLength(fItems, idx);
end;

function tKlausStmtCase.findItem(const key: tKlausSimpleValue): tKlausStatement;
var
  idx: integer;
begin
  idx := fItemMap.indexOf(key);
  if idx < 0 then result := fElseStmt
  else result := tKlausStatement(fItemMap.data[idx]);
end;

{ tKlausProcParam }

constructor tKlausProcParam.create(aOwner: tKlausRoutine; aName: string; aPoint: tSrcPoint; aMode: tKlausProcParamMode; aDataType: tKlausTypeDef);
begin
  fMode := aMode;
  if aName = '' then aName := klausResultParamName;
  inherited create(aOwner, aName, aPoint, aDataType, nil);
end;

{ tKlausProcDecl }

constructor tKlausProcDecl.create(aOwner: tKlausRoutine; aName: string; aPoint: tSrcPoint);
begin
  inherited create(aOwner, aName, aPoint);
  fImplPos := position;
end;

constructor tKlausProcDecl.createHeader(aOwner: tKlausRoutine; aName: string; isFunc: boolean; b: tKlausSyntaxBrowser);
var
  p: tSrcPoint;
  i, idx: integer;
  dt: tKlausTypeDef;
  mode: tKlausProcParamMode;
  nms: array of tKlausLexInfo = nil;
begin
  create(aOwner, aName, srcPoint(b.lex));
  b.next;
  b.check(klsParOpen);
  b.next;
  if b.check('param', false) then begin
    repeat
      idx := 0;
      b.next;
      mode := kpmInput;
      if b.check([kkwdInput, kkwdOutput, kkwdInOut], false) <> kkwdInvalid then begin
        case b.lex.keyword of
          kkwdOutput: mode := kpmOutput;
          kkwdInOut: mode := kpmInOut;
        end;
        b.next;
      end;
      b.check(klxID);
      setLength(nms, idx+1);
      nms[idx] := b.lex;
      b.next;
      while b.check(klsComma, false) do begin
        idx += 1;
        b.next;
        b.check(klxID);
        setLength(nms, idx+1);
        nms[idx] := b.lex;
        b.next;
      end;
      b.check(klsColon);
      b.next;
      b.check('type_id');
      dt := owner.createDataTypeID(b, true);
      for i := 0 to idx do begin
        if find(u8Lower(nms[i].text), knsLocal) <> nil then
          raise eKlausError.createFmt(ercDuplicateName, nms[i].line, nms[i].pos, [nms[i].text]);
        addParam(tKlausProcParam.create(self, nms[i].text, srcPoint(nms[i]), mode, dt));
      end;
      b.next;
      if not b.check(klsSemicolon, false) then break;
      b.next;
    until false;
  end;
  b.check(klsParClose);
  b.next;
  if isFunc then begin
    b.check(klsColon);
    b.next;
    p := srcPoint(b.lex);
    dt := owner.createDataTypeID(b, true);
    setRetValue(tKlausProcParam.create(self, klausResultParamName, p, kpmOutput, dt));
    b.next;
  end else
    fRetValue := nil;
  b.check(klsSemicolon);
end;

constructor tKlausProcDecl.create(aOwner: tKlausRoutine; aName: string; isFunc: boolean; b: tKlausSyntaxBrowser);
begin
  createHeader(aOwner, aName, isFunc, b);
  b.next;
  if b.check(kkwdForward, false) then
    fFwd := true
  else begin
    b.check('routine');
    createRoutine(b);
  end;
end;

procedure tKlausProcDecl.resolveForwardDeclaration(isFunc: boolean; b: tKlausSyntaxBrowser);
var
  pd: tKlausProcDecl;
begin
  pd := tKlausProcDecl.createHeader(owner, '$$fwd$$'+name, isFunc, b);
  try
    if not pd.matchHeader(self) then raise eKlausError.create(ercWrongForwardSignature, pd.point);
    fImplPos := pd.position;
  finally
    freeAndNil(pd);
  end;
  b.next;
  if b.check(kkwdForward, false) then raise eKlausError.create(ercDuplicateForward, b.lex.line, b.lex.pos);
  fFwd := false;
  b.check('routine');
  createRoutine(b);
end;

function tKlausProcDecl.matchHeader(pd: tKlausProcDecl): boolean;
var
  i: integer;
  p: tKlausProcParam;
begin
  result := false;
  if retValue <> nil then begin
    if pd.retValue = nil then exit;
    if retValue.dataType <> pd.retValue.dataType then exit;
  end else
    if pd.retValue <> nil then exit;
  if paramCount <> pd.paramCount then exit;
  for i := 0 to paramCount-1 do begin
    p := pd.params[i];
    with params[i] do begin
      if u8Lower(name) <> u8Lower(p.name) then exit;
      if mode <> p.mode then exit;
      if dataType <> p.dataType then exit;
      //if klausCompare(initial, p.initial, point) <> 0 then exit;
    end;
  end;
  result := true;
end;

function tKlausProcDecl.getIsFunction: boolean;
begin
  result := fRetValue <> nil;
end;

function tKlausProcDecl.getDisplayName: string;
begin
  if isFunction then result := strFunction + ' ' + name
  else result := strProcedure + ' ' + name;
end;

{ tKlausInternalProcDecl }

function tKlausInternalProcDecl.isCustomParamHandler: boolean;
begin
  result := false;
end;

procedure tKlausInternalProcDecl.getCustomParamModes(types: array of tKlausTypeDef; out modes: tKlausProcParamModes; const at: tSrcPoint);
begin
  assert(false, 'This method must be overriden for custom parameter handling');
end;

procedure tKlausInternalProcDecl.customRun(frame: tKlausStackFrame; values: array of tKlausVarValueAt; const at: tSrcPoint);
begin
  assert(false, 'This method must be overriden for custom parameter handling');
end;

{ tKlausExceptDecl }

constructor tKlausExceptDecl.create(aOwner: tKlausRoutine; aName: string; aPoint: tSrcPoint; aMsg: string);
begin
  inherited create(aOwner, aName, aPoint);
  fData := source.simpleExceptType;
  fMessage := aMsg;
end;

constructor tKlausExceptDecl.create(aOwner: tKlausRoutine; aName: string; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  n: string;
  i, idx: integer;
  dt: tKlausTypeDef;
  nms: array of tKlausLexInfo = nil;
begin
  inherited create(aOwner, aName, aPoint);
  b.next;
  if b.check(klsParOpen, false) then begin
    fData := source.createExceptionTypeDef;
    repeat
      b.next;
      b.check('exception_param');
      idx := 0;
      b.next;
      if b.check(kkwdInput, false) then b.next;
      b.check(klxID);
      setLength(nms, idx+1);
      nms[idx] := b.lex;
      b.next;
      while b.check(klsComma, false) do begin
        idx += 1;
        b.next;
        b.check(klxID);
        setLength(nms, idx+1);
        nms[idx] := b.lex;
        b.next;
      end;
      b.check(klsColon);
      dt := owner.createSimpleType(b, true);
      for i := 0 to idx do begin
        n := u8Lower(nms[i].text);
        if fData.member[n] <> nil then
          raise eKlausError.createFmt(ercDuplicateName, nms[i].line, nms[i].pos, [nms[i].text]);
        tKlausStructMember.create(fData, nms[i].text, srcPoint(nms[i]), dt);
      end;
      b.next;
    until not b.check(klsSemicolon, false);
    b.check(klsParClose);
    b.next;
  end else
    fData := source.simpleExceptType;
  if b.check(kkwdMessage, false) then begin
    b.next;
    fMessage := b.get(klxString).sValue;
  end else begin
    fMessage := '';
    b.pause;
  end;
end;

{ tKlausVarDecl }

function tKlausVarDecl.getHidden: boolean;
begin
  if name = '' then exit(true);
  if name[1] = '$' then exit(true);
  result := false;
end;

function tKlausVarDecl.getDataType: tKlausTypeDef;
begin
  result := fDataType;
end;

constructor tKlausVarDecl.create(aOwner: tKlausRoutine; aNames: array of string; aPoint: tSrcPoint; aDataType: tKlausTypeDef; aInitial: tKlausVarValue);
begin
  inherited create(aOwner, aNames, aPoint);
  fDataType := aDataType;
  if aInitial <> nil then begin
    if not fDataType.canAssign(aInitial.dataType) then raise eKlausError.create(ercTypeMismatch, point);
    fInitial := aInitial;
    fInitial.acquire;
  end else
    fInitial := nil;
end;

destructor tKlausVarDecl.destroy;
begin
  releaseAndNil(fInitial);
  inherited destroy;
end;

procedure tKlausVarDecl.initialize(v: tKlausVariable);
begin
  if fInitial <> nil then
    v.acquireValue(fInitial, point);
end;

{ tKlausConstDecl }

constructor tKlausConstDecl.create(aOwner: tKlausRoutine; aNames: array of string; aPoint: tSrcPoint; const val: tKlausSimpleValue);
begin
  inherited create(aOwner, aNames, aPoint);
  fValue := tKlausVarValueSimple.create(source.simpleTypes[val.dataType]);
  (fValue as tKlausVarValueSimple).setSimple(val, aPoint);
end;

constructor tKlausConstDecl.create(aOwner: tKlausRoutine; aNames: array of string; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  p: tSrcPoint;
  dt: tKlausTypeDef;
  sv: tKlausSimpleValue;
  expr: tKlausExpression;
  v: tKlausVarValue;
begin
  inherited create(aOwner, aNames, aPoint);
  p := srcPoint(b.lex);
  b.next;
  if b.check(klsColon, false) then begin
    dt := owner.createDataType(b);
    b.next;
    b.check(klsEq);
    b.next;
    expr := owner.createExpression(owner.body, b, dt);
    v := expr.acquireVarValue;
    if v <> nil then begin
      fValue := dt.valueClass.create(dt);
      try fValue.assign(v, expr.point);
      finally releaseAndNil(v); end;
    end else begin
      sv := expr.evaluate;
      fValue := tKlausVarValueSimple.create(dt);
      (fValue as tKlausVarValueSimple).setSimple(sv, p);
    end;
  end else begin
    b.check(klsEq);
    sv := owner.createConstExpression(b);
    fValue := tKlausVarValueSimple.create(source.simpleTypes[sv.dataType]);
    (fValue as tKlausVarValueSimple).setSimple(sv, p);
  end;
end;

destructor tKlausConstDecl.destroy;
begin
  releaseAndNil(fValue);
  inherited destroy;
end;

function tKlausConstDecl.getDataType: tKlausTypeDef;
begin
  result := fValue.dataType;
end;

{ tKlausTypeDefSimple }

constructor tKlausTypeDefSimple.create(aOwner: tKlausSource; aSimpleType: tKlausSimpleType);
begin
  inherited create(aOwner, srcPoint(1, 1, 0));
  fSimpleType := aSimpleType;
end;

function tKlausTypeDefSimple.getDataType: tKlausDataType;
begin
  result := fSimpleType;
end;

function tKlausTypeDefSimple.canAssign(src: tKlausTypeDef; strict: boolean = false): boolean;
begin
  if strict then result := src.dataType = self.dataType
  else result := klausCanAssign(src.dataType, self.dataType);
end;

function tKlausTypeDefSimple.zeroValue: tKlausSimpleValue;
begin
  result := klausZeroValue(simpleType);
end;

function tKlausTypeDefSimple.valueClass: tKlausVarValueClass;
begin
  result := tKlausVarValueSimple;
end;

{ tKlausTypeDef }

constructor tKlausTypeDef.create(aOwner: tKlausSource; aPoint: tSrcPoint);
begin
  inherited create;
  fPoint := aPoint;
  fOwner := aOwner;
  fOwner.addType(self);
end;

destructor tKlausTypeDef.destroy;
begin
  fOwner.removeType(self);
  inherited destroy;
end;

function tKlausTypeDef.canAssign(src: tKlausTypeDef; strict: boolean = false): boolean;
begin
  result := false;
end;

function tKlausTypeDef.canAssign(src: tKlausDataType; strict: boolean = false): boolean;
begin
  if not (src in klausSimpleTypes) then result := false
  else result := canAssign(owner.simpleTypes[src], strict);
end;

function tKlausTypeDef.canAssign(src: tKlausSimpleValue; strict: boolean = false): boolean;
begin
  result := canAssign(src.dataType, strict);
end;

function tKlausTypeDef.getDataType: tKlausDataType;
begin
  result := kdtComplex;
end;

function tKlausTypeDef.zeroValue: tKlausSimpleValue;
begin
  result := klausZeroValue(kdtString);
end;

function tKlausTypeDef.literalClass: tKlausOpndCompoundClass;
begin
  result := nil;
end;

{ tKlausSource }

constructor tKlausSource.create(p: tKlausLexParser);

  {$ifdef enableLogging}
  procedure logTree(node: tKlausSrcNodeRule);
  var
    i: integer;
  begin
    if node.rule = nil then logln('program', '<root>'#10)
    else logln('program', '%s', [#10'<'+node.rule.name+'>'#10]);
    for i := 0 to node.count-1 do
      if node.items[i] is tKlausSrcNodeRule then
        logTree(node.items[i] as tKlausSrcNodeRule)
      else if node.items[i] is tKlausSrcNodeLexem then
        logln('program', '%s', [(node.items[i] as tKlausSrcNodeLexem).lexInfo.text + ' ']);
  end;
  {$endIf}

var
  t: tKlausSimpleType;
  n: tKlausSrcNodeRule;
  syn: tKlausSyntax;
begin
  fDestroying := false;
  inherited create;
  fTypes := tFPList.create;
  for t := low(t) to high(t) do begin
    fSimpleTypes[t] := tKlausTypeDefSimple.create(self, t);
    fArrayTypes[t] := tKlausTypeDefArray.create(self, t);
  end;
  fSimpleExceptType := createExceptionTypeDef;
  fUnits := tStringList.create;
  fUnits.sorted := true;
  fUnits.caseSensitive := false;
  fUnits.duplicates := dupError;
  fSystemUnit := tKlausUnitSystem.create(self);
  syn := tKlausSyntax.create;
  try
    syn.setParser(p);
    syn.build;
    {$ifdef enableLogging}logTree(syn.tree);{$endIf}
    n := syn.tree.find('program');
    if n <> nil then fModule := createProgram(n)
    else raise eKlausError.create(ercUnexpectedSyntax, 1, 1);
  finally
    freeAndNil(syn);
  end;
end;

destructor tKlausSource.destroy;
var
  i: integer;
begin
  freeAndNil(fModule);
  for i := unitCount-1 downto 0 do units[i].free;
  freeAndNil(fUnits);
  for i := typeCount-1 downto 0 do types[i].free;
  freeAndNil(fTypes);
  inherited destroy;
end;

procedure tKlausSource.beforeDestruction;
begin
  fDestroying := true;
  inherited beforeDestruction;
end;

function tKlausSource.createExceptionTypeDef: tKlausTypeDefStruct;
begin
  result := tKlausTypeDefStruct.create(self, zeroSrcPt);
  tKlausStructMember.create(result, klausExceptionMessageFieldName, zeroSrcPt, simpleTypes[kdtString]);
end;

function tKlausSource.getTypeCount: integer;
begin
  result := fTypes.count;
end;

function tKlausSource.getSimpleTypes(t: tKlausSimpleType): tKlausTypeDefSimple;
begin
  result := fSimpleTypes[t];
end;

function tKlausSource.getArrayTypes(t: tKlausSimpleType): tKlausTypeDefArray;
begin
  result := fArrayTypes[t];
end;

function tKlausSource.getTypes(idx: integer): tKlausTypeDef;
begin
  assert((idx >= 0) and (idx < typeCount), 'Invalid item index');
  result := tKlausTypeDef(fTypes[idx]);
end;

function tKlausSource.addType(aType: tKlausTypeDef): integer;
begin
  result := fTypes.add(aType);
end;

function tKlausSource.getUnitCount: integer;
begin
  result := fUnits.count;
end;

function tKlausSource.getUnits(idx: integer): tKlausUnit;
begin
  assert((idx >= 0) and (idx < unitCount), 'Invalid item index');
  result := fUnits.objects[idx] as tklausUnit;
end;

procedure tKlausSource.addUnit(aUnit: tKlausUnit);
begin
  fUnits.addObject(u8Lower(aUnit.name), aUnit);
end;

procedure tKlausSource.removeUnit(aUnit: tKlausUnit);
var
  idx: integer;
begin
  if not fDestroying then begin
    idx := fUnits.indexOfObject(aUnit);
    if idx >= 0 then fUnits.delete(idx);
  end;
end;

procedure tKlausSource.removeType(aType: tKlausTypeDef);
begin
  if not fDestroying then fTypes.remove(aType);
end;

function tKlausSource.createProgram(prog: tKlausSrcNodeRule): tKlausProgram;
var
  s: string;
  b: tKlausSyntaxBrowser;
begin
  b := tKlausSyntaxBrowser.create(prog);
  try
    b.next;
    b.check(kkwdProgram);
    b.next;
    s := b.get(klxID).text;
    result := tKlausProgram.create(self, s, srcPoint(b.lex), b);
    b.next;
    b.check(klsDot);
  finally
    freeAndNil(b);
  end;
end;

{ tKlausStructMember }

constructor tKlausStructMember.create(aOwner: tKlausTypeDefStruct; aName: string; aPoint: tSrcPoint; aDataType: tKlausTypeDef);
begin
  inherited create;
  fOwner := aOwner;
  fName := aName;
  fDataType := aDataType;
  fPoint := aPoint;
  fOwner.addMember(self);
end;

destructor tKlausStructMember.destroy;
begin
  fOwner.removeMember(self);
  inherited destroy;
end;

{ tKlausTypeDefStruct }

constructor tKlausTypeDefStruct.create(aOwner: tKlausSource; aPoint: tSrcPoint);
begin
  fDestroying := false;
  inherited create(aOwner, aPoint);
  fMembers := tStringList.create;
  fMembers.sorted := true;
  fMembers.caseSensitive := false;
  fMembers.duplicates := dupError;
end;

constructor tKlausTypeDefStruct.create(context: tKlausRoutine; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  n: string;
  i: integer;
  idx: integer;
  nms: array of tKlausLexInfo = nil;
  req: boolean = true;
  dt: tKlausTypeDef;
begin
  create(context.source, aPoint);
  b.next;
  b.check(kkwdStruct);
  b.next;
  b.check('struct_body');
  b.next;
  while b.check('struct_field', req) do begin
    idx := 0;
    b.next;
    b.check(klxID);
    setLength(nms, idx+1);
    nms[idx] := b.lex;
    b.next;
    while b.check(klsComma, false) do begin
      idx += 1;
      b.next;
      b.check(klxID);
      setLength(nms, idx+1);
      nms[idx] := b.lex;
      b.next;
    end;
    b.check(klsColon);
    dt := context.createDataType(b);
    for i := 0 to idx do begin
      n := u8Lower(nms[i].text);
      if fMembers.indexOf(n) >= 0 then
        raise eKlausError.createFmt(ercDuplicateName, nms[i].line, nms[i].pos, [nms[i].text]);
      tKlausStructMember.create(self, nms[i].text, srcPoint(nms[i]), dt);
    end;
    req := false;
    b.next;
    b.check(klsSemicolon);
    b.next;
  end;
  b.check(kkwdEnd);
end;

destructor tKlausTypeDefStruct.destroy;
var
  i: integer;
begin
  for i := count-1 downto 0 do members[i].free;
  freeAndNil(fMembers);
  inherited destroy;
end;

procedure tKlausTypeDefStruct.beforeDestruction;
begin
  fDestroying := true;
  inherited;
end;

function tKlausTypeDefStruct.canAssign(src: tKlausTypeDef; strict: boolean = false): boolean;
var
  i: integer;
  m: tKlausStructMember;
begin
  if src = self then exit(true);
  if not(src is tKlausTypeDefStruct) then exit(false);
  if tKlausTypeDefStruct(src).count <> count then exit(false);
  for i := 0 to count-1 do begin
    m := tKlausTypeDefStruct(src).member[members[i].name];
    if m = nil then exit(false);
    if not members[i].dataType.canAssign(m.dataType, strict) then exit(false);
  end;
  result := true;
end;

function tKlausTypeDefStruct.valueClass: tKlausVarValueClass;
begin
  result := tKlausVarValueStruct;
end;

function tKlausTypeDefStruct.literalClass: tKlausOpndCompoundClass;
begin
  result := tKlausOpndStruct;
end;

function tKlausTypeDefStruct.getCount: integer;
begin
  result := length(fMemberOrder);
end;

function tKlausTypeDefStruct.getMember(const m: string): tKlausStructMember;
var
  idx: integer;
begin
  idx := fMembers.indexOf(u8Lower(m));
  if idx < 0 then result := nil
  else result := tKlausStructMember(fMembers.objects[idx]);
end;

function tKlausTypeDefStruct.getMembers(idx: integer): tKlausStructMember;
begin
  assert((idx >= 0) and (idx < count), 'Invalid item index');
  result := fMemberOrder[idx];
end;

procedure tKlausTypeDefStruct.addMember(m: tKlausStructMember);
var
  idx: integer;
begin
  fMembers.addObject(u8Lower(m.name), m);
  idx := length(fMemberOrder);
  setLength(fMemberOrder, idx+1);
  fMemberOrder[idx] := m;
end;

procedure tKlausTypeDefStruct.removeMember(m: tKlausStructMember);
var
  idx: integer;
begin
  if fDestroying then exit;
  idx := length(fMemberOrder)-1;
  assert(idx >= 0, 'Invalid item index');
  assert(fMemberOrder[idx] = m, 'Only the last item in the list may be removed');
  setLength(fMemberOrder, idx);
  idx := fMembers.IndexOfObject(m);
  if idx >= 0 then fMembers.delete(idx);
end;

{ tKlausTypeDefDict }

constructor tKlausTypeDefDict.create(context: tKlausRoutine; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  li: tKlausLexInfo;
  sv: tKlausSimpleValue;
begin
  inherited create(context.source, aPoint);
  b.next;
  b.check(kkwdDict);
  fValueType := context.createDataType(b);
  b.next;
  b.check(kkwdKey);
  fKeyType := context.createSimpleType(b, true).simpleType;
  b.next;
  if b.check(kkwdAccuracy, false) then begin
    if not (fKeyType in [kdtFloat, kdtMoment]) then raise eKlausError.create(ercAccuracyNotApplicable, b.lex.line, b.lex.pos);
    b.next;
    li := b.lex;
    b.pause;
    sv := context.createConstExpression(b);
    if not klausCanAssign(sv.dataType, kdtFloat) then raise eKlausError.create(ercTypeMismatch, li.line, li.pos);
    fAccuracy := klausTypecast(sv, kdtFloat, srcPoint(li)).fValue;
    if fAccuracy < 0 then raise eKlausError.create(ercNegativeAccuracy, li.line, li.pos);
  end else begin
    fAccuracy := 0;
    b.pause;
  end;
end;

function tKlausTypeDefDict.canAssign(src: tKlausTypeDef; strict: boolean = false): boolean;
begin
  if src = self then exit(true);
  if not(src is tKlausTypeDefDict) then exit(false);
  if tKlausTypeDefDict(src).keyType <> keyType then exit(false);
  result := valueType.canAssign(tKlausTypeDefDict(src).valueType, strict);
end;

function tKlausTypeDefDict.valueClass: tKlausVarValueClass;
begin
  result := tKlausVarValueDict;
end;

function tKlausTypeDefDict.literalClass: tKlausOpndCompoundClass;
begin
  result := tKlausOpndDict;
end;

{ tKlausTypeDefArray }

constructor tKlausTypeDefArray.create(context: tKlausRoutine; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  cnt: integer = 1;
  dt: tKlausTypeDef;
begin
  inherited create(context.source, aPoint);
  b.next;
  b.check(kkwdArray);
  b.next;
  while b.check(kkwdArray, false) do begin
     inc(cnt);
     b.next;
  end;
  b.pause;
  dt := context.createDataType(b);
  if cnt <= 1 then fElmtType := dt
  else fElmtType := tKlausTypeDefArray.create(context.source, aPoint, cnt-1, dt);
end;

constructor tKlausTypeDefArray.create(source: tKlausSource; aPoint: tSrcPoint; aDims: integer; aElmtType: tKlausTypeDef);
begin
  inherited create(source, aPoint);
  if aDims <= 1 then fElmtType := aElmtType
  else fElmtType := tKlausTypeDefArray.create(source, aPoint, aDims-1, aElmtType);
end;

constructor tKlausTypeDefArray.create(aOwner: tKlausSource; aElmtType: tKlausDataType);
begin
  inherited create(aOwner, zeroSrcPt);
  fElmtType := owner.simpleTypes[aElmtType];
end;

function tKlausTypeDefArray.canAssign(src: tKlausTypeDef; strict: boolean = false): boolean;
begin
  if src = self then exit(true);
  if not(src is tKlausTypeDefArray) then exit(false);
  result := elmtType.canAssign((src as tKlausTypeDefArray).elmtType, strict);
end;

function tKlausTypeDefArray.valueClass: tKlausVarValueClass;
begin
  result := tKlausVarValueArray;
end;

function tKlausTypeDefArray.literalClass: tKlausOpndCompoundClass;
begin
  result := tKlausOpndArray;
end;

{ tKlausTypeDecl }

constructor tKlausTypeDecl.create(aOwner: tKlausRoutine; aNames: array of string; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
begin
  inherited create(aOwner, aNames, aPoint);
  fDataType := owner.createDataType(b);
end;

constructor tKlausTypeDecl.create(aOwner: tKlausRoutine; aNames: array of string; aPoint: tSrcPoint; def: tKlausTypeDef);
begin
  inherited create(aOwner, aNames, aPoint);
  fDataType := def;
end;

{ tKlausDecl }

constructor tKlausDecl.create(aOwner: tKlausRoutine; aNames: array of string; aPoint: tSrcPoint);
var
  i: integer;
begin
  inherited create;
  assert(length(aNames) > 0, 'A named declaration must have at least one name.');
  fName := aNames[0];
  setLength(fAltNames, length(aNames)-1);
  for i := 1 to length(aNames)-1 do fAltNames[i-1] := aNames[i];
  fPoint := aPoint;
  if assigned(aOwner) then begin
    fOwner := aOwner;
    fPosition := fOwner.declCount;
    fOwner.addDecl(self);
  end else
    fPosition := -1;
end;

destructor tKlausDecl.destroy;
begin
  if assigned(fOwner) then fOwner.removeDecl(self);
  inherited destroy;
end;

function tKlausDecl.hasName(s: string): boolean;
var
  i: integer;
begin
  s := u8Lower(s);
  if s = u8Lower(fName) then exit(true);
  for i := 0 to length(fAltNames)-1 do
    if s = u8Lower(fAltNames[i]) then exit(true);
  result := false;
end;

function tKlausDecl.getNameCount: integer;
begin
  result := length(fAltNames) + 1;
end;

function tKlausDecl.getNames(idx: integer): string;
begin
  if idx = 0 then
    result := fName
  else begin
    assert((idx > 0) and (idx <= length(fAltNames)), 'Invalid item index');
    result := fAltNames[idx-1];
  end;
end;

function tKlausDecl.getSource: tKlausSource;
begin
  if owner = nil then result := nil
  else result := owner.source;
end;

function tKlausDecl.getUpperScope: tKlausRoutine;
begin
  result := owner;
end;

{ tKlausSyntaxBrowser }

constructor tKlausSyntaxBrowser.create(aRoot: tKlausSrcNodeRule);
begin
  inherited create;
  assert(aRoot.parent <> nil, 'Invalid source tree');
  fRoot := aRoot;
  fCur := fRoot;
  fPause := false;
  updateCurLexInfo;
end;

procedure tKlausSyntaxBrowser.updateCurLexInfo;
var
  save: tKlausSrcNode;
begin
  if fCur = nil then exit;
  save := fCur;
  try
    while cur is tKlausSrcNodeRule do next;
    assert(cur is tKlausSrcNodeLexem, 'Invalid source tree');
    fLex := (cur as tKlausSrcNodeLexem).lexInfo
  finally
    fCur := save;
  end;
end;

procedure tKlausSyntaxBrowser.next;
var
  idx, nextLexem: integer;
begin
  if fPause then begin fPause := false; exit; end;
  try
    if fCur is tKlausSrcNodeRule then begin
      assert((fCur as tKlausSrcNodeRule).count > 0, 'Invalid source tree');
      fCur := (fCur as tKlausSrcNodeRule).items[0];
    end else if fCur is tKlausSrcNodeLexem then begin
      with fCur as tKlausSrcNodeLexem do
        nextLexem := min(lexIdx+1, syntax.lexCount-1);
      idx := fCur.index;
      while idx >= fCur.parent.count - 1 do begin
        if fCur = fRoot then begin fCur := nil; exit; end;
        fCur := fCur.parent;
        idx := fCur.index;
      end;
      fCur := fCur.parent.items[idx+1];
      fLex := fCur.syntax.lexInfo[nextLexem];
    end else
      assert(false, 'Invalid source tree');
  finally
    updateCurLexInfo;
  end;
end;

procedure tKlausSyntaxBrowser.pause;
begin
  fPause := true;
end;

function tKlausSyntaxBrowser.check(aKwd: tKlausValidKeyword; require: boolean): boolean;
begin
  try
    if not (cur is tKlausSrcNodeLexem) then exit(false);
    if lex.lexem <> klxKeyword then exit(false);
    if lex.keyword <> aKwd then exit(false);
    result := true;
  finally
    if not result and require then
      raise eKlausError.create(ercUnexpectedSyntax, lex.line, lex.pos);
  end;
end;

function tKlausSyntaxBrowser.check(aKwd: tKlausValidKeywords; require: boolean): tKlausKeyword;
begin
  try
    if not (cur is tKlausSrcNodeLexem) then exit(kkwdInvalid);
    if lex.lexem <> klxKeyword then exit(kkwdInvalid);
    if not (lex.keyword in aKwd) then exit(kkwdInvalid);
    result := lex.keyword;
  finally
    if (result = kkwdInvalid) and require then
      raise eKlausError.create(ercUnexpectedSyntax, lex.line, lex.pos);
  end;
end;

function tKlausSyntaxBrowser.check(aSym: tKlausValidSymbol; require: boolean): boolean;
begin
  try
    if not (cur is tKlausSrcNodeLexem) then exit(false);
    if lex.lexem <> klxSymbol then exit(false);
    if lex.symbol <> aSym then exit(false);
    result := true;
  finally
    if not result and require then
      raise eKlausError.create(ercUnexpectedSyntax, lex.line, lex.pos);
  end;
end;

function tKlausSyntaxBrowser.check(aSym: tKlausValidSymbols; require: boolean): tKlausSymbol;
begin
  try
    if not (cur is tKlausSrcNodeLexem) then exit(klsInvalid);
    if lex.lexem <> klxSymbol then exit(klsInvalid);
    if not (lex.symbol in aSym) then exit(klsInvalid);
    result := lex.symbol;
  finally
    if (result = klsInvalid) and require then
      raise eKlausError.create(ercUnexpectedSyntax, lex.line, lex.pos);
  end;
end;

function tKlausSyntaxBrowser.check(aLex: tKlausValidLexem; require: boolean): boolean;
begin
  try
    if not (cur is tKlausSrcNodeLexem) then exit(false);
    if lex.lexem <> aLex then exit(false);
    result := true;
  finally
    if not result and require then
      raise eKlausError.create(ercUnexpectedSyntax, lex.line, lex.pos);
  end;
end;

function tKlausSyntaxBrowser.check(aLex: tKlausValidLexemes; require: boolean): tKlausLexem;
begin
  try
    if not (cur is tKlausSrcNodeLexem) then exit(klxInvalid);
    if not (lex.lexem in aLex) then exit(klxInvalid);
    result := lex.lexem;
  finally
    if (result = klxInvalid) and require then
      raise eKlausError.create(ercUnexpectedSyntax, lex.line, lex.pos);
  end;
end;

function tKlausSyntaxBrowser.check(aRule: string; require: boolean): boolean;
begin
  try
    if not (cur is tKlausSrcNodeRule) then exit(false);
    if u8Lower(aRule) <> (cur as tKlausSrcNodeRule).rule.name then exit(false);
    result := true;
  finally
    if not result and require then
      raise eKlausError.create(ercUnexpectedSyntax, lex.line, lex.pos);
  end;
end;

function tKlausSyntaxBrowser.check(aRule: array of string; require: boolean): integer;
var
  i: integer;
begin
  for i := 0 to length(aRule)-1 do
    if check(aRule[i], false) then exit(i);
  if require then raise eKlausError.create(ercUnexpectedSyntax, lex.line, lex.pos);
  result := -1;
end;

function tKlausSyntaxBrowser.get(aLex: tKlausValidLexem; require: boolean): tKlausLexInfo;
begin
  try
    if not (cur is tKlausSrcNodeLexem) then exit(klliError);
    if lex.lexem <> aLex then exit(klliError);
    result := lex;
  finally
    if (result.lexem = klxInvalid) and require then
      raise eKlausError.create(ercUnexpectedSyntax, lex.line, lex.pos);
  end;
end;

function tKlausSyntaxBrowser.get(aLex: tKlausValidLexemes; require: boolean
  ): tKlausLexInfo;
begin
  try
    if not (cur is tKlausSrcNodeLexem) then exit(klliError);
    if not (lex.lexem in aLex) then exit(klliError);
    result := lex;
  finally
    if (result.lexem = klxInvalid) and require then
      raise eKlausError.create(ercUnexpectedSyntax, lex.line, lex.pos);
  end;
end;

{ tKlausModule }

constructor tKlausModule.create(aSource: tKlausSource; aName: string; aPoint: tSrcPoint);
begin
  fSource := aSource;
  inherited create(nil, aName, aPoint);
  fRetValue := nil;
  fUpperScope := nil;
end;

function tKlausModule.getUpperScope: tKlausRoutine;
begin
  result := fUpperScope;
end;

{ tKlausUnit }

constructor tKlausUnit.create(aSource: tKlausSource; aName: string; aPoint: tSrcPoint);
begin
  inherited create(aSource, aName, aPoint);
  source.addUnit(self);
  fDoneBody := tKlausStmtRoutineBody.create(self, srcPoint(1, 1, 0));
end;

destructor tKlausUnit.destroy;
begin
  source.removeUnit(self);
  inherited destroy;
end;

function tKlausUnit.getDisplayName: string;
begin
  result := strUnit + ' ' + name;
end;

procedure tKlausUnit.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  nextFrame: tKlausStackFrame;
begin
  beforeInit(frame);
  try
    if assigned(initBody) then initBody.run(frame);
    try
      if assigned(next) then begin
        nextFrame := tKlausStackFrame.create(frame.owner, next, at);
        try
          frame.owner.push(nextFrame);
          try
            try
              next.run(nextFrame, next.point);
            except
              on eKlausReturn do;
              else raise;
            end;
          finally
            frame.owner.pop(nextFrame);
          end;
        finally
          freeAndNil(nextFrame);
        end;
      end;
    finally
      if assigned(doneBody) then doneBody.run(frame);
    end;
  finally
    afterDone(frame);
  end;
end;

procedure tKlausUnit.beforeInit(stack: tKlausStackFrame);
begin
end;

procedure tKlausUnit.afterDone(stack: tKlausStackFrame);
begin
end;

{ tKlausProgram }

constructor tKlausProgram.create(aSource: tKlausSource; aName: string; aPoint: tSrcPoint);
begin
  inherited create(aSource, aName, aPoint);
  source.systemUnit.fNext := self; // Здесь будет цепочка зависимостей модулей...
  fUpperScope := source.systemUnit;
  setRetValue(tKlausProcParam.create(self, klausResultParamName, aPoint, kpmOutput, source.simpleTypes[kdtInteger]));
end;

constructor tKlausProgram.create(aSource: tKlausSource; aName: string; aPoint: tSrcPoint; b: tKlausSyntaxBrowser);
var
  arg: tKlausLexInfo;
  dt: tKlausTypeDefArray;
  p: tSrcPoint = (line: 0; pos: 0; absPos: 0);
begin
  create(aSource, aName, aPoint);
  arg := klliError;
  b.next;
  if b.check('program_params', false) then begin
    b.next;
    b.check(klsParOpen);
    b.next;
    if b.check(kkwdInput, false) then b.next;
    p := srcPoint(b.lex);
    arg := b.get(klxID);
    b.next;
    b.check(klsColon);
    b.next;
    b.check(kkwdArray);
    b.next;
    b.check(kkwdString);
    b.next;
    b.check(klsParClose);
    b.next;
  end;
  if arg.lexem = klxID then begin
    if find(arg.text, knsLocal) <> nil then
      raise eKlausError.createFmt(ercDuplicateName, arg.line, arg.pos, [arg.text]);
    dt := source.arrayTypes[kdtString];
    fArgs := tKlausProcParam.create(self, arg.text, p, kpmInput, dt);
    addParam(fArgs);
  end else
    fArgs := nil;
  b.check(klsSemicolon);
  b.next;
  b.check('routine');
  createRoutine(b);
end;

procedure tKlausProgram.run(frame: tKlausStackFrame; const at: tSrcPoint);
var
  v: tKlausVariable;
begin
  if args <> nil then begin
    v := frame.varByDecl(args, args.point) as tKlausVariable;
    v.acquireValue(frame.varByName(klausVarName_CmdLineParams, args.point).value, args.point);
  end;
  try
    inherited run(frame, at);
  except
    on eKlausReturn do;
    else raise;
  end;
  v := frame.varByDecl(retValue, point);
  frame.owner.exitCode := (v.value as tKlausVarValueSimple).simple.iValue;
end;

function tKlausProgram.getDisplayName: string;
begin
  result := strProgram + ' ' + name;
end;

{ tKlausRoutine }

constructor tKlausRoutine.create(aOwner: tKlausRoutine; aName: string; aPoint: tSrcPoint);
begin
  fDestroying := false;
  if aOwner <> nil then fSource := aOwner.source;
  inherited create(aOwner, aName, aPoint);
  fDecls := tStringList.create;
  fDecls.sorted := true;
  fDecls.duplicates := dupError;
  fParams := tFPList.create;
  fBody := tKlausStmtRoutineBody.create(self, srcPoint(1, 1, 0));
end;

destructor tKlausRoutine.destroy;
var
  i: integer;
begin
  freeAndNil(fBody);
  for i := declCount-1 downto 0 do decls[i].free;
  freeAndNil(fDecls);
  freeAndNil(fParams);
  inherited destroy;
end;

procedure tKlausRoutine.beforeDestruction;
begin
  fDestroying := true;
  inherited beforeDestruction;
end;

function tKlausRoutine.getSource: tKlausSource;
begin
  result := fSource;
end;

procedure tKlausRoutine.checkCallParamTypes(expr: array of tKlausExpression; at: tSrcPoint);
var
  i: integer;
  outp: boolean;
begin
  if length(expr) <> paramCount then raise eKlausError.createFmt(ercWrongNumberOfParams, at, [length(expr), intToStr(paramCount)]);
  for i := 0 to length(expr)-1 do begin
    outp := params[i].mode <> kpmInput;
    if outp then begin
      if not expr[i].isVarPath then raise eKlausError.create(ercInvalidOutputParam, expr[i].point);
      if (expr[i].left as tKlausOpndVarPath).path.isConstant then raise eKlausError.create(ercConstOutputParam, expr[i].point);
    end;
    if not params[i].dataType.canAssign(expr[i].resultTypeDef, outp) then raise eKlausError.create(ercTypeMismatch, expr[i].point);
  end;
end;

procedure tKlausRoutine.run(frame: tKlausStackFrame; const at: tSrcPoint);
begin
  try
    body.run(frame);
  except
    klausTranslateException(frame, at);
  end;
end;

function tKlausRoutine.find(aName: string; scope: tKlausNameScope): tKlausDecl;
begin
  result := findDecl(aName, scope, maxInt);
end;

function tKlausRoutine.findDecl(aName: string; scope: tKlausNameScope; before: integer): tKlausDecl;
var
  pos: integer;
  p: tKlausDecl;
begin
  aName := u8Lower(aName);
  result := decl[aName];
  if result <> nil then if result.position >= before then result := nil;
  if (result = nil) and self.hasName(aName) then result := self;
  if (result = nil) and (scope = knsGlobal) then begin
    p := self;
    while p.upperScope <> nil do begin
      if p.upperScope <> p.owner then pos := maxInt
      else if p is tKlausProcDecl then pos := (p as tKlausProcDecl).implPos
      else pos := p.position;
      result := p.upperScope.findDecl(aName, knsGlobal, pos);
      if result <> nil then exit(result);
      p := p.upperScope;
    end;
  end;
end;

procedure tKlausRoutine.addParam(p: tKlausProcParam);
begin
  fParams.add(p);
end;

procedure tKlausRoutine.setRetValue(v: tKlausProcParam);
begin
  fRetValue := v;
end;

function tKlausRoutine.getHidden: boolean;
begin
  if name = '' then exit(true);
  if name[1] = '$' then exit(true);
  result := false;
end;

function tKlausRoutine.getDisplayName: string;
begin
  result := className + ' ' + name;
end;

function tKlausRoutine.getParamCount: integer;
begin
  result := fParams.count;
end;

function tKlausRoutine.getParams(idx: integer): tKlausProcParam;
begin
  assert((idx >= 0) and (idx < paramCount), 'Invalid item index');
  result := tKlausProcParam(fParams[idx]);
end;

procedure tKlausRoutine.createIDs(b: tKlausSyntaxBrowser; out ids: tStringArray; out p: tSrcPoint);
var
  i: integer;
begin
  i := 0;
  ids := nil;
  setLength(ids, 1);
  b.next;
  p := srcPoint(b.lex);
  ids[i] := b.get(klxID).text;
  if find(ids[i], knsLocal) <> nil then raise eKlausError.createFmt(ercDuplicateName, srcPoint(b.lex), [ids[i]]);
  b.next;
  while b.check(klsFDiv, false) do begin
    inc(i);
    setLength(ids, i+1);
    b.next;
    ids[i] := b.get(klxID).text;
    if find(ids[i], knsLocal) <> nil then raise eKlausError.createFmt(ercDuplicateName, srcPoint(b.lex), [ids[i]]);
    b.next;
  end;
  b.pause;
end;

procedure tKlausRoutine.createRoutine(b: tKlausSyntaxBrowser);
var
  i: integer;
begin
  b.next;
  if b.check('declarations', false) then begin
    createDeclarations(b);
    b.next;
  end;
  for i := 0 to declCount-1 do
    if decls[i] is tKlausProcDecl then
      if (decls[i] as tKlausProcDecl).fwd then
        raise eKlausError.create(ercUndefinedForward, decls[i].point);
  b.check('compound');
  fBody.createCompound(b);
end;

function tKlausRoutine.getDeclCount: integer;
begin
  result := length(fDeclOrder);
end;

function tKlausRoutine.getDecl(const d: string): tKlausDecl;
var
  idx: integer;
begin
  idx := fDecls.indexOf(u8Lower(d));
  if idx < 0 then result := nil
  else result := tKlausDecl(fDecls.objects[idx]);
end;

function tKlausRoutine.getDecls(idx: integer): tKlausDecl;
begin
  assert((idx >= 0) and (idx < declCount), 'Invalid item index');
  result := fDeclOrder[idx];
end;

procedure tKlausRoutine.addDecl(item: tKlausDecl);
var
  i, idx: integer;
begin
  idx := length(fDeclOrder);
  setLength(fDeclOrder, idx+1);
  fDeclOrder[idx] := item;
  for i := 0 to item.nameCount-1 do
    fDecls.addObject(u8Lower(item.names[i]), item);
end;

procedure tKlausRoutine.removeDecl(item: tKlausDecl);
var
  idx: integer;
begin
  if fDestroying then exit;
  idx := length(fDeclOrder)-1;
  assert(idx >= 0, 'Invalid item index');
  assert(fDeclOrder[idx] = item, 'Only the last item in the list may be removed');
  setLength(fDeclOrder, idx);
  idx := fDecls.indexOfObject(item);
  while idx >= 0 do begin
    fDecls.delete(idx);
    idx := fDecls.indexOfObject(item);
  end;
end;

function tKlausRoutine.getRetValueType: tKlausTypeDef;
begin
  if retValue = nil then result := nil
  else result := retValue.dataType;
end;

procedure tKlausRoutine.createDeclarations(b: tKlausSyntaxBrowser);
const
  rn: array of string = (
    'var_declarations',
    'const_declarations',
    'type_declarations',
    'exception_declarations',
    'procedure',
    'function');
var
  idx: integer;
begin
  b.next;
  idx := b.check(rn, true);
  repeat
    case idx of
      0: createVarDeclarations(b);
      1: createConstDeclarations(b);
      2: createTypeDeclarations(b);
      3: createExceptDeclarations(b);
      4: createProcDeclaration(b);
      5: createFuncDeclaration(b);
    else
      raise eKlausError.create(ercUnexpectedSyntax, b.lex.line, b.lex.pos);
    end;
    b.next;
    idx := b.check(rn, false);
  until idx < 0;
  b.pause;
end;

procedure tKlausRoutine.createTypeDeclarations(b: tKlausSyntaxBrowser);
var
  ids: tStringArray;
  p: tSrcPoint;
begin
  b.next;
  b.check(kkwdType);
  b.next;
  b.check('type_decl', true);
  repeat
    createIDs(b, ids, p);
    b.next;
    b.check(klsEq);
    tKlausTypeDecl.create(self, ids, p, b);
    b.next;
    b.check(klsSemicolon);
    b.next;
  until not b.check('type_decl', false);
  b.pause;
end;

function tKlausRoutine.createDataType(b: tKlausSyntaxBrowser): tKlausTypeDef;
const
  cplx: array of string = ('type_def_array', 'type_def_dict', 'type_def_struct');
var
  a: tKlausTypeDefArray;
begin
  b.next;
  b.check('type_def');
  result := createDataTypeID(b, false);
  if result <> nil then exit;
  b.next;
  case b.check(cplx) of
    0: begin
      a := tKlausTypeDefArray.create(self, srcPoint(b.lex), b);
      if (a.elmtType is tKlausTypeDefSimple) then begin
        result := source.arrayTypes[(a.elmtType as tKlausTypeDefSimple).dataType];
        freeAndNil(a);
      end else
        result := a;
    end;
    1: result := tKlausTypeDefDict.create(self, srcPoint(b.lex), b);
    2: result := tKlausTypeDefStruct.create(self, srcPoint(b.lex), b);
  else
    raise eKlausError.create(ercUnexpectedSyntax, b.lex.line, b.lex.pos);
  end;
end;

function tKlausRoutine.createDataTypeID(b: tKlausSyntaxBrowser; require: boolean = true): tKlausTypeDef;
var
  li: tKlausLexInfo;
  r: tKlausDecl;
begin
  result := createSimpleType(b, false);
  if result <> nil then exit;
  b.next;
  li := b.get(klxID, require);
  if li.lexem = klxID then begin
    r := find(li.text, knsGlobal);
    if not (r is tKlausTypeDecl) then raise eKlausError.create(ercTypeNameRequired, li.line, li.pos);
    result := tKlausTypeDecl(r).dataType;
  end else begin
    result := nil;
    b.pause;
  end;
end;

function tKlausRoutine.createSimpleType(b: tKlausSyntaxBrowser; require: boolean = true): tKlausTypeDefSimple;
begin
  b.next;
  if b.check('simple_type', require) then begin
    b.next;
    b.check(klausSimpleTypeKwd);
    result := source.simpleTypes[klausKwdToSimpleType[b.lex.keyword]];
  end else begin
    result := nil;
    b.pause;
  end;
end;

function tKlausRoutine.createConstExpression(b: tKlausSyntaxBrowser): tKlausSimpleValue;
var
  expr: tKlausExpression;
begin
  b.next;
  b.check('expression');
  expr := createExpression(body, b);
  try result := expr.evaluate;
  finally freeAndNIL(expr); end;
end;

function tKlausRoutine.createExpression(aStmt: tKlausStatement; b: tKlausSyntaxBrowser; expectedType: tKlausTypeDef = nil): tKlausExpression;

  function doCreateExpression(aUop: tKlausUnaryOperation; aPoint: tSrcPoint): tKlausExpression; forward;

  function createOperand: tKlausOperand;
  const
    uopSym = [low(tKlausUnOpSymbols)..high(tKlausUnOpSymbols)];
    uopKwd = [low(tKlausUnOpKeywords)..high(tKlausUnOpKeywords)];
  var
    p: tSrcPoint;
    kwd: tKlausKeyword;
    uop: tKlausUnaryOperation = kuoInvalid;
  begin
    result := nil;
    b.next;
    p := srcPoint(b.lex);
    if b.check('unary_operation', false) then begin
      b.next;
      kwd := b.check(uopKwd, false);
      if kwd <> kkwdInvalid then uop := klausKwdToUnOp[kwd]
      else uop := klausSymToUnOp[b.check(uopSym)];
      b.next;
    end;
    if b.check('literal', false) then result := tKlausOpndLiteral.create(aStmt, uop, p, b)
    else if b.check('typecast', false) then result := tKlausOpndTypecast.create(aStmt, uop, p, b)
    else if b.check('var_path', false) then result := tKlausOpndVarPath.create(aStmt, uop, p, b)
    else if b.check('exists', false) then result := tKlausOpndExists.create(aStmt, uop, p, b)
    else if b.check('call', false) then result := tKlausOpndCall.create(aStmt, uop, p, b)
    else if b.check(klsParOpen) then begin
      b.next;
      b.check('expression');
      result := doCreateExpression(uop, p);
      b.next;
      b.check(klsParClose);
    end;
  end;

  function doCreateExpression(aUop: tKlausUnaryOperation; aPoint: tSrcPoint): tKlausExpression;
  var
    stack: tFPList;
    queue: tFPList;
    index: integer = 0;

    procedure push(op: tKlausBinaryOperation; opPoint: tSrcPoint);
    var
      expr: tKlausExpression;
    begin
      expr := tKlausExpression.create(aStmt, kuoInvalid, zeroSrcPt);
      expr.op := op;
      expr.opPoint := opPoint;
      stack.add(expr);
    end;

    procedure push(opnd: tKlausOperand);
    begin
      stack.add(opnd);
    end;

    function pop(remove: boolean = true): tKlausExpression;
    begin
      if stack.count = 0 then result := nil
      else result := tKlausExpression(stack[stack.count-1]);
      if remove then stack.delete(stack.count-1);
    end;

    function cmp(op: tKlausBinaryOperation): integer;
    var
      expr: tKlausExpression;
    begin
      expr := pop(false);
      if expr = nil then exit(1);
      result := klausBinOpPriorityCompare(op, expr.op);
    end;

    procedure enqueue(opnd: tKlausOperand);
    begin
      queue.add(opnd);
    end;

    function dequeue: tKlausOperand;
    begin
      if index >= queue.count then exit(nil);
      result := tKlausOperand(queue[index]);
      index += 1;
    end;

    function isop(o: tKlausOperand): boolean;
    begin
      if not (o is tKlausExpression) then exit(false);
      if (o as tKlausExpression).left <> nil then exit(false);
      result := true;
    end;

    function build: tKlausExpression;
    var
      expr: tKlausOperand;
    begin
      result := nil;
      repeat
        expr := dequeue;
        if isop(expr) then begin
          result := expr as tKlausExpression;
          result.right := pop;
          result.left := pop;
          push(result);
        end else
          push(expr);
      until index >= queue.count;
      if result = nil then begin
        if expr is tKlausExpression then
          result := expr as tKlausExpression
        else begin
          result := tKlausExpression.create(aStmt, kuoInvalid, zeroSrcPt);
          result.left := expr;
        end;
      end;
    end;

  const
    bopSym = [low(tKlausBinOpSymbols)..high(tKlausBinOpSymbols)];
    bopKwd = [kkwdAnd, kkwdOr, kkwdXor];
  var
    r: integer;
    kwd: tKlausKeyword;
    op: tKlausBinaryOperation;
  begin
    stack := tFPList.create;
    queue := tFPList.create;
    try
      repeat
        b.next;
        if b.check('compound_literal', false) then begin
          if expectedType = nil then raise eKlausError.create(ercUntypedCompoundLiteral, srcPoint(b.lex));
          result := tKlausExpression.create(aStmt, kuoInvalid, srcPoint(b.lex));
          if expectedType.literalClass = nil then raise eKlausError.create(ercTypeMismatch, srcPoint(b.lex))
          else result.left := expectedType.literalClass.create(aStmt, expectedType, srcPoint(b.lex), b);
          exit;
        end;
        b.check('operand');
        enqueue(createOperand());
        b.next;
        if not b.check('binary_operation', false) then break;
        b.next;
        kwd := b.check(bopKwd, false);
        if kwd <> kkwdInvalid then op := klausKwdToBinOp[kwd]
        else op := klausSymToBinOp[b.check(bopSym)];
        repeat
          r := cmp(op);
          if r < 0 then enqueue(pop)
          else if r > 0 then push(op, srcPoint(b.lex))
          else begin enqueue(pop); push(op, srcPoint(b.lex)); end;
        until r >= 0;
      until false;
      while stack.count > 0 do enqueue(pop);
      b.pause;
      result := build;
      if aUop <> kuoInvalid then result.uop := aUop;
      result.point := aPoint;
    finally
      freeAndNil(stack);
      freeAndNil(queue);
    end;
  end;

begin
  result := doCreateExpression(kuoInvalid, srcPoint(b.lex));
end;

procedure tKlausRoutine.createConstDeclarations(b: tKlausSyntaxBrowser);
var
  ids: tStringArray;
  p: tSrcPoint;
begin
  b.next;
  b.check(kkwdConst);
  b.next;
  b.check('const_decl', true);
  repeat
    createIDs(b, ids, p);
    tKlausConstDecl.create(self, ids, p, b);
    b.next;
    b.check(klsSemicolon);
    b.next;
  until not b.check('const_decl', false);
  b.pause;
end;

procedure tKlausRoutine.createVarDeclarations(b: tKlausSyntaxBrowser);
var
  i: integer;
  idx: integer;
  nms: array of record
    n: tStringArray;
    p: tSrcPoint;
  end = nil;
  dt: tKlausTypeDef;
  v: tKlausVarValue;
  sv: tKlausSimpleValue;
  li: tKlausLexInfo;
  expr: tKlausExpression;
begin
  b.next;
  b.check(kkwdVar);
  b.next;
  b.check('var_decl', true);
  repeat
    idx := 0;
    setLength(nms, idx+1);
    createIDs(b, nms[idx].n, nms[idx].p);
    b.next;
    while b.check(klsComma, false) do begin
      idx += 1;
      setLength(nms, idx+1);
      createIDs(b, nms[idx].n, nms[idx].p);
      b.next;
    end;
    b.check(klsColon);
    dt := createDataType(b);
    b.next;
    v := nil;
    try
      if b.check(klsEq, false) then begin
        b.next;
        li := b.lex;
        expr := createExpression(body, b, dt);
        v := expr.acquireVarValue;
        if v = nil then begin
          sv := expr.evaluate;
          v := tKlausVarValueSimple.create(dt);
          (v as tKlausVarValueSimple).setSimple(sv, srcPoint(li));
        end;
        b.next;
      end;
      for i := 0 to idx do
        tKlausVarDecl.create(self, nms[i].n, nms[i].p, dt, v);
    finally
      releaseAndNil(v);
    end;
    b.check(klsSemicolon);
    b.next;
  until not b.check('var_decl', false);
  b.pause;
end;

procedure tKlausRoutine.createExceptDeclarations(b: tKlausSyntaxBrowser);
var
  id: string;
  p: tSrcPoint;
begin
  b.next;
  b.check(kkwdException);
  b.next;
  b.check('exception_decl', true);
  repeat
    b.next;
    p := srcPoint(b.lex);
    id := b.get(klxID).text;
    if find(id, knsLocal) <> nil then raise eKlausError.createFmt(ercDuplicateName, b.lex.line, b.lex.pos, [id]);
    tKlausExceptDecl.create(self, id, p, b);
    b.next;
    b.check(klsSemicolon);
    b.next;
  until not b.check('exception_decl', false);
  b.pause;
end;

procedure tKlausRoutine.createProcDeclaration(b: tKlausSyntaxBrowser);
var
  id: string;
  d: tKlausDecl;
begin
  b.next;
  b.check(kkwdProcedure);
  b.next;
  id := b.get(klxID).text;
  d := find(id, knsLocal);
  if d <> nil then begin
    if d is tKlausProcDecl then with d as tKlausProcDecl do begin
      if fwd then resolveForwardDeclaration(false, b)
      else raise eKlausError.createFmt(ercDuplicateName, b.lex.line, b.lex.pos, [id]);
    end else
      raise eKlausError.createFmt(ercDuplicateName, b.lex.line, b.lex.pos, [id]);
  end else
    tKlausProcDecl.create(self, id, false, b);
  b.next;
  b.check(klsSemicolon);
end;

procedure tKlausRoutine.createFuncDeclaration(b: tKlausSyntaxBrowser);
var
  id: string;
  d: tKlausDecl;
begin
  b.next;
  b.check(kkwdFunction);
  b.next;
  id := b.get(klxID).text;
  d := find(id, knsLocal);
  if d <> nil then begin
    if d is tKlausProcDecl then with d as tKlausProcDecl do begin
      if fwd then resolveForwardDeclaration(true, b)
      else raise eKlausError.createFmt(ercDuplicateName, b.lex.line, b.lex.pos, [id]);
    end else
      raise eKlausError.createFmt(ercDuplicateName, b.lex.line, b.lex.pos, [id]);
  end else
    tKlausProcDecl.create(self, id, true, b);
  b.next;
  b.check(klsSemicolon);
end;

function tKlausRoutine.createStatement(aOwner: tKlausStmtCtlStruct; b: tKlausSyntaxBrowser): tKlausStatement;
const
  stmtKwd = [kkwdNothing, kkwdBreak, kkwdContinue, kkwdHalt, kkwdRaise, kkwdReturn, kkwdThrow];
  stmtRule: array of string = ('call', 'assignment', 'compound', 'control_structure');
begin
  b.next;
  case b.check(stmtKwd, false) of
    kkwdNothing:  result := tKlausStmtNothing.create(aOwner, srcPoint(b.lex));
    kkwdBreak:    result := tKlausStmtBreak.create(aOwner, srcPoint(b.lex));
    kkwdContinue: result := tKlausStmtContinue.create(aOwner, srcPoint(b.lex));
    kkwdHalt:     result := tKlausStmtHalt.create(aOwner, srcPoint(b.lex), b);
    kkwdReturn:   result := tKlausStmtReturn.create(aOwner, srcPoint(b.lex), b);
    kkwdRaise:    result := tKlausStmtRaise.create(aOwner, srcPoint(b.lex), b);
    kkwdThrow:    result := tKlausStmtThrow.create(aOwner, srcPoint(b.lex));
  else
    case b.check(stmtRule) of
      0: result := tKlausStmtCall.create(aOwner, srcPoint(b.lex), b);
      1: result := tKlausStmtAssign.create(aOwner, srcPoint(b.lex), b);
      2: result := tKlausStmtCompound.create(aOwner, srcPoint(b.lex), b);
      3: result := createStmtControlStructure(aOwner, b);
    else
      raise eKlausError.create(ercUnexpectedSyntax, b.lex.line, b.lex.pos);
    end;
  end;
end;

procedure tKlausRoutine.createStatements(aOwner: tKlausStmtCtlStruct; b: tKlausSyntaxBrowser);
begin
  b.next;
  b.check('statement');
  repeat
    createStatement(aOwner, b);
    b.next;
    b.check(klsSemicolon);
    b.next;
  until not b.check('statement', false);
  b.pause;
end;

function tKlausRoutine.createStmtControlStructure(aOwner: tKlausStmtCtlStruct; b: tKlausSyntaxBrowser): tKlausStmtCtlStruct;
const
  stmtRule: array of String = ('if', 'for', 'for_each', 'while', 'repeat', 'case');
begin
  b.next;
  case b.check(stmtRule, false) of
    0: result := tKlausStmtIf.create(aOwner, srcPoint(b.lex), b);
    1: result := tKlausStmtFor.create(aOwner, srcPoint(b.lex), b);
    2: result := tKlausStmtForEach.create(aOwner, srcPoint(b.lex), b);
    3: result := tKlausStmtWhile.create(aOwner, srcPoint(b.lex), b);
    4: result := tKlausStmtRepeat.create(aOwner, srcPoint(b.lex), b);
    5: result := tKlausStmtCase.create(aOwner, srcPoint(b.lex), b);
  else
    raise eKlausError.create(ercUnexpectedSyntax, b.lex.line, b.lex.pos);
  end;
end;

{ tKlausRuntime }

constructor tKlausRuntime.create(aSource: tKlausSource);
begin
  inherited create;
  fSource := aSource;
  fObjects := tKlausObjects.create;
  fStack := tFPList.create;
  fMaxStackSize := klausDefaultMaxStackSize;
  fillChar(fStdIO, sizeOf(fStdIO), 0);
end;

destructor tKlausRuntime.destroy;
begin
  assert(stackCount = 0, 'Stack integrity violation');
  freeAndNil(fStack);
  freeAndNil(fObjects);
  inherited destroy;
end;

procedure tKlausRuntime.setInOutMethods(const io: tKlausInOutMethods);
begin
  fStdIO.setRaw := io.setRaw;
  fStdIO.hasChar := io.hasChar;
  fStdIO.readChar := io.readChar;
  fStdIO.writeOut := io.writeOut;
  fStdIO.writeErr := io.writeErr;
end;

procedure tKlausRuntime.run(const fileName: string; args: tStrings = nil);
var
  frame: tKlausStackFrame;
begin
  (source.systemUnit as tKlausUnitSystem).fileName := fileName;
  (source.systemUnit as tKlausUnitSystem).args := args;
  frame := tKlausStackFrame.create(self, source.systemUnit, zeroSrcPt);
  try
    push(frame);
    try
      try
        source.systemUnit.run(frame, source.systemUnit.point);
        if fObjects.count > 0 then raise eKlausError.create(ercInaccurateCleanup, 0, 0);
      except
        on e: eKlausHalt do fExitCode := e.code;
        else begin fExitCode := -1; raise; end;
      end;
    finally
      pop(frame);
    end;
  finally
    freeAndNil(frame);
  end;
end;

function tKlausRuntime.evaluate(fr: tKlausStackFrame; expr: string; allowCalls: boolean): string;
var
  p: tKlausLexParser;
  syn: tKlausSyntax;
  n: tKlausSrcNodeRule;
  b: tKlausSyntaxBrowser;
  x: tKlausExpression;
  v: tKlausVarValue = nil;
begin
  try
    p := tKlausLexParser.create(expr);
    try
      syn := tKlausSyntax.create;
      try
        syn.setParser(p);
        syn.build;
        n := syn.tree.find('expression');
        if n <> nil then begin
          b := tKlausSyntaxBrowser.create(n);
          try
            with fr.routine do x := createExpression(body, b);
            try
              v := x.acquireVarValue(fr, allowCalls);
              if v = nil then begin
                v := tKlausVarValueSimple.create(x.resultTypeDef);
                (v as tKlausVarValueSimple).setSimple(x.evaluate(fr, allowCalls), srcPoint(0, 0, 0));
              end;
              if assigned(v) then result := v.displayValue
              else result := strEmptyValue;
            finally
              releaseAndNil(v);
              freeAndNil(x);
            end;
          finally
            freeAndNil(b);
          end;
        end else
          raise eKlausError.create(ercUnexpectedSyntax, 1, 1);
      finally
        freeAndNil(syn);
      end;
    finally
      freeAndNil(p);
    end;
  except
    on e: exception do result := format(strKlausException, [e.className, e.message]);
  end;
end;

procedure tKlausRuntime.synchronize(method: tThreadMethod);
begin
  if assigned(fOnSync) then fOnSync(method) else method;
end;

function tKlausRuntime.getStackCount: integer;
begin
  result := fStack.count;
end;

function tKlausRuntime.getStackFrames(idx: integer): tKlausStackFrame;
begin
  assert((idx >= 0) and (idx < stackCount), 'Invalid item index');
  result := tKlausStackFrame(fStack[idx]);
end;

function tKlausRuntime.getStackTop: tKlausStackFrame;
begin
  if stackCount <= 0 then result := nil
  else result := stackFrames[stackCount-1];
end;

procedure tKlausRuntime.push(fr: tKlausStackFrame);
begin
  if fStack.count >= maxStackSize then raise eKlausError.create(ercStackTooBig, 0, 0);
  fr.fIndex := fStack.add(fr);
end;

procedure tKlausRuntime.pop(fr: tKlausStackFrame);
begin
  assert(fr = stackTop, 'Stack integrity violation');
  fStack.delete(fStack.count-1);
end;

procedure tKlausRuntime.readStdIn(out c: u8Char);
begin
  if assigned(fStdIO.readChar) then
    fStdIO.readChar(c)
  else begin
    {$push}{$i-}
    c := u8ReadChar(input);
    if ioResult <> 0 then raise eKlausIOError.create(strReadError);
    {$pop}
  end;
end;

procedure tKlausRuntime.writeStdOut(const s: string);
begin
  if assigned(fStdIO.writeOut) then
    fStdIO.writeOut(s)
  else begin
    {$push}{$i-}
    system.write(stdOut, s);
    if ioResult <> 0 then raise eKlausIOError.create(strWriteError);
    {$pop}
  end;
end;

procedure tKlausRuntime.writeStdErr(const s: string);
begin
  if assigned(fStdIO.writeErr) then
    fStdIO.writeErr(s)
  else begin
    {$push}{$i-}
    system.write(stdErr, s);
    if ioResult <> 0 then raise eKlausIOError.create(strWriteError);
    {$pop}
  end;
end;

procedure tKlausRuntime.setRawInputMode(raw: boolean);
begin
  if assigned(fStdIO.setRaw) then fStdIO.setRaw(raw)
  else klausTerminalSetRaw(input, raw);
end;

function tKlausRuntime.inputAvailable: boolean;
begin
  if assigned(fStdIO.hasChar) then result := fStdIO.hasChar()
  else result := klausTerminalHasChar(input);
end;

{ tKlausStackFrame }

constructor tKlausStackFrame.create(aOwner: tKlausRuntime; aRoutine: tKlausRoutine; at: tSrcPoint);
var
  i: integer;
  decl: tKlausDecl;
begin
  fDestroying := false;
  inherited create;
  fOwner := aOwner;
  fRoutine := aRoutine;
  fCallerPoint := at;
  fVars := tStringList.create;
  fVars.sorted := true;
  fVars.duplicates := dupError;
  for i := 0 to routine.declCount-1 do begin
    decl := routine.decls[i];
    if (decl is tKlausVarDecl)
    and not (decl is tKlausExceptObjDecl) then
      tKlausVariable.create(self, decl as tKlausVarDecl);
  end;
end;

destructor tKlausStackFrame.destroy;
var
  i: integer;
begin
  if fReleased <> nil then begin
    for i := 0 to fReleased.count-1 do
      tKlausVarValue(fReleased[i]).release;
    freeAndNil(fReleased);
  end;
  for i := varCount-1 downto 0 do vars[i].free;
  inherited destroy;
end;

procedure tKlausStackFrame.beforeDestruction;
begin
  fDestroying := true;
  inherited beforeDestruction;
end;

function tKlausStackFrame.upperFrame: tKlausStackFrame;
var
  i: integer;
begin
  result := nil;
  for i := index-1 downto 0 do
    if owner.stackFrames[i].routine = self.routine.upperScope then exit(owner.stackFrames[i]);
end;

procedure tKlausStackFrame.addVariable(v: tKlausVariable);
var
  n: string;
begin
  n := u8Lower(v.decl.name);
  fVars.addObject(n, v);
end;

procedure tKlausStackFrame.removeVariable(v: tKlausVariable);
var
  idx: integer;
begin
  if fDestroying then exit;
  idx := fVars.indexOfObject(v);
  if idx >= 0 then fVars.delete(idx);
end;

function tKlausStackFrame.getVarCount: integer;
begin
  result := fVars.count;
end;

function tKlausStackFrame.getVars(idx: integer): tKlausVariable;
begin
  assert((idx >= 0) and (idx < varCount), 'Invalid item index');
  result := fVars.objects[idx] as tKlausVariable;
end;

function tKlausStackFrame.varByDecl(d: tKlausVarDecl; const at: tSrcPoint): tKlausVariable;
begin
  result := varByName(d.name, at);
  assert(result.decl = d, 'Variable name mismatch in a stack frame');
end;

function tKlausStackFrame.varByName(const n: string; const at: tSrcPoint): tKlausVariable;
var
  idx: integer;
  fr: tKlausStackFrame;
begin
  idx := fVars.indexOf(u8Lower(n));
  if idx < 0 then begin
    fr := upperFrame;
    if fr = nil then raise eKlausError.createFmt(ercVarNameNotFound, at.line, at.pos, [n]);
    result := fr.varByName(n, at);
  end else
    result := vars[idx];
end;

procedure tKlausStackFrame.assignVarValue(dest: tKlausVarPath; source: tKlausExpression; op: tKlausBinaryOperation);
var
  dvar: tKlausVariable;
  dv, sv: tKlausVarValue;
  ssv: tKlausSimpleValue;
begin
  if not (dest.decl is tKlausVarDecl) then raise eKlausError.create(ercConstAsgnTarget, dest.point.line, dest.point.pos);
  dvar := self.varByDecl(dest.decl as tKlausVarDecl, dest.point);
  sv := source.acquireVarValue(self, true);
  if sv <> nil then deferRelease(sv);
  if op <> kboInvalid then begin
    if sv = nil then
      ssv := source.evaluate(self, true)
    else begin
      if not (sv is tKlausVarValueSimple) then raise eKlausError.create(ercIllegalAsgnOperator, source.point.line, source.point.pos);
      ssv := (sv as tKlausVarValueSimple).simple;
    end;
    dvar.ownValueNeeded;
    dv := dest.evaluate(self, vpmAsgnTarget, true);
    if not (dv is tKlausVarValueSimple) then raise eKlausError.create(ercTypeMismatch, source.point.line, source.point.pos);
    ssv := klausBinOp[op].evaluate((dv as tKlausVarValueSimple).simple, ssv, source.point);
    (dv as tKlausVarValueSimple).setSimple(ssv, source.point);
  end else if dest.isVariable then begin
    if sv <> nil then
      dvar.acquireValue(sv, source.point)
    else begin
      if not (dvar.value is tKlausVarValueSimple) then raise eKlausError.create(ercTypeMismatch, source.point.line, source.point.pos);
      ssv := source.evaluate(self, true);
      dvar.ownValueNeeded;
      (dvar.value as tKlausVarValueSimple).setSimple(ssv, source.point);
    end;
  end else if sv <> nil then begin
    dvar.ownValueNeeded;
    dv := dest.evaluate(self, vpmAsgnTarget, true);
    dv.assign(sv, source.point);
  end else begin
    ssv := source.evaluate(self, true);
    dvar.ownValueNeeded;
    dv := dest.evaluate(self, vpmAsgnTarget, true);
    if not (dv is tKlausVarValueSimple) then raise eKlausError.create(ercTypeMismatch, source.point.line, source.point.pos);
    (dv as tKlausVarValueSimple).setSimple(ssv, source.point);
  end;
end;

procedure tKlausStackFrame.assignVarValue(dest: tKlausVariable; source: tKlausExpression);
var
  sv: tKlausVarValue;
  ssv: tKlausSimpleValue;
begin
  sv := source.acquireVarValue(self, true);
  if sv <> nil then begin
    deferRelease(sv);
    dest.acquireValue(sv, source.point)
  end else begin
    ssv := source.evaluate(self, true);
    if not (dest.value is tKlausVarValueSimple) then raise eKlausError.create(ercTypeMismatch, source.point.line, source.point.pos);
    dest.ownValueNeeded;
    (dest.value as tKlausVarValueSimple).setSimple(ssv, source.point);
  end;
end;

procedure tKlausStackFrame.deferRelease(val: tKlausVarValue);
begin
  if val = nil then exit;
  if fReleased = nil then fReleased := tFPList.create;
  fReleased.add(val);
end;

procedure tKlausStackFrame.call(
  callee: tKlausRoutine;
  const params: array of tKlausExpression;
  out rslt: tKlausVarValue;
  const at: tSrcPoint);

  function customEvaluate(expr: tKlausExpression; mode: tKlausProcParamMode): tKlausVarValue;
  var
    ssv: tKlausSimpleValue;
  begin
    if (mode <> kpmInput) then begin
      if not expr.isVarPath then raise eKlausError.create(ercInvalidOutputParam, expr.point);
      if expr.isConstPath then raise eKlausError.create(ercConstOutputParam, expr.point);
    end;
    try
      result := expr.acquireVarValue(self, true);
      if result = nil then begin
        ssv := expr.evaluate(self, true);
        result := tKlausVarValueSimple.create(owner.source.simpleTypes[ssv.dataType]);
        (result as tKlausVarValueSimple).setSimple(ssv, at);
      end;
    finally
      deferRelease(result);
    end;
  end;

var
  i: integer;
  v: tKlausVarValue;
  pvar: tKlausVariable;
  m: tKlausProcParamMode;
  nextFrame: tKlausStackFrame;
  custom: boolean;
  sys: tKlausSysProcDecl;
  types: array of tKlausTypeDef = nil;
  modes: tKlausProcParamModes = nil;
  values: array of tKlausVarValueAt = nil;
begin
  nextFrame := tKlausStackFrame.create(owner, callee, at);
  try
    if not (callee is tKlausSysProcDecl) then
      custom := false
    else begin
      sys := callee as tKlausSysProcDecl;
      custom := sys.isCustomParamHandler;
    end;
    if custom then begin
      setLength(types, length(params));
      for i := 0 to length(params)-1 do
        types[i] := params[i].resultTypeDef;
      sys.getCustomParamModes(types, modes, at);
      assert(length(modes) = length(params), 'Wrond number of parameters');
      setLength(values, length(params));
      for i := 0 to length(params)-1 do begin
        values[i].v := customEvaluate(params[i], modes[i]);
        values[i].at := params[i].point;
      end;
    end else begin
      assert(callee.paramCount = length(params), 'Wrong number of parameters');
      for i := 0 to callee.paramCount-1 do begin
        m := callee.params[i].mode;
        pvar := nextFrame.varByDecl(callee.params[i], params[i].point);
        if m = kpmInput then
          assignVarValue(pvar, params[i])
        else begin
          assert(params[i].isVarPath, 'Invalid output buffer');
          v := params[i].acquireVarValue(self, true);
          try pvar.acquireOutputBuffer(v, params[i].point);
          finally v.release; end;
          if m = kpmOutput then v.clear;
        end;
      end;
    end;
    owner.push(nextFrame);
    try
      try
        if not custom then
          callee.run(nextFrame, at)
        else begin
          for i := 0 to length(params)-1 do
            if modes[i] = kpmOutput then values[i].v.clear;
          sys.customRun(nextFrame, values, at);
        end;
      except
        on eKlausReturn do;
        else raise;
      end;
      if callee.retValue = nil then rslt := nil
      else rslt := nextFrame.varByDecl(callee.retValue, at).value.acquire;
    finally
      owner.pop(nextFrame);
    end;
  finally
    freeAndNil(nextFrame);
  end;
end;

{ tKlausCanvasLink }

constructor tKlausCanvasLink.create(aRuntime: tKlausRuntime; const cap: string = '');
begin
  inherited create;
  fRuntime := aRuntime;
  fNestCount := 0;
end;

procedure tKlausCanvasLink.invalidate;
begin
  if fNestCount = 0 then doInvalidate;
end;

procedure tKlausCanvasLink.beginPaint;
begin
  inc(fNestCount);
end;

procedure tKlausCanvasLink.endPaint;
begin
  if fNestCount > 0 then dec(fNestCount);
  invalidate;
end;

{ tKlausObjects }

constructor tKlausObjects.create;
begin
  inherited;
  fItems := tFPList.create;
  fCount := 0;
  fFreeCount := 0;
  fFreeItems := nil;
end;

destructor tKlausObjects.destroy;
begin
  freeAndNil(fItems);
  inherited destroy;
end;

class procedure tKlausObjects.registerKlausObject(cls: tClass; objectName: string);
begin
  if not assigned(fObjNames) then begin
    fObjNames := tPtrStrMap.create;
    fObjNames.sorted := true;
    fObjNames.duplicates := dupIgnore;
  end;
  fObjNames.add(cls, objectName);
end;

class function tKlausObjects.klausObjectName(cls: tClass): string;
var
  idx: integer;
begin
  if not assigned(cls) then exit(strEmptyValue);
  if not assigned(fObjNames) then exit(cls.className);
  result := cls.className;
  idx := fObjNames.indexOf(cls);
  while idx < 0 do begin
    cls := cls.classParent;
    if not assigned(cls) then exit(result);
    idx := fObjNames.indexOf(cls);
  end;
  result := fObjNames.data[idx];
end;

procedure tKlausObjects.storeFreeHandle(h: tKlausObject);
begin
  if fFreeCount >= length(fFreeItems) then setLength(fFreeItems, fFreeCount+64);
  fFreeItems[fFreeCount] := h;
  inc(fFreeCount);
end;

function tKlausObjects.restoreFreeHandle: tKlausObject;
begin
  assert(fFreeCount > 0, 'No free handles to restore');
  dec(fFreeCount);
  result := fFreeItems[fFreeCount];
end;

function tKlausObjects.allocate(obj: tObject; const at: tSrcPoint): tKlausObject;
begin
  assert(obj <> nil, 'Klaus handle cannot be allocated for a NIL object');
  if fFreeCount > 0 then begin
    result := restoreFreeHandle;
    fItems[result-1] := obj;
  end else begin
    if fItems.count >= high(tKlausObject)-1 then raise eKlausError.create(ercTooManyHandles, at);
    result := fItems.add(obj)+1;
  end;
  inc(fCount);
end;

function tKlausObjects.release(h: tKlausObject; const at: tSrcPoint): tObject;
begin
  result := get(h, at);
  fItems[h-1] := nil;
  storeFreeHandle(h);
  dec(fCount);
end;

procedure tKlausObjects.releaseAndFree(h: tKlausObject; const at: tSrcPoint);
var
  o: tObject;
begin
  o := get(h, at);
  try
    freeAndNil(o);
  except
    on e: eKlausError do begin
      e.line := at.line;
      e.pos := at.pos;
      raise;
    end;
    else raise;
  end;
  release(h, at);
end;

function tKlausObjects.exists(h: tKlausObject): boolean;
begin
  if (h <= 0) or (h-1 >= fItems.count) then exit(false);
  if fItems[h-1] = nil then exit(false);
  result := true;
end;

function tKlausObjects.get(h: tKlausObject; const at: tSrcPoint): tObject;
begin
  if not exists(h) then raise eKlausError.createFmt(ercInvalidKlausHandle, at, [h]);
  result := tObject(fItems[h-1]);
end;

procedure tKlausObjects.put(h: tKlausObject; obj: tObject; const at: tSrcPoint);
begin
  assert(obj <> nil, 'Klaus handle cannot be allocated for a NIL object');
  if (h < 0) or (h-1 >= fItems.count) then raise eKlausError.createFmt(ercInvalidKlausHandle, at, [h]);
  fItems[h-1] := obj;
end;

{ tKlausVarValue }

constructor tKlausVarValue.create(dt: tKlausTypeDef);
begin
  inherited create;
  fDataType := dt;
  acquire;
end;

destructor tKlausVarValue.destroy;
begin
  assert(fRefCount = 0, 'Reference count integrity violation');
  inherited destroy;
end;

function tKlausVarValue.acquire: tKlausVarValue;
begin
  inc(fRefCount);
  result := self;
end;

procedure tKlausVarValue.release;
begin
  dec(fRefCount);
  if fRefCount <= 0 then self.free;
end;

function tKlausVarValue.shared: boolean;
begin
  result := fRefCount > 1;
end;

function tKlausVarValue.canAssign(src: tKlausVarValue; strict: boolean = false): boolean;
begin
  if src.classType <> self.classType then exit(false);
  result := dataType.canAssign(src.dataType, strict);
end;

function tKlausVarValue.clone: tKlausVarValue;
begin
  result := dataType.valueClass.create(dataType);
  result.assign(self, zeroSrcPt);
end;

{ tKlausVarValueSimple }

constructor tKlausVarValueSimple.create(dt: tKlausTypeDef);
begin
  assert(dt is tKlausTypeDefSimple, 'Invalid typdef class for a simple value');
  inherited create(dt);
  fSimple := dt.zeroValue;
end;

function tKlausVarValueSimple.displayValue: string;
begin
  result := klausDisplayValue(fSimple);
end;

procedure tKlausVarValueSimple.assign(src: tKlausVarValue; const at: tSrcPoint);
begin
  setSimple((src as tKlausVarValueSimple).simple, at);
end;

procedure tKlausVarValueSimple.clear;
begin
  fSimple := dataType.zeroValue;
end;

function tKlausVarValueSimple.getSimple: tKlausSimpleValue;
begin
  result := fSimple;
end;

procedure tKlausVarValueSimple.setSimple(const val: tKlausSimpleValue; const at: tSrcPoint);
begin
  if not dataType.canAssign(val.dataType) then raise eKlausError.create(ercTypeMismatch, at);
  fSimple := klausTypecast(val, dataType.dataType, at);
end;

function tKlausVarValueSimple.stringSetLength(len: tKlausInteger; const at: tSrcPoint): tKlausInteger;
begin
  if fSimple.dataType <> kdtString then raise eKlausError.create(ercTypeMismatch, at);
  result := klstrSetLength(fSimple.sValue, len, at);
end;

procedure tKlausVarValueSimple.stringAdd(const s: tKlausString; const at: tSrcPoint);
begin
  if fSimple.dataType <> kdtString then raise eKlausError.create(ercTypeMismatch, at);
  fSimple.sValue := fSimple.sValue + s;
end;

procedure tKlausVarValueSimple.stringInsert(idx: tKlausInteger; const substr: tKlausString; const at: tSrcPoint);
begin
  if fSimple.dataType <> kdtString then raise eKlausError.create(ercTypeMismatch, at);
  klstrInsert(fSimple.sValue, idx, substr, at);
end;

procedure tKlausVarValueSimple.stringDelete(idx, count: tKlausInteger; const at: tSrcPoint);
begin
  if fSimple.dataType <> kdtString then raise eKlausError.create(ercTypeMismatch, at);
  klstrDelete(fSimple.sValue, idx, count, at);
end;

procedure tKlausVarValueSimple.stringOverwrite(
  idx: tKlausInteger; const s: string; from, len: tKlausInteger; const at: tSrcPoint);
begin
  if fSimple.dataType <> kdtString then raise eKlausError.create(ercTypeMismatch, at);
  klstrOverwrite(fSimple.sValue, idx, s, from, len, at);
end;

procedure tKlausVarValueSimple.stringReplace(
  idx, count: tKlausInteger; const repl: string; const at: tSrcPoint);
begin
  if fSimple.dataType <> kdtString then raise eKlausError.create(ercTypeMismatch, at);
  klstrReplace(fSimple.sValue, idx, count, repl, at);
end;

{ tKlausVarValueArray }

constructor tKlausVarValueArray.create(dt: tKlausTypeDef);
begin
  assert(dt is tKlausTypeDefArray, 'Invalid typdef class for an array');
  inherited create(dt);
  fElmt := tFPList.create;
end;

destructor tKlausVarValueArray.destroy;
var
  i: integer;
begin
  for i := 0 to count-1 do
    tKlausVarValue(fElmt[i]).release;
  freeAndNil(fElmt);
  inherited destroy;
end;

function tKlausVarValueArray.getCount: integer;
begin
  result := fElmt.count;
end;

procedure tKlausVarValueArray.setCount(val: integer);
var
  i, l: integer;
  dt: tKlausTypeDef;
begin
  l := fElmt.count;
  if val = l then exit;
  if val < 0 then val := 0;
  if val > l then begin
    dt := (self.dataType as tKlausTypeDefArray).elmtType;
    for i := l to val-1 do fElmt.add(dt.valueClass.create(dt));
  end else for i := l-1 downto val do begin
    tKlausVarValue(fElmt[i]).release;
    fElmt.delete(i);
  end;;
end;

function tKlausVarValueArray.getElmt(idx: integer; const at: tSrcPoint; mode: tKlausVarPathMode): tKlausVarValue;
begin
  if (idx < 0) or (idx >= count) then begin
    if mode = vpmCheckExist then exit(nil);
    raise eKlausError.createFmt(ercInvalidArrayIndex, at.line, at.pos, [idx]);
  end;
  result := tKlausVarValue(fElmt[idx]);
end;

procedure tKlausVarValueArray.insert(idx: integer; val: tKlausVarValue; const at: tSrcPoint);
var
  dt: tKlausTypeDef;
  v: tKlausVarValue;
begin
  if (idx < 0) or (idx > count) then raise eKlausError.createFmt(ercInvalidArrayIndex, at.line, at.pos, [idx]);
  dt := (self.dataType as tKlausTypeDefArray).elmtType;
  if dt.canAssign(val.dataType) then begin
    v := dt.valueClass.create(dt);
    v.assign(val, at);
    fElmt.insert(idx, v);
  end else
    raise eKlausError.create(ercTypeMismatch, at.line, at.pos);
end;

procedure tKlausVarValueArray.delete(idx, cnt: integer; const at: tSrcPoint);
var
  i: integer;
begin
  if (idx < 0) or (idx >= count) then raise eKlausError.createFmt(ercInvalidArrayIndex, at.line, at.pos, [idx]);
  if idx+cnt > count then eKlausError.createFmt(ercInvalidArrayIndex, at.line, at.pos, [idx+cnt-1]);
  for i := cnt-1 downto 0 do begin
    tKlausVarValue(fElmt[idx+i]).release;
    fElmt.delete(idx+i);
  end;
end;

procedure tKlausVarValueArray.clear;
begin
  count := 0;
end;

procedure tKlausVarValueArray.assign(src: tKlausVarValue; const at: tSrcPoint);
var
  i: integer;
  a: tKlausVarValueArray;
begin
  if not canAssign(src) then raise eKlausError.create(ercTypeMismatch, at.line, at.pos);
  count := 0;
  a := src as tKlausVarValueArray;
  for i := 0 to a.count-1 do insert(i, a.getElmt(i, at), at);
end;

function tKlausVarValueArray.displayValue: string;
var
  i: integer;
  s, sep: string;
begin
  if count = 0 then
    result := strEmptyValue
  else begin
    sep := '';
    result := '';
    for i := 0 to count-1 do begin
      s := tKlausVarValue(fElmt[i]).displayValue;
      result += sep + s;
      sep := ', ';
    end;
    result := '[' + result + ']';
  end;
end;

{ tKlausVarValueDict }

constructor tKlausVarValueDict.create(dt: tKlausTypeDef);
begin
  assert(dt is tKlausTypeDefDict, 'Invalid typdef class for an array');
  inherited create(dt);
  with dt as tKlausTypeDefDict do
    fMap := tKlausMap.create(keyType, accuracy);
  fMap.sorted := true;
  fMap.duplicates := dupError;
end;

destructor tKlausVarValueDict.destroy;
begin
  clear;
  freeAndNil(fMap);
  inherited destroy;
end;

procedure tKlausVarValueDict.clear;
var
  i: integer;
begin
  for i := 0 to count-1 do
    tKlausVarValue(fMap.data[i]).release;
  fMap.clear;
end;

function tKlausVarValueDict.getCount: integer;
begin
  result := fMap.count;
end;

procedure tKlausVarValueDict.checkKeyType(var key: tKlausSimpleValue; const at: tSrcPoint);
var
  kt: tKlausSimpleType;
begin
  kt := (self.dataType as tKlausTypeDefDict).keyType;
  if kt = key.dataType then exit
  else if klausCanAssign(key.dataType, kt) then key := klausTypeCast(key, kt, at)
  else raise eKlausError.create(ercTypeMismatch, at.line, at.pos);
end;

procedure tKlausVarValueDict.checkValueType(val: tKlausVarValue; const at: tSrcPoint);
var
  vt: tKlausTypeDef;
begin
  vt := (self.dataType as tKlausTypeDefDict).valueType;
  if not vt.canAssign(val.dataType) then raise eKlausError.create(ercTypeMismatch, at.line, at.pos);
end;

function tKlausVarValueDict.has(key: tKlausSimpleValue; const at: tSrcPoint): boolean;
begin
  checkKeyType(key, at);
  result := fMap.indexOf(key) >= 0;
end;

function tKlausVarValueDict.findKey(key: tKlausSimpleValue; out idx: integer): boolean;
begin
  result := fMap.find(key, idx);
end;

function tKlausVarValueDict.getElmt(key: tKlausSimpleValue; const at: tSrcPoint; mode: tKlausVarPathMode): tKlausVarValue;
var
  idx: integer;
  vt: tKlausTypeDef;
begin
  checkKeyType(key, at);
  idx := fMap.indexOf(key);
  if idx < 0 then begin
    if mode = vpmCheckExist then exit(nil);
    if mode <> vpmAsgnTarget then raise eKlausError.createFmt(ercInvalidDictKey, at.line, at.pos, [klausDisplayValue(key)]);
    vt := (dataType as tKlausTypeDefDict).valueType;
    result := vt.valueClass.create(vt);
    fMap.add(key, result);
  end else
    result := tKlausVarValue(fMap.data[idx]);
end;

function tKlausVarValueDict.getKeyAt(idx: integer; const at: tSrcPoint): tKlausSimpleValue;
begin
  if (idx < 0) or (idx >= count) then raise eKlausError.createFmt(ercInvalidDictIndex, at.line, at.pos, [idx]);
  result := fMap.keys[idx];
end;

function tKlausVarValueDict.getElmtAt(idx: integer; const at: tSrcPoint): tKlausVarValue;
begin
  if (idx < 0) or (idx >= count) then raise eKlausError.createFmt(ercInvalidDictIndex, at.line, at.pos, [idx]);
  result := tKlausVarValue(fMap.data[idx]);
end;

procedure tKlausVarValueDict.setElmt(key: tKlausSimpleValue; val: tKlausVarValue; const at: tSrcPoint);
var
  idx: integer;
  v: tKlausVarValue;
begin
  checkKeyType(key, at);
  checkValueType(val, at);
  idx := fMap.indexOf(key);
  if idx >= 0 then
    getElmtAt(idx, at).assign(val, at)
  else begin
    v := val.clone;
    fMap.add(key, v);
  end;
end;

procedure tKlausVarValueDict.delete(idx: integer; const at: tSrcPoint);
begin
  if (idx < 0) or (idx >= count) then raise eKlausError.createFmt(ercInvalidDictIndex, at.line, at.pos, [idx]);
  getElmtAt(idx, at).release;
  fMap.delete(idx);
end;

procedure tKlausVarValueDict.delete(key: tKlausSimpleValue; const at: tSrcPoint);
var
  idx: integer;
begin
  checkKeyType(key, at);
  idx := fMap.indexOf(key);
  if idx < 0 then raise eKlausError.createFmt(ercInvalidDictKey, at.line, at.pos, [klausDisplayValue(key)]);
  getElmtAt(idx, at).release;
  fMap.delete(idx);
end;

procedure tKlausVarValueDict.assign(src: tKlausVarValue; const at: tSrcPoint);
var
  i: integer;
  d: tKlausVarValueDict;
begin
  if not canAssign(src) then raise eKlausError.create(ercTypeMismatch, at.line, at.pos);
  clear;
  d := src as tKlausVarValueDict;
  for i := 0 to d.count-1 do setElmt(d.fMap.keys[i], d.fMap.data[i] as tKlausVarValue, at);
end;

function tKlausVarValueDict.displayValue: string;
var
  i: integer;
  k, v, sep: string;
begin
  if count = 0 then
    result := strEmptyValue
  else begin
    sep := '';
    result := '';
    for i := 0 to count-1 do begin
      k := klausDisplayValue(fMap.keys[i]) + ': ';
      v := tKlausVarValue(fMap.data[i]).displayValue;
      result += sep + k + v;
      sep := ', ';
    end;
    result := '{' + result + '}';
  end;
end;

{ tKlausVarValueStruct }

constructor tKlausVarValueStruct.create(dt: tKlausTypeDef);
var
  i: integer;
  v: tKlausVarValue;
begin
  assert(dt is tKlausTypeDefStruct, 'Invalid typdef class for an array');
  inherited create(dt);
  fMembers := tStringList.create;
  fMembers.sorted := true;
  fMembers.caseSensitive := false;
  fMembers.duplicates:= dupError;
  with dt as tKlausTypeDefStruct do
    for i := 0 to count-1 do begin
      v := members[i].dataType.valueClass.create(members[i].dataType);
      self.fMembers.addObject(u8Lower(members[i].name), v);
    end;
end;

destructor tKlausVarValueStruct.destroy;
var
  i: integer;
begin
  for i := 0 to fMembers.count-1 do
    tKlausVarValue(fMembers.objects[i]).release;
  freeAndNil(fMembers);
  inherited destroy;
end;

function tKlausVarValueStruct.findMember(const name: string): tKlausVarValue;
var
  idx: integer;
begin
  idx := fMembers.indexOf(u8Lower(name));
  if idx < 0 then result := nil
  else result := tKlausVarValue(fMembers.objects[idx]);
end;

function tKlausVarValueStruct.getMember(const name: string; const at: tSrcPoint): tKlausVarValue;
begin
  result := findMember(name);
  if result = nil then raise eKlausError.createFmt(ercStructMemberNotFound, at, [name]);
end;

procedure tKlausVarValueStruct.clear;
var
  i: integer;
begin
  for i := 0 to fMembers.count-1 do
    tKlausVarValue(fMembers.objects[i]).clear;
end;

procedure tKlausVarValueStruct.assign(src: tKlausVarValue; const at: tSrcPoint);
var
  i: integer;
  v: tKlausVarValue;
begin
  if not canAssign(src) then raise eKlausError.create(ercTypeMismatch, at.line, at.pos);
  for i := 0 to fMembers.count-1 do begin
    v := tKlausVarValue(fMembers.objects[i]);
    v.assign((src as tKlausVarValueStruct).getMember(fMembers[i], at), at);
  end;
end;

function tKlausVarValueStruct.displayValue: string;
var
  i: integer;
  k, v, sep: string;
begin
  if fMembers.count = 0 then
    result := strEmptyValue
  else begin
    sep := '';
    result := '';
    for i := 0 to fMembers.count-1 do begin
      k := fMembers[i] + ' = ';
      v := tKlausVarValue(fMembers.objects[i]).displayValue;
      result += sep + k + v;
      sep := ', ';
    end;
    result := '{' + result + '}';
  end;
end;

{ tKlausVariable }

constructor tKlausVariable.create(aOwner: tKlausStackFrame; aDecl: tKlausVarDecl);
begin
  inherited create;
  fOwner := aOwner;
  fDecl := aDecl;
  fOwner.addVariable(self);
  fValue := decl.dataType.valueClass.create(decl.dataType);
  decl.initialize(self);
end;

destructor tKlausVariable.destroy;
begin
  releaseAndNil(fValue);
  fOwner.removeVariable(self);
  inherited destroy;
end;

procedure tKlausVariable.assignValue(val: tKlausVarValue; const at: tSrcPoint; release: boolean = false);
begin
  try value.assign(val, at);
  finally if release then val.release; end;
end;

procedure tKlausVariable.acquireValue(val: tKlausVarValue; const at: tSrcPoint; release: boolean = false);
begin
  try
    if not fOutputBuffer and not (value is tKlausVarValueSimple)
    and decl.dataType.canAssign(val.dataType, true) then begin
      releaseAndNil(fValue);
      fValue := val.acquire;
    end else
      fValue.assign(val, at);
  finally
    if release then val.release;
  end;
end;

procedure tKlausVariable.acquireOutputBuffer(val: tKlausVarValue; const at: tSrcPoint);
begin
  if decl.dataType.canAssign(val.dataType, true) then begin
    releaseAndNil(fValue);
    fValue := val.acquire;
    fOutputBuffer := true;
  end else
    raise eKlausError.create(ercTypeMismatch, at.line, at.pos);
end;

procedure tKlausVariable.ownValueNeeded;
var
  v: tKlausVarValue;
begin
  if not fOutputBuffer and fValue.shared then begin
    v := fValue.clone;
    releaseAndNil(fValue);
    fValue := v;
  end;
end;

function tKlausVariable.getDisplayValue: string;
begin
  result := fValue.displayValue;
end;

{ tKlausDebugThread }

constructor tKlausDebugThread.create(aSource: tKlausSource; aFileName: string; aArgs: tStrings);
begin
  inherited create(true);
  freeOnTerminate := false;
  initCriticalSection(fLatch);
  fStepEvt := rtlEventCreate;
  rtlEventSetEvent(fStepEvt);
  fInputEvt := rtlEventCreate;
  fStepMode := false;
  fStep := false;
  fSource := aSource;
  fFileName := aFileName;
  fArgs := aArgs;
  fState := kdsInitial;
  fBreakpoints := nil;
end;

destructor tKlausDebugThread.destroy;
begin
  rtlEventDestroy(fStepEvt);
  rtlEventDestroy(fInputEvt);
  doneCriticalSection(fLatch);
  freeAndNil(fArgs);
  inherited destroy;
end;

procedure tKlausDebugThread.checkTerminated;
begin
  if terminated then raise eKlausDebugTerminated.create;
end;

procedure tKlausDebugThread.setBreakpoints(bp: tKlausBreakpoints);
begin
  lock;
  try
    fBreakpoints := bp;
  finally
    unlock;
  end;
end;

procedure tKlausDebugThread.checkBreakpoint;
var
  i: integer;
begin
  lock;
  try
    for i := 0 to length(fBreakpoints)-1 do
      if fBreakpoints[i].enabled
      and (fBreakPoints[i].line = execPoint.line)
      and (fBreakPoints[i].fileName = fFileName) then stepMode := true;
  finally
    unlock;
  end;
end;

procedure tKlausDebugThread.step(over: boolean);
begin
  lock;
  try
    if not fStepMode then exit;
    fStep := true;
    fStepOver := over;
    rtlEventSetEvent(fStepEvt);
  finally
    unlock;
  end;
end;

procedure tKlausDebugThread.terminate;
begin
  terminated := true;
end;

procedure tKlausDebugThread.waitForStep(frame: tKlausStackFrame);
begin
  if not stepMode then exit;
  if fStepOver and (frame.index > fLastStep) then exit;
  setState(kdsWaitStep);
  try
    repeat
      rtlEventWaitFor(fStepEvt, 20);
      checkTerminated;
      lock;
      try
        if not fStepMode then exit;
        if fStep then begin
          fStep := false;
          rtlEventResetEvent(fStepEvt);
          exit
        end;
      finally
        unlock;
      end;
    until false;
  finally
    setState(kdsRunning);
  end;
end;

procedure tKlausDebugThread.setExecPoint(frame: tKlausStackFrame; val: tSrcPoint);
begin
  lock;
  try
    fExecPoint := val;
    if not fStepOver or (fLastStep > frame.index) then fLastStep := frame.index;
  finally
    unlock;
  end;
end;

procedure tKlausDebugThread.execute;
var
  io: tKlausInOutMethods;
begin
  try
    klausDebugThread := self;
    setRuntime(tKlausRuntime.create(fSource));
    if assigned(fOnAssignStdIO) then fOnAssignStdIO(self, fStdIO);
    io.setRaw := @doSetRaw;
    io.hasChar := @doHasChar;
    io.readChar := @doReadChar;
    io.writeOut := @doWriteOut;
    io.writeErr := @doWriteErr;
    runtime.setInOutMethods(io);
    runtime.onSync := @synchronize;
    try
      setState(kdsRunning);
      try
        try runtime.run(fileName, args);
        finally returnValue := runtime.exitCode; end;
      except
        on e: eKlausLangException do begin
          e.message := format(strKlausException, [e.name, e.message]);
          e.finalizeData;
          raise;
        end;
        else raise;
      end;
    finally
      runtime.free;
      setRuntime(nil);
    end;
  except
    on eKlausDebugTerminated do;
    else raise;
  end;
end;

procedure tKlausDebugThread.lock;
begin
  enterCriticalSection(fLatch);
end;

procedure tKlausDebugThread.unlock;
begin
  leaveCriticalSection(fLatch);
end;

function tKlausDebugThread.getState: tKlausDebugState;
begin
  lock;
  try result := fState;
  finally unlock; end;
end;

procedure tKlausDebugThread.setState(val: tKlausDebugState);
var
  modified: boolean = false;
begin
  lock;
  try
    if fState <> val then begin
      fState := val;
      modified := true;
    end;
  finally
    unlock;
  end;
  if modified then doStateChange;
end;

function tKlausDebugThread.getStepMode: boolean;
begin
  lock;
  try result := fStepMode;
  finally unlock; end;
end;

procedure tKlausDebugThread.setStepMode(val: boolean);
begin
  lock;
  try
    fStepMode := val;
    fStepOver := false;
    if fStepMode then begin
      fStep := false;
      rtlEventResetEvent(fStepEvt);
    end else
      rtlEventSetEvent(fStepEvt);
  finally
    unlock;
  end;
end;

function tKlausDebugThread.getWaitForInput: boolean;
begin
  lock;
  try result := fWaitForInput;
  finally unlock; end;
end;

procedure tKlausDebugThread.setWaitForInput(val: boolean);
begin
  lock;
  try fWaitForInput := val;
  finally unlock; end;
end;

function tKlausDebugThread.getTerminated: boolean;
begin
  lock;
  try result := fTerminated;
  finally unlock; end;
end;

procedure tKlausDebugThread.setTerminated(val: boolean);
begin
  lock;
  try fTerminated := val;
  finally unlock; end;
end;

function tKlausDebugThread.getExecPoint: tSrcPoint;
begin
  lock;
  try result := fExecPoint;
  finally unlock; end;
end;

function tKlausDebugThread.getRuntime: tKlausRuntime;
begin
  lock;
  try result := fRuntime;
  finally unlock; end;
end;

procedure tKlausDebugThread.setRuntime(val: tKlausRuntime);
begin
  lock;
  try fRuntime := val;
  finally unlock; end;
end;

procedure tKlausDebugThread.doTerminate;
begin
  setState(kdsFinished);
  inherited doTerminate;
  klausDebugThread := nil;
end;

procedure tKlausDebugThread.doStateChange;
begin
  if assigned(fOnStateChange) then synchronize(@callOnStateChange);
end;

procedure tKlausDebugThread.doSetRaw(raw: boolean);
begin
  if not assigned(fStdIO.setRaw) then raise eKlausIOError.create(strInputNotOpen);
  fStdIO.setRaw(raw);
end;

function tKlausDebugThread.doHasChar: boolean;
begin
  if not assigned(fStdIO.hasChar) then raise eKlausIOError.create(strInputNotOpen);
  result := fStdIO.hasChar();
end;

procedure tKlausDebugThread.callOnStateChange;
begin
  fOnStateChange(self);
end;

procedure tKlausDebugThread.doWriteOut(const s: string);
begin
  if not assigned(fStdIO.writeOut) then raise eKlausIOError.create(strOutputNotOpen);
  fStdIO.writeOut(s);
end;

procedure tKlausDebugThread.doWriteErr(const s: string);
begin
  if not assigned(fStdIO.writeErr) then raise eKlausIOError.create(strOutputNotOpen);
  fStdIO.writeErr(s);
end;

procedure tKlausDebugThread.inputNeeded;
begin
  lock;
  try
    if not fWaitForInput then exit;
    fInputDone := false;
    rtlEventResetEvent(fInputEvt);
  finally
    unlock;
  end;
  setState(kdsWaitInput);
  try
    repeat
      rtlEventWaitFor(fInputEvt, 20);
      checkTerminated;
      lock;
      try if fInputDone then exit;
      finally unlock; end;
    until false;
  finally
    setState(kdsRunning);
  end;
end;

procedure tKlausDebugThread.inputDone;
begin
  lock;
  try
    rtlEventSetEvent(fInputEvt);
    fInputDone := true;
  finally
    unlock;
  end;
end;

procedure tKlausDebugThread.doReadChar(out c: u8Char);
begin
  if not assigned(fStdIO.readChar) then raise eKlausIOError.create(strInputNotOpen);
  if not doHasChar then inputNeeded;
  fStdIO.readChar(c);
end;

end.

