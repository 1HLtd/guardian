#!/usr/bin/perl
# This code is covered by GPLv2 license

use strict;
use warnings;
use lib qw(/usr/local/1h/lib/perl /usr/local/1h/lib/guardian/modules);
use parse_config;
use mysql_funcs;

sub logger { print @_, "\n" }
sub kill_log { print @_, "\n" }

my $VERSION = '0.1';
my %config = parse_config('/usr/local/1h/etc/guardian.conf');
my $mysql_root_pass = '';
my $mysql_host = '';
my $mysql_idle_check = 1;

get_mysql_details(\$mysql_root_pass,\$mysql_host);
$mysql_idle_check = 0 if (!test_mysql_conn($mysql_root_pass,$mysql_host));

printf "MySQL host: %s\nMySQL idle check is %s\n", $mysql_host, $mysql_idle_check ? 'ENABLED' : 'DISABLED';
if ( $config{'mysql_sleep_query_time'} ) {
	printf "Kill all queries in state 'Sleep' and running for more then %d seconds\n", $config{'mysql_sleep_query_time'};
} else {
	print "Disabled the kill of queries in state 'Sleep'\n";
}
if  ( $config{'mysql_copy_tmp_time'} ) {
	printf "Kill all queries in state 'Copying to tmp table' and running for more then %d seconds\n", $config{'mysql_copy_tmp_time'};
} else {
	print "Disabled the kill of queries in state 'Copying to tmp table'\n";
}
if ( $config{'mysql_long_query_time'} ) {
	printf "Kill all queries that are running for more then %d seconds\n", $config{'mysql_long_query_time'};
} else {
	print "Do not kill long running queries.\n";
}

scan_for_idle_mysql($mysql_root_pass, $mysql_host, \%config);
