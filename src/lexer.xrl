Definitions.

Id = [a-zA-Z][0-9a-zA-Z_]*
Real = [0-9]+.[0-9]+ 
Str = ['.*']|[".*"]
WS = (\s+|!.*)
Type = real
Operator = \+

Rules.

%Program declaration.
program : {token, {token_start, TokenLine}}.
end{WS}program : {token, {token_end, TokenLine}}.

%Operations.
= :  {token,  {token_assign, TokenLine}}.
:: : {token, {token_double_colon, TokenLine}}.
{Operator} : {token, {token_operator, TokenLine, list_to_atom(TokenChars)}}.

%Types.
{Type} : {token, {token_type, TokenLine, list_to_atom(TokenChars)}} .

% Separators.
,  : {token, {token_comma, TokenLine}}.
\n : {token, {token_endl, TokenLine}}.


%Basic types.
{Real} : {token, {float, TokenLine, list_to_float(TokenChars)}}.


%Identifiers
{Id} : {token, {identifier, TokenLine,list_to_atom(TokenChars)}}.

% Comments.
{WS}+ : skip_token.
implicit{WS}none : skip_token.

Erlang code.


