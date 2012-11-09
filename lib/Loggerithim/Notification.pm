package Loggerithim::Notification;
use strict;

use base 'Loggerithim::DBI';

__PACKAGE__->table('notifications');
__PACKAGE__->columns(Primary => qw(notificationid));
__PACKAGE__->columns(Essential => qw(jobid groupid systemid));
__PACKAGE__->sequence('notifications_notificationid_seq');
__PACKAGE__->has_a(jobid => 'Loggerithim::Job');
__PACKAGE__->has_a(groupid => 'Loggerithim::Group');
__PACKAGE__->has_a(systemid => 'Loggerithim::System');
