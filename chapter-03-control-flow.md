# Chapter 03 - Control Flow

* Classical conditional constructs such as `if` and `case` are replaced with multiclause functions
* No classical loop statements such as `while`

## 3.1 Pattern matching

* `=` isn't an assignment operator; it is a **match** operator

## 3.1.1 The match operator

```
 iex(1)> person = {"Bob", 25}
```

* At run time, the **left** side is matched to the **right** side
* **Left** side is called **pattern**
* **Right** side is an expression
* To read, *You match the variable `person` to the right side `{"Bob", 25}`*

## 3.1.2 Matching Tuples

```
iex(1)> {name, age} = {"Bob", 25}
```

* Right side term `{"Bob", 25}` is evaluated
* the variable `name` and `age` are bound to the elements of the tuple

* Useful when a function returns a tuple and want to bind individual elements

    ```
    > {date, time} = :calendar.local_time    
    > {year, month, day} = date
    
    #
    # What happens if the right side doesn't correspond to the pattern?
    #
    > {name, age} = "can't match"
    ** (Match Error) ...

    ```
* Just like **other expression**, the match expression also returns a value
    * returns the **right side** term

## 3.1.3 Matching constants

* Left-side can also include constants

```
> 1 = 1
1
```
* Constants are more useful in compound matches

For example, it is common to use tuples to group various fields of a record

```
> person = {:person, "Bob", 25 }
```

* First element `:person` is used here to denote to represent a person
* You can rely on this knowledge and retrieve individual attributes

```
> {:person, name, age} = person

> name
"Bob"

> age
25 
```
* It is a common idiom in Elixir;
    * many functions from Elixir and Erlang return either 
        * `{:ok, result}` or `{:error, reason}`

## 3.1.4 Variables in patterns

* Whenever a variable name exists in the left side pattern, it alwasy matches the right-side term
* When we aren't interested in a value from the right side term use `_` anonymous variable

```
> {_, time} = :calendar.local_time

> time
{20, 44, 18}
```
* `_` works like a named variable but isn't bound to any variable


* A variable can be referencd multiple times
    
    ```
    #
    # Matches a tuple with three identical elements
    #
    > {amount, amount, amount} = {127, 127, 127}
    {127, 127, 127}
    
    #
    # Fails because the tuple elements aren't identical
    #
    > {amount, amount, amount} = {127, 127, 1}
    ** (MatchError) no match of right hand side value: {127, 127, 1}
    ```
* To against the contents of the variable use the **pin operator ^**

    ```
    > expected_name = "Bob"
    "Bob"
    
    > {^expected_name, _} = {"Bob", 25}
    {"Bob", 25}
    
    > {^expected_name, _} = {"Alice", 30}
    ** (MatchError) no match of right hand side value: {"Alice", 30}
    ```

    * Pin operator doesn't bind the variable;
      * expect the variable is already bound
    * it is used **less often**
        * mostly relevant when you need to construct the pattern at runtime

## 3.1.5 Matching lists

```
#
# Decomposes a three element list
#
> [first, second, third] = [1, 2, 3]

```

* Matching lists is more often done by relying on their recursive nature

```
> [head | tail ] = [1, 2, 3]
[1, 2, 3]

> head
1

> tail
[2, 3]
```

## 3.1.6 Matching maps

```
> %{name: name, age: age} = %{name: "Bob", age: 25}

> name
"Bob"

> age
25
```

* Doesn't need to contain all the keys from the right side term
    * `%{age: age} =  %{name: "Bob", age: 25}`

Maps are frequently used for structured data - such case you are often interested in some of the map fields

* Will fails if the pattern contains a key that's not in the matched term

```
> %{age: age, works_at: works_at} = %{name: "Bob", age: 25}
** (MatchError) no match of right hand side value
```

## 3.1.7 Matching bitstrings and binaries

To match binaries use syntax similiar to creating one

```
> binary = <<1, 2, 3>>

> <<b1, b2, b3>> = binary

> b1
1

> b2
2

> b3
4

#
# take first byte
#
> <<b1, rest :: binary>> = binary

> b1
1

> rest
<<2, 3>>

```

```
>  <<a :: 4, b :: 4>> = <<155>>

> a
9

> b
11
```
* `a::4` means expect a four-bit value,
    * `155` is in binary representation of `10011011`
    * `a::4` means first four bits, that's `1001` which is `9`
    * `b::4` means second four bits, that's `1011` which is `11`

### Matching Binary String

Recall strings are binaries.

```
> <<b1, b2, b3>> = "ABC"

> b1
65

> b2
66

> b3
67
```

More useful pattern is to match the beginning of the string

```
> command = "ping www.example.com"

> "ping " <> url = command

> url
"www.example.com"
```

## 3.1.8 Comound Matches

Patterns can be arbitrarily nested.

```
> [_, {name, _}, _] = [{"Bob", 25}, {"Alice", 30}, {"John", 35}]
```

* `pattern = expression`

    ```
    > a = 1 + 3
    
    ```

    * **Expression** on the right side is evaluated
    * Resulting **value** is matched against the left-side pattern
    * Variables from the pattern is bound
    * The result of the match expression is the result of the right-side term

As the consequence of `pattern = expression`, it can be chained.

```
> a = (b = 1 + 3)
```

* `1 + 3` is evaluated
* the result `4` is matched against `b`
* the result of the innter match (which is `4`) is matched against the pattern `a`
* then `a` and `b` have the value `4`

Parentheses are optional

`a = b = 1 + 3`

* This is the same result because the operator `=` is right associative

More useful example: You want to retrieve the function's total result, as well as the current hour of the day

```
> date_time = {_, {hour, _, _}} = :calendar.local_time

> date_time
{{2013, 11, 11}, {21, 32, 34}}

> hour
> 21
```

the order can be swapped

```
> {_, {hour, _, _}} = date_time = :calendar.local_time
```

It works because the result of a pattern match is always the result of the term being matched (right-side)

## 3.1.9 General behavior

* Consists of two parts
    * **pattern** (left side)
    * **term** (right side)
* If the match succeeds, all variables in the pattern are bound
* The result of the entire expression is the entire term you matched
* If the match rails, an error is raised


In a pattern-matching expression, you perform two different tasks

* Assert your expectations about the right-side term;
    * if the expectations aren't met, an error is raised
* Bind some parts of the term to variables from th pattern

The match operator `=` is just one example where pattern matching can be used.

## 3.2 Matching functions

```
def my_fun(arg1, arg2) do
  ...
end
```

* `arg1` and `arg2` are patterns and you can use standard matching techniques

```
defmodule Rectangle do  def area({a, b}) do    a * b
  endend
```
* `Rectangle.area/1` expects its argument to be a two-element tuple
* `> Rectangle.area({2, 3})` to execute
* `> Rectangle.area(2)` will raise an error

## 3.2.1 Multiclause 

* Elixir allos to overload a function by specifying multiple clauses
* A **clause** is a function definition

Example: For `GeoMetry` to suppor different shapes

```
rectangle = {:rectangle, 4, 5}square = {:square, 5}circle = {:circle, 4}

defmodule Geometry do  def area({:rectangle, a, b}) do    a * b
  end  def area({:square, a}) do
    a * a  end  
  def area({:circle, r}) do    r * r * 3.14  end
end

> Geometry.area({:rectangle, 4, 5})
20

> Geometry.area({:square, 5})
25

> Geometry.area({:circle, 4})
50.24

> Geometry.area({:triangle, 1, 2, 3})
** (FunctionClauseError) no function clause matching in Geometry.area/1     geometry.ex:2: Geometry.area({:triangle, 1, 2, 3})
```

When a function is called, the runtime goes through each of its cluses in **the order the're specify.

From the caller's perspective, a multiclause function is a single function

* You can't directly reference a specific clause
* When you capture with `&Geometry.area/1`, you capture all of its cluses

    ```
    > fun = &Geometry.area/1
    
    > fun.({:circle, 4})
    50.24
    
    > fun.({:square, 5})
    25
    ```
* To return a term indicating a failure - instead of raising an error, introduce a **default** clause

    ```
    defmodule Geometry do
      ...
      ...
      
      #
      # IMPORTANT: to place at the last
      #
      def area(unknown) do        {:error, {:unknown_shape, unknown}}      end
    end
    ```
    * `def area(unknown) ..` is only for `area/1`

> Important to place the clauses in the appropriate order.

* should always group clauses of the same function together
    * if spread all over the file, it becomes increasingly hard to analyze the function's behavior
    * the compiler will emit warnings

## 3.2.2 Guards

* Guards are an extension of the basic patten matching mechanism
* Can be specified by providing the `when` clause after the arguments lis

```
defmodule TestNum do
  def test(x) when x < 0 do
    :negative
  end
  
  def test(0), do: :zero
  
  def test(x) when x > 0 do
    :positive
  end
end

> TestNum.test(-1)
:negative    
> TestNum.test(0):zero> TestNum.test(1):positive
```

* Calling this function with a non-number yields strange results

    ```
    > TestNum.test(:not_a_number)
    :positive
    ```
    * Elixir terms can be compared with operators `<` and `>` even if they're not of the same type
    * Type ordering matters
       
        ```
        number < atom < reference < fun < port < pid <          tuple < map < list < bitstring (binary)
        ```
        
        * A numer is smaller than any other type, hence `TestNum.test/1` returns `:positive`

* To fix it extend the guard by testing it is a number or not

    ```
    defmodule TestNum do      def test(x) when is_number(x) and x < 0 do        :negative      end  
      def test(0), do: :zero     
      def test(x) when is_number(x) and x > 0 do        :positive      end
    end
    ```
    * `is_number/1` (`Kernel.is_number/1`) to test whether the argument is a number

    ```
    > TestNum.test(-1)    :negative    > TestNum.test(:not_a_number)      ** (FunctionClauseError) no function clause matching in TestNum.test/1
    ```

The set of operators and functions that can be called from guards is very limited.

* You may not call your own functions
* Most of the other functions won't work
* The following operators are allowed:
    * Comparision operators (`==`, `!=`, `===`, `!==`, `>`, `<`, `<=`, `=>`)
    * Boolean operators `and`, `or` and `not`, `!`
    * `<>` and `++` as long as the left side is a literal
    * `in` operator
    * Type check functions from the `Kernel`; `is_number/1`, `is_atom/1` and so on
    * Additional `Kernel` functions
        * `abs/1`
        * `bit_size/1`
        * `byte_size/1`
        * `div/2`
        * `elem/2`
        * `hd/1`
        * `length/1`
        * `map_size/1`
        * `node/0`
        * `node/1`
        * `rem/2`
        * `round/1`
        * `self/0`
        * `tl/1`
        * `trunc/1`
        * `tuple_size/1`

Some of the functions may cause an error to be raised.

For example, `length/1` makes sense only on lists

```
defmodule ListHelper do
  def smallest(list) when length(list) > 0 do
    Enum.min(list)
  end
  
  def smallest(_), do: {:error, :invalid_argument}
end
```

* Calling `> List.smallest(123)`,
    * you may be expecting to raise Error, because `length` raises error on non-list but it doesn't
    * Any error inside the **guard** won't be propagagted
        * Error is internally handled and return `false` instead
    * With the guard failing, it execute next matching function and returns     `{:error, :invalid_argument}`

## 3.2.3 Multiclause lambdas

* Anonymous functions (lambdas) may consist of multiple clauses

```
> double = fn (x) -> x * 2 end
> 
```
* The general lambda syntax has the following shape

    ```
    fn
      pattern_1 ->
        ...
    
      pattern_2 ->
         ...
        
      ...
    end
    ```
* Example:

    ```
    test_num = fn
    
        x when is_number(x) and x < 0 ->
          :negative
    
        0 -> :zero
        
        x when is_number(x) and x > 0 ->
          :positive
    ```
* Note: There is **no** special neding terminator for a lambda clause
    * the clause ends when the new clause is started

* Multiclause lambdas come in handy when using higher order functions

## 3.3 Conditionals

Elixir provides some standard ways of doing conditional branching with construts such as `if` and `case`. Multiclause functions can be used as well

## 3.3.1 Branching with multiclause functions

```
defmodule TestList do  def empty?([]), do: true  def empty?([_|_]), do: falseend
```

* Relyig on pattern matching, you can implement polymorphic functions tha  do different things depending on the input type

    ```
    defmodule Polymorphic do
      def double(x) when is_number(x), do: 2 * x      def double(x) when is_binary(x), do: x <> x    end
    ```

* A multiclause powered recursion is also used as a primary building block for looping
* The true elegance of multiclauses and pattern matches comes through when your have to combine functions that deal with different results

* The multiclause approach forces you to layer your code into many small functions and push the conditional logic deeper into lower layers

## 3.3.2 Cliassical Branching constructs

Sometime it is simpler to use a classical branching construct in the function over multi clauses.

### `if` and `unless`

```
if condition do
  ...
else
  ...
end
```

* If the condition is anything other than `false` or `nil`, you end up in the main branch.

* Since everything in Elixir is an expression that has a return value, `if` expression returns the result of the executed block

### `cond`

* `cond` macro can be thought as equivalent to an `if-else-if` pattern
* Takes a list of expressions and executes the block of the first expression

```
cond do
  expression_1 -> 
    ...

  expression_2 ->
    ...

  ...
end
```
* the result of `cond` is the result of the executed block,
* If **none** conditions is satisfied, `cond` raises an error

    ```
    def max(a, b) do
      code do
        a >= b -> a
        
        true -> b # Equivalent of a default clause
      end
    end
    ```

### `case`

```
case expression do
  pattern_1 ->
    ...
  
  pattern_2 ->
    ...
end
```

* **pattern** indicates that it deals with pattern matching
* In the `case` construct, `expression` is evaluated then
    * the result is matched against given clause
    * the first one that matches is executed
* If no clause matches, an error is raised

```
def max(a, b) do
  case a >= b do
    true -> a
    false -> b
  end
end
```

the `case` construct is most suitable if you don't want to define a separate multiclause function. Other than that, there is no difference between `case` and
multiclause functions.

## 3.4 Loops and Iterations

* Constructs such as `while` and `do..while` aren't provided
* The principal looping tool is recursion

> Although recursion is the basic building block of looping
> **most* production code uses it sparingly.
> 
> There are many higher level abstractions that hide the
> recursion details. 

## 3.4.1 Iterating with recursion

Example: To print the first **n** natural numbers:

```
defmodule NaturalNums do
  def print(1), do: IO.puts(1)  def print(n) do
    print(n - 1)    IO.puts(n)  end
end
```
* This code relies on recursion, pattern matching and multiclause functions
* Notice it won't work if you provide a negative or a float
    * use **guards** to fix it

## 3.4.2 Tail function calls

If the last thing a function does is call another function (or itself), it is 
a **tail call**.

```
def original_fun(...) do
  ...  another_fun(...) # <--- Tail call
end
```

* Elixir (or more precisely Erlang) performs **tail-call-optimization**
    * instead of of the usual stack push, it is more like a **goto** or a **jump** statement
        * it doesn't allocate additional stack space
* Tail calls are especially useful in recursive functions

    ```
    def loop_forever(...) do        ...      loop_forever(...)    end
    ```
    
    * Equivalent to an endless loop

* You can think of tail recursiion as a direct equivalent of a classical loop in imperative languages

### Recognizing Tail Calls

```
def fun(...) do  ...  if something do    ...    another_fun(...) # <---- Tail Call  endend

def fun(...) do  1 + another_fun(...) # <---- Not a Tail callend
```

## 3.4.3 Higher-order functions

* Higher-order function is a fancy name for a function that takes function as its input and/or returns functions

```
> Enum.each(
    [1, 2, 3],    fn(x) -> IO.puts(x) end
)
```

* `Enum` module is a Swiss army knife for loops and iterations

* `Enum.reduce/3` is the most versatile function

```
Enum.reduce(  enumerable,  initial_acc,  fn(element, acc) ->    ...
  end)
```

```
defmodule NumHelper do  def sum_nums(enumerable) do    Enum.reduce(enumerable, 0, &add_num/2)  end

  defp add_num(num, sum) when is_number(num), do: sum + num  defp add_num(_, sum), do: sumend
```

## 3.4.4 Comprehensions

Comprehensions have various other features that often makes them elegant, com- pared to Enum-based iterations.

```
> for x <- [1, 2, 3], y <- [1, 2, 3], do: {x, y, x*y}[    {1, 1, 1}, {1, 2, 2}, {1, 3, 3},    {2, 1, 2}, {2, 2, 4}, {2, 3, 6},    {3, 1, 3}, {3, 2, 6}, {3, 3, 9}]
```

* compre- hensions can return anything that is collectable

> Collectable is an abstract term for a functional data
> type that can collect values

> a comprehension iterates through enumerables, calling the provided
> block for each value and storing the results into some collectable
> structure.

```
iex(4)> multiplication_table =          for x <- 1..9, y <- 1..9,              into: %{} do         # <----- specifies the collectable            {{x, y}, x*y}        end
```
* `into` option specifies what to collect
    * in the example, `%{}` will be populated with the values returned from the `do` block

    
Another interesting feature is **filters**

```
multiplication_table =
  for x <- 1..9, y <- 1..9,
    x <= y,                  # <---- Comprehension filter    into: %{} do    {{x, y}, x*y}  end
```

* The comprehension filter is evaluated for each element of the input enumerable prior to block execution

## 3.4.5 Streams

* Streams are a special kind of enumerables that can be useful for doing lazy composable operations over anything enumerables

```
> employees = ["Alice", "Bob", "John"]
> employees
     |> Enum.with_index
     |> Enum.each(
          fn
            ({employee, index}) ->              IO.puts "#{index + 1}. #{employee}"          end
    )
```
* With `Enum`, it iterates over twice
  * Once with `Enum.with_index` and `Enum.each` with another

`Stream` is a lazy enumerable - it produces the result on **demand**.


```
> stream = [1, 2, 3] 
    |> Stream.map(fn(x) -> 2 * x end)
```

* create a stream, but the corresponding transformation haven't happened yet.
* To make the iteration happen, send the stream to an `Enum` function
  * ie. `Enum.to_list(stream)`

The laziness of streams goes beyond iterating the list
* You can use for exampe `Enum.take` to request only one element from the stream

    ```
    > Enum.take(stream, 1)
    ```

```
> employees  |> Stream.with_index                  # <--- Perfroms a lazy transformation  |> Enum.each(       fn({employee, index}) ->         IO.puts "#{index + 1}. #{employee}"       end
   )```
* With `stream`, the list iteration is done only once but the same result as `Enum`

