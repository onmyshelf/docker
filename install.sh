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


# Install a package
# Usage: install PACKAGE
install() {
	local cmd

	# try to find package manager
	for cmd in apt-get dnf yum apk notfound ; do
		lb_command_exists $cmd && break
	done

	case $cmd in
		apt-get)
			if [ $1 = docker ] ; then
				# on debian family, the docker package is named docker.io
				apt-get install -y docker.io
			else
				apt-get install -y $1
			fi
			;;
		dnf|yum)
			$cmd install -y $1
			;;
		apk)
			apk add $1
			;;
		*)
			echo "Package manager not found! Please install $1 manually."
			return 1
			;;
	esac
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
			shift
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

# check if docker command exists
if ! lb_command_exists docker ; then
	echo "Docker is required but seems to be missing on this system."
	if lb_yesno "Do you want to install it?" ; then
		install docker
	fi
	echo

	# re-check docker command
	if ! lb_command_exists docker ; then
		echo "Failed to find docker command."
		echo "Please install it manually: https://docs.docker.com/get-docker/"
		exit 1
	fi
fi

if [ -z "$compose_command" ] ; then
	echo "The docker compose tool is required but seems to be missing on this system."
	echo "Do you want to install it?"
	if lb_yesno "Install docker:" ; then
		install docker-compose-plugin
	fi
	echo

	# re-check if docker compose command exists
	compose_command=$(compose_command)
	if [ -z "$compose_command" ] ; then
		echo "Failed to find docker compose command."
		echo "Please install it manually: https://docs.docker.com/compose/install/"
		exit 1
	fi
fi

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