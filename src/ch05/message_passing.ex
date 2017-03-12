defmodule Query do
  def async_run(caller, query_def, delay) do
    spawn(fn
      ->
        :timer.sleep(delay)
        send(caller, %{
          result: "#{query_def}-result",
          completed_at: DateTime.utc_now
        })
    end)
  end
end

Query.async_run self, "3000", 3000
Query.async_run self, "2000", 2000
Query.async_run self, "1000", 1000

IO.puts "Time Now: #{DateTime.utc_now}"


receive do
  %{result: "1000-result", completed_at: completed_at} ->
    IO.puts "1000-result - Now = #{DateTime.utc_now} - completed_at: #{completed_at}"
end

receive do
  %{result: "2000-result", completed_at: completed_at} ->
    IO.puts "2000-result - Now = #{DateTime.utc_now} - completed_at: #{completed_at}"
end

receive do
  %{result: "3000-result", completed_at: completed_at} ->
    IO.puts "3000-result - Now = #{DateTime.utc_now} - completed_at: #{completed_at}"
end