#!/bin/bash

MYSQLUSER=root
MYSQLPASSWORD=toor
FTPUSER=root
FTPPASW=toor
DMPFILE="sql_backup"
BKPLST="backup.lst"
WORKDIR="/usr/local/backup"
LOCKFILE="backup.lck"
TIME_STAMP=`date +%Y"%m""%d.%H"%M`
LOGFILE=$TIME_STAMP"_backup.log"
PREFIX=`hostname`
ARCHIVE=$PREFIX.$TIME_STAMP.tar.gz

export PGPASSWORD

cd $WORKDIR
touch $LOGFILE

echo $TIME_STAMP" Backup is started" | tee -a $LOGFILE

if [ -f $LOCKFILE ]; then
	echo "Another backup process is started. Exiting";
	echo $TIME_STAMP" Another backup process is started. Exiting" | tee -a $LOGFILE
	exit 0;
fi

touch $LOCKFILE

if [ ! -f $BKPLST ]; then
	echo "backup.lst not exist - nothing to do";
	echo $TIME_STAMP" Nothing to do. Check lst file" | tee -a $LOGFILE
	rm -f $LOCKFILE
	exit 0;
fi

#pg_dump --host=127.0.0.1 --username=$PGUSER -w --file=$DMPFILE --format=t postgres 2>$LOGFILE
mysqldump --user=$MYSQLUSER --password=$MYSQLPASSWORD database > /tmp/$DMPFILE
cat backup.lst | xargs tar czf $ARCHIVE

ftp -n -p localhost <<EOF
user $FTPUSER $FTPPASW
prompt
binary
put $ARCHIVE /$PREFIX/$ARCHIVE
bye
EOF

rm -f $DMPFILE
rm -f $LOCKFILE
rm -f $ARCHIVE
#rm -f $LOGFILE






