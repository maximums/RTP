{application, super_super, [
    {description, "RTP - Lab1"},
    {vsn, "1"},
    {module, [autoscaler, connection, daynamic_supervisor, router, worker, worker_logic, super_super]},
    {registered, [supervisor, router, autoscaler, conn1, conn2]},
    {application, [kernel, stdlib]},
    {mod, {super_super, []}},
    {env, []}
]}.