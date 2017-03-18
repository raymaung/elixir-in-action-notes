defmodule Example do
  def run do
    spawn(fn ->
      spawn_link(fn ->
        :timer.sleep(1000)
        IO.puts "Process 2 finished"
      end)
      raise("Something went wrong")
    end)
  end
end

Example.run