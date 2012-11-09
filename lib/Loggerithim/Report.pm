package Loggerithim::Report;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('reports');
__PACKAGE__->columns(Primary => qw(reportid));
__PACKAGE__->columns(Essential => qw(reporterid attributeid interval output));
__PACKAGE__->sequence('reports_reportid_seq');
__PACKAGE__->has_a(reporterid => "Loggerithim::Reporter");
__PACKAGE__->has_a(attributeid => "Loggerithim::Attribute");
__PACKAGE__->has_a(interval => 'DateTime::Event::Cron',
	inflate	=> sub { DateTime::Event::Cron->new_from_cron(shift()) },
	deflate	=> 'original'
);
