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
    assert valid_step?("a", "E")
    refute valid_step?("a", "c")
    assert valid_step?("z", "f")
    assert valid_step?("S", "f")
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
    IO.inspect(path)
    assert Enum.count(path) - 1 == 31
  end

  test "puzzle solution" do
    map = FileReader.read_all_lines("input_day12.txt") |> parse_map()

    assert map.start == {0, 20}
    assert map.target == {138, 20}
    path = find_shortest_path(map)
    assert Enum.count(path) - 1 == 31
  end

  def find_shortest_path(map),
    do:
      find_shortest_path(
        PriorityQueue.new() |> PriorityQueue.put(0, [map.start]),
        map,
        MapSet.new()
      )

  def find_shortest_path(pq, map, seen) do
    if PriorityQueue.empty?(pq) do
      raise "FOUND NOTHING!"
    else
      do_find_shortest_path(pq, map, seen)
    end
  end

  def do_find_shortest_path(pq, map, seen) do
    {{current_length, current_path}, pq} = PriorityQueue.pop(pq)
    [last | remaining] = current_path

    if value_at(map, last) == "E" do
      current_path |> Enum.reverse()
    else
      seen = MapSet.put(seen, last)
      candidate_neighbours_positions(map, last)
      |> Enum.filter(fn candidate ->
        last_value = value_at(map, last)
        candidate_value = value_at(map, candidate)
        valid_step?(last_value, candidate_value) and not MapSet.member?(seen, candidate)
      end)
      |> Enum.reduce(pq, fn neighbour, pq ->
        PriorityQueue.put(pq, {current_length + 1, [neighbour | current_path]})
      end)
      |> find_shortest_path(map, seen)
    end
  end

  def valid_step?("S", "a"), do: true
  def valid_step?("S", _), do: false
  def valid_step?("z", "E"), do: true
  def valid_step?(_, "E"), do: false

  def valid_step?(current, next),
    do: next <= current or :binary.first(current) == :binary.first(next) - 1

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
