#!/bin/bash
#
# Respawn Tomcat in case of failure
# To be called by crontab, since it bootstraps all settings

# Pass all definitions down to called routines
set -a

# Load definitions
source /home/am/bin/tomcat-java.sh # Bootstrap
source $HOME/bin/command-timeout.sh

# Load config
load_config

# My variables
SEND_MAIL="$HOME/bin/send-mail.sh"
WWWLOGIN="http://opensso.in-silico.ch:8180/opensso/UI/Login"
TOMCAT_VER="6.0.26"
TOMCAT_DIR="$HOME/apache-tomcat-$TOMCAT_VER"


# Check Dir
dir="`pwd`"
if [ ! $dir = $HOME ]; then
  echo "Start only from HOME directory! Aborting."
  exit
fi

# Check Mailer
if [ -e $SEND_MAIL ]; then
  source $SEND_MAIL
else
  echo "Fatal: mailer not found."
  exit
fi

# Spawn Tomcat
spawn_tc() {
  echo "Spawning Tomcat..."
  find $TOMCAT_DIR/logs -name '*.log' -delete
  find $TOMCAT_DIR/temp -name '*.xml' -delete
  mv $TOMCAT_DIR/logs/catalina.out $TOMCAT_DIR/logs/catalina.out~
  $TOMCAT_DIR/bin/startup.sh

  local to="$LDAP_USER_MAIL"
  local subject="Tomcat respawned."
  local body="`date`: Spawning Tomcat..."
  nailmail
}

shut_tc() {
  $TOMCAT_DIR/bin/shutdown.sh
  sleep 30
  r=`ps ax | grep java | grep tomcat | grep -v grep`
  if [ -n "$r" ]; then        
    echo "Tomcat not shut down! Forcing..."
    killall -9 java
  fi
}

# Check Tomcat running
ran_startup="false"
caught_hanging="false"

r=`ps ax | grep java | grep tomcat | grep -v grep`
if [ -z "$r" ]; then 
  spawn_tc
  ran_startup="true"
else
  echo "Tomcat runs... ok."
fi


# If Tomcat runs, it might hang or work properly
echo -n "  ... check hanging Tomcat ..."

if [ $ran_startup = "false" ]; then

  cmd="$HOME/bin/list_policies.sh $LDAP_USER $LDAP_USER_PW"

  # Check Tomcat hanging.
  #cmd_timeout "$cmd" 20 >/dev/null 2>&1
  cmd_timeout "$cmd" 20
  if [ $? -eq 0 ]; then
    echo " ok."
  else
    echo " hangs!"
    echo "Trying to shut down tomcat..."
    shut_tc
    sleep 15
    spawn_tc
    exit 1
  fi

  echo -n "  ... check functionality ..."
  $cmd
  if [ $? -gt 0 ]; then
    echo " failed!"
    echo "Trying to shut down tomcat..."
    shut_tc
    sleep 15
    spawn_tc
    exit 1
  else
    echo " ok."
  fi
fi
