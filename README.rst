.. image:: http://www.repostatus.org/badges/latest/active.svg
    :target: http://www.repostatus.org/#active
    :alt: Project Status: Active — The project has reached a stable, usable
          state and is being actively developed.

.. image:: https://img.shields.io/pypi/pyversions/pdfschedule.svg
    :target: https://pypi.org/project/pdfschedule/

.. image:: https://img.shields.io/github/license/jwodder/schedule.svg
    :target: https://opensource.org/licenses/MIT
    :alt: MIT License

.. image:: https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg
    :target: https://saythanks.io/to/jwodder

`GitHub <https://github.com/jwodder/schedule>`_
| `PyPI <https://pypi.org/project/pdfschedule/>`_
| `Issues <https://github.com/jwodder/schedule/issues>`_

``pdfschedule`` is a Python 3 script for creating PDF documents showing
one's weekly schedule of events.  Currently, only events that take place on
weekdays are recognized.


Installation
============
``pdfschedule`` requires Python 3.4 or higher.  Just use `pip
<https://pip.pypa.io>`_ for Python 3 (You have pip, right?) to install
``pdfschedule`` and its dependencies::

    python3 -m pip install pdfschedule


Usage
=====

::

    pdfschedule [<OPTIONS>] [<infile> [<outfile>]]

Input — formatted as described below under "`Input Format <input_format_>`_" —
is read from ``infile`` (or standard input if no file is specified), and the
resulting PDF is written to ``outfile`` (or standard output if no file is
specified).


Options
-------

- ``-C``, ``--color`` — Color the event boxes various colors instead of just
  grey.

- ``-F <ttf-file>``, ``--font <ttf-file>`` — Use the given ``.ttf`` file for
  the text font.  By default, all text is typeset in Helvetica.

- ``-f <size>``, ``--font-size <size>`` — Set the size of the font used for
  event information to ``size`` (default 10).  The names of the days of the
  week are typeset at ``size * 1.2``; the times of day are at ``size / 1.2``.

- ``-p``, ``--portrait`` — Typeset the table in "portrait mode," i.e., with the
  shorter side of the paper as the width.  The default is to typeset it in
  "landscape mode."

- ``-s <factor>``, ``--scale <factor>`` — Divide the length of each side of the
  table by ``factor``.  Without this option, the table fills the whole page,
  except for a one-inch margin on each side.

- ``-T``, ``--no-times`` — Do not show the times for each hour line.


.. _input_format:

Input Format
============

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


Example
=======

The following input file::

    - name: Garfield impersonation
      days: M
      time: 7-9

    - name: Work to live
      days: MTWRF
      time: 9-17

    - name: |
        Exercise class
        (The one on Main Street)
      days: W
      time: 17:00 - 18:00

    - name: Have they brought back my favorite show yet?
      days: R
      time: 19-19.30

    - name: Poor decisions
      days: F
      time: 22-23.59

produces (using the default options) an output file that looks like this:

.. image:: https://github.com/jwodder/schedule/raw/v0.1.0/examples/example01.png
