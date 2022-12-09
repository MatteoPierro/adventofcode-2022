defmodule RopeBridgeTest do
  use ExUnit.Case

  defmodule Rope do
    defstruct head: {0, 0}, tail: {0, 0}
  end

  test "solve puzzles" do
    moves = FileReader.read_all_lines("input_day9.txt")

    assert execute_moves(moves) |> Enum.count() == 6522
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

    assert execute_moves(moves) |> Enum.count() == 13
  end

  def execute_moves(moves), do: execute_moves(moves, %Rope{}, MapSet.new([{0, 0}]))

  def execute_moves([], _, visited_tail_positions), do: visited_tail_positions

  def execute_moves([move | remaning_moves], rope, visited_tail_positions) do
    {rope, visited} = execute_move(move, rope)
    execute_moves(remaning_moves, rope, MapSet.union(visited_tail_positions, visited))
  end

  test "execute move" do
    rope = %Rope{}
    {rope, _} = execute_move("R 4", rope)
    assert rope == %Rope{head: {4, 0}, tail: {3, 0}}
    {rope, _} = execute_move("U 4", rope)
    assert rope == %Rope{head: {4, 4}, tail: {4, 3}}
    {rope, _} = execute_move("L 3", rope)
    assert rope == %Rope{head: {1, 4}, tail: {2, 4}}
    {rope, _} = execute_move("D 1", rope)
    assert rope == %Rope{head: {1, 3}, tail: {2, 4}}
    {rope, _} = execute_move("R 4", rope)
    assert rope == %Rope{head: {5, 3}, tail: {4, 3}}
    {rope, _} = execute_move("D 1", rope)
    assert rope == %Rope{head: {5, 2}, tail: {4, 3}}
    {rope, _} = execute_move("L 5", rope)
    assert rope == %Rope{head: {0, 2}, tail: {1, 2}}
    {rope, _} = execute_move("R 2", rope)
    assert rope == %Rope{head: {2, 2}, tail: {1, 2}}
  end

  def execute_move(move, rope) do
    [direction, steps] = String.split(move, " ")

    1..String.to_integer(steps)
    |> Enum.reduce({rope, MapSet.new()}, fn _, {%Rope{head: head, tail: tail}, visited} ->
      head = move(direction, head)
      tail = follow_head(head, tail)
      {%Rope{head: head, tail: tail}, MapSet.put(visited, tail)}
    end)
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

  def follow_head(same_position, same_position), do: same_position
  def follow_head({hx, hy}, {tx, ty} = tail) when hx == tx + 1 and hy == ty + 1, do: tail
  def follow_head({hx, hy}, {tx, ty} = tail) when hx == tx + 1 and hy == ty - 1, do: tail
  def follow_head({hx, hy}, {tx, ty} = tail) when hx == tx + 1 and hy == ty, do: tail
  def follow_head({hx, hy}, {tx, ty} = tail) when hx == tx and hy == ty - 1, do: tail
  def follow_head({hx, hy}, {tx, ty} = tail) when hx == tx and hy == ty + 1, do: tail
  def follow_head({hx, hy}, {tx, ty} = tail) when hx == tx - 1 and hy == ty + 1, do: tail
  def follow_head({hx, hy}, {tx, ty} = tail) when hx == tx - 1 and hy == ty, do: tail
  def follow_head({hx, hy}, {tx, ty} = tail) when hx == tx - 1 and hy == ty - 1, do: tail

  def follow_head({hx, hy}, {tx, ty}) when hx == tx + 2 and hy == ty, do: {tx + 1, ty}
  def follow_head({hx, hy}, {tx, ty}) when hx == tx - 2 and hy == ty, do: {tx - 1, ty}
  def follow_head({hx, hy}, {tx, ty}) when hx == tx and hy == ty + 2, do: {tx, ty + 1}
  def follow_head({hx, hy}, {tx, ty}) when hx == tx and hy == ty - 2, do: {tx, ty - 1}

  def follow_head({hx, hy}, {tx, ty}) when hx < tx and hy < ty, do: {tx - 1, ty - 1}
  def follow_head({hx, hy}, {tx, ty}) when hx > tx and hy < ty, do: {tx + 1, ty - 1}
  def follow_head({hx, hy}, {tx, ty}) when hx < tx and hy > ty, do: {tx - 1, ty + 1}
  def follow_head({hx, hy}, {tx, ty}) when hx > tx and hy > ty, do: {tx + 1, ty + 1}
end
