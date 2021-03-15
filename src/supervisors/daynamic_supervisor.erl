-module(daynamic_supervisor).
-behaviour(supervisor).
-author("Dodi Cristian-Dumitru").
-define(MIN_WORKERS, 1).

%% API
-export([start_link/0, add_worker/1, kill_workers/1]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, supervisor}, ?MODULE, []).

init(_Args) ->
    io:format("Daynamic supervisor started ~p~n", [self()]),
    SupervisorSpecification = #{
        strategy => simple_one_for_one,
        intensity => 100,
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

    add_worker(N) ->
        supervisor_api:add_worker(N, supervisor).
    
    kill_workers(N) ->
        supervisor_api:kill_workers(N, supervisor, emotion_workers).


            