defmodule DistressSignalTest do
  use ExUnit.Case

  test "right order" do
    assert order_validation([1, 1, 3, 1, 1], [1, 1, 5, 1, 1]) == :valid
    assert order_validation([[1], [2, 3, 4]], [[1], 4]) == :valid
    assert order_validation([9], [[8, 7, 6]]) == :invalid
    assert order_validation([[4, 4], 4, 4], [[4, 4], 4, 4, 4]) == :valid
    assert order_validation([7, 7, 7, 7], [7, 7, 7]) == :invalid
    assert order_validation([], [3]) == :valid
    assert order_validation([[[]]], [[]]) == :invalid

    assert order_validation([1, [2, [3, [4, [5, 6, 7]]]], 8, 9], [
             1,
             [2, [3, [4, [5, 6, 0]]]],
             8,
             9
           ]) == :invalid
  end

  test "parse packets pairs" do
    raw_packets_pairs = FileReader.read_all_lines("input_day13_test.txt")

    packets_pairs = parse_packets_pairs(raw_packets_pairs)

    assert Enum.at(packets_pairs, 0) == [[1, 1, 3, 1, 1], [1, 1, 5, 1, 1]]
    assert Enum.at(packets_pairs, -2) == [[[[]]], [[]]]

    assert Enum.at(packets_pairs, -1) == [
             [1, [2, [3, [4, [5, 6, 7]]]], 8, 9],
             [1, [2, [3, [4, [5, 6, 0]]]], 8, 9]
           ]
  end

  test "find pairs in right order" do
    raw_packets_pairs = FileReader.read_all_lines("input_day13_test.txt")

    packets_pairs = parse_packets_pairs(raw_packets_pairs)

    assert sum_of_indices_of_pairs_in_right_order(packets_pairs) == 13
  end

  test "puzzle solution" do
    raw_packets_pairs = FileReader.read_all_lines("input_day13.txt")

    packets_pairs = parse_packets_pairs(raw_packets_pairs)

    assert sum_of_indices_of_pairs_in_right_order(packets_pairs) == 5605
  end

  def sum_of_indices_of_pairs_in_right_order(packets_pairs),
    do:
      packets_pairs
      |> Enum.with_index()
      |> Enum.filter(fn {[first, second], _} -> order_validation(first, second) == :valid end)
      |> Enum.map(fn {_, index} -> index + 1 end)
      |> Enum.sum()

  def parse_packets_pairs(raw_packets_pairs),
    do:
      raw_packets_pairs
      |> Enum.chunk_by(&(&1 == ""))
      |> Enum.reject(&(&1 == [""]))
      |> Enum.map(&parse_packets_pair/1)

  def parse_packets_pair(raw_packets_pair), do: Enum.map(raw_packets_pair, &parse_packet/1)

  def parse_packet(raw_packet) do
    {packet, _} = Code.eval_string(raw_packet)
    packet
  end

  def order_validation([], []), do: :continue
  def order_validation([], _), do: :valid
  def order_validation(_, []), do: :invalid

  def order_validation([a | other_first], [b | other_second])
      when is_integer(a) and is_integer(b) do
    cond do
      a < b -> :valid
      a == b -> order_validation(other_first, other_second)
      true -> :invalid
    end
  end

  def order_validation([a | other_first], second) when is_integer(a) do
    order_validation([[a] | other_first], second)
  end

  def order_validation(first, [b | other_second]) when is_integer(b) do
    order_validation(first, [[b] | other_second])
  end

  def order_validation([a | other_first], [b | other_second]) do
    case order_validation(a, b) do
      :continue -> order_validation(other_first, other_second)
      x -> x
    end
  end
end
