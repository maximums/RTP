-module(app).
-author("Dodi Cristian-Dumitru").

-behaviour(application).

-export([start/2, start/0, stop/1, stop/0]).

start() ->
    application:start(?MODULE).

start(_Type, _Args) ->
    io:format("App started...~p~n",[self()]),
    application:ensure_all_started(mongodb),
    ets:new(engage_workers,[bag, public, {write_concurrency,true}, {read_concurrency,true}, named_table]),
    ets:new(emotion_workers,[bag, public, {write_concurrency,true}, {read_concurrency,true}, named_table]),
    inets:start(),
    main_supervisor:start_link().

stop() ->
    application:stop(?MODULE).

stop(_State) ->
    ok.


