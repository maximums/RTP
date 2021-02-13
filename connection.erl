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
    httpc:request(get, {?ROUTE_1, []}, [], [{sync, false}, {stream, self}]),
    httpc:request(get, {?ROUTE_2, []}, [], [{sync, false}, {stream, self}]),
    {ok, []}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({http, {_Reference,{error,socket_closed_remotely}}},State) ->
    ?MODULE:terminate(normal,State),
    {noreply,State};

handle_info(Info, State) ->
    gen_server:cast(router,{msg,{init_msg, Info}}),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
