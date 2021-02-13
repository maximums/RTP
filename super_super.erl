-module(super_super).
-author("Dodi Cristian-Dumitru").
-define(ROUTE_1, "http://localhost:8000/tweets/1").
-define(ROUTE_2, "http://localhost:8000/tweets/2").

-behaviour(application).

-export([start/2, start/0, stop/1, stop/0]).

start() ->
    application:start(?MODULE).

start(_Type, _Args) ->
    inets:start(),
    daynamic_supervisor:start_link(),
    Q = daynamic_supervisor:add_worker(5, queue:new()),
    router:start_link(Q),
    autoscaler:start_link(),
    connect().

stop() ->
    application:stop(?MODULE).

stop(_State) ->
    ok.

connect() ->
    io:format("APP PID ~p~n",[self()]),
    PID = spawn(connection, start, [?ROUTE_1]),
    io:format("PID PID ~p~n",[PID]),
    connection:start(?ROUTE_2).

