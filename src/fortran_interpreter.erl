-module(fortran_interpreter).
-export([new/1, run/1, apply/2, fetch/2]).

-record(finter,{current, instructions, variables, labels}).

new(Instructions)->
    Extractor = fun({P,I}, L)->
        case I of 
            % Labels points at next instruction.
            {label, Id} -> [{Id, P + 1}] ++ L;
            _ -> L
        end
    end,
    LabelsPos = lists:foldl(Extractor, [], lists:enumerate(Instructions)),
    io:format("~w~n", [LabelsPos]),
    #finter{current = Instructions, instructions = Instructions, variables = dict:new(), labels = dict:from_list(LabelsPos)}.

run(Finter=#finter{})->
    Loop = 
        fun F(FinterI=#finter{current=[Current | Next]})->
            F(fortran_interpreter:apply(Current, FinterI#finter{current=Next}));
        F(FinterI=#finter{current=[]})->
            FinterI
    end,
    io:format("~w~n", [Finter]),
    Loop(Finter).


apply(Instruction, Finter=#finter{instructions=Instructions, variables=Vars, labels=Labels})->
    io:format("Applying ~w~n", [Instruction]),
    case Instruction of 

        {allocate, Allocation}->
            case Allocation of 
                {{token_type, Type}, Identifiers} ->
                    Allocator = fun({identifier, I}, Finteri=#finter{variables=Varsi})->
                        Finteri#finter{variables=dict:store(I, {Type, {}}, Varsi)}
                    end,
                    lists:foldl(Allocator, Finter, Identifiers)
            end;

        {parameter, Assignements}->
            lists:foldl(fun (A,F)->fortran_interpreter:apply({assign, A}, F) end, Finter, Assignements);

        {assign, Assignement}->
            case Assignement of 
                {{identifier, I}, Expression} ->
                    Value = eval(Expression, Finter),
                    Finter#finter{variables= dict:store(I, Value, Vars)}
            end;

        {goto, Label}->
            JumpPos = dict:fetch(Label, Labels),
            Finter#finter{current=lists:sublist(Instructions, JumpPos, length(Instructions))};

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
        
        {{Operator}, Lhs, Rhs}->
            case Operator of
                '+' -> eval(Lhs, Finter) + eval(Rhs, Finter);
                '-' -> eval(Lhs, Finter) - eval(Rhs, Finter);
                '*' -> eval(Lhs, Finter) * eval(Rhs, Finter);
                '/' -> eval(Lhs, Finter) / eval(Rhs, Finter)
            end
    end,
    io:format("Expression resulted in ~w~n", [Result]),
    Result.

fetch(Key, #finter{variables=Vars})->
    dict:fetch(Key, Vars).