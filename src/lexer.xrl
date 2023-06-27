Definitions.

Id = [a-zA-Z][0-9a-zA-Z_]*
Real = [0-9]+.[0-9]+ 
Str  = ['.*']|[".*"]
WS = (\s+|!.*)


Rules.

%Program declaration.
program : {token, {program_start}}.
end{WS}program : {token, {program_end}}.

%Operations.
= : {token, {assign}}.
:: : {token, {declare}}.
\+ : {token, {add}}.

% Separators.
, : {token, {','}}.


%Basic types.
{Real} : {token, {float, list_to_float(TokenChars)}}.


%Identifiers
{Id} : {token, {identifier,list_to_atom(TokenChars)}}.

% Comments.
{WS}+ : skip_token.
implicit{WS}none : skip_token.

Erlang code.

get_nth_to_atom(Nth, String)->
    list_to_atom(lists:nth(Nth, string:tokens(String," "))).

strip(TokenChars,TokenLen) ->
    lists:sublist(TokenChars, 2, TokenLen - 2).
