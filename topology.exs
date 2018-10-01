defmodule Topology do
  def create(type, actor_list) do
    case type do
      "full"   -> FullNetwork.create(actor_list)
      "rand2D" -> Random.create(actor_list)
      "torus"  -> Torus.create(actor_list)
      "line"   -> Line.create(actor_list)
      "3D"     -> &ThreeD.next/2
      "imp2D" -> ImperfectLine.create(actor_list)
    end
  end
end


defmodule FullNetwork do
  def create(actor_list) do
    Enum.map(actor_list, fn pid -> {pid, Enum.filter(actor_list, fn x -> x != pid end)} end)
    |> Enum.into(%{})
  end
end

defmodule Random do
  def create(actor_list) do
    n = length(actor_list)
    idx_actor = Enum.map(0..n-1, fn i -> [{:rand.uniform, :rand.uniform}, Enum.at(actor_list, i)] end)
    Enum.map(idx_actor, fn [i1, pid1] -> neighbors = get_neighbors(i1, idx_actor)
        {pid1, neighbors} end)
      |> Enum.into(%{})
  end

  defp get_neighbors(i1, idx_actor) do
    Enum.filter(idx_actor, fn [i2, _pid2] -> valid_distance?(i1, i2) end)
    |> Enum.map(fn [i, pid] -> pid end)
  end

  defp valid_distance?({x1, y1}, {x2, y2}) do
    diff_x = abs(:math.pow(x1, 2) - :math.pow(x2, 2))
    diff_y = abs(:math.pow(y1, 2) - :math.pow(y2, 2))
    distance = :math.sqrt(diff_x + diff_y)
    if distance > 0.0 && distance < 0.6 do
      true
    else
      false
    end 
  end
end

defmodule Torus do
  def create(actor_list) do
    n = trunc(:math.sqrt(length(actor_list)))
    loop(0, n, [], actor_list)
    |> Enum.into(%{})
  end

  defp loop(n, n, network, _actor_list), do: network
  defp loop(r, n, network, actor_list) do
    row = Enum.map(0..n-1, fn c -> get_key_val({r, c}, n, actor_list) end)
    loop(r+1, n, network++row, actor_list)
  end

  defp get_key_val({r, c}, n, actor_list) do
    index = r * n + c
    curr = Enum.at(actor_list, index)
    neighbors = get_neighbors({r, c}, n, actor_list)
    {curr, neighbors}
  end

  defp get_neighbors({r, c}, n, actor_list) do
    [{r-1, c}, {r+1, c}, {r, c-1}, {r, c+1}]
    |> Enum.map(fn {r, c} -> {mod(r, n), mod(c, n)} end)
    |> Enum.map(fn {r, c} -> Enum.at(actor_list, r * n + c) end)
  end

  defp mod(x, y) when x > 0, do: rem(x, y)
  defp mod(x, y) when x < 0, do: rem(x, y) + y
  defp mod(0,_y), do: 0
end

defmodule Line do
  def create(actor_list) do
    n = length(actor_list)
    Enum.map(0..n-1, fn(index) -> {Enum.at(actor_list, index), get_neighbors(index, actor_list)} end)
    |> Enum.into(%{})
  end

  def get_neighbors(index, actor_list) do
    [index-1, index+1]
    |> Enum.filter(fn index -> index >=0 && index < length(actor_list) end)
    |> Enum.map(fn index -> Enum.at(actor_list, index) end)
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

defmodule ImperfectLine do
  def create(actor_list) do
    n = length(actor_list)
    Enum.map(0..n-1, fn(index) -> {Enum.at(actor_list, index), get_neighbors(index, actor_list)} end)
    |> Enum.into(%{})
  end

  def get_neighbors(index, actor_list) do
    n = length(actor_list)
    neighbors = [index-1, index+1]
    |> Enum.filter(fn index -> index >=0 && index < length(actor_list) end)
    |> Enum.map(fn index -> Enum.at(actor_list, index) end)
    rand_index = Enum.random(Enum.filter(0..n-1, fn i -> i != index end))
    random_neigbor = Enum.at(actor_list, rand_index)
    [random_neigbor | neighbors]
  end
end
