defmodule ProboscideaVolcaniumTest do
  use ExUnit.Case

  test "parse line" do
    line = "Valve AA has flow rate=0; tunnels lead to valves DD, II, BB"
    current_neighbors = %{}
    current_flow_rates = %{}
    {neighbors, flow_rates} = parse_line(line, {current_neighbors, current_flow_rates})
    assert neighbors == %{"AA" => ["DD", "II", "BB"]}
    assert flow_rates == %{}
  end

  test "parse scan" do
    raw_scan = FileReader.read_all_lines("input_day16_test.txt")

    {neighbors, flow_rates} = parse_scan(raw_scan)

    assert neighbors == %{
             "AA" => ["DD", "II", "BB"],
             "BB" => ["CC", "AA"],
             "CC" => ["DD", "BB"],
             "DD" => ["CC", "AA", "EE"],
             "EE" => ["FF", "DD"],
             "FF" => ["EE", "GG"],
             "GG" => ["FF", "HH"],
             "HH" => ["GG"],
             "II" => ["AA", "JJ"],
             "JJ" => ["II"]
           }

    assert flow_rates == %{
             "BB" => 13,
             "CC" => 2,
             "DD" => 20,
             "EE" => 3,
             "HH" => 22,
             "JJ" => 21
           }
  end

  test "solve example" do
    raw_scan = FileReader.read_all_lines("input_day16_test.txt")

    {neighbors, flow_rates} = parse_scan(raw_scan)

    assert pressure(neighbors, flow_rates) |> max_pressure() ==
             {["CC", "EE", "HH", "JJ", "BB", "DD"], 1651}

    assert max_pressure_with_elephant(neighbors, flow_rates) == 1707
  end

  test "puzzle solution" do
    {neighbors, flow_rates} =
      FileReader.read_all_lines("input_day16.txt")
      |> parse_scan()

    {_, pressure} = pressure(neighbors, flow_rates) |> max_pressure()
    assert pressure == 2056

    assert max_pressure_with_elephant(neighbors, flow_rates) == 2513
  end

  def max_pressure_with_elephant(neighbors, flow_rates) do
    pressure(neighbors, flow_rates, 26)
    # remove the full paths
    |> Enum.filter(fn {path, pressure} ->
      Enum.count(path) < Enum.count(Map.keys(flow_rates))
    end)
    # find the max for each combination of valves ["BB", "CC"] is the same as ["CC","BB"]
    |> Enum.reduce(%{}, fn {path, pressure}, acc ->
      path_sorted = Enum.sort(path)
      current = Map.get(acc, path_sorted, 0)
      updated_pressure = max(current, pressure)
      Map.put(acc, path_sorted, updated_pressure)
    end)
    # make all the possible combination of the paths
    |> Comb.combinations(2)
    # filter paths having same valves
    |> Enum.reject(fn [{path1, _}, {path2, _}] ->
      path1 |> Enum.any?(&(&1 in path2))
    end)
    # sum the pressures
    |> Enum.map(fn [{_, pressure1}, {_, pressure2}] ->
      pressure1 + pressure2
    end)
    # find the max
    |> Enum.max()
  end

  def pressure(neighbors, flow_rates, minutes \\ 30) do
    sp = calculate_shortest_paths(neighbors, flow_rates)
    pressure("AA", neighbors, flow_rates, Map.keys(flow_rates), sp, [], 0, minutes)
  end

  def pressure(_, _, _, [], _, opened, total_pressure, _), do: [{opened, total_pressure}]

  def pressure(
        current_valve,
        neighbors,
        flow_rates,
        valves_to_open,
        shortest_paths,
        opened,
        total_pressure,
        minute
      ) do
    valves_to_open
    |> Enum.map(fn v ->
      path = Map.get(shortest_paths, current_valve) |> Map.get(v)
      remaning_valves = List.delete(valves_to_open, v)
      rate = Map.get(flow_rates, v)
      remaning_minutes = minute - Enum.count(path)

      cond do
        remaning_minutes <= 0 ->
          [{opened, total_pressure}]

        true ->
          [
            {[v | opened], total_pressure + rate * remaning_minutes},
            pressure(
              v,
              neighbors,
              flow_rates,
              remaning_valves,
              shortest_paths,
              [v | opened],
              total_pressure + rate * remaning_minutes,
              remaning_minutes
            )
          ]
      end
    end)
    |> List.flatten()
  end

  def max_pressure(s), do: s |> Enum.max(fn {_, t1}, {_, t2} -> t1 > t2 end)

  def calculate_shortest_paths(neighbors, flow_rates) do
    valves_to_open = Map.keys(flow_rates)

    shortest_paths_from_aa =
      valves_to_open
      |> Enum.reduce(%{}, fn v, total ->
        Map.put(total, v, find_shortest_path("AA", v, neighbors))
      end)

    shortest_paths =
      valves_to_open
      |> Enum.reduce(%{}, fn v, total ->
        reach =
          List.delete(valves_to_open, v)
          |> Enum.reduce(%{}, fn o, acc ->
            Map.put(acc, o, find_shortest_path(v, o, neighbors))
          end)

        Map.put(total, v, reach)
      end)

    Map.put(shortest_paths, "AA", shortest_paths_from_aa)
  end

  def find_shortest_path([], _, _, _), do: raise("FOUND NOTHING!")

  def find_shortest_path(source, target, map),
    do: find_shortest_path([[source]], target, map, MapSet.new())

  def find_shortest_path([current_path | other_paths], target, map, seen) do
    [last | _] = current_path

    cond do
      last == target ->
        current_path

      MapSet.member?(seen, last) ->
        find_shortest_path(other_paths, target, map, seen)

      true ->
        find_shortest_path(
          other_paths ++ paths_to_visit(map, current_path),
          target,
          map,
          MapSet.put(seen, last)
        )
    end
  end

  def paths_to_visit(map, [last | _] = current_path),
    do:
      Map.get(map, last)
      |> Enum.map(&[&1 | current_path])

  def parse_scan(raw_scan) do
    raw_scan
    |> Enum.reduce({%{}, %{}}, &parse_line/2)
  end

  def parse_line(line, {current_neighbors, current_flow_rates}) do
    [_, current_valve, rate, destination_vales_list] =
      Regex.run(~r/Valve (\S+) .+ rate=(\d+).+ valves? (.+)/, line)

    flow_rates =
      Map.put(current_flow_rates, current_valve, String.to_integer(rate))
      |> Enum.reject(fn {_, value} -> value == 0 end)
      |> Map.new()

    neighbors =
      Map.put(current_neighbors, current_valve, String.split(destination_vales_list, ", "))

    {neighbors, flow_rates}
  end
end
