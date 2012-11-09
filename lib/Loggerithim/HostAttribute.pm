package Loggerithim::HostAttribute;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('hostattrs');
__PACKAGE__->columns(Primary => qw(hostattrid));
__PACKAGE__->columns(Essential => qw(hostid attributeid));
__PACKAGE__->sequence('hostattr_hostattrid_seq');

__PACKAGE__->has_a(hostid => 'Loggerithim::Host');
__PACKAGE__->has_a(attributeid => 'Loggerithim::Attribute');
