defmodule NotEnoughMineralsTest do
  use ExUnit.Case

  defmodule Cost do
    defstruct [:ore, clay: 0, obsidian: 0, geodes: 0]
  end

  defmodule Blueprint do
    defstruct [:id, :ore_robots, :clay_robots, :obsidian_robots, :geodes_robots]
  end

  defmodule Factory do
    defstruct ore_robots: 1,
              clay_robots: 0,
              obsidian_robots: 0,
              geodes_robots: 0,
              ore: 0,
              clay: 0,
              obsidian: 0,
              geodes: 0
  end

  test "example" do
    blueprints = [
      %Blueprint{
        id: 1,
        ore_robots: %Cost{ore: 4},
        clay_robots: %Cost{ore: 2},
        obsidian_robots: %Cost{ore: 3, clay: 14},
        geodes_robots: %Cost{ore: 2, obsidian: 7}
      },
      %Blueprint{
        id: 2,
        ore_robots: %Cost{ore: 2},
        clay_robots: %Cost{ore: 3},
        obsidian_robots: %Cost{ore: 3, clay: 8},
        geodes_robots: %Cost{ore: 3, obsidian: 12}
      }
    ]

    quality_level =
      blueprints
      |> Enum.map(fn blueprint ->
        blueprint.id * find_best_geodes([{24, %Factory{}}], MapSet.new(), blueprint, -1)
      end)
      |> Enum.sum()

    assert quality_level == 33

    assert find_best_geodes([{32, %Factory{}}], MapSet.new(), Enum.at(blueprints, 1), -1) == -1
  end

  test "puzzle solution" do
    blueprints = FileReader.read_all_lines("input_day19.txt") |> Enum.map(&parse_blueprint/1)

    quality_level =
      blueprints
      |> Enum.map(fn blueprint ->
        blueprint.id * find_best_geodes([{24, %Factory{}}], MapSet.new(), blueprint, -1)
      end)
      |> Enum.sum()

    assert quality_level == 1266

    result =
      Enum.slice(blueprints, 0..2)
      |> Enum.map(fn blueprint ->
        IO.puts("blueprint #{blueprint.id}")
        find_best_geodes([{32, %Factory{}}], MapSet.new(), blueprint, -1)
      end)
      |> Enum.reduce(&Kernel.*/2)

    assert result == 5800
  end

  def find_best_geodes([], _, _, current_max) do
    current_max
  end

  def find_best_geodes(
        [{minutes, current_factory} = current | rest],
        seen,
        blueprint,
        current_max
      ) do
    cond do
      MapSet.member?(seen, current) ->
        find_best_geodes(rest, seen, blueprint, current_max)

      minutes == 0 ->
        find_best_geodes(
          rest,
          MapSet.put(seen, current),
          blueprint,
          max(current_max, current_factory.geodes)
        )

      true ->
        new_factories =
          build_factories(blueprint, current_factory) |> Enum.map(&{minutes - 1, &1})

        find_best_geodes(rest ++ new_factories, MapSet.put(seen, current), blueprint, current_max)
    end
  end

  def build_factories(bp, current) do
    [
      build_nothing(bp, current),
      build_geodes(bp, current),
      build_obsidian(bp, current),
      build_clay(bp, current),
      build_ore(bp, current)
    ]
    |> Enum.reduce(&Kernel.++/2)
  end

  def build_geodes(bp, current) do
    if build_geodes?(bp, current) do
      [
        %{
          current
          | geodes_robots: current.geodes_robots + 1,
            ore: current.ore - bp.geodes_robots.ore + current.ore_robots,
            obsidian: current.obsidian - bp.geodes_robots.obsidian + current.obsidian_robots,
            clay: current.clay + current.clay_robots,
            geodes: current.geodes + current.geodes_robots
        }
      ]
    else
      []
    end
  end

  def build_geodes?(bp, current),
    do: current.ore >= bp.geodes_robots.ore and current.obsidian >= bp.geodes_robots.obsidian

  def build_obsidian(bp, current) do
    if build_obsidian?(bp, current) do
      [
        %{
          current
          | obsidian_robots: current.obsidian_robots + 1,
            ore: current.ore - bp.obsidian_robots.ore + current.ore_robots,
            obsidian: current.obsidian + current.obsidian_robots,
            clay: current.clay - bp.obsidian_robots.clay + current.clay_robots,
            geodes: current.geodes + current.geodes_robots
        }
      ]
    else
      []
    end
  end

  def build_obsidian?(bp, current) do
    not build_geodes?(bp, current) and current.obsidian_robots < bp.geodes_robots.obsidian and
      (current.ore >= bp.obsidian_robots.ore && current.clay >= bp.obsidian_robots.clay)
  end

  def build_clay(bp, current) do
    if build_clay?(bp, current) do
      [
        %{
          current
          | clay_robots: current.clay_robots + 1,
            ore: current.ore - bp.clay_robots.ore + current.ore_robots,
            obsidian: current.obsidian + current.obsidian_robots,
            clay: current.clay + current.clay_robots,
            geodes: current.geodes + current.geodes_robots
        }
      ]
    else
      []
    end
  end

  def build_clay?(bp, current) do
    if build_geodes?(bp, current) or build_obsidian?(bp, current) do
      false
    else
      current.clay_robots < bp.obsidian_robots.clay and current.ore >= bp.clay_robots.ore
    end
  end

  def build_ore(bp, current) do
    if build_ore?(bp, current) do
      [
        %{
          current
          | ore_robots: current.ore_robots + 1,
            ore: current.ore - bp.ore_robots.ore + current.ore_robots,
            obsidian: current.obsidian + current.obsidian_robots,
            clay: current.clay + current.clay_robots,
            geodes: current.geodes + current.geodes_robots
        }
      ]
    else
      []
    end
  end

  def build_ore?(bp, current) do
    if build_geodes?(bp, current) or build_obsidian?(bp, current) do
      false
    else
      max_ore = Enum.max([bp.obsidian_robots.ore, bp.clay_robots.ore, bp.geodes_robots.ore])
      current.ore_robots < max_ore and current.ore >= bp.ore_robots.ore
    end
  end

  def build_nothing(bp, current) do
    if build_nothing?(bp, current) do
      [
        %{
          current
          | ore: current.ore + current.ore_robots,
            obsidian: current.obsidian + current.obsidian_robots,
            clay: current.clay + current.clay_robots,
            geodes: current.geodes + current.geodes_robots
        }
      ]
    else
      []
    end
  end

  def build_nothing?(bp, current) do
    if build_geodes?(bp, current) do
      false
    else
      max_ore = Enum.max([bp.obsidian_robots.ore, bp.clay_robots.ore, bp.geodes_robots.ore])
      current.ore < 2 * max_ore and current.clay < 3 * bp.obsidian_robots.clay
    end
  end

  def parse_blueprint(raw_blueprint) do
    values =
      Regex.scan(~r/(\d+)/, raw_blueprint) |> Enum.map(fn [_, v] -> String.to_integer(v) end)

    %Blueprint{
      id: Enum.at(values, 0),
      ore_robots: %Cost{ore: Enum.at(values, 1)},
      clay_robots: %Cost{ore: Enum.at(values, 2)},
      obsidian_robots: %Cost{ore: Enum.at(values, 3), clay: Enum.at(values, 4)},
      geodes_robots: %Cost{ore: Enum.at(values, 5), obsidian: Enum.at(values, 6)}
    }
  end
end
