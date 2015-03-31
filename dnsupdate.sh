#!/bin/bash

USERNAME="" #INWX USERNAME
PASSWORD="" #INWX PASSWORD
DNSID="" #DNS Entry ID
APIHOST="https://api.domrobot.com/xmlrpc/"
OLDIP=$(cat old.ip)
NEWIP=$(curl -s curlmyip.com)

if [ ! "$OLDIP" == "$NEWIP" ]; then
    echo $NEWIP > old.ip
    DATA=$(cat update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSID/g;s/%NEWIP%/$NEWIP/g")
    curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml" > update.log
fi

