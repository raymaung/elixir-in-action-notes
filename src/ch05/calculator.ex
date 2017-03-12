defmodule Calculator do

  def start do
    spawn(fn ->
      loop(0)
    end)
  end

  def value(server_id) do
    send server_id, {:value, self}
    receive do
      {:response, value} -> value
    end
  end

  def add(server_id, value), do: send(server_id, {:add, value})
  def sub(server_id, value), do: send(server_id, {:sub, value})
  def mul(server_id, value), do: send(server_id, {:mul, value})
  def div(server_id, value), do: send(server_id, {:div, value})

  defp loop(current_value) do
    new_value = receive do
      {:value, caller} ->
        send(caller, {:response, current_value})
        current_value

      {:add, value} -> current_value + value
      {:sub, value} -> current_value - value
      {:mul, value} -> current_value * value
      {:div, value} -> current_value / value

      invalid_request ->
        IO.puts "invalid request #{inspect invalid_request}"
        current_value
    end
    loop(new_value)
  end
end

# > calculator_pid = Calculator.start
# > Calculator.value(calculator_pid)
# > Calculator.add(calculator_pid, 10)
# Calculator.sub(calculator_pid, 5)