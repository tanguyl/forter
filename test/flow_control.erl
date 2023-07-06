-module(flow_control).
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
   Result = fortran_interpreter:fetch(result, State),
   Result = 29.

goto_test()->
   Program = "
program addNumbers

! This simple program adds two numbers
      implicit none

! Type declarations
      integer :: result
      result = 0
      
      parameter (a = 12, b = 15)
      go to 100

      result = a + b + 2
100   result = result + a + b
!  result should be 27

end program addNumbers
   ",
   State  = forter:interpret(Program),
   Result = fortran_interpreter:fetch(result, State),
   Result = 27.

