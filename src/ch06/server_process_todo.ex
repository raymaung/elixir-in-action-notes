defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        # Invokes the call back to handle the message
        {response, new_state} = callback_module.handle_call(request, current_state)

        # Sends the response back
        send(caller, {:response, response})
        # Loops with the new state
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)
    end
  end

  def cast(server_id, request) do
    # Issue a case message
    send(server_id, {:cast, request})
  end

  def call(server_id, request) do
    # Sends the message
    send(server_id, {:call, request, self})

    # Waits for the response
    receive do
      # Returns the response
      {:response, response} -> response
    end
  end
end

defmodule TodoServer do
  def init() do
    TodoList.new
  end

  def start() do
    ServerProcess.start(TodoServer)
  end

  def add_entry(todo_server, new_entry) do
    ServerProcess.cast(todo_server, {:add_entry, new_entry})
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    TodoList.add_entry(todo_list, new_entry)
  end

  def entries(todo_server, date) do
    ServerProcess.call(todo_server, {:entries, date})
  end

  def handle_call({:entries, date}, todo_list) do
    {TodoList.entries(todo_list, date), todo_list}
  end
end

defmodule TodoList do
  defstruct auto_id: 1, entries: HashDict.new

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(%TodoList{entries: entries, auto_id: auto_id}, entry) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)
    %TodoList{
      entries: new_entries,
      auto_id: auto_id +  1
    }
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
      |> Stream.filter(
        fn ({_, entry}) -> entry.date == date end
      )
      |> Enum.map(
        fn ({_, entry}) -> entry end
      )
  end

  def update_entry(%TodoList{entries: entries} = todo_list, entry_id, updater_fun) do
    case entries[entry_id] do
      nil -> todo_list
      old_entry ->
        new_entry = updater_fun.(old_entry)
        new_entries = HashDict.put(entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries }
    end
  end

  def delete_entry(%TodoList{entries: entries} = todo_list, entry_id) do
    %TodoList{ todo_list | entries: HashDict.delete(entries, entry_id)}
  end
end

todo_server = TodoServer.start
TodoServer.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Dentist"})
TodoServer.add_entry(todo_server, %{date: {2013, 12, 20}, title: "Shopping"})
TodoServer.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Movies"})
TodoServer.entries(todo_server, {2013, 12, 19})