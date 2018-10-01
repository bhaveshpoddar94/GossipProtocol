defmodule Algorithm do
  def get_push_method(algorithm) do
    case algorithm do
      "gossip"   -> &Gossip.push/3
      "pushsum" -> &PushSum.push/3
      _          -> IO.puts "Wrong input for algorithm!"
    end
  end
end

defmodule Gossip do
  use GenServer

  # Client
  def start_link(state) do
    {:ok, pid} = GenServer.start_link(__MODULE__, state)
    pid
  end

  def push(pid, parent, network) do
    GenServer.cast(pid, {:push, parent, network})
  end

  # Server
  def init(state) do
    {:ok, state}
  end

  def handle_cast({:push, parent, network}, state) do
    cond do
      state == 0 ->
        send(parent, {:CHECK, self(), state})
        GenServer.cast(self(), {:transmit, parent, network})
        {:noreply, state+1}
      state < 10 ->
        {:noreply, state+1}
      true ->
        {:noreply, state}
    end
  end

  def handle_cast({:transmit, parent, network}, state) do
    neighbors = Map.get(network, self())
    if state < 10 && !Enum.empty?(neighbors) do
      pid = Enum.random(neighbors)
      push(pid, parent, network)
      :timer.sleep(10)
      GenServer.cast(self(), {:transmit, parent, network})
    end
    {:noreply, state}
  end
end

defmodule PushSum do
  use GenServer

  # Client
  def start_link(state) do
    {:ok, pid} = GenServer.start_link(__MODULE__, state)
    pid
  end

  def push(pid, parent, network, message\\{0.0, 0.0}) do
    GenServer.cast(pid, {:push, parent, network, message})
  end

  # Server
  def init(state) do
    {:ok, state}
  end

  def handle_cast({:push, parent, network, {other_sum, other_wgt}}, {count, sum, wgt}) do
    new_sum = sum + other_sum
    new_wgt = wgt + other_wgt
    neighbors = Map.get(network, self())
    if !Enum.empty?(neighbors) do
      pid = Enum.random(neighbors)
      push(pid, parent, network, {new_sum/2, new_wgt/2})
    end
    diff = (new_sum/new_wgt) - (sum/wgt)
    count = 
      if diff <= :math.pow(10, -10) do
        count + 1
      else
        0
      end
    
    # if converged send message to parent 
    if count >= 3 do
      send(parent, {:CHECK, self(), new_sum/new_wgt})
    end
    {:noreply, {count, new_sum, new_wgt}}
  end
end