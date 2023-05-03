.. image:: http://www.repostatus.org/badges/latest/active.svg
    :target: http://www.repostatus.org/#active
    :alt: Project Status: Active — The project has reached a stable, usable
          state and is being actively developed.

.. image:: https://img.shields.io/pypi/pyversions/pdfschedule.svg
    :target: https://pypi.org/project/pdfschedule/

.. image:: https://img.shields.io/github/license/jwodder/schedule.svg
    :target: https://opensource.org/licenses/MIT
    :alt: MIT License

`GitHub <https://github.com/jwodder/schedule>`_
| `PyPI <https://pypi.org/project/pdfschedule/>`_
| `Issues <https://github.com/jwodder/schedule/issues>`_
| `Changelog <https://github.com/jwodder/schedule/blob/master/CHANGELOG.md>`_

``pdfschedule`` is a Python 3 script for creating PDF documents showing
one's weekly schedule of events.


Installation
============
``pdfschedule`` requires Python 3.7 or higher.  Just use `pip
<https://pip.pypa.io>`_ for Python 3 (You have pip, right?) to install
``pdfschedule`` and its dependencies::

    python3 -m pip install pdfschedule


Usage
=====

::

    pdfschedule [<OPTIONS>] [<infile> [<outfile>]]

Input — formatted as described below under "`Input Format`_" — is read from
``<infile>`` (defaulting to standard input), and the resulting PDF is written
to ``<outfile>`` (defaulting to ``<infile>`` with its file extension changed to
``.pdf``, or to standard output if ``<infile>`` is standard input).


Options
-------

-C, --color             Color the event boxes various colors instead of just
                        grey.

-E TIME, --end-time TIME
                        Specify the time of day at which each day should start.
                        Times are specified in the format ``HH:MM`` using
                        24-hour time, the minutes being optional (and
                        optionally separated from the hour by a colon or
                        period).  Defaults to half an hour before the earliest
                        event start time or 00:00, whichever is later.

-F FONT, --font FONT    Typeset text in the given font.  ``FONT`` must be
                        either the name of a builtin PostScript font or the
                        path to a ``.ttf`` file.  By default, text is typeset
                        in Helvetica.

-f SIZE, --font-size SIZE
                        Set the size of the font used for event information to
                        ``SIZE`` (default 10).  The names of the days of the
                        week are typeset at ``SIZE * 1.2``; the times of day
                        are typeset at ``SIZE / 1.2``.

-M, --start-monday      Use Monday as the first day of the week instead of
                        Sunday.

-p, --portrait          Typeset the table in "portrait mode," i.e., with the
                        shorter side of the paper as the width.  The default is
                        to typeset it in "landscape mode."

-s FACTOR, --scale FACTOR
                        Divide the length of each side of the table by
                        ``FACTOR``.  Without this option, the table fills the
                        whole page, except for a one-inch margin on each side.

-S TIME, --start-time TIME
                        Specify the time of day at which each day should end.
                        Times are specified in the format ``HH:MM`` using
                        24-hour time, the minutes being optional (and
                        optionally separated from the hour by a colon or
                        period).  Defaults to half an hour after the latest
                        event end time or 24:00, whichever is earlier.

-T, --no-times          Do not show the times for each hour line.

--no-weekends           Do not show Sunday and Saturday.


Input Format
============

Input is a `YAML <http://yaml.org>`_ list of dictionaries.  Each dictionary
represents a single weekly event and must contain the following keys:

``name``
   *(optional)* The (possibly multiline) text to display in the event's box on
   the schedule

``days``
   The days of the week on which the event occurs, specified as a string of one
   or more of the following abbreviations in any order (optionally with
   intervening whitespace and/or commas):

   ===================================  =========
   Abbreviation                         Day
   ===================================  =========
   ``Su`` or ``Sun``                    Sunday
   ``M`` or ``Mo`` or ``Mon``           Monday
   ``T`` or ``Tu`` or ``Tue``           Tuesday
   ``W`` or ``We`` or ``Wed``           Wednesday
   ``H`` or ``R`` or ``Th`` or ``Thu``  Thursday
   ``F`` or ``Fr`` or ``Fri``           Friday
   ``Sa`` or ``Sat``                    Saturday
   ===================================  =========

   Case is significant.  Unknown abbreviations are ignored.

``time``
   The start & end times of the event in the format ``HH:MM - HH:MM``.  Times
   are specified in 24-hour format, the minutes being optional (and optionally
   separated from the hour by a colon or period).

``color``
   *(optional)* The background color of the event's box, given as six
   hexadecimal digits.  The default background color is either grey or, if
   ``--color`` is in effect, taken from a small palette of basic colors based
   on the event's index.


Example
=======

The following input file:

.. code:: yaml

    - name: Garfield impersonation
      days: M
      time: 7-9
      color: "FFB04E"

    - name: Work to live
      days: MTWRF
      time: 9-17

    - name: |
        Exercise class
        (The one on Main Street)
      days: M, W, F
      time: 17:00 - 18:00
      color: "29FF65"

    - name: Have they brought back my favorite show yet?
      days: R
      time: 19-19.30
      color: "FF84DF"

    - name: Poor decisions
      days: F
      time: 22-23.59
      color: "000000"

    - name: Sleep in
      days: SatSun
      time: 7-12
      color: "4226C4"

produces (using the default options) an output file that looks like this:

.. image:: https://github.com/jwodder/schedule/raw/v0.4.0/examples/example01.png
