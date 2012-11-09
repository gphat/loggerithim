package Loggerithim::Smeeplets::Base;
use strict;

use Loggerithim::Config;
use Loggerithim::Database;
use Loggerithim::Date;
use Loggerithim::Event;
use Loggerithim::Host;
use Loggerithim::Job;
use Loggerithim::Log;
use Loggerithim::Metric;
use Loggerithim::Resource;
use Loggerithim::ResourceGroup;
use Loggerithim::Threshold;
use Loggerithim::Util::ThresholdChecker;

sub new {
    my $class = shift();
    my $self = {};
    return bless($self, $class);
}

1;
