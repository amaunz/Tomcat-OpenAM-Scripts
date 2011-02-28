#!/bin/bash
# 
# Dump all policy data OpenAM -> XML, MySQL -> SQL file
# To be called by crontab, since it bootstraps all settings

# Pass all definitions down to called routines
set -a

# Load definitions
source /home/am/bin/java.sh

# Load config
load_config

TARGET_DIR="$HOME/opensso"
SSOADM="/usr/local/bin/ssoadm" # use manually installed version
MYSQLDUMP="/usr/bin/mysqldump"


if [ ! -d  $TARGET_DIR ]; then
  echo "Target dir does not exist! Aborting..."
  exit 1
fi

# Dump data- password is always 'upgrade'
echo -n "Dumping... "
echo -n "OpenAM, "
$SSOADM export-svc-cfg -u $OPENAM_ADMIN -f $OPENAM_PASSWD_PATH -e $OPENAM_SVC_PW -o $TARGET_DIR/svcs.xml
echo -n "MySQL, "
$MYSQLDUMP -u root -p$OPENAM_ADMIN_PW Pol > $TARGET_DIR/Pol.sql
echo "done."
