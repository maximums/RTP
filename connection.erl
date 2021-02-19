-module(connection).
-behaviour(gen_server).

-export([start_link/2]).

%Callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link(ROUTE_1,ROUTE_2) ->
    gen_server:start_link({local, connection}, ?MODULE, [ROUTE_1,ROUTE_2], []).
    
init(URLS) ->
    [ROUTE_1|Ts] = URLS,
    [ROUTE_2|_] = Ts,
    httpc:request(get, {ROUTE_1, []}, [], [{sync, false}, {stream, self},{full_result,false}]),
    httpc:request(get, {ROUTE_2, []}, [], [{sync, false}, {stream, self},{full_result,false}]),
    io:format("Connections started ~p~n",[self()]),
    {ok, null}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({http, {_Reference,{error,socket_closed_remotely}}},State) ->
    erlang:error(socket_closed_remotely),
    {noreply,State};

handle_info({http,{_RequestId, stream, Body}}, State) when State =/= null ->
    T = binary_to_list(Body),
    F = ends_with(T,[125,10,10]),
    NewState = if F -> gen_server:cast(router,{msg,{init_msg, State++T}}),
                       null;
                  true -> State++T end,
    {noreply,NewState};

handle_info({http,{_RequestId, stream, Body}}, null) ->
    T = binary_to_list(Body),
    F = ends_with(T,[125,10,10]),
    NewState = if F -> gen_server:cast(router,{msg,{init_msg, T}}),
                       null;
                  true -> T end,
    {noreply,NewState};


handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ends_with(X,Y)->
    lists:suffix(Y,X).