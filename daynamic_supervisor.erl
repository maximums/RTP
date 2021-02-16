-module(daynamic_supervisor).
-behaviour(supervisor).
-author("Dodi Cristian-Dumitru").
-define(MIN_WORKERS, 1).

%% API
-export([start_link/0, add_worker/1, kill_workers/1]).

%%
-export([init/1]).

start_link() ->
    supervisor:start_link({local, supervisor}, ?MODULE, []).

init(_Args) ->
    io:format("~p (~p) starting...~n",[{local, ?MODULE}, self()]),
    SupervisorSpecification = #{
        strategy => simple_one_for_one,
        intensity => 10,
        period => 60},

    ChildSpecifications = [
        #{
            id => worker,
            start => {worker, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [worker]
        }
    ],

    {ok, {SupervisorSpecification, ChildSpecifications}}.

add_worker(N) when N > 0->
    {ok, Pid} = supervisor:start_child(supervisor, []),
    global:register_name(Pid,Pid),
    add_worker(N-1);

add_worker(0) ->
    0.

kill_workers(N) when N > 0 ->
    Workers = supervisor:which_children(supervisor),
    kill_workers(N, Workers);

kill_workers(0) ->
    ok.

kill_workers(N, Workers) when (length(Workers) > ?MIN_WORKERS) ->
    [{undefined, Pid, worker,[worker]}|_] = Workers,
    supervisor:terminate_child(supervisor, Pid),
    kill_workers(N-1);

kill_workers(_N, _Workers) ->
    ok.
    


            