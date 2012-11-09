package Loggerithim::CachedMetric;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('cached_metrics');
__PACKAGE__->columns(Primary => qw(metricid));
__PACKAGE__->columns(Essential => qw(resgroupid hostid data timestamp));
__PACKAGE__->sequence('cached_metrics_metricid_seq');
__PACKAGE__->has_a('hostid', 'Loggerithim::Host');
__PACKAGE__->has_a('resgroupid', 'Loggerithim::ResourceGroup');

1;
