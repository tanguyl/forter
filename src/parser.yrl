Nonterminals
statements statement declare allocate identifier_list expression value assign.

Terminals 
identifier token_start token_end token_endl token_comma token_double_colon token_type
token_operator token_assign float.

Rootsymbol statements.

Left 100 token_operator.

statements -> statement statements: ['$1'] ++ '$2'.
statements -> statement: ['$1'].

statement -> declare token_endl: {declare, '$1'}.
statement -> allocate token_endl: {allocate, '$1'}.
statement -> assign token_endl: {assign, '$1'}.
statement -> token_endl: {token_endl}.

declare -> token_start identifier: {token_start, unwrap('$2')}.
declare -> token_end identifier: {token_end, unwrap('$2')}.

allocate -> token_type token_double_colon identifier_list: {unwrap('$1'), '$3'}. 

identifier_list -> identifier token_comma identifier_list: [unwrap('$1')] ++ '$3'.
identifier_list -> identifier: [unwrap('$1')].

assign -> identifier token_assign expression: {unwrap('$1'), '$3'}.

expression -> expression token_operator expression: {unwrap('$2'), '$1', '$3'}.
expression -> value: '$1'.

value -> identifier: unwrap('$1').
value -> float: unwrap('$1').

Erlang code.
unwrap({Type, _, Value})-> {Type, Value};
unwrap({Type, _}) -> {Type}.
    
