-module(dayn_super_engagement).
-behaviour(supervisor).
-author("Dodi Cristian-Dumitru").
-define(MIN_WORKERS, 1).

%% API
-export([start_link/0, add_worker/1, kill_workers/1]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, dayn_super_engagement}, ?MODULE, []).

init(_Args) ->
    SupervisorSpecification = #{
        strategy => simple_one_for_one,
        intensity => 100,
        period => 60},

    ChildSpecifications = [
        #{
            id => engage_worker,
            start => {engage_worker, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [engage_worker]
        }
    ],

    {ok, {SupervisorSpecification, ChildSpecifications}}.

    add_worker(N) ->
        supervisor_api:add_worker(N, dayn_super_engagement).
    
    kill_workers(N) ->
        supervisor_api:kill_workers(N, dayn_super_engagement, engage_workers).
      