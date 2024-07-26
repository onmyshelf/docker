#!/bin/bash
#
#  Upgrade script for OnMyShelf docker
#

#
#  Functions
#

# Print usage
print_help() {
	echo "Usage: $0 [OPTIONS]"
	echo "Options:"
	echo "   -v, --version VERSION  Choose a version to install"
	echo "   -b, --backup           Force backup before upgrade"
	echo "   --no-backup            Do not backup before upgrade"
	echo "   -h, --help             Print this help"
}


#
#  Main program
#

# go into current directory
cd "$(dirname "$0")" || exit

# load functions
source .functions.sh || exit

# get options
force_mode=false
while [ $# -gt 0 ] ; do
	case $1 in
		-b|--backup)
			backup=true
			;;
		-v|--version)
			if [ -z "$2" ] ; then
				print_help
				exit 1
			fi
			version=$2
			shift
			;;
		--no-backup)
			backup=false
			;;
		-y|--yes)
			force_mode=true
			;;
		-h|--help)
			print_help
			exit 0
			;;
		-*)
			echo "Unknown option: $1"
			print_help
			exit 1
			;;
	esac
	shift
done

pull_project

check_env

if [ -z "$backup" ] ; then
	if $force_mode ; then
		backup=true
	else
		echo "Do you want to backup your instance before upgrade?"
		if lb_yesno -y "It is highly recommended." ; then
			backup=true
		fi
		echo
	fi
fi

# backup instance
if [ "$backup" = true ] ; then
	echo "Run backup script:"
	docker compose exec server oms-backup || exit 1
	echo
fi

if ! $force_mode ; then
	lb_yesno -y "Proceed to upgrade?" || exit 0
	echo
fi

change_version

start_server
