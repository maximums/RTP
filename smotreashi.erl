-module(smotreashi).
-export([kill_worker/1, spawn_worker/2, init/0]).

init() ->
    Workers = spawn_worker(10,[]),
    router ! Workers,
    io:format("S-Alive!~n",[]),
    event_loop(Workers, []).

spawn_worker(N,Ws) when N > 0 ->
    NewWs = lists:append(Ws, [{spawn(raboteaghi, init, []), worker}]),
    spawn_worker(N-1, NewWs);
spawn_worker(0, Ws) ->
    Ws.

kill_worker(Pid) ->
    Pid ! die.

adjust_workers(Num, Available) when Num > length(Available)->
    lists:append(Available, [{spawn_worker((Num - length(Available)),[]),worker}]);

adjust_workers(Num, Available) when Num < (length(Available) + 10)->
    {Pid, worker} = lists:last(Available),
    kill_worker(Pid),
    NewAvailable = lists:delete(lists:keyfind(Pid, 1, Available), Available),
    adjust_workers(Num-1, NewAvailable);

adjust_workers(Num, Available) when Num == 0; Num == length(Available)->
    Available.

add_Working(Pid, Working, Available)->
    NewAvailable = lists:delete(lists:keyfind(Pid, 1, Available), Available),
    NewWorking = lists:append(Working,[lists:keyfind(Pid, 1, Available)]),
    {NewAvailable, NewWorking}.


event_loop(Available, Working) ->
    receive
        {working, Pid} ->
            {NewAvailable, NewWorking} = add_Working(Pid,Working,Available),
            router ! {new, Available},
            event_loop(NewAvailable, NewWorking);
        {msgs, Num} ->
            NewAvailable = adjust_workers(Num, Available),
            router ! {new, Available},
            event_loop(NewAvailable, Working);
        {dying, Pid} ->
            NewWorking = lists:delete(lists:keyfind(Pid, 1, Working), Working),
            event_loop(Available, NewWorking)
    end.


            