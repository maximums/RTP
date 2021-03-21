-module(sink).
-behaviour(gen_server).
-include("../utility.hrl").
-author("Dodi Cristian-Dumitru").

% //////////////////////////////////////////////// DA-DA! Mie mii stidno pentru asta \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%% API
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

start_link() ->
    gen_server:start_link({local, sink}, ?MODULE, [], []).
    
init(_Args) ->
    {ok, MPid} = mongoc:connect(?seed, ?conn_opt, ?worker_opt),
    State = gen_server:call(buffer, {nr_of_elements, ?RAND()}),
    Timee = erlang:monotonic_time(millisecond),
    sink ! MPid,
    {ok, {State, Timee}}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(MPid, {State, Timee}) ->
    {{Us, Ts}, NTime} = db_insert({State, Timee}, MPid, ?sink_timer(Timee)),
    {NUs, NTs} = gen_server:call(buffer, {nr_of_elements, ?RAND()}),
    erlang:send_after(5, self(), MPid),
    {noreply, {{Us++NUs, Ts++NTs}, NTime}}.

% //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

db_insert({{Users, Tweets}, _}, MClient, F) when length(Users) == ?MAX_BATCH_SIZE; F == true; length(Tweets) ==?MAX_BATCH_SIZE ->
    {Us, NUs} = get_batch(Users),
    {Ts, NTs} = get_batch(Tweets),
    mongo_api:insert(MClient, ?users_collection, Us),
    mongo_api:insert(MClient, ?tweets_collection, Ts),
    {{NUs, NTs}, erlang:monotonic_time(millisecond)};

db_insert({{Us, Ts}, Time}, _, _) ->
    {{Us, Ts}, Time}.

get_batch(State) ->
    Batch = lists:sublist(State, ?MAX_BATCH_SIZE),
    NState = lists:sublist(State, ?MAX_BATCH_SIZE+1, length(State)),
    {Batch, NState}.