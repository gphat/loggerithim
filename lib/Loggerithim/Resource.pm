package Loggerithim::Resource;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table("resources");
__PACKAGE__->columns(Primary => qw(resourceid));
__PACKAGE__->columns(Essential => qw(resgroupid name index));
__PACKAGE__->columns(Stringify => qw(name));
__PACKAGE__->sequence('resources_resourceid_seq');

__PACKAGE__->has_a(resgroupid => 'Loggerithim::ResourceGroup');

1;
