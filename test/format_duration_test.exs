defmodule FormatDurationTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  doctest FormatDuration

  import FormatDuration, only: [format: 1, format: 2]

  @second 1000
  @minute @second * 60
  @hour @minute * 60
  @day @hour * 24

  describe "positive durations" do
    test "formats each unit boundary" do
      assert format(999) == "0:00"
      assert format(@second) == "0:01"
      assert format(@second * 2 - 1) == "0:01"
      assert format(@minute) == "1:00"
      assert format(@minute - 1) == "0:59"
      assert format(@hour) == "1:00:00"
      assert format(@hour - 1) == "59:59"
      assert format(@day) == "1:00:00:00"
      assert format(@day - 1) == "23:59:59"
      assert format(@day * 365) == "365:00:00:00"
    end
  end

  describe "negative durations" do
    test "sign only appears at a second or more" do
      assert format(-999) == "0:00"
      assert format(-@second) == "-0:01"
      assert format(-@second * 2 + 1) == "-0:01"
      assert format(-@minute) == "-1:00"
      assert format(-@minute + 1) == "-0:59"
      assert format(-@hour) == "-1:00:00"
      assert format(-@hour + 1) == "-59:59"
      assert format(-@day) == "-1:00:00:00"
      assert format(-@day + 1) == "-23:59:59"
      assert format(-@day * 365) == "-365:00:00:00"
    end
  end

  describe "leading: true" do
    test "pads the leading unit except days" do
      assert format(999, leading: true) == "00:00"
      assert format(@second, leading: true) == "00:01"
      assert format(@second * 2 - 1, leading: true) == "00:01"
      assert format(@minute, leading: true) == "01:00"
      assert format(@minute - 1, leading: true) == "00:59"
      assert format(@hour, leading: true) == "01:00:00"
      assert format(@hour - 1, leading: true) == "59:59"
      assert format(@day, leading: true) == "1:00:00:00"
      assert format(@day - 1, leading: true) == "23:59:59"
      assert format(@day * 365, leading: true) == "365:00:00:00"
    end
  end

  describe "leading: true, ms: true" do
    test "appends .SSS" do
      opts = [leading: true, ms: true]
      assert format(999, opts) == "00:00.999"
      assert format(@second, opts) == "00:01.000"
      assert format(@second * 2 - 1, opts) == "00:01.999"
      assert format(@minute, opts) == "01:00.000"
      assert format(@minute - 1, opts) == "00:59.999"
      assert format(@hour, opts) == "01:00:00.000"
      assert format(@hour - 1, opts) == "59:59.999"
      assert format(@day, opts) == "1:00:00:00.000"
      assert format(@day - 1, opts) == "23:59:59.999"
      assert format(@day * 365, opts) == "365:00:00:00.000"
    end
  end

  describe "negative durations, ms: true" do
    test "sign appears below a second" do
      assert format(-999, ms: true) == "-0:00.999"
      assert format(-@second, ms: true) == "-0:01.000"
      assert format(-@second * 2 + 1, ms: true) == "-0:01.999"
      assert format(-@minute, ms: true) == "-1:00.000"
      assert format(-@minute + 1, ms: true) == "-0:59.999"
      assert format(-@hour, ms: true) == "-1:00:00.000"
      assert format(-@hour + 1, ms: true) == "-59:59.999"
      assert format(-@day, ms: true) == "-1:00:00:00.000"
      assert format(-@day + 1, ms: true) == "-23:59:59.999"
      assert format(-@day * 365, ms: true) == "-365:00:00:00.000"
    end
  end

  describe "input handling" do
    test "truncates floats" do
      assert format(1500.7) == "0:01"
      assert format(-1999.9, ms: true) == "-0:01.999"
    end

    test "raises on non-numbers" do
      assert_raise ArgumentError, fn -> format("100") end
      assert_raise ArgumentError, fn -> format(nil) end
    end

    test "raises on non-boolean options" do
      assert_raise ArgumentError, fn -> format(1000, ms: "yes") end
      assert_raise ArgumentError, fn -> format(1000, leading: nil) end
      assert_raise ArgumentError, fn -> format(1000, lead: true) end
    end
  end

  describe "properties" do
    property "output always matches the duration grammar" do
      check all ms <- integer(-(@day * 1000)..(@day * 1000)),
                leading <- boolean(),
                show_ms <- boolean() do
        assert format(ms, leading: leading, ms: show_ms) =~ ~r/^-?\d+(:\d{2})*(\.\d{3})?$/
      end
    end

    property "sub-second magnitudes are never sign-prefixed without ms" do
      check all ms <- integer(-999..999),
                leading <- boolean() do
        output = format(ms, leading: leading, ms: false)
        refute String.starts_with?(output, "-")
      end
    end

    property "ms: true always ends in .SSS" do
      check all ms <- integer(-(@day * 1000)..(@day * 1000)),
                leading <- boolean() do
        assert format(ms, leading: leading, ms: true) =~ ~r/\.\d{3}$/
      end
    end
  end
end
