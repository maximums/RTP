-module(emotion_values).
-export([init/1,get_emot_score/1]).


init(URL)->
    io:format("",[]),
    {ok,{{_Version,200,_Ok}, _Headers, Body}} = httpc:request(URL),
    parse_resp(Body).

parse_resp(Body) ->
    Lexemes = string:tokens(Body, "\r\n \t"),
    popul_ets_table(Lexemes).

popul_ets_table([Key|Ts])->
    [Value|Ls] = Ts,
    ets:insert(emotion_values, {Key, Value}),
    popul_ets_table(Ls);

popul_ets_table([]) ->
    finish.

get_emot_score(Word) ->
    L = ets:lookup(emotion_values,Word),
    [H|_] = L,
    Score = if length(L) == 0 -> 0;
                true -> {_,Sco} = H,
                Sco
    end,
    list_to_integer(Score).