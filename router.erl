-module(router).
-behaviour(gen_server).
-author("Dodi Cristian-Dumitru").

-export([start_link/0]).

%% Callbacks
-export([init/1,handle_cast/2, handle_call/3, handle_info/2]).


start_link() ->
    gen_server:start_link({local, router}, ?MODULE, [], [{debug, [statistics]}]).

init(_Args) ->
    io:format("Router started ~p~n",[self()]),
    daynamic_supervisor:add_worker(2),
    autoscaler ! count,
    {ok, 1}.

handle_cast({msg, Msg}, State) ->
    Idx = round_robin(Msg, State),
    {noreply, Idx}.

handle_info(_Info, State) ->
    {noreply, State}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%%%%%%%%%%%%%%%%%%%%%%


round_robin(Msg, Idx) ->
    Workers = global:registered_names(),
    NewIdx = if Idx < length(Workers) ->  gen_server:cast(lists:nth(Idx, Workers), {init_msg,Msg}), Idx + 1;
                true -> gen_server:cast(lists:nth(1, Workers), {init_msg,Msg}), 1 end,
    NewIdx.