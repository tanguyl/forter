-module(basic_numeric_types).
-include_lib("eunit/include/eunit.hrl").

basic_double_test()->
   Program = "
program addNumbers

! This simple program adds two numbers
   implicit none

! Type declarations
   double precision :: a, 
           $b
           $, result

! Executable statements
   a = 12.0D0
   b = 15.0D0
   result = a + b + 2.0D0
!  result should be 29

end program addNumbers
   ",
   State  = forter:interpret(Program),
   Result = fortran_vm:fetch(result, State),
   Result = 29.0.

basic_float_test()->
   Program = "
program addNumbers

! This simple program adds two numbers
   implicit none

! Type declarations
   double precision :: a, b, result

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

basic_integer_test()->
   Program = "
program addNumbers

! This simple program adds two numbers
   implicit none

! Type declarations
   integer :: a, b, result

! Executable statements
   a = 12
   b = 15
   result = a + b + 2
!  result should be 29

end program addNumbers
   ",
   State  = forter:interpret(Program),
   Result = fortran_vm:fetch(result, State),
   Result = 29.

basic_boolean_test()->
   Program = "
program addNumbers

! This simple program adds two numbers
   implicit none

! Type declarations
   logical :: a, b

! Executable statements
   a = 1
   b = 0

end program addNumbers
   ",
   State  = forter:interpret(Program),
   Result = fortran_vm:fetch(a, State),
   Result = 1.