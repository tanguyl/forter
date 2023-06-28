Nonterminals
statements statement.

Terminals 
identifier token_start token_end token_endl.

Rootsymbol statements.

statements -> statement statements: {{statement, '$1'}, '$2'}.
statements -> statement: {'$1'}.

statement -> token_start identifier token_endl: {'$1', '$2'}.
statement -> token_end identifier token_endl: {'$1', '$2'}.
statement -> token_endl: {'$1'}.

Erlang code.
