#!/bin/bash

# config parameter
USERNAME="" # INWX USERNAME
PASSWORD="" # INWX PASSWORD
DNSIDv4="" # DNS Entry ID (A-record)
DNSIDv6="" # DNS Entry ID (AAAA-record)
APIHOST="https://api.domrobot.com/xmlrpc/" # API URL from inwx.de
CLEARLOG=1 # switch to delete the log in each run turn to 0 for debugging

# delete update.log
if [ $CLEARLOG -eq 1 ]; then
	rm update.log
fi

# get recent and actual IPv4 and update the A-record
OLDIPv4=$(cat old.ipv4)
NEWIPv4=$(curl -s curlmyip.com)
if [ ! "$OLDIPv4" == "$NEWIPv4" ]; then
    echo $NEWIPv4 > old.ipv4
    echo "\n\nUpdating IPv4..." >> update.log
    DATA=$(cat update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSIDv4/g;s/%NEWIP%/$NEWIPv4/g")
    curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml" >> update.log
fi

# get recent and actual IPv6 and update the AAAA-record
OLDIPv6=$(cat old.ipv6)
NEWIPv6=$(curl -s curlmyip6.com)
if [ ! "$OLDIPv6" == "$NEWIPv6" ]; then
    echo $NEWIPv6 > old.ipv6
    echo "\n\nUpdating IPv6..." >> update.log
    DATA=$(cat update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSIDv6/g;s/%NEWIP%/$NEWIPv6/g")
    curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml" >> update.log
fi

