
-module(main_supervisor).

-behaviour(supervisor).
-define(TWEET1,"http://localhost:8000/tweets/1").
-define(TWEET2,"http://localhost:8000/tweets/2").

%% API
-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, main_supervisor}, ?MODULE, []).

init(_Args) ->
    io:format("Main supervisor started ~p~n",[self()]),
    SupervisorSpecification = #{
        strategy => one_for_all,
        intensity => 10,
        period => 6},

    ChildSpecifications = [
        #{
            id => daynamic_supervisor,
            start => {daynamic_supervisor, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => supervisor,
            modules => [daynamic_supervisor]
        },
        #{
            id => dayn_super_engagement,
            start => {dayn_super_engagement, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => supervisor,
            modules => [dayn_super_engagement]
        },
        #{
            id => autoscaler,
            start => {autoscaler, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [autoscaler]
        },
        #{
            id => router,
            start => {router, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [router]
        },
        #{
            id => connection,
            start => {connection, start_link, [?TWEET1,?TWEET2]},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [connection]
        },
        #{
            id => aggregator,
            start => {aggregator, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [aggregator]
        }
    ],

    {ok, {SupervisorSpecification, ChildSpecifications}}.
