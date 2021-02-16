-module(worker).
-behaviour(gen_server).
-author("Dodi Cristian-Dumitru").

%% API
-export([start_link/0]).

%% 
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([get_work/2 ]).


start_link() ->
    gen_server:start_link(?MODULE, [], []).



init(_Args) ->
    process_flag(trap_exit, true),
    io:format("~p worker....~n",[self()]),
    {ok, []}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({init_msg, Msg}, State) ->
    worker_msg_parser(Msg),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% Client functions

get_work(Pid,Msg) ->
    gen_server:cast(Pid,{init_msg, Msg}).


%% Worker Logic

worker_msg_parser(Msg) ->
    io:format("Your PID is: ~p~n|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||~n",[self()]).   
    % ok.