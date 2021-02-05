-module(smotreashi).
-export([]).

init() ->
    register(supervisor, spawn(smotreashi, , [])).

event_loop() ->