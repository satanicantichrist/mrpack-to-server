#!/bin/bash

set -e

filepath=$1

tmpdir=$(mktemp -d)

unzip "$filepath" -d "$tmpdir"

useragent="satanicantichrist/mrpack-to-server (satanciantichrist1@protonmail.com)"
data=$(cat "$tmpdir/modrinth.index.json")
packversion=$(echo $data | jq '."versionId"'  | cut -d "\"" -f2)
totalmods=$(echo $data | jq '."files" | length')
fabric=$(echo $data | jq '."dependencies"."fabric-loader"'  | cut -d "\"" -f2)
neoforge=$(echo $data | jq '."dependencies"."neoforge"'  | cut -d "\"" -f2)
minecraft=$(echo $data | jq '."dependencies"."minecraft"'  | cut -d "\"" -f2)
path=server
optionalall=0

mkdir -p "$path/mods"

echo Copying overrides
cp -a $tmpdir/overrides/* $path

for ((i = 0; i < $totalmods; i++)) do

	moddata=$(curl -A $useragent -s https://api.modrinth.com/v2/project/$(echo $data | jq '."files"['$i']."downloads"[0]' | cut -c32-39))
	modname=$(echo $moddata | jq '."slug"' | cut -d "\"" -f2)
	modsha=$(echo $data | jq '."files"['$i']."hashes"."sha1"' | cut -d "\"" -f2)
	dwlink=$(echo $data | jq '."files"['$i']."downloads"[0]' | cut -d "\"" -f2)
	dwpath=$(echo $data | jq '."files"['$i']."path"' | cut -d "\"" -f2)

	rq=$(echo $moddata | jq '."server_side"'  | cut -d "\"" -f2)

	if [[ "$rq" == "required" ]]; then
		echo downloading $modname"..."
		curl -A "$useragent" --progress-bar $dwlink -o $path/$dwpath
	elif [[ "$rq" == "optional" ]]; then

		if [[ $optionalall = 1 ]]; then
			echo downloading $modname"..."
                        curl -A "$useragent" --progress-bar $dwlink -o $path/$dwpath
			continue
		fi

		if [[ $optionalall = 2 ]]; then
                        echo Skipping mod...
                        continue
                fi

		read -p "Do you wan´t to download server optional mod: $modname? [Y/n] [all/none] " optional
		optional=$(echo "$optional" | tr '[:upper:]' '[:lower:]')

		if [[ "$optional" == "all" ]]; then
			optionalall=1
                        echo downloading $modname"..."
                        curl -A "$useragent" --progress-bar $dwlink -o $path/$dwpath
			continue
		fi

		if [[ "$optional" == "none" ]]; then
                        optionalall=2
                        echo Skipping mod...
                        continue
                fi

		if [[ $optional == [Yy] ]]; then
                	echo downloading $modname"..."
                	curl -A "$useragent" --progress-bar $dwlink -o $path/$dwpath
		else
			echo Skipping mod...
		fi
	fi
done

if [[ "$fabric" != "null" ]]; then
	echo Downloading fabric server file
	curl -A "$useragent" --progress-bar -s https://meta.fabricmc.net/v2/versions/loader/$minecraft/$fabric/1.0.1/server/jar -o $path/server.jar
	echo "fabric-loader-version: $fabric; minecraft-version: $minecraft; pack-version: $packversion" > $path/versions.txt
	echo Copying server start script for fabric
	cp default_server_start_script.sh $path/start.sh
	echo Server generated. To start server, run start.sh
fi

if [[ "$neoforge" != "null" ]]; then
        echo Downloading neoforge installer
        curl -A "$useragent" --progress-bar -s https://maven.neoforged.net/releases/net/neoforged/neoforge/$neoforge/neoforge-$neoforge-installer.jar -o $tmpdir/neoforge-installer.jar
	echo Installing neoforge server
	java -jar $tmpdir/neoforge-installer.jar --install-server ./server
        echo "neoforge-version: $neoforge; minecraft-version: $minecraft; pack-version: $packversion" > $path/versions.txt
	echo Server generated. To start server, run run.sh
fi

rm -rf "$tmpdir"
