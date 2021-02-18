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

handle_info(count, _State) ->
    NewState = get_msg_nr(sys:statistics(router, get)),
    adjust_workers(NewState),
    sys:statistics(router, false),
    fcking_function(),
    % io:format("Messages: ~p <-------> Workers: ~p <----------->~n",[NewState,proplists:get_value(workers, supervisor:count_children(supervisor))]),
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
    % io:format("DDDDDDDDDDDDDDDDDDDD: ~p~n",[Diff]),
    NewWorkers = if Diff >= 0 -> daynamic_supervisor:add_worker(Diff);
                    true -> daynamic_supervisor:kill_workers(-Diff)
        end,
    NewWorkers.

fcking_function() ->
    fcking_function(global:registered_names()).

fcking_function([]) ->
    ok;

fcking_function(L) ->
    [H|T] = L,
    {message_queue_len, Len} = process_info(H, message_queue_len),
    % io:format("Mess Len: ~p and PID ~p~n", [Len, H]),
    fcking_function(T).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.
