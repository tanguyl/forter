-module(basic_add_test).
-include_lib("eunit/include/eunit.hrl").

basic_add_test()->
   Program = "
program addNumbers

! This simple program adds two numbers
   implicit none

! Type declarations
   real :: a, b, result

! Executable statements
   a = 12.0
   b = 15.0
   result = a + b + 2.0
!  result should be 29

end program addNumbers
   ",
   State  = forter:interpret(Program),
   Result = fortran_vm:fetch(result, State),
   Result = 29.0.