#!/bin/bash
#
#  Install script for OnMyShelf docker
#

#
#  Functions
#

# Print usage
print_help() {
	echo "Usage: $0 [OPTIONS]"
	echo "Options:"
	echo "   -v, --version VERSION  Choose a version to install"
	echo "   -p, --port HTTP_PORT   Choose the default port"
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
		-p|--port)
			if [ -z "$2" ] ; then
				print_help
				exit 1
			fi
			port=$2
			shift
			;;
		-v|--version)
			if [ -z "$2" ] ; then
				print_help
				exit 1
			fi
			version=$2
			shift
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

# copy config if not exists
if ! [ -f .env ] ; then
	echo "Copy environment config file..."
	cp env.example .env || exit
	echo
else
	port=$(get_config HTTP_PORT)
fi

# get http port from config
default_port=$(get_config HTTP_PORT)

if [ -z "$port" ] ; then
	echo -n "Choose the HTTP port [$default_port]: "
	read port
	[ -z "$port" ] && port=$default_port
	echo
fi

# change port if needed
if [ "$port" != "$default_port" ] ; then
	set_config HTTP_PORT "$port"|| exit
fi

change_version

if ! $force_mode ; then
	lb_yesno -y "Proceed to install?" || exit 0
fi

start_server
