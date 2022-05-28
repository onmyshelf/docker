#!/bin/bash
#
#  Upgrade script for OnMyShelf docker
#  https://onmyshelf.cm
#

cd "$(dirname "$0")" || exit

git pull && docker-compose up -d
