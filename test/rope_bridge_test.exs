defmodule RopeBridgeTest do
  use ExUnit.Case

  defmodule Rope do
    defstruct knots: [{0, 0}, {0, 0}]
  end

  def new_rope(number_of_knots \\ 2) do
    knots = for _ <- 1..number_of_knots, do: {0, 0}
    rope = %Rope{knots: knots}
  end

  test "solve puzzles" do
    moves = FileReader.read_all_lines("input_day9.txt")

    assert count_tails_positions(moves) == 6522
    assert count_tails_positions(moves, new_rope(10)) == 2717
  end

  test "execute moves" do
    moves = [
      "R 4",
      "U 4",
      "L 3",
      "D 1",
      "R 4",
      "D 1",
      "L 5",
      "R 2"
    ]

    assert count_tails_positions(moves) == 13

    assert count_tails_positions(moves, new_rope(10)) == 1

    moves = [
      "R 5",
      "U 8",
      "L 8",
      "D 3",
      "R 17",
      "D 10",
      "L 25",
      "U 20"
    ]
    assert count_tails_positions(moves, new_rope(10)) == 36
  end

  def count_tails_positions(moves, rope \\ %Rope{}), do: execute_moves(moves, rope) |> Enum.count()

  def execute_moves(moves, rope), do: execute_moves(moves, rope, MapSet.new([{0, 0}]))

  def execute_moves([], _, visited_tail_positions), do: visited_tail_positions

  def execute_moves([move | remaning_moves], rope, visited_tail_positions) do
    {rope, visited} = execute_move(move, rope)
    execute_moves(remaning_moves, rope, MapSet.union(visited_tail_positions, visited))
  end

  describe "execute move" do
    test "rope with two knots" do
      rope = %Rope{}
      {rope, _} = execute_move("R 4", rope)
      assert rope == %Rope{knots: [{4, 0}, {3, 0}]}
      {rope, _} = execute_move("U 4", rope)
      assert rope == %Rope{knots: [{4, 4}, {4, 3}]}
      {rope, _} = execute_move("L 3", rope)
      assert rope == %Rope{knots: [{1, 4}, {2, 4}]}
      {rope, _} = execute_move("D 1", rope)
      assert rope == %Rope{knots: [{1, 3}, {2, 4}]}
      {rope, _} = execute_move("R 4", rope)
      assert rope == %Rope{knots: [{5, 3}, {4, 3}]}
      {rope, _} = execute_move("D 1", rope)
      assert rope == %Rope{knots: [{5, 2}, {4, 3}]}
      {rope, _} = execute_move("L 5", rope)
      assert rope == %Rope{knots: [{0, 2}, {1, 2}]}
      {rope, _} = execute_move("R 2", rope)
      assert rope == %Rope{knots: [{2, 2}, {1, 2}]}
    end

    test "rope with 10 knots" do
      rope = new_rope(10)
      {rope, _} = execute_move("R 4", rope)
      assert rope.knots == [{4, 0}, {3, 0}, {2, 0}, {1, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
      {rope, _} = execute_move("U 4", rope)
      assert rope.knots == [{4, 4}, {4, 3}, {4, 2}, {3, 2}, {2, 2}, {1, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
      {rope, _} = execute_move("L 3", rope)
      assert rope.knots == [{1, 4}, {2, 4}, {3, 3}, {3, 2}, {2, 2}, {1, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
      {rope, _} = execute_move("D 1", rope)
      assert rope.knots == [{1, 3}, {2, 4}, {3, 3}, {3, 2}, {2, 2}, {1, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
      {rope, _} = execute_move("R 4", rope)
      assert rope.knots == [{5, 3}, {4, 3}, {3, 3}, {3, 2}, {2, 2}, {1, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
      {rope, _} = execute_move("D 1", rope)
      assert rope.knots == [{5, 2}, {4, 3}, {3, 3}, {3, 2}, {2, 2}, {1, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
      {rope, _} = execute_move("L 5", rope)
      assert rope.knots == [{0, 2}, {1, 2}, {2, 2}, {3, 2}, {2, 2}, {1, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
      {rope, _} = execute_move("R 2", rope)
      assert rope.knots == [{2, 2}, {1, 2}, {2, 2}, {3, 2}, {2, 2}, {1, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
    end

    test "second example of a rope with 10 knots" do
      rope = new_rope(10)
      {rope, _} = execute_move("R 5", rope)
      assert rope.knots == [{5, 0}, {4, 0}, {3, 0}, {2, 0}, {1, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
      {rope, _} = execute_move("U 8", rope)
      assert rope.knots == [{5, 8}, {5, 7}, {5, 6}, {5, 5}, {5, 4}, {4, 4}, {3, 3}, {2, 2}, {1, 1}, {0, 0}]
      {rope, _} = execute_move("L 8", rope)
      assert rope.knots == [{-3, 8}, {-2, 8}, {-1, 8}, {0, 8}, {1, 8}, {1, 7}, {1, 6}, {1, 5}, {1, 4}, {1, 3}]
      {rope, _} = execute_move("D 3", rope)
      assert rope.knots == [{-3, 5}, {-3, 6}, {-2, 7}, {-1, 7}, {0, 7}, {1, 7}, {1, 6}, {1, 5}, {1, 4}, {1, 3}]
      {rope, _} = execute_move("R 17", rope)
      assert rope.knots == [{14, 5}, {13, 5}, {12, 5}, {11, 5}, {10, 5}, {9, 5}, {8, 5}, {7, 5}, {6, 5}, {5, 5}]
      {rope, _} = execute_move("D 10", rope)
      assert rope.knots == [{14, -5}, {14, -4}, {14, -3}, {14, -2}, {14, -1}, {14, 0}, {13, 0}, {12, 0}, {11, 0}, {10, 0}]
      {rope, _} = execute_move("L 25", rope)
      assert rope.knots == [{-11, -5}, {-10, -5}, {-9, -5}, {-8, -5}, {-7, -5}, {-6, -5}, {-5, -5}, {-4, -5}, {-3, -5}, {-2, -5}]
      {rope, _} = execute_move("U 20", rope)
      assert rope.knots == [{-11, 15}, {-11, 14}, {-11, 13}, {-11, 12}, {-11, 11}, {-11, 10}, {-11, 9}, {-11, 8}, {-11, 7}, {-11, 6}]
    end
  end

  def execute_move(move, rope) do
    [direction, steps] = String.split(move, " ")

    1..String.to_integer(steps)
    |> Enum.reduce({rope, MapSet.new()}, fn _, {%Rope{knots: knots}, visited} ->
      [head | others] = knots
      head = move(direction, head)
      knots = follow(others, [head])
      {%Rope{knots: knots}, MapSet.put(visited, List.last(knots))}
    end)
  end

  def follow([], moved_knots), do: moved_knots |> Enum.reverse()

  def follow([tail | rem], [head | _] = moved_knots) do
    tail = follow_head(head, tail)
    follow(rem, [tail | moved_knots])
  end

  test "move" do
    assert move("D", {0, 0}) == {0, -1}
    assert move("U", {0, 0}) == {0, 1}
    assert move("L", {0, 0}) == {-1, 0}
    assert move("R", {0, 0}) == {1, 0}
  end

  def move("D", {x, y}), do: {x, y - 1}
  def move("U", {x, y}), do: {x, y + 1}
  def move("L", {x, y}), do: {x - 1, y}
  def move("R", {x, y}), do: {x + 1, y}

  describe "follow head" do
    test "when tail should not move" do
      assert follow_head({1, 1}, {1, 1}) == {1, 1}
      assert follow_head({2, 2}, {1, 1}) == {1, 1}
      assert follow_head({2, 1}, {1, 1}) == {1, 1}
      assert follow_head({2, 0}, {1, 1}) == {1, 1}
      assert follow_head({1, 0}, {1, 1}) == {1, 1}
      assert follow_head({1, 2}, {1, 1}) == {1, 1}
      assert follow_head({0, 2}, {1, 1}) == {1, 1}
      assert follow_head({0, 1}, {1, 1}) == {1, 1}
      assert follow_head({0, 0}, {1, 1}) == {1, 1}
    end

    test "when tail should move" do
      assert follow_head({3, 1}, {1, 1}) == {2, 1}
      assert follow_head({-1, 1}, {1, 1}) == {0, 1}
      assert follow_head({1, 3}, {1, 1}) == {1, 2}
      assert follow_head({1, -1}, {1, 1}) == {1, 0}

      assert follow_head({-1, 0}, {1, 1}) == {0, 0}
      assert follow_head({3, 0}, {1, 1}) == {2, 0}
      assert follow_head({-1, 2}, {1, 1}) == {0, 2}
      assert follow_head({3, 2}, {1, 1}) == {2, 2}

      assert follow_head({0, -1}, {1, 1}) == {0, 0}
      assert follow_head({-1, 0}, {1, 1}) == {0, 0}
      assert follow_head({0, 3}, {1, 1}) == {0, 2}
      assert follow_head({2, -1}, {1, 1}) == {2, 0}
      assert follow_head({2, 3}, {1, 1}) == {2, 2}
    end
  end

  def follow_head({hx, hy}, {tx, hy}) when hx != tx do
    x = if hx > tx, do: hx - 1, else: hx + 1
    {x, hy}
  end

  def follow_head({hx, hy}, {hx, ty}) when hy != ty do
    y = if hy > ty, do: hy - 1, else: hy + 1
    {hx, y}
  end

  def follow_head({hx, hy}, {tx, ty}) when abs(hy - ty) > 1 or abs(hx - tx) > 1 do
    x = if hx > tx, do: tx + 1, else: tx - 1
    y = if hy > ty, do: ty + 1, else: ty - 1
    {x, y}
  end

  def follow_head(_, tail), do: tail
end
