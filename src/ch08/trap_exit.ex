defmodule Example do
  def run do
    spawn(fn ->

      # Traps exits in the current process
      Process.flag(:trap_exit, true)

      # Spawn a linked process
      spawn_link(fn -> raise("Something went wrong") end)

      # Receives and prints the messages
      receive do
        msg -> IO.inspect(msg)
      end

    end)
  end
end

Example.run
