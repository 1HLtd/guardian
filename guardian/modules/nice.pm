#!/usr/bin/perl
use strict;
use warnings;

package nice;
require Exporter;
our @ISA		= qw(Exporter);
our @EXPORT		= qw(get_ionice set_ionice nice_ionice_procs);
our $VERSION	= 0.03;

# executes at run-time, unless used as module
__PACKAGE__->main() unless caller;

sub main {
	my $self = shift;
	sub logger { print @_, "\n"; }
	if (defined($ARGV[0])) {
		if ($ARGV[0] eq 'get') {
			if (defined($ARGV[1]) && $ARGV[1] =~ /[0-9]/) {
				print get_ionice($ARGV[1]), "\n";
			} else {
				print "Incorrect or missing arguments arguments\nUsage: $0 get PID\n";
			}
		}
		set_ionice($ARGV[1],$ARGV[2],$ARGV[3]) if ($ARGV[0] eq 'set');
	} else {
		print "Usage: $0 get|set PID [class] [prio]\n";
	}
}

# IO Classes
#   0 - none
#   1 - realtime
#   2 - best-effort
#   3 - idle
# i386 syscall ids
# __NR_ioprio_set 289
# __NR_ioprio_get 290
# x86_64 syscall ids
# __NR_ioprio_set 251
# __NR_ioprio_get 252

our %io = (
	0     => [0,0],
	4     => [0,0],
	8192  => [0,1],
	8193  => [1,1],
	8194  => [2,1],
	8195  => [3,1],
	8196  => [4,1],
	8197  => [5,1],
	8198  => [6,1],
	8199  => [7,1],
	16384 => [0,2],
	16385 => [1,2],
	16386 => [2,2],
	16387 => [3,2],
	16388 => [4,2],
	16389 => [5,2],
	16390 => [6,2],
	16391 => [7,2],
	24583 => [0,3]
);


sub get_ionice {
	my $pid = shift;
	my $prio = -3;
	my $class = 0;

	if (!defined($pid)) {
		main::logger("Wrong arguments sent to get_ionice()");
		return -2;
	}
	if ( -d '/proc/'.$pid ) {
		$prio = syscall(290, 1, int($pid));
		if ($prio == -1) {
			main::logger("Unable to execute syscall __NR_ioprio_get($pid): $!");
			return -1;
		}
	} else {
		return -3;
	}
	return ($nice::io{$prio}[0],$nice::io{$prio}[1]);
}

sub set_ionice {
	my $pid = shift;
	my $prio = shift;
	my $class = shift;
	my $setio = 0;

	if (!defined($pid) || !defined($prio) || !defined($class)) {
		main::logger("Wrong arguments sent to set_ionice()");
		return -3;
	}

	while ( my ($k,$v) = each (%nice::io) ) {
		if ($nice::io{$k}[0] == $prio && $nice::io{$k}[1] == $class) {
			$setio = $k;
			last;
		}
	}

# 	return 1 if ($setio == 4);
	return -2 if ($setio == 0);

	if (syscall(289, 1, int($pid), $setio) == -1) {
	    main::logger("Unable to execute syscall __NR_ioprio_set($pid,$setio): $!");
		return -1;
	}

	return 1;
}

sub nice_ionice_procs {
	my $proc_ref = shift;
	my $proc_stats_ref = shift;
	my $load_vars_ref = shift;
	my $curload = shift;
	my $cmd;
	# clear old not existing processes from the niced hash
	if ($proc_stats_ref->{'niced_count'} > 0) {
		while ( my $k = each(%{$proc_stats_ref->{'niced'}}) ) {
			if (! exists ($proc_ref->{$k}) ) {
				delete($proc_stats_ref->{'niced'}->{$k});
				$proc_stats_ref->{'niced_count'}--;
			}
		}
	}
	# if the load is over the max tipical load(load_vars[2])
	# then apply ionice and nice on the processes and skip the rest of the function
 	if ($curload > $load_vars_ref->[2]) {
		foreach my $pid (@{$proc_stats_ref->{'rsync'}},	@{$proc_stats_ref->{'stopped'}}, @{$proc_stats_ref->{'archivers'}}) {
			# check if the pid exists
			next if (!defined($pid) || $pid <= 0);
			if (! exists $proc_stats_ref->{'niced'}->{$pid}) {
				$proc_stats_ref->{'niced'}->{$pid} = 0;
				my $nice = 0;
				# if the load is over the high load
				if ($curload > $load_vars_ref->[1]) {
					# set ionice prio 0 class 3 [idle]
					$nice = set_ionice($pid,0,3);
				} else {
					# set ionice prio 7 class 2 [best effort]
					$nice = set_ionice($pid,7,2);
				}
				# check if a command name is found
				$cmd = 'none';
				$cmd = $proc_ref->{$pid}[2] if (defined($proc_ref->{$pid}[2]));
				main::logger("Modify nice/ionice($nice) for PID: $pid CMD: $cmd");
				# renice the process
				setpriority(1,$pid,19);
				$proc_stats_ref->{'niced_count'}++;
			}
		}
		return;
	}
	# if the load is less then the max tipical load and we have niced processes
	# set normal nice and ionice priority to all of them
	# and remove them from the niced array
	if ( $proc_stats_ref->{'niced_count'} > 0 && $curload < $load_vars_ref->[2]-1 ) {
		main::logger("Return normal nice levels to niced procs");
		while( my $pid = each (%{$proc_stats_ref->{'niced'}})) {
			setpriority(1,$pid,0);
			set_ionice($pid,4,2);
			delete($proc_stats_ref->{'niced'}->{$pid});
			$proc_stats_ref->{'niced_count'}--;
		}
	}
}

1;
