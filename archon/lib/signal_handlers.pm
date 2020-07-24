package signal_handlers;
use strict;
use warnings;
use POSIX qw(:sys_wait_h);

require Exporter;
our @ISA        = qw(Exporter);
our @EXPORT     = qw(REAPER RELOAD_CONFIG);
our $VERSION    = 1.1;

sub REAPER {
    while ((waitpid(-1, &WNOHANG)) > 0) {
    	print "raped_childs not defined\n" if !defined($main::raped_childs);
		if ($main::raped_childs >= $main::config{'fork_count'}) {
			printf "Spawned childs %d  -  Rapted %d childs!\n", $main::spawned_childs, $main::config{'fork_count'} if $main::config{'debug'};
			$main::raped_childs=0;
		}
		$main::raped_childs++;
        $main::spawned_childs--;
    }
    $SIG{CHLD} = \&REAPER; # install *after* calling waitpid
};

sub RELOAD_CONFIG {
	print "Rereading configuration!\n" if $main::config{'debug'};
	%mian::config = parse_config($main::CONFIGURATION);
	$SIG{HUP} = \&RELOAD_CONFIG;
}

#$SIG{INT}  = 'IGNORE' if !$main::config{'debug'};
$SIG{CHLD} = \&REAPER;
$SIG{HUP}  = \&RELOAD_CONFIG;

1;
