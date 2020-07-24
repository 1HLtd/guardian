#!/bin/bash

VERSION='0.0.1'

sa_update_dirs='/usr/bin /usr/local/bin /usr/sbin /usr/local/sbin'
sa_update_bin=''
for sa_update_dir in $sa_update_dirs; do
	if [ ! -x $sa_update_dir/sa-update ]; then
		continue
	fi
	sa_update_bin="$sa_update_dir/sa-update"
	break
done
if [ -z "$sa_update_bin" ]; then
	echo "sa-update is not available in the standard bin paths."
	exit 1
fi

function parse_sa_response {
	case ${1} in
		'0')
			echo "An exit code of 0 means an update was available, and was downloaded and installed successfully if --checkonly was not specified."
			return
		;;
		'1')
			echo "An exit code of 1 means no fresh updates were available."
		;;
		'2')
			echo "An exit code of 2 means that at least one update is available but that a lint check of the site pre files failed. The site pre files must pass a lint check before any updates are attempted."
		;;
		*)
			echo "An exit code of 4 or higher, indicates that errors occurred while attempting to download and extract updates!"
	esac

	exit ${1}
}

# Does SA need update?
echo "Checking for SA updates"
$sa_update_bin -D --checkonly
# Parse the response
parse_sa_response $?

# Yes, update is required
echo "SA updates are available. Trying to install them via $sa_update_bin"
$sa_update_bin -D --refreshmirrors
# Check if update was successfull.
parse_sa_response $?

exit 0
