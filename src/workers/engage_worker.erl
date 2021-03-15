-module(engage_worker).
-behaviour(gen_server).
-author("Dodi Cristian-Dumitru").


-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).


start_link() ->
    gen_server:start_link(?MODULE, [], [{debug, [statistics]}]).

init(_Args) ->
    process_flag(trap_exit, true),
    ets:insert(engage_workers,{self(),self()}),
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
    worker_api:check_4_panic(Lang, engage_workers),
    RC = proplists:get_value(<<"retweet_count">>, Msg),
    FC = proplists:get_value(<<"favorite_count">>, Msg),
    % io:format("~n|||||||||||||||||||||||||||||||||||||||||||||||||FOLLOW|||||||||||||||||||||||||||||||||||||||||||||||||||||||||~n~p~n",
    % [calc_eng_ratio(RC, FC, get_nr_followers(Msg))]),
    Eng_ratio = calc_eng_ratio(RC, FC, get_nr_followers(Msg)),
    gen_server:cast(aggregator, {engagement, #{id => ID, eng_ratio => Eng_ratio}}).


get_nr_followers([{<<"user">>, {struct, Info}}|_]) ->
    proplists:get_value(<<"followers_count">>, Info).

calc_eng_ratio(_,_, 0) -> 0;

calc_eng_ratio(Favorites, Retweets, Followers) ->
    (Favorites + Retweets) / Followers.