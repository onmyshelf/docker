#!/bin/bash
#
#  Install script for OnMyShelf docker
#
#  Usage: ./install.sh [-v VERSION]
#

#
#  Functions
#

# Check if command(s) exists
# Usage: lb_command_exists COMMAND [COMMAND...]
lb_command_exists() {
	which "$@" &> /dev/null
}


# Ask a question to be answered by y/n
# Usage: yesno QUESTION
yesno() {
	echo -n "$* (y/N) "
	read choice
	[ "$(echo "$choice" | tr '[:upper:]' '[:lower:]')" = y ]
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

cd "$(dirname "$0")" || exit

# go to version (if specified)
if [ "$1" = -v ] ; then
	git checkout "$2" || exit
	echo
fi

# check if docker command exists
if ! lb_command_exists docker ; then
	echo "Docker is required but seems to be missing on this system."
	if yesno "Do you want to install it?" ; then
		install docker || exit
	fi
	echo
fi

# check if docker-compose command exists
if ! lb_command_exists docker-compose ; then
	echo "The docker-compose tool is required but seems to be missing on this system."
	if yesno "Do you want to install it?" ; then
		install docker-compose || exit
	fi
	echo
fi

if ! [ -f .env ] ; then
	echo "Copy environment variable..."
	cp env.example .env || exit
fi

echo "Starting OnMyShelf..."
docker-compose up -d || exit

echo
echo "OnMyShelf is ready!"
