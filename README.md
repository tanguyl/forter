forter
=====

An ERlang FORTran interpreter, targeted to execute netlib's LAPACK test suite written in Fortran.

Example 
-----
```erlang
    Vm = forter:interpret(forter:file("priv/add.f")),
    fortran_vm:fetch(result, Vm_state).
```
# Man
forter
-----
```erlang
    forter:file(Filepath)               % returns file at Filepath as a String.
    forter:interpret(String)            % Interprets the given String, returns the resulting fortran_vm.
```

fortran_vm
-----
```erlang
    fortran_vm:new()                    % Creates an empty fortran virtual machine.
    fortran_vm:apply(Instruction, VM)   % Applies Instruction to the VM, returns the resulting VM.
```

