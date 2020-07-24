#!/usr/bin/perl
use strict;
use warnings;

package get_users;
require Exporter;
our @ISA		= qw(Exporter);
our @EXPORT		= qw(get_users);
our $VERSION	= 0.03;

# executes at run-time, unless used as module
__PACKAGE__->main() unless caller;

sub main {
	my $self = shift;
	sub logger { print @_, "\n"; }
	my %users = get_users();
	while ( my $k = each (%users) ) {
		print "$k\t:: $users{$k}[0]:$users{$k}[1]\n";
	}
}

sub get_users {
	# $users{USERNAME}[0] - UID
	# $users{USERNAME}[1] - GID
	my $users_ref = shift;
	open(PASS, '<', '/etc/passwd') or main::logger("Unable to open passwd: $!");
	my @line = ();
	while (<PASS>) {
		@line = split ':', $_;
		if ( ! exists $users_ref->{$line[2]} ) {
			$users_ref->{$line[2]} = $line[0];
		}
	}
	close(PASS);
	return 1;
}

1;
