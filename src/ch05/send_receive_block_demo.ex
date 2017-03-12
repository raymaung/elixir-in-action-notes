defmodule ProcessA do
  def start do
    IO.puts "ProcessA started\n"
    spawn(fn -> receive_message() end)
  end

  defp receive_message do
    IO.puts "ProcessA waiting to receive message\n"

    IO.puts "Waiting for message-1\n"
    receive do
      %{message: "message-1", sent_at: sent_at} ->
        IO.puts "message-1 - sent At: #{sent_at} and received at: #{DateTime.utc_now}\n"
    end

    IO.puts "Waiting for message-2\n"
    receive do
      %{message: "message-2", sent_at: sent_at} ->
        IO.puts "message-2 - sent At: #{sent_at} and received at: #{DateTime.utc_now}\n"
    end
  end
end

pid_a = ProcessA.start

:timer.sleep(2000)
send pid_a, %{message: "message-1", sent_at: DateTime.utc_now}

:timer.sleep(2000)
send pid_a, %{message: "message-2", sent_at: DateTime.utc_now}

