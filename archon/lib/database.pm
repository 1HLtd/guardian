package database;
use strict;
use warnings;
use Gearman::Client;

require Exporter;
our @ISA        = qw(Exporter AutoLoader);
our @EXPORT     = qw($VERSION init_db db_ping update_server_list clear_status get_down_ids disabled_end_downs);
our $VERSION    = 1.4;

my $conn;
my $server_list = 'SELECT * FROM monitoring.servers';
my $get_downs = 'SELECT srv_id, id FROM problems.durations_24h WHERE end_time IS NULL';
my $clear_status_query = 'SELECT monitoring.clear_status()';
my $populate_missing_query = 'SELECT monitoring.populate_missing()';

my $client = Gearman::Client->new;
$client->job_servers('127.0.0.1:4730');

sub init_db {
	my $conf_ref = shift;
	$conn = DBI->connect(
		$conf_ref->{'pgbase'}, $conf_ref->{'pguser'}, $conf_ref->{'pgpass'},
			{ PrintError => 0, RaiseError => 0, AutoCommit => 1 } 
	) or $client->dispatch_background('log_me', "Conn failed. DBI: $DBI::errstr Sys: $!") and return 0;
	return 1;
}

sub db_ping {
	my $conf_ref = shift;
	my $conn_status = $conn->pg_ping;
	if ($conn_status <= 0) {
		print "Reconnecting ($conn_status)\n" if ($conf_ref->{'debug'});
		$conn = DBI->connect(
			$conf_ref->{'pgbase'}, $conf_ref->{'pguser'}, $conf_ref->{'pgpass'},
			{ PrintError => 0, RaiseError => 0, AutoCommit => 1 }
		) or $client->dispatch_background('log_me', "Conn failed. DBI: $DBI::errstr Sys: $!") and return 0;
	}
	return 1;
}

sub clear_status {
	my $conf_ref = shift;
	$conn = DBI->connect(
		$conf_ref->{'pgbase'}, $conf_ref->{'pguser'}, $conf_ref->{'pgpass'},
		{ PrintError => 0, RaiseError => 0, AutoCommit => 1 }
	) or $client->dispatch_background('log_me', "Conn failed. DBI: $DBI::errstr Sys: $!") and return 0;
	# clear the status tables and populate them with clean data
	$conn->do($clear_status_query) or $client->dispatch_background('log_me', "Failed to DO $clear_status_query. DBI: $DBI::errstr Sys: $!") and return 0;
	return 1;
}

sub disabled_end_downs {
	my $conf_ref = shift;
	my $server_id = shift;

	$conn = DBI->connect(
		$conf_ref->{'pgbase'}, $conf_ref->{'pguser'}, $conf_ref->{'pgpass'},
		{ PrintError => 0, RaiseError => 0, AutoCommit => 1 }
	) or $client->dispatch_background('log_me', "Conn failed. DBI: $DBI::errstr Sys: $!") and return 0;

	my $end_this_down = 'SELECT problems.end_down( ? )';
	my $end_this_down_now = $conn->prepare($end_this_down) or $client->dispatch_background('log_me', "Failed to prepare $end_this_down. DBI: $DBI::errstr Sys: $!") and return 0;
	$end_this_down_now->execute($server_id) or $client->dispatch_background('log_me', "Failed to execute $end_this_down. DBI: $DBI::errstr Sys: $!") and return 0;
	return 1;
}

sub update_server_list {
	# 0 - server id
	# 1 - server name
	# 2 - server ip
	# 3 - group
	# 4 - disabled services for this server
	my $conf_ref = shift;
	my $servers_ref = shift;
	my $counter = 0;

	db_ping($conf_ref);

	my $missing = $conn->prepare($populate_missing_query) or $client->dispatch_background('log_me', "Failed to prepare $populate_missing_query. DBI: $DBI::errstr Sys: $!") and return 0;
	my $get_servers = $conn->prepare($server_list) or $client->dispatch_background('log_me', "Failed to prepare $server_list. DBI: $DBI::errstr Sys: $!") and return 0;

	$missing->execute() or $client->dispatch_background('log_me', "Failed to execute $populate_missing_query. DBI: $DBI::errstr Sys: $!") and return 0;
	$get_servers->execute() or $client->dispatch_background('log_me', "Failed to execute $server_list. DBI: $DBI::errstr Sys: $!") and return 0;

	while (my @data = $get_servers->fetchrow_array) {
		$servers_ref->[$counter][0] = $data[0];
		$servers_ref->[$counter][1] = $data[1];
		$servers_ref->[$counter][2] = $data[2];
		$servers_ref->[$counter][3] = $data[3];
		if (defined($data[4])) {
			my %hash = ();
			foreach(@{$data[4]}) {
				$hash{$_}=0;
			}
			$servers_ref->[$counter][4] = \%hash;
		}
		$counter++;
	}
	$get_servers->finish();
	$missing->finish();
	return 1;
}

sub get_down_ids {
	my %list = ();
	my $conf_ref = shift;

	db_ping($conf_ref);

	my $downs = $conn->prepare($get_downs) or $client->dispatch_background('log_me', "Failed to prepare $get_downs. DBI: $DBI::errstr Sys: $!") and return 0;
	$downs->execute() or $client->dispatch_background('log_me', "Failed to execute $get_downs. DBI: $DBI::errstr Sys: $!") and return 0;

	while (my @data = $downs->fetchrow_array) {
		if (defined($data[0]) && defined($data[1])) {
			$list{$data[0]} = $data[1];
		}
	}
	$downs->finish();
	return %list;
}

1;

__END__

=head1 NAME

ModuleName - short discription of your program

=head1 SYNOPSIS

 how to us your module

=head1 DESCRIPTION

 long description of your module

=head1 SEE ALSO

 need to know things before somebody uses your program

=head1 AUTHOR

 Marian Marinov

=cut
