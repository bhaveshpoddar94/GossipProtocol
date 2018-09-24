defmodule Topology do
  def create(type, numNodes) do
    case type do
      "full_network"   -> FullNetwork.create_network(numNodes)
      "3D"             -> ThreeD.create_network(numNodes)
      "random_2D"      -> Random2D.create_network(numNodes)
      "torus"          -> Torus.create_network(numNodes)
      "line"           -> Line.create_network(numNodes)
      "imperfect_line" -> ImperfectLine.create_network(numNodes)
    end
  end
end


defmodule FullNetwork do
  def create_network(numNodes) do
    network = Enum.map(1..numNodes, fn _x -> Gossip.start_link(0) end)
    pid = Enum.random(network)
    {pid, network, &next/2}
  end

  def next(curr, network) do
    network = Enum.filter(network, fn pid -> Process.alive?(pid) && pid != curr end)
    case Enum.empty?(network) do
      false -> Enum.random(network)
      true  -> curr
    end
  end
end

# defmodule ThreeD do
#   def create_network(numNodes) do
#     network = Enum.map(1..numNodes, fn _x -> Gossip.start_link(0) end)
#     pid = Enum.random(children_pids)
#     {pid, network, next}
#   end
  
#   def next(curr, network) do
#     network = Enum.filter(network, fn pid -> Process.alive?(pid) && pid != curr end)
#     case Enum.empty?(network) do
#       false -> Enum.random(network)
#       true  -> curr
#     end
#   end
# end

# defmodule Random2D do
#   def create_network(numNodes) do
#     network = Enum.map(1..numNodes, fn _x -> Gossip.start_link(0) end)
#     pid = Enum.random(children_pids)
#     {pid, network, next}
#   end
  
#   def next(curr, network) do
#     network = Enum.filter(network, fn pid -> Process.alive?(pid) && pid != curr end)
#     case Enum.empty?(network) do
#       false -> Enum.random(network)
#       true  -> curr
#     end
#   end
# end

# defmodule Torus do
#   def create_network(numNodes) do
#     network = Enum.map(1..numNodes, fn _x -> Gossip.start_link(0) end)
#     pid = Enum.random(children_pids)
#     {pid, network, next}
#   end
  
#   def next(curr, network) do
#     network = Enum.filter(network, fn pid -> Process.alive?(pid) && pid != curr end)
#     case Enum.empty?(network) do
#       false -> Enum.random(network)
#       true  -> curr
#     end
#   end
# end

defmodule Line do
  def create_network(numNodes) do
    network = Enum.map(1..numNodes, fn _x -> Gossip.start_link(0) end)
    pid = Enum.random(network)
    IO.inspect network
    {pid, network, &next/2}
  end
  
  def next(curr, network) do
    idx = Enum.find_index(network, fn x -> x == curr end)
    neighbors = [idx-1, idx+1]
              |> Enum.filter(fn idx -> idx >= 0 && idx <= length(network) - 1 end)
              |> Enum.map(fn idx -> Enum.at(network, idx) end)
              |> Enum.filter(fn pid -> Process.alive?(pid) end)
    case Enum.empty?(neighbors) do
      false -> Enum.random(neighbors)
      true  -> curr
    end
  end
end

# defmodule ImperfectLine do
#   def create_network(numNodes) do
#     network = Enum.map(1..numNodes, fn _x -> Gossip.start_link(0) end)
#     pid = Enum.random(children_pids)
#     {pid, network, next}
#   end
  
#   def next(curr, network) do
#     network = Enum.filter(network, fn pid -> Process.alive?(pid) && pid != curr end)
#     case Enum.empty?(network) do
#       false -> Enum.random(network)
#       true  -> curr
#     end
#   end
# end
