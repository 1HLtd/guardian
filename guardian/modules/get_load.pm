#!/usr/bin/perl
use strict;
use warnings;

package get_load;

require Exporter;
our @ISA		= qw(Exporter);
our @EXPORT		= qw(get_load get_loadtype);
our $VERSION	= 0.04;

# executes at run-time, unless used as module
__PACKAGE__->main() unless caller;

sub main {
	my $self = shift;
	sub logger { print @_, "\n"; }
	print 'Current load: ', get_load(), "\n";
}

sub get_load {
	open(LOAD, '<', '/proc/loadavg') or main::logger("Unable to open /proc/loadavg: $!");
	my @loadavg = split /\s+/, <LOAD>;
	close(LOAD);
	return $loadavg[0];
}

sub get_loadtype {
	my $curload = shift;
	my $config_ref = shift;
	my $loadinfo_ref = shift;
	my $loadtype = 0;
	my $newload = 0;
	$newload = get_load();
	main::logger("Got new load value: $newload") if $config_ref->{'debug'};
	# load increasing
	if ($newload > $curload) {
		my $load_diff = $newload - $curload;
		if ( $load_diff > 1.1 ) {
			$loadtype = 5;
		} elsif ( $load_diff > 0.9 ) {
			$loadtype = 4;
		} elsif ( $load_diff > 0.7 ) {
			if (defined($loadinfo_ref->[2])) {
				if ($newload - $loadinfo_ref->[2] > 1.5 ) {
					$loadtype = 6;
				} else {
					$loadtype = 5;
				}
			} else {
				$loadtype = 3;
			}
		} elsif ( $load_diff > 0.5 ) {
			$loadtype = 3;
		} elsif ( $load_diff > 0.3 ) {
			$loadtype = 2;
		}
	}
	# load dropping
	$loadtype = 1 if ($loadtype < 2 && $newload < $curload && ($curload - $newload) > 0.2);
	# save the new load entry into current load entry
	$curload = $newload;
	# if we have more then 5 records start shifting the array before adding new entries
	# the value is 30 because we execute this code once in 10 times
	if ( $#{$loadinfo_ref} > 4 ) {
		shift(@{$loadinfo_ref});
		main::logger("Load array shifted") if $config_ref->{'debug'};
	}
	push(@{$loadinfo_ref},$newload);

	# additionaly check the difference between now and hlaf a minute earlyer
	$loadtype = 1 if (
		$loadtype < 2 &&
		defined($loadinfo_ref->[5]) &&
		($loadinfo_ref->[5] > $loadinfo_ref->[0]) &&
		($loadinfo_ref->[5] - $loadinfo_ref->[0]) > 0.5
	);

	return($loadtype,$curload);
}

1;
