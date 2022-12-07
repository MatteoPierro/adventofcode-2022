defmodule NoSpaceLeftOnDeviceTest do
  use ExUnit.Case

  defmodule Directory do
    defstruct sub_directories: [], files: []
  end

  defmodule File do
    defstruct [:name, :size]
  end

  test "parse commands" do
    commands = [
      "$ cd /",
      "$ ls",
      "dir a",
      "14848514 b.txt",
      "$ cd a",
      "dir a",
      "29116 f",
      "$ cd a",
      "123 z"
    ]

    assert parse_commands(commands) == %{
      "/" => %Directory{sub_directories: ["/a"], files: [%File{name: "b.txt", size: 14_848_514}]},
      "/a" => %Directory{sub_directories: ["/a/a"], files: [%File{name: "f", size: 29116}]},
      "/a/a" => %Directory{sub_directories: [], files: [%File{name: "z", size: 123}]}
    }
  end

  test "test example" do
    commands = FileReader.read_all_lines("input_day7_test.txt")

    directories = parse_commands(commands)
    # assert directories["/"] == %Directory{sub_directories: ["d", "a"], files: [%File{name: "c.dat", size: 8504156}, %File{name: "b.txt", size: 14848514}]}
    # assert directories["a"] == %Directory{sub_directories: ["e"], files: [%File{name: "h.lst", size: 62596}, %File{name: "g", size: 2557}, %File{name: "f", size: 29116}]}
    # assert directories["d"] == %Directory{sub_directories: [], files: [%File{name: "k", size: 7214296}, %File{name: "d.ext", size: 5626152}, %File{name: "d.log", size: 8033020}, %File{name: "j", size: 4060174}]}
    # assert directories["e"] == %Directory{sub_directories: [], files: [%File{name: "i", size: 584}]}
    # assert Map.keys(directories) == ["/", "a", "d", "e"]

    directories_size = directories_size(Map.keys(directories), directories)
    assert directories_size == [48381165, 94853, 584, 24933642]
    assert Enum.filter(directories_size, & &1 <= 100000) |> Enum.sum() == 95437
  end

  test "solve puzzle" do
    commands = FileReader.read_all_lines("input_day7.txt")

    directories = parse_commands(commands)
    assert Map.keys(directories) |> Enum.count  == 206
    directories_size = directories_size(Map.keys(directories), directories)
    assert Enum.filter(directories_size, & &1 <= 100000) |> Enum.sum() == 1334506
  end

  def directories_size(directories_names, directories) do
    directories_names
    |> Enum.map(fn name ->
      directory = directories[name]
      sub_directories = Map.get(directory, :sub_directories)
      files = Map.get(directory, :files)
      (directories_size(sub_directories, directories) |> Enum.sum) + (Enum.map(files, & Map.get(&1,:size)) |> Enum.sum())
    end)
  end

  def parse_commands(commands, open_directories \\ [], directories \\ %{})

  def parse_commands([], _, directories), do: directories
  def parse_commands(["$ cd .." | rest], [_ | other_directories], directories), do: parse_commands(rest, other_directories, directories)
  def parse_commands(["$ ls" | rest], open_directories, directories), do: parse_commands(rest, open_directories, directories)

  def parse_commands([command | rest] = commands, open_directories, directories) do
    cond do
      String.match?(command, ~r/\$ cd/ ) -> parse_cd_command(commands, open_directories, directories)
      String.match?(command, ~r/\d+ .+/) -> parse_file(commands, open_directories, directories)
      String.match?(command, ~r/dir .+/) -> parse_directory(commands, open_directories, directories)
      true -> raise "Unknown command"
    end
  end

  def parse_directory([command | rest] = commands, [current_directory | _] = open_directories, directories) do
    [_, name] = Regex.run(~r/dir (.+)/, command)
    current_path = open_directories |> Enum.reverse() |> Enum.join("/") |> String.replace("//", "/")
    directory_path = [name | open_directories] |> Enum.reverse() |> Enum.join("/") |> String.replace("//", "/")
    directories = Map.put_new(directories, directory_path, %Directory{})
                  |> Map.update!(current_path, fn %Directory{sub_directories: sub_directories} = directory ->
                    %{directory| sub_directories: [ directory_path | sub_directories]}
                  end)
    parse_commands(rest, open_directories, directories)
  end

  def parse_file([command | rest] = commands, [current_directory | _] = open_directories, directories) do
    [_, size, name] = Regex.run(~r/(\d+) (.+)/, command)
    current_path = open_directories |> Enum.reverse() |> Enum.join("/") |> String.replace("//", "/")
    {_, directories} = Map.get_and_update(directories, current_path,
    fn %Directory{files: files} = directory ->
      {current_path, %{directory | files: [ %File{name: name, size: String.to_integer(size)} | files]}}
    end)
    parse_commands(rest, open_directories, directories)
  end

  def parse_cd_command([command | rest] = commands, open_directories, directories) do
    [_, directory] = Regex.run(~r/\$ cd (.+)/, command)
    directory_path = [directory | open_directories] |> Enum.reverse() |> Enum.join("/") |> String.replace("//", "/")
    {_, directories} = Map.get_and_update(directories, directory_path, fn value ->
      case value do
        nil -> {directory_path, %Directory{}}
        value -> {directory_path, value}
      end
    end)
    parse_commands(rest, [directory | open_directories], directories)
  end
end
