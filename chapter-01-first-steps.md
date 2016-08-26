# Chapter 01 - First Steps

## 1.1 About Erlang

* A development platform for building scalable and reliable systems
* Conceived in in the mid-1980s by Erricsson
* Built for telecom systems but
    * No way specialized for the telecome
    * A general purpose development platform to provide
        * concurrency
        * scalability
        * fault-tolerance
        * distribution
        * high availability
* In the lat 80s and early 90s, the need for high availability as limited
    * Today, the focus is on the internet and the Web
    * Today, most systems are more about communication and collaboration
        * social network
        * content-management systems
        * on-demand multimedia
        * multiplayer games
* High availability is explicitly supported via technical concepts such as
    * scalability
    * fault tolerance
    * distribution
    * Unlike, most other modern platforms, these concepts are the main motivation behind Erlang
* Example Erlang Apps
    * WhatsApp messaging application
    * the Riak distributed database
    * the Heroku cloud
    * the Chef deployment automation system
    * the RabbitMQ message queue
    * financial systems and 
    * multiplayer backends
 
### 1.1.1 High availability

* Erlang was specifically created to support the development of high available systems
    * always online
    * provide service to their clients even when faced with unexpeced circumstances

#### Fault tolerance

* A system has to keep working when something unforeseen happens
    * unexpected errors, bugs components occasional failure
    * network connection drop
    * the entire machine crashes
* Whatever happens, localize the impact of an error as much as possible and recover from the error

#### Scalability

* A system to handle any possible load
    * able to respond to a load increase by adding more hardware  without any software intervention
        * without a system restart

#### Distribution

* Hav to run it on multiple machines
    * if a machine is taken down, another one can take over


#### Responsiveness

* Should always be reasonablely fast and responssiv
* Request handling should not be drastically prolongs even if the load increases or unexpected errors happen.


#### Live update

* Ability to push a new version without restarting any servers
    * we don't want to disconnect established calls while we upgrade

### 1.1.2 Erlang Concurrency

* Concurrency is at the heart and soul of Erlang systems
* Even the programming language is sometimes called a *concurrency-oriented language*

* see. Figure 1.1 Concurrency in the Erlang virtual machine - page 31
    * *BEAM* is a single OS process
    * Erlang process is a unit of concurrent execution
    * Scheduler is an OS thread responsible for executing multiple processes
    * BEAM uses multiple schedulers to parallelize the work over available CPU cores.

#### *Erlang Process* - basic concurrency primitive 

* Typical Erlang systems run thousands or even millions of such processes
* BEAM - Erlangs Virtual Machine uses its own schedulers to distribute the execution of processes over the available CPU cores
    * parallelizing execution as much as possible

#### Fault Tolerance

* Erlang processes are completly isolated from each other.
* No shared memory
* A crash of one process doesn't cause a crash of other processes

#### Scalability

* No shared memory
* Processes communicate via asynchronous messages
    * no complex synchronization mechanisms such as locks mutexes, semaphores
* Typically, Erlang systems are divided into a large number of concurrent processes which cooperate together to provide the complete service
* BEAM parallelize the processes as much as possible taking advantages of CPU cores

#### Distribution

* Communication between processes works the same way
    * reglardless whether in the same BEAM or two different instances on two separate remote computers
* Automatically ready to be distributed over multiple machines
    * make it possible to scale out

#### Responsiveness

* Runtime is specifically tuned to promote overall responsiveness of the system
* Erlang takes execute multiple processes by employing dedicated schedulers that interchangedably execut many Erlang processes
* A Scheduler is preemptive
    * gives a small execution window to each process, pauses it, then runs another process
    * Because the execution window is small, a single long-running process can't  lock gthe rest of the system
    * IO operations are internally delegated to separate threads or a kernel-poll services of the underlying OS is used if available
        * any process that waits for an I/O operation to finish won't block the execution of other processes
* Garbage collection is tuned to promote system responsiveness
    * with processes completely isolated and hare no memory,
        * each process is *individually* garbage collected without stopping the entire system
    * in multi-core system, it is possible for one CPU core to run a short garbage collection while the remaining cores are doing standard processing

### 1.1.3 Server-side systems

* Erlang can be used in various applications and systems
    * desktop applications
    * often used inembedded environments
    * its sweet sport, lies in server-side systems
        * systems that run on onre ore more servers and must serve many simulaneous clicents

#### *server-side system* 

* it is more than a simple server that processes request
* often distributed on multiple machines and collaborateto produce business value
* Different components on different machines

> Incoming Requests
>      |
>      |
>  Listeners
>      |
>      |
>  Request Handlers --> Responses
>      |
> +----+----------------------+
> |                           | 
> User specific data       cache
>    /|\                    /|\
>     |                      |              
> background job           background job
> 


#### Real life example

* see Page 33 - Table 1.1 Comparison of technologies used in two real life web servers

* Server A
    * HTTP server            : Nginx and Phusion Passenger
    * Request processing     : Ruby on Rails
    * Long Running Requests  : Go
    * Server wide state      : Redis
    * Persistable data       : Redis and MongoDB
    * Background jobs        : Cron, Bash scripts and Ruby
    * Service Crahs recovery : Upstart
* Server B
    * HTTP server            : Erlang
    * Request processing     : Erlang
    * Long Running Requests  : Erlang
    * Server wide state      : Erlang
    * Persistable data       : Erlang
    * Background jobs        : Erlang
    * Service Crahs recovery : Erlang

Server A is powered by various technologies - known and popular in the community

* There is rational behind every technology used in Server A
    * Ruby on Rails handles concurrent requres in separate OS processes
        * uses Redis to share data between these different processes
    * MongoDB is used to manage persitent front-end data
        * most often user related information
* the entire solution seems complex and not contained in a single project
    *  the components are deployed separately
    *  no trivial to start the entire system on a development machine

Server B accomplished the same technical requirements while relying on a single technology -

* Using platform technology for these purposes and proven in large systems
* the Entire server is a single project that runs inside a single BEAM
    * runs inside *a single OS process* using a handful of OS threads
* Concurrency is handled completly by the Erlang scheduler
* the system is scalable, responsive and fault tolerant
* Because it is implemented as a single project, it is easier to manage deploy and run locally on the development machine

> Note: Erlang tools are always full-blown alternatives to
> mainstream solutions - like Nginx, Riak and Redis
> 
> But Erlang gives options to implement an initial solution
> using exclusively Erlang and resort to alternative technologies
> when an Erlang solution isn't sufficient
> 
> This make the entire system more homogeneous and easier to develop
> and maintain.

Erlang can run in-process C code, can communicate with practically 
any external componenet such as message queues, in-memory key-value stores and external databases

### 1.1.4 The development platform

* More than a programming language
* Full-blown development platform; consist of four distinct parts
    1. the language
    2. the virtual machine
    3. the framework
    4. the tools

The primary way of writing code that runs in the Erlang virtual machine

* Simple functional language with basic concurrency primitives
* compiled into byte code executable in BEAM
* Vritual machine parallelizes your concurrent Erlang programs and takes care of process isolation, distribution and overall responsiveness of the system

#### *Open Telecom Platform* (OTP)

* A general purpose framework that abstracts away many typical Erlang tasks
    * Concurrency and distribution patterns
    * Error detection and recovery in concurrent systems
    * Packaging code into libraries
    * Systems deployment
    * Live code updates

* Can be done without OTP but OTP is the battle tested in many production systems and an integral part of Erlang
* Official distribution is called Erlang/OTP

Ericsson is still in charge of the development process and releases a new version on regular basis - once a year
* http://erlang.org
* http://github.com/erlang/otp

## 1.2 About Elixir

* Elixir is alternative language for the Erlang virtual machine
* Unlike Erlang, Elixir is more of a collaborative effort
* https://github.com/elixir-lang/elixir
* Elixir uses the Erlang runtime
* Elixir is semantically close to Erlang - many of its language constructs map directly to the Erlang counter parts
    * provide additional constructs to reduce boilerplate and duplication
* Everything you can do in Erlang is possible in Elixir and vice versa

## 1.2.1 Code simplification

* Elixir can radically reduce boilerplate and eliminate noise from code
* Frequently used building block in Erlang concurrent systems is the *server process*.
 
* A *macro* is Elixir code that runs at *compile time*
    * inspired by LISP
    * should not be confused with C-style macro
        * C/C++ macros work with pure text
        * Elixir macros work on Abstract Syntax Tree (AST)


```
defcall sum(a, b) do
  reply(a + b)
end
```

* no such keyword as `defcall`; it is a custom macro which translates to 

    ```
    def sum(server, a, b) do
      GenServer.call(server, {:sum, a, b})
    end

    def handle_call({:sum, a, b}, _from, state) do
      {:reply, a + b, state}
    end
    ```

* Most of elixir is written in Elixir
* Language constructs like `if` and `unless` and suuuport for structures are implemented via Elixir macros
* Only the smallest possible core is done in Erlang
    * everything else is then built on top of it in Elixir

> Elixir macros are somthing of a black art but make it possible for
> flush out nontrivial boilerplate at compile time and extend the
> language with your own DSL like constructs

## 1.2.2 Composing functions

* Elixir and Erlang are functional languages
* Rely on immutable data and functions that transform data
* The code is divided into many small reusable composable functions

Unfortunately the composability feature in Erlang is clumsy,

For example, to

1. apply the XML to the in-memory model
2. Process the resulting changes
3. Persist the model

    ```
    process_xml(Model, Xml) ->      Model1 = update(Model, Xml),      Model2 = process_changes(Model1),      persist(Model2).
    ``` 
    
    * `Model1` and `Model2` are introduced here to feed it to the next function
    * You could eliminate the temporary variables

        ```
        process_xml(Model, Xml) ->          persist(            process_changes(              update(Model, Xml)            )
        ).
        ```
        
        * the style is known as *staircasing*
            * hard to read and clumsy, you have to manually parse it inside out
    * In Elixir, 

        ```
        def process_xml(model, xml) do          model            |> update(xml)            |> process_changes            |> persist        end
        ```
        * the *pipeline* operator `|>` takes the result of the previous expression and feeds it to the next one as *first* argument

## 1.2.3 The big picture

* There are many other areas where Elixir improves the original Erlang approach
    * API for standard libraries is cleaned up, follows some defined conventions
    * syntactic sugar that simplifies typical idioms
    * Rewritten some Erlang data structures such as the key-value dictionary and set to gain more performance
    * String manipulation is improved
    * Explicit support for Unicode manipulation
* For tooling Elixir provides
    * `mix` to simplify common tasks;
        * creating applications and libraries
        * managing dependencies
        * compiling and 
        * testing code
    * `hex` package manager makes it simplier to package, distribute and reuse dependencies

## 1.3 Disadvantages

### 1.3.1 Speed

* Erlang is *not* the fastest platform
    * won't see Erlang in various benchmarks
* Erlang run in BEAM
    * can't achieve the speed of machine compiled languages
* The goal of the platform isn't to squeeze out as many requests per seconds as possible, but to keep performance predictable and within limits
    * no unexpected hipcup due to garbage collection
    * long-running BEAM processes don't bock or significantly impact the rest of the system
    * As the load increases, BEAM can use as many hardware resources as possible
        * if the hardware capacity isn't enough, expect graceful system degradation

### 1.3.2 Ecosystem

* Erlang isn't small, but isn't as big as that of other languages

## 1.4 Summary

* Erlang is a technology for developing highly available systems with little or no downtime
* Elixir is a mondern language that makes development for the Erlang platform much more pleasant

