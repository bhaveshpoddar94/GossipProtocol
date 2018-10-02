defmodule Parent do
  Code.require_file("topology.exs")
  Code.require_file("algorithm.exs")

  def init(numNodes, topology\\"full", algorithm\\"gossip") do
    #adjust numNodes
    numNodes = adjust_numNodes(topology, numNodes)

    #spawn actors
    actor_list = create_network(numNodes, algorithm)

    # setup topology and get the adjacency list
    network = Topology.create(topology, actor_list)

    # get push method from the respective algorithm
    push = Algorithm.get_push_method(algorithm)
    
    # select a random actor
    random_actor = Enum.random(actor_list)

    # time the protocol
    start_time = Time.utc_now()
    push.(random_actor, self(), network)
    loop(numNodes)
    end_time = Time.utc_now()
    
    # report time
    exec_time = Time.diff(end_time, start_time, :millisecond)
    IO.puts "Time elapsed: #{exec_time} miliseconds"
  end

  defp adjust_numNodes(topology, numNodes) do
    cond do 
      topology == "torus" -> 
        round(:math.pow(:math.ceil(:math.sqrt(numNodes)),2))
      topology == "3D" -> 
        round(:math.pow(:math.ceil(:math.pow(numNodes, 0.33)),3))
      true -> numNodes
    end
  end

  defp create_network(numNodes, algorithm) do
    case algorithm do
      "gossip"  -> Enum.map(1..numNodes, fn _x -> Gossip.start_link(0) end)
      "pushsum" -> Enum.map(1..numNodes, fn x -> PushSum.start_link({0, x/1, 1.0}) end)
    end
  end
  
  def loop(0), do: :ok
  def loop(numNodes) do
    receive do
      {:CHECK, _pid, _value} ->
        loop(numNodes-1)
    end
  end
end

args = System.argv()
cond do 
  length(args) < 3 -> IO.puts "Wrong number of inputs"
  length(args) > 3 -> IO.puts "Wrong number of inputs"
  true             -> [numNodes, topology, algorithm] = args
  					  Parent.init(String.to_integer(numNodes), topology, algorithm)
end