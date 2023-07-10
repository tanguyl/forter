-module(if_flow).

-include_lib("eunit/include/eunit.hrl").

basic_if_test()->
    runner:run("
program if_test
    integer :: a, b

    if (.true.) a = 1

    b = 2
    if (.false.) 
$       b = 1

end program if_test
",
    [a, b],
    [1, 2]).

basic_ifelse_test()->
    runner:run("
program if_test
    integer :: a, b

    if (.true.) then
        a = 1
    else
        a = 2
    end if

    if (.false.) then
        b = 1
    else
        b = 2
    end if
end program if_test

",
    [a, b],
    [1,2]).

nested_ifelse_test()->
    runner:run("
program if_test
    integer :: a, b

    if (.true.) then
        if (.false.) then
            b = 2
        else if (.false.)
            b = 3
        else
            b = 4
        end if

        a = 1
    else
        a = 2
    end if

end program if_test

",
    [a, b],
    [1, 4]).

single_ifelse_test()->
    runner:run("
program if_test
    integer :: a, b

    if (.true.) then
        a = 1
        b = 2
    end if

end program if_test

",
    [a, b],
    [1, 2]).