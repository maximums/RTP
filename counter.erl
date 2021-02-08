-module(counter).
-export([count/0]).

count()->
    timer:sleep(1000),
    {message_queue_len, Len} = process_info(whereis(router), message_queue_len),
    supervisor ! {msgs, Len},
    io:format("C-Alive~n",[]),
    count().