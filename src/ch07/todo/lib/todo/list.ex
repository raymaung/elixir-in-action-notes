defmodule Todo.List do
  defstruct auto_id: 1, entries: HashDict.new

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Todo.List{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(%Todo.List{entries: entries, auto_id: auto_id}, entry) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)
    %Todo.List{
      entries: new_entries,
      auto_id: auto_id +  1
    }
  end

  def entries(%Todo.List{entries: entries}, date) do
    entries
      |> Stream.filter(
        fn ({_, entry}) -> entry.date == date end
      )
      |> Enum.map(
        fn ({_, entry}) -> entry end
      )
  end

  def update_entry(%Todo.List{entries: entries} = todo_list, entry_id, updater_fun) do
    case entries[entry_id] do
      nil -> todo_list
      old_entry ->
        new_entry = updater_fun.(old_entry)
        new_entries = HashDict.put(entries, new_entry.id, new_entry)
        %Todo.List{todo_list | entries: new_entries }
    end
  end

  def delete_entry(%Todo.List{entries: entries} = todo_list, entry_id) do
    %Todo.List{ todo_list | entries: HashDict.delete(entries, entry_id)}
  end
end