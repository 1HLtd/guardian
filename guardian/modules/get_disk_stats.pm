#!/usr/bin/perl
use strict;
use warnings;

package diskstats;
require Exporter;
our @ISA		= qw(Exporter);
our @EXPORT		= qw(get_disk_stats);
our $VERSION	= 0.01;

# executes at run-time, unless used as module
__PACKAGE__->main() unless caller;

sub main {
	my $self = shift;
	require "/usr/local/sbin/parse_config.pm";
	import parse_config;
	if ( -e '/etc/guardian.conf') {
		my %config = parse_config('/etc/guardian.conf');
	}
	sub logger { print @_, "\n"; }
	use vars qw/ @sda @sdb /;
	@sda = ();
	@sdb = ();
	get_disk_stats();
	print 'sda: '.$sda[0],' ', $sda[1], "\n";
	print 'sdb: '.$sdb[0],' ', $sdb[1], "\n" if defined($sdb[0]);
}

sub get_disk_stats {
	if ( open DS, '<', '/proc/diskstats' ) {
		while (<DS>) {
			my @line = split /\s+/, $_;
			if ($line[3] eq 'sda') {
				for (my $i=4; $i<=11; $i++) {
					$sda[$i-4] = $line[$i];
				}
			}
			if ($line[3] eq 'sdb') {
				for (my $i=4; $i<=11; $i++) {
					$sdb[$i-4] = $line[$i];
				}
			}
		}
		close DS;		
	} else {
		main::logger("Unable to open /proc/diskstats: $!");
	}
}

1;