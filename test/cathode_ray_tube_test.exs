defmodule CathodeRayTubeTest do
  use ExUnit.Case

  test "example" do
    instructions = FileReader.read_all_lines("input_day10_test.txt")

    assert execute(instructions) == [420, 1140, 1800, 2940, 2880, 3960]
  end

  test "puzzle solution" do
    instructions = FileReader.read_all_lines("input_day10.txt")

    assert execute(instructions) |> Enum.sum() == 14620
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
