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

triggername () {
    CONFIGFILE=${1}
    jq -r -M .[2].name "${CONFIGFILE}"
}

triggerrunning() {
    triggers=$(watchman trigger-list "$(pwd)" | jq -r -M .triggers[].name)
    echo "$triggers"
    if [ "${1/triggers}" == "${1}" ]; then
        return 0
    else
        return 1
    fi
}

########## check for dependencies
if [ ! "$(command -v watchman)" ]; then
    echo "failed to find watchman https://facebook.github.io/watchman/"
    exit 255
fi
if [ ! "$(command -v jq)" ]; then
    echo "failed to find jq https://stedolan.github.io/jq/"
    exit 255
fi

########## exit early on help
if [ $# -eq 0 ]; then
    help
    exit 255
fi
if [ "$1" = "help" ]; then
    help
    exit 0
fi

########## determine configuration file
if [ $# -eq 2 ]; then
    CONFIGFILE="$2"
else
    CONFIGFILE=watchman.json
fi
if [ ! -f ${CONFIGFILE} ]; then
    echo "error: Could not open file ${CONFIGFILE}: No such file or directory"
    exit 255
fi

if [ "$(jq -e . "${CONFIGFILE}" > /dev/null 2>&1)" ]; then
    jq -e . ${CONFIGFILE}
    exit 255
fi

########## switch to the specified directory
DIR=$(jq -r -M .[1] "${CONFIGFILE}")
if [ ! -d "${DIR}" ]; then
    echo "error: invalid directory ${DIR}"
    exit 255
fi
cd "${DIR}" || exit
DIR=$(pwd)

########## do the actual work
trigger=$(triggername ${CONFIGFILE})
case "$1" in
    # "help" is dealt with above
    start)
        # startup watchman
        if [ "$(triggerrunning "${trigger}")" ]; then
            echo "\"${trigger}\" already running"
        else
            echo "start watching ${DIR}"
            watchman -o "${DIR}/watchman.log" -j < "${CONFIGFILE}"
        fi
        ;;
    stop)
        # delete the trigger and shutdown watchman
        if [ "$(triggerrunning "${trigger}")" ]; then
            echo "stop watching ${DIR}"
            watchman trigger-del "${DIR}" "${trigger}"
            watchman shutdown-server
        else
            echo "\"${trigger}\" not running"
        fi
        ;;
    status)
        # list all of the wacky triggers
        watchman trigger-list "${DIR}"
        ;;
    *)
        echo "unknown command \"$1\""
        exit 255
        ;;
esac

exit
