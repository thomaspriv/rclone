#!/bin/bash

#variables
LOG="/home/user/rclone/logs/$(date +%F)--$(basename $0).log"
#$(date +%F_%T) to include date + time
#$(date +%F) to include date
#$(basename $0) prints the name of the script
LOGLEVEL=INFO
#log levels are DEBUG, INFO, NOTICE and ERROR
SOURCE="source:/Media/Uploading"
DEST="destination:current/archive/"
BACKUPDIR="destination:old"
RCLONECONFIG="/home/user/.config/rclone/rclone.conf"
EXCLUDEFILE="/home/user/rclone/rclone-exclude.txt"
MAXTRANSFERS="6000G"


#limit bandwith on remote
#export RCLONE_CONFIG_NASHOME_BWLIMIT=500

#RClone on a micro instance with less than a gig of memory may crash. Here is what you can do:
#type export GOGC=20 before running rclone.
#remove --fast-list
#lower the value of --transfers=
export GOGC=20

if pidof -o %PPID -x $(basename $0); then

echo $(date "+%Y/%m/%d %H:%M:%S")" WARN : Cron attempted to start the rclone backup but an existing cron job is still running." >> $LOG

exit 1

fi

echo $(date "+%Y/%m/%d %H:%M:%S")" ------------------------------------- " >> $LOG

echo $(date "+%Y/%m/%d %H:%M:%S")" INFO : Cron started the rclone backup." >> $LOG

echo $(date "+%Y/%m/%d %H:%M:%S")" INFO : uploading "$SOURCE" to "$DEST >> $LOG

echo $(date "+%Y/%m/%d %H:%M:%S")" INFO : Starting sync" >> $LOG

#tempory copy for less memory usage
/usr/bin/rclone move $SOURCE $DEST \
--log-level=$LOGLEVEL \
--log-file=$LOG \
--tpslimit=2 \
--tpslimit-burst=5 \
--config=$RCLONECONFIG \
--checkers=1 \
--transfers=3 \
--max-transfer=$MAXTRANSFERS \
--stats-one-line \
--bwlimit="00:15,off 16:45,300" \
--retries=1 \
--create-empty-src-dirs \
--drive-chunk-size=64M \
--order-by modtime,ascending \
--backup-dir=$BACKUPDIR/$(date "+%Y-%m-%d")/  \
--exclude-from=$EXCLUDEFILE \
--drive-stop-on-upload-limit \
--stats=1m \
--min-age 1d \
--stats-one-line \
--drive-use-trash=true

#limit speed to 2MB/s
#--bwlimit=2M \
#--bwlimit="00:30,off 07:30,2M 09.30,2M" \
#exclude dir
#--exclude sourceremote + foldertoexclude/**
#suffix
#--suffix "_$(date +%FT%T%z).bak" \
#nakijken
#--fast-list \
# delete emty source dirs  - so you can see what has been uploaded
#--delete-empty-src-dirs \


echo $(date "+%Y/%m/%d %H:%M:%S")" INFO : sync complete" >> $LOG

echo $(date "+%Y/%m/%d %H:%M:%S")" INFO : Cron finished rclone backup." >> $LOG

echo $(date "+%Y/%m/%d %H:%M:%S")" ------------------------------------- " >> $LOG

exit

