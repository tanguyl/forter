-module(booleans).
-include_lib("eunit/include/eunit.hrl").

basic_boolean_assign_test()->
    Program = "
program booleans

! This simple program adds two numbers
   implicit none

! Type declarations
   logical :: true, false

! Executable statements
   true = .true.
   false = .false.

end program booleans
   ",
   State  = forter:interpret(Program),
   True = fortran_interpreter:fetch(true, State),
   True = 1,
   False = fortran_interpreter:fetch(false, State),
   False = 0.

basic_boolean_expressions_test()->
    Program = "
program not

! This simple program adds two numbers
   implicit none

! Type declarations
   logical :: true, false

! Executable statements
   false = .not. .true.
   true = .not. .false.

end program not
   ",
   State  = forter:interpret(Program),
   True = fortran_interpreter:fetch(true, State),
   True = 1,
   False = fortran_interpreter:fetch(false, State),
   False = 0.


and_test()->
    Program = "
program and

! This simple program adds two numbers
   implicit none

! Type declarations
   logical :: a,b,c

! Executable statements
   a = .true. .and. .true.
   b = .true. .and. .false.
   c = .false. .and. .false.

end program and
   ",
   State  = forter:interpret(Program),
   [A,B,C] = lists:map(fun(Var)-> fortran_interpreter:fetch(Var, State) end, [a,b,c]),
   A = 1,
   B = 0,
   C = 0.

or_test()->
    Program = "
program or

! This simple program adds two numbers
   implicit none

! Type declarations
   logical :: a,b,c

! Executable statements
   a = .true. .or. .true.
   b = .true. .or. .false.
   c = .false. .or. .false.

end program or
   ",
   State  = forter:interpret(Program),
   [A,B,C] = lists:map(fun(Var)-> fortran_interpreter:fetch(Var, State) end, [a,b,c]),
   A = 1,
   B = 1,
   C = 0.