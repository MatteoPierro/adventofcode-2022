defmodule RegolithReservoirTest do
  use ExUnit.Case

  defmodule Map do
    defstruct [:occupied_points, :max_y]
  end

  test "parse lines" do
    raw_lines = [
      "498,4 -> 498,6 -> 496,6",
      "503,4 -> 502,4 -> 502,9 -> 494,9"
    ]

    map = parse_map(raw_lines)

    assert map.occupied_points |> Enum.count() == 20
    assert map.max_y == 9
    assert pour_sand(map) == 24
  end

  test "puzzle solution" do
    raw_lines = FileReader.read_all_lines("input_day14.txt")

    map = parse_map(raw_lines)

    assert pour_sand(map) == 1016
  end

  def pour_sand(map, sand_counter \\ 0), do: pour_sand(map, sand_counter, [500, 0])

  def pour_sand(%Map{occupied_points: occupied_points, max_y: max_y}=map, sand_counter, [x, y] = sand) do
    next_position =
      [[0, 1], [-1, 1], [1, 1]]
      |> Enum.map(fn [dx, dy] -> [x + dx, y + dy] end)
      |> Enum.find(&(not MapSet.member?(occupied_points, &1)))

    cond do
      next_position == nil ->
        pour_sand(%{map | occupied_points: MapSet.put(occupied_points, sand)}, sand_counter + 1)

      List.last(next_position) > max_y -> sand_counter

      true ->
        pour_sand(map, sand_counter, next_position)
    end
  end

  def parse_map(raw_lines) do
    occupied_points =
      raw_lines
      |> Enum.map(&String.split(&1, " -> "))
      |> Enum.map(&Enum.chunk_every(&1, 2, 1, :discard))
      |> Enum.map(&parse_line/1)
      |> Enum.reduce(&MapSet.union/2)

    max_y = Enum.map(occupied_points, fn [_, y] -> y end) |> Enum.max()

    %Map{occupied_points: occupied_points, max_y: max_y}
  end

  def parse_line(segments, points \\ MapSet.new())

  def parse_line([], points), do: points

  def parse_line([[raw_start, raw_stop] | rest], points) do
    start = String.split(raw_start, ",") |> Enum.map(&String.to_integer/1)
    stop = String.split(raw_stop, ",") |> Enum.map(&String.to_integer/1)
    parse_line(rest, MapSet.union(points, parse_segment(start, stop)))
  end

  def parse_segment([sx, sy], [sx, ey]),
    do:
      sy..ey
      |> Enum.map(&[sx, &1])
      |> MapSet.new()

  def parse_segment([sx, sy], [ex, sy]),
    do:
      sx..ex
      |> Enum.map(&[&1, sy])
      |> MapSet.new()
end
