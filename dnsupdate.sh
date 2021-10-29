#!/bin/bash

# curl -s = silent mode
# if [ -z "$OLDIPv4" ] = true if $OLDIPv4 (a string) is null -> https://stackoverflow.com/a/18096739/11458487
# Configuration ################################################################
USERNAME=""         				# Your username at INWX
PASSWORD=""     				# Your password at INWX
DNSIDsv4=("1" "2")       	   		# The ID of the A record
DNSIDsv6=()          				# The ID of the AAAA record
SILENT=false        				# Should the script write a logfile? (true | false)
UPDATEURLv4=""					# Your prefered host to get the IPv4 from
UPDATEURLv6=""					# Your prefered host to get the IPv6 from
################################################################################

DNSIDS=("${DNSIDsv4[@]}" "${DNSIDsv6[@]}")	# Concat the two arrays
APIHOST="https://api.domrobot.com/xmlrpc/" 	# API URL from inwx.de

# Define functions #############################################################
function log() {
	# Only log if $SILENT is false
	$SILENT || echo "$(date) | $1" >> update.log
}

function get_v4_ip() {
	if [ ! -z "$UPDATEURLv4" ]
	then
		log "Host defined, get IP from $UPDATEURLv4"
		# get this from https://unix.stackexchange.com/a/20793
		echo $(host $UPDATEURLv4 | awk '/has address/ { print $4 ; exit }')
		return 0
	fi
	
	if [ ! -e v4.pool ]
	then
		log "No IPv4 pool (v4.pool file) found. Using https://ip4.ident.me/"
		echo $(curl -s "https://v4.ident.me")
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
	if [ ! -z "$UPDATEURLv6" ]
	then
		log "Host defined, get IP from $UPDATEURLv6"
		# get this from https://unix.stackexchange.com/a/20793
		echo $(host $UPDATEURLv6 | awk '/has address/ { print $4 ; exit }')
		return 0
	fi

	if ! [ -e v6.pool ]
	then
		log "No IPv6 pool (v6.pool file) found. Using https://ip6.ident.me/"
		echo $(curl -s "https://v6.ident.me/")
		return 0
	fi

	V6_POOL=$(cat v6.pool)
	for V6_API in $V6_POOL; do
		MAYBE_V6_ADDR=$(curl -s "$V6_API")
		if [[ $MAYBE_V6_ADDR == *":"* ]]; then
			echo "$MAYBE_V6_ADDR"
			return 0
		fi
	done

	return 1
}

# check if the IPv4/6 array exists, then create old.ipv4/6 if not available
# finally get recent IPv4/IPv6
if [ ${#DNSIDsv4[@]} -ne 0 ]
then
	if ! [ -e old.ipv4 ]
	then
		touch old.ipv4
	fi
	OLDIPv4=$(cat old.ipv4)
fi
if [ ${#DNSIDsv6[@]} -ne 0 ]
then
	if ! [ -e old.ipv6 ]
	then
		touch old.ipv6
	fi
	OLDIPv6=$(cat old.ipv6)
fi

################################################################################
# Do the update if needed ######################################################
for DNSID in ${DNSIDS[@]}; do
	# checking if the entry is v4 or not, see https://stackoverflow.com/a/15394738/11458487
	if [[ " ${DNSIDsv4[@]} " =~ " ${DNSID} " ]]; then
		ISIPv4=true
		log "Entry $DNSID, v4 starts"
	else
		ISIPv4=false
		log "Entry $DNSID, v6 starts"
	fi


	# Write "(empty)" if the files are empty for nice output on first run.
	if [ -z "$OLDIPv4" ]; then OLDIPv4="(empty)"; fi
	if [ -z "$OLDIPv6" ]; then OLDIPv6="(empty)"; fi

	# get actual IPv4/IPv6
	if [[ "$ISIPv4" = true ]]; then 
		NEWIPv4=$(get_v4_ip)
		if [[ $? == 1 ]]; then
			echo $NEWIPv4
			log "Could not get a valid IPv4 address from the pool or URL. Is the connection up?"
			exit 1
		fi

		# update the A-record
		if [ ! "$OLDIPv4" == "$NEWIPv4" ]; then
			log "Updating IPv4 to $NEWIPv4"
			DATA=$(cat update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSID/g;s/%NEWIP%/$NEWIPv4/g")
			RET=$(curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml")

			if ! grep -q "Command completed successfully" <<< "$RET"; then
				log "Something went wrong updating the IPv4 address. Check the configuration and make sure you're not using Two-Factor-Authentication."
				exit 1
			fi
			echo $NEWIPv4 > old.ipv4
			log "Updated IPv4: $OLDIPv4 --> $NEWIPv4"
		else
			log "IPv4: No changes"
		fi
	else
		log "Skipping IPv4: No DNS record ID set"
	fi

	if [[ "$ISIPv4" = false ]]; then 
		NEWIPv6=$(get_v6_ip)
		if [[ $? == 1 ]]; then
			log "Could not get a valid IPv6 address from the pool or URL. Is the connection up?"
			exit 1
		fi

		# update the AAAA-record
		if [ ! "$OLDIPv6" == "$NEWIPv6" ]; then
			log "Updating IPv6 to $NEWIPv6"
			DATA=$(cat update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSID/g;s/%NEWIP%/$NEWIPv6/g")
			RET=$(curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml")

			if ! grep -q "Command completed successfully" <<< "$RET"; then
				log "Something went wrong updating the IPv6 address. Check the configuration and make sure you're not using Two-Factor-Authentication."
				exit 1
			fi
			echo $NEWIPv6 > old.ipv6
			log "Updated IPv6: $OLDIPv6 --> $NEWIPv6"
		else
			log "IPv6: No changes"
		fi
	else
		log "Skipping IPv6: No DNS record ID set"
	fi
	
	log "Entry $DNSID finished"
	log "###################################################"
done

################################################################################
