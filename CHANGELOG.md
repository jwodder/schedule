v0.4.0 (2023-05-03)
-------------------
- Drop support for Python 3.6
- Support Python 3.11
- Added `--start-time` and `--end-time` command-line options
  (contributed by [@bikdney](https://github.com/bikdney))

v0.3.4 (2022-02-06)
-------------------
- Support PyYAML 6.0

v0.3.3 (2021-06-12)
-------------------
- Fix error message displayed when an event is missing a "days" or "time" field

v0.3.2 (2021-05-31)
-------------------
- Drop support for Python 3.4 and 3.5
- Support Click 8

v0.3.1 (2020-01-24)
-------------------
- Adjusted the vertical positioning of text so that it no longer intersects the
  bottom of the event box
- Support Python 3.8

v0.3.0 (2019-05-09)
-------------------
- `--font` now accepts names of builtin fonts
- When an input filename is given but no output filename, write to the input
  filename with the extension set to `.pdf` instead of to stdout
- Events can now have a "color" field to set the background color

v0.2.0 (2019-04-16)
-------------------
- Support for weekend events added
- Day-of-week abbreviations in input files may no longer be lowercase
- Added a `--no-weekends` option for not showing Sunday & Saturday
- Added a `--start-monday` option for starting the week on Monday

v0.1.0 (2019-04-11)
-------------------
Initial release
