defmodule PyroclasticFlowTest do
  use ExUnit.Case

  test "build shapes" do
    assert horizontal(0) == [[3, 4], [4, 4], [5, 4], [6, 4]]
    assert cross(0) == [[4, 6], [4, 4], [3, 5], [4, 5], [5, 5]]
    assert elle(0) == [[5, 6], [5, 5], [3, 4], [4, 4], [5, 4]]
    assert vertical(0) == [[3, 4], [3, 5], [3, 6], [3, 7]]
    assert square(0) == [[3, 5], [4, 5], [3, 4], [4, 4]]
  end

  test "new shape" do
    assert next_shape(:square, 0) == {:horizontal, horizontal(0)}
    assert next_shape(:cross, 0) == {:elle, elle(0)}
  end

  test "move left" do
    shape = horizontal(0)
    points = MapSet.new()
    assert move_left(shape, points) == [[2, 4], [3, 4], [4, 4], [5, 4]]

    assert move_left(shape, points)
           |> move_left(points) == [[1, 4], [2, 4], [3, 4], [4, 4]]

    assert move_left(shape, points)
           |> move_left(points)
           |> move_left(points) == [[1, 4], [2, 4], [3, 4], [4, 4]]

    assert move_left(shape, MapSet.new([[2, 4]])) == horizontal(0)
  end

  test "moved right" do
    shape = horizontal(0)
    points = MapSet.new()

    assert move_right(shape, points) == [[4, 4], [5, 4], [6, 4], [7, 4]]

    assert move_right(shape, points)
           |> move_right(points) == [[4, 4], [5, 4], [6, 4], [7, 4]]

    assert move_right(shape, MapSet.new([[7, 4]])) == horizontal(0)
  end

  test "move down" do
    shape = horizontal(0)
    points = MapSet.new()

    assert move_down(shape, points) == [[3, 3], [4, 3], [5, 3], [6, 3]]

    assert move_down(shape, points)
           |> move_down(points)
           |> move_down(points)
           |> move_down(points)
           |> move_down(points) == [[3, 1], [4, 1], [5, 1], [6, 1]]

    assert move_down(shape, MapSet.new([[3, 3]])) == horizontal(0)
  end

  test "square" do
    print_rocks(MapSet.new(horizontal(0)))
    print_rocks(MapSet.new(square(0)))
    print_rocks(MapSet.new(cross(0)))
    print_rocks(MapSet.new(elle(0)))
    print_rocks(MapSet.new(vertical(0)))
  end

  test "evolution" do
    n_rocks = 2022
    move_sequence = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>" |> String.graphemes()

    {occupied, heights_when_consumend} = evolution(n_rocks, move_sequence)

    differences = heights_when_consumend
    # assert differences == []
    # |> Enum.chunk_every(2, 1, :discard)
    # |> Enum.map(fn [{r1, h1}, {r2, h2}] -> {r2 - r1, h1 - h2} end)
    # |> Enum.reverse()
    chunked = chunk_increasing(differences |> Enum.reverse(), [], [])
    first = Enum.at(chunked, 2)
    assert chunked |> Enum.map(& List.last(&1)) |> Enum.map(fn {a,b,c} -> {n_rocks - a, b ,c} end) == []
    assert calculate_max_y(occupied) == 3068
  end

  test "chunk increasing" do
    assert chunk_increasing([{0, 0, 0}, {0, 0, 1}, {0, 0, 0}], [], []) == [
             [{0, 0, 1}, {0, 0, 0}],
             [{0, 0, 0}]
           ]
  end

  def chunk_increasing([], current_chunk, chunks) do
    [current_chunk | chunks] |> Enum.reverse()
  end

  def chunk_increasing([t2 | rest], [], chunks) do
    chunk_increasing(rest, [t2], chunks)
  end

  def chunk_increasing([{_, _, v1} = t1 | rest], [{_, _, v2} | _] = current_chunk, chunks)
      when v2 < v1 do
    chunk_increasing(rest, [t1 | current_chunk], chunks)
  end

  def chunk_increasing(values, current_chunk, chunks) do
    chunk_increasing(values, [], [current_chunk | chunks])
  end

  test "puzzle solution" do
    move_sequence =
      FileReader.read_all_lines("input_day17.txt") |> List.first() |> String.graphemes()

    n_rocks = 6022

    {occupied, heights_when_consumend} = evolution(n_rocks, move_sequence)

    # print_rocks(occupied)

    # assert calculate_max_y(occupied) == 3197

    differences = heights_when_consumend
    #           # |> Enum.chunk_every(2, 1, :discard)
    #           # |> Enum.map(fn [{r1, h1}, {r2, h2}] -> {r2 - r1, h1 - h2} end)
    #           # |> Enum.reverse()
    chunked = chunk_increasing(differences |> Enum.reverse(), [], [])
    assert chunked |> Enum.reverse() |> Enum.map(& Enum.slice(&1, -3..-1)) == []
    assert differences == [{1740, 2762}, {1715, 2690}, {1715, 2690}]
  end

  def print_rocks(rocks) do
    IO.puts("")
    max_y = calculate_max_y(rocks)

    max_y..0
    |> Enum.map(&print_line(&1, rocks))
    |> Enum.join("\n")
    |> IO.puts()
  end

  def print_line(line_index, rocks) do
    0..8
    |> Enum.map(&print_block([&1, line_index], rocks))
    |> Enum.join()
  end

  def print_block([0, 0], _), do: "+"
  def print_block([8, 0], _), do: "+"
  def print_block([_, 0], _), do: "_"
  def print_block([0, _], _), do: "|"
  def print_block([8, _], _), do: "|"

  def print_block(block, rocks) do
    if MapSet.member?(rocks, block) do
      "#"
    else
      "."
    end
  end

  def evolution(n_rocks, move_sequence) do
    evolution(n_rocks, move_sequence, 0, {:horizontal, horizontal(0)}, MapSet.new(), [])
  end

  def evolution(
        0,
        _,
        _,
        _,
        occupied,
        heights_when_consumend
      ),
      do: {occupied, heights_when_consumend}

  def evolution(
        n_rocks,
        move_sequence,
        current_move_index,
        {current_shape, current_shape_position},
        occupied,
        heights_when_consumend
      ) do
    next_move_index = calculate_next_move_index(move_sequence, current_move_index)
    move = Enum.at(move_sequence, current_move_index)
    shape_position_moved_horizontally = move_horizzontally(move, current_shape_position, occupied)
    shape_position = shape_position_moved_horizontally |> move_down(occupied)

    if shape_position == shape_position_moved_horizontally do
      new_occupied = MapSet.union(occupied, MapSet.new(shape_position_moved_horizontally))
      new_max_y = calculate_max_y(new_occupied)
      next_shape = next_shape(current_shape, new_max_y)

      current_max = calculate_max_y(new_occupied)
      # new_floor = Enum.filter(new_occupied, fn [x, y] -> y == current_max end)
      new_heights_when_consumend = [
        {n_rocks - 1, current_max, current_move_index} | heights_when_consumend
      ]

      evolution(
        n_rocks - 1,
        move_sequence,
        next_move_index,
        next_shape,
        new_occupied,
        new_heights_when_consumend
      )
    else
      evolution(
        n_rocks,
        move_sequence,
        next_move_index,
        {current_shape, shape_position},
        occupied,
        heights_when_consumend
      )
    end
  end

  def calculate_min_y(rock) do
    rock
    |> Enum.map(fn [_, y] -> y end)
    |> Enum.min()
  end

  def calculate_max_y(occupied) do
    if MapSet.size(occupied) == 0 do
      0
    else
      occupied
      |> Enum.map(fn [_, y] -> y end)
      |> Enum.max()
    end
  end

  def calculate_next_move_index(move_sequence, current_move_index) do
    rem(current_move_index + 1, Enum.count(move_sequence))
  end

  def move_horizzontally(move, current_shape_position, occupied) do
    case move do
      ">" -> move_right(current_shape_position, occupied)
      "<" -> move_left(current_shape_position, occupied)
    end
  end

  def move_down(shape, points) do
    moved = Enum.map(shape, fn [x, y] -> [x, y - 1] end)

    cond do
      # going in the floor
      Enum.any?(moved, fn [_, y] -> y == 0 end) -> shape
      # Any point touching a point
      Enum.any?(moved, &MapSet.member?(points, &1)) -> shape
      true -> moved
    end
  end

  def move_right(shape, points) do
    moved = Enum.map(shape, fn [x, y] -> [x + 1, y] end)

    cond do
      # going in the wall
      Enum.any?(moved, fn [x, _] -> x == 8 end) -> shape
      # Any point touching a point
      Enum.any?(moved, &MapSet.member?(points, &1)) -> shape
      true -> moved
    end
  end

  def move_left(shape, points) do
    moved = Enum.map(shape, fn [x, y] -> [x - 1, y] end)

    cond do
      # going in the wall
      Enum.any?(moved, fn [x, _] -> x == 0 end) -> shape
      # Any point touching a point
      Enum.any?(moved, &MapSet.member?(points, &1)) -> shape
      true -> moved
    end
  end

  @shapes [:horizontal, :cross, :elle, :vertical, :square]

  def next_shape(current_shape, max_y) do
    current_shape_index = Enum.find_index(@shapes, &(&1 == current_shape))
    next_shape_index = rem(current_shape_index + 1, Enum.count(@shapes))
    next_shape = Enum.at(@shapes, next_shape_index)
    {next_shape, build_next_shape(next_shape, max_y)}
  end

  def build_next_shape(next_shape, max_y) do
    case next_shape do
      :horizontal -> horizontal(max_y)
      :cross -> cross(max_y)
      :elle -> elle(max_y)
      :vertical -> vertical(max_y)
      :square -> square(max_y)
    end
  end

  def horizontal(max_y), do: Enum.map(3..6, &[&1, max_y + 4])
  def cross(max_y), do: [[4, max_y + 6], [4, max_y + 4]] ++ Enum.map(3..5, &[&1, max_y + 5])
  def elle(max_y), do: [[5, max_y + 6], [5, max_y + 5]] ++ Enum.map(3..5, &[&1, max_y + 4])
  def vertical(max_y), do: Enum.map(4..7, &[3, max_y + &1])
  def square(max_y), do: [[3, max_y + 5], [4, max_y + 5], [3, max_y + 4], [4, max_y + 4]]
end
