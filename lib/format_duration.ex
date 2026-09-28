defmodule FormatDuration do
  @moduledoc """
  Convert a number of milliseconds to a clock-style duration string.
  """

  @type option :: {:leading, boolean()} | {:ms, boolean()}

  @doc """
  Formats `ms` milliseconds as `m:ss`, `h:mm:ss`, or `d:hh:mm:ss`.

  ## Options

    * `:leading` - zero-pad the leading unit to two digits. Days are never padded.
      Defaults to `false`.
    * `:ms` - append milliseconds as `.SSS`. Defaults to `false`.

  ## Examples

      iex> FormatDuration.format(1000)
      "0:01"

      iex> FormatDuration.format(3_600_000)
      "1:00:00"

      iex> FormatDuration.format(59_999, leading: true)
      "00:59"

      iex> FormatDuration.format(-1999, ms: true)
      "-0:01.999"

  """
  @spec format(number(), [option]) :: String.t()
  def format(ms, opts \\ [])

  def format(ms, opts) when is_number(ms) do
    opts = Keyword.validate!(opts, leading: false, ms: false)

    for {key, value} <- opts, not is_boolean(value) do
      raise ArgumentError, "expected a boolean for #{inspect(key)}, got: #{inspect(value)}"
    end

    leading = opts[:leading]
    show_ms = opts[:ms]
    t = ms |> abs() |> trunc() |> parse()
    output = sign(ms, show_ms) <> render(t, leading)

    if show_ms, do: output <> "." <> pad(t.ms, 3), else: output
  end

  def format(ms, _opts) do
    raise ArgumentError, "expected a number, got: #{inspect(ms)}"
  end

  defp parse(ms) do
    seconds = div(ms, 1000)
    ms = rem(ms, 1000)
    minutes = div(seconds, 60)
    seconds = rem(seconds, 60)
    hours = div(minutes, 60)
    minutes = rem(minutes, 60)
    days = div(hours, 24)
    hours = rem(hours, 24)

    %{days: days, hours: hours, minutes: minutes, seconds: seconds, ms: ms}
  end

  defp render(%{days: d, hours: h, minutes: m, seconds: s}, _leading) when d > 0 do
    "#{d}:#{pad(h)}:#{pad(m)}:#{pad(s)}"
  end

  defp render(%{days: 0, hours: h, minutes: m, seconds: s}, leading) when h > 0 do
    "#{lead(h, leading)}:#{pad(m)}:#{pad(s)}"
  end

  defp render(%{days: 0, hours: 0, minutes: m, seconds: s}, leading) do
    "#{lead(m, leading)}:#{pad(s)}"
  end

  defp lead(n, true), do: pad(n)
  defp lead(n, false), do: Integer.to_string(n)

  defp sign(ms, true) when ms < 0, do: "-"
  defp sign(ms, false) when ms <= -1000, do: "-"
  defp sign(_ms, _show_ms), do: ""

  defp pad(n, digits \\ 2), do: n |> Integer.to_string() |> String.pad_leading(digits, "0")
end
