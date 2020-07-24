#!/usr/bin/perl
package mysql_funcs;
use strict;
use warnings;
use DBD::mysql;
require Exporter;
our @ISA		= qw(Exporter);
our @EXPORT		= qw(get_mysql_details test_mysql_conn scan_for_idle_mysql get_mysql_procs get_max_mysql_conns get_current_mysql_conns);
our $VERSION	= 2.2;

sub get_mysql_details {
	# $_[0] - mysql_root_pass
	# $_[1] - mysql_host
	my $pass_ref = shift;
	my $host_ref = shift;
	if (open(MY, '<', '/root/.my.cnf')) {
		while (<MY>) {
			$$pass_ref = $_ if ($_ =~ /^\s*pass/i);
			$$host_ref = $_ if ($_ =~ /^\s*host/i);
		}
		close(MY);
		$$pass_ref = '' if ($$pass_ref eq '');
		$$host_ref = 'localhost' if ($$host_ref eq '');
		chomp($$pass_ref);
		chomp($$host_ref);
		$$pass_ref =~ s/pass(word)?=//;
		$$host_ref =~ s/host=//;
		if ($$pass_ref =~ /^"/) {
			$$pass_ref =~ s/^"(.*)"$/$1/g;
		} else {
			$$pass_ref =~ s/^(.*)$/$1/g;
		}
		if ($$host_ref =~ /^"/) {
			$$host_ref =~ s/^"(.*)"$/$1/g;
		} else {
			$$host_ref =~ s/^(.*)$/$1/g;
		}
	}
}
sub test_mysql_conn {
	my $rootpass = $_[0];
	my $host = $_[1];
	if ((my $conn = DBI->connect("DBI:mysql:database=mysql:host=$host",'root',$rootpass, { RaiseError => 0 }))) {
		$conn->disconnect;
		return 1;
	} else {
		main::logger("Disabled mysql check because I was unable to connect.\nEither mysql was down or the password was wrong.");
		return 0;
	}
}

sub get_max_mysql_conns {
	# Returns $max_connections or -1 on failure.

	my $rootpass = $_[0];
	my $host = $_[1];

	if ((my $conn = DBI->connect("DBI:mysql:database=mysql:host=$host",'root',$rootpass, { RaiseError => 0, PrintError => 1 }))) {
		$conn->{mysql_auto_reconnect} = 1;

		my $my_procs = $conn->prepare('show variables like "max_connections"') or return -1;
		$my_procs->execute or return -1;
		my $max_connections = $my_procs->fetchrow_hashref->{'Value'};

		if (! defined($max_connections) || $max_connections eq '' || $max_connections == 0) {
			return -1;
		}

		return $max_connections;
	} else {
		return -1;
	}
}

sub get_current_mysql_conns {
	# Returns number of Threads_connected or -1 on failure.

	my $rootpass = $_[0];
	my $host = $_[1];
	my $conn_rotate = $_[2]; # 0 - socket; 1 - tcp

	my $connect_type = (defined($conn_rotate) && $conn_rotate) ? "host=127.0.0.1" : "host=$host";

	# Rotate it
	if (defined($$conn_rotate)) {
		$$conn_rotate = ($$conn_rotate == 0) ? 1 : 0;
	}

	if ((my $conn = DBI->connect("DBI:mysql:database=mysql:$connect_type",'root',$rootpass, { RaiseError => 0, PrintError => 1 }))) {
		$conn->{mysql_auto_reconnect} = 1;

		my $my_procs = $conn->prepare('SHOW status LIKE "Threads_connected"') or return -1;
		$my_procs->execute or return -1;
		my $current_mysql_conns = $my_procs->fetchrow_hashref->{'Value'};

		if (! defined($current_mysql_conns) || $current_mysql_conns eq '') {
			return -1;
		}

		return $current_mysql_conns;
	} else {
		return -1;
	}
}

sub get_mysql_procs {
	my $rootpass = shift;
	my $host = shift;
	my $data_ref = shift;
	my $conn = shift;
	if (($$conn = DBI->connect("DBI:mysql:database=mysql:host=$host",'root',$rootpass, { RaiseError => 0, PrintError => 1 }))) {
		$$conn->{mysql_auto_reconnect}=1;
		my $my_procs = $$conn->prepare('SHOW PROCESSLIST');
		if (defined($my_procs) && $my_procs->execute) {
			push(@{$data_ref}, @{$my_procs->fetchall_arrayref});
		}
	} else {
		push(@{$data_ref}, 0);
		main::logger("Error: $0 :: unable to connect to MySQL");
	}
	
}

sub scan_for_idle_mysql {
	my $rootpass = shift;
	my $host = shift;
	my $config_ref = shift;
	my $excluded_ref = shift;
	my $gather_info_ref = shift;
	defined(my $cpid=fork) or main::logger("Unable to fork MySQL-idle: $!");
	if ($cpid == 0) {
		$0 = 'MySQL-idle';
		main::logger("Starting $0");

		# | Id | User | Host | db | Command | Time | State | Info |
		# | 0  | 1	| 2	| 3  | 4	   | 5	| 6	 | 7	|
		my @gather_info = ();
		my $conn;
		get_mysql_procs($rootpass, $host, \@gather_info, \$conn);
		foreach my $data (@gather_info) {
			if (defined($data->[4]) && defined($data->[5]) && defined($data->[6]) ) {
				local $conn->{PrintError}=0;
				# skip this query if the user exists in the excluded_ref hash
				next if (defined($data->[1]) && exists $excluded_ref->{$data->[1]});

				# skip this query if the db exists in the excluded_ref hash
				next if (defined($data->[3]) && exists $excluded_ref->{$data->[3]});

				# kill sleeping queries
				if ( $config_ref->{'mysql_sleep_query_time'} && 
					 $data->[5] > $config_ref->{'mysql_sleep_query_time'} && 
					( $data->[4] =~ /Sleep/i || $data->[6] =~ /Sleep/i ) ) {
					$conn->do("KILL $data->[0]");
					main::kill_log("Killed MySQL Query ID: $data->[0], Query user: $data->[1], Query time: $data->[5], Query cmd: $data->[4]");
				}
				# kill copy to tmp table queries
				if ( $config_ref->{'mysql_copy_tmp_time'} && 
					 $data->[5] > $config_ref->{'mysql_copy_tmp_time'} && $data->[6] =~ /Copying to tmp table/i ) {
					$conn->do("KILL $data->[0]");
					main::kill_log("Killed MySQL Query ID: $data->[0], Query user: $data->[1], Query time: $data->[5], Query cmd: $data->[4]");

				}
				# kill long queries
				if ( $config_ref->{'mysql_long_query_time'} && $data->[5] > $config_ref->{'mysql_long_query_time'} ) {
					$conn->do("KILL $data->[0]");
					if (defined($data->[7])){ 
						main::kill_log("Killed MySQL Query ID: $data->[0], Query user: $data->[1], Query time: $data->[5], Query cmd: $data->[7]($data->[4])");
					} else {
						main::kill_log("Killed MySQL Query ID: $data->[0], Query user: $data->[1], Query time: $data->[5], Query cmd: $data->[4]");
					}
				}
			}
		}
		$conn->disconnect();
		exit;
	}
}

1;
