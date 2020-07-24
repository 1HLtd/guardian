use strict;
use warnings;

package db_utils;

use DBD::Pg;
use web_error;

require Exporter;
our @ISA		= qw(Exporter);
our @EXPORT		= qw(connect_db disconnect_db);
our $VERSION	= 0.1;

use File::Basename;

sub connect_db {
	# $_[0] - config hash reference. being searched for dbname, dbhost, dbport, dbuser, dbpass
	# $_[1] - auto_commit - default on
	my $attempts = 0;
	my $conn;
	my $config_ref = $_[0];
	my $auto_commit = defined($_[1])? $_[1] : 1;
	do {
		$conn = DBI->connect("DBI:Pg:database=$config_ref->{'dbname'};host=$config_ref->{'dbhost'};port=$config_ref->{'dbport'}",
				$config_ref->{'dbuser'},
				$config_ref->{'dbpass'},
				{ PrintError => 1, AutoCommit => $auto_commit}
		  	) or $attempts++;
	} until ($conn or $attempts > 5);
	$conn or web_error("Could not connect to database: $DBI::errstr");
}

sub disconnect_db {
	$_[0]->disconnect();
}

1;
