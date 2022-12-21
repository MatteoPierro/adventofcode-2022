defmodule MonkeyMathTest do
  use ExUnit.Case

  test "example" do
    monkeys = %{
      "root" => "pppw + sjmn",
      "dbpl" => "5",
      "cczh" => "sllz + lgvd",
      "zczc" => "2",
      "ptdq" => "humn - dvpt",
      "dvpt" => "3",
      "lfqf" => "4",
      "humn" => "5",
      "ljgn" => "2",
      "sjmn" => "drzm * dbpl",
      "sllz" => "4",
      "pppw" => "cczh / lfqf",
      "lgvd" => "ljgn * ptdq",
      "drzm" => "hmdt - zczc",
      "hmdt" => "32"
    }

    assert substitute("hmdt", monkeys) == "32"
    assert substitute("drzm", monkeys) == "30"
    assert substitute("sjmn", monkeys) == "150"
    assert yell_root(monkeys) == 152
  end

  test "puzzle solution" do
    monkeys =
      FileReader.read_all_lines("input_day21.txt")
      |> Enum.reduce(%{}, &parse_monkey/2)

    assert yell_root(monkeys) == 31_017_034_894_002

    root =
      Map.get(monkeys, "root")
      |> String.replace("+", "=")
      |> String.replace("-", "=")
      |> String.replace("/", "=")
      |> String.replace("*", "=")

    equation_monkeys =
      Map.put(monkeys, "humn", "x")
      |> Map.put("root", root)

    # used this result in Mathematica
    IO.puts(substitute("root", equation_monkeys))
  end

  def yell_root(monkeys) do
    {result, _} =
      substitute("root", monkeys)
      |> Code.eval_string()

    result
  end

  def substitute(name, monkeys) do
    expression = Map.get(monkeys, name)

    cond do
      expression == "x" ->
        "x"

      Regex.match?(~r/^\d+$/, expression) ->
        expression

      true ->
        [left, op, right] = String.split(expression, " ")
        left_part = substitute(left, monkeys) |> calculate()
        right_part = substitute(right, monkeys) |> calculate()
        "(#{left_part}) #{op} (#{right_part})"
        |> calculate()
    end
  end

  def calculate(expression) do
    if String.contains?(expression, "x") do
      expression
    else
      {result, _} = expression
                  |> Code.eval_string()
      "#{result}"
    end
  end

  def parse_monkey(raw_monkey, monkeys) do
    [name, sound] = String.split(raw_monkey, ": ")
    Map.put(monkeys, name, sound)
  end
end
