-module(labels).
-include_lib("eunit/include/eunit.hrl").


label_test()->
   Program = "
program addNumbers

! This simple program adds two numbers
   implicit none

! Type declarations
100   parameter (a = 12, b = 15)

   result = a + b + 2
!  result should be 29

end program addNumbers
   ",
   State  = forter:interpret(Program),
   Result = fortran_vm:fetch(result, State),
   Result = 29.

