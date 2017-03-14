defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {request, caller} ->
        # Invokes the call back to handle the message
        {response, new_state} = callback_module.handle_call(request, current_state)

        # Sends the response back
        send(caller, {:response, response})
        # Loops with the new state
        loop(callback_module, new_state)
    end
  end

  def call(server_id, request) do
    # Sends the message
    send(server_id, {request, self})

    # Waits for the response
    receive do
      # Returns the response
      {:response, response} -> response
    end
  end
end

defmodule KeyValueStore do
  def init do
    # Initial process state
    HashDict.new
  end

  def start do
    ServerProcess.start(KeyValueStore)
  end

  def put(pid, key, value) do
    ServerProcess.call(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  def handle_call({:put, key, value}, state) do
    {:ok, HashDict.put(state, key, value)}
  end

  def handle_call({:get, key}, state) do
    {HashDict.get(state, key), state}
  end
end

# pid = ServerProcess.start(KeyValueStore)
# ServerProcess.call(pid, {:put, :some_key, :some_value})
# ServerProcess.call(pid, {:get, :some_key})