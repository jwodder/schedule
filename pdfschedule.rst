NAME
^^^^

:program:`pdfschedule` — Typeset a weekly schedule

SYNOPSIS
^^^^^^^^

.. code-block:: shell

    pdfschedule [<OPTIONS>] [<infile> [<outfile>]]

DESCRIPTION
^^^^^^^^^^^

:program:`pdfschedule` is a Python 3 script for creating PDF documents showing
one's weekly schedule of events.  Currently, only events that take place on
weekdays are recognized.

Input — formatted as described below under :ref:`input_format` — is read from
``infile`` (or standard input if no file is specified), and the resulting
output is written to ``outfile`` (or standard output if no file is specified).

OPTIONS
^^^^^^^

.. option:: -C, --color

    Color the event boxes various colors instead of just grey.

.. option:: -F <ttf-file>, --font <ttf-file>

    Use the given ``.ttf`` file for the text font.  By default, all text is
    typeset in Helvetica.

.. option:: -f <size>, --font-size <size>

    Set the size of the font used for event information to ``size`` (default
    10).  The names of the days of the week are typeset at ``size * 1.2``; the
    times of day are at ``size / 1.2``.

.. option:: -p, --portrait

    Typeset the table in "portrait mode," i.e., with the shorter side of the
    paper as the width.  The default is to typeset it in "landscape mode."

.. option:: -s <factor>, --scale <factor>

    Divide the length of each side of the table by ``factor``.  Without this
    option, the table fills the whole page, except for a one-inch margin on
    each side.

.. option:: -T, --no-times

    Do not show the times for each hour line.

.. _input_format:

INPUT FORMAT
^^^^^^^^^^^^

Input is a `YAML <http://yaml.org>`_ list of dictionaries.  Each dictionary
represents a single weekly event and must contain the following keys:

``name``
   *(optional)* The (possibly multiline) text to display in the event's box on
   the schedule

``days``
   The days of the week on which the event occurs, specified as a string of one
   or more of the following single-letter codes:

   ======  =========
   Letter  Day
   ======  =========
   M       Monday
   T       Tuesday
   W       Wednesday
   H or R  Thursday
   F       Friday
   ======  =========

   These letters may be in any order & case.  Characters outside this set are
   ignored.

``time``
   The start & end times of the event in the format ``HH:MM - HH:MM``.  Times
   are specified in 24-hour format, the minutes being optional (and optionally
   separated from the hour by a colon or period).

AUTHOR
^^^^^^

John T. Wodder II <pdfschedule@varonathe.org>
