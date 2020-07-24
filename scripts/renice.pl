#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(strftime);
require 'sys/syscall.ph';

my $debug = 0;
sub logger {
        print strftime('%b %d %H:%M:%S', localtime(time)) . ' ' . $_[0] ."\n";
}

sub get_nice_level {
	my $pid =  shift;
	my $level = -2;

	$pid = 0 if (!defined($pid));
	$level = syscall( &SYS_getpriority, 0, $pid );

	if ($level == -1) {
	    logger "Error in syscall(__NR_getpriority): $!\n";
	}


	# logic for interpreting kernel nice levels 1-40
	# the kernel does not handle negative numbers
	if ($level > 20) {
		$level = $level - 20;
		$level = -$level;
	} elsif ($level == 20 ) {
		$level = 0;
	} else {
		$level = 20 - $level;
	}
	logger "$pid has nice level of: $level\n" if $debug;

	return $level;
}

sub set_nice_level {
	my $pid =  shift;
	my $level = shift;
	my $syscall_status = -2;
	if ( !defined($level) ) {
		logger "Wrong arguments sent to set_nice_level()";
		return -3;
	}
	$pid = 0 if !defined($pid);

	$syscall_status = syscall( &SYS_setpriority, 0, $pid, $level );

	if ($syscall_status == -1) {
	    logger "Error in syscall(__NR_setpriority): $!";
		return -4;
	}

	if ($syscall_status == 0) {
		return 1;
	} else {
		return 0;
	}

}

my $nice = 0;
$nice = get_nice_level($$);
print "Nice level: $nice\n";
set_nice_level($$,-12);
$nice = get_nice_level($$);
print "New level: $nice\n";
