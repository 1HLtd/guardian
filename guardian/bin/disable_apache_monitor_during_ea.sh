#!/bin/bash
# 1H - Stop apache monitoring during easyapache
#
# This code is covered by GPLv2 license

VERSION='0.1.3'

scripts_dirs="/scripts /usr/local/cpanel/scripts"
got_apache=0

function usage () {
	echo "Use: $0 install|uninstall"
	exit 1
}

if [ $# -ne 1 ]; then
	usage
fi

if [ "${1}" != 'install' ] && [ "${1}" != 'uninstall' ]; then
	usage
fi

apache_bin='/usr/local/apache/bin/httpd'
if [ -x "$apache_bin" ] && ( "$apache_bin" -V 2>&1 | grep '^Built by 1H' > /dev/null ); then
	got_apache=1
fi

for scripts_dir in $scripts_dirs; do
	pre_script="$scripts_dir/preeasyapache"
	post_script="$scripts_dir/posteasyapache"

	if [ "${1}" == 'install' ]; then
		# This code is executed on install request

		if [ ! -d "$scripts_dir" ]; then
			# Scripts dir does not exist. This is not a cPanel enabled server so we will just bounce
			continue
		fi
	
		if [ "$got_apache" == '0' ]; then
			# Fix/create preeasyapache script here only in case hive is NOT installed
			if [ -f "$pre_script" ] && ( ! grep 1H_START $pre_script >> /dev/null ); then
				if ( file $pre_script | grep 'perl script' >> /dev/null ); then
					# We have perl
					sed -i "1 a\# 1H_START\nsystem('touch /svcstop/apache');\n# 1H_END\n" $pre_script
				elif ( file $pre_script | grep 'shell script' >> /dev/null ); then
					# We have shell script
					sed -i "1 a\# 1H_START\ntouch /svcstop/apache\n# 1H_END\n" $pre_script
				fi
			elif [ ! -f $pre_script ]; then
				echo -e "#!/bin/bash\n# 1H_START\ntouch /svcstop/apache\n# 1H_END\n" >> $pre_script
				chmod 700 $pre_script
			fi
		elif [ "$got_apache" == '1' ]; then
			# Ok. This server has hive installed so we need to make things in such way so if hive is uninstalled guardian pre script to be copied to correct location
			pre_backup="$pre_script.before.1h"
			if [ -f "$pre_backup" ] && ( ! grep 1H_START "$pre_backup" >> /dev/null ); then
				if ( file $pre_backup | grep 'perl script' >> /dev/null ); then
					# We have perl
					sed -i "1 a\# 1H_START\nsystem('touch /svcstop/apache');\n# 1H_END\n" $pre_backup
				elif ( file $pre_backup | grep 'shell script' >> /dev/null ); then
					# We have shell script
					sed -i "1 a\# 1H_START\ntouch /svcstop/apache\n# 1H_END\n" $pre_backup
				fi
			elif [ ! -f $pre_backup ]; then
				echo -e "#!/bin/bash\n# 1H_START\ntouch /svcstop/apache\n# 1H_END\n" >> $pre_backup
				chmod 700 $pre_backup
			fi
		fi
	
		# Fix/create posteasyapache script here
		# We do not care if hive is installed or not. It would not hurt if we try to remove non existing file
		if [ -f "$post_script" ] && ( ! grep 1H_START $post_script >> /dev/null ); then
			if ( file $post_script | grep 'perl script' >> /dev/null ); then
				sed -i "1 a\# 1H_START\nsystem('rm -f /svcstop/apache');\n# 1H_END\n" $post_script
			elif ( file $post_script | grep 'shell script' >> /dev/null ); then
				sed -i "1 a\# 1H_START\nrm -f /svcstop/apache\n# 1H_END\n" $post_script
			fi
		elif [ ! -f $post_script ]; then
			echo -e "#!/bin/bash\n# 1H_START\nrm -f /svcstop/apache\n# 1H_END\n" >> $post_script
			chmod 700 $post_script
		fi
	elif [ "${1}" == 'uninstall' ]; then
		# This code is executed on uninstall request
		for ea_script in $pre_script $post_script; do
			# Loop on all pre and post scripts in all scripts dirs and erase lines from 1H_START till 1H_END
			if [ ! -f "$ea_script" ]; then
				continue
			fi
	
			sed -i "/1H_START/,/1H_END/d" $ea_script
		done
	fi
done

# Always be nice at the end please ;)
exit 0
