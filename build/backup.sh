#!/bin/bash
#
#  OnMyShelf backup script
#

exitcode=0

destination=/var/backups/onmyshelf

display() {
	echo "$*" | tee -a "$logfile"
}

date=$(date +%Y-%m-%d-%H%M%S)
logfile=$destination/$date/backup.log

mkdir -p "$destination/$date"
if [ $? != 0 ] ; then
	echo "FAILED to create backup folder!"
	exit 1
fi

display "Backup database..."
mysqldump -h db -u onmyshelf -ponmyshelf onmyshelf 2>> "$logfile" | gzip > "$destination/$date/onmyshelf.sql.gz"
result=${PIPESTATUS[0]}
if [ $result = 0 ] ; then
	display "Done"
else
	display "FAILED (exit code: $result)"
	exitcode=1
fi

exit $exitcode
