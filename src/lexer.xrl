Definitions.

Id = [a-zA-Z][0-9a-zA-Z_]*
Integer = [0-9]+
Double  = [0-9]+\.[0-9]+D0
Real = [0-9]+\.[0-9]+ 
Logical = (\.true\.)|(\.false\.)
Str = ['.*']|[".*"]
WS = (\s+|!.*)
Type = real|double\sprecision|logical|integer
Operator = \+|\-|\*|\/|\.not\.|\.and\.|\.or\.

Rules.

%Program declaration.
program : {token, {token_start, TokenLine}}.
end{WS}program : {token, {token_end, TokenLine}}.

%Program flow.
go{WS}to  : {token, {token_goto, TokenLine}}.
do{WS}    : {token, {token_do, TokenLine}}.
if        : {token, {token_if, TokenLine}}.
else      : {token, {token_else, TokenLine}}.
end{WS}if : {token, {token_end_if, TokenLine}}.
then      : {token, {token_then, TokenLine}}.

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
{WS}continue : {token, {token_endl, TokenLine}}.

%Declarations
{WS}parameter : {token, {parameter, TokenLine}}.

%Basic types.
{Double} :  {token, {double, TokenLine, list_to_float(remove_lasts(2,TokenChars))}}.
{Real} :    {token, {float, TokenLine, list_to_float(TokenChars)}}.
{Integer} : {token, {integer, TokenLine, list_to_integer(TokenChars)}}.
{Logical} : {token, {boolean, TokenLine, to_logical(TokenChars)}}.


%Identifiers
{Id} : {token, {identifier, TokenLine,list_to_atom(TokenChars)}}.

% Comments.
{WS}+ : skip_token.
\n{WS}*\$ : skip_token.
implicit{WS}none : skip_token.


Erlang code.

remove_lasts(N, List)->
    Size = length(List),
    lists:sublist(List, 1, Size-N).

to_logical(String)->
    case String of
        ".true." -> 1;
        ".false." -> 0
    end.