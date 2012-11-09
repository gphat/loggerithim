package Loggerithim::Metric;
use strict;

=head1 NAME

Loggerithim::Metric - Host Metric

=head1 DESCRIPTION

A point of data from a Host for a specified ResourceGroup at a specific point in time.

=head1 SYNOPSIS

  my $m = Loggerithim::Metric->create(
    resgroup  => $resgroup,
    data      => $data,
    timestamp => $time,
    cache     => 'yes',
    host      => $hostid,
  );
  $m->commit();

=cut
use DateTime::Format::Pg;

use Loggerithim::Cache;
use Loggerithim::Config;
use Loggerithim::Database;
use Loggerithim::Date;
use Loggerithim::Processors;
use Loggerithim::ResourceGroup;

=head1 METHODS

=head2 Constructor

=over 4

=item Loggerithim::Metric->create()

Creates a new Loggerithim::Metric object.  This constructor accepts parameters:

my $m = Loggerithim::Metric->create(
    resgroup   => $someresgroup,
    timestamp  => $time,
    data       => $data,
    cache      => 'yes',
    cacheonly  => 'no',
    host       => $host,
    process    => 'yes',
);

Writes the Metric into the database.  Requires that resgroupid, time, data, and
hostid have been set.  If a database handle is passed, that database handle
will be used.  This facilitates batch insertion in a single transaction.
Otherwise a new database handle will be created.

=back

=cut
sub create {
	my $proto = shift();
	my $class = ref($proto) || $proto;
	my $self = {};
	my $params = shift();

	$self->{RESGROUP}	= $params->{resgroup};
	$self->{TIME}		= $params->{timestamp};
	$self->{DATA}		= $params->{data};
	$self->{CACHE}		= $params->{cache};
	$self->{CACHEONLY}	= $params->{cacheonly};
	$self->{HOST}		= $params->{host};
	$self->{PROCESS}	= $params->{process};
	my $dbh				= $params->{handle};

    if(!$dbh) {
        my $db = Loggerithim::Database->new();
        $dbh = $db->connect();
	}

	# Put the attributes in sane variables
	my $rg		 = $self->{RESGROUP};
	my $time	 = $self->{TIME};
	my $data	 = $self->{DATA};
	my $cache    = $self->{CACHE};
	my $cacheonly= $self->{CACHEONLY};
	my $host	 = $self->{HOST};
	my $process	 = $self->{PROCESS};

	# The result variable will hold the stuff that actually gets
	# UPDATEd or INSERTed into the table.  It is here because we
	# process raw data for some metrics, but not for others.  More
	# on this later.
	my $result;

	# Sentinel set if this metric already had a cached value or if
	# the data does not need to be processed.
	my $cachedok;

	my $procref;

	# If the process attribute is set, we are being given raw numbers.
	# It is then our job to take this data, subtract the last raw
	# numbers, and put the result in... result ;)
	my $rawtype;
	if($process) {
		$rawtype = Loggerithim::ResourceGroup->search(name => "raw".$rg->name())->next();
		my $procsth = $dbh->prepare("SELECT metricid, data, timestamp FROM cached_metrics WHERE resgroupid=? AND hostid=?");
		$procsth->execute($rawtype->id(), $host->id());
		$procref = $procsth->fetchrow_arrayref();
		if($procref->[0]) {
			$cachedok = 1;
			my $method = "processRaw".$rg->name();
			$result = Loggerithim::Processors->$method($procref->[1], DateTime::Format::Pg->parse_timestamp($procref->[2]), $data, $time);
		} else {
			# Yes, this is unecessary, but it's hard to follow without this.
			$cachedok = 0;
		}
	} else {
		# Else, just put data in result (this was discussed earlier)
		$cachedok = 1;
		$result = $data;
	}

	# If the CacheOnly attribute is NOT set, insert the data into the
	# Metrics table.  This is the important step, as it actually allows
	# us to graph the data.
	if(!($cacheonly) and ($cachedok)) {
		my $mettable = "metrics";
		if($rg->custom()) {
			$mettable = "custom_metrics";
		}
		my $sth = $dbh->prepare("INSERT INTO $mettable (resgroupid, data, timestamp, hostid) VALUES (?, ?, ?, ?)");
		$sth->execute($rg->id(), $result, DateTime::Format::Pg->format_timestamp($time), $host->id());
	}

	# If the Cache attribute is set, check the Cached table for an
	# existing Cache record.  If it exists, update the record.  If it
	# does not exist, add one.
	if($cache) {
		my $checksth = $dbh->prepare("SELECT metricid FROM cached_metrics WHERE resgroupid=? AND hostid=?");
		$checksth->execute($rg->id(), $host->id());
		my $test = $checksth->fetchrow_arrayref();
		if(defined($test->[0])) {
			# If we processed the data, store the raw version.
			# We could do a check, like we did above, but if a
			# processed metric exists, the raw one will too.
			if($process) {
				my $rawupdatesth = $dbh->prepare("UPDATE cached_metrics SET data=?, timestamp=? WHERE hostid=? AND resgroupid=?");
				$rawupdatesth->execute($data, DateTime::Format::Pg->format_timestamp($time), $host->id(), $rawtype->id());
			}
			my $updatesth = $dbh->prepare("UPDATE cached_metrics SET data=?, timestamp=? WHERE metricid=?");
			$updatesth->execute($result, DateTime::Format::Pg->format_timestamp($time), $test->[0]);
		} else {
			# If we processed the data, store the raw version in the cached table for future use
			if($process) {
				if(!$procref->[0]) {
					my $rawaddsth = $dbh->prepare("INSERT INTO cached_metrics (resgroupid, data, timestamp, hostid) VALUES (?, ?, ?, ?)");
					$rawaddsth->execute($rawtype->id(), $data, DateTime::Format::Pg->format_timestamp($time), $host->id());
				}
			}
			if($cachedok) { 
				# The only time we won't get here is if $cache is false, 
				# $process is true, and there was no cached raw value.
				my $addsth = $dbh->prepare("INSERT INTO cached_metrics (resgroupid, data, timestamp, hostid) VALUES (?, ?, ?, ?)");
				$addsth->execute($rg->id(), $result, DateTime::Format::Pg->format_timestamp($time), $host->id());
			}
		}
	}

	$host->last_sampled(Loggerithim::Date->new());
	$host->update();

	if(Loggerithim::Config->fetch("caching/object")) {
		Loggerithim::Cache->remove("Sense", $host->id());
	}

	bless($self, $class);
	return $self;
}

=item $m->resource()

=item $m->resource($res)

Set/Get the Resource.  This value gets "raw" pre-pended to it for use as the
raw type if necessary.  This is required.

=cut
sub resource {
	my $self = shift();
	if(@_) { $self->{RESOURCE} = shift() }
	return $self->{RESOURCE};
}

=item $m->time()

=item $m->time($time)

Set/Get the time.  This is the time that the metric was gathered. This
is required.

=cut
sub time {
	my $self = shift();
	if(@_) { $self->{TIME} = shift() }
	return $self->{TIME};
}

=item $m->data()

=item $m->data($data)

Set/Get the data. The data is the 'metric' information.  Note that this
data has a specific structure. This is required.

=cut
sub data {
	my $self = shift();
	if(@_) { $self->{DATA} = shift() }
	return $self->{DATA};
}

=item $m->cache()

=item $m->cache($cache)

Set/Get the Cache attribute.  If this is set, the metric will also be
written to the cache table.  If there is an existing cache record, it's
timestamp() and data() will be updated.  If there is NOT, a new one
will be created.

=cut
sub cache {
	my $self = shift();
	if(@_) { $self->{CACHE} = shift() }
	return $self->{CACHE};
}

=item $m->cacheonly()

=item $m->cacheonly($cacheonly)

Set/Get the CacheOnly attribute. If this is set, the metric will not be
written into the normal metrics table, but only to the cache table.  This is
useful for static information, like the total amount of memory, or the number
of processors.

=cut
sub cacheonly {
	my $self = shift();
	if(@_) { $self->{CACHEONLY} = shift() }
	return $self->{CACHEONLY};
}

=item $m->host()

=item $m->host($host)

Set/Get the Host.  This is the host that the metric was fetched
from.  This is required.

=cut
sub host {
	my $self = shift();
	if(@_) { $self->{HOST} = shift() }
	return $self->{HOST};
}

=item $m->process()

=item $m->process($process)

Set/Get the Metric's Process flag.  If set, the data will be 'processed'.
Processed data is compared against the last reading and the different is
written into the metrics table.  This is used for CPU and Network traffic as
the totals are sent, and the difference between this and the last reading are
of interest.

=cut
sub process {
	my $self = shift();
	if(@_) { $self->{PROCESS} = shift() }
	return $self->{PROCESS};
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

