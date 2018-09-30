defmodule Topology do
  def create(type, numNodes) do
    case type do
      "full"   -> &FullNetwork.next/2
      "rand2D" -> &TwoD.next_random/2
      "torus"  -> &TwoD.next_torus/2
      "line"   -> &Line.next/2
      "3D"     -> &ThreeD.next/2
      "imperfect_line" -> &ImperfectLine.next/2
    end
  end
end


defmodule FullNetwork do
  def next(curr, network) do
    neighbors = Enum.filter(network, fn -> Process.alive?(pid) && pid != curr end)
    case Enum.empty?(neighbors) do
      true  -> curr
      false -> Enum.random(neighbors)
    end
  end
end

defmodule TwoD do
  def next_random({r, c}, network) do
    neighbors = [{r-1, c} , {r+1, c}, {r, c-1}, {r, c+1}]
                |> Enum.filter(fn {r, c} -> r >=0 and r < N and c >=0 and c < N end)
                |> clean(network, {r, c})
    case Enum.empty?(neighbors) do
      true  -> {r, c}
      false -> Enum.random(neighbors)
    end
  end

  def next_torus({r, c}, network) do
    N = length(network)
    neighbors = [{r-1, c} , {r+1, c}, {r, c-1}, {r, c+1}]
                |> Enum.map(neighbors, fn {r, c} -> {r % N, c % N})
                |> clean(network, {r, c})
    case Enum.empty?(neighbors) do
      true  -> {r, c}
      false -> Enum.random(neighbors)
    end
  end

  defp clean(neighbors, network, {x, y}) do
    N = trunc(:math.sqrt(length(network)))
    curr = Enum.at(network, get_index(r, c))
    |> Enum.map(neighbors, fn {r, c} -> Enum.at(network, r * (N-1) + c) end)
    |> Enum.into(%{})
    |> Enum.filter(fn {rc, pid} -> Process.alive?(pid) && pid != curr end)
    |> Map.keys
  end
end

defmodule Line do
  def next(curr_index, network) do
    neighbors = clean(network, curr_index)
    case Enum.empty?(pids) do
      true  -> curr
      false -> Enum.random(neighbors)
    end
  end

  defp clean(neighbors, network, curr_index) do
    curr = Enum.at(network, curr_index)
    Enum.map([curr_index-1, curr_index+1], fn index -> Enum.at(network, index) end)
    |> Enum.into(%{})
    |> Enum.filter(fn {index, pid} -> !is_nil(pid) && Process.alive?(pid) && pid != curr end)
    |> Map.keys
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
