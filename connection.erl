-module(connection).
% -export([init/0,request/1]).
-export([t/0]).

t() ->
    inets:start(),
    httpc:request(get, {"http://localhost:8000/tweets/1", []}, [], [{sync, false}, {stream, self}]),
    inf_loop(), ok.

inf_loop() ->
    receive
        stop ->
            {stoped, self()};
        Msg ->
            gen_server:cast(router,{msg,{init_msg, Msg}}),
            inf_loop()
end.