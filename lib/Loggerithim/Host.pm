package Loggerithim::Host;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('hosts');
__PACKAGE__->columns(Primary => qw(hostid));
__PACKAGE__->columns(Essential => qw(systemid departmentid name ip active purpose db_sid db_port db_password last_sampled));
__PACKAGE__->columns(Stringify => qw(name));
__PACKAGE__->sequence('hosts_hostid_seq');

__PACKAGE__->has_a(systemid => 'Loggerithim::System');
__PACKAGE__->has_a(departmentid => 'Loggerithim::Department');
__PACKAGE__->has_a('last_sampled', 'DateTime', 
	inflate => sub { DateTime::Format::Pg->parse_timestamp(shift()) },
	deflate => sub { DateTime::Format::Pg->format_timestamp(shift()) }
);

__PACKAGE__->has_many('attributes' => ['Loggerithim::HostAttribute' => 'attribute'], {sort => 'attributeid'});
__PACKAGE__->has_many('hostAttributes' => 'Loggerithim::HostAttribute');
__PACKAGE__->has_many('thresholds' => 'Loggerithim::Threshold');
__PACKAGE__->has_many('cachedMetrics' => 'Loggerithim::CachedMetric');

__PACKAGE__->set_sql('byAttribute' => qq{
	SELECT hostid FROM hostattrs WHERE attributeid=?
});

sub addAttribute {
	my $self = shift();
	my $att = shift();

	my $aIter = $self->attributes();
	while(my $a = $aIter->next()) {
		if($a->id() == $att->id()) {
			return;
		}
	}

	Loggerithim::HostAttribute->create({
		host		=> $self,
		attribute	=> $att
	});
}

sub hasAttribute {
	my $self = shift();
	my $att = shift();

	my $aIter = $self->attributes();
	while(my $a = $aIter->next()) {
		if($a->id() == $att->id()) {
			return 1;
		}
	}
	return 0;
}

sub hasThreshold {
	my $self = shift();
	my $res = shift();

	my $tIter = $self->thresholds();
	while(my $t = $tIter->next()) {
		if($t->resource()->id() == $res->id()) {
			return 1;
		}
	}
	return 0;
}

sub thresholdsByResource {
	my $self = shift();
	my $res = shift();

	my $tIter = $self->thresholds();
	my @tholds;
	while(my $thold = $tIter->next()) {
		if($thold->resource()->id() eq $res->id()) {
			push(@tholds, $thold);
		}
	}
	return @tholds;
}

1;
