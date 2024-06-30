#!/bin/bash

tmpdir=$(mktemp -d)

unzip pack.mrpack -d "$tmpdir"

useragent="satanicantichrist/mrpack-to-server (satanciantichrist1@protonmail.com)"
data=$(cat "$tmpdir/modrinth.index.json")
packversion=$(echo $data | jq '."versionId"'  | cut -d "\"" -f2)
totalmods=$(echo $data | jq '."files" | length')
fabric=$(echo $data | jq '."dependencies"."fabric-loader"'  | cut -d "\"" -f2)
minecraft=$(echo $data | jq '."dependencies"."minecraft"'  | cut -d "\"" -f2)
path=server

mkdir -p "$path/mods"

echo Copying overrides
cp -a $tmpdir/overrides/* $path

echo Copying server start script
cp default_server_start_script.sh $path/start.sh

for ((i = 0; i < 0; i++)) do

	moddata=$(curl -A $useragent -s https://api.modrinth.com/v2/project/$(echo $data | jq '."files"['$i']."downloads"[0]' | cut -c32-39))
	modname=$(echo $moddata | jq '."slug"' | cut -d "\"" -f2)
	modsha=$(echo $data | jq '."files"['$i']."hashes"."sha1"' | cut -d "\"" -f2)
	dwlink=$(echo $data | jq '."files"['$i']."downloads"[0]' | cut -d "\"" -f2)
	dwpath=$(echo $data | jq '."files"['$i']."path"' | cut -d "\"" -f2)

	rq=$(echo $moddata | jq '."server_side"'  | cut -d "\"" -f2)

	if [[ "$rq" == "required" ]]; then
		echo downloading $modname"..."
		curl -A "$useragent" --progress-bar $dwlink -o $path/$dwpath
	fi
done

echo Downloading fabric server file
curl -A "$useragent" --progress-bar -s https://meta.fabricmc.net/v2/versions/loader/$minecraft/$fabric/1.0.1/server/jar -o $path/server.jar
echo "fabric-loader-version: $fabric; minecraft-version: $minecraft; pack-version: $packversion" > $path/versions.txt

rm -rf "$tmpdir"
