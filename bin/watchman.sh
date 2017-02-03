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
    echo ""
    echo "Example configuration file:"
    echo " [\"trigger\", \"/home/username/hotscience\","
    echo " {"
    echo "     \"name\": \"latex\","
    echo "     \"append_files\": true,"
    echo "     \"expression\": ["
    echo "         \"anyof\","
    echo "         [\"match\", \"*.tex\", \"wholename\"]"
    echo "     ],"
    echo "     \"command\": [\"pdflatex\", \"awesome_paper.tex\"]"
    echo "    }"
    echo " ]"

}

########## check for dependencies
if [ ! $(command -v watchman) ]; then
    echo "failed to find watchman https://facebook.github.io/watchman/"
    exit -1
fi
if [ ! $(command -v jq) ]; then
    echo "failed to find jq https://stedolan.github.io/jq/"
    exit -1
fi

########## exit early on help
if [ $# == 0 ]; then
    help
    exit -1
fi
if [ $1 == "help" ]; then
    help
    exit
fi

########## determine configuration file
if [ $# == 2 ]; then
    CONFIGFILE="$2"
else
    CONFIGFILE=watchman.json
fi
if [ ! -f ${CONFIGFILE} ]; then
    echo "error: Could not open file ${CONFIGFILE}: No such file or directory"
    exit -1
fi
jq -e . ${CONFIGFILE} &> /dev/null
if [ $? -ne 0 ]; then
    jq -e . ${CONFIGFILE}
    exit -1
fi

########## switch to the specified directory
DIR=$(jq -r -M .[1] ${CONFIGFILE})
if [ ! -d ${DIR} ]; then
    echo "error: invalid directory ${DIR}"
    exit -1
fi
cd ${DIR}
DIR=$(pwd)

########## do the actual work
case "$1" in
    # "help" is dealt with above
    start)
        # startup watchman
        echo "start watching ${DIR}"
        watchman -o ${DIR}/watchman.log -j < ${CONFIGFILE}
        ;;
    stop)
        # delete the trigger and shutdown watchman
        echo "stop watching ${DIR}"
        watchman trigger-del ${DIR} `jq -r -M .[2].name ${CONFIGFILE}`
        watchman shutdown-server
        ;;
    status)
        # list all of the wacky triggers
        watchman trigger-list ${DIR}
        ;;
    *)
        echo "unknown command \"$1\""
        exit -1
        ;;
esac

exit
