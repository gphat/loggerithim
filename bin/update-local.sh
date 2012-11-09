#!/bin/sh

cp ../lib/Loggerithim/*.pm /usr/local/apache/lib/perl/Loggerithim/
cp ../lib/Loggerithim/Page/*.pm /usr/local/apache/lib/perl/Loggerithim/Page/
cp ../lib/Loggerithim/Smeeplets/*.pm /usr/local/apache/lib/perl/Loggerithim/Smeeplets/
cp ../lib/Loggerithim/Util/*.pm /usr/local/apache/lib/perl/Loggerithim/Util/

cp ../httpd/templates/* /home/httpd/loggerithim/templates
cp ../httpd/html/* /home/httpd/loggerithim/html/
cp ../cron/* /etc/cron.Loggerithim/
cp ../bin/loggerserver.pl /usr/local/bin/
