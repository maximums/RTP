-record(data_object, {tweet, score, ratio}).
-record(db_user, {user_info}).

-define(TWEET1,"http://localhost:8000/tweets/1").
-define(TWEET2,"http://localhost:8000/tweets/2").
-define(PANIC, [{<<"text">>, <<"PANIC">>}]).

-ifndef(INTERVAL).
-define(INTERVAL, 1000). % One second
-endif.

-ifndef(MIN_WORKERS).
-define(MIN_WORKERS, 2).
-endif.

-ifndef(MAX_BATCH_SIZE).
-define(MAX_BATCH_SIZE, 150).
-endif.

-ifndef(MAX_DELAY).
-define(MAX_DELAY, 200). % 200 ms
-endif.


-ifndef(conn_opt).
-define(conn_opt, [
        { name,  mongoc_pool },
        { register,  mongoc_topology },
        { pool_size, 5 },
        { max_overflow, 10 },
        { overflow_ttl, 1000 },
        { overflow_check_period, 1000 },
        { localThresholdMS, 1000 },
        { connectTimeoutMS, 20000 },
        { socketTimeoutMS, 100 },
        { serverSelectionTimeoutMS, 30000 },
        { waitQueueTimeoutMS, 1000 },
        { heartbeatFrequencyMS, 10000 },
        { minHeartbeatFrequencyMS, 1000 },
        { rp_mode, primary },
        { rp_tags, [{tag,1}] }
]).
-define(worker_opt, [
    {database, <<"twitter_db">>},
    {login, <<"db_god">>},
    {password, <<"45215q">>},
    {ssl, true}
]).
-define(users_collection, <<"users">>).
-define(tweets_collection, <<"tweets">>).
-define(seed, {rs, <<"atlas-59hk3i-shard-0">>, [
    "ciotkiicluster-shard-00-00.saxmi.mongodb.net:27017",
    "ciotkiicluster-shard-00-01.saxmi.mongodb.net:27017",
    "ciotkiicluster-shard-00-02.saxmi.mongodb.net:27017"    
]}).
-endif.

-ifndef(RAND).
-define(RAND, fun() -> rand:uniform(50) + 50 end ).
-endif.

-ifndef(sink_timer).
-define(sink_timer,
    fun(Time) -> 
        Res = erlang:monotonic_time(millisecond) - Time,
        Res >= ?MAX_DELAY
    end 
).
-endif.