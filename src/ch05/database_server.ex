defmodule DatabaseServer do

  def start do
    spawn(&loop/0)
  end

  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self, query_def})
  end

  def get_result do
    receive do
      {:query_result, result} -> result
    after 5000 ->
      {:error, :timeout}
    end
  end

  defp loop do
    receive do
      {:run_query, caller, query_def} ->
        send(caller, {:query_result, run_query(query_def)})
    end
    loop
  end

  defp run_query(query_def) do
    :timer.sleep(2000)
    "#{query_def} result"
  end
end

# > server_pid = DatabaseServer.start
# > DatabaseServer.run_async(server_pid, "query 1")
# > DatabaseServer.get_result
#

# # Create a pool of DatabaseServer processes
#
# pool = 1..100 |> Enum.map(fn (_) -> DatabaseServer.start end)
#
# # Run query on randomly selected process from the poool
# 1..5 |> Enum.each(fn
#   (query_def) ->
#     # Selects a random process
#     server_pid = Enum.at(pool, :random.uniform(100) - 1)
#     DatabaseServer.run_async(server_pid, query_def)
# end)
#
# # Get the result
# 1..5 |> Enum.map(fn (_) -> DatabaseServer.get_result end)