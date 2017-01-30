# Chapter 02 - Building Blocks

## 2.1 The interactive shell

* Everything in Elixir is an expression and has a return value
    * including constructs like `if` and `case`
* The shell does not evaluate until an expression is completed

    ```
    > 2 * (
        3 + 1
        ) / 4
    2.0
    ```
* You can put multiple expressions on a single line by separating with `;`

    ```
    > 1 + 2; 1 + 3
    4
    ```
    
    * `4` the result of the last expression

* To leave the shell `Ctrl + C` or type in `System.halt`
* `h` to research what else can be done

    ```
    > h IEx
    ``` 

## 2.2 Working with variables

* Elixir is a **dynamic** programming language
    * does not require to explicitly declare a variable or its type
* assignment is called **binding**

    ```
    > monthly_salary = 1000
    ``` 
* A variable name always **starts** with a lower case alphabetic or an underscore

    ```
    > valid_variable_name
    > also_valid_1
    > validButNotRecommended
    
    > NotValid
    ```    
    * Variable names can end with `?` and `!`

* Data in Elixir is immutable - its content can't be changed
* Variables can be rebound
    * rebinding variable does not mutate the existing memory location
* Elixir is a garbaged-collectable language
    * when a variable is out of scope, the corresponding memory is eligible for garbage collection

## 2.3 Organizing your code

* Typical Elixir program consists of many small functions
* Multiple functions can be further organized into modules

## 2.3.1 Modules

* A **module** is a collection of functions something like a namespace
* Elixir comes with a standard library that provides many useful modules
    * `IO` module to do various I/O operations
        
        ```
        > IO.puts("Hello World")
        Hello World
        ```
* `ModuleName.function_name(args)` is the syntax
* To define your own module use `defmodule` construct
* Inside the module, use `def`

    ```
    defmodule Geometry do
      def rectangle_area(a, b) do
        a * b
      end
    end
    ```   
    * Enter directly in the shell or
    * save in the file and run `> iex geometry.ex` to run the the file
* By convention, the file name has the `.ex` extension
* A single file may contains **multiple** module definitions

* Module name must follow certain rules
    * Starts with an **upper** case - usually written as *CamelCase* style
    * Consist of alphanumerics, underscores and the dot (`.`)
    * The dot is often used to organize modules hierarchically

    ```
    defmodule Geometry.Rectangle do
    end
    ```
    
    * The dot character is convenience
        * once the code is compiled there are no special hierarchical
        * Just syntactical sugar to help scope your names
* Module can be nested

    ```
    defmodule Geometry do
      defmodule Rectangle do
      ...
      end
    end
    ```
    
    * Nesting is a convenience
        * no special relation between the module `Geometry` and `Geometry.Rectangle`

## 2.3.2 Functions

* A function must always be a part of a module
* Function name **also** follows the same convention as variables
    * start with **lowercase** letter or underscore followed by alphanumeric
    * can end with `?` and `!`
        * `?` is often used to indicate boolean
        * `!`  indicates a function may raise a runtime error
        * both are by convention rather than rules. best to follow them
* Definition starts with
    * the `def` construct
    * followed by a function name
    * the argument list
        * no type specifications for arguments
    * and the body in a `do ... end` block

* `|>` **pipeline** operator
    * places the result of the previous call as the **first** argument of the next call

    ```
    prev(arg1, arg2) |> next(arg3, arg4)
    ```
    * is translated to

    ```
    next(prev(arg1, arg2), arg3, arg4)
    ```

## 2.3.3 Function arity

* **Arity** is a fancy name for the number of arguments a function receives

```
defmodule Rectangle do  def area(a, b) do    ...
  endend
```

* `Rectangle.area` receives two arguments and said to be a function of arity `2`
* Often called `Rectangle.area/2`

```
defmodule Calculator do
    def sum(a) do
      sum(a, 0)
    end
    
    def sum(a, b) do
      a + b
    end
end
```
* a lower arity function is implemented in terms of a higher arity one
* This pattern is so frequent that Elixir allows to specify defaults arguments by using the `\\` operator

    ```
    defmodule Calculator do
      def sum(a, b \\ 0) do
        a + b
      end
    end
    ```
    * is generated as previous example

```
defmodule MyModule do
  def fun(a, b \\ 1, c, d \\ 2) do
    a + b + c + d
  end
end
```
* Setting default for multiple arguments
* Will generate
    * `MyModule.fun/2`
    * `MyModule.fun/3`
    * `MyModule.fun/4`

* Not possible to have a function accept a variable number of arguments
    * No such thing as JavScript's `arguments`

## 2.3.4 Function Visibility

* `def` macro make the function public; In Elixir terminology, the function said to be **exported**
* `defp` to make the function **private**

## 2.3.5 Imports and aliases

* If a module often calls functions from another module, you can **`import`** that other module.

```
defmodule MyModule do
  import IO
  
  def my_function do
    puts "Callign imported function
  end
end
```

* You can import multiple modules
* The standard library `Kernel` module is automatically imported into every module

Alternative to `import` is `alias`.

* `alias` makes it possible to reference a module under a different name

```
defmodule MyModule do
  alias IO, as: MyIO
  
  def my_function do
    MyIO.puts("Calling imported function.")
  end
end
```

* Aliases can be used when module has a long name
    * cumbersome to reference modules via fully qualified names

    ```
    defmodule MyModule do
      alias Geometry.Rectangle, as: Rectangle
      
      def my_function do
        Rectangle.area(...)
      end
    end
    ```
    
## 2.3.6 Module attributes

* the purpose of module attributes is two folds
    * used as compile-time constants
    * can **register** any attribute which can be then queried in run time

```
defmodule Circle do
  @pi 3.14159
  
  def area(r), do: r * r * @pi
  def circumference(r), do: 2 * r * @pi
end
```

* **Important** about `@pi` is it exists **only** during the compilations of the module

* An attribute can be **registered**
    * means it will be stored in the generated binary can be accessed in runtime
* Elixir registers some module attributes by default
    * for example `@moduledoc` and `@doc` can be used to provide documentation for modules and functions

```
defmodule Circle do  @moduledoc "Implements basic circle functions"  
  @pi 3.14159  
  @doc "Computes the area of a circle"  def area(r), do: r * r * @pi  
  @doc "Computes the circumference of a circle"  def circumference(r), do: 2 * r * @piend

> Code.get_docs(Circle, :moduledoc)
{1, "Implements basic circle functions"}
```
* `get_docs` to access
* other tools from Elixir ecosystem knows how to work with these attributes
    ```
    > h Circle
    ....
    
    > h Circle.area
    ```
* [`ex_doc`](https://github.com/elixir-lang/ ex_doc) tool to generate HTML documentation

* The underlaying point is registered attributes can be used to attach meta information to a module

### Type Specifications

* Often called **typespecs** another important feature based on attributes
    * allows to provide type information for the functions
    * can be analysed by [`dialyzer`](www.erlang.org /doc/man/dialyzer.html) a static analysis tool

```
defmodule Circle do  @pi 3.14159  
  @spec area(number) :: number  def area(r), do: r*r*@pi  
  @spec circumference(number) :: number  def circumference(r), do: 2*r*@piend
```

* `@spec` to indicate both functions accept and return a number
* provide a way to compensating for the lack of a static type system
* Useful in conjunction with the `dialyzer` to perform static analysis

> Elixir is a dynamic language so function inputs/outputs
> can't be deduced by looking at the function's signature
> 
> Typespecs can help significantly with this.

* Should seriously consider using typespecs 
* [A detailed reference in the official docs](http://elixir- lang.org/docs/stable/elixir/Kernel.Typespec.html)

## 2.3.7 Comments

```
# This is a comment

a = 3.14 # so is this
```

## 2.4 Understanding the type system

* At its core, Elixir uses the Erlang type system
    * Integration with Erlang libraries is usually imple
* If you are from the **OO** background, it is significanly different

## 2.4.1 Numbers

* `3` Integer
* `0xFF` Integer written in Hex
* `3.14` Float
* `1.0e-2` Float, exponential notation
* Standard operators are supported

    ```
    > 1 + 2 * 3
    7
    ```
* Division operator `/` returns float value
* `div(5, 2) # 2` to calculate integer division
* `rem(5, 2) # 1` to calculate remainer
* Can use `_` underscore as visual delimiter, `1_000_000`

## 2.4.2 Atoms

* Atoms are literal named constants
* Similar to symbols in Ruby or enumerations in C/C++
* Examples

    ```
    :an_atom
    :another_atom
    :"an atom with spaces"
    ```
* Atom concists of two parts; **text** and the **value**
    * Text is whatever after the colon character
        * this text is kept in the **atom table**
    * Value is the data that goes into the variable; merely a reference to the atom table
* Best used for named constants - efficient both memory and performance wise


```
variable = :some_atom
```
* Variable doesn't containt the entire text - only a reference to the atom table

### Aliases

* Another syntax for atom constants
    * `AnAtom` - you can omit **colon** and start with upper case
* `AnAtom == :"Elixir.AnAtom` - when you use an alias the compiler implicitly adds the `Elixir` prefix
* Recall

    ```
    > alias IO, as: MyIO
    > MyIO.puts("Hello")
    Hello
    ```
    * `alias IO, as: MyIO`
        * Instruct the compiler to transfor `MyIO` into `IO`
        * then `IO` is further resolved to `Elixir.IO`
        * `MyIO == Elixir.IO`

### Atoms as Booleans

* Elixir does **not** have a decidated boolean type
* Instead the atoms `:true` and `:false` are used

```
> :true == true
true

> :false == false
true

> true and false
false

> true and false
false

> false or true
true

> not false
true

> not :an_atom_other_than_true_or_false
** (ArgumentError) argument error
```

### Nil and Truthy Values

* `:nil` is an another special atom - similiar to `null` in other languages
* `nil` and `false` are treated as **falsy** values
    * everything else is treated as **truthy** values

    ```
    > nil || false || 5 || true
    5
    ```
    * `nil` and `false` are falsy values then `5` is returned
* Boolean short-circuiting can be used for operation chaining
    * `read_cached || read_from_disk || read_from_database`

## 2.4.3 Tuples

* untyped structures or records
* Often used to group a **fixed number** of elements together

```
> person = { "Bob", 25 }

> age = elem(person, 1)
25

> older_person = put_elem(person, 1, 26)
{ "Bob", 26 }

```

## 2.4.4 Lists

* To manage dynamic **variable sized** collections of data
* Syntax resembles arrays from other languages

```
> prime_numbers = [ 1, 2, 3, 5, 7 ]
```
* Worked like **singly linked list**
* To do somthing with the list, you have to traverse it
    * Have `O(n)` complexity - including `Kernel/length/1`
* `++` operator to concatenates two lists

    ```
    > [1, 2, 3] ++ [4, 5]
    [1, 2, 3, 4, 5]
    ```
* In general, avoid adding elements to the **end** of a list
* List are most efficient when new elements are pushed to the top or popped

### Recursive List Definition

* List can e represented by a pair (**head**, **tail**)
    * **head** is the first element
    * **tail** points to the (**head**, **tail**) of the remaining

```
> a_list = [ head | tail ]

> [1 | [] ]
[1]

> [1 | [2 | [3 | [4 | []]]]]
[1, 2, 3, 4]

> hd( [1, 2, 3, 4] )
1

> tl( [1, 2, 3, 4] )
[2, 3, 4]
```    
* use `hd` to get the head of a list
* use `tl` to get the tail of a list

## 2.4.5 Immutability

* Elixir data can't be mutated
* Modification of the input will result in some data copying
    * but generally most of the memory will be shared

### Modifying Tuples

### Modifying Lists

* When you modify the **nth** element of a list,
    * the new version will contain shallow copies of the first **n - 1** 
    * followed by the modified element
    * the tails are completely shared
* that's why modifying at the end of the list is expensive
* Pushing to the top is the least expensive as a list doesn't copy anything

### Benefits

* can treat most functions as side-effect-free transformations
* more complicated programs are written by combining simpler transformations

> Elixir isn't a pure functional language - writing to a file
> issue a database or network call produce a side effect.

## 2.4.6 Maps

* A **map** is a key-value store
* Keys and Values can be any term
* Introduced in Erlang/OTP 17.0 (Apr 2014)
* Doesn't perform well for large number of elements
    * Use `HashDict`

```
> bob = { :name => "Bob", :age => 25, :works_at => "Initech" }
```

If keys are atoms, can be written as 

```
> bob = { name: "Bob", age: 25, works_at: "Initech" }
```

To retrieve use `[]` operator

```
> bob = { name: "Bob", age: 25, works_at: "Initech" }

> bob[:name]
"Bob"

> bob[:non_existent_field]
nil
```

Atom keys get special syntax treatment

```
> bob = { name: "Bob", age: 25, works_at: "Initech" }

> bob.name
"Bob"

> bob.non_existent_field
** (Key Error)...
```

To change a field value

```
> bob = { name: "Bob", age: 25, works_at: "Initech" }

> %{bob | age: 26, works_at: "Initrode"}
```

To insert a new key-value pair into the map


```
> Map.put(bob, :salary, 50000)

```
    
* `Map` module for map manipulations
* `Dict` is a more general purpose to manipulate any abstract key-value such as `HashDict`

## 2.4.7 Binaries and bitstrings

* A **binary** is a chunk of bytes
* Use `<<` and `>>` operators

* `<<1, 2, 3>>` - three bytes
* If the byte values greater than **255**, it's truncated to the byte size

    ```
    > <<256>>
    <<0>>
    
    > <<257>>
    <<1>>
    
    > <<512>>
    <<0>>
    ```
* Specify the size of each value
    
    ```
    > <<257::16>>
    <<1, 1>>
    ```
    * Turn `257` into `16` bits of consecutive memory space
    * Out put indicates two byptes
    * the binary representation of `257` is `00000001 00000001` hence `<<1, 1>>`

* Size need **not** to be a multiplier of `8`
* If If the total size of all the values isn't a multiplier of `8`, it is called **bit string**

    ```
    > <<1::1, 0::1, 1::1>>
    <<5::size(3)>>
    ```
* Can concatenate two binaries or bitstrings with `<>` operator

    ```
    > <<1, 2>> <> <<3, 4>>
    <<1, 2, 3, 4>>
    ```

## 2.4.8 Strings

* Elixir **does not** have a dedicated string type
* Strings are represented either **binary** or a **list**

### Binary Strings

* Double quote syntax 
    * `"This is a string"` is printed as a string
    * but it is nothing more than a consecutive sequence of bytes

* `#{....}` syntax for string interpolation

    ```
    > "Embedded expression: #{3 + 0.14}"
    "Embedded expression: 3.14"
    ``` 
* Strings don't have to finished on the same line

    ```
    > "
      This is
      a multiline string
      "
    ```
* Elixir provides sigils ie `~s(Foo String)`

* Special **heredocs** syntax with triple quotes `"""`
    
    ```
    > """
      Heredoc must end on its own line
      """
    ```

### Character Lists

* Using **sinqle quote** syntax

* `'ABC'` creates a **character list**
    * is the same as `[65, 66, 67]`
* Runtime doesn't distinguish betwen a list of integer and a character list

* Support String interpolation `'Interpolation: #{3 + 0.14}'`

* Character list **aren't** compatible with binary strings
    * Most of the operations from `String` module **won't** work
* In general, **binary** string is prefer over character lists
* `String.to_char_list` to convert binary string to character list
* `List.to_string` to convert character list to a binary string

## 2.4.9 First-class functions

* `fn` construct to create a function

```
> square = fn (x) -> 
             x * x
           end
```
* it is called **anonymous function** or **lambda**
* To call the function use `.`, ie. `square.(5)`

> `.` operator is make the code more explicit that the function
> is anonymous function, `square(5)` (not `.`) means a **named**
> function and defined somewhere in the module

* Elixir makes it possible to directly reference a more compact lambda
    * Instead of `fn (x) -> IO.puts(x)`, you can write `&IO.puts/1`

* `&` is the **capture** operator;
    * takes the **full* function qualifier and turns it into a lambda

        ```
        Enum.each([1, 2, 3], &IO.puts/1)
        ```    

    * can also used to shorten the lambda definition

        ```
        > lambda = fn (x, y, z) -> x * y + z end
        
        # More compact form
        > lambda = &(&1 * &2 + &3)
        ```
### Closures

* Lambda can reference any variable from the outside scope

    ```
    > outside_var = 5
    > my_lambda = fn -> IO.puts(outside_var) end
    
    > my_lambda.()
    5
    ```
    * `outside_var` is acccessible as long as you hold the reference to `my_lambda`
        * it is also known as **closure**
* Closure always captures a specific memory location;
    * rebinding doesn't affet the previously defined lambda 

    ```
    > outside_var = 5
    > my_lambda = fn -> IO.puts(outside_var) end
    
    # Rebinding
    > outside_var = 10000
    
    # Doesn't affect the previously held variable
    > my_lambda.()  
    5
    ```
## 2.4.10 Other built-in types

* **Reference** is almost unique piece of information in a BEAM instance
    * can be generated using `Kernel.make_ref/0` (or `make_ref`)
    * Reference will reoccure after **2 ^ 82** calls
    * Reference generation starts from the beginning after restarting BEAM
* **PID** is to identify an Erlang process
    * Important for cooperating between concurrent tasks
* **Port Identifier** is for using **ports**
    * port is a mechanism in Erlang to talke to the outside world
        * File I/O
        * Commmunication with external program

## 2.4.11 Higher level types

### Range

* An abstraction to represent a range of numbers

```
> range = 1..2

> 2 in range
true

> -1 in range
false
```
* Ranges are enumerable; work with `Enum` module
* Important to realise a range **isn't** special type
    * internally represented as a map which contains range boundaries
    * the memory foot print of a range is very small
        * a million number range is still small map
    * Shouldn't rely on this knowledge

### Keyword Lists

* A special case of a list
    * each element is a **two-element** tuple
    * first element of each tuple is an atom

```
> days = [{:monday, 1}, {:tuesday, 2}, {:wednesday, 3}]

# More elegant syntax
> days = [monday: 1, tuesday: 2, wednesday: 3]

> Keyword.get(days, :monday)
1 

> days[:tuesday]
2
```

* Often used for small-size key-value structures where keys are atoms
    * useful to allow clients to pass an arbitrary number of optional arguments

    ```
    > Float.to_string(1/3, [decimals: 2])
    
    #
    # Elixir allows to omit the square bracket
    # it is still passing TWO arguments
    #
    > Float.to_string(1/3, decimals: 2, compact: true)    
    ```
    
    * can be used to simulate optional arguments
    
        ```
        def my_fun(arg1, arg2, opts \\ []) do            ...        end
        ``` 
* Since it is a **list** the complexity of a lookup is still `O(n)`

* Main reason to use **Keyword List** over **Map** is for backward compatibility with existing Erlang and Elixir code
    * Maps are recent addition to the Elixir/Erlang World
    * Before Maps, Keywords are a standard approach to make functions accept varisou optional named arguments

* Keyword list can contain multiple values for the same key
* Can control the ordering of keyword list elements (not possible with Maps)

## HashDict

* `HashDict` module is a module that implements an arbitrarily sized key-value lookup structure
* More performant over `Map` for larger collections

```
> days = [monday: 1, tuesday: 2, wednesday: 3] |> Enum.into(HashDict.new)
```
* `Enum.into/2` is a generic function that can transfer anything enumeralbe into anything that is **collectable**

> **Collectables** are complement to **Enumerable**.
> 
> **Enumerable** is an abstract collection you can iterate,
> **Collectable** is an abstract collection you can put elements
> into
> 
> Most provided collections ie. **Lists**, **Maps** and **HashDict**
> are both enumerable and collectable.
> 
> You can make you own data abstraction enumerable and/or collectable

```
#
# To retrieve something from Dictionary
#
> HashDict.get(days, :monday)
1

#
# Returns nil for non existent key
#
> HashDict.get(days, :noday)
nil

#
# Uisng [] operator
#
> days[:monday]

#
# To put an element
#
> days = HashDict.put(days, :thursday, 4)
> days[: thursday]
4
```

* `HashDict` instance is also an enumerable - can use all function from `Enum` module

```
iex(8)> Enum.each(          days,          fn(key_value) ->            key = elem(key_value, 0)            value = elem(key_value, 1)            IO.puts "#{key} => #{value}"          end
        )

monday => 1thursday => 4tuesday => 2wednesday => 3
```
* Note, the ordering **isn't** guranteed.
* `HashDict` performs better thatn the map data type for large collections
* Use `HashDict` for a dynamically sized key-value structure
* `Map` has more elegant syntax and can be pattern matched

> Use `HashDict` for dynamic key-value stores
> Use `Map` for small fixed-sized structures

### HashSet

* A `HashSet` is the implementation of a set
    * similiar to `HashDict`
        * no pairs of data
    * store **unique** values - value can be any type

```
> days = [:monday, :tuesday, :wednesday] |> Enum.into(HashSet.new)
#HashSet<[:monday, :tuesday, :wednesday]>> HashSet.member?(days, :monday)true

> HashSet.member?(days, :noday)
false

> days = HashSet.put(days, :thursday)
#HashSet<[:monday, :tuesday, :wednesday, :thursday]>> Enum.each(days, &IO.puts/1)
mondaytuesdaywednesdaythursday
```
* `HashSet` is an enumerable

## 2.4.12 IO Lists

* Special list that is useful for incrementally building an output that will be forwarded to I/O devices
* Each element of an IO list must be one of the following
    * An integer in the range of `0` to `255`
    * A binary
    * An IO list
* In other words, IO list is a deep nested structure in which **leaf** elements are plain bytes

```
> iolist = [[['H', 'e'], "llo,"], " worl", "d!"]
> IO.puts iolist
"Hello, world!"
```
* Notice, you can combine character lists and binary string into a **deep** nested list
* Under the hood, the structure is flattened and see the human-readly output
    * the same effect if you send an IO list to a file or a network socket
* IO List are useful when you need to incrementally build a stream of bytes
    * Lists **are not** usually good at appending as it is `O(n)`
    * But appending to IO is `O(1)` because you can use nesting.

    ```
    > iolist = []    > iolist = [iolist, "This"]    > iolist = [iolist, " is"]    > iolist = [iolist, " an"]    > iolist = [iolist, " IO list."]

    [[[[[], "This"], " is"], " an"], " IO list."]
    
    > IO.puts iolist
    This is an IO list.
    ```

## 2.5 Operators

* Most of the operators are defined in the `Kernel` module
* `+`, `-`, `*`, `/` work mostly as expected
    * `/` always returns `float`
* Weak Equality `==` vs. Strict Equality `===`

    ```
    > 1 == 1.0
    true
    
    > 1 === 1.0
    false
    ```
    * Only relevant when comparing **Integer** to **Floats**

* Logical operators work on **boolean** atoms
    * `and`, `or` and `not`
* **Short-circuit** operators work with concept of **truthness**
    * `false` and `nil` are **falsy**
    * Everything else is **truthy**
    * `&&` operator returns the second expression only if the first one isn't falsy
    * `||` operator returns the first expression if it's truthy, other wise it returns the second expression
    * `!` returns false if the value is truthy, otherwise it returns `true`
* `\>` pipe operator

> ### Many operators are functions
> For example, Instead `a + b`, `Kernel.+(a, b)`
> Useful to turn into anonymouse functions,
> for exampe, `&Kernel.+/2` or just `&+/2`
> Such lambda can be used with various enumeration
> and stream functions

## 2.6 Macros

* One of the **most** important Elixir feature compared to plain Erlang
* Make it possible to perform code transformations in compile time
    * reducing boilerplate and providing elegant mini DSL constructs
* A Macro consists of Elixir code that change the semantics of the input code
* Always called at compile time
    * receives the parsed representation of the input Elixir code
    * it has opportunity to return an alternative version of that code
* `unless` is a simple macro provided by Elixir

## 2.7 Understanding the runtime

* the Elixir runtime is a BEAM instance
* Once the compiling is done, the system is started, Erlang takes control

## 2.7.1 Modules and functions in the run time

Once the system is started, when calling some functions from modules, the VM
keeps track of all modules loaded in memory. 

When a function is called, BEAM first checks whethere the module is loaded.
If so, the function code is executed, otherwise the VM tries to find the
compiled file - the **bytecode** on the disk, load then execute

### Modules Names and Atoms

```
defmodule Geometry do
  ...
end

```

* Recall `Geometry == :"Elixir.Geometry"`
* The `Geometry` module compiled to `Elixir.Geometry.beam` regardless of the name of the input file.
    * If there are multiple modules in the **same** source file, the compiler will generates multiple beam files
* VM looks the beam file in the current folder then in the **code paths**
* When you start BEAM with Elixir tools ie `iex`, some code paths are predefined
* Add additional code path using `-pa` switch

    ```
    $ iex -pa my/code/path -pa another/code/path
    
    # to check the code paths
    > :code.get_path
    [ 
      ..
     '/usr/local/Cellar/erlang/18.3/lib/erlang/lib/stdlib-2.8/ebin',
     '/usr/local/Cellar/erlang/18.3/lib/erlang/lib/xmerl-1.3.10/ebin',
     '/usr/local/Cellar/erlang/18.3/lib/erlang/lib/wx-1.6.1/ebin',
     ..
    ]
    ```
* If the module is loaded, the run time doesn't search for it on the disk

    ```
    $ iex my_source.ex
    ```

    * compiles the source file then immediately loads all generated modules
    * Beam files **aren't** saved to disk
    * `iex` perform an in-memory generation and loads the modules

### Pure Erlang Modules

* In Erlang, modules are correspond to atoms
* `code.beam` file contains the `:code` module
* Elixir modules are nothing more than Erlang modules with fancier names
    * ie. `Elixir.MyModule`
    * Not recommended but you can create 

        ```
        defmodule :my_module do
          ...
        end
        ```
* Important thing to remember
    * module names are atoms
    * there is `xyz.beam` file for `xyz` module

#### Dynamically Calling Functions

* `Kernel.apply/3` to dynamically call function at run time

```
> apply(IO, :puts, ["Dynamic function call."])
Dynamic function call.
```

* `Kernel.apply` receives three arguments
    * module name
    * function atom
    * a list of argument to the function
    * aka MFA (for Module, Function, Arguments
* Usefule when you need to make a runtime decision about which function to call

## 2.7.2 Starting the runtime

* Multiple ways to start BEAM

### Interactive Shell

* When the shell is started, the BEAM instance is started underneath
* the Elixir shell takes the control
    * takes the input
    * interprets it
    * print the result
* Note: input is **interpreted** - won't be as performant as the compiled code
* But modules are compiled even if it is defined in the SHELL

### Running Scripts

* `$ elixir my_source.ex`
    * BEAM instance started
    * `my_source.ex` is compiled in-memory and loaded to the VM
        * no beam file generated
    * What code resides outside of a module is interpreted
    * Once everything is finished, BEAM is stopped
* `exs` file extension for Elixir Script

* Use `--no-halt` option to keep the BEAM instance running
    * `$ elixir --no-halt script.exs`
    * Often useful if the main code starts concurrent tasks,
        * In this case, once the main call finishes, BEAM is immediately terminated
        * `--no-halt` option to keep the entire system running

### The Mix Tool

* To manage projects that made up of multiple source files
* `$ mix new my_project` to create a new Elixir project
* `$ mix run` to start the mix project and terminates as soon as the project `MyProject.start` finishes
    * `$ mix run --no-halt` doesn't terminate
    * `$ iex -S mix run` starts the system then loads the interactive shell

## 2.8 Summary

* Elixir code is divided into modules and functions
* Elixir is a dynamic language
* Data is immutable
* Most important data type are numbers, atoms and binaries
* No boolean type; instead atoms `true` and `false` are used
* No nuuability; attome `nil` is used for null
* No string type; instead binaries or list
* **Only** complex types are tuples, lists and maps
* `Range`, Keyword List, `HashDict` and `HashSet` are abstractions built on top of existing data system
* Functions are first class citizens
* Modules names are atoms - correspnd to **beam** files on the disk
* Multiple ways of starting programs; `iex`, `elixir` and the `mix` tool
