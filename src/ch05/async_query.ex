defmodule Query do
  def run(query_def) do
    :timer.sleep(500)
    "#{query_def}-result"
  end

  def async_run(query_def) do
    spawn(fn
      -> IO.puts(run(query_def))
    end)
  end
end

1..5 |> Enum.each(&Query.async_run("query-#{&1}"))
