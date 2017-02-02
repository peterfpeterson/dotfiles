#!/bin/sh
######################################################################
# Script to run [watchman](https://facebook.github.io/watchman/)
######################################################################

help () {
    echo "usage: watchman.sh <command> [texfile]"
    echo ""
    echo "help   Show this help"
    echo "start  Delete the triggers and shutdown the watchman server"
    echo "stop   Delete the triggers and shutdown the watchman server"
    echo "status List the triggers in this directory"
}

if [ ! $(command -v watchman) ]; then
    echo "failed to find watchman https://facebook.github.io/watchman/"
    exit -1
fi

if [ ! $(command -v watchman) ]; then
    echo "failed to find jq https://stedolan.github.io/jq/"
    exit -1
fi

if [ $# == 0 ]; then
    help
    exit -1
fi

if [ $# == 2 ]; then
    CONFIGFILE="$2"
else
    CONFIGFILE=watchman.json
fi

case "$1" in
    help)
        help
        exit
        ;;
    start)
        # startup watchman
        echo "start watching"
        watchman -o `pwd`/watchman.log -j < ${CONFIGFILE}
        ;;
    stop)
        # delete the trigger and shutdown watchman
        echo "stop watching"
        watchman trigger-del `pwd` `jq -r -M .[2].name ${CONFIGFILE}`
        watchman shutdown-server
        ;;
    status)
        # list all of the wacky triggers
        watchman trigger-list `pwd`
        ;;
    *)
        echo "unknown command \"$1\""
        exit -1
        ;;
esac

exit
