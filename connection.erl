-module(connection).
-behaviour(gen_server).

-export([start_link/2]).

%Callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

start_link(ROUTE_1,ROUTE_2) ->
    gen_server:start_link({local, connection}, ?MODULE, [ROUTE_1,ROUTE_2], []).
    
init(URLS) ->
    [ROUTE_1|Ts] = URLS,
    [ROUTE_2|_] = Ts,
    httpc:request(get, {ROUTE_1, []}, [], [{sync, false}, {stream, self},{full_result,false}]),
    httpc:request(get, {ROUTE_2, []}, [], [{sync, false}, {stream, self},{full_result,false}]),
    io:format("Connections started ~p~n",[self()]),
    {ok, []}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({http, {_Reference,{error,socket_closed_remotely}}},State) ->
    erlang:error(socket_closed_remotely),
    {noreply,State};

handle_info({http, {_RequestId, stream, Body}}, State) ->
    {noreply, sse_stream:get_msgs(Body, State)};

handle_info(_Info, State) ->
    {noreply, State}.

