-module(raboteaghi).
-export([init/0]).

init() ->
    event_loop().

parse_msg(Msg)->
    ok.

emotion_analyze(Tweet)->
    ok.

event_loop()->
    io:format("Alive!~n",[]),
    receive
        die ->
            io:format("~n|||||||||||||||||||||||||||||||||DIED||||||||||||||||||||||||||||||||||||||||||||~n",[]),
            event_loop();
        Msg ->
            io:format("---------------------------------------------------------------------------------~n~w",[Msg]),
            supervisor ! {working, self()},
            event_loop()
    end.
