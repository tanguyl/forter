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