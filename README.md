forter
=====

FORTran inTERpreter.
It is targeted to execute netlib's LAPACK test suite.

Build
-----
    $ rebar3 compile

Example 
-----
forter:parse(forter:file("priv/empty.f")).

Man a file
-----
    % tokenize(String): Generate a list of tokens from a String input.
    
    % parse(String): Generate a AST from a String input.
    
    % file(Filepath): Reads file at Filepath as a String.

