-module(fortran_interpreter).
-export([new/1, run/1, apply/2, fetch/2]).

-record(finter,{current, instructions, variables, labels, ifs, stack}).

new(Instructions)->
    EnumeratedInstructions = lists:enumerate(Instructions),

    % Extract label positions
    LabelExtractor = fun({Pos,I}, L)->
        case I of 
            % Labels points at next instruction.
            {label, Id} -> [{Id, Pos + 1}] ++ L;
            _ -> L
        end
    end,
    LabelsPos = lists:foldl(LabelExtractor, [], EnumeratedInstructions),

    % Detect if_group, group their expression with their position.
    % Stack is used for nested if_then.
    IfGroupExtractor = fun({Pos,I}, State={GroupId, Stack, Table})->
        io:format("Processing ~w with state ~w~n", [I, {GroupId, Stack}]),
        case I of 
            {if_then, Exp} -> {        Pos+1, [Pos+1]++Stack, dict:store (  Pos+1, [{Pos + 1,         Exp}], Table)};
            {else_if, Exp} -> {      GroupId,          Stack, dict:append(GroupId,  {Pos + 1,         Exp} , Table)};
            {end_if}       -> {hd(tl(Stack)),      tl(Stack), dict:append(GroupId,  {Pos + 1, {boolean, 1}}, Table)};
            _              -> State
        end
    end,
    EndState = lists:foldl(IfGroupExtractor, {0, [0], dict:new()}, EnumeratedInstructions),
    IfTable  = element(3, EndState),

    % Associate each else_if to the end_if.
    IfEndMapper = fun({_, Values}, Acc)->
        if 
            length(Values) > 2->
                {End,_}  = lists:last(Values), 
                lists:foldl(fun({P,_}, AccI) -> dict:store(P, End, AccI) end, Acc, lists:sublist(Values, 2, length(Values) - 2));
            
            true ->
                Acc
        end
    end,
    IfEndTable = lists:foldl(IfEndMapper, dict:new(), dict:to_list(IfTable)),

    io:format("Ifs table is: ~w~n", [dict:to_list(IfTable)]),
    Skip = fun(_,_)-> this_is_awkward_same_key_ifs_merge end,
    #finter{current = 1, instructions = Instructions, variables = dict:new(), labels = dict:from_list(LabelsPos), ifs = dict:merge(Skip, IfTable, IfEndTable), stack=[]}.

run(Finter=#finter{})->
    Loop = 
        fun F(FinterI=#finter{current=I, instructions = Instr}) when I =< length(Instr)->
            F(fortran_interpreter:apply(I, FinterI#finter{current=I+1}));
        F(FinterI=#finter{})->
            FinterI
    end,
    io:format("~w~n", [Finter]),
    Loop(Finter).


apply(I, Finter=#finter{current=Current, instructions=Instructions, variables=Vars, labels=Labels, ifs=Ifs, stack=Stack})->
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
            if  Value == 0 -> Finter#finter{current = Current + 1}; % Skip next statement;
                true       -> Finter
                end;

        % If block statements
        % Retrieve all boolean branching expressions, execute the first that is true.
        % else is coded as an else if true.
        {'if_then', _} ->
            Blocks    = dict:fetch(Current, Ifs),
            io:format("Blocks are ~w~n", [Blocks]),
            [{P,_}|_] = lists:dropwhile(fun({_,E}) -> eval(E, Finter) == 0 end, Blocks), 
            Finter#finter{current=P};

        {'else_if', _} ->
            % 'if_then' jumps to the correct branch. If 'else_if' is reached, the correct branch already executed; so jump to end.
            Finter#finter{current=dict:fetch(Current, Ifs)};

        Statement ->
            io:format("Skipping statement: ~w~n", [Statement]),
            Finter
        end.


eval(Expression, Finter=#finter{variables=Vars})->
    io:format("Evaluating ~w ", [Expression]),
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