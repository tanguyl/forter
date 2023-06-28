-module(forter).
-export([parse/1, file/1]).


file(FileName)->
    {ok, Binary} = file:read_file(FileName),
    erlang:binary_to_list(Binary).

parse(String)->
    {ok, Tokens, _} = lexer:string(String),
    io:format("Tokens are:~n~w~n", [Tokens]),
    Parse  = parser:parse(Tokens),
    Parse.
