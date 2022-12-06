defmodule TuningTroubleTest do
  use ExUnit.Case

  test "find marker position" do
    assert find_marker_position("bvwbjplbgvbhsrlpgdmjqwftvncz") == 5
    assert find_marker_position("nppdvjthqldpwncqszvftbrmjlhg") == 6
    assert find_marker_position("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") == 10
    assert find_marker_position("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") == 11
    assert find_marker_position("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") == 11
  end

  test "solve puzzles" do
    datagram = FileReader.read_all_lines("input_day6.txt") |> List.first()

    assert find_marker_position(datagram) == 1598
    assert find_marker_position(datagram, 14) == 2414
  end

  def find_marker_position(datastram, window \\ 4),
    do:
      datastram
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.chunk_every(window, 1, :discard)
      |> find_position

  def find_position([sequence | rest]) do
    if unique_symbols(sequence) |> MapSet.size() == Enum.count(sequence) do
      {_, p} = List.last(sequence)
      p + 1
    else
      find_position(rest)
    end
  end

  def unique_symbols(sequence), do: Enum.map(sequence, fn {s, _} -> s end) |> MapSet.new()
end
