-module(super_super).
-author("Dodi Cristian-Dumitru").

-behaviour(application).

-export([start/2, start/0, stop/1, stop/0]).

start() ->
    application:start(?MODULE).

start(_Type, _Args) ->
    io:format("App starting...~n",[]),
    inets:start(),
    mega_super:start_link().

stop() ->
    application:stop(?MODULE).

stop(_State) ->
    ok.


