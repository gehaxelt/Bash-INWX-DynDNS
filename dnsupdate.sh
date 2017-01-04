#!/bin/bash

# Configuration ################################################################
USERNAME=""         # Your username at INWX
PASSWORD=""         # Your password at INWX
DNSIDv4="1"          # The ID of the A record
DNSIDv6=""          # The ID of the AAAA record
SILENT=false        # Should the script write a logfile? (true | false)
################################################################################

APIHOST="https://api.domrobot.com/xmlrpc/" # API URL from inwx.de

function get_v4_ip() {
    if [[ ! -e v4.pool ]]; then
#        log "No IPv4 pool (v4.pool file) found. Using https://ip4.nnev.de/"
        echo $(curl -s "https://ip4.nnev.de/")
        return 0
    fi

    V4_POOL=$(cat v4.pool)
    for V4_API in $V4_POOL; do
        MAYBE_V4_ADDR=$(curl -s "$V4_API")
        if [[ $MAYBE_V4_ADDR =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "$MAYBE_V4_ADDR"
            return 0
        fi
    done

    return 1
}

function get_v6_ip() {
    if ! [ -e v6.pool ]
    then
#        log "No IPv6 pool (v6.pool file) found. Using https://ip6.nnev.de/"
        echo $(curl -s "https://ip6.nnev.de/")
        return 0
    fi

    V6_POOL=$(cat v6.pool)
    for V4_API in $V6_POOL; do
        MAYBE_V6_ADDR=$(curl -s "$V6_API")
        if [[ $MAYBE_V6_ADDR == *":"* ]]; then
            echo "$MAYBE_V6_ADDR"
            return 0
        fi
    done

    return 1
}

function log() {
    # Only log if $SILENT is false
    $SILENT || echo "$(date --utc) | $1" | tee -a update.log
}

# create old.ipv4/6 if not available
if ! [ -e old.ipv4 ]
then
	touch old.ipv4
fi
if ! [ -e old.ipv6 ]
then
	touch old.ipv6
fi

# get recent and actual IPv4/IPv6
OLDIPv4=$(cat old.ipv4)
OLDIPv6=$(cat old.ipv6)
# Write "(empty)" if the files are empty for nice output on first run.
if [ -z "$OLDIPv4" ]; then OLDIPv4="(empty)"; fi
if [ -z "$OLDIPv6" ]; then OLDIPv6="(empty)"; fi

if [[ ! -z "$DNSIDv4" ]]; then 
    NEWIPv4=$(get_v4_ip)
    if [[ $? == 1 ]]; then
        echo $NEWIPv4
        log "Could not get a valid IPv4 address from the pool. Is the connection up?"
        exit 1
    fi

    # update the A-record
    if [ ! "$OLDIPv4" == "$NEWIPv4" ]; then
        echo $NEWIPv4 > old.ipv4
        log "Updating IPv4..."
        DATA=$(cat update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSIDv4/g;s/%NEWIP%/$NEWIPv4/g")
        RET=$(curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml")

        if ! grep -q "Command completed successfully" <<< "$RET"; then
            log "Something went wrong updating the IPv4 address. Check the configuration and make sure you're not using Two-Factor-Authentication."
            exit 1
        fi
        log "Updated IPv4: $OLDIPv4 --> $NEWIPv4"
    else
        log "IPv4: No changes"
    fi
else
    log "Skipping IPv4: No DNS record ID set"
fi

if [[ ! -z "$DNSIDv6" ]]; then 
    NEWIPv6=$(get_v6_ip)
    if [[ $? == 1 ]]; then
        log "Could not get a valid IPv6 address from the pool. Is the connection up?"
        exit 1
    fi

    # update the AAAA-record
    if [ ! "$OLDIPv6" == "$NEWIPv6" ]; then
        echo $NEWIPv6 > old.ipv6
        log "Updating IPv6..."
        DATA=$(cat update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSIDv6/g;s/%NEWIP%/$NEWIPv6/g")
        RET=$(curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml")

        if ! grep -q "Command completed successfully" <<< "$RET"; then
            log "Something went wrong updating the IPv6 address. Check the configuration and make sure you're not using Two-Factor-Authentication."
            exit 1
        fi
        log "Updated IPv6: $OLDIPv6 --> $NEWIPv6"
    else
        log "IPv6: No changes"
    fi
else
    log "Skipping IPv6: No DNS record ID set"
fi
