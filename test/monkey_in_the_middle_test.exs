defmodule MonkeyintheMiddleTest do
  use ExUnit.Case

  defmodule Monkey do
    defstruct [:items, :operation, :find_destination, :inspected_items]
  end

  test "parse monkeys" do
    lines = FileReader.read_all_lines("input_day11_test.txt")

    monkeys = parse_monkeys(lines)

    third_monkey = Enum.at(monkeys, 2)
    assert third_monkey.items == [79, 60, 97]
    assert third_monkey.operation.(2) == 4
    assert third_monkey.find_destination.(13) == 1
  end

  test "inspect_monkey_items" do
    monkeys = FileReader.read_all_lines("input_day11_test.txt") |> parse_monkeys()

    monkeys = inspect_monkey_items(Enum.at(monkeys, 0), 0, monkeys, & div(&1, 3))

    assert Enum.at(monkeys, 0).items == []
    assert Enum.at(monkeys, 3).items == [74, 500, 620]
  end

  test "monkeys_round" do
    monkeys = FileReader.read_all_lines("input_day11_test.txt") |> parse_monkeys()

    monkeys =
      1..20 |> Enum.reduce(monkeys, fn _, current_monkeys -> monkeys_round(current_monkeys) end)

    assert Enum.at(monkeys, 0).items == [10, 12, 14, 26, 34]
    assert Enum.at(monkeys, 1).items == [245, 93, 53, 199, 115]
    assert Enum.at(monkeys, 2).items == []
    assert Enum.at(monkeys, 3).items == []

    inspected_items = Enum.map(monkeys, & &1.inspected_items)
    assert inspected_items == [101, 95, 7, 105]

    sorted_inspected_items = inspected_items |> Enum.sort()

    assert Enum.at(sorted_inspected_items, -1) * Enum.at(sorted_inspected_items, -2) == 10605
  end

  test "puzzle solution" do
    monkeys = FileReader.read_all_lines("input_day11.txt") |> parse_monkeys()

    monkeys =
      1..20 |> Enum.reduce(monkeys, fn _, current_monkeys -> monkeys_round(current_monkeys) end)

    sorted_inspected_items = Enum.map(monkeys, & &1.inspected_items) |> Enum.sort()
    assert Enum.at(sorted_inspected_items, -1) * Enum.at(sorted_inspected_items, -2) == 98280
  end

  def monkeys_round(monkeys, worry_reducer \\ & div(&1, 3)) do
    0..(Enum.count(monkeys) - 1)
    |> Enum.reduce(monkeys, fn monkey_index, current_monkeys ->
      inspect_monkey_items(Enum.at(current_monkeys, monkey_index), monkey_index, current_monkeys, worry_reducer)
    end)
  end

  def inspect_monkey_items(monkey, _, monkeys, _) when monkey.items == [], do: monkeys

  def inspect_monkey_items(monkey, monkey_index, monkeys, worry_reducer) do
    [first_item | rest] = monkey.items
    worrey_level = monkey.operation.(first_item) |> worry_reducer.()
    updated_monkey = %{monkey | items: rest, inspected_items: monkey.inspected_items + 1}
    destination_monkey_index = monkey.find_destination.(worrey_level)
    destination_monkey = Enum.at(monkeys, destination_monkey_index)

    updated_monkeys =
      List.replace_at(monkeys, monkey_index, updated_monkey)
      |> List.replace_at(destination_monkey_index, %{
        destination_monkey
        | items: destination_monkey.items ++ [worrey_level]
      })

    inspect_monkey_items(updated_monkey, monkey_index, updated_monkeys, worry_reducer)
  end

  def parse_monkeys(lines) do
    lines
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(&(&1 == [""]))
    |> Enum.map(&parse_monkey/1)
  end

  def parse_monkey(raw_monkey) do
    items =
      Enum.at(raw_monkey, 1)
      |> String.split(": ")
      |> Enum.at(1)
      |> String.split(", ")
      |> Enum.map(&String.to_integer/1)

    operation =
      Enum.at(raw_monkey, 2)
      |> String.split(": ")
      |> Enum.at(1)
      |> parse_operation

    find_destination = parse_find_destination(raw_monkey)

    %Monkey{
      items: items,
      operation: operation,
      find_destination: find_destination,
      inspected_items: 0
    }
  end

  def parse_find_destination(raw_monkey) do
    divisible_number =
      Enum.at(raw_monkey, 3)
      |> String.split(" by ")
      |> Enum.at(1)
      |> String.to_integer()

    positive_destination =
      Enum.at(raw_monkey, 4)
      |> String.split(" to monkey ")
      |> Enum.at(1)
      |> String.to_integer()

    nagative_destination =
      Enum.at(raw_monkey, 5)
      |> String.split(" to monkey ")
      |> Enum.at(1)
      |> String.to_integer()

    fn worry_level ->
      if rem(worry_level, divisible_number) == 0,
        do: positive_destination,
        else: nagative_destination
    end
  end

  def parse_operation("new = old * old"), do: fn old -> old * old end

  def parse_operation(operation) do
    cond do
      String.starts_with?(operation, "new = old * ") ->
        number = String.split(operation, " * ") |> Enum.at(1) |> String.to_integer()
        fn old -> old * number end

      String.starts_with?(operation, "new = old + ") ->
        number = String.split(operation, " + ") |> Enum.at(1) |> String.to_integer()
        fn old -> old + number end
    end
  end
end
