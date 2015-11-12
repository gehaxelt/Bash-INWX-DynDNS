#!/bin/bash

# config parameter
USERNAME="" # INWX USERNAME
PASSWORD="" # INWX PASSWORD
DNSIDv4="" # DNS Entry ID (A-record)
DNSIDv6="" # DNS Entry ID (AAAA-record)
APIHOST="https://api.domrobot.com/xmlrpc/" # API URL from inwx.de
CLEARLOG=1 # switch to delete the log in each run turn to 0 for debugging
# get recent and actual IPv4/IPv6
OLDIPv4=$(cat old.ipv4)
OLDIPv6=$(cat old.ipv6)
NEWIPv4=$(curl -s ip4.nnev.de)
NEWIPv6=$(curl -s ip6.nnev.de)

# delete update.log
if [ $CLEARLOG -eq 1 ]; then
	rm update.log
fi

# update the A-record
if [ ! "$OLDIPv4" == "$NEWIPv4" ]; then
    echo $NEWIPv4 > old.ipv4
    echo "\n\nUpdating IPv4..." >> update.log
    DATA=$(cat update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSIDv4/g;s/%NEWIP%/$NEWIPv4/g")
    curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml" >> update.log
fi

# update the AAAA-record
if [ ! "$OLDIPv6" == "$NEWIPv6" ]; then
    echo $NEWIPv6 > old.ipv6
    echo "\n\nUpdating IPv6..." >> update.log
    DATA=$(cat update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSIDv6/g;s/%NEWIP%/$NEWIPv6/g")
    curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml" >> update.log
fi

