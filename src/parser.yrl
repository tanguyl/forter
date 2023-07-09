Nonterminals
statements statement declare allocate identifier_list expression binary_expression unary_expression value assign identifier_list_declaration iteration expression_list
label if_group if_header if_branch.

Terminals 
identifier token_start token_end token_endl token_comma token_double_colon token_type
 token_assign float double integer boolean parameter '+' '-' '*' '/' '.not.' '.and.' '.or.' token_bracket_close token_bracket_open
token_goto token_do token_if token_end_if token_then token_else.

Rootsymbol statements.

Left 90 '.and.'.
Left 90 '.or.'.
Left 100 '+'.
Left 110 '-'.
Left 120 '*'.
Left 130 '/'.
Unary 200 '.not.'.

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


statements -> if_group statements : '$1' ++ '$2'.
if_group   -> if_header statement: ['$1', '$2'].
if_header  -> token_if token_bracket_open expression token_bracket_close token_endl: {'if', '$3'}.


expression -> binary_expression: '$1'.
expression -> unary_expression: '$1'.
expression -> value: '$1'.

binary_expression -> expression '+' expression: {value('$2'), '$1', '$3'}.
binary_expression -> expression '-' expression: {value('$2'), '$1', '$3'}.
binary_expression -> expression '*' expression: {value('$2'), '$1', '$3'}.
binary_expression -> expression '/' expression: {value('$2'), '$1', '$3'}.
binary_expression -> expression '.and.' expression: {'and', '$1', '$3'}.
binary_expression -> expression '.or.' expression: {'or', '$1', '$3'}.

unary_expression -> '.not.' expression: {'not', '$2'}.



value -> identifier: unwrap('$1').
value -> float: unwrap('$1').
value -> integer: unwrap('$1').
value -> double: unwrap('$1').
value -> boolean: unwrap('$1').

Erlang code.
unwrap({Type, _, Value})-> {Type, Value};
unwrap({Type, _}) -> {Type}.

value({Value, _}) -> Value;
value({_, _, Value}) -> Value.
    