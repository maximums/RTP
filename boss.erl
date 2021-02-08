-module(boss).
-export([init/0]).

init() ->
    Workers = receive _ -> ok end,
    io:format("B-Alive!~n",[]),
    event_loop(Workers).

send_work([H,Ts], Msg) ->
    {Pid, worker} = H,
    Pid ! Msg,
    Ts.

event_loop(Workers) ->
    receive
        {new, NewWorkers} ->
            event_loop(NewWorkers);
        {init, Msg} ->
            NewWorkers = send_work(Workers, Msg),
            event_loop(NewWorkers)
    end.
