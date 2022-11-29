defmodule FileReader do
  def read_all_lines(filename), do:
   File.stream!("./test/input/#{filename}")
   |> Stream.map(&String.trim_trailing/1)
   |> Enum.to_list()
end
