-module(fortran_vm).
-export([new/0, apply/2, fetch/2]).

-record(f_vm,{vars}).

new()->
    #f_vm{vars=dict:new()}.

apply(Instruction, F_vm=#f_vm{vars=Vars})->
    io:format("Applying ~w~n", [Instruction]),
    case Instruction of 
        {token_endl}->
            F_vm;

        {declare, Declaration}->
            case Declaration of 
                {token_start, _ } -> F_vm;
                {token_end,   _ } -> F_vm
            end;

        {allocate, Allocation}->
            case Allocation of 
                {{token_type, Type}, Identifiers} ->
                    Allocator = fun({identifier, I}, F_vmi=#f_vm{vars=Varsi})->
                        F_vmi#f_vm{vars=dict:store(I, {Type, {}}, Varsi)}
                    end,
                    lists:foldl(Allocator, F_vm, Identifiers)
            end;

        {assign, Assignement}->
            case Assignement of 
                {{identifier, I}, Expression} ->
                    Value = eval(Expression, F_vm),
                    F_vm#f_vm{vars = dict:store(I, Value, Vars)}
            end
        end.

eval(Expression, F_vm=#f_vm{vars=Vars})->
    case Expression of
        {identifier, I} ->
            dict:fetch(I, Vars);
        {float, Value} ->
            Value;
        {{token_operator, Operator}, Lhs, Rhs}->
            case Operator of
                '+' -> eval(Lhs, F_vm) + eval(Rhs, F_vm);
                '-' -> eval(Lhs, F_vm) - eval(Rhs, F_vm);
                '*' -> eval(Lhs, F_vm) * eval(Rhs, F_vm);
                '/' -> eval(Lhs, F_vm) / eval(Rhs, F_vm)
            end

    end.

fetch(Key, #f_vm{vars=Vars})->
    dict:fetch(Key, Vars).