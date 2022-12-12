defmodule HillClimbingAlgorithmTest do
  use ExUnit.Case

  defmodule Map do
    defstruct [:rows, :dimensions, :start, :target]
  end

  @test_map [
    "Sabqponm",
    "abcryxxl",
    "accszExk",
    "acctuvwj",
    "abdefghi"
  ]

  @directions [
    {0, -1},
    {0, 1},
    {-1, 0},
    {1, 0}
  ]

  test "parse map" do
    map = parse_map(@test_map)

    assert map.start == {0, 0}
    assert map.target == {5, 2}
    assert map.dimensions == {8, 5}
  end

  test "find neighbours" do
    map = parse_map(@test_map)

    assert candidate_neighbours_positions(map, {0, 0}) == [{0, 1}, {1, 0}]
    assert candidate_neighbours_positions(map, {7, 0}) == [{7, 1}, {6, 0}]
    assert candidate_neighbours_positions(map, {7, 4}) == [{7, 3}, {6, 4}]
    assert candidate_neighbours_positions(map, {2, 1}) == [{2, 0}, {2, 2}, {1, 1}, {3, 1}]
  end

  test "value at" do
    map = parse_map(@test_map)

    assert value_at(map, {2, 1}) == "c"
    assert value_at(map, {0, 0}) == "S"
    assert value_at(map, {5, 3}) == "v"
    assert value_at(map, {6, 3}) == "w"
    assert valid_step?("v", "w")
  end

  test "valid step" do
    assert valid_step?("a", "b")
    refute valid_step?("a", "E")
    refute valid_step?("a", "c")
    assert valid_step?("z", "f")
    refute valid_step?("S", "f")
  end

  test "priority queue" do
    pq =
      PriorityQueue.new()
      |> PriorityQueue.put(30, "foo")
      |> PriorityQueue.put(1, "bar")
      |> PriorityQueue.put(20, "biz")

    assert Enum.count(pq) == 3

    {{priority, value}, pq} = PriorityQueue.pop(pq)
    assert value == "bar"

    {{priority, value}, pq} = PriorityQueue.pop(pq)
    assert value == "biz"

    {{priority, value}, pq} = PriorityQueue.pop(pq)
    assert value == "foo"

    assert PriorityQueue.empty?(pq)
  end

  test "shortest path" do
    map = parse_map(@test_map)

    path = find_shortest_path(map)
    assert Enum.count(path) - 1 == 31
  end

  test "puzzle solution" do
    map = FileReader.read_all_lines("input_day12.txt") |> parse_map()

    assert map.start == {0, 20}
    assert map.target == {138, 20}
    path = find_shortest_path(map)
    assert Enum.count(path) - 1 == 440
  end

  def find_shortest_path(map),
    do:
      find_shortest_path(
        [[map.start]],
        map,
        MapSet.new()
      )

  def find_shortest_path([], _, _), do: raise("FOUND NOTHING!")

  def find_shortest_path([current_path | other_paths], map, seen) do
    [last | _] = current_path

    cond do
      last == map.target ->
        current_path |> Enum.reverse()

      MapSet.member?(seen, last) ->
        find_shortest_path(other_paths, map, seen)

      true ->
        find_shortest_path(
          other_paths ++ paths_to_visit(map, current_path),
          map,
          MapSet.put(seen, last)
        )
    end
  end

  def paths_to_visit(map, [last | _] = current_path),
    do:
      candidate_neighbours_positions(map, last)
      |> Enum.filter(fn candidate ->
        last_value = value_at(map, last)
        candidate_value = value_at(map, candidate)
        valid_step?(last_value, candidate_value)
      end)
      |> Enum.reduce([], fn neighbour, paths_to_visit ->
        [[neighbour | current_path] | paths_to_visit]
      end)

  def valid_step?("S", next), do: valid_step?("a", next)
  def valid_step?(current, "E"), do: valid_step?(current, "z")

  def valid_step?(current, next),
    do: :binary.first(next) - :binary.first(current) <= 1

  def value_at(%Map{rows: rows}, {x, y}), do: Enum.at(rows, y) |> Enum.at(x)

  def candidate_neighbours_positions(%Map{dimensions: {dim_x, dim_y}}, {px, py}),
    do:
      Enum.map(@directions, fn {dx, dy} -> {px + dx, py + dy} end)
      |> Enum.reject(fn {x, y} -> x < 0 or y < 0 or x >= dim_x or y >= dim_y end)

  def parse_map(raw_map) do
    rows = Enum.map(raw_map, &String.graphemes/1)
    columns = Enum.zip(rows) |> Enum.map(&Tuple.to_list/1)
    start_x = Enum.find_index(columns, &("S" in &1))
    start_y = Enum.find_index(rows, &("S" in &1))
    start = {start_x, start_y}
    target_x = Enum.find_index(columns, &("E" in &1))
    target_y = Enum.find_index(rows, &("E" in &1))
    target = {target_x, target_y}
    dimensions = {Enum.count(columns), Enum.count(rows)}

    %Map{rows: rows, start: start, target: target, dimensions: dimensions}
  end
end
