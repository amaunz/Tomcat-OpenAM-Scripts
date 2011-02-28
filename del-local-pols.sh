#!/bin/bash
#
# Delete policies associated with a non-resolvable URI
# To be called by crontab, since it bootstraps all settings

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
MYSQL="/usr/bin/mysql"
CURL="/usr/bin/curl"


ID="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$LDAP_USER")"
PW="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$LDAP_USER_PW")"

reply=""
cmd1="$CURL -i -d \"username=$ID&password=$PW\" $HOST/$OPENSSO/authenticate"
reply=`eval $cmd1 2>/dev/null`

token=`echo $reply | grep "token\.id" | sed 's/^.*token.id=//g'` 
token_enc="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$token")"

outfile="/tmp/orders.txt"
rm $outfile
select_all_cmd="$MYSQL -u root -p$PW -e \"use Pol; SELECT * FROM pol INTO OUTFILE '$outfile' FIELDS TERMINATED BY ',';\""
eval "$select_all_cmd"

for l in `cat $outfile`; do
  hn=`echo $l | sed 's/.*,//g' | sed 's/http.*:\/\///g' | sed 's/[:\/].*//g'`
  pn=`echo $l | sed 's/,.*//g'`

  delete=0
  if [[ ! $hn =~ "." ]]; then 
    delete=1
  else
    nsl=$(nslookup $hn)
    if echo $nsl | grep -q "can't find "; then
      delete=1
    fi
  fi

  if [ $delete -eq 1 ]; then

    echo -n "$l"

    cmd2="$CURL -i -X POST -d \"policynames=$pn\" -d \"realm=/\" -d \"submit=\" -H 'Cookie: iPlanetDirectoryPro=\"$token\"' $HOST/opensso/ssoadm.jsp?cmd=delete-policies"
    reply2=`eval $cmd2 2>/dev/null`

    if echo $reply2 | grep -q "Policies were deleted"; then
      echo -n " => ok"
      cmd3="$MYSQL -u root -p$PW -e \"use Pol; DELETE FROM pol WHERE pol='$pn';\""
      if eval $cmd3; then
        echo -n " => ok"
      fi
    fi
    echo 
    sleep 2 # allow some rest
  fi

done

cmd15="$CURL -i -d \"subjectid=$token_enc\" $HOST/$OPENSSO/logout"
reply=`eval $cmd15 2>/dev/null`
