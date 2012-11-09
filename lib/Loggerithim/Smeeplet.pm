package Loggerithim::Smeeplet;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('smeeplets');
__PACKAGE__->columns(Primary => qw(smeepletid));
__PACKAGE__->columns(Essential => qw(name description));
__PACKAGE__->columns(Stringify => qw(name));
__PACKAGE__->sequence('smeeplets_smeepletid_seq');

1;
