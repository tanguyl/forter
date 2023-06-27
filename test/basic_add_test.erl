-module(basic_files_test).

basic_add_test()->
    Program = "program addNumbers

! This simple program adds two numbers
   implicit none

! Type declarations
   real :: a, b, result

! Executable statements
   a = 12.0
   b = 15.0
   result = a + b
   print *, 'The total is ', result

end program addNumbers
"   ,
    forter:interpret(Program),
    1 = 2.
