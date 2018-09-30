defmodule Parent do
  Code.require_file("topology.exs")
  Code.require_file("algorithm.exs")

  def init(numNodes, topology\\"full", algorithm\\"gossip") do
    Process.flag :trap_exit, true

    #round numNodes
    numNodes = 
      case topology do
        "3D"     -> get_Numnodes_for_3D()
        "rand2D" -> get_Numnodes_for_2D()
        "torus"  -> get_Numnodes_for_2D()
        _        -> numNodes
      end

    #spawn actors
    network = create_network(numNodes, algorithm)

    # setup topology and get the next method
    next = Topology.create(topology, network)
    
    # get push method from respective algorithm
    push = Algorithm.get_push_method(algorithm)
    
    # fetch a random actor
    rand = :rand.uniform(numNodes)
    pid  = Enum.at(network, rand)

    # time the protocol
    start_time = Time.utc_now()
    push.(pid, self(), network, next)
    loop(numNodes)
    end_time = Time.utc_now()
    
    # report time
    exec_time = Time.diff(end_time, start_time, :millisecond)
    IO.puts "Time elapsed: #{exec_time} miliseconds"
  end

  defp create_network(numNodes, algorithm) do
    case algorithm do
      "gossip"  -> Enum.map(1..numNodes, fn _x -> Gossip.start_link(0) end)
      "pushsum" -> Enum.map(1..numNodes, fn _x -> PushSum.start_link(%{}) end)
    end
  end

  defp get_Numnodes_for_2D(n) do
    root = :math.sqrt(n)
    decimal_part = root - trunc(root)
    if decimal_part > 0.5 do
      root = root + 1
    end
    :math.pow(root, 2) |> round
  end
  
  def loop(0), do: Process.exit(self(), :normal)
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

Parent.init(100)