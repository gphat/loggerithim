package Loggerithim::Job;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('jobs');
__PACKAGE__->columns(Primary => qw(jobid));
__PACKAGE__->columns(Essential => qw(attributeid smeepletid interval));
__PACKAGE__->sequence('jobs_jobid_seq');
__PACKAGE__->has_a(attributeid => 'Loggerithim::Attribute');
__PACKAGE__->has_a(smeepletid => 'Loggerithim::Smeeplet');
__PACKAGE__->has_many(notifications => 'Loggerithim::Notification');
__PACKAGE__->has_a(interval => 'DateTime::Event::Cron',
	inflate => sub { DateTime::Event::Cron->new_from_cron(shift()) },
	deflate => 'original'
);
