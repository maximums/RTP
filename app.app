{application, app, [
    {description, "RTP - Lab1"},
    {vsn, "1"},
    {module, [autoscaler, connection, daynamic_supervisor, router, worker, app, emotion_values]},
    {registered, [supervisor, router, autoscaler, connection]},
    {application, [kernel, stdlib]},
    {mod, {app, []}},
    {env, []}
]}.