-module(worker_api).
-author("Dodi Cristian-Dumitru").

-export([check_4_panic/2]).

check_4_panic(undefined, Type) ->
    io:format("~n~n<<<<<<<<<<<<<<<<<<<<<<< PANIC >>>>>>>>>>>>>>>>>>~n~n"),
    ets:delete(Type, self()),
    erlang:error(panic);

check_4_panic(_, _) ->
    ok.