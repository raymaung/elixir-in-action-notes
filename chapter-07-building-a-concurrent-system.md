# Chapter 07 Building a concurrent system

## 7.1 Working with the mix project

## 7.2 Managing multiple to-do lists

Two approaches to work with multiple lists

### First approach - One Server for All To-Do Lists

* Implement a `TodoListCollection` to work with multiple to-do lists
    * Modify `Todo.Server` to use the new abstraction

* Only one process to server all users
    * will frequenly block each other
    * single server to process that performs all tasks

### Second Approach - A Server For Each To-Do Lists

* Run one instance of the existing to-do server for **each** to-do list


## 7.2.1 Implemeting a Cache

```
{:ok, cache} = Todo.Cache.start

length(:erlang.processes) # <-- returns a list of processes

1..100_000 |> Enum.each(fn(index) ->  Todo.Cache.server_process(cache, "to-do list #{index}")end)

1..100 |> Enum.each(fn(index) ->  Todo.Cache.server_process(cache, "to-do list #{index}")end)

a_todo = Todo.Cache.server_process(cache, "to-do list 31")
Todo.Server.add_entry(a_todo, %{date: {2013, 12, 19}, title: "Dentist"})
Todo.Server.entries(a_todo, {2013, 12, 19})

```

## 7.2.2 Analyzing process dependencies

## 7.3 Persisting data

* `:erlang.term_to_binary/1` accepts an Erlang term and returns an encoded bytes sequence
* `:erlang.binary_to _term/1` retrieves and decoded to an Erlang term

## 7.3.4 Addressing the processing bottleneck

### Bypassing the process

There are various reasons for running a piece of code in a dedicated serverprocess:

* The code must manage a long-living state
* The code handles a kind of a resource that can and should be reused - ie.
    * a TCP connection
    * File handle
    * Pipe to an OS process and so on
* A critical section of the code must be synchronized
    * only one process may run this code in any momeny

If none of these conditions are met, you probably don’t need a process and can run the code in client processes, which will completely eliminate the bottleneck and pro- mote parallelism and scalability.

### HANDLING REQUESTS CONCURRENTLY

```
def handle_cast({:store, key, data}, db_folder) do
  #
  # Handled in a spawned process
  #  spawn(fn ->    file_name(db_folder, key)    |> File.write!(:erlang.term_to_binary(data))  end)  {:noreply, db_folder}end


def handle_call({:get, key}, caller, db_folder) do
  
  #
  # Spawns the reader
  #  spawn(fn ->    data = case File.read(file_name(db_folder, key)) do      {:ok, contents} -> :erlang.binary_to_term(contents)      _ -> nil    end
    
    #
    # Responds from the spawned process
    #    GenServer.reply(caller, data)  end)
  
  #
  # No reply from the database process
  #  {:noreply, db_folder}end
```

* Send `{:noreply, db_folder}` from `handle_call` to indicate to `gen_server` that you won’t reply at this point

The problem with this approach is that concurrency is unbound. If you have 100,000 simultaneous clients, then you’ll issue that many concurrent I/O operations, which may negatively affect the entire system.

### LIMITING CONCURRENCY WITH POOLING

> #### Database Connection pool
> Increasing the number of concurrent disk-based operations doesn't in
> reality yield significant improvements and may hurt performance.
> 
> In real life, you would probably talk to a database that is able to
> handle multiple concurrent requests.
> 
> A couple of generic pool libraries are available for Elixir/Erlang
> ecosystem. [`poolboy`](https://github.com/devinus/poolboy) and
> 
> Depending on which database library, [`ecto`](https://github.com/elixir-ecto/ecto)
> is available, which internally relies on poolboy.
> 

## 7.4 Reasoning with processes

* A Server process is a simple entity - something like a concurrent object
    * it is sequential thing that accepts and handles requests, optionally maintain internal state
* Alternatively, a server process can be thought as **servicess**.
    * Each process is like a small service responsible for a single task