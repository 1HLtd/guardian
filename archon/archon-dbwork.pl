#!/usr/bin/perl -w

use strict;
use warnings;

use Storable qw(thaw);
use DBD::Pg;

use lib qw(/usr/local/1h/lib/archon /usr/local/1h/lib/perl);
use Gearman::Client;
use Gearman::Worker;
use daemonize;
use parse_config;

my $VERSION = '0.2.2';
my $config_file = '/usr/local/1h/etc/archon.conf';
my %config = parse_config($config_file);

become_daemon;
$0='Archon-DBworker';

sub RELOAD_CONFIG {
	%config = parse_config($config_file);
	$SIG{HUP} = \&RELOAD_CONFIG;
}
$SIG{HUP}  = \&RELOAD_CONFIG;


our $conn;

my $update_services_info = '
UPDATE monitoring.svc_status
	SET http = ?, mysql = ?, smtp = ?, ftp = ?, cron = ?, pop3 = ?, imap = ?, pgsql = ?, dns = ?, nscd = ?, cpanel = ?,
		hawk = ?, cpustats = ?, mailquota = ?, lifesigns = ?, cpanellogd = ?, zendaemon = ?, ionotify = ?, syslogd = ?, klogd = ?,
		mailscanner = ?, licd = ?, cdp_agent = ?, cdp_server = ?, lfd = ?, clamav = ?
WHERE srv_id = ?';

my $update_server_info = '
UPDATE monitoring.srv_status
	SET last_updated = now(), status = ?, lag = ?, load = ?, proc_count = ?, mail_queue = ?
WHERE srv_id = ?';

my $update_server_status = '
UPDATE monitoring.srv_status
	SET last_updated = now(), status = ?
WHERE srv_id = ?';

my $end_down = 'SELECT problems.end_down( ? )';
my $new_down = 'SELECT problems.new_down( ?, ?, ?, ? )';

my $client = Gearman::Client->new;
my $worker = Gearman::Worker->new;
$client->job_servers('127.0.0.1:4730');
$worker->job_servers('127.0.0.1:4730');

$conn = DBI->connect_cached(
	$config{'pgbase'}, $config{'pguser'}, $config{'pgpass'},
	{ PrintError => 1, RaiseError => 0, AutoCommit => 0 })
	or $client->dispatch_background('log_me', "Unable to connect to database: $DBI::errstr");

sub db_ping {
	if (!$conn->ping) {
		$conn->disconnect;
		$conn = DBI->connect_cached(
			$config{'pgbase'}, $config{'pguser'}, $config{'pgpass'},
			{ PrintError => 1, RaiseError => 0, AutoCommit => 0 })
		or $client->dispatch_background('log_me', "Unable to connect to database: $DBI::errstr");
	}
}

sub get_down_ids {
	# generates ARRAY[] value
	my $svc_ref = shift;
	my $ids = '{';
	while (my $k = each(%{$svc_ref})) {
		next if ($k !~ /^[0-9]+$/);
    	$ids .= $k.',' if ($svc_ref->{$k} == 2);
	}
	$ids =~ s/\,$//;
	$ids .= '}';
	$ids = 'NULL' if ($ids eq '{}');
	return $ids;
}

my $update_status = sub {
#sub update_status {
	# server statuses
	# 0 - not monitored
	# 1 - ok
	# 2 - timeout
	# 3 - service down
	# 4 - all services down
	# 5 - maintenance
	my ($type,$id,$down_id,%svc) = @{ thaw($_[0]->arg) };

	db_ping;

	if ($type == 0) {
		# Timeout/Unable to connect to server
		$conn->do($update_server_status, undef, 2, $id)
			or $client->dispatch_background('log_me', "Unable to execute the reg_timeout_srv query: $DBI::errstr");
	} elsif ($type == 1) {
		# Guardian down or All services down
		$conn->do($update_server_status, undef, 4, $id)
			or $client->dispatch_background('log_me', "Unable to prepare the reg_timeout_all query: $DBI::errstr");
	} elsif ($type == 2) {
		# One or more services down
		$conn->do($update_services_info, undef, $svc{0}, $svc{1}, $svc{2}, $svc{3}, $svc{4}, $svc{5}, $svc{5}, $svc{6}, $svc{7},
			$svc{8}, $svc{9}, $svc{11}, $svc{12}, $svc{13}, $svc{14}, $svc{15}, $svc{16}, $svc{10}, $svc{17}, $svc{18}, 
			$svc{22}, $svc{26}, $svc{29}, $svc{30}, $svc{31}, $svc{32}, $id)
			or $client->dispatch_background('log_me', "Unable to execute the reg_problem_svc query: $DBI::errstr");
		$conn->do($update_server_info, undef, 3, $svc{'lag'}, $svc{'load'}, $svc{'procs'}, $svc{'queue'}, $id)
			or $client->dispatch_background('log_me', "Unable to execute the reg_problem_srv query: $DBI::errstr");
	} elsif ($type == 3) {
		# everything is fine
		$conn->do($update_server_info, undef, 1, $svc{'lag'}, $svc{'load'}, $svc{'procs'}, $svc{'queue'}, $id)
			or $client->dispatch_background('log_me', "Unable to execute the update_ok_server query: $DBI::errstr");
		$conn->do($update_services_info, undef, $svc{0}, $svc{1}, $svc{2}, $svc{3}, $svc{4}, $svc{5}, $svc{5}, $svc{6}, $svc{7},
			$svc{8}, $svc{9}, $svc{11}, $svc{12}, $svc{13}, $svc{14}, $svc{15}, $svc{16}, $svc{10}, $svc{17}, $svc{18},
			$svc{22}, $svc{26}, $svc{29}, $svc{30}, $svc{31}, $svc{32}, $id)
			or $client->dispatch_background('log_me', "Unable to execute the update_ok_services query: $DBI::errstr");
		if ($down_id > 0) {
			$conn->do($end_down, undef, $id)
				or $client->dispatch_background('log_me', "Unable to execute the end_down query: $DBI::errstr");
		}
	}

	$conn->commit;

	undef $type;
	undef $id;
	undef $down_id;
	undef %svc;
};

my $store_down = sub {
#sub store_down {
	# types of downs
	# 0 - unable to connect ( timeout or error in the connection )
	# 1 - invalid response ( unable to validate the output from lifesigns )
	# 2 - one or more services were detected as down
	my ($type, $server, $comment, %services) = @{ thaw($_[0]->arg) };
	db_ping;
	$comment = 'NULL' if ($comment eq '');
	if ($type == 0) {
		# Timeout/Unable to connect to server
		# down_id
		# server_id
		# down_type
		# svc_list
		# comment
		$conn->do($new_down, undef, $type, $server, $comment, '{}')
			or $client->dispatch_background('log_me', "Unable to execute the timeout_down query: $DBI::errstr");
	} elsif ($type == 1) {
		# Guardian down or All services down
		$conn->do($new_down, undef, $type, $server, $comment, '{}')
			or $client->dispatch_background('log_me', "Unable to execute the validate_down query: $DBI::errstr");
	} elsif ($type == 2) {
		# One or more services down
		if (exists($services{'load'})) {
			$conn->do($new_down, undef, $type, $server, $comment, get_down_ids(\%services))
				or $client->dispatch_background('log_me', "Unable to execute the service_down query: $DBI::errstr");
		} else {
			$conn->do($new_down, undef, $type, $server, $comment, '{}')
				or $client->dispatch_background('log_me', "Unable to execute the service_down0 query: $DBI::errstr");
		}
	}
	$conn->commit;
	undef $type;
	undef $server;
	undef $comment;
	undef %services;
};

$worker->register_function( store_down => $store_down );
$worker->register_function( update_status => $update_status );
$worker->work while 1;

__END__

=head1 NAME

 Database.pl - when run it switches to Archon-DBworker

=head1 SYNOPSIS

 This worker reads the archon.conf and services.conf configuration files.
 Then connects to the PG DB and to the defined Gearman JobServer

 It is primary used to update the status of a single server in the DB and save any detected downs.

 It exports two functions:  update_status & store_down

=head1 DESCRIPTION

 The tool is both Gearman Worker and a Client
 It is a client to the log_me function, used to log any errors that may occure
 The tool contains 3 functions


=head2 db_ping

	This function is used to check the connectivity to DB and reestablish it if broken.
	It does not require parameters, however it uses the global $conn var and the global %config hash.

=head2 store_down

	This function stores any downtimes into the DB, it requires the following parameters
	This function also uses the following global params (its queries):

=head2 update_status

	This function updates the status information about a server, it requires the following parameters:

	$type,$id,$down_id,%svc

	type - what type of update we are doing
		0 Timeout/Unable to connect to server
		1 Guardian down or All services down
		2 One or more services down
		3 Everything is fine
	id - id of the server
	down_id - if non zero value, this is the ID of previously registered down for this server
	svc - hash with the status of all services including guardian lag/load/procs/queue


	This function also uses the following global params:
		conn - the connection handler
		svc  - the list of services
		update_services_info - query to update all services for the server
		update_server_info   - query to server information

=head2 get_down_ids (\%services)

	This function collects all service ids which are marked as down and generate one
	PG array which is then stored into DB

=head1 CHANGELOG

=head2 19.Mar.2010 Marian

 Fixed store_down
 Added comment to store_down
 Added down_id to update_status
 Updated new_down query to insert sys_comment
 Updated all queries to use srv_id instead server_id

=head1 SEE ALSO

 parse_config, daemonize, Gearman::Worker, Gearman::Client, Storable

=head1 AUTHOR

 Marian Marinov <mm@yuhu.biz> (c)
 Project started Mar.2010

=cut
