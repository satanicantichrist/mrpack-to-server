#!/bin/bash

useragent="modrinth .mrpack to server env builder"
data=$(cat modrinth.index.json)
totalmods=$(echo $data | jq '."files" | length')
for ((i = 0; i < $totalmods; i++)) do

moddata=$(curl -A $useragent -s https://api.modrinth.com/v2/project/$(echo $data | jq '."files"['$i']."downloads"[0]' | cut -c32-39))
modname=$(echo $moddata | jq '."slug"' | cut -d "\"" -f2)
modsha=$(echo $data | jq '."files"['$i']."hashes"."sha1"' | cut -d "\"" -f2)
dwlink=$(echo $data | jq '."files"['$i']."downloads"[0]' | cut -d "\"" -f2)
dwpath=$(echo $data | jq '."files"['$i']."path"' | cut -d "\"" -f2)


rq=$(echo $moddata | jq '."server_side"'  | cut -d "\"" -f2)

if [[ "$rq" == "required" ]]; then
	echo downloading $modname"..."
	curl --progress-bar $dwlink -o $dwpath
fi
done
