package daemonize;
use warnings;
use strict;
use POSIX qw(setsid);

require Exporter;
our @ISA        = qw(Exporter);
our @EXPORT     = qw($VERSION become_daemon);
our $VERSION    = 0.3;

sub check_running {
	my $pidfile = shift;
	return 0 if (!defined($pidfile) || ! -f $pidfile);
	open PID, '<', $pidfile or return 0;
	my $pid = <PID>;
	close PID;
	return 0 if ( $pid !~ /^[0-9]+$/);
	if ( -d '/proc/'.$pid ) {
	    die "Already running($pid)\n";
	}
	return 0;
}

sub become_daemon {
	my $pidfile = shift;
	my $have_pid = 0;
	my $pid;
	$have_pid = 1 if (defined($pidfile) && $pidfile !~ /^\s*$/);

	check_running($pidfile) if ($have_pid);

	# become daemon
	defined($pid=fork) or die "DIE: Cannot fork process: $! \n";
	exit if $pid;
	setsid or die "DIE: Unable to setsid: $!\n";
	#umask 0;

	# redirect standart file descriptors to /dev/null
	open STDIN, '</dev/null' or die "DIE: Cannot read stdin: $! \n";
	open STDOUT, '>>/dev/null' or die "DIE: Cannot write to stdout: $! \n";
	open STDERR, '>>/dev/null' or die "DIE: Cannot write to stderr: $! \n";

	if ($have_pid) {
		open PIDFILE, '>', $pidfile or die "DIE: Can't write to pid file($pidfile): $!\n";
		print PIDFILE $$;
		close PIDFILE;
	}
	return 1;
}

1;

__END__

=head1 NAME

 daemonize - Becomes a daemon

=head1 SYNOPSIS

 check_running($pidfile)
 become_daemon($pidfile)


=head1 DESCRIPTION

 Becomes a daemon and checks if it is already running
 Stores the pid in a file which name it gets as the first parameter of the function

=head1 SEE ALSO

 monitor.pl, and all workers

=head1 AUTHOR

 Marian Marinov <mm@yuhu.biz> (c)
 Project started: Nov.2009

=cut
