#!/bin/bash
# Massive Network Game Object Server
# autorestart Script

DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
EXECUTABLE=$( tail -n 1 ${DIR}/../log/mangosd-latest )
LOGPATH=$( tail -n 1 ${DIR}/../log/log-latest )

EXECUTABLE_DIR=$(dirname "${EXECUTABLE}")

crashcount=0

case $1 in
    start )
        screen -dmS tbc-mangos $PWD/$0 detached
        echo "MaNGOS daemon started"
    ;;
    stop )
        screen -X -S tbc-mangos quit
        echo "MaNGOS deamon stopped"
    ;;
    detached )
        while :
        do
                echo `date` >> $LOGPATH/crash.log
                cd $EXECUTABLE_DIR;
                cmd="./mangosd"
                $cmd
                status=$?
                echo "Status after downtime is: $status"
                mv $LOGPATH/Server.log $LOGPATH/Server$(date +%F-%H:%M).log && touch $LOGPATH/Server.log
                if [ "$status" == "2" ]; then
                   echo `date` ", MaNGOS daemon restarted."
                elif [ "$status" == "0" ]; then
                   echo "date" ", MaNGOS daemon shut down."
                   exit 0
                else
                   mv $LOGPATH/crash.log $LOGPATH/crash$(date +%F-%H:%M).log && touch $LOGPATH/crash.log
                   echo "date" ", MaNGOS daemon crashed."
                   ((crashcount=crashcount+1))
                   if [ "$crashcount" -gt 50 ]; then
                      exit 0
                   fi
                fi
        done
        ;;
esac