package Loggerithim::Session;
use strict;

=head1 NAME

Loggerithim::Session

=head1 DESCRIPTION

This module represents Sessions in Loggerithim.

=head1 SYNOPSIS

 my $sess = Loggerithim::Session->new();

=cut
use Apache::Session::Postgres;

use Apache::Cookie;

use Loggerithim::Config;
use Loggerithim::Database;

use Digest::MD5;

=head1 METHODS

=head2 Constructor

=over 4

=item Loggerithim::Session->new()

Makes a new Session.

=cut
sub new {
	my $proto	= shift();
	my $userid	= shift();

	my $class = ref($proto) || $proto;
	my $self = {};
	bless($self, $class);

	my $now	= time();

	my $db = Loggerithim::Database->new();
	my $dbh = $db->connect();
	my %session;
	tie %session, 'Apache::Session::Postgres', undef, {
		Handle	=> $dbh,
		Commit	=> 0
	};

	$session{userid}	= $userid;
	$session{timestamp}	= $now;

	my $ctx = Digest::MD5->new();
	$ctx->add(Loggerithim::Config->fetch("secret"));
	$ctx->add(join(':', $now, $session{_session_id}));
	my $hash = $ctx->hexdigest();
	
	my $cookie = {
		'time'		=> $now,
		'sessionid'	=> $session{_session_id},
		'hash' 		=> $hash
	};

	$dbh->disconnect();

	$self->{SESSIONID}	= $session{_session_id};
	$self->{COOKIE}		= $cookie;
	$self->{HASH}		= $hash;
	return $self;
}
=back

=head2 Class Methods

=over 4

=item $sess->updateSession()

Update the timestamp in the session.

=cut
sub updateSession {
	my $self = shift();

	my $db = Loggerithim::Database->new();
	my $dbh = $db->connect();

	my %session;
	tie %session, 'Apache::Session::Postgres', $self->{SESSIONID}, {
		Handle	=> $dbh,
		Commit	=> 0
	};

	$session{timestamp} = time();
	$dbh->disconnect();
}

=item $sess->get($key)

Returns the value of the specified key from the session.

=cut
sub get {
	my $self= shift();
	my $key	= shift();

	my $db = Loggerithim::Database->new();
	my $dbh = $db->connect();
	my %session;
	tie %session, 'Apache::Session::Postgres', $self->{SESSIONID}, {
		Handle	=> $dbh,
		Commit	=> 0
	};
	my $val = $session{$key};
	$dbh->disconnect();

	return $val;
}

=item $sess->set($key, $value)

Sets the specified key value pair for the session.

=cut
sub set {
	my $self= shift();
	my $key	= shift();
	my $val = shift();

	my $db = Loggerithim::Database->new();
	my $dbh = $db->connect();
	my %session;
	tie %session, 'Apache::Session::Postgres', $self->{SESSIONID}, {
		Handle	=> $dbh,
		Commit	=> 0
	};
	$session{$key} = $val;
	$dbh->disconnect();
}

=item $sess->destroy()

Destroys the session by removing it from the backend store.

=cut
sub destroy {
	my $self = shift();

	my $db = Loggerithim::Database->new();
	my $dbh = $db->connect();

	my %session;
	tie %session, 'Apache::Session::Postgres', $self->{SESSIONID}, {
		Handle	=> $dbh,
		Commit	=> 0
	};
	tied(%session)->delete();

	$dbh->disconnect();
}

=item $sess->cookie()

Return this session's cookie.

=cut
sub cookie {
	my $self = shift();

	return $self->{COOKIE};
}
=back

=head2 Static Methods

=over 4

=item Loggerithim::Session->existingSession($r)

Given the Apache request object, returns a message (reason it's bad) to
verify the existence of a Session.  Returns an Loggerithim::Session object on
success, returns a SessionException on failure.

=cut
sub existingSession {
	my $proto	= shift();
	my $r   	= shift();

	my %cookies = Apache::Cookie->parse($r->header_in('Cookie'));
	unless(%cookies) {
		$r->log_error("No cookies");
		return undef;
	}
	unless($cookies{'LoggerTicket'}) {
		$r->log_error("No Ticket");
		return undef;
	}
	my %ticket = $cookies{'LoggerTicket'}->value();

	unless($ticket{'time'} && $ticket{'sessionid'}) {
		$r->log_error("Malformed Ticket");
		return undef;
	}
	my $ctx = Digest::MD5->new();
	$ctx->add(Loggerithim::Config->fetch("secret"));
	$ctx->add(join(':', $ticket{'time'}, $ticket{'sessionid'}));
	unless($ctx->hexdigest() eq $ticket{'hash'}) {
		$r->log_error("Hex Mismatch");
		return undef;
	}

	my $db = Loggerithim::Database->new();
	my $dbh = $db->connect();

	eval {
		tie my %session, 'Apache::Session::Postgres', $ticket{'sessionid'}, {
			Handle	=> $dbh,
			Commit	=> 0
		};
	};
	if($@) {
		$r->log_error("Error fetching session");
		return undef;
	}

	$dbh->disconnect();

	my $class = ref($proto) || $proto;
	my $self = {};
	bless($self, $class);
	$self->{SESSIONID}	= $ticket{'sessionid'};
	$self->{COOKIE}		= \%ticket;

	$self->updateSession();
	
	return $self;
}

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;
