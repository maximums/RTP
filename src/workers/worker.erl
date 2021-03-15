-module(worker).
-behaviour(gen_server).
-author("Dodi Cristian-Dumitru").

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).



start_link() ->
    gen_server:start_link(?MODULE, [], [{debug, [statistics]}]).

init(_Args) ->
    process_flag(trap_exit, true),
    ets:insert(emotion_workers, {self(),self()}),
    {ok, []}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({init_msg, Msg}, State) ->
    msg_parser(Msg),
    timer:sleep(rand:uniform(41) + 9),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

msg_parser(#{id := ID, msg := Msg}) ->
    Lang = proplists:get_value(<<"lang">>, Msg),
    worker_api:check_4_panic(Lang, emotion_workers),
    Text = proplists:get_value(<<"text">>, Msg),
    Score = sentiment_anal(Lang, binary_to_list(Text)),
    gen_server:cast(aggregator, {sentiment, #{id => ID, score => Score}}).


sentiment_anal(<<"en">>, Msg)->
    Lexemes = string:tokens(string:trim(Msg), " ,.?!;:/'"),
    Score = [emotion_values:get_emot_score(Word) || Word<-Lexemes],
    lists:sum(Score)/length(Lexemes);
    % io:format("Tweet:~n--------------------------------------------~n~s~nScore: ~p~n~n", [Msg, lists:sum(Score)/length(Lexemes)]);

sentiment_anal(_, _) -> 0.