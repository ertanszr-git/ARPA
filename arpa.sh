#!/bin/bash

if [ $1 == "-h" ] || [ $1 == "--help" ]; then
    echo "Usage: arpa [-h,--help] [-s <seconds>] [-i <interface>]"
    echo " -s <seconds> : interval in seconds between each check"
    echo " -i <interface> : interface to listen"
    echo "Example: arpa -s 5 -i eth0"
    echo "Logs will save in /tmp directory"
    exit 0
fi

if [ $# -eq 0 ]; then
    echo "Usage: arpa [-h,--help] [-s <seconds>] [-i <interface>]"
    exit 1
fi

if [ `id -u` -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

while getopts ":s:i" opt; do
    case $opt in
        s)
            INTERVAL=$OPTARG
            ;;
        i)
            INTERFACE=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

IPADDR=`ifconfig $INTERFACE | grep "inet addr" | sed -r 's/^.*addr:(.*)  Bcast.*$/\1/'`

while true; do
    ARPTABLE=`arp -a -n | grep $INTERFACE | grep -v $IPADDR`

    if [ -n "$ARPTABLE" ]; then
        echo "$ARPTABLE"
        echo "$ARPTABLE" > /tmp/ARPA.log
        echo `date +"%Y-%m-%d %H:%M:%S"` > /tmp/ARPA.log.time
    else
       if [ -s /tmp/ArpListener.log ]; then
            echo "$(cat /tmp/NetworkLister.log)"
            echo "$(cat /tmp/NetworkLister.log)" > /tmp/ARPA.log
            echo `date +"%Y-%m-%d %H:%M:%S"` > /tmp/ARPA.log.time
        fi
    fi
    
    sleep $INTERVAL
done
