#!/bin/bash
URL="https://windscribe.com/features/large-network"
HTML="template/src.html"
SERVERS="template/servers.csv"

mkdir -p template
curl -L $URL >$HTML
sed -nE "s/^.*<td><i class=\"cflag ([A-Z]+)\".*$/\1,\1,/p" $HTML >$SERVERS

# fix codes inconsistencies
sed -i "" -E "s/GB,GB,/UK,GB,/" $SERVERS
sed -i "" -E "s/US,US,/US-CENTRAL,US,CENTRAL/" $SERVERS
echo "US-EAST,US,EAST" >>$SERVERS
echo "US-WEST,US,WEST" >>$SERVERS

sort $SERVERS >$SERVERS.tmp
mv $SERVERS.tmp $SERVERS
