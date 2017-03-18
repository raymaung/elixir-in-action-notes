# Chapter 08 - Fault-tolerance basics

* Fault tolerance is a first class concept in BEAM
* The aim of fault tolerance is to acknowledge the existence of failures, minimize their impact, and ultimately recover without human intervention

## 8.1 Runtime errors

When a runtime error happens, execution control is transferred to the call stack
to the error handling code. If you didn't specify such code, then the process
where error happened is **terminated**. All other process by default is unaffected.

## 8.1.1 Error types

Three types of run time errors

* errors
* exists
* throws

You can also **raise** your own error by using `raise/1`

```
> raise("something went wrong")
** (RuntimeError) Something went wrong
```

If a function **explicitly** raise an error, you should append the `!` to its name

```
> File.open!("nonexistent_file")
** (File.Error) could not open non_existing_file:  no such file or directory

> File.open("nonexistent_file") # <-- No !
{:error, :enoent}
```

Another type of error is `exit`.

```
exit("I'm done") # <-- deliberately terminate a process
```
* To terminate the current process

The final runtime error type is a `throw` - to allow non-local returns.

```
iex(3)> throw(:thrown_value)** (throw) :thrown_value
```

Loops are implemented as recursions - the consequence is that there are no 
constructs suh as `break`, `continue` and `return`.

When you're deep in a loop, it's not trivial to stop the loop and return a
value. `THROWS` can help with this but it is hacky like `goto`; should avoid
this technique as much as possible.

## 8.1.2 Handling errors

To intercept any kind of error (`error`, `exit` or `throw`):

```
try do
  ...catch
    :error, error_value ->
      ...
    
    :exit, error_value ->
      ...

    error_type, error_value ->      ...end
```
* `errot_type` is an atom indicating `:error`, `:exit` or `:throw`
* `error_value` contains error-specific information
* `catch` block is pattern

```
> raise("something wrong")
** (RuntimeError) something wrong
```
* `RuntimeError` is an Elixir specific decoration done from within `raise/1`
* To raise a naked undecorated error, use `:erlang:error/1`

As everything in Elixir is an expression that has a return value, `try`
return value is the result of the last executed statement - either `do`
block or `catch` block

```
try do
  raise("Something went wrong")catch
  _,_ -> IO.puts "Error caught"after
  IO.puts "Cleanup code"end
```
* `after` is to specify code that should **always** be executed after the `try` block
    * good for cleaning up resources
* the return value of `try` block remains `do` block or `catch` block - not `after` block

> ### Try and tail calls
> Recall the tail-call optimization is performed when the last thing a function does
> is call another function (or itself). This optimization isn't possible if the function
> call resides in a `try` block.

#### Define custom error

`defexception` to define custom errors.

Compared to other languages - C#, C++, Java and JavaScript, there's much **less** need to
catch runtime errors.

> A more common idiom is to let the process crash  then do something about it - restart.
> unpredictable errors that occur irregularly in special circumstances and are hard to
> reproduce. The cause of such errors usually lies in corruptness of the state.
> Therefore, a reasonable remedy for such errors is to let the process crash and start 
> another one.


## 8.2 Errors in concurrent systems

Concurrency plays a central role in building fault-tolerant, BEAM-based systems. This is due to the total isolation and independence of individual processes.

A crash in one process won’t affect the others (unless you explicitly want it to).

```
spawn(fn ->                     # <-- Start process 1
  spawn(fn ->                   # <-- Start process 2    :timer.sleep(1000)    IO.puts "Process 2 finished"   end)  raise("Something went wrong") # <-- Raise an error from process 1end)

[error] Error in process <0.61.0> # <-- Error logger output
...
Process 2 finished                # <-- Output of process 2
```
* Even after `process 1` crashes, the `process 2` execution gos on

## 8.2.1 Linking processes

A basic primitive for detecting a process crash is the concept of **links**. If two processes are linked, and one of them terminates, the other process receives an `exit` signal—a notification that a process has crashed.

An exit signal contains the pid of the crashed process and the **exit reason** — an arbitrary Elixir term.

In the case of a **normal** termination (the spawned function has finished), the exit reason is `:normal`.

## 8.2.2 Trapping exits

```
spawn(fn ->
  # Traps exits in the current process  Process.flag(:trap_exit, true)
  
  # Spawns a linked process  spawn_link(fn -> raise("Something went wrong") end) 
  # Receives and prints the message  receive do    msg -> IO.inspect(msg)  end
end)

# Out put
{:EXIT, #PID<0.85.0>, {%RuntimeError{message: "Something went wrong"}, [{:erlang, :apply, 2, []}]}}
```

## 8.2.3 Monitors

```
> target_pid = spawn(fn ->
  :timer.sleep(1000)
end)

> Process.monitor(target_pid)

> receive do
  msg -> IO.inspect msg
end


{:DOWN, #Reference<0.0.0.65>, :process, #PID<0.49.0>, :normal}
```

There are two main differences between monitors and links.

* First, monitors are unidi- rectional—only the process that created a monitor receives notifications.
* In addition, unlike a link, the observer process won’t crash when the monitored process termi- nates.
  * Instead, a message is sent, which you can handle or ignore.

> ### Exits are propagated through gen_server calls
> > When you issue a synchronous request via GenServer.call, if a server process crashes,
> then an exit signal will occur in your client process. This is a simple but very 
> important example of cross-process error propagation. Internally, `:gen_server` 
> sets up a temporary monitor that targets the server process. While waiting for a 
> response from the server, if a `:DOWN` message is received, `:gen_server` can 
> detect that a process has crashed and raise a corresponding exit signal in the client process.

Links, exit traps, and monitors make it possible to detect errors in a concurrent sys- tem

## 8.3 Supervisors

The idea behind supervision is simple. You have a bunch of worker processes that do 
meaningful work. Each worker is supervised by a supervisor process. Whenever a worker 
terminates, the supervisor starts another one in its place. The supervisor does 
nothing but supervise, which makes its code simple, error-free, and thus unlikely 
to crash. This pattern is so important and frequent that OTP provides the 
corresponding supervisor behaviour.

## 8.3.1 Supervisor behaviour

In the case of supervisors, a behaviour implemented in the generic :supervisor module works as follows:

* The behaviour starts and runs the supervisor process.* The supervisor process traps exits.* From within the supervisor process, child processes are started and linked to the supervisor process.
* If a crash happens, the supervisor process receives an exit signal and performs corrective actions, such as restarting the crashed process.
* If a supervisor is terminated, child processes are terminated immediately.

## 8.3.2 Defining a supervisor

```
defmacro Todo.Supervisor do
  use Supervisor

  def init(_) do
    processes = [
      worker(Todo.Cache, [])
    ]
    supervise(processes, strategy: :one_for_one)
  end
end
```

The only required callback is init/1, which must return a supervisor specification that consists of the following:

* The list of processes that need to be started and supervised. These are often called child processes.
* Supervisor options, such as how to handle process termination.

The term worker here means **“anything but a supervisor.”**

A worker is defined using the imported function `Supervisor.Spec.worker/2`.
This function is imported to your module when you call `use Supervisor`.

`worker(Todo.Cache, [])` means

* “This worker must be started by calling Todo .Cache.start_link with an empty arguments list.” 
* `supervise/2` function, which creates a tuple that describes the supervisor.
* `strategy: one_for_one` aka **restart strategy**.
  * **“If a child crashes, start another one.”**

When you start the supervisor process, the following things happen:
* The `init/1` callback is invoked. It must return the supervisor specification that describes
  * how to start children and 
  * what to do in case of a crash (restart strategy).* Given this specification, the supervisor behaviour starts the correspondingchild processes.3 If a child crashes, the information is propagated to the supervisor (via a linkmechanism), which performs a corresponding action according to the speci- fied restart strategy. In the case of a one_for_one supervisor, it starts a new child in place of the old one.

## 8.3.3 Starting a supervisor

```
# To obtain the PID 
> Process.whereis(:todo_cache)

# To kill the process
> Process.whereis(:todo_cache) |> Process.exit(:kill)

```

## 8.3.4 Linking all processes

## 8.3.5 Restart frequency

It’s important to keep in mind that a supervisor won’t restart a child process forever. The supervisor relies on the maximum restart frequency, which defines how many restarts are allowed in a given time period. By default, the maximum restart frequency is five restarts in five seconds. If this frequency is exceeded, the supervisor gives up and ter- minates itself. When the supervisor terminates, all of its children are terminated as well (because all children are linked to the supervisor).

## 8.4 Summary

* There are three types of runtime errors: `throws`, `errors`, and `exits`.
* When a runtime error occurs, execution moves up the stack to the corresponding try block. 
  * If an error isn’t handled, a process will crash.* Process termination can be detected in another process. To do this, you can use links or monitors. 
* Links are bidirectional—a crash of either process is propagated to the other process.
* By default, when a process terminates abnormally, all processes linked to it terminate as well. 
  * By trapping exits, you can react to the crash of a linked process and do something about it. 
* Supervisors can be used to start, supervise, and restart crashed processes.