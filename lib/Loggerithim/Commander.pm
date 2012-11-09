package Loggerithim::Commander;
use strict;

=head1 NAME

Loggerithim::Commander - Remote Machine Communicator

=head1 DESCRIPTION

Remote loggeragents are capable of executing commands.   Command provides
the communication necessary to send these commands.

=head1 SYNOPSIS

my $comm = Loggerithim::Commander->new($hostid);

=cut
use Socket;
use Net::SSLeay qw(die_now die_if_ssl_error);

use Loggerithim::Config;
use Loggerithim::Host;
use Loggerithim::Util::Response;

Net::SSLeay::load_error_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();
Net::SSLeay::randomize();

=head1 METHODS

=head2 Constructor

=over 4

=item Loggerithim::Commander->new($hostid)

Creates a new Loggerithim::Commander object to communicate with the Host with
an ID of $hostid.  If that Host ID is not found, undef is returned.

=back

=cut
sub new {
	my $proto = shift();
	my $class = ref($proto) || $proto;
	my $self = {};
	bless($self, $class);
	if(@_) {
		$self->{HOST} = Loggerithim::Host->new(shift());
		if(!defined($self->{HOST})) {
			return undef;
		}
	} else {
		return undef;
	}
	return $self;
}

=head2 Class Methods

=over 4

=item $c->send($command);

Send the specified command to the Host assoicated with the Commander.

=cut
sub send {
	my $self	= shift();
	my $command	= shift();

	my $host = $self->{HOST};

	my $resp = Loggerithim::Util::Response->new();

	my $port = 4443;
	my $h = gethostbyname($host->ip());
	print $h;
	my $dest_serv_params = sockaddr_in($port, $h);

	if(!socket(S, &AF_INET, &SOCK_STREAM, 0)) {
		$resp->success(0);
		$resp->error("Could not open socket: $!");
		return $resp;
	}
	if(!connect(S, $dest_serv_params)) {
		$resp->success(0);
		$resp->error("Could not connect to remote host: $!");
		return $resp;
	}
	select(S);
	select(STDOUT);

	my $ctx = Net::SSLeay::CTX_v3_new();
	unless($ctx) {
		$resp->success(0);
		$resp->error("Failed to create SSL v3 Context: $!");
		return $resp;
	}

	eval {
		Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL);
		die_if_ssl_error("Error setting SSL context options: $!");
		Net::SSLeay::set_verify($ctx,&Net::SSLeay::VERIFY_PEER | &Net::SSLeay::VERIFY_FAIL_IF_NO_PEER_CERT, 0);
		die_if_ssl_error("Error setting verification options: $!");
		Net::SSLeay::CTX_load_verify_locations($ctx, Loggerithim::Config->fetch("prefix")."/loggerithim/certificates/CA.crt", 0);
		die_if_ssl_error("Error loading verification certificate: $!");
		Net::SSLeay::set_client_CA_list($ctx, Net::SSLeay::load_client_CA_file(Loggerithim::Config->fetch("prefix")."/loggerithim/certificates/CA.crt"));

		Net::SSLeay::CTX_use_RSAPrivateKey_file($ctx, Loggerithim::Config->fetch("prefix")."/loggerithim/certificates/server.key", &Net::SSLeay::FILETYPE_PEM);
		Net::SSLeay::CTX_use_certificate_file($ctx, Loggerithim::Config->fetch("prefix")."/loggerithim/certificates/server.crt", &Net::SSLeay::FILETYPE_PEM);
	};

	if($@) {
		$resp->success(0);
		$resp->error("Error configuring context: $@");
		Net::SSLeay::CTX_free($ctx);
		return $resp;
	}

	my $ssl = Net::SSLeay::new($ctx);
	unless($ssl) {
		Net::SSLeay::CTX_free($ctx);
		$resp->success(0);
		$resp->error("Failed to create SSL structure: $!");
		return $resp;
	}

	Net::SSLeay::set_fd($ssl, fileno(S));
	unless(Net::SSLeay::connect($ssl)) {
		Net::SSLeay::free($ctx);
		Net::SSLeay::CTX_free($ctx);
		$resp->success(0);
		$resp->error("Failed to connect: $!");
		return $resp;
	}

	unless(Net::SSLeay::write($ssl, "$command\r\n")) {;
		Net::SSLeay::free($ctx);
		Net::SSLeay::CTX_free($ctx);
		$resp->success(0);
		$resp->error("Failed to write to socket: $!");
		return $resp;
	}

	my $blank = 0;

	while(1) {
		my $got = Net::SSLeay::read($ssl);
		chop($got);
		chop($got);
		print "$got\n";
		unless($got) {
			Net::SSLeay::free($ssl);
			Net::SSLeay::CTX_free($ctx);
			$resp->success(0);
			$resp->error("Failed to read from socket: $!");
			return $resp;
		}
		if($got eq "+OK+") {
			$resp->success(1);
			next;
		}
		if($got eq "+NOK+") {
			$resp->success(0);
			next;
		}
		if($got eq "+DONE+") {
			goto DONEREADING;
		}
		if($got eq "") {
			$blank++;
			if($blank >= 3) {
				$resp->success(0);
				$resp->error($resp->error()." Blank line limit, something went wrong.");
				goto DONEREADING;
			}
		}
		if($resp->success()) {
			$resp->output($got);
		} else {
			$resp->error($got);
		}
	}
DONEREADING:
	Net::SSLeay::free($ssl);
	Net::SSLeay::CTX_free($ctx);
	close S;

	return $resp;
}
=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;
