#!/bin/bash
#
# Mail utility

# Pass all definitions down to called routines
set -a

# Load definitions
source /home/am/bin/java.sh

# Load config
load_config

NAIL=/usr/bin/nail


function nailmail {
echo -n "Sending mail to $to concerning '$subject' ..."
if [ ! -z $attachment ]; then
    echo -n "with attachment '$attachment' " 
$NAIL -s "$subject" -a "$attachment" "$to" << EOM
    $body
EOM
else

$NAIL -S smtp-use-starttls -S ssl-verify=ignore -S smtp-auth=login -S smtp=maunz.de:587 -S from="noreply@opensso.in-silico.ch" -S smtp-auth-user=$NAIL_USER -S smtp-auth-password="$NAIL_USER_PW" -s "$subject" "$to"  << EOM
    $body
EOM
fi
if [ $? -eq 1 ]; then
    echo " FAILED!"
    return 1
else
    echo " done."
    return 0
fi

}

function thundermail {
    echo "Sending mail to $to concerning '$subject' ..."
    echo "thunderbird -compose to='$to',subject='$subject',body='',attachment='$attachment'"
    thunderbird -compose "to='$to',subject='$subject',body='',attachment='$attachment'"
}
