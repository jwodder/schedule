- Add support for weekend events
- Support events that end at 00:00
- Handle events that go past midnight

- Input format:
    - Support an optional "color" field in event input dicts
    - Change the input format to a YAML dict of which the list of event dicts
      is one field, the others being font, font size, min & max times, etc.?
    - Add support for 12-hour times
    - Support "24:00" in input to mean "00:00"

- Output tweaks:
    - Improve the color palette
    - Handle the day headers being too wide for their columns
    - Fix "squeezing" of overly long text so that the last line doesn't touch
      the bottom of the box
    - Handle textless entries

- Command-line usage:
    - Support specifying builtin fonts with `--font` (The available builtin
      fonts can be listed with `Canvas(*).getAvailableFonts()`)
    - Make the page size and margins configurable
    - Support specifying the minimum & maximum times to draw
    - When an input filename is given but no output filename, write to the
      input filename with the extension set to `.pdf` instead of to stdout

- Library usage:
    - Allow configuring the fonts & font sizes used for the event texts, day
      headers, and times separately?
    - Change `Schedule` to a `reportlab.*.Flowable` subclass (or factory
      thereof?)

- Documentation:
    - Write a README
    - Add a link to the repository to the documentation
    - Add docstrings
    - Include example input in docs

- Release on PyPI
