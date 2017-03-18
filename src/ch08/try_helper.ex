defmodule TryHelper do
  def try_helper(fun) do
    try do
      fun.()
      IO.puts "No Error"
    catch type, value ->
      IO.puts "Error\n #{inspect type}\n #{inspect value}\n"
    end
  end
end

TryHelper.try_helper(fn -> raise("Something went wrong - using raise") end)
TryHelper.try_helper(fn -> :erlang.error("Something went wrong - using :erlang.error") end)
TryHelper.try_helper(fn -> throw("Something went wrong - using throw") end)
TryHelper.try_helper(fn -> exit("Something went wrong - using exit") end)
