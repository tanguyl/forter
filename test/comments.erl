-module(comments).
-include_lib("eunit/include/eunit.hrl").

comment_test()->
    Program =
"
program empty
! Something
end program empty
",
    forter:interpret(Program).