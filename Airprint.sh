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
TheCommand=`dns-sd -R "$i" _ipp._tcp,_universal . 631"$Options" | tr -d \'\\\\\(\)\" >> /tmp/output.log & sleep 1`

$TheCommand

done
IFS=$SAVEIFS

## kills the processes
#killall dns-sd
#nqr - almost there

## Working test command
#dns-sd -R "Printer" _ipp._tcp,_universal . 631 \
#txtvers=1 qtotal=1 rp=printers/Brother_DCP_J125 \
#ty="HP CUPS" adminurl= note=Office \
#priority=0 product="(HP1200)" transparent=T binary=T \
#Fax=F Color=T \
#pdl=application/octet-stream,application/pdf,application/postscript,image/jpeg,image/png,image/urf \
#URF=W8,SRGB24,CP255,RS300 UUID=2c7087de-2ab6-2c7087de-2ab6-3770 TLS=1.2 Color=T Scan=T printer-state=3 printer-type=0x480900E

