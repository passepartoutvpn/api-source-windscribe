#!/bin/bash
URL="https://windscribe.com/features/large-network"
TPL="template"
SERVERS_SRC="$TPL/servers.html"
SERVERS_DST="$TPL/servers.csv"

echo "Scraping is outdated"
exit 1

mkdir -p $TPL
if ! curl -L $URL >$SERVERS_SRC.tmp; then
    exit
fi
mv $SERVERS_SRC.tmp $SERVERS_SRC
sed -nE "s/^.*<td><i class=\"cflag ([A-Z]+)\".*$/\1,\1,/p" $SERVERS_SRC >$SERVERS_DST

# fix codes inconsistencies
sed -i"" -E "s/GB,GB,/UK,GB,/" $SERVERS_DST
sed -i"" -E "s/US,US,/US-CENTRAL,US,CENTRAL/" $SERVERS_DST
echo "US-EAST,US,EAST" >>$SERVERS_DST
echo "US-WEST,US,WEST" >>$SERVERS_DST
echo "WF-CA,CA,WINDFLIX" >>$SERVERS_DST
echo "WF-UK,GB,WINDFLIX" >>$SERVERS_DST
echo "WF-JP,JP,WINDFLIX" >>$SERVERS_DST
echo "WF-US,US,WINDFLIX" >>$SERVERS_DST

sort $SERVERS_DST >$SERVERS_DST.tmp
mv $SERVERS_DST.tmp $SERVERS_DST
