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

  test "example" do
    lines = FileReader.read_all_lines("input_day15_test.txt")

    sensors = lines |> Enum.map(&parse_sensor/1)

    assert find_positions_without_beacons(sensors, 10) |> Enum.count() == 26

    max_y = 20
    assert find_distress_beacon(sensors, max_y) == {14, 11}
  end

  test "puzzle solution" do
    lines = FileReader.read_all_lines("input_day15.txt")

    sensors = lines |> Enum.map(&parse_sensor/1)
    target_row = 2_000_000

    assert find_positions_without_beacons(sensors, target_row) |> Enum.count() == 4_961_647

    max_y = 4_000_000
    assert find_distress_beacon(sensors, max_y) == {3_068_581, 3_017_867}
    assert 3_068_581 * 4_000_000 + 3_017_867 == 12_274_327_017_867
  end

  def find_distress_beacon(sensors, max_y, row \\ 0)
  def find_distress_beacon(_, max_y, max_y), do: raise("ERROR")

  def find_distress_beacon(sensors, max_y, row) do
    range = find_range(sensors, row, max_y)

    if Enum.count(range) == 1 do
      find_distress_beacon(sensors, max_y, row + 1)
    else
      [%Range{last: x}, _] = range
      {x + 1, row}
    end
  end

  def find_range(sensors, row, max_y) do
    sensor_viewing_row =
      sensors
      |> Enum.reject(fn s ->
        distance = manhattan_distance(s.position, s.beacon)
        [_, sy] = s.position
        abs(sy - row) > distance
      end)

    ranges =
      sensor_viewing_row
      |> Enum.map(fn s ->
        distance = manhattan_distance(s.position, s.beacon)
        [sx, sy] = s.position
        left = distance - abs(sy - row)
        max(sx - left, 0)..min(sx + left, max_y)
      end)

    join_ranges(ranges)
  end

  def join_ranges([_] = ranges), do: ranges

  def join_ranges([%Range{first: fx, last: fy} = first | others]) do
    joint =
      others
      |> Enum.find(fn %Range{first: rx, last: ty} = r ->
        Range.disjoint?(first, r) == false || max(fx, rx) == min(fy, ty) + 1
      end)

    case joint do
      nil ->
        [first | join_ranges(others)]

      %Range{first: rx, last: ty} = r ->
        [min(fx, rx)..max(ty, fy) | List.delete(others, r)]
        |> join_ranges()
    end
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
