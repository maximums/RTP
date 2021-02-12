-module(super_super).
-author("Dodi Cristian-Dumitru").

-behaviour(application).

-export([start/2, start/0, stop/1, stop/0]).

start() ->
    application:start(?MODULE).

start(_Type, _Args) ->
    daynamic_supervisor:start_link(),
    Q = daynamic_supervisor:add_worker(5, queue:new()),
    router:start_link(Q).
    % autoscaler:start_link(),
    % connection:start().

stop() ->
    application:stop(?MODULE).

stop(_State) ->
    ok.