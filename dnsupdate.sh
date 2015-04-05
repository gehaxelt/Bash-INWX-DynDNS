#!/bin/bash

USERNAME="" #INWX USERNAME
PASSWORD="" #INWX PASSWORD
DNSIDv4="" #DNS Entry ID
DNSIDv6="" #DNS Entry ID
APIHOST="https://api.domrobot.com/xmlrpc/"
OLDIPv4=$(cat old.ipv4)
OLDIPv6=$(cat old.ipv6)
NEWIPv4=$(curl -s curlmyip.com)
NEWIPv6=$(curl -s curlmyip6.com)

if [ ! "$OLDIPv4" == "$NEWIPv4" ]; then
    echo $NEWIPv4 > old.ipv4
    echo "Updating IPv4..." >> update.log
    DATA=$(cat update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSIDv4/g;s/%NEWIP%/$NEWIPv4/g")
    curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml" >> update.log
fi

if [ ! "$OLDIPv6" == "$NEWIPv6" ]; then
    echo $NEWIPv6 > old.ipv6
    echo "Updating IPv6..." >> update.log
    DATA=$(cat update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSIDv6/g;s/%NEWIP%/$NEWIPv6/g")
    curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml" >> update.log
fi

