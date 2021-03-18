-module(second_main_super).

-behaviour(supervisor).

%% API
-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, second_main_super}, ?MODULE, []).

init(_Args) ->
    io:format("Second main supervisor started ~p~n",[self()]),
    SupervisorSpecification = #{
        strategy => one_for_all,
        intensity => 10,
        period => 6},

    ChildSpecifications = [
        #{
            id => dayn_super_engagement,
            start => {dayn_super_engagement, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => supervisor,
            modules => [dayn_super_engagement]
        },
        #{
            id => aggregator,
            start => {aggregator, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [aggregator]
        },
        #{
            id => buffer,
            start => {aggr_storage, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [aggr_storage]
        },
        #{
            id => sink,
            start => {sink, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [sink]
        }
    ],

    {ok, {SupervisorSpecification, ChildSpecifications}}.
