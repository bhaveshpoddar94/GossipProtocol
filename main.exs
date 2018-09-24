defmodule Parent do
  Code.require_file("topology.exs")
  Code.require_file("algorithm.exs")

  def init(numNodes, topology\\"full_network", algorithm\\"gossip") do
    Process.flag :trap_exit, true

    # create topology
    {pid, network, next} = Topology.create(topology, numNodes)
    
    # get push method from respective algorithm
    push = Algorithm.get_push_method(algorithm)
    
    # time the protocol
    start_time = Time.utc_now()
    push.(self(), pid, network, next)
    loop(numNodes)
    end_time = Time.utc_now()
    
    # report time
    exec_time = Time.diff(end_time, start_time, :millisecond)
    IO.puts "Time elapsed: #{exec_time} miliseconds"
  end
  
  def loop(0), do: :ok
  def loop(numNodes) do
    receive do
      {:EXIT, pid, _} ->
        IO.puts "Parent got message: #{inspect pid }"
        loop(numNodes)
      {:CHECK, pid} ->
        IO.puts "Actor #{inspect pid} got the rumour"
        loop(numNodes-1)
    end
  end
end

Parent.init(100, "line")