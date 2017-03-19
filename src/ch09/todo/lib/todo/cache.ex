defmodule Todo.Cache do
  use GenServer

  def init(_) do
    {:ok, HashDict.new}
  end

  def start_link do
    IO.puts "Starting to-do cache."
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def server_process(todo_list_name) do
    GenServer.call(:todo_cache, {:server_process, todo_list_name})
  end

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case HashDict.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}
      :error ->
        {:ok, new_server} = Todo.Server.start_link(todo_list_name)

        {
          :reply,
          new_server,
          HashDict.put(todo_servers, todo_list_name, new_server)
        }
    end
  end
end

# # Start Cache
# {:ok, cache} = Todo.Cache.start_link

# # Create Two Lists - Alice and Bob
# Todo.Cache.server_process(cache, "Alice's list")
# Todo.Cache.server_process(cache, "Bob's list")

# # Add to the Bob List
# bobs_list = Todo.Cache.server_process(cache, "Bob's list")
# Todo.Server.add_entry(bobs_list, %{date: {2013, 12, 19}, title: "Dentist"})
# Todo.Server.entries(bobs_list, {2013, 12, 19})

# # Verify Alice List isn't affected
# Todo.Cache.server_process(cache, "Alice's list") |>
#                   Todo.Server.entries({2013, 12, 19})
#

# # Get the number of processes in the BEAM
#
# length(:erlang.processes)
#
# 1..100_000 |> Enum.each(fn(index) ->
#   Todo.Cache.server_process(cache, "to-do list #{index}")
# end)
#
# a_todo = Todo.Cache.server_process(cache, "to-do list 31")
# Todo.Server.add_entry(a_todo, %{date: {2013, 12, 19}, title: "Dentist"})
# Todo.Server.entries(a_todo, {2013, 12, 19})