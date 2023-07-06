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


do_loop_test()->
   Program = "
program do_iterate
      integer :: result0, result1
      result = 0

      do 100 loop = 0, 5
         result = result + loop
      100 continue

!  result0 should be 10
end program do_iterate
",
   State  = forter:interpret(Program),
   Result = fortran_interpreter:fetch(result, State),
   Result = 10.
