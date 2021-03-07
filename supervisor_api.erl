-module(supervisor_api).
-define(MIN_WORKERS, 1).
-export([add_worker/2, kill_workers/2]).

add_worker(N, Supervisor_type) when N > 0->
        {ok, _Pid} = supervisor:start_child(Supervisor_type, []),
        add_worker(N-1, Supervisor_type);
    
    add_worker(0, _Supervisor_type) ->
        0.
    
    kill_workers(N, Supervisor_type) when N > 0 ->
        Workers = supervisor:which_children(Supervisor_type),
        kill_workers(N, Workers, Supervisor_type);
    
    kill_workers(0, _Supervisor_type) ->
        ok.
    
    kill_workers(N, Workers, Supervisor_type) when (length(Workers) > ?MIN_WORKERS) ->
        [{undefined, Pid, _,[_]}|_] = Workers,
        supervisor:terminate_child(Supervisor_type, Pid),
        kill_workers(N-1, Supervisor_type);
    
    kill_workers(_N, _Workers, _Supervisor_type) ->
        ok.