Nonterminals
statement expression.

Terminals 
identifier program_start program_end.

Rootsymbol statement.

statement -> program_start identifier: {program_start, '$2'}.
statement -> program_end identifier: {program_end, '$2'}.

Erlang code.