package Loggerithim::Util::ThresholdChecker;
use strict;

=head1 NAME

Loggerithim::Util::ThresholdChecker - Check Thresholds

=head1 DESCRIPTION

Compares a list of Thresholds to a list of values and keys.

=head1 SYNOPSIS

  my $t = Loggerithim::Util::ThresholdChecker->new();
  $tcheck->thresholds(\@thresholds);
  $tcheck->values(\@values);
  my $violations = $tcheck->check();

=cut
use Loggerithim::Violation;

=head1 METHODS

=head2 Constructor

=over 4

=item Loggerithim::Util::ThresholdChecker->new()

Creates a new instance of Loggerithim::Util::ThresholdChecker.
=back

=cut
sub new {
	my $proto = shift();
	my $class = ref($proto) || $proto;
	my $self = {};
	bless($self, $class);
	return $self;
}

=item $t->thresholds()

=item $t->thresholds(\@thresholds)

Set/Get the Thresholds for this ThresholdChecker.  Should be an arrayref.

=cut
sub thresholds {
	my $self = shift();
	if(@_) { $self->{THRESHOLDS} = shift() }
	return $self->{THRESHOLDS};
}

=item $t->values()

=item $t->values(\@values)

Set/Get the values that we are checking the Thresholds against.  Should be an
arrayref.

=cut
sub values {
	my $self = shift();
	if(@_) { $self->{VALUES} = shift() }
	return $self->{VALUES};
}

=item $t->check()

Check the values against the Thresholds, and return a list of Violations.

=cut
sub check {
	my $self = shift();

	my $keyed = 0;
	my @keyedPreppedTs;	
	my @preppedTs;	
	foreach my $thresh (@{ $self->{THRESHOLDS} }) {
		my $key = undef;
		my $regex = 0;

		if($thresh->key() =~ /^~(.*)/) {
			$regex = 1;
			$keyed = 1;
			$key = $1;
		} elsif($thresh->key()) {
			$key = $thresh->key();
			$keyed = 1;
		}

		# If the threshold has a key, add it to the array of keyed thresholds,
		# else, add it to the non-keyed threshold array.
		if(defined($key)) {
			push(@keyedPreppedTs, {
				Regex		=> $regex,
				Key			=> $key,
				Value		=> $thresh->value(),
				Severity	=> $thresh->severity(),
			});
		} else {
			push(@preppedTs, {
				Value		=> $thresh->value(),
				Severity	=> $thresh->severity(),
			});
		}
	}
	my @violations;

	# Go through all the values and check them against the keyed array.
	# If there is a match, check the threshold and set the matched flag.
    # After we've finished the keyed thresholds, if there was no match made
	# (matched flag) then we can compare the value to the non-keyed thresholds.	
	foreach my $checks (@{ $self->{VALUES} }) {
		my $matched;
		foreach my $t (@keyedPreppedTs) {
			if($t->{'Regex'}) {
				if($checks->{'Key'} =~ $t->{'Key'}) {
					if($checks->{'Value'} > $t->{'Value'}) {
						my $v = Loggerithim::Violation->new();
						$v->value($checks->{'Value'});
						$v->threshValue($t->{'Value'});
						$v->severity($t->{'Severity'});
						$v->key($->{'Key'});
						push(@violations, $v);
					}
					$matched = 1;
				}
			} else {
				if($checks->{'Key'} eq $t->{'Key'}) {
					if($checks->{'Value'} > $t->{'Value'}) {
						my $v = Loggerithim::Violation->new();
						$v->value($checks->{'Value'});
						$v->threshValue($t->{'Value'});
						$v->severity($t->{'Severity'});
						$v->key($checks->{'Key'});
						push(@violations, $v);
					}
					$matched = 1;
				}
			}
		}

		if(!($matched)) {
			foreach my $t (@preppedTs) {
				if($checks->{'Value'} > $t->{'Value'}) {
					my $v = Loggerithim::Violation->new();
					$v->value($checks->{'Value'});
					$v->threshValue($t->{'Value'});
					$v->severity($t->{'Severity'});
					$v->key($checks->{'Key'});
					push(@violations, $v);
				}
			}
		}
	}

	return \@violations;
}
=back

=head2 Static Methods

=over 4

NONE.

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1), Loggerithim::Threshold

=cut
1;
