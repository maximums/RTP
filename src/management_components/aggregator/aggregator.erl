-module(aggregator).
-behaviour(gen_server).
-include("../../utility.hrl").
-author("Dodi Cristian-Dumitru").

%% API
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

start_link() ->
    gen_server:start_link({local, aggregator}, ?MODULE, [], []).

init(_Args) ->
    {ok, #{}}.
    
handle_cast({tweet, #{id := ID, msg := Tweet}}, State) ->
    % io:format("~n______________________________________________JUST TWEET______________________________________________~n~p~n",[Tweet]),
    NewState = check_panic(proplists:get_value(<<"lang">>, Tweet), ID, Tweet, State),
    {noreply, NewState};

handle_cast({engagement, #{id := ID, eng_ratio := Ratio}}, State) ->
    O = check_id(ID, State),
    Nobj = #data_object{tweet=O#data_object.tweet, score=O#data_object.score, ratio=Ratio},
    NewState = update_state(check_obj(Nobj), Nobj, ID, State),
    {noreply,  NewState};

handle_cast({sentiment, #{id := ID, score := Score}}, State) ->
    O = check_id(ID, State),
    Nobj = #data_object{tweet=O#data_object.tweet,score=Score,ratio=O#data_object.ratio},
    NewState = update_state(check_obj(Nobj), Nobj, ID, State),
    {noreply, NewState}.

check_id(ID, State) ->
    maps:get(ID, State, #data_object{tweet=null, score = null, ratio = null}).

update_state(full, Obj, Id, State) ->
    extract_user(Obj),
    maps:remove(Id, State);

update_state(not_full, Obj, Id, State) ->
    maps:put(Id, Obj, State).

extract_user(DataObj) ->
    [User|Tweet] = DataObj#data_object.tweet,
    % io:format("~n______________________________________________JUST TWEET______________________________________________~n~p~n",[Tweet]),
    DB_T = #data_object{tweet=Tweet, score=DataObj#data_object.score, ratio=DataObj#data_object.ratio},
    gen_server:cast(buffer, {user, #db_user{user_info = User}}),
    gen_server:cast(buffer, {tweet, DB_T}).

check_obj(Obj) when Obj#data_object.tweet =/= null, Obj#data_object.score =/= null, Obj#data_object.ratio =/= null ->
    full;

check_obj(_Obj) ->
    not_full.

check_panic(undefined, _ID, _Tweet, State) ->
    State;

check_panic(_, ID, Tweet, State) ->
    O = check_id(ID, State),
    Nobj = #data_object{tweet=Tweet, score=O#data_object.score, ratio=O#data_object.ratio},
    update_state(check_obj(Nobj), Nobj, ID, State).

% 
% ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
%       Nobody wants them
%              |
%              V

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_info(_Info, State) ->
    {noreply, State}.

