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
    dayn_super_engagement:add_worker(2),
    autoscaler ! count,
    {ok, 1}.

handle_cast({msg, Msg}, State) ->
    {noreply, round_robin(Msg, State)}.

handle_info(_Info, State) ->
    {noreply, State}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%%%%%%%%%%%%%%%%%%%%%%


round_robin(Msg, Idx) ->
    EmoWorkers = ets:tab2list(emotion_workers),
    EngWorkers = ets:tab2list(engage_workers),
    EmoPids = proplists:get_keys(EmoWorkers),
    EngPids = proplists:get_keys(EngWorkers),
    Id = uuid:to_string(uuid:uuid1()),
    gen_server:cast(aggregator, {tweet, #{id => Id, msg => Msg}}),
    send_msg(Id, Idx, EmoPids, EngPids, Msg).

send_msg(ID, Idx, EmoPids, EngPids, Msg) when Idx < length(EmoPids) ->
    gen_server:cast(lists:nth(Idx, EmoPids), {init_msg, #{id => ID, msg => Msg}}),
    gen_server:cast(lists:nth(Idx, EngPids), {init_msg, #{id => ID, msg => Msg}}),
    Idx + 1;

send_msg(ID, _Idx, EmoPids, EngPids, Msg) ->
    gen_server:cast(lists:nth(1, EmoPids), {init_msg, #{id => ID, msg => Msg}}),
    gen_server:cast(lists:nth(1, EngPids), {init_msg, #{id => ID, msg => Msg}}),
    2.


