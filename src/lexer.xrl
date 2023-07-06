Definitions.

Id = [a-zA-Z][0-9a-zA-Z_]*
Integer = [0-9]+
Double  = [0-9]+\.[0-9]+D0
Real = [0-9]+\.[0-9]+ 
Logical = 0|1
Str = ['.*']|[".*"]
WS = (\s+|!.*)
Type = real|double\sprecision|logical|integer
Operator = \+|\-|\*|\/

Rules.

%Program declaration.
program : {token, {token_start, TokenLine}}.
end{WS}program : {token, {token_end, TokenLine}}.

%Program flow.
go{WS}to : {token, {token_goto, TokenLine}}.

%Operations.
= :  {token,  {token_assign, TokenLine}}.
:: : {token, {token_double_colon, TokenLine}}.
{Operator} : {token, {list_to_atom(TokenChars), TokenLine }}.

%Types.
{Type} : {token, {token_type, TokenLine, list_to_atom(TokenChars)}} .

% Separators.
,  : {token, {token_comma, TokenLine}}.
\n : {token, {token_endl, TokenLine}}.
\(  : {token, {token_bracket_open, TokenLine}}.
\)  : {token, {token_bracket_close, TokenLine}}.

%Declarations
parameter : {token, {parameter, TokenLine}}.

%Basic types.
{Double} :   {token, {double, TokenLine, list_to_float(remove_lasts(2,TokenChars))}}.
{Real} :    {token, {float, TokenLine, list_to_float(TokenChars)}}.
{Integer} :  {token, {integer, TokenLine, list_to_integer(TokenChars)}}.
{Logical} : {token, {boolean, TokenLine, list_to_integer(TokenChars)}}.


%Identifiers
{Id} : {token, {identifier, TokenLine,list_to_atom(TokenChars)}}.

% Comments.
{WS}+ : skip_token.
\n{WS}\$ : skip_token.
implicit{WS}none : skip_token.


Erlang code.

remove_lasts(N, List)->
    Size = length(List),
    lists:sublist(List, 1, Size-N).