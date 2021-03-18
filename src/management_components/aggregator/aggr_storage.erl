-module(aggr_storage).
-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).


start_link() ->
    gen_server:start_link({local, buffer}, ?MODULE, [], []).

init(_Args) ->
    {ok, #{users=>[], tweets=>[]}}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({user, User}, #{users:=Us,tweets:=Ts}) ->
    % gen_server:cast(sink, Us),
    {noreply, #{users=>[User|Us], tweets=>Ts}};

handle_cast({tweet, Tweet}, #{users:=Us,tweets:=Ts}) ->
    io:format("~n______________________________________________JUST TWEET______________________________________________~n~p~n",[Tweet]),
    {noreply, #{users=>Us, tweets=>[Tweet|Ts]}}.

handle_info(_Info, State) ->
    {noreply, State}.
