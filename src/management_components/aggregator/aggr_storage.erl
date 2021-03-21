-module(aggr_storage).
-include("../../utility.hrl").
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

handle_call({nr_of_elements, Nr}, _From, #{users:=Us,tweets:=Ts}) ->
    Users = lists:sublist(Us, Nr),
    Tweets = lists:sublist(Ts, Nr),
    NUs = lists:sublist(Us, Nr+1, length(Us)),
    NTs = lists:sublist(Ts, Nr+1, length(Ts)),
    NState = #{users=>NUs, tweets=>NTs},
    {reply, {Users, Tweets}, NState}.

handle_cast({user, User}, #{users:=Us,tweets:=Ts}) ->
    NUser = #{<<"user_info">> =>User#db_user.user_info},
    {noreply, #{users=>[NUser|Us], tweets=>Ts}};

handle_cast({tweet, Tweet}, #{users:=Us,tweets:=Ts}) ->
    NTweet = #{<<"tweet">> => Tweet#data_object.tweet,
               <<"Emotinal Score">> => Tweet#data_object.score,
               <<"Engagement Score">> => Tweet#data_object.ratio},
    {noreply, #{users=>Us, tweets=>[NTweet|Ts]}}.

handle_info(_Info, State) ->
    {noreply, State}.
