-module(mega_super).
-behaviour(supervisor).

%% API
-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, mega_super}, ?MODULE, []).

init(_Args) ->
    io:format("~p (~p) starting...~n",[{local, ?MODULE}, self()]),
    SupervisorSpecification = #{
        strategy => one_for_all,
        intensity => 10,
        period => 60},

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
            id => router,
            start => {router, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [router]
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
            id => connection,
            start => {connection, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [connection]
        }
    ],

    {ok, {SupervisorSpecification, ChildSpecifications}}.
