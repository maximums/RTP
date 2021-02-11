-module(daynamic_supervisor).
-behaviour(supervisor).
-author("Dodi Cristian-Dumitru").

%% API
-export([start_link/0, add_worker/2]).

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

add_worker(N, Workers) when N > 0->
    {ok, Pid} = supervisor:start_child(supervisor, []),
    add_worker(N-1,queue:in(Pid,Workers));

add_worker(0, Workers) ->
    io:format("Workers PID: ~w~n",[Workers]),
    Workers.


            