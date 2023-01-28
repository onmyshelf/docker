#!/bin/bash
#
#  OnMyShelf docker: script to execute the oms command inside server container
#

# go into current directory
cd "$(dirname "$0")" || exit

# load functions
source .functions.sh || exit

# check docker compose command
if [ -z "$compose_command" ] ; then
	echo "Failed to find docker compose command"
	exit 1
fi

# run oms command
$compose_command exec server oms "$@"
