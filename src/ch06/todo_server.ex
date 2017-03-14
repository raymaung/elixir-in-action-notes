defmodule TodoServer do

  use GenServer

  def start() do
    GenServer.start(TodoServer, nil)
  end

  def init(_) do
    {:ok, TodoList.new}
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    new_todo_list = TodoList.add_entry(todo_list, new_entry)
    {
      :noreply,
      new_todo_list
    }
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end
  def handle_call({:entries, date}, _, todo_list) do
    {
      :reply,
      TodoList.entries(todo_list, date),
      todo_list
    }
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

{:ok, todo_server} = TodoServer.start
TodoServer.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Dentist"})
TodoServer.add_entry(todo_server, %{date: {2013, 12, 20}, title: "Shopping"})
TodoServer.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Movies"})
IO.inspect TodoServer.entries(todo_server, {2013, 12, 19})