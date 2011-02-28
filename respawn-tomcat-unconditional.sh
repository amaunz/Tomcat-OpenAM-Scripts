#!/bin/bash
#
# Respawn Tomcat unconditionally
# To be called by crontab, since it bootstraps all settings

# Pass all definitions down to called routines
set -a

# Load definitions
source /home/am/bin/tomcat-java.sh

# Load config
load_config

SEND_MAIL="$HOME/bin/send-mail.sh"
WWWLOGIN="http://opensso.in-silico.ch:8180/opensso/UI/Login"

dir="`pwd`"
if [ ! $dir = $HOME ]; then
    echo "Start only from HOME directory! Aborting."
    exit
fi

if [ -e $SEND_MAIL ]; then
    source $SEND_MAIL
else
    echo "Fatal: mailer not found."
    exit
fi

ran_startup="false"
r=`ps ax | grep java | grep tomcat | grep -v grep`
if [ -z "$r" ]; then 

    echo "Tomcat not running- spawning..."
    mv $HOME/pol.db $HOME/pol.db.bck
    cp $HOME/pol.db.bck $HOME/pol.db
    find $HOME/apache-tomcat-6.0.26/logs -name '*.log' -delete
    find $HOME/apache-tomcat-6.0.26/temp -name '*.xml' -delete
    $HOME/apache-tomcat-6.0.26/bin/startup.sh

    ran_startup="true"
    to="$LDAP_USER_MAIL"
    subject="Tomcat respawned."
    body="`date`: Tomcat not running- spawning..."
    nailmail

else
    echo "Tomcat runs... ok."
fi



if [ $ran_startup == "false" ]; then

        echo "Tomcat running- killing and repawning..."
        echo "Trying to shut down tomcat..."
        $HOME/apache-tomcat-6.0.26/bin/shutdown.sh
        sleep 60
        r=`ps ax | grep java | grep tomcat | grep -v grep`
        if [ -n "$r" ]; then        
            echo "Tomcat not shut down! Forcing..."
            killall -9 java
        fi
        sleep 30
        echo "Copying DB, clearing logs..."
        mv $HOME/pol.db $HOME/pol.db.bck
        cp $HOME/pol.db.bck $HOME/pol.db
        find $HOME/apache-tomcat-6.0.26/logs -name '*.log' -delete
        find $HOME/apache-tomcat-6.0.26/temp -name '*.xml' -delete
        echo "Spawning Tomcat..."
        $HOME/apache-tomcat-6.0.26/bin/startup.sh

        to="$LDAP_USER_MAIL"
        subject="Tomcat killed."
        body="`date`: Tomcat not responding- killed and respawned..."
        nailmail
fi
