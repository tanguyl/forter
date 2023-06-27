-module(forter).
-export([tokenize/1, parse/1, file/1]).


file(FileName)->
    {ok, Binary} = file:read_file(FileName),
    erlang:binary_to_list(Binary).

tokenize(String)->
    Iterator = 
        fun I([Line|Next], Acc)->
            Tokens = lexer:string(Line),
            %io:format("Line is: ~sTokens are ~w~n~n", [Line, Tokens]),
            I(Next, [Tokens] ++ Acc);
        I([], Acc)->
            lists:reverse(Acc)
    end,

    Iterator(string:tokens(String, "\n"), []).

parse(String)->
    Tokens = tokenize(String),
    io:format("Tokens are:~n~w~n", [Tokens]),
    Parse  = parser:parse(Tokens),
    io:format("~w~n", [Parse]).
