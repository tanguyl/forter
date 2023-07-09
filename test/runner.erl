-module(runner).
-export([run/3]).

run(Program, Variables, Expected)->
    State = forter:interpret(Program),
    Expected = lists:map(fun(V)->fortran_interpreter:fetch(V, State) end, Variables).
