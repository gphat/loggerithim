package Loggerithim::Event;
use strict;

use base 'Loggerithim::DBI';

use Loggerithim::Database;

__PACKAGE__->table('events');
__PACKAGE__->columns(Primary => qw(eventid));
__PACKAGE__->columns(Essential => qw(hostid jobid severity identifier message timestamp attempts hushed squelched));
__PACKAGE__->columns(Stringify => qw(identifier));
__PACKAGE__->sequence('events_eventid_seq');
__PACKAGE__->has_a(hostid => 'Loggerithim::Host');
__PACKAGE__->has_a(jobid => 'Loggerithim::Job');
__PACKAGE__->has_a(timestamp => 'DateTime',
	inflate => sub { DateTime::Format::Pg->parse_timestamp(shift()) },
	deflate => sub { DateTime::Format::Pg->format_timestamptz(shift()) }
);
__PACKAGE__->has_many('childEvents' => 'Loggerithim::ChildEvent');

sub create {
	my $self = shift();
	my $args = shift();

	my $host	= $args->{'host'};
	my $job		= $args->{'job'};
	my $ident	= $args->{'identifier'};

	my $eIter;
	if(defined($host)) {
		if(defined($job)) {
			$eIter = Loggerithim::Event->search(jobid => $job->id(), hostid => $host->id(), identifier => $ident);
		} else {
			$eIter = Loggerithim::Event->search(hostid => $host->id(), identifier => $ident);
		}
	} else {
		if(defined($job)) {
			$eIter = Loggerithim::Event->search(jobid => $job->id(), identifier => $ident);
		} else {
			$eIter = Loggerithim::Event->search(identifier => $ident);
		}
	}
	if($eIter->count() > 0) {
		my $event = $eIter->next();
		Loggerithim::ChildEvent->create({
			event		=> $event,
			severity	=> $args->{'severity'},
			message		=> $args->{'message'},
			timestamp	=> $args->{'timestamp'}
		});
		$event->message($args->{'message'});
		$event->update();
	} else {
		$self->SUPER::create($args);
	}
}

sub relativeSeverity {
	my $self = shift();

	my $cIter = $self->childEvents();

	my $relative = $self->severity();
	while(my $child = $cIter->next()) {
		$relative += ($self->severity() - $child->severity()) + 1;
	}

	return $relative;
}

sub archive {
	my $self = shift();

	my $db = Loggerithim::Database->new();
	my $dbh = $db->connect();

	my $psth = $dbh->prepare("INSERT INTO archivedevents
		SELECT nextval('archivedevents_eventid_seq'),
			NULL, hostid, severity, identifier, message, timestamp
		FROM events
		WHERE eventid=?"
	);
	$psth->execute($self->{ID});

	my $csth = $dbh->prepare("INSERT INTO archivedevents
		SELECT nextval('archivedevents_eventid_seq'),
			?, NULL, severity, NULL, message, timestamp
		FROM childevents
		WHERE eventid=?"
	);
	$csth->execute($self->{ID}, $self->{ID});

	my $ceIter = $self->childEvents();
	while(my $ce = $ceIter->next()) {
		$ce->delete();
	}
	$self->delete();

	$dbh->disconnect();
}

1;
