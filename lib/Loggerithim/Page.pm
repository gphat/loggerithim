package Loggerithim::Page;
use strict;

=head1 NAME

Loggerithim::Page - Page base object.

=head1 DESCRIPTION

Page provides a new() method to any pages who don't with to write their
own.  Most pages don't do anything special with their constructors, so
this object just saves code.

=head1 SYNOPSIS

use base ("Loggerithim::Page");

=head1 METHODS

=head2 Constructor

=over 4

=item Loggerithim::Page->new()

Creates and returns a new Loggerithim::Page object.

=back

=cut
sub new {
    my $class = shift();
    my $self = {};
    return bless($self, $class);
}

=head2 Class Methods

=over 4

NONE

=back

=head2 Static Methods

=over 4

NONE

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;
