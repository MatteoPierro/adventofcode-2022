defmodule GrovePositioningSystemTest do
  use ExUnit.Case

  test "decrypt" do
    arrangment = [1, 2, -3, 3, -2, 0, 4]
    decrypted = decrypt(arrangment)

    assert decrypted == [-2, 1, 2, -3, 4, 0, 3]
  end

  test "example" do
    arrangment = [1, 2, -3, 3, -2, 0, 4]

    assert sum_of_grove_coordinates(arrangment) == 3
  end

  test "puzzle solution" do
    arrangment = FileReader.read_all_lines("input_day20.txt") |> Enum.map(&String.to_integer/1)

    assert sum_of_grove_coordinates(arrangment) == 13522
  end

  def sum_of_grove_coordinates(arrangment) do
    decrypted = decrypt(arrangment)

    zero_index = Enum.find_index(decrypted, &(&1 == 0))

    [1000, 2000, 3000]
    |> Enum.map(fn i ->
      first_value_index = rem(zero_index + i, length(decrypted))
      Enum.at(decrypted, first_value_index)
    end)
    |> Enum.sum()
  end

  def decrypt(file) do
    initial_file_index = 0..(length(file) - 1) |> Enum.to_list()

    file
    |> Enum.with_index()
    |> Enum.reduce(initial_file_index, fn {v, i}, file_index ->
      if v == 0 do
        file_index
      else
        j = Enum.find_index(file_index, &(&1 == i))
        x = Enum.at(file_index, j)
        k = rem(j + v, length(file) - 1)
        k = if k < 0, do: k - 1, else: k

        List.delete_at(file_index, j)
        |> List.insert_at(k, x)
      end
    end)
    |> Enum.map(&Enum.at(file, &1))
  end
end
