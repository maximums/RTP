
-module(main_supervisor).

-behaviour(supervisor).

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
            id => second_main_super,
            start => {second_main_super, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => supervisor,
            modules => [second_main_super]
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
            start => {connection, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [connection]
        }
    ],

    {ok, {SupervisorSpecification, ChildSpecifications}}.
