defmodule Example do
  def run do
    target_pid = spawn(fn -> :timer.sleep(1000) end)

    # Monitor the spawned process
    Process.monitor(target_pid)

    receive do
      msg -> IO.inspect msg
    end
  end
end

Example.run
