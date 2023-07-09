-module(if_flow).

-include_lib("eunit/include/eunit.hrl").

basic_if_test()->
    runner:run("
program if_test
    integer :: a, b

    if (.true.) 
        a = 1

    b = 2
    if (.false.)
        b = 1
end program if_test
",
    [a, b],
    [1, 2]).