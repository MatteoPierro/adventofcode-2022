defmodule FileReaderTest do
  use ExUnit.Case

  test "reads all file lines" do
    lines = FileReader.read_all_lines("test.txt")

    assert Enum.count(lines) == 3
    assert List.first(lines) == "This is a test input"
    assert Enum.at(lines, -1) == "Almost"
  end
end
