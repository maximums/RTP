-module(sink).
-behaviour(gen_server).
-include("../utility.hrl").
-author("Dodi Cristian-Dumitru").

%% API
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

start_link() ->
    gen_server:start_link({local, sink}, ?MODULE, [], []).
    
init(_Args) ->
    % mongo_api:insert(?db_client(), ?users_collection, #data_object{tweet = <<"tweet">>, score = <<"score">>, ratio = <<"ratio">>}),
    {ok, []}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, [H|Ts]) ->
    {noreply, [H|Ts]}.

% write_to_db(Date, true) ->
%     mongo_api:insert(?db_client(), ?users_collection, Date),
%     mongo_api:insert(?db_client(), ?tweets_collection, Date),
%     ok;

% write_to_db(Date, false) when length(Date) >= ?MAX_BATCH_SIZE ->
%     mongo_api:insert(?db_client(), ?users_collection, Date),
%     mongo_api:insert(?db_client(), ?tweets_collection, Date),
%     ok.

handle_info(_Info, State) ->
    {noreply, State}.