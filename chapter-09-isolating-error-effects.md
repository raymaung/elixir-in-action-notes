# Chapter 09 - Isolating error effects

## 9.1 Supervision trees

## 9.1.1 Separating loosely dependent parts

Running both the database and cache processes under the supervisor
makes it possible to restart each worker individually.

> ### Child processes are started synchronously
> In this example, the supervisor starts two child processes. 
> It’s important to be aware that children are started 
> synchronously, in the order specified. 
> 
> The supervisor starts a child, waits for it to finish, 
> and then moves on to start the next child. When the 
> worker is a `gen_server`, the next child is started only 
> after the `init/1` callback function for the current 
> child is finished.
> 
> You may recall from chapter 7 that `init/1` shouldn’t 
> run for a long time. This is precisely why. 
> 
> If `Todo.Database` was taking, say, five minutes to 
> start, you wouldn’t have the to-do cache available 
> all that time. 
> 
> Always make sure your `init/1` functions run fast, 
> and use the trick mentioned in chapter 7 (a process 
> that sends itself a message during initialization) 
> when you need more complex initialization.

## 9.1.2 Rich process discovery

You can’t keep a process’s pid for a long time, because 
that process might be restarted, and its successor will 
have a different pid. This is a property of the Supervisor 
pattern.

Therefore, you need a way to give symbolic names to supervised processes and access each process via this name. When a process is restarted, the successor will regis- ter itself under the same name, which will allow you to reach the right process even after multiple restarts.

> A process registry differs from standard local registration in 
> that aliases can be arbitrarily complex.

Every time a process is created, it can register itself to the registry under an alias. If a process is terminated and restarted, the new process will re-register itself. So, having a registry will give you a fixed point where you can discover processes (their pids). Because you need to maintain a long-running state, the registry needs to be a process.