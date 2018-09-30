defmodule Algorithm do
  def get_push_method(algorithm) do
    case algorithm do
      "gossip"   -> &Gossip.push/4
      "push_sum" -> &PushSum.push/4
      _          -> IO.puts "Wrong input for algorithm!"
    end
  end
end

defmodule Gossip do
  use GenServer

  def start_link(state) do
    {:ok, pid} = GenServer.start_link(__MODULE__, state)
    pid
  end

  def push(pid, parent, network, next) do
    GenServer.cast(pid, {:push, parent, network, next})
  end

  def init(state) do
    {:ok, state}
  end

  def loop(parent, network, next) do
    pid = next.(self(), network)
    if pid == self() do
      :ok
    else
      push(pid, parent, network, next)
      loop(parent, network, next)
    end
  end

  def handle_cast({:push, parent, network, next}, state) do
    cond do
      state+1 == 1 ->
        send(parent, {:CHECK, self()})
        loop(parent, network, next)
        {:noreply, state+1}
      state+1 >= 10 ->
        {:noreply, state}
      true ->
        {:noreply, state+1}
    end
  end
end

# defmodule PushSum do
#   use GenServer

#   def start_link(state) do
#     {:ok, pid} = GenServer.start_link(__MODULE__, state)
#     pid
#   end

#   def push(pid, neighbors) do
#     GenServer.cast(pid, {:push, neighbors})
#   end

#   def init(state) do
#     # runs in the server context 🐨Bob
#     {:ok, state}
#   end

#   def handle_cast({:push, neighbors}, state) do
#     pid = find_neighbor(self(), neighbors)
#     push(pid, neighbors)
#     if state+1 == 10 do
#       Process.exit(self(), :normal)
#     end
#     {:noreply, state+1}
#   end
# end