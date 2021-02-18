-module(worker).
-behaviour(gen_server).
-author("Dodi Cristian-Dumitru").

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).



start_link() ->
    gen_server:start_link(?MODULE, [], []).

init(_Args) ->
    process_flag(trap_exit, true),
    global:register_name(self(),self()),
    {ok, []}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({init_msg, Msg}, State) ->
    msg_parser(Msg),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Worker Logic

msg_parser(Msg) ->
    Init_msg = string:prefix(string:chomp(Msg), "event: \"message\"\n\ndata: "),
    PropList = mochijson2:decode(Init_msg),
    {struct,[{<<"message">>,{struct,[{<<"tweet">>,{struct,Temp}},_]}}]} = PropList,
    Lang = proplists:get_value(<<"lang">>, Temp),
    Text = proplists:get_value(<<"text">>, Temp),
    sentiment_anal(binary_to_list(Lang), binary_to_list(Text)).

sentiment_anal("en", Msg)->
    Lexemes = string:tokens(string:trim(Msg), " ,.?!;:/'"),
    ok;
    % Score = [emotion_values:get_emot_score(Word)|| Word<-Lexemes],
    % io:format("~n||||||||||||||||||||||||||||||||||||||||~n~p~n",[Lexemes]);
    % io:format("~n~p~n~n--------------->>>>>>>>>> ~p",[Msg,lists:sum(Score)]);

sentiment_anal(_,_Msg)->
    ok.
    % io:format("~n<<<<<<<<<<<<<<<<<<<<<<< Invalid language >>>>>>>>>>>>>>>>>>~n").