#!/usr/bin/perl
use strict;

my $insequence = undef;
my $intable = undef;
my $tablename;
my @sequences;
my @fields;

my $filename = shift or die "Usage: db_page.pl <filename>\n";

open DBFILE, $filename;

while(<DBFILE>) {
    if($_ =~ /^CREATE (\w*) (\w*)/) {
        my $entity = $1;
        my $name   = $2;

        if($entity eq "SEQUENCE") {
            $intable = 0;
            $insequence = 1;
            push(@sequences, $name);
        }
        if($entity eq "TABLE") {
            $intable = 1;
            $insequence = 0;
			$tablename = $2;
        }
    } elsif($intable) {
        if($_ =~ /\s*(\w*)\s*((\w|\d|\(|\))*)\s*(.*)/) {
			my $name = $1;
			my $type = $2;
			my $const = $4;
			while(($const !~ /\,$/) and ($const !~ /;$/)) {
				$const .= <DBFILE>;
			}
			$const =~ tr/ |\t/ /;
			if($const =~ /;$/) {
				$intable = 0;
			}
			chop($const);
			if($name eq "CONSTRAINT") {
				if($const =~ /UNIQUE\((\w*)\)/) {
					my $count = 0;
					my $fname = $1;
					foreach my $field (@fields) {
						if($field->{'Name'} eq $fname) {
							$field->{'Constraints'} .= " UNIQUE";
						}
						@fields[$count] = $field;
						$count++;
					}
				}
			} else {
				if($const =~ /CONSTRAINT (\w*)/) {
					my $constname = $1;
					if($const =~ /CONSTRAINT $constname (.*)/) {
						$const = $1;
					}
				}
				if($const =~ /REFERENCES (\w*)/) {
					my $tname = $1;
					$const =~ s/$tname/<a href=\"$tname.html\">$tname<\/a>/;
				}
				push(@fields, {
					Name		=> $name,
					Type		=> $type,
					Constraints	=> $const,
				});
			}
        }
    }
    if($_ =~ /\;$/) {
        $intable = 0;
        $insequence = 0;
    }
}

close DBFILE;

print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"DTD/xhtml11.dtd\">\n";
print "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n";
print " <head>\n";
print "  <title>Loggerithim table $tablename</title>\n";
print "  <link rel=\"stylesheet\" href=\"db.css\" type=\"text/css\" />\n";
print " </head>\n";
print " <body>\n";
print "  <table>\n";
print "   <tr>\n";
print "    <td class=\"name\">$tablename</td>\n";
print "   </tr>\n";
print "   <tr>\n";
print "    <td>\n";
print "     <table class=\"dbtable\">\n";
print "      <tr>\n";
print "       <th>name</th>\n";
print "       <th>type</th>\n";
print "       <th>properties</th>\n";
print "      </tr>\n";

foreach my $field (@fields) {
	print "      <tr>\n";
	print "       <td>".$field->{'Name'}."</td>\n";
	print "       <td>".$field->{'Type'}."</td>\n";
	if($field->{'Constraints'} eq "") {
		print "       <td>&nbsp;</td>\n";
	} else {
		print "       <td>".$field->{'Constraints'}."</td>\n";
	}
	print "      </tr>\n";
}

foreach my $seqname (@sequences) {
	#print "$seqname\n";
}

print "     </table>\n";
print "    </td>\n";
print "   </tr>\n";
print "  </table>\n";
print " </body>\n";
print "</html>\n";
