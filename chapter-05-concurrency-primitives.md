# Chapter 05 - Concurrency primitives

## 5.1 Principles

To make your system hightly available, you have to tackle following challenges

* Minimize, isolate, and recover from the runtime errors (fault tolerance)
* Handle a load increase by adding more hardware resources without changing or redeploying the code (scalability)
* Run your system on multiple machines so that others can take over if one machine crashes (distribution)

In BEAM, a unit of concurrency is a **process**; a basic building block to build scalable, fault-tolerant, distributed systems

> A BEAM process is **NOT** an OS process; BEAM processes are ligher and
> cheaper than OS processes.

In production, a typical server system must handle many simultaneous requests from many different clients, maintain a shared state (for example, caches, user session data, and server-wide data), and run some additional background processing jobs.

It’s imperative to execute them in parallel as much as possible, thus taking advantage of all available CPU resources.

In BEAM, a process is a concurrent thread of execution.


```
OS Process
    - BEAM
        - OS Thread 1
            - Scheduler
                - BEAM Process-1
                - BEAM Process-2
                - BEAM Process-3
                - BEAM Process-N
        - OS Thread 2
        - ...
        - OS Thread M
```

Processes are light

* a couple of micro seconds to create a single process
* 1 to 2 KB initial memory footprint
    * OS Thread takes couple of megabytes just for the stack

Using a dedicated process for each task, you can take advantage of all available CPU cores and parallelize the work

Running tasks in different processes improves the server’s reliability and fault tolerance.

Each process can manage some state and can receive messages from other processes to manipulate or retrieve that state. A process can be considered a container of
the data; a place where an immutable structure is stored and kept alive for a longer time, possibly forever.

## 5.2 Workign with Processes

> #### Concurrency vs. parallelism
> Concurrency doesn’t necessary imply parallelism. Two concurrent things
> have independent execution contexts. But this doesn’t mean they will
> run in parallel.
> 
> If you run two CPU-bound concurrent tasks and only one CPU core,
> then parallel execution can’t happen.

## 5.2.1 Creating processes

* Use `spawn/1` to create a process

```
iex(4)> spawn(fn -> IO.puts(run_query.("query 1")) end)#PID<0.48.0> Immediately returned 

result of query 1 Printed after 2 seconds
```


```
async_query = fn(query_def) ->
  spawn(
    fn
      ->
        IO.puts(
          run_query.(query_def)
        )
    end
  )
end

> async_query.("query 1")
#PID<...>

result of query 1  # 2 second later
```

  * `async_query` takes on argument and binds it to pass data to the created process
  * Binds it to the `query_def` variable
  * Data is passed to the newly created process via the closure mechanism
    * Data is **deep copied** because two processes can't share any memory


## 5.2.2 Message Passing

* Processes communicate via messages

* When process **A** wants process **B** to do something, **A** sends **asynchronous** message to **B**
* Sending message amounts to storing it into the **receiver's mailbox**
* Caller then continue with its own execution
* Process mail box is **FIFO** queue - limited only by the available memory
* To send a message to a process, you need to have access to its PID

### Sending/Receiving Message

* Sending `send`

    ```
    send(receiver_pid, {:an, :arbitrary, :term})
    ```
    
    * `send` plaes a message in the mail box of the receiver
    * sender continues doing something else

* Receiving `receive`

    ```
    receive do
      pattern_1 -> do_something
      pattern_2 -> do_something_else
    end
    ```
    
    * works similar to the `case` expression
    * Tries to pull one message from the process mail box
    * Match against the provided patterns then run the corresponding code
    * If there are no messages in the mail box, `receive` waits indefinitely for a new message
        * During `receive` wait, the process is **blocked**


### `RECEIVE` Algorithm

* Take the first message from the mail box
* Try to match it against the patterns, going from top to bottom
* If a pattern matches, run the corresponding code
* If no pattern matches, put the message back into the mail box at the same position it originally occupied, then try the next message
* If there are no more messages in the queue, wait for a new one to arrive
* If the after clause is specified and no message arrives in the given amount oftime, run the code from the after block.
* Return the last expression result just like any other Elixir expression

### Synchronous Sending

* Basic message-passing mechanism ias the asynchronous - **fire and forget** kind.
* No special language construct for a caller to get response from the receiver
  * Instead both sender/receiver must be programmed to cooperate using the basic asynchronous messaging facility
  *  the caller includes its own PID in the message contents and wait for the response

### Collecting Query Results

```
async_query = fn(query_def) ->  caller = self # <-- Stores the pid of the calling process  spawn(fn ->    send(caller, {:query_result, run_query.(query_def)})  end)
end
```
* the result of `self/0` depends on the calling process
* the worker process can now use `caller` to return the result of the calculation
* the caller process is neither blocked nor interrupted while receiving messages
* Sending a message doesn’t disturb the receiving process in any way
* The only thing affected is the content of the receiving process’s mailbox

## 5.3 Stateful server processes

It is common to create long-running processes that can respond to various messages. Such processes keep their internal state which other processes can query or even manipulate

* Stateful server processes resembld objects

## 5.3.1 Server processes

* **Server Processs** is an informal name for a process that runs for a long time (or forever)
* Endless tail recursion is used to run forever

```
defmodule DatabaseServer do  def start do    spawn(&loop/0)  end  defp loop do    receive do      ... 
    end    loop
  end  ...
end
```

* `start/0` is the so-called **interface function**
* `loop/0` runs in the server process
    * perfectly normal to have different functions from the **same** module running in different processes
    * no special relationship between modules and processes
* When implementing a server process, it usually makes sense to put all of its code in a single module.
* You typically **don't** need to code the recursion
    * Standard abstraction called `gen_server` is provided
 
> ### Interface functions
> * public and executed in the caller process
> * hide the details of process creation and the communication protocol
> 
> ### Implementation functions
> * private
> * run in the server process

### Server Processes are sequential

* Important to realize that a server process is internally sequential
* It runs a loop that processes one message at a time
    * If you issue five asynchronous requests to a single process, they will be handled one by one

### Keeping a process state

* Server processes open the possibility of keeping some kind of process-specific state
* To keep a state in the process, you can extend the loop function with additional argument(s). Here is a basic sketch:

```
def start do  spawn(fn ->    initial_state = ... # <-- Initializes the state during process creation    loop(initial_state) # <-- Enters the loop with that state  end)enddefp loop(state) do  ...  loop(state) # <-- Keeps the state during the loopend```

## 5.3.3 Mutable state

We’ve seen how to keep a constant, process-specific state. It doesn’t take much to make this state mutable. Here is the basic idea:

```
def loop(state) do  new_state = receive do    msg1 -> ...    msg2 -> ...  end  loop(new_state)end
```

* Wait for a message
* then based on the message, compute the new state
* loop recursively with the new state

## 5.3.4 Complex states

### Concurrent vs. Functional Approach

* Process that keeps a mutable state can be regarded as a kind of mutable data structure
* The role of the stateful process is to keep the data **available** while the system is **running**
* The data should be moded using pure functional abstractions

> A stateful process is then used on top of functional abstractions as
> a kind of concurrent controller that keeps the state and can be used
> to manipulate that state or read parts of it

## 5.3.5 Registered processes

* To make process **A** send messages to process **B**, you need the **B** PID.
    * in this sense, a PID resembles a reference or pointer in the OO world
* If you know there will always be one instance of process, then you can **register** it under a **local alias**
    * alias is called **local** because it is for the **currently** running BEAM.
    * it is important when you start connecting multiple BEAM instances to a distributed system

```
> Process.register(self, :some_name) # <-- Register a process> send(:some_name, :msg)             # <-- Send a mesage via a symbolic name
> receive do
    msg -> IO.puts "received #{msg}"  end
```

The following rules apply to registered processes:

* the process alias can only be an atom
* a single process can have only one alias
* two processes can't have the same alias

## 5.4 Runtime Considerations

## 5.4.1 A process is a bottleneck

* although multiple processes may run in parallel, a single process is always **sequential**
* If many processes send messages to a single process, then that single process can significantly affect overall throughput.
* If message can't be handled fast enough, try splitting the server into multiple processes; effectively parallelizing the original work

## 5.4.2 Unlimited process mailboxes

* Theoretically, a process mail box has an unlimited size but in practice, limited by available memory
* a single slow process may cause an entire system to crash by consuming all the available memory

```
def loop  receive    {:message, msg} ->
      do_something(msg)  end  loop
end
```
* `loop` handling message in the form of `{:message, msg}` could force other process mail box forever and taking up memory for no reason
* large mailbox contents cause performance slowdowns
    * having to iterates through the millions of unprocess message in the mail box
* To solve this problem, each server process should introduce a match all receive clause that deals with unexpected kinds of messages

```
def loop  receive    {:message, msg} ->      do_something(msg)
      
    #
    # Catch all
    #    other ->      log_unknown_message(other)  end  loop
end
```

## 5.4.3 Shared nothing concurrency

* processes share no memory
* sending a message to another process results in a deep copy of the message contents

    ```
    send(target_pid, data) # <-- the data variable is deep copied
    ```

* Less obvious deep data copied:

    ```
    data = ...
    spawn(fn ->
      ...
      some_fun(data) # <-- Results in a deep copy of the data variable
    )
    ```

* Deep copying is an in-memory operation, so it should be reasonably fast
* A special case where deep copying doesn’t take place involves binaries larger than **64 bytes**.
    * maintained on a special shared binary heap
    * sending them doesn't result in a deep copy
    * can be useful when you need to send information to many processes and the processes don't need to decode the string

### The purpose of shared nothing

* Simplifies the code
* don't need complicated synchronization mechanisms such as locks and mutexes
* One process can't comprise the memory of another
* possible to implement an efficient garbage collector
    * garbage collection can take place on a process level
    * Each process gets an initial small chunk of heap memory (**2 KB** on 64 Bit BEAM)
    * Instead of on large **stop the entire system** collection, you have many smaller collections


## 5.4.4 Scheduler inner workings

* Each BEAM scheduler is in reality an OS thread that manages the execution of BEAM process**es**
* BEAM uses only as many schedulers as there are logical proces- sors available
* **`n`** schedulers that run **`m`** processes, with **`m`** most often being significantly larger than **`n`**

Internally, each scheduler maintains a run queue, which is something like a list of BEAM processes it’s responsible for. Each process gets a small execution window, after which it’s preempted and another process is executed. The execution window is approximately 2,000 function calls (internally called reductions). Because you’re deal- ing with a functional language where functions are very small, it’s clear that context switching happens often, generally in less than 1 millisecond.

If one process performs a **long CPU-bound operation**, such as computing the value of pi to a billion dec- imals, it **won’t** block the entire scheduler, and other processes shouldn’t be affected.

Some special cases when a process will implicitly yield execution to the scheduler before its execution time is up such as `receive` and `:timer.sleep/1`

Another important case of implicit yielding involves I/O operations, which are internally executed on separate threads called async threads. When issuing an I/O call, the calling process is preempted, and other processes get the execution slot. After the I/O operation finishes, the scheduler resumes the calling process.

By default, BEAM fires up 10 async threads, but you can change this via the +A n Erlang flag

Additionally, if your OS supports it, you can rely on a kernel poll such as epoll or kqueue, which takes advantage of the OS kernel for nonblocking I/O. You can request the use of a kernel poll by providing the +K true Erlang flag when you start the BEAM.

## 5.5 Summary

* BEAM process is a lightweight concurrent unit of execution - processes are isolated and shared no memory
* Proesses can communicate with asynchronous messages
* A server proces is a process that runs for a long time
* Server processes can maintain their own private state