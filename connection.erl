-module(connection).
-export([start/1]).

start(Route) ->
    io:format("APP PID ~p~n~p~n",[self(),Route]),
    httpc:request(get, {Route, []}, [], [{sync, false}, {stream, self}]),
    inf_loop(Route),
    ok.

inf_loop(Route) ->
    receive
        {http, {_T,{error,socket_closed_remotely}}} ->
            io:format("____________________________________________~n~p~n",[self()]),
            start(Route);
        Msg ->
            gen_server:cast(router,{msg,{init_msg, Msg}}),
            inf_loop(Route)
end.