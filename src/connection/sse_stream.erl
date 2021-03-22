-module(sse_stream).
-include("../utility.hrl").
-author("Dodi Cristian-Dumitru").

-export([get_msgs/2]).


get_msgs(Data, State) ->
    WData = split_msg(binary:bin_to_list(Data)),
    make_msg(WData, State).

make_msg([], State) ->
    State;

make_msg([H|Ts], State) ->
    NewState = make_msg(ends_with(H, "\n"), State++H),
    make_msg(Ts, NewState);
    
make_msg(true, Tweet) ->
    Init_msg = string:chomp(Tweet),
    try mochijson2:decode(Init_msg) of _ ->
        PropList = mochijson2:decode(Init_msg),
        {struct, [{<<"message">>, {struct, [{<<"tweet">>, {struct, Temp}}, _]}}]} = PropList,
        get_retweets(Temp, proplists:get_value(<<"retweeted_status">>, Temp))
    catch
        _:_ -> gen_server:cast(router,{msg, ?PANIC}) end,
    [];

make_msg(false, Chunk) ->
    Chunk.

split_msg(Str) ->
    string:split(Str, "event: \"message\"\n\ndata: ", all).

ends_with(Str, SubStr) ->
    lists:suffix(SubStr, Str).

get_retweets(Tweet, undefined) ->
    gen_server:cast(router,{msg, Tweet});

get_retweets(Tweet, {struct, ReTweet}) ->
    NewTweet = proplists:delete(<<"retweeted_status">>, Tweet),
    % io:format("~n____________________________________________________________________________________________________~n~p~n",[ReTweet]),
    gen_server:cast(router, {msg, NewTweet}),
    gen_server:cast(router, {msg, ReTweet}).
