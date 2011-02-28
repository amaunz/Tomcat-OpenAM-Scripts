#!/bin/bash
#
# Lists policies associated with a given user account. Returns 0 on success.

# Pass all definitions down to called routines
set -a

# Load definitions
source /home/am/bin/java.sh

# Load config
load_config

HOST="http://opensso.in-silico.ch:8180"
OPENSSO="auth"
POL="pol"
POLO="Pol/opensso-pol"
OPTS="?uri=service=openldap"
CURL="/usr/bin/curl"


ID="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$LDAP_USER")"
PW="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$LDAP_USER_PW")"

cmd1="$CURL -i -d \"username=$LDAP_USER&password=$LDAP_USER_PWD\" $HOST/$OPENSSO/authenticate$OPTS"
res=`eval $cmd1 2>/dev/null`
stat=`echo $res | head -1`
token=`echo $res | grep "token\.id" | sed 's/^.*token.id=//g'` 
token_enc="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$token")"

success=0 # 0 is success!
if [[ $stat =~ "200" ]]; then

    cmd15="$CURL -i -H \"subjectid: $token\" $HOST/$POLO"
    stat=`eval $cmd15 2>/dev/null | head -1`
    if [[ $stat =~ "200" ]]; then
        echo -n ""
    else
        success=1
    fi

    cmd2="$CURL -i -d \"subjectid=$token_enc\" $HOST/$OPENSSO/logout"
    eval $cmd2 >/dev/null 2>&1
else
    success=1
fi

exit $success
