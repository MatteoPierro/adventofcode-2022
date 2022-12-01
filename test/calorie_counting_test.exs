defmodule CalorieCountingTest do
  use ExUnit.Case

  test "solves puzzles" do
    elves = FileReader.read_all_lines("input_day1.txt")

    calories = top_three_elves_calories(elves)

    assert 65912 == List.last(calories)
    assert 195_625 == Enum.sum(calories)
  end

  def top_three_elves_calories(elves),
    do:
      Enum.chunk_by(elves, & &1 == "")
      |> Enum.reject(&(&1 == [""]))
      |> Enum.map(&elf_total_calories/1)
      |> Enum.sort()
      |> Enum.take(-3)

  def elf_total_calories(calories),
    do:
      calories
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()
end
