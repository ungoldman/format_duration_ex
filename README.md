# format_duration

Convert a number in milliseconds to a standard duration string. An Elixir port of [format-duration](https://github.com/ungoldman/format-duration), with the same output for every input the original handles.

## Install

Not on Hex. Add it as a git dependency:

```elixir
def deps do
  [
    {:format_duration, github: "ungoldman/format_duration_ex"}
  ]
end
```

## Usage

```elixir
FormatDuration.format(999)            # "0:00", anything under a second rounds down to zero
FormatDuration.format(1000)           # "0:01"
FormatDuration.format(1000 * 60 - 1)  # "0:59"
FormatDuration.format(1000 * 60 * 60) # "1:00:00"
FormatDuration.format(86_400_000)     # "1:00:00:00"
FormatDuration.format(-1000)          # "-0:01"
FormatDuration.format(-999)           # "0:00", no sign below a second

# `leading` zero-pads the largest unit, except days, which have no fixed width
FormatDuration.format(1000, leading: true)       # "00:01"
FormatDuration.format(86_400_000, leading: true) # "1:00:00:00"

# `ms` appends milliseconds, and shows the sign below a second
FormatDuration.format(999, ms: true)  # "0:00.999"
FormatDuration.format(-999, ms: true) # "-0:00.999"
```

Floats are truncated. A non-number, an unknown option, or a non-boolean option value raises `ArgumentError`.

## Differences from the JS version

- Unknown options and non-boolean option values raise instead of being ignored or coerced.
- Integers stay exact at any size, where JS starts rounding above 2^53.
- BEAM floats can't be `NaN` or infinite, so those inputs don't exist here.

## Tests

```sh
mix test
```

The suite ports every example from the JS tests, plus its three property tests using [StreamData](https://hexdocs.pm/stream_data).

## License

[ISC](LICENSE.md)
