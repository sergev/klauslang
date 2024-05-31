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

unit KlausSyn;

{$mode ObjFPC}{$H+}
{$i ../lib/klaus.inc}

interface

uses
  Classes, SysUtils, FGL, U8, KlausErr, KlausLex;

// СИНТАКСИЧЕСКИЕ ПРАВИЛА КЛАУСА.
//
// В угловых скобках -- имя вложенного правила.
//
// В обратных апострофах -- ключевое слово языка Клаус. В исходном коде
// допустимо также любое ключевое слово из klausKeywords, синонимичное
// указанному в правиле.
//
// В двойных кавычках -- знак языка Клаус. В исходном коде допустим также
// любой знак из klausSymbols, синонимичный указанному в правиле.
//
// После "#" -- лексема Клаус: id, keyword, char и т.п., в соответствии с именами
// элементов типа tKlausValidLexUnitType. Примечание: если тип лексемы входит
// в klausLexUnitIgnore, то #XXXX не сработает, будет ошибка. Т.е., мы не можем
// требовать или ожидать комментария в исходном коде.
//
// В круглых скобках -- обязательная группа. Как правило, один из нескольких
// вариантов через "|". В квадратных скобках -- необязательная группа: может
// быть, а может не быть.
//
// Звёздочка после открывающей круглой или квадратной скобки -- содержимое
// группы может повторяться сколько угодно раз. Т.е., для круглых скобок --
// не менее одного раза, для квадратных -- 0 и более раз.
//
// Знак "|" внутри группы -- эквивалент логического "или": допустима одна из
// перечисленных последовательностей. Вне группы знак "|" не допускается.
//
// Знак ">>" перед элементом правила указывает, что этот элемент является
// маркерным. Если такой знак отсутствует, маркерным считается первый по
// порядку элемент.
//
// При анализе исходного кода последовательно проверяется соответствие между
// лексемами кода и элементами правила. Если есть соответствие, то правило
// считается подходящим, и дальше ТРЕБУЕТСЯ соответствие кода всем оставшимся
// обязательнм элементам правила, в противном случае возникает ошибка.
// Если есть несоответствие, то правило считается неподходящим, и анализатор
// переходит к проверке следующего допустимого правила или создаёт ошибку.
// Если маркерный элемент не указан явно, то правило считается подходящим при
// соответствии первого элемента и считается неподходящим, если первый элемент
// не подходит. Если маркер указан, то правило считается подходящим при
// соответствии всех элементов от начала правила и вплоть до маркерного элемента,
// включительно, и неподходящим в противном случае.
// Если в начале правила есть необязательная группа и она подходит, то правило
// считается подходящим. Если необязательные группы в начале правила не подходят,
// то они игнорируются и анализ продолжается.
// Если маркерный элемент указан внутри группы, то он работает в пределах группы.
// Если в группе несколько частей, разделённых знаками "|", то маркерный элемент
// работает только в пределах своей части группы между знаками "|".
//
// Знак ">>" следует использовать с осторожностью.
// 1. Из-за него криво собираются сообщения о синтаксических ошибках.
// 2.1. Если перед ним есть вложенное правило, то всё работает неправильно.
// 2.2. Даже если бы работало правильно, нужно понимать глубину рекурсии.
// 3. Правила со знаком ">>" должны по всему дереву синтаксиса во всех группах "ИЛИ"
// быть расположены прежде, чем "похожие" правила без этого знака. Иначе "похожие"
// правила вызовут синтаксическую ошибку прежде, чем дело дойдёт до ">>".

type
  tKlausSynRuleRec = record
    name: string;
    def: string;
  end;

const
  // Имя корневого синтакцического правила
  klausSynRuleRoot = 'klaus_syntax_root';

  // Синтаксические правила
  klausSynRules: array of tKlausSynRuleRec = (
    (name: klausSynRuleRoot;
    def: '(<program> | <expression>)'), // def: '(<program> | <unit>)'),

    (name: 'program';
    def:   '`программа` #id [<program_params>] ";" <routine> "."'), // uses'),

    (name: 'program_params';
    def:   '"(" [`вх`] #id ":" `массив` `строк` ")"'),

    // (name: 'uses';
    // def:   '`используется` #id [* "," #id] ";"'),

    (name: 'routine';
    def:   '[<declarations>] <compound>'),

    (name: 'declarations';
    def:   '(* <type_declarations> | <const_declarations> | <var_declarations> | '+
           '<exception_declarations> | <procedure> | <function>)'),

    (name: 'type_declarations';
    def:   '`тип` (* <type_decl>)'),

    (name: 'type_decl';
    def:   '#id [* "/" #id] "=" <type_def> ";"'),

    (name: 'simple_type';
    def:   '(`символ` | `строка` | `целое` | `дробное` | `момент` | `логическое` | `объект`)'),

    (name: 'type_id';
    def:   '(<simple_type> | #id)'),

    (name: 'type_def';
    def:   '(<simple_type> | #id | <type_def_array> | <type_def_dict> | <type_def_struct>)'),

    (name: 'type_def_array';
    def:   '`массив` [* `массивов`] <type_def>'),

    (name: 'type_def_dict';
    def:   '`словарь` <type_def> `ключ` <simple_type> [`точность` <expression>]'),

    (name: 'type_def_struct';
    def:   '`структура` <struct_body> `окончание`'),

    (name: 'struct_body';
    def:   '<struct_field> [* <struct_field>]'),

    (name: 'struct_field';
    def:   '#id [* "," #id] ":" <type_def> ";"'),

    (name: 'var_declarations';
    def:   '`переменная` (* <var_decl>)'),

    (name: 'var_decl';
    def:   '#id [* "/" #id] [* "," #id [* "/" #id]] ":" <type_def> ["=" <expression>] ";"'),

    (name: 'const_declarations';
    def:   '`константа` (* <const_decl>)'),

    (name: 'const_decl';
    def:   '#id [* "/" #id] [":" <type_def>] "=" <expression> ";"'),

    (name: 'exception_declarations';
    def:   '`исключение` (* <exception_decl>)'),

    (name: 'exception_decl';
    def:   '#id ["(" <exception_param> [* ";" <exception_param>] ")"] [`сообщение` #string] ";"'),

    (name: 'exception_param';
    def:   '[`вх`] #id [* "," #id] ":" <simple_type>'),

    (name: 'procedure';
    def:   '`процедура` #id "(" [<param> [* ";" <param>]] ")" ";" (`дальше` | <routine>) ";"'),

    (name: 'function';
    def:   '`функция` #id "(" [<param> [* ";" <param>]] ")" ":" <type_id> ";" (`дальше` | <routine>) ";"'),

    (name: 'param';
    def:   '[`вх` | `вых` | `вв`] #id [* "/" #id] [* "," #id [* "/" #id]] ":" <type_id>'),

    (name: 'statements';
    def:   '<statement> ";" [* <statement> ";"]'),

    (name: 'statement';
    def:   '(`ничего` | `прервать` | `продолжить` | `завершить` [<expression>] | '+
           '`ошибка` [<exception>] | `бросить` | `вернуть` [<expression>] | '+
           '<compound> | <control_structure> | <call> | <assignment>)'),

    (name: 'exception';
    def:   '#id ["(" <expression> [* "," <expression>] ")"] [`сообщение` <expression>]'),

    (name: 'typecast';
    def:   '<simple_type> "(" <expression> ")"'),

    (name: 'call';
    def:   '#id >>"(" [<expression> [* "," <expression>]] ")"'),

    (name: 'assignment';
    def:   '<var_path> <assign_symbol> <expression>'),

    (name: 'var_path';
    def:   '<var_ref> [* "." <var_ref>]'),

    (name: 'var_ref';
    def:   '#id [* "[" <expression> "]"]'),

    (name: 'assign_symbol';
    def:   '(":=" | "+=" | "-=" | "*=" | "/=" | "\=" | "%=" | "^="  | "&=" | "|=" | "~=")'),

    (name: 'expression';
    def:   '(<compound_literal> | <operand> [* <binary_operation> <operand>])'),

    (name: 'unary_operation';
    def:   '("-" | "!" | `не`)'),

    (name: 'binary_operation';
    def:   '("+" | "++" | "-" | "*" | "/" | "\" | "%" | "^" | "=" | "<>" | ">" | "<" |'+
           '">=" | "<=" | "&&" | "||" | "~~" | "&" | "|" | "~" | `и` | `или` | `либо`)'),

    (name: 'operand';
    def:   '[<unary_operation>] (<literal> | <typecast> | <call> | <var_path> | <exists> | '+
           '"(" <expression> ")")'),

    (name: 'literal';
    def:   '(#char | #string | #integer | #float | #moment | `да` | `нет` | `пусто`)'),

    (name: 'exists';
    def:   '(`есть` "(" <var_path> ")" | `нету` "(" <var_path> ")")'),

    (name: 'compound_literal';
    def:   '(<struct_literal> | <dict_literal> | <array_literal>)'),

    (name: 'struct_literal';
    def:   '"{" #id >>"=" <expression> [* "," #id "=" <expression>] "}"'),

    (name: 'dict_literal';
    def:   '"{" <expression> ":" <expression> [* "," <expression> ":" <expression>] "}"'),

    (name: 'array_literal';
    def:   '"[" <expression> [* "," <expression>] "]"'),

    (name: 'compound';
    def:   '`начало` <statements> [`исключение` <except_block>] [`напоследок` <statements>] `окончание`'),

    (name: 'except_block';
    def:   '(<statements> | <except_else> | <except_handler> [* <except_handler>] [<except_else>])'),

    (name: 'except_handler';
    def:   '`когда` >>(#id >>":" #id | #id [* "," #id]) `тогда` <statement> ";"'),

    (name: 'except_else';
    def:   '`когда` >>`любое` `тогда` <statement> ";"'),

    (name: 'control_structure';
    def:   '(<if> | <for> | <for_each> | <while> | <repeat> | <case>)'),

    //(name: 'with';
    //def:   '`внутри` <var_path> ":" <statement>'),

    (name: 'if';
    def:   '`если` <expression> `то` <statement> [`иначе` <statement>]'),

    (name: 'for';
    def:   '`для` >>#id `от` <expression> `до` <expression> [`обратный`] `цикл` <statement>'),

    (name: 'for_each';
    def:   '`для` >>`каждого` #id `из` <var_path> [`от` <expression>] [`обратный`] `цикл` <statement>'),

    (name: 'while';
    def:   '`пока` <expression> `цикл` <statement>'),

    (name: 'repeat';
    def:   '`цикл` <statement> `пока` <expression>'),

    (name: 'case';
    def:   '`выбор` <expression> [`точность` <expression>] `из` <case_body> `окончание`'),

    (name: 'case_body';
    def:   '<case_item> [* <case_item>] [<case_else>]'),

    (name: 'case_item';
    def:   '<expression> [* "," <expression>] ":" <statement> ";"'),

    (name: 'case_else';
    def:   '`иначе` <statement> ";"')
);

type
  // Тип лексемы языка описания синтаксиса
  tKlSynLexem = (
    klslEOF,        // конец потока
    klslError,      // недопустимый символ
    klslRule,       // имя синтаксического правила
    klslSymbol,     // знак
    klslKlausKwd,   // ключевое слово языка Клаус
    klslKlausLex,   // лексема языка Клаус
    klslKlausSym    // знак языка Клаус
  );

type
  // Допустимый тип лексемы языка описани синтаксиса
  tKlSynValidLexem = succ(klslError)..high(tKlSynLexem);

type
  // Знаки языка описания синтаксиса
  tKlSynSymbol = (
    klssInvalid,     // не знак
    klssMarker,      // маркер распознавания правила
    klssReqSglGroup, // обязательная одиночная группа
    klssReqMulGroup, // обязательная множественная группа
    klssOptSglGroup, // необязательная одиночная группа
    klssOptMulGroup, // необязательная множественная группа
    klssReqGroupEnd, // конец обязательной группы
    klssOptGroupEnd, // коней необязательной группы
    klssGroupSep     // разделитель правил в группе
  );
  tKlSynSymbolSet = set of tKlSynSymbol;

type
  // Допустимые знаки языка описания синтаксиса
  tKlSynValidSymbol = succ(klssInvalid)..high(tKlSynSymbol);
  tKlSynValidSymbolSet = set of tKlSynValidSymbol;

type
  // Лексема языка описания синтаксиса
  tKlSynLexInfo = record
    lexem: tKlSynLexem;          // тип лексической единицы
    symbol: tKlSynSymbol;        // определено для klsuSymbol
    value: string;               // значение
    klausKeyword: tKlausKeyword; // определено для klsuKeyword
    klausLexem: tKlausLexem;     // определено для klsuLexem
    klausSymbol: tKlausSymbol;   // определено для klsuKlausSym
    pos: integer;                // позиция в строке
  end;

type
  tKlausSyntax = class;
  tKlausSynEntry = class;

type
  // Парсер лексики языка описания синтаксиса языка Клаус
  tKlausSynLexParser = class(tCustomLexParser)
    private
      procedure setLexInfo(s: string; aLexem: tKlSynLexem; out li: tKlSynLexInfo);
      procedure setLexInfo(s: string; aSymbol: tKlSynValidSymbol; out li: tKlSynLexInfo);
      procedure processEntry(c: u8Char; out li: tKlSynLexInfo);
      procedure processKeyword(c: u8Char; out li: tKlSynLexInfo);
      procedure processLexem(c: u8Char; out li: tKlSynLexInfo);
      procedure processKlausSym(c: u8Char; out li: tKlSynLexInfo);
      procedure processSymbol(c: u8Char; out li: tKlSynLexInfo);
    public
      class function findKlausLexem(s: string): tKlausLexem;

      procedure getNextLexem(out li: tKlSynLexInfo);
  end;

type
  // Определение синтаксического правила.
  // Либо именованное правило, либо содержимое группы в круглых или
  // квадратных скобках, либо содержимое части группы между знаками "|"
  tKlausSynRule = class(tObject)
    private
      fSyntax: tKlausSyntax;
      fName: string;
      fEntries: array of tKlausSynEntry;
      fMarker: integer;

      function getCount: integer;
      function getEntries(idx: integer): tKlausSynEntry;
    protected
      procedure parseDef(def: string);
      function  parse(p: tKlausSynLexParser; stopAt: tKlSynSymbolSet = []): tKlSynSymbol;
      procedure addEntry(entry: tKlausSynEntry; setMarker: boolean);
      function  match(require: boolean): boolean;
    public
      property name: string read fName;
      property count: integer read getCount;
      property entries[idx: integer]: tKlausSynEntry read getEntries; default;

      constructor create(aSyntax: tKlausSyntax; aName: string; def: string = '');
      destructor  destroy; override;
      function toString: string; override;
  end;

type
  // Базовый класс элемента синтаксического правила: лексема, знак, вложенное правило и т.п.
  tKlausSynEntry = class(tObject)
    private
      fSyntax: tKlausSyntax;
    protected
      function match(require: boolean): boolean; virtual; abstract;
    public
      constructor create(aSyntax: tKlausSyntax);
  end;

type
  // Элемент синтаксического правила -- вложенное правило
  tKlausSynSubRule = class(tKlausSynEntry)
    private
      fSubRule: tKlausSynRule;
    protected
      function match(require: boolean): boolean; override;
    public
      constructor create(aSyntax: tKlausSyntax; subRuleName: string);
      function toString: string; override;
  end;

type
  // Элемент синтаксического правила -- ключевое слово
  tKlausSynKeyword = class(tKlausSynEntry)
    private
      fKeyword: tKlausValidKeyword;
    protected
      function match(require: boolean): boolean; override;
    public
      constructor create(aSyntax: tKlausSyntax; aKeyword: tKlausKeyword);
      function toString: string; override;
  end;

type
  // Элемент синтаксического правила -- лексема (идентификатор, литерал)
  tKlausSynLexem = class(tKlausSynEntry)
    private
      fLexem: tKlausValidLexem;
    protected
      function match(require: boolean): boolean; override;
    public
      constructor create(aSyntax: tKlausSyntax; aLexem: tKlausLexem);
      function toString: string; override;
  end;

type
  // Элемент синтаксического правила -- знак языка
  tKlausSynSymbol = class(tKlausSynEntry)
    private
      fSymbol: tKlausValidSymbol;
    protected
      function match(require: boolean): boolean; override;
    public
      constructor create(aSyntax: tKlausSyntax; aSymbol: tKlausSymbol);
      function toString: string; override;
  end;

type
  // Элемент синтаксического правила -- группа в круглых или квадратных скобках
  tKlausSynGroup = class(tKlausSynEntry)
    private
      fOptional: boolean;
      fMultiple: boolean;
      fItems: array of tKlausSynRule;

      function getCount: integer;
      function getItems(idx: integer): tKlausSynRule;
    protected
      procedure addItem(item: tKlausSynRule);
      function  match(require: boolean): boolean; override;
    public
      property count: integer read getCount;
      property items[idx: integer]: tKlausSynRule read getItems; default;

      constructor create(aSyntax: tKlausSyntax; aOptional, aMultiple: boolean);
      destructor  destroy; override;
      function toString: string; override;
  end;

type
  tKlausSrcNodeRule = class;

type
  // Базовый класс для узла древовидной структуры исходного кода.
  // Вызов tKlausSyntax.build() создаёт древовидную структуру, где лексемы
  // исходного кода поставлены в соответствие синтаксическим правилам языка.
  tKlausSrcNode = class
    private
      fSyntax: tKlausSyntax;
      fParent: tKlausSrcNodeRule;
      fIndex: integer;
    public
      property syntax: tKlausSyntax read fSyntax;
      property parent: tKlausSrcNodeRule read fParent;
      property index: integer read fIndex;

      constructor create(aSyntax: tKlausSyntax; aParent: tKlausSrcNodeRule);
      destructor  destroy; override;
  end;

type
  // Узел структуры исходного кода -- лексема
  tKlausSrcNodeLexem = class(tKlausSrcNode)
    private
      fLexIdx: integer;

      function getLexInfo: tKlausLexInfo;
    public
      property lexIdx: integer read fLexIdx;
      property lexInfo: tKlausLexInfo read getLexInfo;

      constructor create(aSyntax: tKlausSyntax; aParent: tKlausSrcNodeRule; aLexIdx: integer);
  end;

type
  // Узел структуры исходного кода -- поименованное синтаксическое правило
  tKlausSrcNodeRule = class(tKlausSrcNode)
    private
      fDestroying: boolean;
      fRule: tKlausSynRule;
      fRecognized: boolean;
      fItems: array of tKlausSrcNode;

      function getCount: integer;
      function getItems(idx: integer): tKlausSrcNode;
    protected
      property recognized: boolean read fRecognized;
    public
      property rule: tKlausSynRule read fRule;
      property count: integer read getCount;
      property items[idx: integer]: tKlausSrcNode read getItems;

      constructor create(aSyntax: tKlausSyntax; aParent: tKlausSrcNodeRule; aRule: tKlausSynRule);
      destructor  destroy; override;
      procedure beforeDestruction; override;
      function  add(item: tKlausSrcNode): integer;
      procedure remove(item: tKlausSrcNode);
      function  find(ruleName: string): tKlausSrcNodeRule;
  end;

type
  tKlausSynRules = specialize TFPGMapObject <string, tKlausSynRule>;

type
  // Синтаксический анализатор Клаус
  tKlausSyntax = class(tObject)
    private
      fRules: tKlausSynRules;
      fParser: tKlausLexParser;
      fLexInfo: array of tKlausLexInfo;
      fLexIdx: integer;
      fLexLen: integer;
      fTree: tKlausSrcNodeRule;
      fNowMatching: tKlausSrcNodeRule;
      fErrInfo: tStringList;

      function  getCurLexInfo: pKlausLexInfo;
      function  getCurLine: integer;
      function  getCurPos: integer;
      function  getLexCount: integer;
      function  getLexInfo(idx: integer): tKlausLexInfo;
      function  getRule(aName: string): tKlausSynRule;
    protected
      property curLexIndex: integer read fLexIdx;
      property curLexInfo: pKlausLexInfo read getCurLexInfo;
      property curLine: integer read getCurLine;
      property curPos: integer read getCurPos;
      property nowMatching: tKlausSrcNodeRule read fNowMatching;

      function  nextLexInfo: tKlausLexInfo;
      procedure prevLexInfo(count: integer = 1);
      function  lastLexInfo: tKlausLexInfo;
      procedure matching(rule: tKlausSynRule);
      procedure recognized(rule: tKlausSynRule);
      procedure matched(rule: tKlausSynRule);
      procedure addMatchedLexem;
      procedure addErrInfo(const s: string);
      procedure clearErrInfo;
      function  formatErrInfo: string;
    public
      property rules: tKlausSynRules read fRules;
      property lexCount: integer read getLexCount;
      property lexInfo[idx: integer]: tKlausLexInfo read getLexInfo;
      property tree: tKlausSrcNodeRule read fTree;

      constructor create;
      destructor  destroy; override;
      procedure setParser(p: tKlausLexParser);
      procedure build;
  end;

implementation

uses
  KlausLog;

resourcestring
  strExpectedOne = 'Ожидается: %s';
  strExpectedMany = 'Ожидается одно из: %s';

const
  // Знаки языка описания синтаксиса языка Клаус
  klSynSymbols: array of record
    s: string;
    k: tKlSynValidSymbol;
  end = (
    (s: '>>';  k: klssMarker),
    (s: '(';   k: klssReqSglGroup),
    (s: '(*';  k: klssReqMulGroup),
    (s: ')';   k: klssReqGroupEnd),
    (s: '[';   k: klssOptSglGroup),
    (s: '[*';  k: klssOptMulGroup),
    (s: ']';   k: klssOptGroupEnd),
    (s: '|';   k: klssGroupSep)
  );

// Поиск синтаксического правила по имени
function findSynRule(s: string; mustFind: boolean): integer;
var
  i: integer;
begin
  result := -1;
  s := u8Lower(s);
  for i := 0 to length(klausSynRules)-1 do
    if klausSynRules[i].name = s then exit(i);
  if mustFind then assert(false, 'Syntax rule not found');
end;

{ tKlausSrcNode }

constructor tKlausSrcNode.create(aSyntax: tKlausSyntax; aParent: tKlausSrcNodeRule);
begin
  inherited create;
  fSyntax:= aSyntax;
  fParent := nil;
  fIndex := -1;
  if assigned(aParent) then aParent.add(self);
  if self.classType = tKlausSrcNode then abstractError;
end;

destructor tKlausSrcNode.destroy;
begin
  if fSyntax.fTree = self then fSyntax.fTree := nil;
  if assigned(fParent) then fParent.remove(self);
  inherited destroy;
end;

{ tKlausSrcNodeRule }

constructor tKlausSrcNodeRule.create(aSyntax: tKlausSyntax; aParent: tKlausSrcNodeRule; aRule: tKlausSynRule);
begin
  inherited create(aSyntax, aParent);
  fDestroying := false;
  fRule := aRule;
  fItems := nil;
  fRecognized := false;
end;

destructor tKlausSrcNodeRule.destroy;
var
  i: integer;
begin
  for i := length(fItems)-1 downto 0 do fItems[i].free;
  fItems := nil;
  inherited destroy;
end;

procedure tKlausSrcNodeRule.beforeDestruction;
begin
  fDestroying := true;
  inherited beforeDestruction;
end;

function tKlausSrcNodeRule.getCount: integer;
begin
  result := length(fItems);
end;

function tKlausSrcNodeRule.getItems(idx: integer): tKlausSrcNode;
begin
  assert((idx >= 0) and (idx < count), 'Invalid item index');
  result := fItems[idx];
end;

function tKlausSrcNodeRule.add(item: tKlausSrcNode): integer;
begin
  result := length(fItems);
  setLength(fItems, result+1);
  fItems[result] := item;
  item.fParent := self;
  item.fIndex := result;
end;

procedure tKlausSrcNodeRule.remove(item: tKlausSrcNode);
var
  idx: integer;
begin
  if fDestroying then exit;
  idx := length(fItems)-1;
  assert(fItems[idx] = item, 'Syntax rule stack integrity violation');
  setLength(fItems, idx);
  item.fParent := nil;
  item.fIndex := -1;
end;

function tKlausSrcNodeRule.find(ruleName: string): tKlausSrcNodeRule;
var
  i: integer;
begin
  ruleName := u8Lower(ruleName);
  for i := 0 to count-1 do begin
    if not (items[i] is tKlausSrcNodeRule) then continue;
    if (items[i] as tKlausSrcNodeRule).rule.name = ruleName then exit(items[i] as tKlausSrcNodeRule);
  end;
  result := nil;
end;

{ tKlausSrcNodeLexem }

constructor tKlausSrcNodeLexem.create(aSyntax: tKlausSyntax; aParent: tKlausSrcNodeRule; aLexIdx: integer);
begin
  inherited create(aSyntax, aParent);
  fLexIdx := aLexIdx;
end;

function tKlausSrcNodeLexem.getLexInfo: tKlausLexInfo;
begin
  result := fSyntax.lexInfo[fLexIdx];
end;

{ tKlausSynEntry }

constructor tKlausSynEntry.create(aSyntax: tKlausSyntax);
begin
  inherited create;
  fSyntax := aSyntax;
end;

{ tKlausSyntax }

constructor tKlausSyntax.create;
begin
  inherited create;
  fRules := tKlausSynRules.create(false);
  fRules.sorted := true;
  fRules.duplicates := dupError;
  fParser := nil;
  fLexInfo := nil;
  fLexLen := 0;
  fLexIdx := -1;
  fTree := nil;
  fNowMatching := nil;
  fErrInfo := tStringList.create;
  fErrInfo.sorted := true;
  fErrInfo.duplicates := dupIgnore;
  getRule(klausSynRuleRoot);
end;

destructor tKlausSyntax.destroy;
var
  i: integer;
begin
  if assigned(fTree) then freeAndNil(fTree);
  fNowMatching := nil;
  for i := fRules.count-1 downto 0 do fRules.data[i].free;
  freeAndNil(fRules);
  freeAndNil(fErrInfo);
  inherited destroy;
end;

function tKlausSyntax.getCurLexInfo: pKlausLexInfo;
begin
  if (fLexIdx < 0) or (fLexIdx >= fLexLen) then result := nil
  else result := @fLexInfo[fLexIdx];
end;

function tKlausSyntax.getCurLine: integer;
var
  li: pKlausLexInfo;
begin
  li := getCurLexInfo;
  if assigned(li) then result := li^.line else result := 1;
end;

function tKlausSyntax.getCurPos: integer;
var
  li: pKlausLexInfo;
begin
  li := getCurLexInfo;
  if assigned(li) then result := li^.pos else result := 1;
end;

function tKlausSyntax.getLexCount: integer;
begin
  result := length(fLexInfo);
end;

function tKlausSyntax.getLexInfo(idx: integer): tKlausLexInfo;
begin
  assert((idx >= 0) and (idx < length(fLexInfo)), 'Invalid item index');
  result := fLexInfo[idx];
end;

function tKlausSyntax.nextLexInfo: tKlausLexInfo;
const
  step = 20;
var
  li: tKlausLexInfo;
begin
  if fLexIdx < fLexLen-1 then begin
    if fLexIdx < 0 then fLexIdx += 1
    else if (fLexInfo[fLexIdx]).lexem <> klxEOF then fLexIdx += 1;
  end else begin
    fLexLen += 1;
    if fLexLen > length(fLexInfo) then
      setLength(fLexInfo, fLexLen + step);
    repeat fParser.getNextLexem(li);
    until not (li.lexem in klausLexemIgnore);
    fLexIdx += 1;
    fLexInfo[fLexIdx] := li;
  end;
  result := fLexInfo[fLexIdx];
end;

function tKlausSyntax.lastLexInfo: tKlausLexInfo;
begin
  while fLexIdx < fLexLen-1 do result := nextLexInfo;
end;

procedure tKlausSyntax.prevLexInfo(count: integer);
begin
  if count <= 0 then exit;
  assert(fLexIdx >= count-1, 'Cannot feed back');
  fLexIdx -= count;
end;

procedure tKlausSyntax.matching(rule: tKlausSynRule);
var
  n: tKlausSrcNodeRule;
begin
  n := tKlausSrcNodeRule.create(self, fNowMatching, rule);
  if not assigned(fTree) then fTree := n;
  fNowMatching := n;
end;

procedure tKlausSyntax.matched(rule: tKlausSynRule);
var
  i: integer;
  n: tKlausSrcNodeRule;
begin
  assert(assigned(fNowMatching), 'Syntax rule stack integrity violation');
  n := fNowMatching;
  assert(rule = n.rule, 'Syntax rule stack integrity violation');
  fNowMatching := n.parent;
  if not n.recognized then
    // всё было напрасно
    freeAndNil(n)
  else if n.rule.name = '' then begin
    // безымянное правило сливаем с родительским
    assert(assigned(fNowMatching), 'Syntax rule stack integrity violation');
    fNowMatching.remove(n);
    for i := 0 to n.count-1 do
      fNowMatching.add(n.items[i]);
    n.fItems := nil;
    freeAndNil(n);
  end;
end;

procedure tKlausSyntax.recognized(rule: tKlausSynRule);
begin
  assert(assigned(fNowMatching), 'Syntax rule stack integrity violation');
  assert(rule = nowMatching.rule, 'Syntax rule stack integrity violation');
  fNowMatching.fRecognized := true;
end;

procedure tKlausSyntax.addMatchedLexem;
begin
  assert(assigned(fNowMatching), 'Syntax rule stack integrity violation');
  tKlausSrcNodeLexem.create(self, fNowMatching, curLexIndex);
  clearErrInfo;
end;

procedure tKlausSyntax.addErrInfo(const s: string);
begin
  fErrInfo.add(s);
end;

procedure tKlausSyntax.clearErrInfo;
begin
  fErrInfo.clear;
end;

function tKlausSyntax.formatErrInfo: string;

  function list: string;
  var
    i: integer;
    sep: string = '';
  begin
    result := '';
    for i := 0 to fErrInfo.count-1 do begin
      result += sep + fErrInfo[i];
      sep := ' ';
    end
  end;

begin
  case fErrInfo.count of
    0: result := '';
    1: result := format(strExpectedOne, [list]);
    else result := format(strExpectedMany, [list]);
  end;
  clearErrInfo;
end;

function tKlausSyntax.getRule(aName: string): tKlausSynRule;
var
  idx: integer;
begin
  aName := u8Lower(aName);
  idx := fRules.IndexOf(aName);
  if idx >= 0 then
    result := fRules.data[idx]
  else begin
    idx := findSynRule(aName, true);
    assert(klausSynRules[idx].def <> '', 'Empty syntax rule');
    result := tKlausSynRule.create(self, aName, klausSynRules[idx].def);
  end;
end;

procedure tKlausSyntax.setParser(p: tKlausLexParser);
begin
  fParser := p;
  fLexInfo := nil;
  fLexLen := 0;
  fLexIdx := -1;
  if assigned(fTree) then freeAndNil(fTree);
  fNowMatching := nil;
end;

procedure tKlausSyntax.build;
var
  li: tKlausLexInfo;
begin
  if assigned(fTree) then freeAndNil(fTree);
  fNowMatching := nil;
  getRule(klausSynRuleRoot).match(true);
  li := nextLexInfo;
  if li.lexem <> klxEOF then raise eKlausError.create(ercTextAfterEnd, li.line, li.pos);
end;

{ tKlausSynGroup }

constructor tKlausSynGroup.create(aSyntax: tKlausSyntax; aOptional, aMultiple: boolean);
begin
  inherited create(aSyntax);
  fOptional := aOptional;
  fMultiple := aMultiple;
end;

destructor tKlausSynGroup.destroy;
var
  i: integer;
begin
  for i := count-1 downto 0 do freeAndNil(fItems[i]);
  inherited destroy;
end;

function tKlausSynGroup.toString: string;
const
  co: array[boolean] of u8Char = ('(', '[');
  cc: array[boolean] of u8Char = (')', ']');
var
  i: integer;
  sep: string = '';
begin
  result := co[fOptional];
  if fMultiple then result += '* ';
  for i := 0 to count-1 do begin
    result += sep + items[i].toString;
    sep := ' | ';
  end;
  result += cc[fOptional];
end;

function tKlausSynGroup.getCount: integer;
begin
  result := length(fItems);
end;

function tKlausSynGroup.getItems(idx: integer): tKlausSynRule;
begin
  if (idx < 0) or (idx >= count) then assert(false, 'Invalid item index');
  result := fItems[idx];
end;

procedure tKlausSynGroup.addItem(item: tKlausSynRule);
begin
  setLength(fItems, length(fItems)+1);
  fItems[length(fItems)-1] := item;
end;

function tKlausSynGroup.match(require: boolean): boolean;
var
  found: boolean = false;
  i: integer;
begin
  logln('syntax', boolStr(require, 'req ', 'opt ') + toString + #10);
  result := false;
  repeat
    found := false;
    for i := 0 to count-1 do
      if items[i].match(false) then begin
        found := true;
        result := true;
        break;
      end;
  until not (fMultiple and found);
  if not fOptional and not result and require then begin
    fSyntax.lastLexInfo;
    raise eKlausError.create(ercSyntaxError, fSyntax.curLine, fSyntax.curPos);
  end;
end;

{ tKlausSynSymbol }

constructor tKlausSynSymbol.create(aSyntax: tKlausSyntax; aSymbol: tKlausSymbol);
begin
  inherited create(aSyntax);
  fSymbol := tKlausValidSymbol(aSymbol);
end;

function tKlausSynSymbol.match(require: boolean): boolean;
var
  li: tKlausLexInfo;
begin
  logln('syntax', boolStr(require, 'req ', 'opt ') + toString);
  fSyntax.addErrInfo('"'+tKlausLexParser.symbolValue(fSymbol)+'"');
  li := fSyntax.nextLexInfo;
  result := (li.lexem = klxSymbol) and (li.symbol = fSymbol);
  if result then
    fSyntax.addMatchedLexem
  else begin
    if require then raise eKlausError.create(ercSyntaxError, li.line, li.pos)
    else fSyntax.prevLexInfo;
  end;
  logln('syntax', ' >> %s ("%s")'#10, [result, li.text]);
end;

function tKlausSynSymbol.toString: string;
begin
  result := ansiQuotedStr(tKlausLexParser.symbolValue(fSymbol), '"');
end;

{ tKlausSynLexem }

constructor tKlausSynLexem.create(aSyntax: tKlausSyntax; aLexem: tKlausLexem);
begin
  inherited create(aSyntax);
  fLexem := tKlausValidLexem(aLexem);
end;

function tKlausSynLexem.match(require: boolean): boolean;
var
  li: tKlausLexInfo;
begin
  logln('syntax', boolStr(require, 'req ', 'opt ') + toString);
  fSyntax.addErrInfo('<'+klausLexemCaption[fLexem]+'>');
  li := fSyntax.nextLexInfo;
  result := li.lexem = fLexem;
  if result then
    fSyntax.addMatchedLexem
  else begin
    if require then raise eKlausError.create(ercSyntaxError, li.line, li.pos)
    else fSyntax.prevLexInfo;
  end;
  logln('syntax', ' >> %s ("%s")'#10, [result, li.text]);
end;

function tKlausSynLexem.toString: string;
begin
  result := '#'+u8Lower(klausLexemName(fLexem));
end;

{ tKlausSynKeyword }

constructor tKlausSynKeyword.create(aSyntax: tKlausSyntax; aKeyword: tKlausKeyword);
begin
  inherited create(aSyntax);
  fKeyword := aKeyword;
end;

function tKlausSynKeyword.match(require: boolean): boolean;
var
  li: tKlausLexInfo;
begin
  logln('syntax', boolStr(require, 'req ', 'opt ') + toString);
  fSyntax.addErrInfo('"'+tKlausLexParser.keywordValue(fKeyword)+'"');
  li := fSyntax.nextLexInfo;
  result := (li.lexem = klxKeyword) and (li.keyword = fKeyword);
  if result then
    fSyntax.addMatchedLexem
  else begin
    if require then raise eKlausError.create(ercSyntaxError, li.line, li.pos)
    else fSyntax.prevLexInfo;
  end;
  logln('syntax', ' >> %s ("%s")'#10, [result, li.text]);
end;

function tKlausSynKeyword.toString: string;
begin
  result := '`'+tKlausLexParser.keywordValue(fKeyword)+'`';
end;

{ tKlausSynSubRule }

constructor tKlausSynSubRule.create(aSyntax: tKlausSyntax; subRuleName: string);
begin
  inherited create(aSyntax);
  fSubRule := fSyntax.getRule(subRuleName);
end;

function tKlausSynSubRule.match(require: boolean): boolean;
begin
  logln('syntax', boolStr(require, 'req ', 'opt ') + 'subrule: ' + toString + #10);
  result := fSubRule.match(require);
end;

function tKlausSynSubRule.toString: string;
begin
  result := '<' + fSubRule.name + '>';
end;

{ tKlausSynRule }

constructor tKlausSynRule.create(aSyntax: tKlausSyntax; aName: string; def: string = '');
begin
  inherited create;
  fSyntax := aSyntax;
  fName := u8lower(aName);
  fMarker := 0;
  if fName <> '' then begin
    if fSyntax.rules.IndexOf(fName) >= 0 then assert(false, 'Duplicate syntax rule name');
    fSyntax.rules[fName] := self;
  end;
  if def <> '' then try
    parseDef(def);
  except
    fSyntax.rules.remove(fName);
    raise;
  end;
end;

destructor tKlausSynRule.destroy;
var
  i: integer;
begin
  for i := count-1 downto 0 do freeAndNil(fEntries[i]);
  inherited destroy;
end;

function tKlausSynRule.toString: string;
var
  sep: string = '';
  i: integer;
begin
  result := name;
  if (result <> '') then result += ':: ';
  for i := 0 to count-1 do begin
    result += sep + entries[i].toString;
    sep := ' ';
  end;
end;

function tKlausSynRule.getCount: integer;
begin
  result := length(fEntries);
end;

function tKlausSynRule.getEntries(idx: integer): tKlausSynEntry;
begin
  if (idx < 0) or (idx >= count) then assert(false, 'Invalid item index');
  result := fEntries[idx];
end;

procedure tKlausSynRule.parseDef(def: string);
var
  p: tKlausSynLexParser;
begin
  p := tKlausSynLexParser.create(def);
  try
    parse(p);
  finally
    freeAndNil(p);
  end;
end;

function tKlausSynRule.parse(p: tKlausSynLexParser; stopAt: tKlSynSymbolSet): tKlSynSymbol;
const
  grpOpening = [klssReqSglGroup, klssReqMulGroup, klssOptSglGroup, klssOptMulGroup];
  grpMul = [klssReqMulGroup, klssOptMulGroup];
  grpOpt = [klssOptSglGroup, klssOptMulGroup];
  grpEnd: array[klssReqSglGroup..klssOptMulGroup] of tKlSynSymbol = (
    klssReqGroupEnd, klssReqGroupEnd, klssOptGroupEnd, klssOptGroupEnd);
var
  li: tKlSynLexInfo;
  g: tKlausSynGroup;
  r: tKlausSynRule;
  stop: tKlSynSymbol;
  marker: boolean = false;
  markerFound: boolean = false;
begin
  p.getNextLexem(li);
  while li.lexem <> klslEOF do begin
    if (stopAt <> []) and (li.lexem = klslSymbol) and (li.symbol in stopAt) then exit(li.symbol);
    case li.lexem of
      klslRule: begin
        addEntry(tKlausSynSubRule.create(fSyntax, li.value), marker);
        marker := false;
      end;
      klslKlausKwd: begin
        addEntry(tKlausSynKeyword.create(fSyntax, tKlausValidKeyword(li.klausKeyword)), marker);
        marker := false;
      end;
      klslKlausLex: begin
        addEntry(tKlausSynLexem.create(fSyntax, li.klausLexem), marker);
        marker := false;
      end;
      klslKlausSym: begin
        addEntry(tKlausSynSymbol.create(fSyntax, li.klausSymbol), marker);
        marker := false;
      end;
      klslSymbol:   begin
        if li.symbol = klssMarker then begin
          assert(not markerFound, 'Duplicate syntax marker');
          marker := true;
          markerFound := true;
        end else begin
          if li.symbol in grpOpening then begin
            g := tKlausSynGroup.create(fSyntax, li.symbol in grpOpt, li.symbol in grpMul);
            repeat
              r := tKlausSynRule.create(fSyntax, '');
              stop := r.parse(p, [klssGroupSep, grpEnd[li.symbol]]);
              g.addItem(r);
              if stop = grpEnd[li.symbol] then break
              else assert(stop = klssGroupSep, 'Syntax rule syntax error');
            until false;
            addEntry(g, marker);
            marker := false;
          end else
            assert(false, 'Unexpected symbol in a syntax rule');
        end;
      end;
    else
      assert(false, 'Syntax rule syntax error');
    end;
    p.getNextLexem(li);
  end;
  assert(length(fEntries) > 0, 'Empty syntax rule');
  result := klssInvalid;
end;

procedure tKlausSynRule.addEntry(entry: tKlausSynEntry; setMarker: boolean);
var
  idx: integer;
begin
  idx := length(fEntries);
  if setMarker then fMarker := idx
  else if fMarker < 0 then fMarker := 0;
  setLength(fEntries, idx+1);
  fEntries[idx] := entry;
end;

function tKlausSynRule.match(require: boolean): boolean;

  function opt(entry: tKlausSynEntry): boolean; inline;
  begin
    result := (entry is tKlausSynGroup) and (entry as tKlausSynGroup).fOptional;
  end;

var
  i, cnt: integer;
  recognized: boolean = false;
  matched: boolean = false;
begin
  logln('syntax', boolStr(require, 'req ', 'opt ') + 'rule: ' + toString + #10);
  try
    fSyntax.matching(self);
    try
      cnt := 0;
      result := true;
      for i := 0 to count-1 do begin
        if fEntries[i].match(require) then begin
          matched := true;
          inc(cnt);
        end else if not opt(fEntries[i]) then begin
          fSyntax.prevLexInfo(cnt);
          exit(false);
        end;
        if matched and (i >= fMarker) then begin
          if not recognized then fSyntax.recognized(self);
          recognized := true;
          require := true;
        end;
      end;
    finally
      fSyntax.matched(self);
    end;
  except
    on e: eKlausError do begin
      if e.code = ercSyntaxError then
        e.message := e.message + ' ' + fSyntax.formatErrInfo;
      raise;
    end;
    else raise;
  end;
end;

{ tKlausSynLexParser }

procedure tKlausSynLexParser.getNextLexem(out li: tKlSynLexInfo);
var
  c: u8Char;
begin
  if stream = nil then begin
    setLexInfo(LF, klslEOF, li);
    exit;
  end;
  c := nextChar;
  while not EOF do begin
    if not tKlausLexParser.isSpace(c) then break;
    c := nextChar;
  end;
  if not EOF then begin
    if c = '`' then begin
      processKeyword(c, li);
    end else if c = '<' then begin
      processEntry(c, li);
    end else if c = '"' then begin
      processKlausSym(c, li);
    end else if c = '#' then begin
      processLexem(c, li);
    end else begin
      processSymbol(c, li);
    end;
  end else
    setLexInfo(LF, klslEOF, li);
end;

procedure tKlausSynLexParser.setLexInfo(s: string; aLexem: tKlSynLexem; out li: tKlSynLexInfo);
begin
  assert(aLexem <> klslSymbol);
  with li do begin
    lexem := aLexem;
    symbol := klssInvalid;
    klausKeyword := kkwdInvalid;
    klausLexem := klxInvalid;
    klausSymbol := klsInvalid;
    value := s;
    pos := self.pos;
  end;
end;

procedure tKlausSynLexParser.setLexInfo(s: string; aSymbol: tKlSynValidSymbol; out li: tKlSynLexInfo);
begin
  with li do begin
    lexem := klslSymbol;
    symbol := aSymbol;
    klausKeyword := kkwdInvalid;
    klausLexem := klxInvalid;
    klausSymbol := klsInvalid;
    value := s;
    pos := self.pos;
  end;
end;

procedure tKlausSynLexParser.processEntry(c: u8Char; out li: tKlSynLexInfo);
begin
  setLexInfo('', klslRule, li);
  repeat
    c := nextChar;
    if c = '>' then break;
    if EOF or not tKlausLexParser.isIdentChar(c) then assert(false, 'Syntax rule name not closed');
    li.value += c;
  until FALSE;
end;

procedure tKlausSynLexParser.processKeyword(c: u8Char; out li: tKlSynLexInfo);
begin
  setLexInfo('', klslKlausKwd, li);
  repeat
    c := nextChar;
    if c = '`' then break;
    if EOF or not tKlausLexParser.isIdentChar(c) then assert(false, 'Keyword not closed');
    li.value += c;
  until FALSE;
  li.klausKeyword := tKlausLexParser.findKeyword(li.value);
  assert(li.klausKeyword <> kkwdInvalid, 'Klaus keyword not found');
end;

procedure tKlausSynLexParser.processLexem(c: u8Char; out li: tKlSynLexInfo);
begin
  setLexInfo('', klslKlausLex, li);
  c := nextChar;
  while tKlausLexParser.isIdentChar(c) do begin
    li.value += c;
    c := nextChar;
  end;
  feedBack;
  li.klausLexem := findKlausLexem(li.value);
  if not (li.klausLexem in [low(tKlausValidLexem)..high(tKlausValidLexem)])
  or (li.klausLexem in klausLexemIgnore) then assert(false, 'Invalid Klaus lexem type');
end;

function findSymbol(s: string): tKlSynSymbol;
var
  i: integer;
begin
  for i := low(klSynSymbols) to high(klSynSymbols) do
    if klSynSymbols[i].s = s then exit(klSynSymbols[i].k);
  result := klssInvalid;
end;

procedure tKlausSynLexParser.processSymbol(c: u8Char; out li: tKlSynLexInfo);
var
  c2: string;
  sym: tKlSynSymbol;
begin
  c2 := c + nextChar;
  sym := findSymbol(c2);
  if sym <> klssInvalid then
    setLexInfo(c2, sym, li)
  else begin
    sym := findSymbol(c);
    if sym <> klssInvalid then begin
      feedBack;
      setLexInfo(c, sym, li);
    end else
      setLexInfo(c, klslError, li);
  end;
end;

procedure tKlausSynLexParser.processKlausSym(c: u8Char; out li: tKlSynLexInfo);
begin
  setLexInfo('', klslKlausSym, li);
  repeat
    c := nextChar;
    if EOF then raise eKlausError.create(ercQuoteNotClosed, line, pos);
    if c = '"' then begin
      c := nextChar;
      if c = '"' then li.value += c
      else begin feedBack; break; end;
    end else
      li.value += c;
  until FALSE;
  li.klausSymbol := tKlausLexParser.findSymbol(li.value);
  assert(li.klausSymbol <> klsInvalid, 'Klaus symbol not found.');
end;

class function tKlausSynLexParser.findKlausLexem(s: string): tKlausLexem;
var
  n: String;
  i: tKlausValidLexem;
begin
  s := u8Upper(s);
  for i := low(tKlausValidLexem) to high(tKlausValidLexem) do begin
    n := u8Upper(klausLexemName(i));
    if n = s then exit(i);
  end;
  result := klxInvalid;
end;

{$ifdef enablelogging}
var
  s: string;
  i, idx: integer;
initialization
  for i := 0 to length(klausSynRules)-1 do begin
    s := klausSynRules[i].def;
    idx := pos('>>', s);
    while idx > 0 do begin
      delete(s, idx, 2);
      idx := pos('>>', s, idx);
    end;
    idx := pos('%', s);
    while idx > 0 do begin
      insert('%', s, idx);
      idx := pos('%', s, idx+2);
    end;
    logln('rules', klausSynRules[i].name + ' ::= ' + s + #10);
  end;
{$endif}
end.

