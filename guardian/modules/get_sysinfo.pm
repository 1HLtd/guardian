#!/usr/bin/perl
use strict;
use warnings;

package sysinfo;
require Exporter;
our @ISA		= qw(Exporter);
our @EXPORT		= qw(get_sysinfo);
our $VERSION	= 0.01;

# executes at run-time, unless used as module
__PACKAGE__->main() unless caller;

sub main {
	require 'sys/syscall.ph';
	my $self = shift;
 	sub logger { print @_, "\n"; }
	my @sys = get_sysinfo();
	print "Uptime: $sys[0]
Load1: $sys[1]
Load5: $sys[2]
Load15: $sys[3]
Total RAM: $sys[4]
Free RAM: $sys[5]
Shared RAM: $sys[6]
Buffer RAM: $sys[7]
Total Swap: $sys[8]
Free Swap: $sys[9]
Total number of processes: $sys[10]\n";
}

sub get_sysinfo {
	my $buf = "\0" x 64;
	syscall(&SYS_sysinfo, $buf) == 0 or logger "get_sysinfo: $!";
# 	my ($uptime, $load1, $load5, $load15, $totalram, $freeram, $sharedram, $bufferram, $totalswap, $freeswap, $procs) = unpack "l L9 S", $buf;
	my @sysinfo = unpack "l L9 S", $buf;
	return @sysinfo;
}

1;