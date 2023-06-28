Nonterminals
statements statement start.

Terminals 
identifier token_start token_end token_endl.

Rootsymbol statements.

statements -> statement statements.
statements -> statement.

statement -> token_start identifier token_endl: {'$1', '$2'}.
statement -> token_end identifier token_endl: {'$1', '$2'}.
statement -> token_endl.

Erlang code.
