defmodule FileReader do
  def read_all_lines(filename),
    do:
      File.stream!("./test/input/#{filename}")
      |> Stream.map(&String.replace(&1, "\n", ""))
      |> Enum.to_list()
end
