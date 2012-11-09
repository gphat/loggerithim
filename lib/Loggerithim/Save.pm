package Loggerithim::Save;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('saves');
__PACKAGE__->columns(Primary => qw(saveid));
__PACKAGE__->columns(Essential => qw(userid page params name));
__PACKAGE__->sequence('saves_saveid_seq');
__PACKAGE__->has_a(userid => 'Loggerithim::User');
