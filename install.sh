#!/bin/bash
#
#  Install script for OnMyShelf docker
#
#  Usage: ./install.sh [-v VERSION]
#

cd "$(dirname "$0")" || exit

# go to version (if specified)
if [ "$1" = -v ] ; then
	git checkout "$2" || exit
fi

if ! [ -f .env ] ; then
	echo "Copy environment variable..."
	cp env.example .env || exit
fi

echo "Starting OnMyShelf..."
docker-compose up -d || exit

echo
echo "OnMyShelf is ready!"
