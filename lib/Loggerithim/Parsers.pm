package Loggerithim::Parsers;
use strict;

=head1 NAME

Loggerithim::Parsers - Parse metrics

=head1 DESCRIPTION

Loggerithim's data is basically lists of comma seperated values. Parsers provide
methods to break these lists down into structures appropriate for graphing.

=head1 SYNOPSIS

TODO

=head1 METHODS

=head2 Constructor

=over 4

NONE.

=back

=head2 Class Methods

=over 4

NONE.

=back

=head2 Static Methods

=item Loggerithim::Parsers->parseMetrics($resultref, $resource)

=item Loggerithim::Parsers->parseMetrics($resultref, $resource, $key)

This method takes the result of a Loggerithim metric query and a resourceid.
The resourceid is the particular resource you are interested in. It returns an
array of target values.

=cut
sub parseMetrics {
	my $self	    = shift();
	my $result_ref	= shift();
	my $res			= shift();
	my $key		    = shift();

	my $rg = $res->resgroup();
	my $index = $res->index();

	my @targetarray;
	my @timearray;

	if(defined($index)) {
		for(@{$result_ref}) {
			my($timestamp, $data) = (@{$_});
			my @dater;
			if($rg->keyed()) {
				my @parts = split(/:/, $data);
				foreach my $piece (@parts) {
					if($piece =~/^$key/) {
						@dater = split(/,/, $piece);
						last;
					}
				}
			} else {
				@dater = split(/,/, $data);
			}

			push(@targetarray, $dater[$index]);
			push(@timearray, $timestamp);
		}
	}
	return (\@targetarray, \@timearray);
}

=item Loggerithim::Parsers->genParse($resgroup, $data)

Given a ResourceGroup and the data from a metric row, this method returns a
a hashref of the values with the Resource names as keys.

=cut
sub genParse {
	my $self	= shift();
	my $rg		= shift();
	my $data	= shift();

	# Get a list of all the resources for this group.
	my $rIter = $rg->resources();

	my $metric_data;
	if($rg->keyed()) {
		my @objects = split(/:/, $data);
		foreach my $obj (@objects) {
			my @splitdata = split(/,/, $obj);
			my $mdata;
			while(my $res = $rIter->next()) {
				# Add one for the key
				$mdata->{$res->name()} = $splitdata[$res->index()];
			}
			$metric_data->{$splitdata[0]} = $mdata;
		}
	} else {
		my @splitdata = split(/,/, $data);
		while(my $res = $rIter->next()) {
			$metric_data->{$res->name()} = $splitdata[$res->index()];
		}
	}

	return $metric_data;
}

=back

=head1 AUTHOR

Cory 'G' Watson <gphat@loggerithim.org>

=head1 SEE ALSO

perl(1)

=cut
1;
