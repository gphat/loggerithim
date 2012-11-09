package Loggerithim::Config;
use strict;

=head1 NAME

Loggerithim::Config - Configuration

=head1 DESCRIPTION

# Interface to Loggerithim's configuration file.

=head1 SYNOPSIS

  use Loggerithim::Config;

  my $val = Loggerithim::Config->fetch("key");

=cut

use base qw(Apache::Singleton);

use XML::XPath;

my $xp;

BEGIN {
	$xp = XML::XPath->new(filename => "/etc/loggerithim.xml");
}

=head1 METHODS

=head2 Constructor

=over 4

NONE.

=back

=head2 Class Methods

=over 4

NONE.

=back

=cut

=head2 Static Methods

=over 4

=item Loggerithim::Config->fetch($key)

Fetch the value of the specified key.  Returns undef is key does not exist.

=cut
sub fetch {
	my $self = shift();
	my $key = shift();

	my $newkey = "/configuration/";
	$newkey .= $key;
	my $res = $xp->getNodeText($newkey);
	if(defined($res) and ($res ne "")) {
		return $res->value();
	} else {
		return undef;
	}
}

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;
