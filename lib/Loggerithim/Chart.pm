package Loggerithim::Chart;
use strict;

=head1 NAME

Loggerithim::Chart - Loggerithim Graphs

=head1 DESCRIPTION

Loggerithim::Chart takes Elements and creates PNG chart.

=head1 SYNOPSIS

  my $c = Loggerithim::Char->new();
  $c->elements(\@elements);
  $c->width(800 + $totalHours);
  $c->height(500);
  $c->skip(int($totalHours / 2));
  $c->chartType("line"):
  my $png = $c->graph();

=cut

use GD;
use GD::Polyline;

use Loggerithim::Date;
use Loggerithim::Log;

use Time::HiRes qw(time);

our ($tfw, $tfh) = (gdTinyFont->width(), gdTinyFont->height());
our ($sfw, $sfh) = (gdSmallFont->width(), gdSmallFont->height());
our ($mfw, $mfh) = (gdMediumBoldFont->width(), gdMediumBoldFont->height());

# Longest y is static because the X tick format is always the
# same, MM/DD HH:MM
our $longesty = 11 * $sfw;

=head1 METHODS

=head2 Constructor

=over 4

=item Loggerithim::Chart->new()

Creates a new Loggerithim::Chart object.  Sets the width to 500, the
height to 300, and the avgLine to 1.

=back

=cut
sub new {
	my $proto = shift();
	my $class = ref($proto) || $proto;
	my $self = {};

	$self->{WIDTH}		= 500;
	$self->{HEIGHT}		= 300;
	$self->{ELEMENTS}	= [];
	$self->{DATA}		= {};
	$self->{AVG_LINE}	= 1;
	$self->{LEGEND}		= 1;
	$self->{XLABELS}	= 1;
	
	bless($self, $class);
	return $self;
}

=head2 Class Methods

=over 4

=item $c->width()

=item $c->width($width)

Set/Get the width of the chart.

=cut
sub width {
	my $self = shift();
	if(@_) { $self->{WIDTH} = shift() }
	return $self->{WIDTH};
}

=item $c->height()

=item $c->height($height)

Set/Get the height of the chart.

=cut
sub height {
	my $self = shift();
	if(@_) { $self->{HEIGHT} = shift() }
	return $self->{HEIGHT};
}

=item $c->skip()

=item $c->skip($skip)

Set/Get the number of X-ticks to skip when drawing the chart.  Not
drawing some of the X-ticks makes the graph much more readable.  The
skip value is usually set to the number of hours a graph covers divided
by 2 (and rounded down).

=cut
sub skip {
	my $self = shift();
	if(@_) { $self->{SKIP} = shift() }
	return $self->{SKIP};
}

=item $c->max()

=item $c->max($max)

Set/Get the maximum value of the graph.  This causes the graph to either crop
or stretch to this value.

=cut
sub max {
	my $self = shift();
	if(@_) { $self->{MAX} = shift() }
	return $self->{MAX};
}

=item $c->avgLine()

=item $c->avgLine($avgline)

Set/Get the flag for drawing an average line.  It true, draws a dashed line
for each element at it's average.

=cut
sub avgLine {
	my $self = shift();
	if(@_) { $self->{AVG_LINE} = shift() }
	return $self->{AVG_LINE};
}

=item $c->elements()

=item $c->elements(\@elements)

Set/Get the Elements for this Chart, uses an array-ref.

=cut
sub elements {
	my $self = shift();
	if(@_) { $self->{ELEMENTS} = shift() }
	return $self->{ELEMENTS};
}

=item $c->chartType()

=item $c->chartType($charttype)

Set/Get the type of Chart, either filled or line.

=cut
sub chartType {
	my $self = shift();
	if(@_) { $self->{CHARTTYPE} = shift() }
	return $self->{CHARTTYPE};
}

=item $c->legend()

=item $c->legend($legend)

Set/Get the legend flag.  False to _not_ draw a legend.

=cut
sub legend {
	my $self = shift();
	if(@_) { $self->{LEGEND} = shift() }
	return $self->{LEGEND};
}

=item $c->xlabels()

=item $c->xlabels($xlabels)

Set/Get the xlabels flag.  False to _not_ draw X labels.

=cut
sub xlabels {
	my $self = shift();
	if(@_) { $self->{XLABELS} = shift() }
	return $self->{XLABELS};
}

=item $c->getColor($cid)

Fetch the color associated with the supplied number.

=cut
sub getColor {
	my $self	= shift();
	my $cid		= shift();

	return $self->{COLORS}->[$cid];
}

=item $c->getAlphaColor($cid)

Fetch the alpha-color associated with the supplied number.

=cut
sub getAlphaColor {
	my $self	= shift();
	my $cid		= shift();

	return $self->{ACOLORS}->[$cid];
}

=item $c->graph()

Graph this chart

=cut
sub graph {
	my $self = shift();
	my $r = shift();

	my $s = time();

	my @elements = @{ $self->elements() };

	$self->{IMAGE}	= GD::Image->new($self->{WIDTH}, $self->{HEIGHT}, 1);
	my $col = time();
	$self->allocateColors();
	$r->log_error(sprintf("%.02f in color allocation code", time() - $col));
	$self->{IMAGE}->fill(1, 1, $self->{WHITE});

	# Variable used to selected the appropriate color from the array.
	my $ccount = 0;

	$self->findAxisStats();

	# If we have more elements than colors, expand our color space
	# by the difference.
	if($#elements > $self->colorCount()) {
		$self->expandColors($#elements - $self->colorCount());
	}

	# Get a buffer of 25 pixels.
	my $x = 25;
	my $y = 7;

	# Get 5 values for the Y axis.
	my $arse = time();
	$self->labelAxes();
	$r->log_error(sprintf("%.02f in axis label code", time() - $arse));
	
	if($self->{LEGEND}) {
		my $leg = time();
		($x, $y) = $self->drawLegend($x, $y);
		$r->log_error(sprintf("%.02f in legend code", time() - $leg));
	}

	$y += 5;

	# Set the header height.
	my $header = $y;

	# Find the top left of the data area.
	my @tl = (($x + $self->{LEFTXSHRINK}), $header);
		
    loglog("DEBUG", "($tl[0], $tl[1]) is top left of data area.");

	# Find the data width.
	my $dwidth  = $self->{WIDTH} - (($self->{RIGHTXSHRINK} + 5 + ($tfw * 5))+ $tl[0]);
    loglog("DEBUG", "$dwidth pixels width for data.");

	# Find the data height.
	my $dheight;
	if($self->{XLABELS}) {
		$dheight = ($self->{HEIGHT} - 1) - $header - 10 - ($longesty + 4);
	} else {
		$dheight = ($self->{HEIGHT} - 1) - $header - 10;
	}
	my $dbottom = $dheight + $header;

	# Draw the rectangle around the graph area.
	$self->{IMAGE}->rectangle($tl[0] , $y, ($dwidth + $tl[0]), ($dheight + $header), $self->{BLACK});
	$self->{IMAGE}->fill(($tl[0] + 1), ($y + 1), $self->{WHITE});
	my @dataBottomLeft = ($tl[0], ($dheight + $header));
	my @dataBottomRight = (($tl[0] + $dwidth), ($dheight + $header));

	my $dbcount = 0;
	my $lastdb = undef;
	my $dbxper = $dwidth / ($elements[0]->endtime()->epoch() - $elements[0]->starttime()->epoch());

	my $eek = time();
	my $dbcheck = $#{ $elements[0]->dayBoundaries() };
	if($dbcheck > -1) {
		if($dbcheck % 2) {
			$dbcount = 1;
		}
		foreach my $db (@{ $elements[0]->dayBoundaries() }) {
			if(!($dbcount % 2)) {
				if(defined($lastdb)) {
					$self->{IMAGE}->filledRectangle(
						$tl[0] + ($dbxper * ($lastdb->epoch() - $elements[0]->starttime()->epoch())),
						$tl[1],
						$tl[0] + ($dbxper * ($db->epoch() - $elements[0]->starttime()->epoch())),
						$dataBottomRight[1],
						$self->{DAYS}
					);
				} else {
					$self->{IMAGE}->filledRectangle(
						$tl[0] + 1,
						$tl[1] + 1,
						$tl[0] + ($dbxper * ($db->epoch() - $elements[0]->starttime()->epoch())),
						$dataBottomRight[1],
						$self->{DAYS}
					);
				}
			}
			$dbcount++;
			$lastdb = $db;
		}
	}
	$r->log_error(sprintf("%.02f in day boundary code", time() - $eek));

	my $acount;
	my $adxl = $tl[0] - 7;
	my $adxr = $tl[0] + $dwidth + 7;
	my $dunDrawn = 0;
	my $eep = time();
	foreach my $a (keys(%{ $self->{AXES} })) {
		my $ax = $self->{AXES}->{$a};
		$ax->{YPER} = $dheight / $ax->{MAX};
		foreach my $label (@{ $ax->{LABELS}  }) {
			my $why = ($dbottom - ($label * $ax->{YPER}));
			unless($dunDrawn) {
				$self->{IMAGE}->line(($tl[0] - 3), $why, ($dwidth + $tl[0] + 3), $why, $self->{FGAXES});
			}
			my $length = length($label) * $sfw;
			if($acount % 2) {
				$self->{IMAGE}->string(gdSmallFont, $adxr, ($why - 3), $label, $self->{BLACK});
			} else {
				$self->{IMAGE}->string(gdSmallFont, ($adxl - $length), ($why - 3), $label, $self->{BLACK});
			}
		}
		if($acount % 2) {
			$adxr += $ax->{LONGLAB} + 5;
		} else {
			$adxl -= $ax->{LONGLAB} + 5;
		}
		$dunDrawn = 1;
		$self->{AXES}->{$a} = $ax;
		$acount++;
	}
	$r->log_error(sprintf("%.02f in axis code", time() - $eep));

	# Set the starting point for graphs.

	$ccount = 0;
	my $gridflag = 0;
	my @preppedElements;

	$self->{IMAGE}->setThickness(2);

	# Iterate through all the elements.
	my $eew = time();
	foreach my $ge (@elements) {
		my $axis = $self->{AXES}->{$ge->axis()};
		my %preppedElement;
		my @data = @{ $ge->data() };
		my $xlabels = $ge->xlabels();
		my ($lastx, $lasty, $y);
        loglog("DEBUG", "Prepping Element for Host ".$ge->host()->id().", Resource ".$ge->resource()->id().".");

		# $xper is the value used to increment x for a data point.
		my $xper = $dwidth / ($ge->endtime()->epoch() - $ge->starttime()->epoch());
        loglog("DEBUG", "XPer is $xper pixels.");
		$preppedElement{'XPer'} = $xper;
		$x = $tl[0] - $xper;

		# Get the average for this element.
		my $stats = $ge->stats();
		$preppedElement{'AverageY'} = ($header + $dheight) - ($stats->{'Avg'} * $axis->{YPER});
        $preppedElement{'Average'} = sprintf("%.1f", $stats->{'Avg'});

		# Store information for annotations.
		$preppedElement{'StartTime'} = $ge->starttime();
		if($ge->annotations()) {
			$preppedElement{'Annotations'} = $ge->annotations();
		}

		my $skipper;
		if($self->skip()) {
			$skipper = $self->skip();
		} else {
			$skipper = 1;
		}

		my $valcount = 0;
		my $lastday = undef;
		my $line = GD::Polyline->new();
		for(my $i = 0; $i <= $#data; $i++) {
			my $diff = $xlabels->[$i] - $ge->starttime()->epoch();
			$x = ($tl[0] - $xper) + ($xper * $diff);
			$y = ($header + $dheight) - ($data[$i] * $axis->{YPER});

			if($lastx) {
				if(!$gridflag) {
					# Write the X labels
					unless($valcount % $skipper) {
						my $date = Loggerithim::Date->fromEpoch($xlabels->[$i]);
						my $labelstr = sprintf("%02d/%02d %02d\:%02d", $date->month(), $date->day(), $date->hour(), $date->minute());

						my $labellen = length($labelstr) * $sfw;

						$self->{IMAGE}->line($x, $tl[1], $x, ($dbottom + 3), $self->{FGAXES});
						if($self->{XLABELS}) {
							$self->{IMAGE}->stringUp(gdSmallFont, ($x - ($sfh / 2)), ($dbottom + $labellen + 5), $labelstr, $self->{BLACK});
						}
					}
				}
				$line->addPt($x, $y);
			}
			$lastx = $x;
			$lasty = $y;
			$valcount++;
		}
		$preppedElement{'Line'} = $line;
		$gridflag = 1;
		$ccount++;
		push(@preppedElements, \%preppedElement);
	}
	$r->log_error(sprintf("%.02f in poly creation / y-marker code", time() - $eew));

	my $eed = time();
	my $polyCount = 0;
	foreach my $prepe (@preppedElements) {
		if($self->{CHARTTYPE} eq "filled") {
            loglog("DEBUG", "Filled polygon.");
			my $polyline = $prepe->{'Line'};
			my $verticeCount = $polyline->vertices();
			my ($leftX, $leftY) = $polyline->getPt(0);
			my ($rightX, $rightY) = $polyline->getPt($verticeCount - 1);
            loglog("DEBUG", "Closing polygon.");
	   		$polyline->addPt($rightX, $dataBottomRight[1]);
	   		$polyline->addPt($leftX, $dataBottomLeft[1]);
	    	$polyline->addPt($leftX, $leftY);
			$self->{IMAGE}->filledPolygon($polyline, $self->getAlphaColor($polyCount));
		} else {
			my $polyline = $prepe->{'Line'};
			$self->{IMAGE}->setAntiAliased($self->getColor($polyCount));
			$self->{IMAGE}->polydraw($polyline, gdAntiAliased);
		}

		# Draw the average for this element.
		if(($self->{AVG_LINE})) {
			$self->{IMAGE}->setStyle($self->getColor($polyCount), $self->getColor($polyCount), $self->getColor($polyCount), gdTransparent, gdTransparent);
			$self->{IMAGE}->line($tl[0], $prepe->{'AverageY'}, ($tl[0] + $dwidth), $prepe->{'AverageY'}, gdStyled);
            $self->{IMAGE}->string(gdTinyFont, ($tl[0] + $dwidth + 10) - 5, ($prepe->{'AverageY'} - ($sfh / 2)), $prepe->{'Average'}, $self->getColor($polyCount));
		}

		# Draw lines and sigils for any annotations.
		foreach my $annot (@{ $prepe->{'Annotations'} }) {
            loglog("DEBUG", "Drawing annotation for ".$annot->sigil().".");
			my $stampdiff = $annot->timestamp()->epoch() - $prepe->{'StartTime'}->epoch();
			my $ecks = ($tl[0] - $prepe->{'XPer'}) + ($prepe->{'XPer'} * $stampdiff);
			my $akey = $annot->sigil()."-".$stampdiff;
			my $astr = $annot->sigil()."(".$annot->id().")";
			$self->{IMAGE}->line($ecks, $tl[1], $ecks, ($dbottom + 3), $self->{PINK});
			$self->{IMAGE}->string(gdSmallFont, (($ecks - (length($astr) * $sfw)/2)), ($tl[1] - $sfh), $astr, $self->{PINK});
		}

		$polyCount++;
	}
	$r->log_error(sprintf("%.02f in poly draw / annotation code", time() - $eed));

	my $elapsed = time() - $s;
	$r->log_error(sprintf("Charting: %.02f", $elapsed));
	return $self->{IMAGE}->png();
}

sub drawLegend {
	my $self	= shift();
	my $x		= shift();
	my $y		= shift();

	my $ccount = 0;
	# Place the names into the legend.
	my $legx = $x;
	foreach my $ge (@{ $self->elements() }) {
		my $length = length($ge->name()) * $mfw;
		if(($legx + $length) > ($self->{WIDTH} - 5)) {
			$y += 2 + $sfh;
			$legx = 25;
		}
		$self->{IMAGE}->string(gdMediumBoldFont, $legx, $y, "- ".$ge->name(), $self->getColor($ccount));
		$ccount++;
		$legx += $length + 25;
	}

	# Draw a rectangle around the legend.
	$self->{IMAGE}->rectangle(15, 3, $self->{WIDTH} - 1, ($y + 5 + $sfh), $self->{BLACK});

	# Add 5 to get a buffer under the legend, then 5 more for a
	# buffer for annotations.
	$y += 5 + $mfh + $sfh;

	return ($x, $y);
}

sub findAxisStats {
	my $self = shift();

	# Find the highest, lowest, and number of datapoints.
	foreach my $ge (@{ $self->elements() }) {
		my $stats = $ge->stats();
		my $axis = $self->{AXES}->{$ge->axis()};
		my @data = @{ $ge->data() };
		if(defined($self->{MAX})) {
			$axis->{MAX} = $self->{MAX};
			if($stats->{'Min'} < $axis->{MIN}) { $axis->{MIN} = $stats->{'Min'}; }
		} else {
			if($stats->{'Max'} > $axis->{MAX}) { $axis->{MAX} = $stats->{'Max'}; }
			if($stats->{'Min'} < $axis->{MIN}) { $axis->{MIN} = $stats->{'Min'}; }
		}
		loglog("DEBUG", "Axis '".$ge->axis()."' max=".$self->{MAX}.", min=".$self->{MIN});
		$self->{AXES}->{$ge->axis()} = $axis;
	}
}

=item $c->allocateColors()

Allocate colors for the graph

=cut
sub allocateColors() {
	my $self = shift();

	$self->{FGAXES}	= $self->{IMAGE}->colorAllocate(155, 155, 155);
	$self->{BLACK}	= $self->{IMAGE}->colorAllocate(0, 0, 0);
	$self->{WHITE}	= $self->{IMAGE}->colorAllocate(255, 255, 255);
	$self->{PINK}	= $self->{IMAGE}->colorAllocate(255, 191, 40);
	$self->{RED}	= $self->{IMAGE}->colorAllocate(255, 0, 0);
	$self->{DAYS}	= $self->{IMAGE}->colorAllocate(230, 230, 230);

	push(@{ $self->{COLORS} }, (
		$self->{IMAGE}->colorAllocate(0, 187, 0),
		$self->{IMAGE}->colorAllocate(0, 0, 255),
		$self->{IMAGE}->colorAllocate(249, 103, 30),
		$self->{RED},
		$self->{IMAGE}->colorAllocate(214, 6, 155),
		$self->{IMAGE}->colorAllocate(128, 172, 255),
		$self->{IMAGE}->colorAllocate(255, 12, 150),
		$self->{IMAGE}->colorAllocate(255, 191, 40)
	));

	push(@{ $self->{ACOLORS} }, (
		$self->{IMAGE}->colorAllocateAlpha(0, 187, 0, 85),
		$self->{IMAGE}->colorAllocateAlpha(0, 0, 255, 85),
		$self->{IMAGE}->colorAllocateAlpha(249, 103, 30, 85),
		$self->{IMAGE}->colorAllocateAlpha(255, 0, 0, 85),
		$self->{IMAGE}->colorAllocateAlpha(214, 6, 155, 85),
		$self->{IMAGE}->colorAllocateAlpha(128, 172, 255, 85),
		$self->{IMAGE}->colorAllocateAlpha(255, 12, 150, 85),
		$self->{IMAGE}->colorAllocateAlpha(255, 191, 40, 85)
	));
}

sub colorCount {
	my $self = shift();

	return $#{ $self->{COLORS} };
}

sub expandColors {
	my $self	= shift();
	my $count	= shift();

	for(my $i = 0; $i <= $count; $i++) {
		my $r = int(rand(255));
		my $g = int(rand(255));
		my $b = int(rand(255));
		push(@{ $self->{COLORS} }, $self->{IMAGE}->colorAllocate($r, $g, $b));
		push(@{ $self->{ACOLORS} }, $self->{IMAGE}->colorAllocateAlpha($r, $g, $b, 85));
	}
	loglog("DEBUG", "Expanded color space by $count with randoms.");
}

sub labelAxes {
	my $self = shift();

	my $acounter = 0;
	foreach my $a (keys(%{ $self->{AXES} })) {
		my $ax = $self->{AXES}->{$a};
		$ax->{LABELINT} = sprintf("%.2f", ($ax->{MAX} / 5));
		for(my $i = 0; $i <= 5; $i++) {
			my $label = $i * $ax->{LABELINT};
			my $length = length($label) * $sfw;
			if($length > $ax->{LONGLAB}) { $ax->{LONGLAB} = $length; }
			push(@{ $ax->{LABELS} }, $label);
		}
		loglog("DEBUG", "Calculated labels for axis.");

		if($acounter % 2) {
			$self->{RIGHTXSHRINK} += $ax->{LONGLAB} + 5;
		} else {
			$self->{LEFTXSHRINK} += $ax->{LONGLAB} + 5;		
		}

		$self->{AXES}->{$a} = $ax;

		$acounter++;
	}
}

=back

=head2 Static Methods

=over 4

NONE.

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;

