defmodule Query do
  def run(query_def) do
    :timer.sleep(500)
    "#{query_def}-result"
  end
end

query_results = 1..5 |> Enum.map(&Query.run("query-#{&1}"))

IO.inspect query_results