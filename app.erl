-module(app).
-author("Dodi Cristian-Dumitru").
-define(EMOTIONS, "http://localhost:8000/emotion_values").

-behaviour(application).

-export([start/2, start/0, stop/1, stop/0]).

start() ->
    application:start(?MODULE).

start(_Type, _Args) ->
    io:format("App starting...~p~n",[self()]),
    inets:start(),
    ets:new(emotion_values,[bag,protected,named_table,{read_concurrency,true}]),
    emotion_values:init(?EMOTIONS),
    main_supervisor:start_link().

stop() ->
    application:stop(?MODULE).

stop(_State) ->
    ok.


