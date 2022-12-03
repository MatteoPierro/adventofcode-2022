defmodule RucksackReorganizationTest do
  use ExUnit.Case

  test "find intersection" do
    assert find_intersection("vJrwpWtwJgWrhcsFMMfFFhFp") == 'p'
    assert find_intersection("jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL") == 'L'
    assert find_intersection("PmmdzqPrVvPwwTWBwg") == 'P'
    assert find_intersection("wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn") == 'v'
    assert find_intersection("ttgJtRGJQctTZtZT") == 't'
    assert find_intersection("CrZsJsPPZsGzwwsLwLmpwMDw") == 's'
  end

  test "calculate priority" do
    assert calculate_priority('p') == 16
    assert calculate_priority('a') == 1
    assert calculate_priority('z') == 26
    assert calculate_priority('A') == 27
    assert calculate_priority('Z') == 52
  end

  test "sum of priorities" do
    rucksacks = [
      "vJrwpWtwJgWrhcsFMMfFFhFp",
      "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL",
      "PmmdzqPrVvPwwTWBwg",
      "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn",
      "ttgJtRGJQctTZtZT",
      "CrZsJsPPZsGzwwsLwLmpwMDw"
    ]

    assert sum_of_priorities(rucksacks) == 157
  end

  test "intersections in groups" do
    rucksacks = [
      "vJrwpWtwJgWrhcsFMMfFFhFp",
      "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL",
      "PmmdzqPrVvPwwTWBwg",
      "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn",
      "ttgJtRGJQctTZtZT",
      "CrZsJsPPZsGzwwsLwLmpwMDw"
    ]

    assert sum_of_priorities_in_group(rucksacks) == 70
  end

  test "puzzle solutions" do
    rucksacks = FileReader.read_all_lines("input_day3.txt")

    assert sum_of_priorities(rucksacks) == 8018
    assert sum_of_priorities_in_group(rucksacks) == 2518
  end

  def sum_of_priorities_in_group(rucksacks),
    do:
      rucksacks
      |> Enum.chunk_every(3)
      |> Enum.map(&intersection_in_group/1)
      |> Enum.map(&calculate_priority/1)
      |> Enum.sum()

  def intersection_in_group(group),
    do:
      group
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(&MapSet.new/1)
      |> Enum.reduce(&MapSet.intersection/2)
      |> Enum.to_list()
      |> List.first()
      |> to_charlist()

  def sum_of_priorities(rucksacks),
    do:
      rucksacks
      |> Enum.map(&find_intersection/1)
      |> Enum.map(&calculate_priority/1)
      |> Enum.sum()

  def calculate_priority([letter]) when letter >= ?a and letter <= ?z, do: letter - ?a + 1

  def calculate_priority([letter]), do: letter - ?A + 27

  def find_intersection(rucksack) do
    list = String.graphemes(rucksack)
    len = round(length(list) / 2)

    Enum.chunk_every(list, len)
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(& MapSet.intersection/2)
    |> Enum.to_list()
    |> List.first()
    |> to_charlist()
  end
end
