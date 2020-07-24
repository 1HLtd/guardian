#!/usr/bin/perl

use strict;
use warnings;

use JSON::XS;
use Data::Dumper;
use Fcntl qw(:flock);

my $queue_file = '/var/cpanel/taskqueue/servers_queue.json';

my $cpanel_queues = {
	total				=>	0,	# There is no such queue but we need it for global cleaned count
	waiting_queue		=>	0,
	deferral_queue		=>	0,
	processing_queue	=>	0,
};

sub lerr {
	print STDERR $_[0] . "\n";
}

sub l {
	# Guardian will log output to its error log
	lerr $_[0];
}

sub quitok {
	l $_[0];
	exit 0;
}

sub quiterr {
	lerr $_[0];
	exit 1;
}

sub json_encode {
	my $json = JSON::XS->new->ascii->allow_nonref;
	# Play nice if debug :)
	$json = JSON::XS->new->ascii->pretty->allow_nonref if ($_[1]);

	return $json->encode($_[0]);
}

sub json_decode {
	my $json = JSON::XS->new->ascii->allow_nonref;
	my $json_results = undef;

	# Play nice if debug :)
	$json = JSON::XS->new->ascii->pretty->allow_nonref if ($_[1]);

	eval {
		$json_results = $json->decode($_[0]);
		if (! $json_results) {
			lerr "json_decode($_[0]): failed reason: $!\n" if ($_[1]);
			return;
		}
	};
	if ($@) {
		lerr "eval(json_decode($_[0])): failed reason: $@" if ($_[1]);
		return;
	}

	return $json_results;
}

if (! -f $queue_file) {
	quitok "Queue file $queue_file is missing. Nothing to do.";
}

my $queue_fh;
my $queue_data = do {
	local $/;
	open $queue_fh, '+<', $queue_file
		or lerr "failed to open $queue_file (rw): $!\n"
		and return;
	flock $queue_fh, LOCK_EX
		or lerr "failed to LOCK_EX $queue_file: $!\n"
		and return;
	<$queue_fh>
};

quitok "$queue_file got no data" if (! $queue_data);

$queue_data = json_decode($queue_data)
	or quiterr "Failed to decode $queue_data: $!";

l "LOADED: " . Dumper($queue_data);

foreach my $queue_object (@{$queue_data}) {
	# This is not a hash
	next if (ref($queue_object) ne 'HASH');

	# This is not the queue hash we are looking for
	next if (! defined($queue_object->{max_running}));
	#l Dumper($queue_object);

	# Traverse all queues that we are aware of
	foreach my $queue_name (keys %{$cpanel_queues}) {
		# Queue object does not contain the queue we are interested in
		next if (! defined($queue_object->{$queue_name}));

		# Loop queued objects and look for apache_restart
		for (my $queue_task_id = 0; $queue_task_id < scalar(@{$queue_object->{$queue_name}}); $queue_task_id++) {

			# We are NOT interested in NON-apache_restart commands
			next if ($queue_object->{$queue_name}->[$queue_task_id]->{_command} ne 'apache_restart');

			# Ok. This should be apache_restart. We need to remove it from this object.
			splice(@{$queue_object->{$queue_name}}, $queue_task_id, 1);

			# Let's count for fun and report
			$cpanel_queues->{$queue_name}++;

			# Count the total forcefully unqueued tasks
			$cpanel_queues->{total}++;
		}
	}
}

if ($cpanel_queues->{total} > 0) {
	seek ($queue_fh, 0, 0)
		or quiterr "Failed to seek $queue_file from start: $!";

	truncate($queue_fh, 0)
		or quiterr "Failed to truncate $queue_file: $!";

	print $queue_fh json_encode($queue_data)
		or quiterr "Failed to print to $queue_file file handle: $!";

	l "WROTE" . Dumper($queue_data);

	foreach my $queue_name (sort { $cpanel_queues->{$a} <=> $cpanel_queues->{$b} } keys %{$cpanel_queues}) {
		l "cleaned $cpanel_queues->{$queue_name} $queue_name objects";
	}
}

flock $queue_fh, LOCK_UN
	or quiterr "Failed to unlock $queue_file: $!";

close $queue_fh;

quitok "We are all set";
