#!/bin/bash

#core shell script/service to mirror Mac printers to Airprint


## Get Computername
ComputerName=`scutil --get ComputerName`

## Get all bonjour printers for printers belonging to $ComputerName and print to file "/tmp/printerlist.txt"
dns-sd -B _ipp._tcp local | colrm 1 73 | grep -v 'Instance Name' | sort | uniq | grep ${ComputerName} > /tmp/printerlist.txt & sleep 1 & killall dns-sd

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

## List printers
printers=`cat /tmp/printerlist.txt`

## For each printer listed, Get the dns-sd full details and print them to file as titled by the printer name.
## Adds the urf format and "transparent=T binary=T" settings which I believe are needed

for i in $printers; do
dns-sd -L "$i" _ipp._tcp local | grep 'product=' | tr -d \'\\\\\(\) | sed "s@pwg-raster@urf URF=W8,SRGB24,CP255,RS300@g" |  sed "s/$/ transparent=T binary=T/" | sed 's/note.*priority/note= priority/g' > /tmp/"$i" & sleep 0 &
killall dns-sd
done

##NEEDS WORK!!
## For each printer, advertise via bonjour
for i in $printers; do
Options=`cat /tmp/"$i"`
## Works but doesnt.. dns-sd -R "$i" _ipp._tcp,_universal . 631"$Options" | tr -d \'\\\\\(\)\" >> /tmp/output.log & sleep 1
## A Bonjour browser shos them as advertised but with no "details"
## Bonjour browser - http://www.tildesoft.com

TheCommand=`dns-sd -R "$i" _ipp._tcp,_universal . 631"$Options" | tr -d \'\\\\\(\)\" >> /tmp/output.log & sleep 1`

$TheCommand

done
IFS=$SAVEIFS

## kills the processes
#killall dns-sd
