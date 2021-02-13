-module(worker_logic).
-author("Dodi Cristian-Dumitru").

% API
-export([]).

%%  Actual logic of worker

worker_handler() ->
    receive
        _ ->
            ok
end.