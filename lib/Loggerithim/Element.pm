package Loggerithim::Element;
use strict;

=head1 NAME

Loggerithim::Element - An Element of a Chart

=head1 DESCRIPTION

An Element represents a single line on a Loggerithim Chart.  This is
usually composed of a Host, Resource, Start Span, and End Span.

=head1 SYNOPSIS

  my $e = Loggerithim::Element->new()

=cut
use DateTime::Format::Pg;

use Loggerithim::Database;
use Loggerithim::Date;
use Loggerithim::Host;
use Loggerithim::Parsers;
use Loggerithim::Resource;
use Loggerithim::ResourceGroup;

use Math::NumberCruncher;

=head1 METHODS

=head2 Constructor

=over 4

=item Loggerithim::Element->new()

Creates a new Loggerithim::Element object.

=back

=cut
sub new {
	my $proto = shift();
	my $class = ref($proto) || $proto;
	my $self = {};
	bless($self, $class);
	return $self;
}

=head2 Class Methods

=over 4

=item $e->host()

=item $e->host($host)

Set/Get the Element's Host

=cut
sub host {
	my $self = shift();
	if(@_) { $self->{HOST} = shift() }
	return $self->{HOST};
}

=item $e->resource()

=item $e->resource($res)

Set/Get the Element's Resource.

=cut
sub resource {
	my $self = shift();
	if(@_) { $self->{RESOURCE} = shift() }
	return $self->{RESOURCE};
}

=item $e->starttime()

=item $e->starttime($stime)

Set/Get the Element's Start Time

=cut
sub starttime {
	my $self = shift();
	if(@_) { $self->{STARTTIME} = shift() }
	return $self->{STARTTIME};
}

=item $e->endtime()

=item $e->endtime($etime)

Set/Get the Element's End Time

=cut
sub endtime {
	my $self = shift();
	if(@_) { $self->{ENDTIME} = shift() }
	return $self->{ENDTIME};
}

=item $e->dayBoundaries()

=item $e->dayBoundaries()

Set/Get the day boundaries during the elements span.

=cut
sub dayBoundaries {
	my $self = shift();
	if(@_) { $self->{DAYBOUNDARIES} = shift() }
	return $self->{DAYBOUNDARIES};
}

=item $e->key()

=item $e->key($key)

Set/Get the Element's Key.

=cut
sub key {
	my $self = shift();
	if(@_) { $self->{KEY} = shift() }
	return $self->{KEY};
}

=item $e->data()

=item $e->data(\@data)

Set/Get the Element's Data.  An array-ref is used.

=cut
sub data {
	my $self = shift();
	if(@_) { $self->{DATA} = shift() }
	return $self->{DATA};
}

=item $e->xlabels()

=item $e->xlabels(\@xlabels)

Set/Get the GrapElements's X Labels.  An array-ref is used.

=cut
sub xlabels {
 	my $self = shift();
	if(@_) { $self->{XLABELS} = shift() }
	return $self->{XLABELS};
}

=item $e->name()

=item $e->name($name)

Set/Get the Element's Name.

=cut
sub name {
	my $self = shift();
	if(@_) { $self->{NAME} = shift() }
	return $self->{NAME};
}

=item $e->span()

=item $e->span($span)

Set/Get the Element's Span.

=cut
sub span {
	my $self = shift();
	if(@_) { $self->{SPAN} = shift() }

	$self->{ENDTIME} = Loggerithim::Date->new();
	$self->{STARTTIME} = $self->{ENDTIME} - $self->{SPAN};

	return $self->{SPAN};
}

=item $e->stats()

=item $e->stats(\%stats)

Set/Get the Element's stats.  A hash-ref is used.

=cut
sub stats {
	my $self = shift();
	if(@_) { $self->{STATS} = shift() }
	return $self->{STATS};
}

=item $e->axis()

=item $e->axis($axis)

Set/Get the Element's axis.

=cut
sub axis {
	my $self = shift();
	if(@_) { $self->{AXIS} = shift() }
	return $self->{AXIS};
}

=item $e->annotations()

=item $e->annotations(\@annots)

Set/Get the Element's Annotations.  An array-ref is used.

=cut
sub annotations {
	my $self = shift();
	if(@_) { $self->{ANNOTATIONS} = shift() }
	return $self->{ANNOTATIONS};
}

=item $e->prepare()

=item $e->prepare($dbh)

Populates the data and name for this Element.  Requires a start and end time
or a span, a resource id, and a host id to have been set.  If a DBI database
handle is specified, it will be used, rather than creating a new one.

=cut
sub prepare {
	my $self	= shift();
	my $cache	= shift();

	my $host = $self->{HOST};
	my $resource= $self->{RESOURCE};
	my $resgroup= $resource->resgroup();

	my $table;
	if($resgroup->custom()) {
		$table = "custom_metrics";
	} else {
		$table = "metrics";
	}

	my $ref = undef;

	my $cachekey = $resgroup->id()."-".$host->id()."-".$self->{STARTTIME}->ymd()." ".$self->{STARTTIME}->hms()."-".$self->{ENDTIME}->ymd()." ".$self->{ENDTIME}->hms();
	if(defined($cache)) {
		if(exists($cache->{$cachekey})) {
			$ref = $cache->{$cachekey};
		}
	}

	if(!defined($ref)) {
		my $db = Loggerithim::Database->new();
		my $dbh = $db->connect();

		my $sth = $dbh->prepare("SELECT EXTRACT(EPOCH FROM timestamp), data FROM $table WHERE resgroupid=? AND hostid=? AND timestamp BETWEEN ? AND ? ORDER BY timestamp");
		$sth->execute($resgroup->id(), $host->id(), DateTime::Format::Pg->format_datetime($self->{STARTTIME}), DateTime::Format::Pg->format_datetime($self->{ENDTIME}));

		$ref = $sth->fetchall_arrayref();
		$cache->{$cachekey} = $ref;

		$dbh->disconnect();
	}

	my ($resarray, $timearray) = Loggerithim::Parsers->parseMetrics($ref, $resource, $self->{KEY});
	my ($max, $min) = Math::NumberCruncher::Range($resarray);
	my $avg = Math::NumberCruncher::Mean($resarray);

	$self->name($host->name()." - ".$resource->name());
	$self->data($resarray);
	$self->xlabels($timearray);

	my $endFinder = $self->starttime();
	$endFinder->subtract(minutes => $self->starttime()->minute());
	$endFinder->subtract(seconds => $self->starttime()->second());

	my @dbs;
	while($endFinder < $self->endtime()) {
		if($endFinder > $self->starttime()) {
			push(@dbs, $endFinder);
		}
		my $tillEnd = 24 - $endFinder->hour();
		my $dur = DateTime::Duration->new(hours => $tillEnd);
		$endFinder += $dur;
	}
	$self->dayBoundaries(\@dbs);

	$self->stats({
		Name	=> $self->{NAME},
		Avg	    => sprintf("%.2f", $avg),
		Count	=> $#{ $resarray } + 1,
		Max	    => $max,
		Min	    => $min
	});

	if(defined($cache)) {
		return $cache;
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
