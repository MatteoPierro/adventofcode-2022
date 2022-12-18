defmodule BoilingBouldersTest do
  use ExUnit.Case

  @delta [1, 0, -1]

  @relative_neighbours [[0, 0, 1], [0, 0, -1], [1, 0, 0], [-1, 0, 0], [0, 1, 0], [0, -1, 0]]

  @first_face for x <- @delta, z <- @delta, do: [x, 0, z]
  @second_face for x <- @delta, z <- @delta, do: [x, 1, z]
  @third_face for y <- @delta, z <- @delta, do: [1, y, z]
  @forth_face for y <- @delta, z <- @delta, do: [0, y, z]
  @fifth_face for x <- @delta, y <- @delta, do: [x, y, 1]
  @sixth_face for x <- @delta, y <- @delta, do: [x, y, 0]

  @relative_faces [@first_face, @second_face, @third_face, @forth_face, @fifth_face, @sixth_face]

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
  end

  test "puzzle" do
    raw_droplets = FileReader.read_all_lines("input_day18.txt")

    droplets = parse_droplets(raw_droplets)

    assert count_unique_faces(droplets) == 3662
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

  def find_neighbours([x, y, z] = p, min_v, max_v) do
    @relative_neighbours
    |> Enum.map(fn [dx, dy, dz] -> [x + dx, y + dy, z + dz] end)
    |> Enum.filter(&Enum.all?(&1, fn v -> v > min_v and v < max_v end))
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
