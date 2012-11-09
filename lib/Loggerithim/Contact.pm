package Loggerithim::Contact;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('contacts');
__PACKAGE__->columns(Primary => qw(contactid));
__PACKAGE__->columns(Essential => qw(userid mediumid value));
__PACKAGE__->sequence('contacts_contactid_seq');
__PACKAGE__->has_a(userid => 'Loggerithim::User');
__PACKAGE__->has_a(mediumid => 'Loggerithim::Medium');

1;
