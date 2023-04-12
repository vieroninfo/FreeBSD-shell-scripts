#!/bin/sh

rawportname="$1"
portname=`echo $rawportname| tr -d "/"`
snapshotname="zroot/poudriere/ports/$portname@`date +%Y%m%d%H%M`"
found="false"


if [ ! -z $portname ]
then
    for i in `poudriere ports -l | awk '{print $1}'`; do
        if [ $portname = "$i" ]; then
            found="true"
            echo "Creating snapshot \"$snapshotname\""
            zfs snapshot $snapshotname
            rc=$?
            if [ "$rc" = "0" ]
            then
                echo "Updating \"$portname\" port tree"
                poudriere ports -u -p $portname
                rc=$?
                if [ "$rc" = "0" ]
                then
                    echo "Port tree correctly updated"
                    exit 0
                else
                    echo "Issues occured during port tree update! Exiting..."
                    exit $rc
                fi
            else
                echo "Issues with snapshot creation! Exiting..."
                exit $rc
            fi    
        else
            continue
        fi
    done
    if [ $found = "false" ]
    then
        echo "\"$portname\" is not a valid port name! Exiting..."
        exit 1
    fi           
else
    echo "Must specify port name!"
    exit 1
fi

