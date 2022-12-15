defmodule BeaconExclusionZoneTest do
  use ExUnit.Case

  defmodule Sensor do
    defstruct [:position, :beacon]
  end

  test "parse sensor" do
    line = "Sensor at x=8, y=7: closest beacon is at x=2, y=10"

    sensor = parse_sensor(line)

    assert sensor.position == [8, 7]
    assert sensor.beacon == [2, 10]
  end

  test "manhattan distance" do
    assert manhattan_distance([8, 7], [2, 10]) == 9
  end

  test "points at a given level" do
    free = MapSet.new()

    target_row = 10
    sensor = [8, 7]
    beacon = [2, 10]
    distance = manhattan_distance(sensor, beacon)
    assert distance == 9

    [sx, sy] = sensor
    assert sy - distance == -2
    assert sy + distance == 16

    left = distance - abs(sy - target_row)
    assert left == 6

    sensors_and_beacons = MapSet.new([sensor, beacon])
    points = collect_point(sensor, beacon, target_row, free, sensors_and_beacons)
    # assert points == []
    # assert points |> Enum.map(& manhattan_distance(sensor, &1)) == []
    # assert collect_point(sensor, beacon, target_row, free, sensors_and_beacons) |> Enum.count() == []
  end

  test "example" do
    lines = FileReader.read_all_lines("input_day15_test.txt")

    sensors = lines |> Enum.map(&parse_sensor/1)
    target_row = 10

    # sensors_and_beacons =
    #   sensors
    #   |> Enum.reduce(MapSet.new(), fn s, acc ->
    #     MapSet.union(acc, MapSet.new([s.position, s.beacon]))
    #   end)

    # positions_without_beacons =
    #   sensors
    #   |> Enum.reduce(MapSet.new(), fn s, free ->
    #     collect_point(s.position, s.beacon, target_row, free, sensors_and_beacons)
    #   end)

    assert find_positions_without_beacons(sensors, target_row) |> Enum.count() == 26
  end

  test "puzzle solution" do
    lines = FileReader.read_all_lines("input_day15.txt")

    sensors = lines |> Enum.map(&parse_sensor/1)
    target_row = 2000000

    assert find_positions_without_beacons(sensors, target_row) |> Enum.count() == 4961647
  end

  def find_positions_without_beacons(sensors, target_row) do
    sensors_and_beacons =
      sensors
      |> Enum.reduce(MapSet.new(), fn s, acc ->
        MapSet.union(acc, MapSet.new([s.position, s.beacon]))
      end)

    sensors
    |> Enum.reduce(MapSet.new(), fn s, free ->
      collect_point(s.position, s.beacon, target_row, free, sensors_and_beacons)
    end)
  end

  def collect_point(sensor, beacon, target_row, free, sensors_and_beacons) do
    distance = manhattan_distance(sensor, beacon)
    [sx, sy] = sensor

    if abs(sy - target_row) <= distance do
      left = distance - abs(sy - target_row)

      (sx - left)..(sx + left)
      |> Enum.reduce(free, fn x, acc ->
        point = [x, target_row]

        if MapSet.member?(sensors_and_beacons, point) do
          acc
        else
          MapSet.put(acc, point)
        end
      end)
    else
      free
    end
  end

  def manhattan_distance([x1, y1], [x2, y2]), do: abs(x1 - x2) + abs(y1 - y2)

  def parse_sensor(line) do
    [senser_position, beacon_position] =
      Regex.scan(~r/x=(-?\d+), y=(-?\d+)/, line)
      |> Enum.map(fn [_, x, y] -> [String.to_integer(x), String.to_integer(y)] end)

    %Sensor{position: senser_position, beacon: beacon_position}
  end
end
