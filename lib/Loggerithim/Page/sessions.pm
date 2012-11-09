package Loggerithim::Page::sessions;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r			= $stuff->{'request'};
	my $user		= $stuff->{'user'};

	unless(Loggerithim::Util::Permission->check($user, "User", "read")) {
		return { NORIGHTS => 1 }
	}
	my $db = Loggerithim::Database->new();
	my $dbh = $db->connect();
	my $sesssth = $dbh->prepare("SELECT id FROM sessions");
	$sesssth->execute();

	my @sessions;
	while(my $sessref = $sesssth->fetchrow_arrayref()) {
		my %session;
		tie %session, 'Apache::Session::Postgres', $sessref->[0], {
			Handle	=> $dbh,
			Commit	=> 1
		};

		my $user = Loggerithim::User->retrieve($session{userid});
		if(defined($user)) {
			push(@sessions, {
				sessionid	=> $sessref->[0],
				username	=> $user->username(),
				timestamp	=> DateTime->from_epoch(epoch => $session{timestamp})->strftime("%A %B %d, %Y"),
			});
		}
	}
	$dbh->disconnect();
	return {
		title		=> 'Session Listing',
		sessions	=> \@sessions,
	};
}

1;
