package Loggerithim::Violation;
use strict;

=head1 NAME

Loggerithim::Violation

=head1 DESCRIPTION

A Violation represents a broken Threshold.

=head1 SYNOPSIS

  my $v = Loggerithim::Violation->new();

=head1 METHODS

=head2 Constructor

=over 4

=item Loggerithim::Violation->new()

Creates and new instance of Loggerithim::Violation

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

=item $v->value()

=item $v->value($value)

Set/Get the value that broke the Threshold.

=cut
sub value {
	my $self = shift();
	if(@_) { $self->{VALUE} = shift() }
	return $self->{VALUE};
}

=item $v->threshValue()

=item $v->threshValue($threshValue)

Set/Get the value of the Threshold that was broken.

=cut
sub threshValue {
	my $self = shift();
	if(@_) { $self->{THRESHVALUE} = shift() }
	return $self->{THRESHVALUE};
}

=item $v->severity()

=item $v->severity($severity)

Set/Get the severity of the Threshold that was broken.

=cut
sub severity {
	my $self = shift();
	if(@_) { $self->{SEVERITY} = shift() }
	return $self->{SEVERITY};
}

=item $v->key()

=item $v->key($key)

Set/Get the key of the Threshold that was broken.

=cut
sub key {
	my $self = shift();
	if(@_) { $self->{KEY} = shift() }
	return $self->{KEY};
}
=back

=head2 Static Methods

=over 4

NONE.

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1), L<Loggerithim::Util::ThresholdChecker>

=cut
1;
