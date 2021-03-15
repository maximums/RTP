-module(aggregator).
-behaviour(gen_server).
-author("Dodi Cristian-Dumitru").

-record(data_object, {tweet, score, ratio}).
% -record(db_object, {tweet=#data_object{}, user}).


%% API
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

start_link() ->
    gen_server:start_link({local, aggregator}, ?MODULE, [], []).

init(_Args) ->
    % aggregator ! oook,
    {ok, #{}}.
    
handle_cast({tweet, #{id := ID, msg := Tweet}}, State) ->
    O = check_id(ID, State),
    Nobj = #data_object{tweet=Tweet, score=O#data_object.score, ratio=O#data_object.ratio},
    NewState = update_state(check_obj(Nobj), Nobj, ID, State),
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
    io:format("--------------------------------------------------------------------------------~n~p~n",[Obj]),
    maps:remove(Id, State);

update_state(not_full, Obj, Id, State) ->
    maps:put(Id, Obj, State).


check_obj(Obj) when Obj#data_object.tweet =/= null, Obj#data_object.score =/= null, Obj#data_object.ratio =/= null ->
    % io:format("--------------------------------------------------------------------------------~n~p~n",[Obj]),
    full;
check_obj(_Obj) ->
    not_full.

% ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_info(_Info, State) ->
    io:format("--------------------------------------------------------------------------------------~n~p~n",[State]),
    aggregator ! ook,
    timer:sleep(100),
    {noreply, State}.

