package Loggerithim::Util::Response;
use strict;

=head1 NAME

Loggerithim::Util::Response - Response from remote machine

=head1 DESCRIPTION

Response holds the result of commands sent to Hosts.

=head1 SYNOPSIS

  my $resp = $comm->send($command);

=head1 METHODS

=head2 Constructor

=over 4

=item Loggerithim::Util::Response->new()

Creates a new Loggerithim::Util::Response object.

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

=item $r->success()

=item $r->success($success)

Sets/Gets whether or not a command succeeded.

=cut
sub success {
	my $self = shift();
	if(@_) { $self->{SUCCESS} = shift() }
	return $self->{SUCCESS};
}

=item $r->error()

=item $r->error($message)

Sets/Gets the error message associated with this Response.  If there is no error,
undef is returned.

=cut
sub error {
	my $self = shift();
	if(@_) { $self->{ERROR} = shift() }
	return $self->{ERROR};
}

=item $r->output()

=item $r->output($op)

Sets/Gets the output associated with this Response.  If there is no output,
undef is returned.

=cut
sub output {
	my $self = shift();
	if(@_) { $self->{OUTPUT} = shift() }
	return $self->{OUTPUT};
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
