-module(forter).
-export([parse/1, file/1, interpret/1]).

file(FileName)->
    {ok, Binary} = file:read_file(FileName),
    erlang:binary_to_list(Binary).

parse(String)->
    {ok, Tokens, _} = lexer:string(String),
    {ok, Parse}     = parser:parse(Tokens),
    io:format("~nTokens are ~n~w~n, statements are : ~n~w~n~n", [Tokens, Parse]),
    Parse.

interpret(String)->
    Instructions = parse(String),
    fortran_interpreter:run(fortran_interpreter:new(Instructions)).