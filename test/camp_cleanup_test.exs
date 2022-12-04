defmodule CampCleanupTest do
  use ExUnit.Case

  test "parse range" do
    assert parse_ranges("2-4,6-8") == [[2, 4], [6, 8]]
  end

  test "find overlap" do
    ranges =
      [
        "2-4,6-8",
        "2-3,4-5",
        "5-7,7-9",
        "2-8,3-7",
        "6-6,4-6",
        "2-6,4-8"
      ]
      |> parse_all_ranges()

    assert count_contains(ranges) == 2
    assert count_contains(ranges, & partially_contains?/1) == 4
  end

  test "solve puzzles" do
    ranges = FileReader.read_all_lines("input_day4.txt") |> parse_all_ranges()

    assert count_contains(ranges) == 500
    assert count_contains(ranges, & partially_contains?/1) == 815
  end

  def count_contains(ranges, filter \\ &fully_contains?/1),
    do:
      ranges
      |> Enum.filter(&filter.(&1))
      |> Enum.count()

  def fully_contains?([[x1, y1], [x2, y2]]),
    do: (x1 <= x2 and y1 >= y2) or (x2 <= x1 and y2 >= y1)

  def partially_contains?([[x1, y1], [x2, y2]]), do: !Range.disjoint?(x1..y1, x2..y2)

  def parse_all_ranges(all_ranges),
    do:
      all_ranges
      |> Enum.map(&parse_ranges/1)

  def parse_ranges(ranges),
    do:
      ranges
      |> String.split(",")
      |> Enum.map(&String.split(&1, "-"))
      |> Enum.map(&Enum.map(&1, fn n -> String.to_integer(n) end))
end
