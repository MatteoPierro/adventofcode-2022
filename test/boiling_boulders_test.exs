defmodule BoilingBouldersTest do
  use ExUnit.Case

  test "example" do
    raw_droplet = [
      "2,2,2",
      "1,2,2",
      "3,2,2",
      "2,1,2",
      "2,3,2",
      "2,2,1",
      "2,2,3",
      "2,2,4",
      "2,2,6",
      "1,2,5",
      "3,2,5",
      "2,1,5",
      "2,3,5"
    ]

    droplets = parse_droplets(raw_droplet)

    assert count_unique_faces(droplets) == 64
    assert calculate_unique_faces_without_air(droplets) == 58
  end

  test "puzzle solution" do
    raw_droplets = FileReader.read_all_lines("input_day18.txt")

    droplets = parse_droplets(raw_droplets)

    assert count_unique_faces(droplets) == 3662
    assert calculate_unique_faces_without_air(droplets) == 2060
  end

  def calculate_unique_faces_without_air(droplets) do
    {min_v, max_v} = calculate_min_max(droplets)
    frontier = [[min_v, min_v, min_v]]
    steam = MapSet.new([[min_v, min_v, min_v]])
    calculate_unique_faces_without_air(droplets, frontier, steam, min_v, max_v, 0)
  end

  def calculate_unique_faces_without_air(_, [], _, _, _, area), do: area

  def calculate_unique_faces_without_air(droplets, [point | rest], steam, min_v, max_v, area) do
    neighbour = find_neighbours(point, min_v, max_v) |> MapSet.difference(steam)

    {new_steam, new_frontier, new_area} =
      Enum.reduce(neighbour, {steam, rest, area}, fn other,
                                                     {current_steam, current_frontier,
                                                      current_area} ->
        if MapSet.member?(droplets, other) do
          {current_steam, current_frontier, current_area + 1}
        else
          {MapSet.put(current_steam, other), [other | current_frontier], current_area}
        end
      end)

    calculate_unique_faces_without_air(droplets, new_frontier, new_steam, min_v, max_v, new_area)
  end

  def count_unique_faces(droplets) do
    {min_v, max_v} = calculate_min_max(droplets)

    initial_area = 6 * Enum.count(droplets)

    Enum.reduce(droplets, initial_area, fn point, acc ->
      point_area =
        find_neighbours(point, min_v, max_v) |> MapSet.intersection(droplets) |> Enum.count()

      acc - point_area
    end)
  end

  @relative_neighbours [[0, 0, 1], [0, 0, -1], [1, 0, 0], [-1, 0, 0], [0, 1, 0], [0, -1, 0]]
  def find_neighbours([x, y, z] = p, min_v, max_v) do
    @relative_neighbours
    |> Enum.map(fn [dx, dy, dz] -> [x + dx, y + dy, z + dz] end)
    |> Enum.filter(&Enum.all?(&1, fn v -> v >= min_v and v <= max_v end))
    |> List.delete(p)
    |> MapSet.new()
  end

  def calculate_min_max(droplets) do
    {min, max} = MapSet.to_list(droplets) |> List.flatten() |> Enum.min_max()
    {min - 1, max + 1}
  end

  def parse_droplets(raw_droplets),
    do:
      Enum.map(raw_droplets, fn raw_vertex ->
        raw_vertex |> String.split(",") |> Enum.map(&String.to_integer/1)
      end)
      |> MapSet.new()
end
