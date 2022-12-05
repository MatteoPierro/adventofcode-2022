defmodule SupplyStacksTest do
  use ExUnit.Case

  test "execute moves" do
    stacks = [
      ["N", "Z"],
      ["D", "C", "M"],
      ["P"]
    ]

    moves = [
      {1, 2, 1},
      {3, 1, 3},
      {2, 2, 1},
      {1, 1, 2}
    ]

    assert execute_moves(moves, stacks) == [["C"], ["M"], ["Z", "N", "D", "P"]]
    assert execute_moves(moves, stacks, &Enum.reverse(&1)) == [["M"], ["C"], ["D", "N", "Z", "P"]]
  end

  test "parse input" do
    input = [
      "    [D]    ",
      "[N] [C]    ",
      "[Z] [M] [P]",
      " 1   2   3 ",
      "",
      "move 1 from 2 to 1",
      "move 3 from 1 to 3",
      "move 2 from 2 to 1",
      "move 1 from 1 to 2"
    ]

    {stacks, moves} = parse_input(input)
    assert stacks == [["N", "Z"], ["D", "C", "M"], ["P"]]
    assert moves == [{1, 2, 1}, {3, 1, 3}, {2, 2, 1}, {1, 1, 2}]
  end

  test "solve puzzles" do
    {stacks, moves} = FileReader.read_all_lines("input_day5.txt") |> parse_input()
    word = execute_moves(moves, stacks) |> Enum.map(&List.first(&1)) |> Enum.join()

    second_word =
      execute_moves(moves, stacks, &Enum.reverse(&1)) |> Enum.map(&List.first(&1)) |> Enum.join()

    assert word == "QGTHFZBHV"
    assert second_word == "MGDMPSZTM"
  end

  def parse_input(input) do
    [raw_stack, _, raw_moves] = Enum.chunk_by(input, &(&1 == ""))
    raw_stack = List.delete_at(raw_stack, length(raw_stack) - 1)
    {parse_stacks(raw_stack), parse_moves(raw_moves)}
  end

  def parse_moves(raw_moves),
    do:
      raw_moves
      |> Enum.reduce([], fn move, moves ->
        [_, quantity, source, destination] = Regex.run(~r/move (\d+) from (\d+) to (\d+)/, move)

        [
          {String.to_integer(quantity), String.to_integer(source), String.to_integer(destination)}
          | moves
        ]
      end)
      |> Enum.reverse()

  def parse_stacks(raw_stack),
    do:
      raw_stack
      |> Enum.map(fn l ->
        l
        |> String.graphemes()
        |> Enum.chunk_every(4)
        |> Enum.map(&Enum.at(&1, 1))
      end)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(fn stack -> Enum.reject(stack, &(&1 == " ")) end)

  def execute_moves(moves, stacks, pick \\ & &1),
    do:
      moves
      |> Enum.reduce(stacks, fn move, stacks -> execute_move(move, stacks, pick) end)

  def execute_move({quantity, source, destination}, stacks, pick) do
    source_stack = Enum.at(stacks, source - 1)
    destination_stack = Enum.at(stacks, destination - 1)
    {items, source_stack} = offload(quantity, source_stack)
    destination_stack = pick.(items) ++ destination_stack

    List.replace_at(stacks, source - 1, source_stack)
    |> List.replace_at(destination - 1, destination_stack)
  end

  def offload(quantity, stack, offloaded_items \\ [])
  def offload(0, stack, items), do: {items, stack}

  def offload(quantity, [item | remaning], items),
    do: offload(quantity - 1, remaning, [item | items])
end
