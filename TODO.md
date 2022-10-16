- Support events that end at 00:00
- Handle events that go past midnight
- Use pydantic to parse the input?
- Test parsing input

- Input format:
    - Change the input format to a YAML dict of which the list of event dicts
      is one field, the others being font, font size, min & max times, etc.?
    - Add support for 12-hour times
    - Support "24:00" in input to mean "00:00"

- Output tweaks:
    - Improve the color palette
    - Handle the day headers being too wide for their columns
    - Handle textless entries

- Command-line usage:
    - Make the page size and margins configurable
    - Support specifying the minimum & maximum times to draw

- Library usage:
    - Allow configuring the fonts & font sizes used for the event texts, day
      headers, and times separately?
    - Change `Schedule` to a `reportlab.*.Flowable` subclass (or factory
      thereof?)
    - Add a function that takes loaded YAML data, renders a schedule, and
      returns a `Canvas` object?  Saves a `Canvas` object to a given path?

- Documentation:
    - Add more docstrings
    - Come up with a better example schedule
