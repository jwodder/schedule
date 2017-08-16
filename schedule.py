#!/usr/bin/python3
__requires__ = ['click~=6.5', 'reportlab']
from   math                      import ceil, floor
import re
from   textwrap                  import wrap
import click
from   reportlab.lib             import pagesizes
from   reportlab.lib.units       import inch
from   reportlab.pdfbase         import pdfmetrics
from   reportlab.pdfbase.ttfonts import TTFont
from   reportlab.pdfgen.canvas   import Canvas

EM = 0.6  ### TODO: Eliminate

@click.command()
@click.option('-C', '--color', is_flag=True)
@click.option('-F', '--font')
@click.option('-f', '--font-size', type=float, default=10)
@click.option('-p', '--portrait', is_flag=True)
@click.option('-s', '--scale', type=float)
@click.option('-T', '--no-times', is_flag=True)
@click.argument('infile', type=click.File(), default='-')
@click.argument('outfile', type=click.File('wb'), default='-')
def main(infile, outfile, color, font, font_size, portrait, scale, no_times):

    if font is not None:
        font_name = 'CustomFont'
        ### Use the basename of the filename as the font name?  (Could that
        ### ever cause problems?)
        pdfmetrics.registerFont(TTFont(font_name, font))
    else:
        font_name = 'Helvetica'

    if color:
        colors = [
            (0.8, 0.8, 0.8),  # grey
            (1,   0,   0),    # red
            (0,   1,   0),    # blue
            (0,   0,   1),    # green
            (0,   1,   1),    # cyan
            (1,   1,   0),    # yellow
            (0.5, 0,   0.5),  # purple
            (1,   1,   1),    # white
            (1,   0.5, 0),    # orange
            (1,   0,   1),    # magenta
        ]
    else:
        colors = [(0.8, 0.8, 0.8)]

    if portrait:
        width, height = pagesizes.portrait(pagesizes.letter)
    else:
        width, height = pagesizes.landscape(pagesizes.letter)
    page_width = width - 2*inch
    page_height = height - 2*inch

    day_width = page_width / 5
    line_height = font_size * 1.2
    day_height = line_height * 1.2
    line_width = floor(day_width / (font_size * EM))

    classes = []
    day_start = None
    day_end = None
    for i, line in enumerate(infile):
        line = line.rstrip('\r\n').partition('#')[0]
        if not line.strip():
            continue
        days, time, *text = line.split('\t')
        text = sum((wrap(t, line_width) for t in text), [])
        m = re.match(r'^\s*(\d{1,2})(?:[:.]?(\d{2}))?\s*'
                     r'-\s*(\d{1,2})(?:[:.]?(\d{2}))?\s*$', time)
        if not m:
            click.echo('Invalid time format: ' + repr(time), err=True)
            continue
        start = int(m.group(1))
        if m.group(2) is not None:
            start += int(m.group(2))/60
        if day_start is None or start < day_start:
            day_start = start
        end = int(m.group(3))
        if m.group(4) is not None:
            end += int(m.group(4))/60
        if day_end is None or end > day_end:
            day_end = end
        classes.append((days, start, end, colors[i % len(colors)], text))
    day_start = floor(day_start) - 1
    day_end = ceil(day_end) + 1
    hour_height = page_height / (day_end - day_start)

    c = Canvas(outfile, (width, height))
    if scale is not None:
        factor = 1 / scale
        c.translate((1 - factor) * width / 2, (1 - factor) * height / 2)
        c.scale(factor, factor)

    margin = inch
    header_offset = page_height + margin - day_height

    def drawClass(txt, start_time, end_time, rgb):
        c.setStrokeColorRGB(0,0,0)
        c.setFillColorRGB(*rgb)
        c.rect(
            x,
            header_offset - ((end_time - day_start) * hour_height),
            day_width,
            (end_time - start_time) * hour_height,
            stroke=1,
            fill=1,
        )
        c.setFillColorRGB(0,0,0)
        y = header_offset \
            - (start_time - day_start) * hour_height \
            - ((end_time - start_time) * hour_height - len(txt) * line_height)/2
        for t in txt:
            y -= line_height
            c.drawCentredString(x + day_width/2, y, t)

    x = margin
    c.rect(
        x,
        page_height + margin,
        day_width * 5,
        -((day_end - day_start) * hour_height + day_height),
    )

    c.setFont(font_name, line_height)
    for day in 'Monday Tuesday Wednesday Thursday Friday'.split():
        c.drawCentredString(
            x + day_width/2, 
            page_height + margin - line_height,
            day,
        )
        x += day_width

    x = margin

    def rline(x, y, dx, dy):
        c.line(x, y, x+dx, y+dy)

    rline(x, page_height + margin - day_height, day_width * 5, 0)

    c.setDash([2], 0)
    for i in range(floor(day_start+1), ceil(day_end)):
        rline(
            x,
            header_offset - (i - day_start) * hour_height,
            day_width * 5,
            0,
        )

    c.setDash([], 0)
    for i in range(1,5):
        rline(
            x + i * day_width,
            page_height + margin,
            0,
            -(day_height + (day_end - day_start) * hour_height),
        )

    if not no_times:
        c.setFont(font_name, font_size / 1.2)
        for i in range(ceil(day_start) + 1, floor(day_end)):
            c.drawRightString(
                x - 0.2 * c.stringWidth(':00'),
                header_offset - (i - day_start) * hour_height - font_size / 2.4,
                '{}:00'.format(i),
            )

    c.setFont(font_name, font_size)
    for rgx in 'M T W [HR] F'.split():
        for _, start, end, rgb, text in \
                filter(lambda cls: re.search(rgx, cls[0], flags=re.I), classes):
            tmp_size = None
            if len(text) * line_height > (end - start) * hour_height:
                tmp_size = (end - start) * hour_height / len(text) / 1.2
                c.setFont(font_name, tmp_size)
                line_height = tmp_size * 1.2
            drawClass(text, start, end, rgb)
            if tmp_size is not None:
                c.setFont(font_name, font_size)
                line_height = font_size * 1.2
        x += day_width

    c.showPage()
    c.save()

if __name__ == '__main__':
    main()
