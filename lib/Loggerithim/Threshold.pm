package Loggerithim::Threshold;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table("thresholds");
__PACKAGE__->columns(Primary => qw(thresholdid));
__PACKAGE__->columns(Essential => qw(hostid resourceid severity value key));
__PACKAGE__->sequence('thresholds_thresholdid_seq');
__PACKAGE__->has_a("hostid" => 'Loggerithim::Host');
__PACKAGE__->has_a("resourceid" => 'Loggerithim::Resource');

sub empty {
	my $self = {};
	bless($self);
	$self->mk_accessors(qw(severity value key));
	return $self;
}
