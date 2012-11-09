package Loggerithim::ProfileAttribute;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('profattrs');
__PACKAGE__->columns(Primary => qw(profattrid));
__PACKAGE__->columns(Essential => qw(profileid attributeid));
__PACKAGE__->sequence('profattrs_profattrid_seq');
__PACKAGE__->has_a(profileid => "Loggerithim::Profile");
__PACKAGE__->has_a(attributeid => "Loggerithim::Attribute");
