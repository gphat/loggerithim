package Loggerithim::Smeeplets::FileSystemSpace;
use strict;

use base ("Loggerithim::Smeeplets::Base");

sub run {
	my $self	= shift();
	my $hostid	= shift();
	my $jobid	= shift();

	my $job = Loggerithim::Job->retrieve($jobid);

	my $host = Loggerithim::Host->retrieve($hostid);
	my $ip = $host->ip();

	my $resgroup = Loggerithim::ResourceGroup->search(name => 'storage')->next();

	my $db = Loggerithim::Database->new();
	my $dbh = $db->connect();

	my $failed = undef;
	my $cachesth = $dbh->prepare("SELECT data FROM cached_metrics WHERE hostid=? AND resgroupid=?");
	$cachesth->execute($hostid, $resgroup->id());
	my $fsref = $cachesth->fetchrow_arrayref();
	my @filesystems = split(/:/, $fsref->[0]);
	$cachesth->finish();
	$dbh->disconnect();

	my $res = Loggerithim::Resource->search(name => 'stoUsed')->next();
	my $hasThresh = $host->hasThreshold($res);

	my @efeses;
	# Determine which filesystems have thresholds keyed to them.
	foreach my $fs (@filesystems) {
		my @stats = split(/,/, $fs);
		push(@efeses, {
			Key		=> $stats[0],
			Value	=> $stats[4],
		});
	}

	my $tcheck = Loggerithim::Util::ThresholdChecker->new();
	my @thresholds = $host->thresholdsByResource($res);
	my $dthresh1 = Loggerithim::Threshold->empty();
	$dthresh1->value(85);
	$dthresh1->severity(5);
	push(@thresholds, $dthresh1);
	my $dthresh2 = Loggerithim::Threshold->empty();
	$dthresh2->value(90);
	$dthresh2->severity(7);
	push(@thresholds, $dthresh2);
	$tcheck->thresholds(\@thresholds);
	$tcheck->values(\@efeses);
	my $violations = $tcheck->check();
	$dthresh1->delete();
	$dthresh2->delete();

	my $hostname = $host->name();
	foreach my $v (@{ $violations }) {
		my $message = $v->key()." filesystem on $hostname:$hostid ($ip) is ".$v->value()." consumed, which violates threshold set at ".$v->threshValue()."%.";
		Loggerithim::Event->create({
			host		=> $host,
			job			=> $job,
			timestamp	=> Loggerithim::Date->new(),
			severity	=> $v->severity(),
			identifier	=> "FILESYSTEM SIZE: ".$v->key(),
			message		=> $message,
		});
	}
}
	
1;
