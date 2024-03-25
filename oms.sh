#!/bin/bash
#
#  OnMyShelf docker: script to execute the oms command inside server container
#

# go into current directory
cd "$(dirname "$0")" || exit

# load functions
source .functions.sh || exit

# run oms command
docker compose exec server oms "$@"
