package Loggerithim::Page::manipdepartment;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};
	my $user	    = $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Department", "write")) {
			return { NORIGHTS => 1 };
		}
		my $dept;
		if($parameters->{'departmentid'}) {
			$dept = Loggerithim::Department->retrieve($parameters->{'departmentid'});
			$dept->name($parameters->{'name'});
			$dept->update();
		} else {
			my $dept = Loggerithim::Department->create({
				name	=> $parameters->{'name'}
			});
		}
		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "Department", "read")) {
			return { NORIGHTS => 1 };
		}
		my @departments;
		my $dIter = Loggerithim::Department->retrieve_all();
		while(my $dept = $dIter->next()) {
			push(@departments, {
				id	=> $dept->id(),
				name=> $dept->name()
			});
		}
		return {
			title		=> 'List Departments',
			departmentlist	=> 1,
			departments	=> \@departments,
		};

	} elsif($parameters->{'departmentid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Department", "read")) {
			return { NORIGHTS => 1 };
		}
		my $dept = Loggerithim::Department->retrieve($parameters->{'departmentid'});

		return {
			title		=> "Manipulate Department",
			departmentid=> $parameters->{'departmentid'},
			name		=> $dept->name(),
		};
	}

	unless(Loggerithim::Util::Permission->check($user, "Department", "write")) {
		return { NORIGHTS => 1 };
	}
	return {
		title		=> "Manipulate Department",
	};
}

1;
