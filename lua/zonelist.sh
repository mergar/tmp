#!/bin/sh

grep -v ^# /usr/share/zoneinfo/zone.tab |while read code coordinate tz; do
	echo $tz
done



