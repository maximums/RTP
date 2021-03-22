-module(autoscaler).
-behaviour(gen_server).
-include("../utility.hrl").
-author("Dodi Cristian-Dumitru").


-export([start_link/0]).

%% Callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

start_link() ->
    gen_server:start_link({local, autoscaler}, ?MODULE, [], []).

init(_Args) ->
    io:format("Autoscaler started ~p~n",[self()]),
    {ok, [0]}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(count, _State) ->
    NewState = get_msg_nr(sys:statistics(router, get)),
    adjust_workers(NewState),
    sys:statistics(router, false),
    % io:format("Messages: ~p <-------> Workers: ~p <------->~n",[NewState,proplists:get_value(workers, supervisor:count_children(supervisor))]),
    sys:statistics(router, true),
    erlang:send_after(?INTERVAL, self(), count),
    {noreply, NewState};

handle_info(_Info, State) ->
    {noreply, State}.

get_msg_nr(Statistics) ->
    {ok, Ls} = Statistics,
    {messages_in, Nr_of_msg} = lists:keyfind(messages_in, 1, Ls),
    Nr_of_msg.

adjust_workers(Nr_of_msg) ->
    C = Nr_of_msg div 10,
    Diff = C - proplists:get_value(workers, supervisor:count_children(supervisor)),
    if 
        Diff >= 0 -> daynamic_supervisor:add_worker(Diff), dayn_super_engagement:add_worker(Diff);
             true ->  daynamic_supervisor:kill_workers(-Diff), dayn_super_engagement:kill_workers(-Diff)
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.
