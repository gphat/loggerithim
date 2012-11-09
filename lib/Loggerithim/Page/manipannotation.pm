package Loggerithim::Page::manipannotation;
use strict;

use base ("Loggerithim::Page");

sub handler {
	my $self    = shift();
	my $stuff   = shift();

	my $parameters	= $stuff->{'parameters'};
	my $r		    = $stuff->{'request'};
	my $user	    = $stuff->{'user'};

	if($parameters->{'submitter'}) {
		unless(Loggerithim::Util::Permission->check($user, "Annotation", "write")) {
			return { NORIGHTS => 1 };
		}
		my $strp = DateTime::Format::Strptime->new(
			pattern 	=> '%Y-%m-%d %T',
		);
		my $dt = $strp->parse_datetime($parameters->{'timestamp'});
		if($parameters->{'annotationid'}) {
			my $ann = Loggerithim::Annotation->retrieve($parameters->{'annotationid'});
			$ann->system(Loggerithim::System->retrieve($parameters->{'system'}));
			$ann->sigil($parameters->{'sigil'});
			$ann->timestamp($dt);
			$ann->comment($parameters->{'comment'});
			$ann->update();
		} else {
			my $ann = Loggerithim::Annotation->create({
				system		=> Loggerithim::System->retrieve($parameters->{'system'}),
				timestamp	=> $dt,
				sigil		=> $parameters->{'sigil'},
				comment		=> $parameters->{'comment'},
			});
		}
		return {REDIRECT => "admin.phtml"};
	} elsif($parameters->{'action'} eq "list") {
		unless(Loggerithim::Util::Permission->check($user, "Annotation", "read")) {
			return { NORIGHTS => 1 };
		}

		my @annotations;
		my $annIter = Loggerithim::Annotation->retrieve_all();
		while(my $ann = $annIter->next()) {
			push(@annotations, {
				id			=> $ann->id(),
				system		=> $ann->system()->name(),
				timestamp	=> $ann->timestamp()->strftime("%A %B %d, %Y"),
				sigil		=> $ann->sigil(),
				comment		=> $ann->comment()
			});
		}
		
		return {
			title			=> 'List Annotations',
			annotationlist	=> 1,
			annotations		=> \@annotations,
		};

	} elsif($parameters->{'annotationid'}) {
		unless(Loggerithim::Util::Permission->check($user, "Annotation", "read")) {
			return { NORIGHTS => 1 };
		}

		my $ann = Loggerithim::Annotation->retrieve($parameters->{'annotationid'});

		my @systems;
		my $sysIter = Loggerithim::System->retrieve_all();
		while(my $sys = $sysIter->next()) {
			my $selected = 1 unless $sys->id() != $ann->system()->id();
			push(@systems, {
				id		=> $sys->id(),
				selected=> $selected,
				name	=> $sys->name(),
			});
		}

		return {
			title		=> "Manipulate Annotation",
			annotationid=> $parameters->{'annotationid'},
			systems		=> \@systems,
			sigil		=> $ann->sigil(),
			timestamp	=> $ann->timestamp()->ymd()." ".$ann->timestamp()->hms(),
			comment		=> $ann->comment(),
		};
	}

	unless(Loggerithim::Util::Permission->check($user, "Annotation", "write")) {
		return { NORIGHTS => 1 };
	}

	my @systems;
	my $sysIter = Loggerithim::System->retrieve_all();
	while(my $sys = $sysIter->next()) {
		push(@systems, {
			id		=> $sys->id(),
			name	=> $sys->name(),
		});
	}

	my $now = Loggerithim::Date->new();
	return {
		title		=> "Manipulate Annotation",
		systems		=> \@systems,
		timestamp	=> $now->ymd()." ".$now->hms()
	};
}

1;
