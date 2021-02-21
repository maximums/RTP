-module(sse_stream).
-export([get_msgs/2]).


get_msgs(Data, State) ->
    WData = split_msg(binary:bin_to_list(Data)),
    make_msg(WData, State).

make_msg([], State) ->
    State;

make_msg([H|Ts], State) ->
    NewState = make_msg(ends_with(H, "\n\n"), State++H),
    make_msg(Ts, NewState);
    
make_msg(true, Tweet) ->
gen_server:cast(router,{msg, Tweet}),
[];

make_msg(false, Chunk) ->
    Chunk.

split_msg(Str) ->
    string:split(Str, "event: \"message\"\n\ndata: ", all).

ends_with(Str, SubStr) ->
    lists:suffix(SubStr, Str).
