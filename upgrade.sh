#!/bin/bash
#
#  Upgrade script for OnMyShelf docker
#
#  Usage: ./upgrade.sh [VERSION]
#

cd "$(dirname "$0")" || exit

# update git
git pull || exit

# go to version (if specified)
if [ -n "$1" ] ; then
	git checkout "$1" || exit
fi

# (re)start containers
docker-compose up -d
