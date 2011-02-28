#!/bin/bash
#
# Migration: Copies latest backups over and restores them. Interactive mode, so do this manually

# Pass all definitions down to called routines
set -a

# Load definitions
source /home/am/bin/java.sh

# Load config
load_config

SVCS=$HOME/svcs.xml
POLSQL=$HOME/Pol.sql
SCP="/usr/bin/scp"
MYSQL="/usr/bin/mysql"
SSOADM="/usr/local/bin/ssoadm" # use manually installed version

mv $SVCS $SVCS~
mv $POLSQL $POLSQL~

echo "Importing MySQL backup..."
$SCP $PREF:~/opensso-backup/gestern/Pol.sql $HOME/
if [ -e $POLSQL ]; then
  $MYSQL -u root -padmin123 Pol < $POLSQL
fi

echo "Importing OpenSSO backup..."
$SCP $PREF:~/opensso-backup/gestern/svcs.xml $HOME/
if [ -e $SVCS ]; then
  # Edit and comment IN below lines to enable moving from host to host
  #sed -i 's/opensso.in-silico.ch/j8616.servers.jiffybox.net/g' $SVCS
  #sed -i 's/<Value>\.in-silico\.ch<\/Value>/<Value>\.jiffybox\.net<\/Value>/g' $SVCS
  $SSOADM import-svc-cfg -u $OPENAM_ADMIN -f $OPENAM_PASSWD_PATH -e $OPENAM_SVC_PW -X $SVCS
fi
