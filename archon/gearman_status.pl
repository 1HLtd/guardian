#!/usr/bin/perl

use strict;
use warnings;

use IO::Socket::INET;

my $VERSION = '0.0.1';

my $sock = new IO::Socket::INET (
        PeerAddr => '127.0.0.1',
        PeerPort => 4730,
        Proto => 'tcp',
        Timeout => 5)
	or print "Error: unable to connect to gearman server: $!\n" and exit 1;

print $sock "status\n";

printf "%25s %6s %6s %6s\n", 'function name', 'queue', 'exec', 'worker';

while (<$sock>) {
        last if ($_ =~ /^\.\s*$/);
        my @line = split /\s+/, $_;
        printf "%25s %6d %6d %6d\n", $line[0], $line[1], $line[2], $line[3];
}
close $sock;

exit 0;
