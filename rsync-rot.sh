#!/bin/bash
#
# Rsync OpenSSO / Tomcat to other server
# Implements 7d/4w rotating backup
# To be called by crontab, since it bootstraps all settings

# Pass all definitions down to called routines
set -a

# Load definitions
source /home/am/bin/java.sh

# Load config
load_config

LOG="/tmp/rsync-log.txt"
RSYNC="/usr/bin/rsync"
SSH="/usr/bin/ssh"



# Backup OpenSSO
TDIR="/home/maunz/opensso-backup"
SDIR="/home/am/opensso"

rm $LOG
if [ -e $SDIR ]; then

    $SSH $PREF "rm -rf $TDIR/vorsiebentagen"
    $SSH $PREF "mv $TDIR/vorsechstagen $TDIR/vorsiebentagen"
    $SSH $PREF "mv $TDIR/vorfuenftagen $TDIR/vorsechstagen"
    $SSH $PREF "mv $TDIR/vorviertagen $TDIR/vorfuenftagen"
    $SSH $PREF "mv $TDIR/vordreitagen $TDIR/vorviertagen"
    $SSH $PREF "mv $TDIR/vorgestern $TDIR/vordreitagen"
    $SSH $PREF "mv $TDIR/gestern $TDIR/vorgestern"
    $RSYNC -a --delete --exclude-from=$HOME/rsync-rot-excl.txt --delete-excluded $SDIR/ $PREF:$TDIR/gestern/ > $LOG
fi


# Backup Apache
TDIR=/home/maunz/apache-tomcat-6.0.26-backup
SDIR=/home/am/apache-tomcat-6.0.26

if [ -e $SDIR ]; then

    $SSH $PREF "rm -rf $TDIR/vorsiebentagen"
    $SSH $PREF "mv $TDIR/vorsechstagen $TDIR/vorsiebentagen"
    $SSH $PREF "mv $TDIR/vorfuenftagen $TDIR/vorsechstagen"
    $SSH $PREF "mv $TDIR/vorviertagen $TDIR/vorfuenftagen"
    $SSH $PREF "mv $TDIR/vordreitagen $TDIR/vorviertagen"
    $SSH $PREF "mv $TDIR/vorgestern $TDIR/vordreitagen"
    $SSH $PREF "mv $TDIR/gestern $TDIR/vorgestern"
    $RSYNC -a --delete --exclude-from=$HOME/rsync-rot-excl.txt --delete-excluded $SDIR/ $PREF:$TDIR/gestern/ >> $LOG

fi
