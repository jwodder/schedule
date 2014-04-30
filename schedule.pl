#!/usr/bin/perl -w
# To do:
# - Improve the color palette
# - Add support for weekend events
# - Fix "squeezing" of overly long text so that the last line doesn't touch the
#   bottom of the box
# - Add support for 12-hour times
# - Rewrite `drawClass' so that it takes the font size as an argument and sets
#   it & the line height, thereby simplifying "squeezing" a bit
# - Handle textless entries
# - Allow literal hash marks to appear in text lines
# - Add an -F option for setting the font?
use strict;
use Getopt::Std;
use POSIX qw(floor ceil);

my @colors = ('0.8 0.8 0.8');
my $em = 0.6;
# $em = the em value to font size ratio.  In PostScript (for Monaco & Courier,
# at least), this appears to be approximately 0.6.

my %opts;
getopts('Cf:pSs:T', \%opts) || exit 2;
@colors = (
 '0.8 0.8 0.8',  # grey
 '1 0 0',  # red
 '0 1 0',  # blue
 '0 0 1',  # green
 '0 1 1',  # cyan
 '1 1 0',  # yellow
 '0.5 0 0.5',  # purple
 '1 1 1',  # white
 '1 0.5 0',  # orange
 '1 0 1',  # magenta
) if $opts{C};

my($pageWidth, $pageHeight) = $opts{p} ? (6.5*72, 9*72) : (9*72, 6.5*72);
my $dayWidth = $pageWidth / 5;
my $fontSize = $opts{f} || 10;
my $lineHeight = $fontSize * 1.2;
my $dayHeight = $lineHeight * 1.2;
my $lineWidth = floor($dayWidth / ($fontSize * $em));

my($in, $out) = (*STDIN, *STDOUT);
my $infile = shift || '-';
my $outfile = shift || '-';
open $in, '<', $infile or die "$0: $infile: $!" unless $infile eq '-';
open $out, '>', $outfile or die "$0: $outfile: $!" unless $outfile eq '-';
select $out;

my @classes;
my($dayStart, $dayEnd);

$/ = '' if !$opts{S};
while (<$in>) {
 chomp;
 s/^\#.*$ \n//gmx;
 s/#.*$//gm;
 next if /^\s*$/;
 my($days, $time, @text) = split /[\n\t]/;
 @text = map { wrapLine($_, $lineWidth) } @text;
 $time =~ /^\s*(\d{1,2})(?:[:.]?(\d{2}))?\s*-\s*(\d{1,2})(?:[:.]?(\d{2}))?\s*$/
  or do {print STDERR "$0: item $.: invalid time format\n"; next; };
 my $start = $1;
 $start += $2/60 if $2;
 $dayStart = $start if !defined($dayStart) || $start < $dayStart;
 my $end = $3;
 $end += $4/60 if $4;
 $dayEnd = $end if !defined($dayEnd) || $end > $dayEnd;
 push @classes, [ $days, $start, $end, $colors[$. % @colors], @text ];
}
$dayStart = floor($dayStart) - 1;
$dayEnd = ceil($dayEnd) + 1;
my $hourHeight = $pageHeight / ($dayEnd - $dayStart);

print "%!PS-Adobe-3.0\n";
print "0 792 translate -90 rotate\n" if !$opts{p};
if ($opts{s}) {
 print "/factor 1 $opts{s} div def ";
 printf "1 factor sub %g mul 2 div 1 factor sub %g mul 2 div translate ",
  $opts{p} ? (8.5*72, 11*72) : (11*72, 8.5*72);
 print "factor dup scale\n" if $opts{s};
}
print <<EOT;
/baseFont /Monaco findfont def

/dayWidth $dayWidth def
/hourHeight $hourHeight def
/lineHeight $lineHeight def
/dayHeight $dayHeight def

/margin 72 def
/headerOffset $pageHeight margin add dayHeight sub def

/dayStart $dayStart def
/dayEnd $dayEnd def

/drawClass { % arguments: array of strings, start time, end time, R G B
 setrgbcolor
 /endTime exch def
 /startTime exch def
 [x headerOffset endTime dayStart sub hourHeight mul sub dayWidth endTime startTime sub hourHeight mul] dup
 rectfill
 0 0 0 setrgbcolor rectstroke
 dup length lineHeight mul endTime startTime sub hourHeight mul exch sub 2 div headerOffset startTime dayStart sub hourHeight mul sub exch sub /y exch def
 {
  /y y lineHeight sub def
  dup stringwidth pop dayWidth exch sub 2 div x add y moveto show
 } forall
} def

/x margin def
x $pageHeight margin add dayWidth 5 mul dayEnd dayStart sub hourHeight mul dayHeight add neg rectstroke

baseFont lineHeight scalefont setfont
[(Monday) (Tuesday) (Wednesday) (Thursday) (Friday)] {
 dup stringwidth pop dayWidth exch sub 2 div x add $pageHeight margin add lineHeight sub moveto show
 /x x dayWidth add def
} forall

/x margin def
x $pageHeight margin add dayHeight sub moveto dayWidth 5 mul 0 rlineto stroke
[2] 0 setdash
dayStart 1 add floor 1 dayEnd 1 sub ceiling {
 x exch dayStart sub hourHeight mul headerOffset exch sub moveto
 dayWidth 5 mul 0 rlineto
 stroke
} for
[] 0 setdash
1 1 4 {
 dayWidth mul x add $pageHeight margin add moveto
 0 dayHeight dayEnd dayStart sub hourHeight mul add neg rlineto
 stroke
} for
EOT

print <<EOTIMES if !$opts{T};
baseFont $fontSize 1.2 div scalefont setfont
/str 3 string def
dayStart ceiling 1 add 1 dayEnd floor 1 sub {
 dup x exch dayStart sub hourHeight mul headerOffset exch sub moveto
 (:00) dup stringwidth pop dup -1.2 mul $fontSize -2.4 div rmoveto exch show
 neg 0 rmoveto
 str cvs dup stringwidth pop neg 0 rmoveto show
} for
EOTIMES

print "baseFont $fontSize scalefont setfont\n";

foreach my $regex (qw< M T W [HR] F >) {
 foreach (grep { $_->[0] =~ /$regex/i } @classes) {
  my @text = @$_[4..$#$_];
  my $tmpSize;
  if (@text * $lineHeight > ($_->[2] - $_->[1]) * $hourHeight) {
   $tmpSize = ($_->[2] - $_->[1]) * $hourHeight / @text / 1.2;
   print "baseFont $tmpSize scalefont setfont\n";
   print "/lineHeight $tmpSize 1.2 mul def\n";
  }
  print '[(', join(') (', @text), ')] ', $_->[1], ' ', $_->[2], ' ', $_->[3],
   " drawClass\n";
  if (defined $tmpSize) {
   print "baseFont $fontSize scalefont setfont\n";
   print "/lineHeight $lineHeight def\n";
  }
 }
 print "/x x dayWidth add def\n";
}

print "showpage\n";

sub wrapLine {
 my $str = shift;
 my $len = shift || 80;
 $str =~ s/\s+$//;
 my @lines = ();
 while (length $str > $len) {
  if (reverse(substr $str, 0, $len) =~ /\s+/) {
   push @lines, substr $str, 0, $len - $+[0], ''
  } else { push @lines, substr $str, 0, $len, '' }
  $str =~ s/^\s+//;
 }
 s/([()\\])/\\$1/g foreach @lines, $str;
 return (@lines, $str);
}

__END__

=pod

=head1 NAME

B<schedule> - format class schedules

=head1 SYNOPSIS

B<schedule> [B<-CpST>] [B<-f> I<size>] [B<-s> I<factor>] [I<infile> [I<outfile>]]

=head1 DESCRIPTION

B<Schedule> is a L<perl(1)> script for creating charts in PostScript showing
one's weekly schedule, usually for classes or the like.  Currently, only events
that take place on weekdays are recognized.

Input -- which must be formatted as described below under L</"INPUT FILES"> --
is read from I<infile> (or standard input if no file is specified), and the
resulting output is written to I<outfile> (or standard output if no file is
specified).

=head1 OPTIONS

=over

=item B<-C>

Color the class boxes various colors instead of just grey.

=item B<-f> I<size>

Set the size of the font used for class information to I<size> (default 10).
The names of the days of the week are typeset at I<size> * 1.2; the times of
day are at I<size> / 1.2.

=item B<-p>

Typeset the table in "portrait mode," i.e., with the shorter side of the paper
as the width.  The default is to typeset it in "landscape mode."

=item B<-S>

Interpret each line of input as a separate entry rather than separating entries
by blank lines.

=item B<-s> I<factor>

Divide the length of each side of the table by I<factor>.  Without this option,
the table fills the whole page, except for a 1 in. margin on each side.

=item B<-T>

Do not show the times for each hour line.

=back

=head1 INPUT FILES

Each entry in the input file consists of three or more fields of text separated
by tabs and/or newlines, and each entry is terminated by one or (if the B<-S>
option was not given) more newlines.  Any text from a C<#> to the end of a line
is ignored.  The first field in each entry consists of a set of letters which
indicate on which days the class is held:

    M - Monday
    T - Tuesday
    W - Wednesday
    R or H - Thursday
    F - Friday

These letters may be in any order & case.  Any characters outside this set are
ignored.

The second field of each entry specifies the time of day at which the class is
held.  Times are specified in 24-hour format, the minutes being optional (and
optionally preceded by a colon or period), and the beginning & ending times are
separated by a hyphen.  This is the only part of the entry for which the format
matters; if the field is not formatted correctly, B<schedule> prints an error
message and moves on to the next entry.

The remaining fields of an entry consist of user-defined text which will be
printed in separate lines in the class's box on the schedule.  Long lines will
be broken at whitespace, and if a box contains more lines than can fit, the
font size will be scaled down until they do.

=head1 AUTHOR

John T. Wodder II <jwodder@sdf.lonestar.org>

=cut
