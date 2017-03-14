# Chapter 06 - Generic Server Processes

## 6.1 Building a generic server process

All code that implements a server process needs to do the following tasks:

* Spawn a separate process
* Run an infinite loop in the process
* Maintain the process state
* React to messages
* Send a response back to the caller

No matter what kind of a server process, these tasks need to be done.

## 6.1.1 Plugging in with modules

The generic code will perform various tasks common to server processes, leaving the specific decisions to concrete implementations.

* Make the generic code accept a plug-in module as the argument. That module is called a **callback module**.
* Maintain the module atom as part of the process state
* Invoke callback-module functions when needed.

A callback module must implement and export a well defined set of functions.

## 6.1.2 Implementing the generic code & 6.1.3 Using the generic abstraction

```
defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {request, caller} ->
        # Invokes the call back to handle the message
        {response, new_state} = callback_module.handle_call(request, current_state)

        # Sends the response back
        send(caller, {:response, response})
        # Loops with the new state
        loop(callback_module, new_state)
    end
  end

  def call(server_id, request) do
    # Sends the message
    send(server_id, {request, self})

    # Waits for the response
    receive do
      # Returns the response
      {:response, response} -> response
    end
  end
end

defmodule KeyValueStore do
  def init do
    # Initial process state
    HashDict.new
  end

  def start do
    ServerProcess.start(KeyValueStore)
  end

  def put(pid, key, value) do
    ServerProcess.call(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  def handle_call({:put, key, value}, state) do
    {:ok, HashDict.put(state, key, value)}
  end

  def handle_call({:get, key}, state) do
    {HashDict.get(state, key), state}
  end
end

# pid = ServerProcess.start(KeyValueStore)
# ServerProcess.call(pid, {:put, :some_key, :some_value})
# ServerProcess.call(pid, {:get, :some_key})
```

## 6.1.4 Supporting asynchronous requests

* To allow asynchronous request use implement `cast`
* Introduce the second request type to determine the request type

```
defmodule ServerProcess do  ...  def call(server_pid, request) do    send(server_pid, {:call, request, self})    ...
  end  
  defp loop(callback_module, current_state) do    receive do # <-- Tags the request message as a call      {:call, request, caller} ->      ...    end
  end  ...
end
```## 6.1.5 Exercise Refactoring the to-do server

## 6.2 Using `gen_server`

Instead of using manually baked custom `ServerProcess`, OTP ships with a much better support for generic server process called `gen_server`.

Some of the compelling features provided by `gen_server`

* Support for calls and casts
* Customizable timeouts for call requests
* Propagation of server-process crashes to client processes waiting for a response
* Support for distributed systems

Note there is **no special magic** behind `gen_server` - its code replies on concurrency primitives as explained in Chapter 05.

## 6.2.1 OTP behaviours

In Erlang terminology, a behaviour is generic code that implements a common pattern. The generic logic is exposed through the behaviour module, and you can plug into it by implementing a corre- sponding callback module. The callback module must satisfy a contract defined by the behaviour, meaning it must implement and export a set of functions. The behaviour module then calls into these functions, thus allowing you to provide your own speciali- zation of the generic code.

OTP ships with a few predefined behaviours

* `gen_server` - Generic implementation of a stateful server process
* `supervisor` - Provides error handling and recovery in concurrent systems
* `application` - Generic implementation of components and libraries
* `gen_event` - Provides event-handling support
* `gen_fsm` - Runs a finite state machine in a stateful server process

## 6.2.2 Plugging into `gen_server`

```
defmodule KeyValueStore do
  use GenServerend

#
# List injected functions by GenServer
#
> KeyValueStore.__info__ :functions
[code_change: 3, handle_call: 3, handle_cast: 2, handle_info: 2, init: 1, terminate: 2]

#
# Start the process - the second argument
# is a custom parameter that is passed to
# the process during its initialization
#
> GenServer.start(KeyValueStore, nil)
```

## 6.2.3 Handling requests

To work with `gen_server`, you need to implement three callbacks.

* `init/1`
    * accepts one argument - that is the second argument provided to `GenServer.start/2`
    * must be in `{:ok, initial_state}` or
    * returns `{:stop, some_reason}` if you decide the server process shouldn't be started
* `handle_cast/2`
    * accepts the request and the state
    * should return `{:noreply, new_state}`
* `handle_call/3`
    * accepts the request, the caller information and the state
    * should return the result in the format `{:reply, response, new_state}` 

* `GenServer.call/2` doesn’t wait indefinitely for a response. By default, if the response message doesn’t arrive in five seconds, an error is raised in the client process

## 6.2.4 Handling plain messages

* Messages sent to the server process via `GenServer.call` and `GenServer.cast` contain more than just a request payload

Similiar to custom `ServerProcess` using `:call` and `:cast`, `gen_server` has `$gen_cast` and `$gen_call` to decorate cast and call mesages for internal uses.

Occasionally you may need to handle messages that aren't specific to `gen_server`.

For example: `:timer.send_interval/2` which periodically sends a message to the caller process. Since they are not `gen_server` specific message (ie `cast` or `call` messages), you can handle using `handle_info/2`

```
defmodule KeyValueStore do
  use GenServer  def init(_) do
    #
    # Set up periodic message sending
    #    :timer.send_interval(5000, :cleanup)
    {:ok, HashDict.new}  end          
  #
  # Handles the plain :cleanup message
  #
  def handle_info(:cleanup, state) do
    IO.puts "performing cleanup..."
    {:noreply, state}  end
  
  #
  # Handles all other messages
  #       
  def handle_info(_, state), do: {:noreply, state}end

> GenServer.start(KeyValueStore, nil)
```

* Without the catch all `def handle_info(_, state)`, your process would crash the server process
  * If your callback function doesn’t match the provided arguments, an error is raised. Such errors aren’t handled by gen_server, and, consequently, the server pro- cess will crash.
  * plain messages are something you don’t have control over. 
  * A process may occasionally receive a VM-specific message even if you didn’t ask for it
  * But if your callback module doesn’t define handle_info/2, you don’t have to do this—it’s included as a default implementation, courtesy of use GenServer.

* Note, there is **not** match-all clauses for handle_cast and handle_call
  * `cast` and `calls` are well-defined requests
  * they specify interface between clients and the server process
    * an invalid cast means your client are using an unsupported interface


## 6.2.5 Other `gen_server` features

[`GenServer` Docs](https://hexdocs.pm/elixir/GenServer.html)

### ALIAS REGISTRATION

a process can be registered under a local alias (an atom), where local means the alias is registered only in the currently running BEAM instance

```
GenServer.start(  CallbackModule,  init_param,  name: :some_alias)

GenServer.call(:some_alias, ...)
GenServer.cast(:some_alias, ...)
```

### Stopping The Server

Returning `{:stop, reason, new_state}` from `handle_*` callbacks causes `gen_server` to stop the server process. If the termination is part of the standard workflow, you should use the atom `:normal` as the stoppage reason. If you’re in `handle_call/3` and also need to respond to the caller before terminating, you can return `{:stop, reason, response, new_state}`.

why you need to return a new state if you’re terminating the pro- cess. The reason is that just before the termination, gen_server calls the callback function terminate/2, sending it the termination reason and the final state of the process. This can be useful if you need to perform cleanup.## 6.2.6 Process life cycle

* A client process starts the server by calling `GenServer.start`
    * providing the callback module
    * this creats the new server process which is powered by `gen_server` behaviour
* When a message is received, gen_server invokes callback functions to handle it
* the process state is maintained in the gen_server loop but is defined and manip- ulated by the callback functions. It starts with init/1, which defines the initial state

## 6.2.7 OTP-compliant processes

Building production systems, you should usually **avoid** using plain processes started with `spawn`. Instead, all of your processes should be **OTP-compliant** processes.

All processes powered by OTP behaviours such as `gen_server` and `supervisor` are OTP compliant.

Elixir 1.0 introduces highter level abstractions that implement OTP compliant processes:

* tasks
* agents

They’re built on top of OTP concepts such as `gen_server` and `supervisor`.

## 6.3 Summary

* A generic server process is an abstraction that implements tasks common to any kind of server process, such as recursion-powered looping and message passing.

* A generic server process can be implemented as a behaviour. A behaviour drives the process, whereas specific implementations can plug into the behaviour viacallback modules.

* The behaviour invokes callback functions when the specific implementationneeds to make a decision.

* `gen_server` is an OTP behaviour that implements a generic server process.* A callback module for gen_server must implement various functions. Themost frequently used ones are `init/1`, `handle_cast/2`, `handle_call/3`, and`handle_info/2`.* You can interact with a `gen_server` process with the `GenServer` module.

* Two types of requests can be issued to a server process: `calls` and `casts`

* A `cast` is a fire-and-forget type of request—a caller sends a message and immedi-ately moves on to do something else.

* A `call` is a synchronous send-and-respond request—a caller sends a message andwaits until the response arrives, the timeout occurs, or the server crashes.

