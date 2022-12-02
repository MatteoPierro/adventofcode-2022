defmodule RockPaperScissorsTest do
  use ExUnit.Case

  test "calculate score turn" do
    assert score_turn(["A", "Y"]) == 8
    assert score_turn(["B", "X"]) == 1
    assert score_turn(["C", "Z"]) == 6
  end

  test "calculate total match score" do
    turns = [
      "A Y",
      "B X",
      "C Z"
    ]

    assert match_score(turns) == 15
  end

  test "solves puzzles" do
    turns = FileReader.read_all_lines("input_day2.txt")

    assert match_score(turns) == 12535
    assert match_score(turns, &score_for/1) == 15457
  end

  def match_score(turns, calculator \\ &score_turn/1),
    do:
      turns
      |> Enum.map(&String.split(&1, " "))
      |> Enum.map(&calculator.(&1))
      |> Enum.sum()

  # Rock - Rock -> Draw
  def score_turn(["A", "X"]), do: 1 + 3
  # Rock - Paper -> Win
  def score_turn(["A", "Y"]), do: 2 + 6
  # Rock - Scissors -> Lose
  def score_turn(["A", "Z"]), do: 3 + 0

  # Paper - Rock -> Win
  def score_turn(["B", "X"]), do: 1 + 0
  # Paper - Paper -> Draw
  def score_turn(["B", "Y"]), do: 2 + 3
  # Paper - Scissors -> Lose
  def score_turn(["B", "Z"]), do: 3 + 6

  # Scissors - Rock -> Win
  def score_turn(["C", "X"]), do: 1 + 6
  # Scissors - Paper -> Draw
  def score_turn(["C", "Y"]), do: 2 + 0
  # Scissors - Scissors -> Lose
  def score_turn(["C", "Z"]), do: 3 + 3

  # Rock - need to lose
  def score_for(["A", "X"]), do: 3 + 0
  # Rock - need to draw
  def score_for(["A", "Y"]), do: 1 + 3
  # Rock - need to win
  def score_for(["A", "Z"]), do: 2 + 6

  # Paper - need to lose
  def score_for(["B", "X"]), do: 1 + 0
  # Paper - need to draw
  def score_for(["B", "Y"]), do: 2 + 3
  # Paper - need to win
  def score_for(["B", "Z"]), do: 3 + 6

  # Scissors - need to lose
  def score_for(["C", "X"]), do: 2 + 0
  # Scissors - need to draw
  def score_for(["C", "Y"]), do: 3 + 3
  # Scissors - need to win
  def score_for(["C", "Z"]), do: 1 + 6
end
