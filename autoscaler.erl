-module(autoscaler).
-export([t/0]).

t() ->
    ChildSpecifications = [
        #{
            id => raboteaga,
            start => {worker, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [worker]
        }
    ],
    supervisor:start_child(super, ChildSpecifications).