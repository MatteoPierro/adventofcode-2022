defmodule FullOfHotAirTest do
  use ExUnit.Case

  test "convert to decimal" do
    assert to_decimal("1=11-2") == 2022
    assert to_decimal("1121-1110-1=0") == 314159265
  end

  test "convert to snafu" do
    assert to_snafu(3) == "1="
    assert to_snafu(4) == "1-"
    assert to_snafu(2022) == "1=11-2"
    assert to_snafu(314159265) == "1121-1110-1=0"
  end

  test "solve puzzle" do
    result = FileReader.read_all_lines("input_day25.txt")
            |> Enum.map(& to_decimal/1)
            |> Enum.sum()
            |> to_snafu()

    assert result == "20=212=1-12=200=00-1"
  end

  def to_snafu(decimal_number) when decimal_number < 3, do: Integer.to_string(decimal_number)

  def to_snafu(decimal_number) do
    reminder = rem(decimal_number, 5)
    remaining_decimal = div(decimal_number, 5)

    if reminder < 3 do
      to_snafu(remaining_decimal) <> Integer.to_string(reminder)
    else
      symbol = if reminder == 3, do: "=", else: "-"
      to_snafu(remaining_decimal + 1) <> symbol
    end
  end

  def to_decimal(snafu_number),
    do:
      snafu_number
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.reduce(0, fn {number, position}, decimal ->
        times =
          case number do
            "=" -> -2
            "-" -> -1
            _ -> String.to_integer(number)
          end

        decimal + times * Integer.pow(5, position)
      end)
end
