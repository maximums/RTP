-module(connection).
-export([start/1]).

start(Route) ->
    io:format("APP PID ~p~n~p~n",[self(),Route]),
    httpc:request(get, {Route, []}, [], [{sync, false}, {stream, self}]),
    inf_loop(),
    ok.

inf_loop() ->
    receive
        stop ->
            {stoped, self()};
        Msg ->
            gen_server:cast(router,{msg,{init_msg, Msg}}),
            inf_loop()
end.