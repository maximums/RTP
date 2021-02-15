-module(connection).
-behaviour(gen_server).
-define(ROUTE_1, "http://localhost:8000/tweets/1").
-define(ROUTE_2, "http://localhost:8000/tweets/2").

%% API
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link({local, connection}, ?MODULE, [], []).
    
init(_Args) ->
    io:format("~p (~p) starting...~n",[{local, ?MODULE}, self()]),
    httpc:request(get, {?ROUTE_1, []}, [], [{sync, false}, {stream, self},{full_result,false}]),
    httpc:request(get, {?ROUTE_2, []}, [], [{sync, false}, {stream, self},{full_result,false}]),
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
    if F ->
        gen_server:cast(router,{msg,{init_msg, State++T}}),
        {noreply, null};
    true ->
        {noreply, State++T}
end;

handle_info({http,{_RequestId, stream, Body}}, null) ->
    T = binary_to_list(Body),
    F = ends_with(T,[125,10,10]),
    if F ->
        gen_server:cast(router,{msg,{init_msg, T}}),
        {noreply, null};
    true ->
        {noreply, T}
end;


handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

ends_with(X,Y)->
    lists:suffix(Y,X).