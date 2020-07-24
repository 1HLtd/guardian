#!/bin/bash
# 1H - Guardian setup
#
# This code is covered by GPLv2 license

function perl_install {
	second_perl=$(ls -1 /usr/bin/perl.[0-9]* 2>/dev/null)
	for mod in $module_list; do
		if perl -M$mod -e 1 > /dev/null 2>&1; then
			echo "Perl module $mod already installed"
			continue;
		fi
		echo "Installing Perl module: $mod"
		perl -MCPAN -e "install $mod"
		if [ ! -z "$second_perl" ]; then
			$second_perl -MCPAN -e "install $mod"
		fi
	done

	for mod in $module_list; do
		echo "Testing Perl module $mod"
		if ! perl -M$mod -e 1; then
			echo "Perl module $mod is not working properly"
			exit 1;
		fi
		if [ ! -z "$second_perl" ]; then
			if $second_perl -M$mod -e 1; then
				echo "Perl($second_perl) module $mod is not working properly"
				exit 1;
			fi
		fi
	done
}

# Install and check the perl module requirements
module_list='DBD::mysql'
perl_install

exit 0
