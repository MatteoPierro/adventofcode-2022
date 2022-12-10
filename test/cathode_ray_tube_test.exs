defmodule CathodeRayTubeTest do
  use ExUnit.Case

  test "example" do
    instructions = FileReader.read_all_lines("input_day10_test.txt")

    assert execute(instructions) == [420, 1140, 1800, 2940, 2880, 3960]

    assert draw_lines(instructions) == [
             "##..##..##..##..##..##..##..##..##..##..",
             "###...###...###...###...###...###...###.",
             "####....####....####....####....####....",
             "#####.....#####.....#####.....#####.....",
             "######......######......######......####",
             "#######.......#######.......#######....."
           ]
  end

  test "puzzle solution" do
    instructions = FileReader.read_all_lines("input_day10.txt")

    assert execute(instructions) |> Enum.sum() == 14620

    assert draw_lines(instructions) == [
             "###....##.####.###..#..#.###..####.#..#.",
             "#..#....#.#....#..#.#..#.#..#.#....#..#.",
             "###.....#.###..#..#.####.#..#.###..#..#.",
             "#..#....#.#....###..#..#.###..#....#..#.",
             "#..#.#..#.#....#.#..#..#.#.#..#....#..#.",
             "###...##..#....#..#.#..#.#..#.#.....##.."
           ]
  end

  def draw_lines(instructions, registry_value \\ 1, current_line \\ [], lines \\ [])

  def draw_lines([], _, _, lines), do: Enum.reverse(lines) |> Enum.map(&Enum.join/1)

  def draw_lines(["noop" | others], registry_value, current_line, lines) do
    {new_current_line, new_lines} =
      draw_symbol(current_line, registry_value) |> update_lines(lines)

    draw_lines(others, registry_value, new_current_line, new_lines)
  end

  def draw_lines([instruction | others], registry_value, current_line, lines) do
    {new_current_line, new_lines} =
      1..2
      |> Enum.reduce({current_line, lines}, fn _, {new_current_line, new_lines} ->
        draw_symbol(new_current_line, registry_value) |> update_lines(new_lines)
      end)

    [_, value] = String.split(instruction, " ")
    registry_value = registry_value + String.to_integer(value)

    draw_lines(others, registry_value, new_current_line, new_lines)
  end

  def update_lines(line, lines) do
    if Enum.count(line) == 40 do
      {[], [Enum.reverse(line) | lines]}
    else
      {line, lines}
    end
  end

  def draw_symbol(current_line, registry_value) do
    if (Enum.count(current_line) + 1) in registry_value..(registry_value + 2) do
      ["#" | current_line]
    else
      ["." | current_line]
    end
  end

  def execute(instructions, registry_value \\ 1, cycle \\ 0, target \\ 20, signal_strengths \\ [])

  def execute([], _, _, _, signal_strengths), do: Enum.reverse(signal_strengths)

  def execute(["noop" | rest], registry_value, cycle, target, signal_strengths) do
    cycle = cycle + 1
    {target, signal_strengths} = check_target(cycle, registry_value, target, signal_strengths)
    execute(rest, registry_value, cycle, target, signal_strengths)
  end

  def execute([instruction | rest], registry_value, cycle, target, signal_strengths) do
    cycle = cycle + 1
    {target, signal_strengths} = check_target(cycle, registry_value, target, signal_strengths)

    cycle = cycle + 1
    {target, signal_strengths} = check_target(cycle, registry_value, target, signal_strengths)

    [_, value] = String.split(instruction, " ")
    registry_value = registry_value + String.to_integer(value)

    execute(rest, registry_value, cycle, target, signal_strengths)
  end

  def check_target(cycle, registry_value, target, signal_strengths) do
    if cycle == target do
      {target + 40, [cycle * registry_value | signal_strengths]}
    else
      {target, signal_strengths}
    end
  end
end
