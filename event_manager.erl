-module(event_manager).
-export([init/0,request/1]).
-export([]).

init() ->
    register(router,spawn(boss, init, [])),
    register(supervisor,spawn(smotreashi, init, [])),
    register(p1,spawn(event_manager, request, ["http://localhost:8000/tweets/1"])),
    register(counter,spawn(counter,count,[])).

request(Request) ->
    httpc:request(get, {Request, []}, [], [{sync, false}, {stream, self}]),
    loop().

loop() ->
    io:fomrat("P1-Alive!~n",[]),
    receive
        Msg -> router ! {init,Msg},
        loop()
    end.
