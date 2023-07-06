Nonterminals
statements statement declare allocate identifier_list expression value assign identifier_list_declaration iteration expression_list
label.

Terminals 
identifier token_start token_end token_endl token_comma token_double_colon token_type
 token_assign float double integer boolean parameter '+' '-' '*' '/' token_bracket_close token_bracket_open
token_goto token_do.

Rootsymbol statements.

Left 100 '+'.
Left 110 '-'.
Left 120 '*'.
Left 130 '/'.

statements -> statement statements: ['$1'] ++ '$2'.
statements -> statement: ['$1'].

statement -> declare token_endl: {declare, '$1'}.
declare -> token_start identifier: {token_start, unwrap('$2')}.
declare -> token_end identifier: {token_end, unwrap('$2')}.

statement -> allocate token_endl: {allocate, '$1'}.
allocate -> token_type token_double_colon identifier_list: {unwrap('$1'), '$3'}. 
identifier_list -> identifier token_comma identifier_list: [unwrap('$1')] ++ '$3'.
identifier_list -> identifier: [unwrap('$1')].

statement -> assign token_endl: {assign, '$1'}.
assign -> identifier token_assign expression: {unwrap('$1'), '$3'}.

statement -> token_endl: {token_endl}.

statement -> label: '$1'.
label -> integer: {label, value('$1')}.

statement -> token_goto label token_endl: {goto, '$2'}.

statement -> token_do label iteration token_endl: {do, '$2', '$3'}.
iteration -> identifier token_assign expression_list: {unwrap('$1'), '$3'}.
expression_list -> expression token_comma expression : ['$1', '$3', {integer, 1}].
expression_list -> expression token_comma expression token_comma expression: ['$1', '$3', '$5'].

statement -> parameter token_bracket_open identifier_list_declaration token_bracket_close token_endl: {parameter, '$3'}.

identifier_list_declaration -> assign token_comma identifier_list_declaration: ['$1'] ++ '$3'.
identifier_list_declaration -> assign: ['$1'].


expression -> expression '+' expression: {unwrap('$2'), '$1', '$3'}.
expression -> expression '-' expression: {unwrap('$2'), '$1', '$3'}.
expression -> expression '*' expression: {unwrap('$2'), '$1', '$3'}.
expression -> expression '/' expression: {unwrap('$2'), '$1', '$3'}.
expression -> value: '$1'.

value -> identifier: unwrap('$1').
value -> float: unwrap('$1').
value -> integer: unwrap('$1').
value -> double: unwrap('$1').
value -> boolean: unwrap('$1').

Erlang code.
unwrap({Type, _, Value})-> {Type, Value};
unwrap({Type, _}) -> {Type}.
value({_, _, Value}) -> Value.
    