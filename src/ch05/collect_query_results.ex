defmodule Query do
  def run_query(query_def, delay) do
    :timer.sleep(delay)
    "#{query_def}-result-delay-#{delay}"
  end

  def async_run(query_def, delay) do
    IO.puts "async_run - #{query_def}\n"
    caller = self
    spawn(
      fn
        -> send(caller, {:query_result, run_query(query_def, delay), self})
      end
    )
  end

  def get_result do
    receive do
      {:query_result, result, _} -> result
    end
  end

  def get_result_by_order(pid) do
    receive do
      {:query_result, result, ^pid} -> result
    end
  end
end


5..1
  |> Enum.map(&Query.async_run("query-#{&1}", &1 * 500))
  |> Enum.map(fn (_) -> Query.get_result() end)
  |> Enum.each(&IO.inspect(&1))

5..1
  |> Enum.map(&Query.async_run("query-#{&1}", &1 * 500))
  |> Enum.map(fn (pid) -> Query.get_result_by_order(pid) end)
  |> Enum.each(&IO.inspect(&1))