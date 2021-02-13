-module(router).
-export([]).
-author("Dodi Cristian-Dumitru").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% Callbacks
-export([init/1,handle_cast/2, handle_call/3, handle_info/2, terminate/2]).


start_link() ->
    Workers = daynamic_supervisor:add_worker(5, queue:new()),
    gen_server:start_link({local, router}, ?MODULE, [Workers], []).

init(Workers) ->
    io:format("~p (~p) starting...~n",[{local, ?MODULE}, self()]),
    {ok, Workers}.

handle_cast({msg, Msg}, State) ->
    [H|_] = State,
    {noreply, round_robin(H, Msg)};

handle_cast({workers, Workers}, _State) ->
    {noreply, Workers}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.


%%%%%%%%%% Sync nu am nevoie parca

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%%%%%%%%%%%%%%%%%%%%%%

round_robin(Workers, Msg) ->
    {{value, Worker}, NewWorkers} = queue:out(Workers),
    % io:format("Worker PID: ~p~n",[Worker]),
    gen_server:cast(Worker, Msg),
    [queue:in(Worker,NewWorkers)].



