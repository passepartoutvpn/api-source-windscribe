#!/bin/bash
URL="https://windscribe.com/features/large-network"

mkdir -p template
curl -L $URL >template/src.html
sed -nE "s/^.*<td><i class=\"cflag ([A-Z]+)\".*$/\1/p" template/src.html | sort >template/countries.txt
