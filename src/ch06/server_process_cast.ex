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

defmodule KeyValueStore do
  def init do
    # Initial process state
    HashDict.new
  end

  def start do
    ServerProcess.start(KeyValueStore)
  end

  def put(pid, key, value) do
    # Issues the put request as cast
    ServerProcess.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  def handle_cast({:put, key, value}, state) do
    # Handles the put request
    HashDict.put(state, key, value)
  end

  def handle_call({:get, key}, state) do
    {HashDict.get(state, key), state}
  end
end

pid = KeyValueStore.start
KeyValueStore.put(pid, :key1, :value1)
KeyValueStore.get(pid, :key1)
