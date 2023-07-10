forter
=====

An ERlang FORTran interpreter, targeted to execute netlib's LAPACK test suite written in Fortran.

Example 
-----
```erlang
    EndState = forter:interpret(forter:file("priv/add.f")),
    fortran_interpreter:fetch(result, EndState).
```
