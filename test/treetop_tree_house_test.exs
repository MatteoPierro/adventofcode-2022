defmodule TreetopTreeHouseTest do
  use ExUnit.Case

  defmodule Grid do
    defstruct [:rows, :columns, :coordinates]
  end

  test "example" do
    raw_grid = [
      "30373",
      "25512",
      "65332",
      "33549",
      "35390"
    ]

    grid = parse_grid(raw_grid)

    assert grid.rows == [
             [3, 0, 3, 7, 3],
             [2, 5, 5, 1, 2],
             [6, 5, 3, 3, 2],
             [3, 3, 5, 4, 9],
             [3, 5, 3, 9, 0]
           ]

    assert grid.columns == [
             [3, 2, 6, 3, 3],
             [0, 5, 5, 3, 5],
             [3, 5, 3, 5, 3],
             [7, 1, 3, 4, 9],
             [3, 2, 2, 9, 0]
           ]

    assert number_of_visible_points(grid) == 21
    assert viewing_distance(grid) == 8
  end

  test "puzzle solution" do
    raw_grid = FileReader.read_all_lines("input_day8.txt")

    grid = parse_grid(raw_grid)

    assert number_of_visible_points(grid) == 1798
    assert viewing_distance(grid) == 259_308
  end

  def viewing_distance(grid),
    do:
      grid.coordinates
      |> Enum.map(&viewing_distance(&1, grid.rows, grid.columns))
      |> Enum.max()

  def viewing_distance({0, _}, _, _), do: 0
  def viewing_distance({_, 0}, _, _), do: 0

  def viewing_distance({column_index, _}, _, columns) when column_index == length(columns) - 1,
    do: 0

  def viewing_distance({_, row_index}, rows, _) when row_index == length(rows) - 1, do: 0

  def viewing_distance({column_index, row_index}, rows, columns) do
    row = Enum.at(rows, row_index)
    column = Enum.at(columns, column_index)
    value = Enum.at(row, column_index)

    [
      Enum.slice(row, 0..(column_index - 1)) |> Enum.reverse(),
      Enum.slice(row, (column_index + 1)..-1),
      Enum.slice(column, 0..(row_index - 1)) |> Enum.reverse(),
      Enum.slice(column, (row_index + 1)..-1)
    ]
    |> Enum.map(&distance(&1, value))
    |> Enum.reduce(&Kernel.*/2)
  end

  def distance(trees, value, d \\ 0)
  def distance([], _, d), do: d
  def distance([tree | _], value, d) when tree >= value, do: d + 1
  def distance([_ | rest], value, d), do: distance(rest, value, d + 1)

  def number_of_visible_points(grid),
    do:
      grid.coordinates |> Enum.filter(&visible_tree?(&1, grid.rows, grid.columns)) |> Enum.count()

  def visible_tree?({0, _}, _, _), do: true

  def visible_tree?({column_index, _}, _, columns) when column_index == length(columns) - 1,
    do: true

  def visible_tree?({_, 0}, _, _), do: true
  def visible_tree?({_, row_index}, rows, _) when row_index == length(rows) - 1, do: true

  def visible_tree?({column_index, row_index}, rows, columns) do
    row = Enum.at(rows, row_index)
    column = Enum.at(columns, column_index)
    value = Enum.at(row, column_index)

    [
      Enum.slice(row, 0..(column_index - 1)),
      Enum.slice(row, (column_index + 1)..-1),
      Enum.slice(column, 0..(row_index - 1)),
      Enum.slice(column, (row_index + 1)..-1)
    ]
    |> Enum.any?(fn l -> Enum.all?(l, &(&1 < value)) end)
  end

  def parse_grid(raw_grid) do
    rows =
      raw_grid
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(fn r -> Enum.map(r, &String.to_integer/1) end)

    columns = rows |> Enum.zip() |> Enum.map(&Tuple.to_list/1)

    coordinates =
      for x <- 0..(Enum.count(columns) - 1), y <- 0..(Enum.count(rows) - 1), do: {x, y}

    %Grid{rows: rows, columns: columns, coordinates: coordinates}
  end
end
