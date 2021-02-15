-module(autoscaler).
-behaviour(gen_server).
-author("Dodi Cristian-Dumitru").

-define(INTERVAL, 1000). % One second

%% API
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link({local, autoscaler}, ?MODULE, [], []).

init(_Args) ->
    io:format("~p (~p) starting...~n",[{local, ?MODULE}, self()]),
    {ok, [0]}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(count, State) ->
    io:format("State>>>>>>>>>>>> ~p~n",[State]),
    NewState = get_msg_nr(sys:statistics(router, get)),
    sys:statistics(router, false),
    sys:statistics(router, true),
    erlang:send_after(?INTERVAL, self(), count),
    {noreply, NewState};

handle_info(_Info, State) ->
    {noreply, State}.

get_msg_nr(Statistics) ->
    {ok, Ls} = Statistics,
    {messages_in, Nr_of_msg} = lists:keyfind(messages_in, 1, Ls),
    Nr_of_msg.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.




