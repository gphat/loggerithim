package Loggerithim::Smeeplets::LastSampled;
use strict;

use base ("Loggerithim::Smeeplets::Base");
use Loggerithim::Date;
use Loggerithim::Log;

sub run {
	my $self	= shift();
	my $hostid	= shift();
	my $jobid	= shift();

    loglog("DEBUG", "LastSampled running against Host $hostid.");

	my $job = Loggerithim::Job->new($jobid);

	my $db = Loggerithim::Database->new();
	my $dbh = $db->connect();

	my $sth = $dbh->prepare("SELECT last_sampled, hostid FROM hosts
			WHERE last_sampled < now() - interval '00:20' AND active=1"
	);
	$sth->execute();
	my ($lsampled, $hid);
	$sth->bind_columns(\($lsampled, $hid));
	while($sth->fetch()) {
		my $host = Loggerithim::Host->new($hid);
		my $udate = Loggerithim::Date->unixFormat($lsampled);

        loglog("DEBUG", "last_sampled is more than 20 minutes old, generating event.");
		my $name	= $host->hostname();
		my $ip		= $host->ip();
		my $message = "$name:$hostid ($ip) has not been updated since $lsampled, which is more than 20 minutes ago.";

		my $event = Loggerithim::Event->new();
		$event->hostid($hostid);
		$event->jobid($jobid);
		$event->severity(5);
		$event->identifier("LAST UPDATED");
		$event->text($message);
		$event->commit();
    }
	$sth->finish();
	$dbh->disconnect();
}

1;
