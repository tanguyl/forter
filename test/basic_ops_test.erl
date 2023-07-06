-module(basic_ops_test).
-include_lib("eunit/include/eunit.hrl").

basic_add_test()->
   Program = "
program addNumbers

! This simple program adds two numbers
   implicit none

! Type declarations
   real :: a, 
           $b
           $, result

! Executable statements
   a = 12.0
   b = 15.0
   result = a + b + 2.0
!  result should be 29

end program addNumbers
   ",
   State  = forter:interpret(Program),
   Result = fortran_interpreter:fetch(result, State),
   Result = 29.0.


basic_sub_test()->
   Program = "
program addNumbers

! This simple program adds two numbers
   implicit none

! Type declarations
   real :: a, b, result

! Executable statements
   a = 12.0
   b = 15.0
   result = a - b - 2.0

end program addNumbers
   ",
   State  = forter:interpret(Program),
   Result = fortran_interpreter:fetch(result, State),
   Result = -5.0.

basic_mult_test()->
   Program = "
program addNumbers

! This simple program adds two numbers
   implicit none

! Type declarations
   real :: a, b, result

! Executable statements
   a = 2.0
   b = 4.0
   result = a * b * 2.0

end program addNumbers
   ",
   State  = forter:interpret(Program),
   Result = fortran_interpreter:fetch(result, State),
   Result = 16.0.


basic_div_test()->
   Program = "
program addNumbers

! This simple program adds two numbers
   implicit none

! Type declarations
   real :: a, b, result

! Executable statements
   a = 4.0
   b = 2.0
   result = a / b / 2.0

end program addNumbers
   ",
   State  = forter:interpret(Program),
   Result = fortran_interpreter:fetch(result, State),
   Result = 1.0.

basic_precedence_test()->
   Program = "
program addNumbers

! This simple program adds two numbers
   implicit none

! Type declarations
   real :: a, b, result

! Executable statements
   a = 4.0
   b = 2.0
   result = a + 3.0 * b / 6.0 - 1.0

end program addNumbers
   ",
   State  = forter:interpret(Program),
   Result = fortran_interpreter:fetch(result, State),
   Result = 4.0.