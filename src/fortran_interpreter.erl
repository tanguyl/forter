-module(fortran_interpreter).
-export([new/1, run/1, apply/2, fetch/2]).

-record(finter,{current, instructions, variables, labels, stack}).

new(Instructions)->
    Extractor = fun({P,I}, L)->
        case I of 
            % Labels points at next instruction.
            {label, Id} -> [{Id, P + 1}] ++ L;
            _ -> L
        end
    end,
    EnumeratedInstructions = lists:enumerate(Instructions),
    LabelsPos = lists:foldl(Extractor, [], EnumeratedInstructions),
    #finter{current = 1, instructions = Instructions, variables = dict:new(), labels = dict:from_list(LabelsPos), stack=[]}.

run(Finter=#finter{})->
    Loop = 
        fun F(FinterI=#finter{current=I, instructions = Instr}) when I =< length(Instr)->
            F(fortran_interpreter:apply(I, FinterI#finter{current=I+1}));
        F(FinterI=#finter{})->
            FinterI
    end,
    io:format("~w~n", [Finter]),
    Loop(Finter).


apply(I, Finter=#finter{current=Current, instructions=Instructions, variables=Vars, labels=Labels, stack=Stack})->
    % I is either an instruction by itself, or the instruction number.
    Instruction = if 
        is_integer(I) -> io:format("Instruction ~w~n", [I]), lists:nth(I, Instructions);
        true          -> I
    end,
    
    io:format("Applying ~w~n", [Instruction]),

    case Instruction of 

        {allocate, Allocation}->
            case Allocation of 
                {{token_type, Type}, Identifiers} ->
                    Allocator = fun({identifier, Id}, Finteri=#finter{variables=Varsi})->
                        Finteri#finter{variables=dict:store(Id, {Type, {}}, Varsi)}
                    end,
                    lists:foldl(Allocator, Finter, Identifiers)
            end;

        {parameter, Assignements}->
            lists:foldl(fun (A,F)->fortran_interpreter:apply({assign, A}, F) end, Finter, Assignements);

        {assign, Assignement}->
            case Assignement of 
                {{identifier, Id}, Expression} ->
                    Value = eval(Expression, Finter),
                    Finter#finter{variables= dict:store(Id, Value, Vars)}
            end;

        {goto, {label,Label}}->
            JumpPos = dict:fetch(Label, Labels),
            Finter#finter{current=JumpPos};

        {label, Label}->
            io:format("Label is ~w, Stack is ~w~n", [Label, Stack]),
            case Stack of 
                [{Instruction, Position, _}|_] -> Finter#finter{current=Position}; % Do loop.
                _                       -> Finter
            end;

        {do, Label, {Identifier, Iteration}}->
            case Stack of 
                [{Label, _, {_, End, Inc}} | Tail] ->
                    % This do was already executed.
                    Value = fetch(Identifier, Finter) + Inc,
                    io:format("Value vs end: ~w~w~n", [Value, End]),
                    case Value of 
                        End -> fortran_interpreter:apply({goto, Label}, Finter#finter{stack=Tail});
                        _   -> fortran_interpreter:apply({assign, {Identifier, {integer, Value}}}, Finter)
                    end;
                _ ->
                    % First time the loop is done: evaluate iteration.
                    IterationValues = list_to_tuple(lists:map( fun (Exp) -> eval(Exp, Finter) end, Iteration)),
                    Start = element(1, IterationValues),
                    fortran_interpreter:apply({assign, {Identifier, {integer, Start}}}, Finter#finter{stack = [{Label, Current-1, IterationValues}] ++ Stack})
            end;

        % Single if statement.
        {'if', Expression} ->
            Value = eval(Expression, Finter),
            if 
                Value == 1 ->
                    Finter;
                true ->
                    Finter#finter{current = Current + 1} % Skip next statement.
                end;

        Statement ->
            io:format("Skipping statement: ~w~n", [Statement]),
            Finter
        end.

eval(Expression, Finter=#finter{variables=Vars})->
    Result =
    case Expression of
        {identifier, I} ->
            R = dict:fetch(I, Vars),
            io:format("Fetched ~w~n", [R]),
            R;
        {float, Value} ->
            io:format("float: ~w~n", [Value]),
            Value;
        {double, Value} ->
            io:format("double: ~w~n", [Value]),
            Value;
        {integer, Value} ->
            io:format("integer: ~w~n", [Value]),
            Value;
        {boolean, Value} ->
            io:format("boolean: ~w~n", [Value]),
            Value;
        
        {Operator, Lhs, Rhs}->
            {Lv, Rv} = {eval(Lhs, Finter), eval(Rhs, Finter)},
            case Operator of
                '+' -> Lv + Rv;
                '-' -> Lv - Rv;
                '*' -> Lv * Rv;
                '/' -> Lv / Rv;

                'and' -> if Lv == 1 andalso Rv ==  1 -> 1; true -> 0 end;
                'or'  -> if Lv =/= 0 orelse Rv =/= 0 -> 1; true -> 0 end
            end;

        {Operator, Rhs}->
            Value = eval(Rhs, Finter),
            case Operator of
                'not' -> if Value == 0 -> 1; true -> 0 end
            end
    end,
    io:format("Expression resulted in ~w~n", [Result]),
    Result.

fetch(Entry, #finter{variables=Vars})->
    Key = 
    case Entry of 
        {identifier, Name} -> Name;
        _ -> Entry
    end,
    dict:fetch(Key, Vars).