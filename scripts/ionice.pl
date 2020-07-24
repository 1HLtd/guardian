#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(strftime);

require 'sys/syscall.ph';

my ($prio, $class) = (0, 0);
our %ioclass = ( 0 => 'none', 1 => 'realtime', 2 => 'best-effort', 3 => 'idle' );

sub logger {
	print strftime('%b %d %H:%M:%S', localtime(time)) . ' ' . $_[0] ."\n";
}

sub get_ionice {
	my $pid = shift;
	my $prio = -3;
	my $class = 0;
	my %io = (
		4 => [0,0],
		8192 => [0,1], 8193 => [1,1], 8194 => [2,1], 8195 => [3,1],	8196 => [4,1], 8197 => [5,1], 8198 => [6,1], 8199 => [7,1],
		16384 => [0,2],	16385 => [1,2], 16386 => [2,2], 16387 => [3,2], 16388 => [4,2], 16389 => [5,2], 16390 => [6,2], 16391 => [7,2], 
		24583 => [0,3]
	);

	if (!defined($pid)) {
		logger "Wrong arguments set to get_ionice()";
		return -2;
	}
	
	$prio = syscall(&SYS_ioprio_get, 1, $pid);
	if ($prio == -1) {
	    logger "Unable to execute syscall SYS_ioprio_get($pid): $!";
		return -1;
	}

	return ($io{$prio}[0],$io{$prio}[1]);
}

sub set_ionice {
	my $pid = shift;
	my $prio = shift;
	my $class = shift;
	my $setio = 0;
	my %io = (
		4 => [0,0],
		8192 => [0,1], 8193 => [1,1], 8194 => [2,1], 8195 => [3,1],	8196 => [4,1], 8197 => [5,1], 8198 => [6,1], 8199 => [7,1],
		16384 => [0,2],	16385 => [1,2], 16386 => [2,2], 16387 => [3,2], 16388 => [4,2], 16389 => [5,2], 16390 => [6,2], 16391 => [7,2], 
		24583 => [0,3]
	);

	if (!defined($pid) || !defined($prio) || !defined($class)) {
		logger "Wrong arguments set to get_ionice()";
		return -3;
	}

	while ( my ($k,$v) = each (%io) ) {
		if ($io{$k}[1] == $class && $io{$k}[0] == $prio) {
			$setio = $k;
			last;
		}
	}

	return 1 if ($setio == 4);
	return -2 if ($setio == 0);

	if (syscall(&__NR_ioprio_set, 1, $pid, $setio) == -1) {
	    logger "Unable to execute syscall __NR_ioprio_set($pid,$setio): $!";
		return -1;
	}

	return 1;
}

($prio, $class) = get_ionice($$);
print "PID: $$\nPrio: $prio Class: $ioclass{$class}\n";
for (my $c=0; $c<=3; $c++) {
	for (my $i=0; $i<=7; $i++) {
		set_ionice($$,$i,$c);
		($prio, $class) = get_ionice($$);
		print "Prio: $prio Class: $ioclass{$class}\n";
	}
}

