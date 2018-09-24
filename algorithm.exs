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

  def push(parent, pid, network, next) do
    GenServer.cast(pid, {:push, parent, network, next})
  end

  def init(state) do
    # runs in the server context 🐨Bob
    {:ok, state}
  end

  def handle_cast({:push, parent, network, next}, state) do
    pid = next.(self(), network)
    push(parent, pid, network, next)
    cond do
      state+1 == 100 -> 
        Process.exit(self(), :normal)
      state+1 == 1  -> 
        send(parent, {:CHECK, self()}) 
        {:noreply, state+1}
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