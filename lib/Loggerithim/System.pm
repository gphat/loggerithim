package Loggerithim::System;
use strict;

use base 'Loggerithim::DBI';

use Data::Dumper;
use DateTime::Format::Pg;

__PACKAGE__->table('systems');
__PACKAGE__->columns(Primary => qw(systemid));
__PACKAGE__->columns(Essential => qw(name));
__PACKAGE__->columns(Stringify => qw(name));
__PACKAGE__->sequence('systems_systemid_seq');
__PACKAGE__->has_many('annotations' => 'Loggerithim::Annotation');

sub annotationsBetween {
	my $self	= shift();
	my $start	= shift();
	my $end		= shift();

	my $fstart	= DateTime::Format::Pg->format_timestamptz($start);
	my $fend	= DateTime::Format::Pg->format_timestamptz($end);

	my @annots = Loggerithim::Annotation->search_annotationsBetween($self->id(), $fstart, $fend);
	return @annots;
}

1;
