-module(worker).
-behaviour(gen_server).
-author("Dodi Cristian-Dumitru").

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).



start_link() ->
    gen_server:start_link(?MODULE, [], [{debug, [statistics]}]).

init(_Args) ->
    process_flag(trap_exit, true),
    global:register_name(self(),self()),
    {ok, []}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({init_msg, Msg}, State) ->
    timer:sleep(rand:uniform(491) + 9),
    msg_parser(Msg),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

%% Worker Logic

msg_parser(Msg) ->
    Init_msg = string:chomp(Msg),
    PropList = mochijson2:decode(Init_msg),
    {struct, [{<<"message">>, {struct, [{<<"tweet">>, {struct, Temp}}, _]}}]} = PropList,
    io:format("~n---------------------------------------------------------------------~n~p",[Temp]).
    % Lang = proplists:get_value(<<"lang">>, Temp),
    % Text = proplists:get_value(<<"text">>, Temp),
    % sentiment_anal(binary_to_list(Lang), binary_to_list(Text)).

sentiment_anal("en", Msg)->
    Lexemes = string:tokens(string:trim(Msg), " ,.?!;:/'"),
    Score = [emotion_values:get_emot_score(Word)|| Word<-Lexemes],
    io:format("Tweet:~n--------------------------------------------~n~s~nScore: ~p~n~n",[Msg, lists:sum(Score)/length(Lexemes)]);

sentiment_anal(_,_Msg)->
    ok.
    % io:format("~n!n<<<<<<<<<<<<<<<<<<<<<<< Invalid language >>>>>>>>>>>>>>>>>>~n~n").