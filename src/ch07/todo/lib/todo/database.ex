defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    GenServer.start(
      __MODULE__,
      db_folder,
      name: :database_server # <-- Locally registers the process
    )
  end

  def store(key, data) do
    GenServer.cast(:database_server, {:store, key, data})
  end

  def get(key) do
    GenServer.call(:database_server, {:get, key})
  end

  def init(db_folder) do
    File.mkdir_p(db_folder)
    {:ok, db_folder}
  end

  def handle_cast({:store, key, data}, db_folder) do
    spawn(fn ->
      file_name(db_folder, key)
        |> File.write!(:erlang.term_to_binary(data))
    end)
    {:noreply, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
    #
    # Spawn a new reader
    #
    spawn(fn ->
      data = case File.read(file_name(db_folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

      #
      # Responds from the spawned process
      GenServer.reply(caller, data)
    )

    #
    # No reply from the database
    #
    {:noreply, db_folder}
  end

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
end