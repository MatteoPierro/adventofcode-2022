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
             "/" => %Directory{
               sub_directories: ["/a"],
               files: [%File{name: "b.txt", size: 14_848_514}]
             },
             "/a" => %Directory{sub_directories: ["/a/a"], files: [%File{name: "f", size: 29116}]},
             "/a/a" => %Directory{sub_directories: [], files: [%File{name: "z", size: 123}]}
           }
  end

  test "test example" do
    commands = FileReader.read_all_lines("input_day7_test.txt")

    directories = parse_commands(commands)

    directories_size = directories_size(Map.keys(directories), directories)
    assert directories_size == [48_381_165, 94853, 584, 24_933_642]
    assert Enum.filter(directories_size, &(&1 <= 100_000)) |> Enum.sum() == 95437
    assert find_directory_to_delete_size(directories_size) == 24_933_642
  end

  test "solve puzzle" do
    commands = FileReader.read_all_lines("input_day7.txt")

    directories = parse_commands(commands)
    assert Map.keys(directories) |> Enum.count() == 206
    directories_size = directories_size(Map.keys(directories), directories)
    assert Enum.filter(directories_size, &(&1 <= 100_000)) |> Enum.sum() == 1_334_506
    assert find_directory_to_delete_size(directories_size) == 7_421_137
  end

  def find_directory_to_delete_size(sizes),
    do:
      Enum.sort(sizes)
      |> find_directory_to_delete_size(30_000_000 - (70_000_000 - Enum.max(sizes)))

  def find_directory_to_delete_size([size | _], space_to_free) when size >= space_to_free,
    do: size

  def find_directory_to_delete_size([_ | rest], space_to_free),
    do: find_directory_to_delete_size(rest, space_to_free)

  def directories_size(directories_names, directories) do
    directories_names
    |> Enum.map(fn name ->
      directory = directories[name]
      sub_directories = Map.get(directory, :sub_directories)
      files = Map.get(directory, :files)

      (directories_size(sub_directories, directories) |> Enum.sum()) +
        (Enum.map(files, &Map.get(&1, :size)) |> Enum.sum())
    end)
  end

  def parse_commands(commands, open_directories \\ [], directories \\ %{})

  def parse_commands([], _, directories), do: directories

  def parse_commands(["$ cd .." | rest], [_ | other_directories], directories),
    do: parse_commands(rest, other_directories, directories)

  def parse_commands(["$ ls" | rest], open_directories, directories),
    do: parse_commands(rest, open_directories, directories)

  def parse_commands([command | _] = commands, open_directories, directories) do
    cond do
      String.match?(command, ~r/\$ cd/) ->
        parse_cd_command(commands, open_directories, directories)

      String.match?(command, ~r/\d+ .+/) ->
        parse_file(commands, open_directories, directories)

      String.match?(command, ~r/dir .+/) ->
        parse_directory(commands, open_directories, directories)

      true ->
        raise "Unknown command"
    end
  end

  def parse_directory(
        [command | rest],
        open_directories,
        directories
      ) do
    [_, name] = Regex.run(~r/dir (.+)/, command)
    current_path = path(open_directories)
    directory_path = path([name | open_directories])

    directories =
      Map.put_new(directories, directory_path, %Directory{})
      |> Map.update!(current_path, fn %Directory{sub_directories: sub_directories} = directory ->
        %{directory | sub_directories: [directory_path | sub_directories]}
      end)

    parse_commands(rest, open_directories, directories)
  end

  def parse_file(
        [command | rest],
        open_directories,
        directories
      ) do
    [_, size, name] = Regex.run(~r/(\d+) (.+)/, command)
    current_path = path(open_directories)

    directories =
      Map.update!(directories, current_path, fn %Directory{files: files} = directory ->
        %{directory | files: [%File{name: name, size: String.to_integer(size)} | files]}
      end)

    parse_commands(rest, open_directories, directories)
  end

  def parse_cd_command([command | rest], open_directories, directories) do
    [_, directory] = Regex.run(~r/\$ cd (.+)/, command)
    directory_path = path([directory | open_directories])
    directories = Map.put_new(directories, directory_path, %Directory{})
    parse_commands(rest, [directory | open_directories], directories)
  end

  def path(directories),
    do:
      directories
      |> Enum.reverse()
      |> Enum.join("/")
      |> String.replace("//", "/")
end
